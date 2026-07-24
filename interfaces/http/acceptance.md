# HTTP Interface Acceptance

- [ ] Domain/application errors preserve their stable code in the HTTP envelope.
- [ ] `/livez` and `/readyz` are unauthenticated and expose only `System.HealthView.v1`.
- [ ] All `/api/v1` routes require authentication unless explicitly documented.
- [ ] HTTP does not construct or pass an OperationPermit/capability.
- [ ] Retry reconciliation maps to `System.TopologyApplication.RetryLayerReconciliation`.
- [ ] Idempotency mismatch, secret-not-replayable, blocked/needs-attention and uncertain-create errors use the documented conflict mapping.
- [ ] Rate-limit, invalid-response, unavailable and timeout backend categories retain their documented status mapping.
- [ ] Unknown command fields are rejected before application invocation.
