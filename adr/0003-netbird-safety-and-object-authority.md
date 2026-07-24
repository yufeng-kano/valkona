# ADR 0003 — NetBird safety and remote object authority

## Context

Valkona cannot enforce meaningful topology while NetBird's default broad all-to-all rule is active or while connected to an unexpected NetBird account. Remote names/hashes can be copied and cannot prove ownership.

## Options

- automatically modify unmanaged NetBird state;
- continue in degraded mode;
- fail closed with explicit startup/runtime safety and durable ObjectMap authority.

## Decision

Startup requires stable account identity to match the configured expectation and the verified default broad rule to be disabled/absent. Runtime identity mismatch or rule reappearance seals writes. Only exact durable ObjectMap mappings authorize remote update/delete; metadata and hashes are diagnostics.

## Consequences

Operators must prepare NetBird and resolve uncertain/orphan state explicitly. Valkona avoids silently taking control of unmanaged objects.
