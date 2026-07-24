# Contract Index

## Shared System and adapters

| Contract ID | Owner | Consumers | Definition |
|---|---|---|---|
| `System.Principal.v1` | System composition | Gate, workers, Audit | [`contracts/system.md`](contracts/system.md) |
| `System.OperationClass.v1` | System composition | Gate callers | [`contracts/system.md`](contracts/system.md) |
| `System.OperationGate.v1` | System composition | Core, Integration, Runtime | [`contracts/system.md`](contracts/system.md) |
| `System.SafetyState.v1` | System composition | HTTP/diagnostics | [`contracts/system.md`](contracts/system.md) |
| `System.SafetyInspection.v1` | System composition | safety inspector/NetBird | [`contracts/system.md`](contracts/system.md) |
| `System.SafetyInspectorPort.v1` | System composition | NetBird adapter | [`contracts/system.md`](contracts/system.md) |
| `System.HealthView.v1` | System composition | HTTP health routes | [`contracts/system.md`](contracts/system.md) |
| `System.StatusView.v1` | System composition | HTTP diagnostics | [`contracts/system.md`](contracts/system.md) |
| `System.NetBirdDiagnostics.v1` | System composition | HTTP/CLI diagnostics | [`contracts/system.md`](contracts/system.md) |
| `System.CoreApplication.v1` | Integration | HTTP adapter | [`integration/contract.md`](integration/contract.md) |
| `System.TopologyApplication.v1` | Integration | HTTP adapter | [`integration/contract.md`](integration/contract.md) |
| `System.InventoryApplication.v1` | Integration | scheduled Peer sync | [`integration/contract.md`](integration/contract.md) |
| `System.DiagnosticsApplication.v1` | Integration | HTTP/CLI | [`integration/contract.md`](integration/contract.md) |
| `HTTP.Interface.v1` | HTTP | API clients | [`interfaces/http/contract.md`](interfaces/http/contract.md) |
| `Audit.Event.v1` | Audit | Core, Integration, Runtime, System | [`modules/audit/contract.md`](modules/audit/contract.md) |
| `Audit.Sink.v1` | Audit | Core, Integration, Runtime, System | [`modules/audit/contract.md`](modules/audit/contract.md) |
| `Backend.Error.v1` | shared outbound boundary | Core, Runtime, System, NetBird | [`contracts/backend.md`](contracts/backend.md) |

## Core

| Contract ID | Consumers | Definition |
|---|---|---|
| `Core.Application.v1` | HTTP | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.IdentityCommandPort.v1` | System composition | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.TopologyChangeSet.v1` | System composition | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.ListQuery.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.InventorySync.v1` | System inventory composition | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.EnrollmentReconciler.v1` | scheduled Enrollment loop | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.UserContext.v1` | Topology, Runtime, System | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.PeerRef.v1` | Topology, Runtime | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.PeerPresence.v1` | HTTP/Core clients | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.PeerReader.v1` | Topology, Runtime | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.ObservationRef.v1` | Runtime, Integration | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.ObservationReader.v1` | Runtime | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.ObservationResult.v1` | Integration | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.InventorySnapshot.v1` | Core/Integration | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.EnrollmentCommand.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.EnrollmentCreation.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.UserView.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.UpdateUserCommand.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.PeerView.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.AssignPeerOwnerCommand.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.IdentityBindingCommand.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.BindingView.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.EnrollmentView.v1` | HTTP/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.EnrollmentReconcileSummary.v1` | scheduled Enrollment loop | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.PeerInventoryPort.v1` | NetBird adapter | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.IdentityInventoryPort.v1` | NetBird adapter | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.EnrollmentBackendPort.v1` | NetBird adapter | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.IdentityRecord.v1` | NetBird adapter/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.ObservedPeer.v1` | NetBird adapter/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.IdentityInventoryResult.v1` | NetBird adapter/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.PeerInventoryResult.v1` | NetBird adapter/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.StagingGroupSpec.v1` | NetBird adapter | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.SetupKeySpec.v1` | NetBird adapter | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.RemoteGroupRef.v1` | NetBird adapter/Core | [`modules/core/contract.md`](modules/core/contract.md) |
| `Core.SetupKeyCreation.v1` | NetBird adapter/Core | [`modules/core/contract.md`](modules/core/contract.md) |

## Topology

| Contract ID | Consumers | Definition |
|---|---|---|
| `Topology.CommandPort.v1` | System composition | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.LayerReader.v1` | Runtime, System composition | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.LayerSnapshot.v1` | Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.LayerView.v1` | HTTP/System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.NodeView.v1` | HTTP/System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.GroupView.v1` | HTTP/System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.ServiceView.v1` | HTTP/System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.ExposureView.v1` | HTTP/System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.AccessEdgeView.v1` | HTTP/System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.ListQuery.v1` | HTTP/System | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.LayerAuthority.v1` | System/Runtime | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.MutationResult.v1` | System composition | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.LayerCommand.v1` | System/HTTP | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.NodeCommand.v1` | System/HTTP | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.GroupCommand.v1` | System/HTTP | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.ServiceCommand.v1` | System/HTTP | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.ExposureCommand.v1` | System/HTTP | [`modules/topology/contract.md`](modules/topology/contract.md) |
| `Topology.AccessEdgeCommand.v1` | System/HTTP | [`modules/topology/contract.md`](modules/topology/contract.md) |

## Runtime

| Contract ID | Consumers | Definition |
|---|---|---|
| `Runtime.ProjectionCoordinator.v1` | System composition/scheduled reconciler | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.QueryApplication.v1` | HTTP/System diagnostics | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.ListQuery.v1` | HTTP/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.LayerRevision.v1` | Runtime queries/retention | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.LayerProjectionState.v1` | System/Runtime queries | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.ReconcileAttempt.v1` | Runtime queries | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.NetBirdObjectMap.v1` | Runtime diagnostics/reconciliation | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.PendingReason.v1` | System/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.PendingResult.v1` | System/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.ReconcileSummary.v1` | scheduled reconciler/System status | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.DeletionEligibility.v1` | System composition | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.ProjectionView.v1` | HTTP/System | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.RevisionView.v1` | HTTP/System | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.AttemptView.v1` | HTTP/System | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.ExplainQuery.v1` | HTTP/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.ExplainResult.v1` | HTTP/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.GroupSpec.v1` | NetBird adapter | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.CanonicalGroup.v1` | NetBird adapter/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.RemoteGroup.v1` | NetBird adapter/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.PolicyRuleSpec.v1` | NetBird adapter | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.PolicySpec.v1` | NetBird adapter | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.CanonicalPolicy.v1` | NetBird adapter/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.RemotePolicy.v1` | NetBird adapter/Runtime | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.GroupBackendPort.v1` | NetBird adapter | [`modules/runtime/contract.md`](modules/runtime/contract.md) |
| `Runtime.PolicyBackendPort.v1` | NetBird adapter | [`modules/runtime/contract.md`](modules/runtime/contract.md) |

## NetBird

| Contract ID | Consumers | Definition |
|---|---|---|
| `NetBird.Adapter.v1` | composition wiring | [`modules/netbird/contract.md`](modules/netbird/contract.md) |
