# Runtime Acceptance

- [ ] Contract contains no HTTP route and does not own System safety state.
- [ ] ProjectionState is the persisted work source; queue loss is harmless.
- [ ] Every dirty event atomically increments `work_version`, including same-generation Peer changes.
- [ ] ReconcileAttempt stores `target_work_version`.
- [ ] A stale attempt cannot clear a newer pending work version.
- [ ] Verified stale work may advance applied revision while status remains pending.
- [ ] uncertain create produces needs_attention regardless of newer work.
- [ ] Invalid Peer/reference produces a blocked Revision for only that Layer.
- [ ] ProjectionState keeps only current pointers/status/work version.
- [ ] ReconcileAttempt is created at execution start and has no queued/blocked state.
- [ ] Every remote write is authorized immediately before start.
- [ ] Read-back is required before applied/inactive.
- [ ] ObjectMap, not metadata/hash/name, authorizes remote mutation.
- [ ] Explain decisions are granted/not_granted/indeterminate and report basis.
- [ ] Deletion eligibility is checked under the caller's deletion transaction locks.
- [ ] Retry schedules durable work and does not perform remote writes in the HTTP request.
- [ ] All public backend specs/canonical/results are fully owned and defined.
