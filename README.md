# Valkona v0.11.4 — Concurrency and Type Closure

Valkona is a self-hosted, high-level topology and access-control layer for one NetBird account.

The name **Valkona** is inspired by *falconer*: it guides and coordinates NetBird rather than replacing the underlying network.

v0.11.4 closes the remaining concurrency and public-type gaps in the module interfaces. Durable Layer work now uses a monotonic `work_version`, Core inventory application and affected-Layer invalidation commit atomically, deletion eligibility is transaction-scoped, and all exported operation signatures reference owned boundary types.

## Documentation

所有說明文件位於 [`docs/`](docs/)。開始前請先閱讀 [`docs/index.md`](docs/index.md)。

## Read first

1. [`docs/PRODUCT.md`](docs/PRODUCT.md) — product boundary and MVP outcome.
2. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — module graph, adapters and composition layer.
3. [`docs/CONTRACTS.md`](docs/CONTRACTS.md) — public contract index.
4. The `contract.md` of the module being consumed under `docs/modules/`.
5. `design.md` and `schema.sql` only when implementing that module.

## Package map

```text
docs/modules/core        users, Peers, attribution and Enrollment
docs/modules/topology    Layer-local access intent
docs/modules/runtime     compilation, reconciliation, projection and Explain
docs/modules/netbird     NetBird outbound adapter
docs/modules/audit       append-only audit sink
docs/interfaces/http     HTTP inbound adapter and route mapping
docs/integration         composition contracts, transactions and cross-module FK
docs/contracts           shared System safety, backend errors and configuration
docs/operations          configuration, Phase 0 evidence and implementation order
docs/adr                 architecture decision records
```

## Status

The contracts are implementation-ready subject to Phase 0 NetBird evidence. Phase 0 must prove the exact representations used for account identity, default all-to-all detection, built-in All Group access, Policy canonicalization, Setup Key behavior and uncertain remote-create outcomes.
