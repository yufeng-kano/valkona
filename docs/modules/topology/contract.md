# Topology Contract

**Owner:** Topology  
**Imports:** `Core.UserContext.v1`, `Core.PeerReader.v1`  
**Exports:** `Topology.CommandPort.v1`, `Topology.LayerReader.v1`, `Topology.LayerSnapshot.v1`, Topology commands/views/results

## Responsibility

Topology owns Layer-local access intent. It does not observe NetBird, reconcile Policies, define HTTP routes or own process safety.

## Domain

```text
Layer(kind: personal | system, owner, enabled, generation)
Node(peer_id)
Group(static Node members)
Service(protocol: tcp | udp | icmp, normalized ports)
Exposure(destination: Node | Group, service)
AccessEdge(source: Node | Group | Selector, exposure, enabled)
```

All direct references are within one Layer. Personal Nodes require a resolved Peer owned by the Layer owner; System Nodes may reference any resolved Peer. Node is persistent intent bound to stable Peer identity.

TCP/UDP Services use non-empty normalized ports/ranges within `1..65535`; ICMP uses no ports.

`selector: all` is source-only and represents every current/future Peer in the connected NetBird account. It does not enumerate membership or grant authority over source Peers.

## Public values

### `Topology.LayerView.v1`

```text
layer_id, name, kind: personal|system, owner_user_id nullable,
enabled, generation, created_at, updated_at
```

### Resource views

```text
Topology.NodeView.v1:
  node_id, layer_id, name, peer_id, created_at, updated_at

Topology.GroupView.v1:
  group_id, layer_id, name, node_ids[], created_at, updated_at

Topology.ServiceView.v1:
  service_id, layer_id, name, protocol, normalized_ports[], created_at, updated_at

Topology.ExposureView.v1:
  exposure_id, layer_id, name, destination_kind, destination_id,
  service_id, created_at, updated_at

Topology.AccessEdgeView.v1:
  edge_id, layer_id, name, source_kind, source_id nullable,
  selector_type nullable, exposure_id, enabled, created_at, updated_at
```

### `Topology.LayerAuthority.v1`

```text
layer_id
kind
owner_user_id nullable
read_allowed: boolean
manage_allowed: boolean
```

The reader evaluates these booleans for the supplied actor; consumers do not inspect Topology tables.

### `Topology.LayerSnapshot.v1`

```text
layer: LayerView
nodes[]: NodeView
groups[]: GroupView
services[]: ServiceView
exposures[]: ExposureView
access_edges[]: AccessEdgeView
```

The snapshot is immutable compiler input. Peer resolution is consumed through `Core.PeerReader.v1` rather than embedding attribution algorithms.

### `Topology.MutationResult.v1`

```text
layer_id
new_generation
change_kind
resource_type
resource_id
```

Every successful mutation increments Layer generation and returns this result to composition.

### Command and query types

```text
Topology.ListQuery.v1:
  cursor nullable, limit, enabled nullable

Topology.LayerCommand.v1:
  name nullable, enabled nullable, kind/owner only where operation permits

Topology.NodeCommand.v1:
  name, peer_id

Topology.GroupCommand.v1:
  name, node_ids[]

Topology.ServiceCommand.v1:
  name, protocol, ports[]

Topology.ExposureCommand.v1:
  name, destination_kind, destination_id, service_id

Topology.AccessEdgeCommand.v1:
  name, source_kind, source_id nullable, selector_type nullable, exposure_id, enabled
```

Pages contain `items[]` and `next_cursor nullable`.

## `Topology.CommandPort.v1`

All mutations accept actor and a composition transaction handle. Safety authorization occurs at the application composition boundary; Topology enforces resource authority and invariants.

```text
CreateLayer(transaction, actor, LayerCommand) -> MutationResult + LayerView
UpdateLayer(transaction, actor, layer_id, LayerCommand) -> MutationResult + LayerView
DeleteRetiredLayer(transaction, actor, layer_id) -> void

CreateNode(transaction, actor, layer_id, NodeCommand) -> MutationResult + NodeView
UpdateNode(transaction, actor, layer_id, node_id, NodeCommand) -> MutationResult + NodeView
DeleteNode(transaction, actor, layer_id, node_id) -> MutationResult

CreateGroup(transaction, actor, layer_id, GroupCommand) -> MutationResult + GroupView
UpdateGroup(transaction, actor, layer_id, group_id, GroupCommand) -> MutationResult + GroupView
DeleteGroup(transaction, actor, layer_id, group_id) -> MutationResult

CreateService(transaction, actor, layer_id, ServiceCommand) -> MutationResult + ServiceView
UpdateService(transaction, actor, layer_id, service_id, ServiceCommand) -> MutationResult + ServiceView
DeleteService(transaction, actor, layer_id, service_id) -> MutationResult

CreateExposure(transaction, actor, layer_id, ExposureCommand) -> MutationResult + ExposureView
UpdateExposure(transaction, actor, layer_id, exposure_id, ExposureCommand) -> MutationResult + ExposureView
DeleteExposure(transaction, actor, layer_id, exposure_id) -> MutationResult

CreateAccessEdge(transaction, actor, layer_id, AccessEdgeCommand) -> MutationResult + AccessEdgeView
UpdateAccessEdge(transaction, actor, layer_id, edge_id, AccessEdgeCommand) -> MutationResult + AccessEdgeView
DeleteAccessEdge(transaction, actor, layer_id, edge_id) -> MutationResult
```

Individual deletion returns `resource_in_use` when referenced. `DeleteRetiredLayer` is called only inside a transaction where composition has locked the Layer and Runtime has confirmed deletion eligibility.

## `Topology.LayerReader.v1`

```text
ListLayers(actor, ListQuery) -> Page<LayerView>
GetLayer(actor, layer_id) -> LayerView

ListNodes(actor, layer_id, ListQuery) -> Page<NodeView>
GetNode(actor, layer_id, node_id) -> NodeView
ListGroups(actor, layer_id, ListQuery) -> Page<GroupView>
GetGroup(actor, layer_id, group_id) -> GroupView
ListServices(actor, layer_id, ListQuery) -> Page<ServiceView>
GetService(actor, layer_id, service_id) -> ServiceView
ListExposures(actor, layer_id, ListQuery) -> Page<ExposureView>
GetExposure(actor, layer_id, exposure_id) -> ExposureView
ListAccessEdges(actor, layer_id, ListQuery) -> Page<AccessEdgeView>
GetAccessEdge(actor, layer_id, edge_id) -> AccessEdgeView

GetLayerSnapshot(layer_id) -> LayerSnapshot
GetLayerAuthority(actor, layer_id) -> LayerAuthority
FindLayersReferencingPeers(transaction, peer_ids[]) -> layer_ids[]
GetLayerGeneration(transaction_or_context, layer_id) -> generation
LockLayerForDeletion(transaction, layer_id) -> LayerView
```

Personal Layer owner/admin may manage it; System Layer is admin-managed. Resources inherit Layer authority.

## Errors

```text
invalid_argument
forbidden
resource_not_found
resource_in_use
peer_not_resolved
cross_layer_reference
invalid_service_ports
```
