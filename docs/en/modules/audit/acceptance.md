# Audit Acceptance

- [ ] Entries are append-only.
- [ ] User and system principals are represented without worker impersonation.
- [ ] Security/admin mutations commit their audit event atomically.
- [ ] Source modules own event meaning; Audit stores only the common envelope.
- [ ] Ordinary successful reconciliation is not duplicated in Audit.
- [ ] No secret plaintext is accepted in audit metadata.
- [ ] MVP does not imply an Audit HTTP/query interface that is not contracted.
