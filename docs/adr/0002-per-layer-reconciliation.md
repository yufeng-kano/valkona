# ADR 0002 — Per-Layer reconciliation

## Context

Global revisions became artificial once cross-Layer references/atomicity were excluded and failures were isolated per Layer.

## Options

- global immutable revisions with per-Layer execution exceptions;
- independent LayerRevision and ProjectionState;
- no revision history.

## Decision

Compile/reconcile one Layer independently and retain immutable LayerRevision plus one mutable ProjectionState.

## Consequences

A broken Layer does not block siblings. Retirement is explicit. Applied state naturally consists of each Layer's applied revision. There is no global atomic snapshot.
