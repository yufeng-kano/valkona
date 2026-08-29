# Runtime Contract

**Owner:** Runtime  
**Imports:** `Core.PeerReader.v1`, `Core.ObservationReader.v1`, `Topology.LayerReader.v1`, `System.OperationGate.v1`, `System.Principal.v1`, `Audit.Sink.v1`, `Backend.Error.v1`, Runtime backend ports  
**Exports:** `Runtime.ProjectionCoordinator.v1`, `Runtime.QueryApplication.v1`, `Runtime.PendingReason.v1`, revision/projection/explain/backend boundary types

## Responsibility

Runtime compiles one Layer at a time, reconciles its desired state to the backend, records verified projection state and explains Valkona grants. It does not own live Topology/Core resources, HTTP routes or process safety state.

## State types

### `Runtime.LayerRevision.v1`

```text
revision_id
layer_id
layer_generation
layer_name_snapshot
layer_kind_snapshot: personal | system
action: apply | retire
status: valid | blocked
core_observation_id nullable
input_snapshot_hash
compiled_spec_hash nullable
compiled_policy nullable: Runtime.PolicySpec.v1
diagnostics[]
created_by_user_id nullable
created_at
```

Compilation is deterministic and performs no remote writes. A blocked result affects only its Layer and does not replace an older applied revision.

### `Runtime.LayerProjectionState.v1`

```text
layer_id
work_version: monotonically increasing integer
desired_revision_id nullable
applied_revision_id nullable
status: pending | applied | blocked | inactive | needs_attention
updated_at
```

This row is the durable work pointer. Every dirty event increments `work_version`, including Peer changes that do not change Layer generation. Queues are wakeups only.

### `Runtime.ReconcileAttempt.v1`

```text
attempt_id
layer_id
target_revision_id
target_work_version
status: running | succeeded | failed | needs_attention
observed_before_hash nullable
observed_after_hash nullable
failure_code nullable
failure_detail nullable
started_at
completed_at nullable
```

An attempt is created only when execution begins.

### `Runtime.PendingReason.v1`

```text
topology_mutation | peer_change | retry | startup_recovery | drift_observed
```

### `Runtime.PendingResult.v1`

```text
projection_state: Runtime.LayerProjectionState.v1
new_work_version
```

### `Runtime.ReconcileSummary.v1`

```text
result: idle | succeeded | blocked | failed | needs_attention
layer_id nullable
attempt_id nullable
target_work_version nullable
```

### `Runtime.DeletionEligibility.v1`

```text
eligible: boolean
reason_code nullable
```

## `Runtime.ProjectionCoordinator.v1`

```text
EnsureLayer(transaction, layer_id) -> ProjectionState
MarkPending(transaction, layer_id, Runtime.PendingReason.v1) -> PendingResult
GetProjectionState(layer_id) -> ProjectionState
CheckDeletionEligibility(transaction, layer_id) -> DeletionEligibility
RetryReconciliation(transaction, actor, layer_id) -> ProjectionState
ReconcileNext(context, principal: System.Principal.v1) -> Runtime.ReconcileSummary.v1
```

`MarkPending` atomically increments `work_version`. It sets `pending` unless the Layer is already `needs_attention`, in which case the higher work version is retained while automatic execution remains stopped.

`RetryReconciliation` revalidates the current ObjectMap and correlated remote candidates. If uncertainty has been removed, it increments `work_version` with reason `retry` and changes the state to `pending`; otherwise it returns `needs_attention` without clearing the state.

`CheckDeletionEligibility` runs inside the caller's deletion transaction after the Layer and ProjectionState are locked. It succeeds only when state is `inactive` and no owned ObjectMap remains.

### Work-version completion rule

Reconciliation snapshots `target_work_version` before compiling and stores it on the attempt. Completion uses compare-and-swap semantics:

```text
if current work_version == target_work_version:
  valid verified result -> applied/inactive
  blocked compile       -> blocked
else:
  persist the immutable revision and attempt result
  update applied_revision_id only when remote application was verified
  do not mark blocked/applied/inactive; keep status pending for newer work
```

An uncertain remote outcome always yields `needs_attention`, even if a newer work version exists. A stale attempt cannot clear or overwrite newer pending work.

During reconciliation Runtime obtains `Topology.LayerSnapshot.v1`, resolves Peer values through Core, persists a valid/blocked Revision, and for valid revisions observes/diffs/writes/read-backs the backend. Immediately before every remote write Runtime authorizes `backend_write` through `System.OperationGate.v1` using the supplied system principal.

