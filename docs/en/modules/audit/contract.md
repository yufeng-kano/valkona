# Audit Contract

**Owner:** Audit  
**Imports:** `System.Principal.v1`  
**Exports:** `Audit.Sink.v1`, `Audit.Event.v1`

## `Audit.Event.v1`

```text
event_id
occurred_at
principal: System.Principal.v1
source_module
kind
resource_type nullable
resource_id nullable
metadata: structured object
```

The source module owns the semantic meaning of `kind` and metadata. Audit owns the durable envelope and retention.

## `Audit.Sink.v1`

```text
Append(transaction, event) -> void | Error
```

Security/administrative mutations append within the same transaction as the state change. The sink is append-only; callers do not update/delete entries.

Typical events include user/role status changes, identity binding/owner changes, Enrollment final outcomes, topology user mutations, `needs_attention` operator actions and System sealed transitions. Ordinary successful reconciliation is already represented by ReconcileAttempt and is not duplicated.

MVP provides durable storage but no public Audit query application or HTTP route. Operators inspect Audit through administrative database tooling until a query contract is intentionally added.

## Errors

```text
audit_unavailable
audit_invalid_event
```
