# Documentation Rules

## One fact, one owner

Every normative fact belongs to one module or shared contract. Other files reference its stable contract identifier; they do not copy its full definition.

Examples:

- attribution evidence belongs to Core;
- same-Layer references belong to Topology;
- reconciliation state belongs to Runtime;
- process safety and write gating belong to System composition;
- NetBird representations belong to the NetBird adapter;
- HTTP route mapping belongs to the HTTP interface.

## Contract hierarchy

1. Module/interface `contract.md` owns public semantics.
2. Shared contracts under `contracts/` own process-wide gates and backend error categories.
3. `integration/contract.md` owns cross-module application transactions.
4. `design.md` cannot override a contract.
5. Module `schema.sql` owns local persistence shape; `integration/schema.sql` owns cross-module FK.
6. Production migrations become executable database authority.
7. `acceptance.md` expresses contract tests.
8. ADRs explain rationale but do not redefine current behavior.

## Contract form

A callable contract names:

- operations/methods;
- every public command/query/result type and its unique owner;
- closed error categories;
- transaction and idempotency expectations;
- complete/partial semantics for external observations.

Use language-neutral pseudo-signatures unless an implementation language is already authoritative.

## Writing style

Prefer positive definitions, state machines and invariants. Use explicit negative rules only for safety boundaries, non-obvious behavior likely to be misimplemented, or high-impact regressions.

## Changing a contract

1. update the owning contract;
2. update owner acceptance tests;
3. update dependent signatures only if their imported shape changed;
4. update design/schema/integration wiring as needed;
5. update HTTP routes only when the application surface changed;
6. record externally relevant changes in `CHANGELOG.md`.

## Generated API specification

The current HTTP contract is human-readable. Once handlers and schemas exist, one complete OpenAPI document should be generated or maintained from implementation sources. Do not add a second incomplete handwritten OpenAPI outline.
