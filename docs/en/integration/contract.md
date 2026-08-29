# System Composition Contract

**Owner:** application composition  
**Imports:** `System.OperationGate.v1`, `System.Principal.v1`, `Core.Application.v1`, `Core.IdentityCommandPort.v1`, `Core.InventorySync.v1`, `Topology.CommandPort.v1`, `Topology.LayerReader.v1`, `Runtime.ProjectionCoordinator.v1`, `Runtime.QueryApplication.v1`, `Audit.Sink.v1`  
**Exports:** `System.CoreApplication.v1`, `System.TopologyApplication.v1`, `System.InventoryApplication.v1`, `System.DiagnosticsApplication.v1`

Process safety types and the inspection port are defined in [`contracts/system.md`](../contracts/system.md). Composition implements SafetyState and OperationGate and wires the NetBird safety inspector.

## `System.CoreApplication.v1`

Identity operations that can change existing Peer topology facts are composed here:

```text
AssignPeerOwner(actor, peer_id, Core.AssignPeerOwnerCommand.v1) -> Core.PeerView.v1
CreateIdentityBinding(actor, Core.IdentityBindingCommand.v1) -> Core.BindingView.v1
DeleteIdentityBinding(actor, binding_id) -> void
```

Each operation authorizes `identity_write` and executes the Core mutation and Layer invalidation in the same transaction:

```text
Core.IdentityCommandPort mutation
→ obtain Core.TopologyChangeSet.v1
→ Topology.FindLayersReferencingPeers(transaction, changed_peer_ids)
→ Runtime.MarkPending(transaction, each affected Layer, peer_change)
→ Audit.Sink append identity event
→ commit
```

A crash cannot commit an owner/attribution change without the corresponding Layer work invalidation.

## `System.TopologyApplication.v1`

HTTP and other inbound adapters call these operations rather than calling Topology/Runtime separately.

```text
ListLayers(actor, Topology.ListQuery.v1) -> Page<Topology.LayerView.v1>
GetLayer(actor, layer_id) -> Topology.LayerView.v1
CreateLayer(actor, Topology.LayerCommand.v1) -> Topology.LayerView.v1
UpdateLayer(actor, layer_id, Topology.LayerCommand.v1) -> Topology.LayerView.v1
DeleteLayer(actor, layer_id) -> void

ListNodes(actor, layer_id, Topology.ListQuery.v1) -> Page<Topology.NodeView.v1>
GetNode(actor, layer_id, node_id) -> Topology.NodeView.v1
CreateNode(actor, layer_id, Topology.NodeCommand.v1) -> Topology.NodeView.v1
UpdateNode(actor, layer_id, node_id, Topology.NodeCommand.v1) -> Topology.NodeView.v1
DeleteNode(actor, layer_id, node_id) -> void

ListGroups(actor, layer_id, Topology.ListQuery.v1) -> Page<Topology.GroupView.v1>
GetGroup(actor, layer_id, group_id) -> Topology.GroupView.v1
CreateGroup(actor, layer_id, Topology.GroupCommand.v1) -> Topology.GroupView.v1
UpdateGroup(actor, layer_id, group_id, Topology.GroupCommand.v1) -> Topology.GroupView.v1
DeleteGroup(actor, layer_id, group_id) -> void

ListServices(actor, layer_id, Topology.ListQuery.v1) -> Page<Topology.ServiceView.v1>
GetService(actor, layer_id, service_id) -> Topology.ServiceView.v1
CreateService(actor, layer_id, Topology.ServiceCommand.v1) -> Topology.ServiceView.v1
UpdateService(actor, layer_id, service_id, Topology.ServiceCommand.v1) -> Topology.ServiceView.v1
DeleteService(actor, layer_id, service_id) -> void

ListExposures(actor, layer_id, Topology.ListQuery.v1) -> Page<Topology.ExposureView.v1>
GetExposure(actor, layer_id, exposure_id) -> Topology.ExposureView.v1
CreateExposure(actor, layer_id, Topology.ExposureCommand.v1) -> Topology.ExposureView.v1
UpdateExposure(actor, layer_id, exposure_id, Topology.ExposureCommand.v1) -> Topology.ExposureView.v1
DeleteExposure(actor, layer_id, exposure_id) -> void

ListAccessEdges(actor, layer_id, Topology.ListQuery.v1) -> Page<Topology.AccessEdgeView.v1>
GetAccessEdge(actor, layer_id, edge_id) -> Topology.AccessEdgeView.v1
CreateAccessEdge(actor, layer_id, Topology.AccessEdgeCommand.v1) -> Topology.AccessEdgeView.v1
UpdateAccessEdge(actor, layer_id, edge_id, Topology.AccessEdgeCommand.v1) -> Topology.AccessEdgeView.v1
DeleteAccessEdge(actor, layer_id, edge_id) -> void

RetryLayerReconciliation(actor, layer_id) -> Runtime.ProjectionView.v1
```

