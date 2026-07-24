# HTTP Routes

Routes are transport mappings, not domain contracts.

## Core

```text
GET    /api/v1/core/me
GET    /api/v1/core/users
GET    /api/v1/core/users/{user_id}
PATCH  /api/v1/core/users/{user_id}
GET    /api/v1/core/peers
GET    /api/v1/core/peers/{peer_id}
POST   /api/v1/core/peers/{peer_id}/assign-owner
GET    /api/v1/core/netbird-identity-bindings
POST   /api/v1/core/netbird-identity-bindings
GET    /api/v1/core/netbird-identity-bindings/{binding_id}
DELETE /api/v1/core/netbird-identity-bindings/{binding_id}
POST   /api/v1/core/enrollments
GET    /api/v1/core/enrollments/{enrollment_id}
POST   /api/v1/core/enrollments/{enrollment_id}/revoke
```

Reads, user status updates and Enrollment operations invoke `Core.Application.v1`. Peer owner assignment and identity-binding create/delete invoke `System.CoreApplication.v1`, which commits affected-Layer invalidation atomically.

## Topology

```text
GET/POST                /api/v1/topology/layers
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}
GET/POST                /api/v1/topology/layers/{layer_id}/nodes
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/nodes/{node_id}
GET/POST                /api/v1/topology/layers/{layer_id}/groups
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/groups/{group_id}
GET/POST                /api/v1/topology/layers/{layer_id}/services
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/services/{service_id}
GET/POST                /api/v1/topology/layers/{layer_id}/exposures
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/exposures/{exposure_id}
GET/POST                /api/v1/topology/layers/{layer_id}/access-edges
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/access-edges/{edge_id}
```

Reads and writes invoke `System.TopologyApplication.v1`.

## Runtime and Explain

```text
POST /api/v1/topology/explain?basis=applied|desired
GET  /api/v1/topology/access-edges/{edge_id}/explain
GET  /api/v1/topology/layers/{layer_id}/projection
GET  /api/v1/topology/layers/{layer_id}/revisions
GET  /api/v1/topology/layers/{layer_id}/revisions/{revision_id}
GET  /api/v1/topology/reconcile-attempts/{attempt_id}
POST /api/v1/topology/layers/{layer_id}/retry-reconciliation
```

Queries invoke `Runtime.QueryApplication.v1`. Retry invokes `System.TopologyApplication.RetryLayerReconciliation` and schedules durable pending work; it does not perform backend writes in the request.

## System

```text
GET /api/v1/system/status
GET /api/v1/system/netbird/diagnostics
GET /livez
GET /readyz
```

`/api/v1/system/*` invokes authenticated `System.DiagnosticsApplication.v1` operations. `/livez` and `/readyz` are unauthenticated and invoke `GetLiveness`/`GetReadiness`; they expose only the health shape. `readyz` is false in `sealed`. No HTTP unseal or startup recheck mutation exists.
