# ADR 0004 — Application Contracts and Adapter Boundaries

## Context

v0.11.2 placed documentation under module folders, but domain contracts still listed HTTP routes and cross-module flows lacked callable interfaces.

## Decision

Domain modules expose language-neutral application operations, readers and outbound ports. HTTP is a separate inbound adapter. Cross-module transactions and process safety are owned by composition. Cross-module database foreign keys are applied by integration migrations.

## Consequences

Consumers can implement against a stable header without reading provider design/schema. HTTP, CLI and scheduled jobs can reuse the same application contracts. The composition layer is explicit but remains thin; it owns orchestration rather than domain rules.
