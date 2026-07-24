# Core Design

This file describes one implementation behind [`contract.md`](contract.md).

## Persistence

Current attribution lives on Peer; history is Audit. Fast presence uses one replaceable row per Peer. CoreObservation records inventory completeness.

An ambiguous Peer retains a prior durable owner pair when one existed; ambiguity only changes whether consumers may treat the Peer as resolved.

Enrollment stores one internal state and the idempotency key/request hash on the Enrollment row. No general idempotency table or secret replay store exists.

## Sync

System composition starts an observation, asks Core to fetch complete identity/Peer inventories outside the database transaction, then opens one shared transaction. Core applies the inventory and completes the observation while composition marks all referencing Layers pending before commit. A failed fetch records a failed observation and never marks absence.

Stale running observations left by process failure are marked failed at startup.

## Enrollment crash boundary

Persist each returned remote ID immediately. Remote metadata contains a correlation ID for diagnosis only. If create outcome is uncertain before an ID was stored, transition the Enrollment to `needs_attention`; do not adopt, delete or create a duplicate from metadata alone.

## Safety gate

User-facing Core writes authorize identity/Enrollment classes before mutation. Enrollment workers authorize backend writes immediately before each remote request. No safety permit is persisted or passed through domain records.
