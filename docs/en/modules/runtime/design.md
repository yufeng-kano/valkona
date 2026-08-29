# Runtime Design

## Dirty discovery

Composition transactionally increments `ProjectionState.work_version` and marks work pending. Startup and periodic sweeps query persisted pending/blocked states; queues only wake or debounce.

## Compile/reconcile

```text
lock/select pending Layer
→ snapshot target_work_version
→ load newest LayerSnapshot
→ resolve public PeerRefs
→ store apply/retire Revision
→ blocked: CAS blocked only if work_version unchanged
→ valid: create running ReconcileAttempt(target_work_version)
→ observe mapped remote state
→ in-memory diff
→ gated sequential writes/read-back
→ update ObjectMap
→ CAS completion against target_work_version
```

If work arrived during execution, a verified revision may update `applied_revision_id`, but state remains pending for the newer work. One NetBird writer runs at a time; sibling Layers are independently retryable.

## Crash/seal

ReconcileAttempt exists before remote create. Restart re-observes rather than resuming an operation cursor. If an already-sent request may have succeeded without a stored mapping, the attempt and projection become `needs_attention`.

System composition owns mode changes. Runtime receives cancellation and authorizes immediately before each backend write; it starts no further write after sealing. Local desired-state transactions may have committed and remain pending.
