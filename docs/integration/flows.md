# Integration Flows

This file illustrates the contracts in [`contract.md`](contract.md); it does not redefine module behavior.

## Startup

```text
load configuration and database
→ acquire PostgreSQL advisory instance lock
→ NetBird adapter InspectSafety
→ compare expected account identity
→ verify default broad all-to-all disabled/absent
→ active: bind HTTP and start loops
→ failure: structured log, non-zero exit
```

## Topology mutation

```text
HTTP route
→ System.TopologyApplication
→ OperationGate.Authorize(topology_write)
→ Topology mutation + Layer generation
→ Runtime.MarkPending increments work_version in same transaction
→ commit and wake reconciler
```

## Core inventory change

```text
Core.StartObservation
→ fetch complete inventory outside transaction
→ shared transaction:
   Core.ApplyInventory
   → complete CoreObservation
   → obtain changed stable Peer IDs
   → Topology.FindLayersReferencingPeers
   → Runtime.MarkPending increments each work_version
→ one commit
```

## Layer reconciliation

```text
ProjectionState pending
→ snapshot target_work_version
→ Runtime loads Topology.LayerSnapshot and Core.PeerRefs
→ persist valid/blocked LayerRevision
→ valid: persist running ReconcileAttempt(target_work_version)
→ fresh remote read and in-memory diff
→ authorize backend_write immediately before each remote write
→ read-back verification
→ compare-and-swap completion:
   same work_version -> applied/blocked/inactive
   newer work_version -> keep pending
```

## Enrollment

```text
Core.Application authorizes enrollment_issue
→ create Enrollment
→ each staging Group/Setup Key write authorizes backend_write
→ first response may carry plaintext once
→ Enrollment loop finds staged Peer
→ persist ownership
→ revoke key/delete staging Group with fresh backend-write checks
```

## Runtime safety violation

```text
periodic InspectSafety
→ identity mismatch or default broad rule enabled
→ System mode sealed
→ cancel active backend-write contexts
→ no new writes
→ already-open local transaction may commit as pending desired state
→ read-only diagnostics remain
→ operator repairs and restarts
```
