# ADR 0005 — Monotonic Work Versions and Gate Boundaries

## Context

Layer generation does not change when a referenced Peer changes, and an in-flight reconciliation could otherwise clear a newer same-generation dirty event. The previous opaque OperationPermit also added cross-module plumbing without creating a true transaction lease.

## Decision

Every Layer ProjectionState owns a monotonic `work_version`; every dirty event increments it, and reconciliation completion compares its captured target version before changing the terminal state. Core inventory application and affected-Layer increments share one transaction.

OperationGate authorizes local mutations at application boundaries and authorizes again immediately before each remote write. No permit/capability is passed through domain interfaces. A local transaction already in progress may commit after sealing, but backend enforcement cannot advance while sealed.

## Consequences

Queue loss and stale reconciliation cannot lose work. The safety interface is smaller and honest about its guarantee: it blocks new operations and backend writes, but is not a distributed lock or database transaction lease.
