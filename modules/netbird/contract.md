# NetBird Adapter Contract

**Owner:** NetBird integration  
**Implements:** Core inventory/enrollment ports, Runtime Group/Policy ports, `System.SafetyInspectorPort.v1`  
**Imports:** `Backend.Error.v1`, Core/Runtime/System outbound boundary types  
**Exports:** `NetBird.Adapter.v1`

## Responsibility

The adapter owns NetBird HTTP authentication, pagination, DTOs, timeout/retry policy, error translation, canonicalization and verified backend-specific projections. Domain/application modules never consume raw NetBird JSON.

## Inventory semantics

Adapter pagination is internal. Inventory methods return a complete result or an error. A partial page, pagination failure or malformed response never appears as complete inventory.

## Enrollment semantics

Staging Groups and Setup Keys honor the requested expiry, usage limit and auto-group set. Create methods return stable remote IDs; Setup Key plaintext exists only in the create result.

## Projection

```text
one enabled Layer → one Valkona-owned Policy
one enabled AccessEdge → one Rule within that Policy
one Node → one Valkona-owned singleton Group
one Topology Group → one Valkona-owned Group
selector: all → built-in All Group at projection time
```

Rules are unidirectional accept rules. Explicit deny is outside MVP.

## Safety inspection

The adapter returns:

- stable opaque identity evidence for the connected NetBird account;
- classification/evidence for the verified default broad all-to-all rule;
- `unknown`/error when Phase 0-proven evidence cannot be obtained.

It does not decide whether the process starts/seals; System composition owns that policy.

## Canonicalization

Group/Policy read-back is normalized for stable hashes, no-op detection and verification. Exact ignored/read-only fields are fixed by recorded Phase 0 fixtures.

## Diagnostic metadata

Valkona names/descriptions contain local resource and correlation hints. They never authorize update/delete/adoption; Runtime ObjectMap remains authority.

## Adapter instance

`NetBird.Adapter.v1` is one configured client bound to one expected account identity and implements all listed outbound interfaces. A stateful fake implements the same contracts for tests.

## Type fidelity

The adapter returns exactly the boundary types owned by Core, Runtime and System. Backend DTOs, pagination tokens and provider-only fields remain private to the adapter.
