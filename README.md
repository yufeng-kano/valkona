# Valkona v0.11.4 — Concurrency and Type Closure

Valkona is a self-hosted, high-level topology and access-control layer for one NetBird account.

The name **Valkona** is inspired by *falconer*: it guides and coordinates NetBird rather than replacing the underlying network.

v0.11.4 closes the remaining concurrency and public-type gaps in the module interfaces. Durable Layer work now uses a monotonic `work_version`, Core inventory application and affected-Layer invalidation commit atomically, deletion eligibility is transaction-scoped, and all exported operation signatures reference owned boundary types.

## Documentation

所有說明文件位於 [`docs/`](docs/)。開始前先讀 [`docs/index.md`](docs/index.md) 的結構說明。

想讀懂整個專案，從 [`docs/tw/index.md`](docs/tw/index.md) 的導讀開始，照它的順序讀。

## docs 結構

```text
docs/tw     繁體中文規格（維護中，規格以此為準）
docs/en     英文概念文件 v0.11.4（已凍結，只讀不改）
docs/dev    實作文件（程式碼出現後開始長，最終只留這區）
```

## Status

The contracts are implementation-ready subject to the NetBird evidence milestone (called Phase 0 in the frozen `docs/en/`). That milestone must prove the exact representations used for account identity, default all-to-all detection, built-in All Group access, Policy canonicalization, Setup Key behavior and uncertain remote-create outcomes.
