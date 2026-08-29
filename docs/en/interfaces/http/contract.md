# HTTP Interface Contract

**Owner:** HTTP inbound adapter  
**Imports:** `Core.Application.v1`, `System.CoreApplication.v1`, `System.TopologyApplication.v1`, `Runtime.QueryApplication.v1`, `System.DiagnosticsApplication.v1`  
**Exports:** `HTTP.Interface.v1`

## Responsibility

HTTP authenticates requests, constructs `Core.UserContext.v1`, applies transport validation, invokes application contracts and maps results/errors to HTTP. It contains no domain persistence, safety policy or NetBird logic.

## Conventions

- Base path: `/api/v1` except `/livez` and `/readyz`.
- JSON request/response bodies unless explicitly secret-bearing.
- Unknown/extra fields are rejected for command bodies.
- Pagination uses opaque cursor plus bounded `limit`.
- Timestamps use RFC 3339 UTC.
- Resource identifiers are opaque strings.
- `Idempotency-Key` is required only where the application operation declares it.
- `/livez` and `/readyz` are unauthenticated and expose only `System.HealthView.v1`.
- All `/api/v1` routes require authentication unless explicitly documented otherwise.

## Error envelope

```json
{
  "error": {
    "code": "resource_in_use",
    "message": "The resource is referenced.",
    "details": {}
  }
}
```

Stable status mapping:

```text
invalid_argument                                      400
unauthenticated                                       401
forbidden, runtime_sealed                             403
resource_not_found                                    404
resource_in_use, conflict, layer_not_retired,
idempotency_payload_mismatch,
enrollment_secret_not_replayable,
reconciliation_blocked, needs_attention,
remote_conflict, remote_create_outcome_uncertain      409
rate_limited                                          429
invalid_response, remote_readback_mismatch            502
backend_unavailable, unavailable                      503
timeout                                                504
internal_error, audit_unavailable                     500
```

A domain/backend error code remains in the envelope even when multiple codes share one status. Transport code never replaces a specific domain error with a generic conflict when the specific code is available.

## Authorization and safety

The adapter authenticates the actor and invokes the owning application operation. Core or System composition performs process-safety authorization; the owning module/application enforces resource authority. HTTP does not construct or pass safety capabilities.

See [`routes.md`](routes.md) for the route-to-operation mapping.
