# Backend Error Contract

**Owner:** shared outbound boundary  
**Exports:** `Backend.Error.v1`

Outbound adapters return one stable category plus optional diagnostics:

```text
unauthenticated
forbidden
not_found
conflict
rate_limited
timeout
unavailable
invalid_response
outcome_uncertain
```

Consumers branch only on the category. `outcome_uncertain` means a non-idempotent remote write may have happened; automatic retry, adoption or duplicate creation is unsafe.
