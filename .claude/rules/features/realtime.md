# Feature Rules: Realtime
> Loaded when: features.realtime=true

## Stack: Cloudflare Durable Objects + Server-Sent Events

Choose the right primitive for the job:

| Need | Solution |
|---|---|
| Server → client push (notifications, live data) | **Server-Sent Events (SSE)** via Worker |
| Bidirectional (chat, collaborative editing, live cursors) | **Durable Objects + WebSocket** |
| Simple polling (refresh every N seconds) | Don't use realtime — just poll |

**Default to SSE.** Only use WebSockets when bidirectional is genuinely required.
SSE is simpler, works with HTTP/2 multiplexing, and reconnects automatically.

## Architecture Options

### Option A: SSE (Server → Client Push)
```
Client → GET /api/stream/[resource] → Worker (streaming response)
                                     ↓ SSE events
Worker ← KV / D1 polling or DO notification
```

### Option B: Durable Objects WebSocket (Bidirectional)
```
Client ←→ WebSocket → Worker → Durable Object (per room/session)
                                ↓ State, broadcasts, persistence
```

## Required Files

```
workers/api/src/
  routes/stream/
    notifications.ts    ← SSE stream for user notifications
    [resource].ts       ← SSE stream for live data updates

  durable-objects/      ← Only if WebSocket is needed
    room.ts             ← DO class for bidirectional sessions
    
packages/shared/src/
  types/realtime.ts     ← Event types (shared client/server)

apps/web/app/
  hooks/
    useSSE.ts           ← SSE client hook with auto-reconnect
    useWebSocket.ts     ← WS client hook (only if DO variant)
  lib/
    realtime.ts         ← Event subscription manager
```

## SSE Implementation (Workers)

```typescript
// workers/api/src/routes/stream/notifications.ts
export async function streamNotifications(c: Context) {
  const user = c.get('user')

  // SSE response — must set these headers exactly
  c.header('Content-Type', 'text/event-stream')
  c.header('Cache-Control', 'no-cache')
  c.header('Connection', 'keep-alive')
  c.header('X-Accel-Buffering', 'no')  // Disable nginx buffering

  const encoder = new TextEncoder()

  const body = new ReadableStream({
    async start(controller) {
      // Send initial connection event
      controller.enqueue(encoder.encode('event: connected\ndata: {}\n\n'))

      // Poll for updates every 2 seconds
      // In production: use D1's watch feature or KV + Queues for push
      const interval = setInterval(async () => {
        try {
          const notifications = await getUnreadNotifications(c.env.DB, user.id)
          
          for (const notif of notifications) {
            const event = formatSSE('notification', notif)
            controller.enqueue(encoder.encode(event))
          }

          // Heartbeat to keep connection alive (every 15s)
          controller.enqueue(encoder.encode(': heartbeat\n\n'))
        } catch {
          controller.close()
          clearInterval(interval)
        }
      }, 2000)

      // Clean up on disconnect
      c.req.raw.signal.addEventListener('abort', () => {
        clearInterval(interval)
        controller.close()
      })
    }
  })

  return new Response(body, { headers: c.res.headers })
}

function formatSSE(event: string, data: unknown): string {
  return `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`
}
```

## Durable Object (WebSocket — only when bidirectional required)

```typescript
// workers/api/durable-objects/room.ts
export class Room {
  private sessions: Map<string, WebSocket> = new Map()
  private state: DurableObjectState

  constructor(state: DurableObjectState, env: Env) {
    this.state = state
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)
    const sessionId = url.searchParams.get('sessionId')!

    // Upgrade to WebSocket
    const pair = new WebSocketPair()
    const [client, server] = Object.values(pair)
    this.state.acceptWebSocket(server)
    this.sessions.set(sessionId, server)

    return new Response(null, { status: 101, webSocket: client })
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const data = JSON.parse(typeof message === 'string' ? message : new TextDecoder().decode(message))
    
    // Handle message types
    switch (data.type) {
      case 'broadcast':
        this.broadcast(data.payload, ws)
        break
      default:
        ws.send(JSON.stringify({ error: 'Unknown message type' }))
    }
  }

  async webSocketClose(ws: WebSocket) {
    // Remove from sessions map
    for (const [id, socket] of this.sessions) {
      if (socket === ws) {
        this.sessions.delete(id)
        break
      }
    }
  }

  private broadcast(payload: unknown, exclude?: WebSocket) {
    for (const ws of this.sessions.values()) {
      if (ws !== exclude && ws.readyState === WebSocket.READY_STATE_OPEN) {
        ws.send(JSON.stringify(payload))
      }
    }
  }
}
```

## Client SSE Hook

```typescript
// apps/web/app/hooks/useSSE.ts
export function useSSE<T>(endpoint: string, eventTypes: string[]) {
  const [data, setData] = useState<Record<string, T>>({})
  const esRef = useRef<EventSource | null>(null)

  useEffect(() => {
    function connect() {
      const es = new EventSource(endpoint, { withCredentials: true })
      esRef.current = es

      eventTypes.forEach(type => {
        es.addEventListener(type, (e) => {
          setData(prev => ({ ...prev, [type]: JSON.parse(e.data) }))
        })
      })

      es.onerror = () => {
        es.close()
        // Auto-reconnect with exponential backoff
        setTimeout(connect, Math.min(1000 * 2 ** reconnectCount++, 30000))
      }
    }

    let reconnectCount = 0
    connect()

    return () => {
      esRef.current?.close()
    }
  }, [endpoint])

  return data
}
```

## Event Type Definitions (Shared)

```typescript
// packages/shared/src/types/realtime.ts
export type RealtimeEvent =
  | { type: 'notification'; data: { id: string; message: string; href?: string } }
  | { type: 'status_update'; data: { entityId: string; status: string } }
  | { type: 'data_refresh'; data: { resource: string } }

// Type-safe event emitter pattern
export function createEvent<T extends RealtimeEvent['type']>(
  type: T,
  data: Extract<RealtimeEvent, { type: T }>['data']
): string {
  return `event: ${type}\ndata: ${JSON.stringify(data)}\n\n`
}
```

## Rules

- **SSE first.** Only escalate to WebSocket when you need client → server messages.
- **Always heartbeat.** Send `: heartbeat\n\n` every 15s or the connection drops silently.
- **Auto-reconnect on client.** EventSource reconnects by default; WebSocket hook must implement exponential backoff.
- **Auth on the SSE/WS endpoint.** SSE requests carry cookies — verify the session. WS initial request: verify in `fetch()` before upgrade.
- **Don't broadcast raw DB rows.** Transform to typed events before sending.
- **Durable Objects have a 128MB memory limit.** Store state in D1 for persistence; use DO only for active session coordination.
- **Rate limit connection attempts.** Prevent reconnect storms: max 1 connection per user per resource.
- **Log connection/disconnection.** Realtime connection issues are hard to debug without logging.
- **Test with network throttling.** Simulate slow connections and disconnects in testing.

## Wrangler Config

```toml
# wrangler.toml additions for Durable Objects
[[durable_objects.bindings]]
name = "ROOM"
class_name = "Room"

[[migrations]]
tag = "v1"
new_classes = ["Room"]
```
