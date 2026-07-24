# Audit Design

Audit is infrastructure shared by the modular monolith. It stores one append-only envelope and does not import Core, Topology or Runtime internals.

Retention is configuration-driven. Events required by security policy remain pinned; ordinary operational records may expire by age.
