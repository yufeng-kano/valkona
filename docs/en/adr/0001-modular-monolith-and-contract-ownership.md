# ADR 0001 — Modular monolith and contract-owned documentation

## Context

Valkona modules share one process/database, but central documents repeatedly described every module and drifted during changes.

## Options

- one central specification;
- separately deployed services;
- modular monolith with module-owned public contracts and internal design docs.

## Decision

Use a modular monolith. Each module owns its `contract.md`, design, schema reference and acceptance tests. Other modules depend only on public contracts. A root composition layer coordinates cross-module use cases.

## Consequences

Internal refactors remain local when contracts are stable. Cross-module interface changes become explicit. Documentation contains more small files but fewer duplicated facts.
