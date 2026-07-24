# Core Contract

**Owner:** Core  
**Imports:** `Audit.Sink.v1`, `System.OperationGate.v1`, `System.Principal.v1`, `Backend.Error.v1`, outbound ports  
**Exports:** `Core.Application.v1`, `Core.IdentityCommandPort.v1`, `Core.InventorySync.v1`, `Core.EnrollmentReconciler.v1`, Core public values and outbound ports

## Responsibility

Core owns authenticated users, observed NetBird Peers, durable Peer ownership/attribution, latest presence, identity bindings, Enrollment and inventory observations. It does not own access topology or Policy projection.

## Public identity and Peer types

### `Core.UserContext.v1`

```text
user_id
role: member | admin
status: active | disabled
oidc_identity: (issuer, subject)
```

Identity uniqueness is `(issuer, subject)`. Bootstrap administrators are exact configured pairs. The last active administrator is protected from demotion/disable.

### `Core.PeerRef.v1`

```text
peer_id
netbird_peer_id
owner_user_id nullable
owner_source: valkona_enrollment | netbird_identity_binding | admin_assignment | null
attribution: resolved | ambiguous | unresolved
inventory_presence: present | missing
```

A normal Topology Node requires `resolved`. Offline presence does not alter attribution. A missing/unresolved Peer remains durable.

Attribution precedence is existing durable owner, completed Enrollment, explicit one-to-one identity binding, then unresolved. Conflicting explicit evidence yields `ambiguous`; similarity of email/name is not evidence.

If a previously resolved Peer becomes ambiguous, its durable `owner_user_id` and `owner_source` remain stored as historical authority while `attribution=ambiguous` prevents Topology from treating it as resolved. An ambiguous Peer with no prior owner stores both owner fields as null.

### `Core.PeerPresence.v1`

```text
status: online | offline | unknown
netbird_last_seen_at nullable
observed_at nullable
```

Missing inventory or absent/stale telemetry yields `unknown`; fresh connected true/false yields online/offline.

### Views and commands

```text
Core.UserView.v1:
  user_id, display_name, email nullable, role, status, created_at, updated_at

Core.UpdateUserCommand.v1:
  role nullable, status nullable

Core.PeerView.v1:
  peer_ref, presence, name, alias nullable, origin, netbird_ip nullable,
  dns_label nullable, os nullable, last_inventory_seen_at nullable

Core.AssignPeerOwnerCommand.v1:
  owner_user_id

Core.IdentityBindingCommand.v1:
  netbird_user_id, user_id

Core.BindingView.v1:
  binding_id, netbird_user_id, user_id, created_by_user_id, created_at

Core.EnrollmentCommand.v1:
  expires_at nullable

Core.EnrollmentView.v1:
  enrollment_id, user_id, status, expires_at, matched_peer_id nullable,
  created_at, completed_at nullable, failure_code nullable

Core.EnrollmentCreation.v1:
  enrollment: EnrollmentView
  setup_key_plaintext nullable
  secret_replayable: false
```

### `Core.ListQuery.v1`

```text
cursor nullable
limit
owner_user_id nullable
status nullable
```

Pages contain `items[]` and opaque `next_cursor nullable`. Unsupported filters for a specific operation are rejected.

## Reader contracts

### `Core.PeerReader.v1`

```text
GetPeerRef(context, peer_id) -> PeerRef | Error
GetPeerRefs(context, peer_ids[]) -> {refs_by_id, missing_ids[]}
```

Consumers receive public Peer values, never Core rows or NetBird DTOs.

### `Core.ObservationRef.v1`

```text
observation_id
status: running | complete | failed
inventory_hash nullable
started_at
completed_at nullable
```

### `Core.ObservationReader.v1`

```text
GetObservationRef(context, observation_id) -> ObservationRef | Error
GetLatestCompleteObservation(context) -> ObservationRef | Error
```

### `Core.ObservationResult.v1`

```text
observation: ObservationRef
changed_topology_relevant_peer_ids[]
```

Only a complete observation proves absent Peers missing. The changed list contains stable identity, owner, attribution or inventory-presence changes; it excludes connected/last-seen-only changes.

## `Core.Application.v1`

```text
GetCurrentUser(actor) -> Core.UserView.v1
ListUsers(actor, Core.ListQuery.v1) -> Page<Core.UserView.v1>
GetUser(actor, user_id) -> Core.UserView.v1
UpdateUser(actor, user_id, Core.UpdateUserCommand.v1) -> Core.UserView.v1

ListPeers(actor, Core.ListQuery.v1) -> Page<Core.PeerView.v1>
GetPeer(actor, peer_id) -> Core.PeerView.v1
ListIdentityBindings(actor, Core.ListQuery.v1) -> Page<Core.BindingView.v1>
GetIdentityBinding(actor, binding_id) -> Core.BindingView.v1

CreateEnrollment(actor, Core.EnrollmentCommand.v1, idempotency_key) -> Core.EnrollmentCreation.v1
GetEnrollment(actor, enrollment_id) -> Core.EnrollmentView.v1
RevokeEnrollment(actor, enrollment_id) -> Core.EnrollmentView.v1
```

