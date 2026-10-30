# <service> Cross-Service Contract

How other services talk to <service> over NATS: the requests it
answers, the events it publishes, and the events it consumes.

Its NATS subjects use the domain `<domain>`.

## Conventions

These hold for every entry below.

**Request subject.** Requests to <service> go to
`tenant.{tenant}.<domain>.request.v1.{resource}.{operation}`. Each
entry gives its `{resource}.{operation}`.

**Request.** A MsgPack map:

| Key | Type | Meaning |
|-----|------|---------|
| `payload` | bytes | the request body, as raw JSON; absent when there is no body |
| `query` | map of string to string | named string parameters |
| `auth_context` | map | the signed identity of the caller |

The caller's identity also comes as headers: `X-Tenant-ID`,
`X-Org-ID`, `X-User-ID`, `X-Roles`, `X-Session-ID`, `X-Request-ID`.

**Reply.** A MsgPack map. On success:

```json
{"ok": true, "http_status": 200, "record": {}}
```

`record` holds one item; a list comes in `records` instead. On error:

```json
{"ok": false, "http_status": 404, "error": "ERR_NOT_FOUND", "message": "device not found", "detail": "optional extra text"}
```

`detail` is optional.

**Event subject.** Events go on
`tenant.{tenant}.{domain}.event.v1.{entity}.{verb}`. A published event
carries the tenant's id in lowercase, or `_` when it belongs to no
tenant. A subscription uses `*` for the tenant. Each entry gives the
full subject.

**Event headers.** The event's id is the `Nats-Msg-Id` header. Its
type is the subject. Its time is the JetStream message time.
`traceparent` and `X-Tenant-ID` come as headers when the publisher has
them.

**Body form.** Each event's body takes one of two forms:

- **flat:** a MsgPack map of the event's fields.
- **envelope:** the request map above, with the event's fields as
  JSON in `payload`. Consumers bound through crud `Events` expect
  this form.

**Delivery.** Each event is delivered one of two ways:

- **JetStream:** stored, and redelivered until a consumer acknowledges
  it.
- **core NATS:** request and reply. The consumer replies with the
  reply map above.

## Types

<!-- Example: replace with this service's types. -->

### Device

| Field | Type | Required | Meaning |
|-------|------|----------|---------|
| `id` | string | yes | the device's id |
| `name` | string | yes | display name, 1–100 characters |

## Error Codes

| Code | Status | When |
|------|--------|------|
| `ERR_NOT_FOUND` | 404 | the item doesn't exist in the caller's tenant |

## Requests We Answer

<!-- Example: replace with this service's requests. -->

### Get a device

- **Purpose:** returns one device.
- **Subject:** `devices.get`
- **Query:**

  | Name | Required | Value |
  |------|----------|-------|
  | `id` | yes | the device's id |

- **Body:** none
- **Success:** `200`, `record`: [Device](#device)
- **Errors:**
  - `404 ERR_NOT_FOUND`: no device with that id in the caller's tenant

## Events We Publish

<!-- Example: replace with this service's events. -->

### Device deleted

- **Subject:** `tenant.{tenant}.<domain>.event.v1.device.deleted`
- **Fires when:** a device has been removed.
- **Body form:** flat
- **Delivery:** JetStream
- **Event id:** random <!-- or: stable, built from <fields>, when duplicates must be dropped -->
- **Fields:**

  | Field | Type | Required | Meaning |
  |-------|------|----------|---------|
  | `id` | string | yes | the removed device's id |
  | `tenant_id` | string | yes | the tenant it belonged to |

## Events We Consume

<!-- Example: replace with the events this service listens to. -->

### Tenant provisioned

- **Subject:** `tenant.*.dal.event.v1.tenant.provisioned`
- **Publisher:** dal, [Tenant provisioned](../../dal/contracts/cross-service.md#tenant-provisioned)
- **Body form we expect:** flat
- **Delivery:** JetStream
- **What we do:** set up the tenant's default device groups.
