# Implementation Plan

## Phase 0 — evidence

Record NetBird fixtures and tests listed in [`phase0-validation.md`](phase0-validation.md).

## Phase 1 — skeleton and persistence

- module/package boundaries matching `ARCHITECTURE.md`;
- migration runner;
- module schemas then integration FK migration;
- PostgreSQL advisory single-instance lock;
- configuration and startup doctor;
- Audit sink with user/system principals;
- stateful fake NetBird adapter implementing all boundary types.

## Phase 2 — Core and crash-safe inventory

- OIDC users/admin bootstrap;
- observation start/fetch/apply/fail lifecycle;
- composition transaction joining inventory application to Layer work invalidation;
- presence cache, attribution and identity bindings;
- Enrollment state machine and idempotency.

## Phase 3 — Topology and composition

- Topology command/read ports and owned commands/views;
- System OperationGate at application boundaries;
- CRUD HTTP adapter mapping;
- transaction-scoped deletion eligibility;
- reference/authority validation.

## Phase 4 — Runtime and NetBird projection

- Layer compiler/revisions;
- monotonic work-version pending sweeps;
- compare-and-swap reconciliation completion;
- ObjectMap and reconciliation;
- safety monitor/sealed cancellation;
- Explain and diagnostics.

## Implementation rule

A consumer package is written against the imported contract interface and tested with a fake before wiring the production adapter. Do not create a universal backend abstraction, duplicate HTTP/domain types or pass process-safety capability tokens through domain signatures.
