# <service> API Contract

How the UI talks to <service>. A request goes UI → API Gateway → bridge
→ NATS → <service>, and the reply comes back the same way.

Its NATS subjects use the domain `<domain>`.

## Conventions

These hold for every request below.

**Routing.** The bridge matches the method and the exact path. Paths
have no parameters: an id goes in the query, as `?id=`.

**Subject.** The bridge sends each request on
`tenant.{tenant}.<domain>.request.v1.{resource}.{operation}`. Each
entry gives its `{resource}.{operation}`.

**Request.** On NATS, a MsgPack map:

| Key | Type | Meaning |
|-----|------|---------|
| `payload` | bytes | the request body, as raw JSON; absent when there is no body |
| `query` | map of string to string | the query parameters, as the UI sent them |
| `auth_context` | map | the signed identity of the caller |

The caller's identity also comes as headers: `X-Tenant-ID`,
`X-Org-ID`, `X-User-ID`, `X-Roles`, `X-Session-ID`, `X-Request-ID`.

**Values.** Query values are always strings; each entry says what a
value must look like. Bodies and replies follow JSON, so 64-bit
integers travel as strings.
<!-- Add how this service sends times and binary data, if it does. -->

**Reply.** A MsgPack map, which the UI receives as the same JSON
object. On success:

```json
{"ok": true, "http_status": 200, "record": {}}
```

`record` holds one item; a list comes in `records` instead. On error:

```json
{"ok": false, "http_status": 404, "error": "ERR_NOT_FOUND", "message": "device not found", "detail": "optional extra text"}
```

`http_status` is the HTTP status the UI gets. `detail` is optional.

**Bridge errors.** The bridge can refuse a request before it reaches
<service>, with the same reply shape and one of these codes:
`ERR_UNKNOWN_ROUTE`, `ERR_UNAUTHENTICATED`, `ERR_FORBIDDEN`,
`ERR_INVALID_BODY`, `ERR_AUTH_UNAVAILABLE`.

## Types

<!-- Example: replace with this service's types. -->

### Device

| Field | Type | Required | Meaning |
|-------|------|----------|---------|
| `id` | string | yes | the device's id |
| `name` | string | yes | display name, 1–100 characters |
| `metrics` | map of string to number | no | latest value of each metric; present only when the request asked for it |

## Error Codes

The codes <service> returns. The bridge's own codes are under
Conventions.

| Code | Status | When |
|------|--------|------|
| `ERR_NOT_FOUND` | 404 | the item doesn't exist in the caller's tenant |
| `ERR_INVALID_QUERY` | 400 | a query value is missing or not allowed |

## Requests

<!-- Example: replace with this service's requests. -->

### Get a device

- **Purpose:** returns one device, optionally with its latest metrics.
- **HTTP:** `GET /devices`
- **Subject:** `devices.get`
- **Query:**

  | Name | Required | Value |
  |------|----------|-------|
  | `id` | yes | the device's id |
  | `include` | no | `metrics` to add the device's latest metrics |

- **Body:** none
- **Success:** `200`, `record`: [Device](#device)
- **Errors:**
  - `404 ERR_NOT_FOUND`: no device with that id in the caller's tenant
  - `400 ERR_INVALID_QUERY`: `id` is missing, or `include` isn't `metrics`
