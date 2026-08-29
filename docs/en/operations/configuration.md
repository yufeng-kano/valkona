# Configuration

Configuration is loaded before the HTTP listener starts.

Required groups:

- database connection, migration policy and advisory instance-lock key;
- OIDC issuer/client/audience and exact bootstrap admin identities;
- NetBird API URL/token source;
- expected stable NetBird account identity;
- Peer presence freshness and sync intervals;
- Enrollment expiry/polling;
- reconciliation and retention bounds.

Secrets are referenced through environment/secret-file mechanisms and are not embedded in committed configuration.

One installation supports one active process. Startup holds a PostgreSQL advisory lock for process lifetime; lock failure exits before HTTP/workers start.

If Phase 0 proves no reliable API account identity field, implementation must document and validate an operator-pinned alternative evidence mechanism before startup safety can pass.
