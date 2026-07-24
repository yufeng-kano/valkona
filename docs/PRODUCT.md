# Product

## Statement

Valkona lets users describe access topology at a higher level than raw NetBird Groups and Policies. One installation controls one NetBird account through the supported public HTTP API.

Valkona is a modular monolith. It is not a generic SDN controller, identity provider, DNS service, multi-backend abstraction or enterprise workflow platform.

## Users

- `member` manages owned Peers, Enrollments and Personal Layers.
- `admin` manages System Layers, identity bindings, ownership resolution and system diagnostics.

## MVP outcome

A member can authenticate through OIDC, obtain a resolved Peer, create a Personal Layer, describe a Layer-local Service, grant access from a Node, Group or `selector: all`, and inspect projection/Explain results.

An admin can inspect complete Peer inventory, resolve ownership explicitly, manage System Layers, and diagnose safety, drift, mappings and reconciliation failures.

## Safety premise

Valkona serves only after confirming both of the following:

1. the connected NetBird account matches the configured expected account identity;
2. NetBird's broad default all-to-all allow rule is disabled or absent.

A runtime mismatch or reappearance seals the process and stops writes until operator repair and restart.

## Non-goals

- DNS
- multiple NetBird accounts or other backends
- multi-tenancy, workspaces or organizations
- custom RBAC or collaborative Layer editing
- Layer hierarchy, inheritance or cross-Layer references
- nested/dynamic Groups or selectors other than `all`
- explicit deny or policy priority
- manual Revision/Plan/Apply workflow
- microservices, distributed workers or a generic event platform
- complete NetBird state archival or Peer presence analytics
