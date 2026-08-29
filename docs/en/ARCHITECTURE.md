# Architecture

## Module graph

```text
                     interfaces/http
                           │
                           ▼
                  integration/composition
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
          Core          Topology        Runtime
            │              │              │
            └───────┬──────┴──────┬──────┘
                    ▼             ▼
                 Audit.Sink    outbound ports
                                  │
                                  ▼
                              NetBird adapter
```

Modules are code/domain boundaries inside one process and one database. They are not deployable microservices.

## Dependency rule

A module consumes another module's public contract only. It does not consume that module's `design.md`, raw DTOs or table layout.

- Core has no domain dependency on Topology or Runtime.
- Topology imports Core public user/Peer contracts.
- Runtime imports Core readers/observations and Topology readers/snapshots.
- Audit is a shared append-only sink; it does not own source event semantics.
- NetBird implements outbound ports declared by Core, Runtime and System composition.
- HTTP is an inbound adapter over application interfaces; domain modules do not define routes.
- Integration owns cross-module transactions, process safety and operation gating.

## Composition layer

[`integration/contract.md`](integration/contract.md) defines the callable composition interfaces.

A topology write is one composition transaction:

```text
OperationGate.Authorize(topology_write)
→ Topology mutation and generation increment
→ Runtime.MarkPending increments work_version
→ commit
→ optional in-process wakeup
```

Core inventory application, manual Peer owner/identity changes and their affected-Layer invalidation each use one cross-module transaction. The queue is an optimization; persisted `work_version` and ProjectionState are the durable work source.

## Concurrency model

Each Layer has a monotonic Runtime `work_version`. Reconciliation records the version it targeted and uses compare-and-swap completion, so older attempts cannot clear newer pending work. Exactly one process holds the PostgreSQL advisory instance lock, and Runtime uses one backend writer within that process.

## Safety boundary

OperationGate is checked at application boundaries for local writes and immediately before every NetBird write. There is no capability token passed through modules. A local transaction already in progress may commit during sealing, but it remains pending and cannot reach NetBird until a later active process reconciles it.

## Persistence integration

Each module schema creates only tables/types owned by that module. Cross-module foreign keys are added by [`integration/schema.sql`](integration/schema.sql) after module schemas.

This permits database integrity without making module code query another module's private tables.

## Data ownership

| Owner | Live/persistent data |
|---|---|
| Core | User, Peer, PeerRuntimeState, IdentityBinding, Enrollment, CoreObservation |
| Topology | Layer, Node, Group, Service, Exposure, AccessEdge |
| Runtime | LayerRevision, LayerProjectionState, ReconcileAttempt, NetBirdObjectMap |
| Audit | AuditEntry |
| Integration | cross-module FK and transaction orchestration, no domain records |
| System composition | process-local SafetyState and instance lock |

## Document analogy

- `contract.md` is the public header: operations, types, guarantees, errors and imported/exported interfaces.
- `design.md` is private implementation guidance.
- `schema.sql` is a reference representation owned by the module.
- `acceptance.md` verifies the public contract.
- inbound/outbound adapter contracts live with the adapter boundary, not inside the domain contract.
