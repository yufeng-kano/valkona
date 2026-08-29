# System Safety Contract

**Owner:** System composition  
**Imports:** `Backend.Error.v1`  
**Exports:** `System.Principal.v1`, `System.OperationClass.v1`, `System.SafetyState.v1`, `System.OperationGate.v1`, `System.SafetyInspection.v1`, `System.SafetyInspectorPort.v1`, `System.HealthView.v1`, `System.StatusView.v1`, `System.NetBirdDiagnostics.v1`

## `System.Principal.v1`

```text
kind: user | system
principal_id
system_component nullable: peer_sync | enrollment_reconciler | topology_reconciler | safety_monitor | startup_doctor
```

A user principal is derived from the authenticated Core user context. A system principal identifies the scheduled component performing work; workers never impersonate an administrator.

## `System.OperationClass.v1`

```text
read | diagnostic | topology_write | identity_write | enrollment_issue | backend_write
```

## `System.SafetyState.v1`

```text
mode: starting | active | sealed
reason_code nullable
changed_at
```

`starting` exposes no HTTP listener or workers. Startup enters `active` only after safety inspection succeeds. Runtime violations enter `sealed`; repair requires restart and a fresh startup inspection.

## `System.OperationGate.v1`

```text
Authorize(principal: System.Principal.v1, operation_class: System.OperationClass.v1) -> void | Error
GetSafetyState() -> SafetyState
```

| Mode | read | diagnostic | topology_write | identity_write | enrollment_issue | backend_write |
|---|---:|---:|---:|---:|---:|---:|
| starting | no interface | no interface | deny | deny | deny | deny |
| active | allow | allow | allow | allow | allow | allow |
| sealed | allow | allow | deny | deny | deny | deny |

Application boundaries authorize before starting a local mutation. A local database transaction already in progress may commit after a concurrent transition to `sealed`; its result remains durable desired state. Every NetBird write is authorized again immediately before that remote request, and active write contexts are cancelled when sealing occurs. This contract deliberately does not provide a serializable permit or transaction lease.

Resource authority remains the owning module's responsibility.

## `System.SafetyInspection.v1`

```text
backend_account_identity: opaque stable string | unavailable
default_all_to_all: disabled | enabled | unknown
evidence: diagnostic object
observed_at
```

## `System.SafetyInspectorPort.v1`

```text
InspectSafety(context) -> SafetyInspection | Backend.Error.v1
```

Configured expected identity is compared exactly. Unavailable/unknown evidence, identity mismatch or an enabled default broad rule fails startup and seals an active process.

## `System.HealthView.v1`

```text
live: boolean
ready: boolean
mode: starting | active | sealed
reason_code nullable
checked_at
```

Liveness means the process can answer. Readiness is true only in `active` with critical dependencies available.

## Diagnostic views

```text
System.StatusView.v1:
  safety_state, latest_complete_observation nullable, reconciliation_summary, checked_at

System.NetBirdDiagnostics.v1:
  safety_inspection nullable, backend_errors[], mapping_summary, checked_at
```