A retire revision deletes only precisely mapped owned objects and verifies absence before `inactive`.

## Object authority

`Runtime.NetBirdObjectMap.v1` is the sole remote identity authority:

```text
local resource type/id ↔ remote object type/id
status: managed | drifted | remote_missing | conflict
last applied/observed hashes and observation time
```

Names, metadata, hashes and correlation IDs are diagnostics only. A correlated but unmapped possible create becomes `needs_attention`; Runtime does not adopt, delete or create a duplicate automatically.

## Query types

### `Runtime.ExplainQuery.v1`

```text
source_peer_id
destination_peer_id
protocol
port nullable
```

### `Runtime.ExplainResult.v1`

```text
decision: granted | not_granted | indeterminate
basis: desired | applied
matched_grants[]: {layer_id, revision_id, edge_id, exposure_id, service_snapshot}
observation_refs[]
backend_drift_status
indeterminate_reason nullable
```

`not_granted` means the selected Valkona state has no grant; unmanaged backend Policies are outside that claim.

### Query views

```text
Runtime.ProjectionView.v1:
  projection_state, latest_attempt nullable, mapping_summary

Runtime.RevisionView.v1:
  LayerRevision

Runtime.AttemptView.v1:
  ReconcileAttempt
```

### `Runtime.ListQuery.v1`

```text
cursor nullable
limit
status nullable
```

Pages contain `items[]` and `next_cursor nullable`. Unsupported filters are rejected.

## `Runtime.QueryApplication.v1`

```text
GetProjection(actor, layer_id) -> Runtime.ProjectionView.v1
ListRevisions(actor, layer_id, Runtime.ListQuery.v1) -> Page<Runtime.RevisionView.v1>
GetRevision(actor, layer_id, revision_id) -> Runtime.RevisionView.v1
GetReconcileAttempt(actor, attempt_id) -> Runtime.AttemptView.v1
ExplainAccess(actor, Runtime.ExplainQuery.v1, basis: desired|applied) -> Runtime.ExplainResult.v1
ExplainAccessEdge(actor, edge_id) -> Runtime.ExplainResult.v1
```

Projection/revision/attempt views require Layer owner or admin authority. `ExplainAccess` across Layers is admin-only. `ExplainAccessEdge` is available to the Personal Layer owner or admin; System Layer Explain is admin-only.

## Backend boundary types

### Group types

```text
Runtime.GroupSpec.v1:
  logical_key, name, description, peer_ids[]

Runtime.CanonicalGroup.v1:
  remote_group_id, canonical_name, canonical_peer_ids[], spec_hash

Runtime.RemoteGroup.v1:
  remote_group_id, canonical: CanonicalGroup
```

### Policy types

```text
Runtime.PolicyRuleSpec.v1:
  rule_key, source_group_ids[], destination_group_ids[], protocol, ports[], bidirectional=false, action=accept

Runtime.PolicySpec.v1:
  logical_key, name, description, enabled, rules[]

Runtime.CanonicalPolicy.v1:
  remote_policy_id, canonical_name, enabled, canonical_rules[], spec_hash

Runtime.RemotePolicy.v1:
  remote_policy_id, canonical: CanonicalPolicy
```

## Outbound ports

### `Runtime.GroupBackendPort.v1`

```text
GetGroup(context, remote_id) -> CanonicalGroup | Backend.Error.v1
CreateGroup(context, GroupSpec, correlation_id) -> RemoteGroup | Backend.Error.v1
UpdateGroup(context, remote_id, GroupSpec) -> CanonicalGroup | Backend.Error.v1
DeleteGroup(context, remote_id) -> void | Backend.Error.v1
```

### `Runtime.PolicyBackendPort.v1`

```text
GetPolicy(context, remote_id) -> CanonicalPolicy | Backend.Error.v1
CreatePolicy(context, PolicySpec, correlation_id) -> RemotePolicy | Backend.Error.v1
UpdatePolicy(context, remote_id, PolicySpec) -> CanonicalPolicy | Backend.Error.v1
DeletePolicy(context, remote_id) -> void | Backend.Error.v1
ResolveBuiltInAllGroup(context) -> RemoteGroup | Backend.Error.v1
```

Create operations accept correlation IDs. `outcome_uncertain` is fail-closed. Delete `not_found` is idempotent success only when ObjectMap proves the intended remote identity.

## Errors

```text
invalid_argument
forbidden
resource_not_found
reconciliation_blocked
runtime_sealed
remote_mapping_missing
remote_conflict
remote_readback_mismatch
remote_create_outcome_uncertain
needs_attention
backend_unavailable
```
