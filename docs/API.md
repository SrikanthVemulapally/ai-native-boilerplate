# API Documentation

> **Auto-generated from OpenAPI spec.** Run `pnpm api:docs` to regenerate.
> For manual additions, use the sections below.

---

## Overview

| Property | Value |
|---|---|
| **Base URL (prod)** | `https://api.yourapp.com` |
| **Base URL (staging)** | `https://api.staging.yourapp.com` |
| **API Version** | `v1` |
| **Auth** | Bearer JWT (`Authorization: Bearer <token>`) |
| **Format** | JSON (`Content-Type: application/json`) |
| **Rate limit** | 100 req/min per user, 1000 req/min per org |

---

## Authentication

All authenticated endpoints require:
```
Authorization: Bearer <jwt_token>
```

Tokens are obtained via:
- `POST /auth/login` — email + password
- `POST /auth/magic-link` — magic link
- `POST /auth/refresh` — refresh token

Token lifetime: 15 minutes (access), 30 days (refresh).

---

## Standard Response Shape

### Success
```json
{
  "data": { ... },
  "meta": { "page": 1, "total": 100 }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [{ "field": "email", "message": "Invalid email" }]
  }
}
```

### Error codes
| Code | HTTP | Meaning |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Input failed validation |
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `FORBIDDEN` | 403 | Valid token, insufficient permissions |
| `NOT_FOUND` | 404 | Resource does not exist |
| `CONFLICT` | 409 | Duplicate or state conflict |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

---

## Endpoints

> Replace this section with actual endpoint docs.
> If OpenAPI is enabled, this is auto-generated from `workers/api/src/openapi.ts`.

### Auth

#### POST /auth/login
Login with email and password.

**Request:**
```json
{ "email": "user@example.com", "password": "..." }
```

**Response `200`:**
```json
{
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "...",
    "expires_in": 900
  }
}
```

---

### Users

#### GET /users/me
Get the current authenticated user.

**Response `200`:**
```json
{
  "data": {
    "id": "01j...",
    "email": "user@example.com",
    "name": "Jane Smith",
    "plan": "pro",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

---

## Webhooks

If Stripe is enabled, the following webhook endpoint is registered:

### POST /payments/webhook
Receives Stripe webhook events.

**Headers required:**
```
stripe-signature: t=...,v1=...
```

**Events handled:**
- `checkout.session.completed`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_failed`

---

## Pagination

List endpoints use cursor-based pagination:

```
GET /items?cursor=<cursor>&limit=20
```

**Response:**
```json
{
  "data": [ ... ],
  "meta": {
    "cursor": "next_cursor_value",
    "has_more": true
  }
}
```

---

## Versioning

API version is in the URL path: `/v1/`, `/v2/`, etc.

Breaking changes introduce a new version. Old versions are supported for 12 months after a new version is released. Deprecation notices are sent 90 days in advance.

---

*Last updated: auto-generated from `workers/api/src/openapi.ts`*
*OpenAPI spec: `http://localhost:8787/doc` (dev)*
