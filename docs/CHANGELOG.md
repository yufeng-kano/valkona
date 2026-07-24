# Changelog

## v0.11.4 — Concurrency and Type Closure

- renamed the project and all public identifiers to **Valkona**, inspired by *falconer*, without changing the architecture or product semantics;
- added monotonic `work_version` to Layer projection state and `target_work_version` to reconciliation attempts;
- made stale reconciliation attempts unable to clear newer pending work;
- split Core inventory fetch from transactional inventory application;
- made Core observation completion and affected-Layer pending markers one cross-module transaction;
- moved Layer deletion eligibility checks and locks into the deletion transaction;
- removed `System.OperationPermit.v1` and replaced capability passing with boundary authorization plus per-remote-write checks;
- added `System.Principal.v1` for user and worker actors;
- completed public command, result, view, backend canonical and safety-inspection types;
- added explicit retry, liveness and readiness application operations;
- expanded HTTP error mapping and authentication rules for health routes;
- defined durable-owner representation for ambiguous Peer attribution;
- defined single-active-process enforcement through a PostgreSQL advisory lock.

## v0.11.3 — Interface Closure

- removed HTTP routes from Core, Topology and Runtime contracts;
- added an explicit HTTP inbound adapter and route-to-operation mapping;
- added callable Core, Topology, Runtime and composition interfaces;
- added process-wide System safety ownership and write gating;
- moved AuditEntry from Runtime to a shared Audit module;
- moved cross-module foreign keys to `integration/schema.sql`;
- specified NetBird outbound port methods, result types and stable error categories;
- added expected NetBird account identity to startup/runtime safety;
- simplified Enrollment idempotency/state storage;
- removed Peer raw observed JSON;
- reduced ProjectionState and ReconcileAttempt to non-derivable fields.

## v0.11.2 — Modular Documentation Baseline

- reorganized documentation around module-owned contracts/design/schema/acceptance;
- replaced central duplicated specification files with contract references;
- retained v0.11.1 product semantics.
