# Feature Rules: File Uploads
> Loaded when: features.file-uploads=true

## Stack: Cloudflare R2 + Presigned URLs

Never stream file uploads through your Worker — it burns CPU time and memory.
Always use **presigned URLs** so the client uploads directly to R2.

## Architecture

```
Client → POST /api/upload/presign → Worker → R2 presigned URL
Client → PUT [presigned URL] → R2 directly (skips Worker)
Client → POST /api/upload/confirm → Worker → save metadata to DB
```

## Required Files

```
workers/api/src/
  routes/upload/
    presign.ts          ← Generate presigned PUT URL
    confirm.ts          ← Record upload in DB after completion
    delete.ts           ← Delete file from R2 + DB

packages/db/schema/
  uploads.ts            ← Upload metadata table

packages/shared/src/
  types/upload.ts       ← Shared upload types

apps/web/app/
  components/
    FileUpload.tsx      ← Upload component (client-side)
    FilePreview.tsx     ← Preview component
  hooks/
    useUpload.ts        ← Upload hook with progress tracking
```

## Presign Route

```typescript
// workers/api/src/routes/upload/presign.ts
import { R2 } from '@cloudflare/workers-types'
import { z } from 'zod'
import { uuidv7 } from 'uuidv7'

const PresignSchema = z.object({
  fileName: z.string().min(1).max(255),
  fileType: z.string().regex(/^[a-z]+\/[a-z0-9\-\+\.]+$/), // validated MIME
  fileSize: z.number().min(1).max(50 * 1024 * 1024), // 50MB max — adjust per spec
})

export async function presignUpload(c: Context) {
  const user = c.get('user')       // auth required
  const body = await c.req.json()
  const input = PresignSchema.parse(body)

  // Validate file type against allowlist
  if (!ALLOWED_MIME_TYPES.includes(input.fileType)) {
    throw new ValidationError(`File type ${input.fileType} not allowed`)
  }

  const key = `uploads/${user.id}/${uuidv7()}-${sanitizeFileName(input.fileName)}`

  // Generate presigned URL (valid for 5 minutes)
  const url = await c.env.R2.createPresignedUrl('PUT', key, {
    expiresIn: 300,
    httpMetadata: { contentType: input.fileType },
  })

  return c.json({ uploadUrl: url, key })
}

// Allowed MIME types — customize per project requirements
const ALLOWED_MIME_TYPES = [
  'image/jpeg', 'image/png', 'image/webp', 'image/gif',
  'application/pdf',
  'text/csv',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // xlsx
]

function sanitizeFileName(name: string): string {
  return name.replace(/[^a-z0-9\.\-\_]/gi, '-').toLowerCase()
}
```

## Confirm Route

```typescript
// workers/api/src/routes/upload/confirm.ts
const ConfirmSchema = z.object({
  key: z.string(),
  purpose: z.enum(['avatar', 'attachment', 'document']), // define per project
})

export async function confirmUpload(c: Context) {
  const user = c.get('user')
  const { key, purpose } = ConfirmSchema.parse(await c.req.json())

  // Verify file actually exists in R2
  const object = await c.env.R2.head(key)
  if (!object) throw new NotFoundError('Upload')

  // Verify the key belongs to this user (path prefix check)
  if (!key.startsWith(`uploads/${user.id}/`)) {
    throw new ForbiddenError()
  }

  // Save metadata to DB
  const upload = await db.insert(uploads).values({
    id: uuidv7(),
    userId: user.id,
    key,
    purpose,
    fileName: key.split('/').pop() ?? key,
    fileSize: object.size,
    mimeType: object.httpMetadata?.contentType ?? 'application/octet-stream',
    createdAt: new Date(),
  }).returning()

  return c.json({ upload: upload[0] })
}
```

## DB Schema

```typescript
// packages/db/schema/uploads.ts
export const uploads = sqliteTable('uploads', {
  id:         text('id').primaryKey().$defaultFn(() => uuidv7()),
  user_id:    text('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  key:        text('key').notNull().unique(),       // R2 object key
  purpose:    text('purpose').notNull(),             // avatar | attachment | document
  file_name:  text('file_name').notNull(),
  file_size:  integer('file_size').notNull(),        // bytes
  mime_type:  text('mime_type').notNull(),
  created_at: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
})
```

## Client Upload Hook

```typescript
// apps/web/app/hooks/useUpload.ts
export function useUpload() {
  const [progress, setProgress] = useState(0)
  const [error, setError] = useState<string | null>(null)

  async function upload(file: File, purpose: string) {
    setError(null)
    setProgress(0)

    // Step 1: Get presigned URL
    const { uploadUrl, key } = await api.post('/upload/presign', {
      fileName: file.name,
      fileType: file.type,
      fileSize: file.size,
    })

    // Step 2: Upload directly to R2 with progress
    await uploadWithProgress(uploadUrl, file, setProgress)

    // Step 3: Confirm in DB
    const { upload } = await api.post('/upload/confirm', { key, purpose })

    setProgress(100)
    return upload
  }

  return { upload, progress, error }
}

async function uploadWithProgress(url: string, file: File, onProgress: (n: number) => void) {
  return new Promise<void>((resolve, reject) => {
    const xhr = new XMLHttpRequest()
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) onProgress(Math.round((e.loaded / e.total) * 100))
    })
    xhr.addEventListener('load', () => xhr.status < 400 ? resolve() : reject(new Error(`Upload failed: ${xhr.status}`)))
    xhr.addEventListener('error', () => reject(new Error('Upload failed')))
    xhr.open('PUT', url)
    xhr.setRequestHeader('Content-Type', file.type)
    xhr.send(file)
  })
}
```

## Rules

- **Presigned URLs only.** Never stream multipart through a Worker.
- **Always validate MIME type server-side.** Client `file.type` is untrustworthy.
- **50MB max by default.** Adjust per spec — enforce both client-side (UX) and server-side (hard limit).
- **Allowlist MIME types.** Never accept `*/*`. Only types the app actually needs.
- **Sanitize filenames.** Strip special characters before using as R2 key.
- **Namespace by user ID.** `uploads/{userId}/{fileId}-{name}` — prevents path traversal.
- **Confirm step is mandatory.** An unconfirmed upload = orphaned R2 object. Always confirm.
- **Scan with ClamAV or Cloudflare WARP for malware** if accepting documents from untrusted users.
- **Delete from R2 AND DB atomically.** When a user deletes a file, delete both or neither.
- **Lifecycle rules in R2.** Set expiry on `uploads/temp/` prefix for unconfirmed uploads (24h).
- **Serve via CDN URL.** Expose R2 files via `r2.dev` or a custom domain — never presign GET URLs per request.

## Environment Variables Required

```bash
R2_BUCKET_NAME=your-bucket
R2_PUBLIC_URL=https://assets.yourdomain.com  # CDN URL for public files
```