Every write first authorizes `topology_write`, then executes one database transaction:

```text
OperationGate.Authorize(user principal, topology_write)
→ Topology.CommandPort mutation
→ Runtime.MarkPending(layer_id, reason)
→ Audit.Sink append user mutation event
→ commit
```

The transaction may finish if the process seals after authorization; its desired state remains pending. NetBird writes remain separately gated.

### Hard Layer deletion

Deletion uses one transaction:

```text
Authorize(topology_write)
→ lock Layer
→ lock ProjectionState
→ Runtime.CheckDeletionEligibility(transaction, layer_id)
→ Topology.DeleteRetiredLayer(transaction, ...)
→ integration FK cascade removes ProjectionState
→ append Audit event
→ commit
```

No eligibility decision is reused outside the transaction. Historical revisions/attempts/audit remain.

### Retry

`RetryLayerReconciliation` authorizes `topology_write`, verifies Layer authority, and transactionally calls Runtime retry/MarkPending. It does not perform a remote write in the request thread. A Layer with unresolved uncertain-create evidence remains `needs_attention` until the operator removes the ambiguity.

## `System.InventoryApplication.v1`

```text
SyncPeerInventory(context, system_principal) -> Core.ObservationResult.v1
```

The operation is crash-safe across Core and Runtime:

```text
Core.StartObservation
→ Core.FetchInventory outside database transaction
→ begin shared database transaction
→ Core.ApplyInventory(transaction, observation, snapshot)
→ Topology.FindLayersReferencingPeers(transaction, changed_peer_ids)
→ Runtime.MarkPending(transaction, each affected layer, peer_change)
→ commit observation completion + Peer changes + pending markers atomically
```

If fetch fails, composition records a failed observation and does not mark Peers missing or Layers pending. Startup recovers stale `running` observations as failed.

## `System.DiagnosticsApplication.v1`

```text
GetSystemStatus(actor) -> System.StatusView.v1
GetNetBirdDiagnostics(actor) -> System.NetBirdDiagnostics.v1
GetLiveness() -> System.HealthView.v1
GetReadiness() -> System.HealthView.v1
RunStartupDoctor(configuration) -> System.NetBirdDiagnostics.v1
```


`GetSystemStatus` is available to authenticated users. NetBird diagnostics are admin-only. Liveness/readiness are unauthenticated transport health operations and expose no user/resource data. `RunStartupDoctor` is local CLI-only.

Read-only HTTP diagnostics exist only after the process reached `active`; they remain available in `sealed`. Startup failure diagnostics are CLI/log output because the HTTP listener is not started.

## Transaction boundary

Cross-module writes share one database transaction supplied by composition. Module ports accept an opaque transaction/unit-of-work handle and do not begin independent commits for the same use case.

## Process cardinality

One installation supports exactly one active Valkona process. Startup acquires a configured PostgreSQL advisory lock before safety inspection and retains the session for process lifetime. Failure to acquire the lock fails startup; no distributed leader election is part of MVP.

## Errors

```text
runtime_sealed
backend_identity_mismatch
default_all_to_all_enabled
safety_evidence_unavailable
instance_already_active
forbidden
resource_not_found
resource_in_use
layer_not_retired
needs_attention
```