The application authorizes `identity_write` for user-role/status changes and `enrollment_issue` for Enrollment creation/revoke before starting those mutations. Peer owner and identity-binding commands are exposed through the transactional command port below so composition can invalidate affected Layers atomically. Members see owned Peers/Enrollments; admins see complete inventory. Disabled users cannot create active sessions or mutations. Disabling does not implicitly retire Layers.

## Transactional identity commands

### `Core.TopologyChangeSet.v1`

```text
changed_topology_relevant_peer_ids[]
```

### `Core.IdentityCommandPort.v1`

```text
AssignPeerOwner(transaction, actor, peer_id, Core.AssignPeerOwnerCommand.v1)
  -> Core.PeerView.v1 + Core.TopologyChangeSet.v1

CreateIdentityBinding(transaction, actor, Core.IdentityBindingCommand.v1)
  -> Core.BindingView.v1 + Core.TopologyChangeSet.v1

DeleteIdentityBinding(transaction, actor, binding_id)
  -> Core.TopologyChangeSet.v1
```

These commands enforce admin authority and return every Peer whose stable owner/attribution facts changed. Composition commits the Core change together with Runtime pending markers for all referencing Layers.

### Enrollment creation

One Enrollment creates one dedicated staging Group and one one-off, usage-limit-one Setup Key whose auto-groups contain only that Group. The first successful response may return plaintext once; Valkona stores neither plaintext nor ciphertext. The same idempotency key and payload returns the existing Enrollment without a second remote create and cannot replay plaintext.

Ownership commits before remote cleanup.

Internal state is a single closed set. `EnrollmentView.status` is derived as follows:

```text
creating_staging_group | creating_setup_key                 -> creating
issued_waiting_for_peer                                    -> issued
peer_detected_persisting_ownership | cleaning_*             -> peer_detected
completed | expired | revoked | failed | needs_attention    -> same public value
```

## Crash-safe inventory synchronization

### `Core.InventorySnapshot.v1`

```text
identities[]: Core.IdentityRecord.v1
peers[]: Core.ObservedPeer.v1
observed_at
inventory_hash
```

The snapshot is complete-or-error; pagination is adapter-internal.

### `Core.InventorySync.v1`

```text
StartObservation(context) -> ObservationRef
FetchInventory(context, observation_id) -> InventorySnapshot | Backend.Error.v1
ApplyInventory(transaction, observation_id, InventorySnapshot) -> ObservationResult
FailObservation(context, observation_id, failure) -> ObservationRef
RecoverStaleRunningObservations(context) -> count
```

`ApplyInventory` updates Peer identity/presence/attribution and completes the observation in the caller-supplied transaction. System composition commits this result together with all affected Runtime pending markers. A failed/partial fetch never calls `ApplyInventory` and never marks absent Peers missing.

## `Core.EnrollmentReconciler.v1`

```text
ReconcileEnrollments(context, principal: System.Principal.v1) -> Core.EnrollmentReconcileSummary.v1
```

```text
Core.EnrollmentReconcileSummary.v1:
  inspected, completed, failed, needs_attention
```

Immediately before every staging-Group/Setup-Key create, revoke or delete, Core authorizes `backend_write` with the system principal. Sealing cancels active contexts and prevents new remote writes.

## Outbound types and ports

### Inventory types

```text
Core.IdentityRecord.v1:
  netbird_user_id, idp_id nullable, email nullable, display_name nullable

Core.ObservedPeer.v1:
  netbird_peer_id, netbird_user_id nullable, name,
  netbird_ip nullable, dns_label nullable, os nullable,
  connected nullable, last_seen nullable,
  extra_metadata: allowlisted object

Core.IdentityInventoryResult.v1:
  identities[], observed_at

Core.PeerInventoryResult.v1:
  peers[], observed_at
```

### `Core.IdentityInventoryPort.v1`

```text
ListIdentities(context) -> IdentityInventoryResult | Backend.Error.v1
```

### `Core.PeerInventoryPort.v1`

```text
ListPeers(context) -> PeerInventoryResult | Backend.Error.v1
```

Both results are complete or errors. A partial backend fetch never appears as successful inventory.

### Enrollment backend types

```text
Core.StagingGroupSpec.v1:
  name, description, expires_at

Core.SetupKeySpec.v1:
  name, expires_at, usage_limit=1, one_off=true, auto_group_ids[exactly one]

Core.RemoteGroupRef.v1:
  remote_group_id, canonical_name

Core.SetupKeyCreation.v1:
  remote_setup_key_id, plaintext, expires_at
```

### `Core.EnrollmentBackendPort.v1`

```text
CreateStagingGroup(context, StagingGroupSpec, correlation_id) -> RemoteGroupRef | Backend.Error.v1
DeleteGroup(context, remote_group_id) -> void | Backend.Error.v1
CreateSetupKey(context, SetupKeySpec, correlation_id) -> SetupKeyCreation | Backend.Error.v1
RevokeSetupKey(context, remote_setup_key_id) -> void | Backend.Error.v1
ListGroupPeers(context, remote_group_id) -> PeerInventoryResult | Backend.Error.v1
```

Create calls require a correlation ID. `outcome_uncertain` means the remote create may have succeeded and automatic retry/adoption is unsafe.

## Errors

```text
invalid_argument
forbidden
resource_not_found
conflict
idempotency_payload_mismatch
enrollment_secret_not_replayable
remote_create_outcome_uncertain
backend_unavailable
```
