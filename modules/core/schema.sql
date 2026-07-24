-- Core schema reference for Valkona v0.11.4.
-- REFERENCE ONLY; production migrations are authoritative once implemented.

CREATE TYPE user_role AS ENUM ('member', 'admin');
CREATE TYPE user_status AS ENUM ('active', 'disabled');
CREATE TYPE peer_origin AS ENUM ('valkona_enrollment', 'netbird_user', 'external_setup_key', 'unknown');
CREATE TYPE attribution_status AS ENUM ('resolved', 'ambiguous', 'unresolved');
CREATE TYPE peer_owner_source AS ENUM ('valkona_enrollment', 'netbird_identity_binding', 'admin_assignment');
CREATE TYPE peer_inventory_presence AS ENUM ('present', 'missing');
CREATE TYPE enrollment_state AS ENUM (
  'creating_staging_group',
  'creating_setup_key',
  'issued_waiting_for_peer',
  'peer_detected_persisting_ownership',
  'cleaning_setup_key',
  'cleaning_staging_group',
  'completed',
  'expired',
  'revoked',
  'failed',
  'needs_attention'
);
CREATE TYPE observation_status AS ENUM ('running', 'complete', 'failed');

CREATE TABLE core_users (
  id text PRIMARY KEY,
  oidc_issuer text NOT NULL,
  oidc_subject text NOT NULL,
  display_name text NOT NULL,
  email text,
  role user_role NOT NULL DEFAULT 'member',
  status user_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (oidc_issuer, oidc_subject)
);

CREATE TABLE core_peers (
  id text PRIMARY KEY,
  netbird_peer_id text NOT NULL UNIQUE,
  netbird_user_id text,
  owner_user_id text REFERENCES core_users(id),
  name text NOT NULL,
  alias text,
  origin peer_origin NOT NULL,
  attribution_status attribution_status NOT NULL DEFAULT 'unresolved',
  owner_source peer_owner_source,
  attribution_evidence_type text,
  attribution_evidence_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  attribution_conflict_reason text,
  attribution_evaluated_at timestamptz,
  inventory_presence peer_inventory_presence NOT NULL DEFAULT 'present',
  netbird_ip inet,
  dns_label text,
  os text,
  extra_observed_metadata_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_inventory_seen_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (attribution_status = 'resolved' AND owner_user_id IS NOT NULL AND owner_source IS NOT NULL)
    OR (attribution_status = 'ambiguous' AND (
      (owner_user_id IS NULL AND owner_source IS NULL)
      OR (owner_user_id IS NOT NULL AND owner_source IS NOT NULL)
    ))
    OR (attribution_status = 'unresolved' AND owner_user_id IS NULL AND owner_source IS NULL)
  )
);

CREATE TABLE core_peer_runtime_states (
  peer_id text PRIMARY KEY REFERENCES core_peers(id) ON DELETE CASCADE,
  connected boolean,
  netbird_last_seen_at timestamptz,
  observed_at timestamptz NOT NULL
);

CREATE TABLE core_netbird_identity_bindings (
  id text PRIMARY KEY,
  netbird_user_id text NOT NULL UNIQUE,
  user_id text NOT NULL UNIQUE REFERENCES core_users(id),
  created_by_user_id text NOT NULL REFERENCES core_users(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE core_enrollments (
  id text PRIMARY KEY,
  user_id text NOT NULL REFERENCES core_users(id),
  state enrollment_state NOT NULL,
  idempotency_key text NOT NULL,
  request_hash text NOT NULL,
  netbird_setup_key_id text,
  netbird_staging_group_id text,
  matched_peer_id text REFERENCES core_peers(id),
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  failure_code text,
  failure_detail text,
  UNIQUE (user_id, idempotency_key)
);

CREATE TABLE core_observations (
  id text PRIMARY KEY,
  status observation_status NOT NULL,
  inventory_hash text,
  started_at timestamptz NOT NULL,
  completed_at timestamptz,
  failure_detail text
);
