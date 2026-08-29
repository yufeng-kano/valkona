# Phase 0 NetBird Validation

Implementation is evidence-gated by recorded fixtures/tests for:

1. stable NetBird account identity evidence and mismatch behavior;
2. default broad all-to-all rule/policy identification;
3. built-in All Group resolution without name guessing;
4. Policy/Rule read-back and canonical ordering;
5. Group/Policy create-update-delete and nested Rule identity behavior;
6. Setup Key one-off/usage-limit/auto-group/expiry behavior;
7. Peer/User inventory pagination and completeness failures;
8. supported API error/status/rate-limit behavior;
9. create timeout cases where outcome is uncertain.

The adapter contract may not invent unsupported guarantees. Unknown evidence fails closed.
