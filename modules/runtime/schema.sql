-- Runtime schema reference for Valkona v0.11.4.
-- Cross-module foreign keys are added by integration/schema.sql. REFERENCE ONLY.

CREATE TYPE layer_revision_action AS ENUM ('apply', 'retire');
CREATE TYPE layer_revision_status AS ENUM ('valid', 'blocked');
CREATE TYPE layer_projection_status AS ENUM ('pending', 'applied', 'blocked', 'inactive', 'needs_attention');
CREATE TYPE reconcile_attempt_status AS ENUM ('running', 'succeeded', 'failed', 'needs_attention');
CREATE TYPE netbird_mapping_status AS ENUM ('managed', 'drifted', 'remote_missing', 'conflict');

CREATE TABLE runtime_layer_revisions (
  id text PRIMARY KEY,
  layer_id text NOT NULL,
  layer_generation bigint NOT NULL,
  layer_name_snapshot text NOT NULL,
  layer_kind_snapshot text NOT NULL CHECK (layer_kind_snapshot IN ('personal', 'system')),
  action layer_revision_action NOT NULL,
  core_observation_id text,
  status layer_revision_status NOT NULL,
  input_snapshot_hash text NOT NULL,
  compiled_spec_hash text,
  compiled_policy_json jsonb,
  diagnostics_json jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_by_user_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (id, layer_id),
  CHECK (
    (action = 'apply' AND status = 'valid' AND compiled_spec_hash IS NOT NULL AND compiled_policy_json IS NOT NULL)
    OR (action = 'apply' AND status = 'blocked' AND compiled_policy_json IS NULL)
    OR (action = 'retire' AND status = 'valid' AND compiled_policy_json IS NULL)
  )
);

CREATE TABLE runtime_layer_projection_states (
  layer_id text PRIMARY KEY,
  work_version bigint NOT NULL DEFAULT 1 CHECK (work_version > 0),
  desired_revision_id text,
  applied_revision_id text,
  status layer_projection_status NOT NULL DEFAULT 'pending',
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (desired_revision_id, layer_id) REFERENCES runtime_layer_revisions(id, layer_id),
  FOREIGN KEY (applied_revision_id, layer_id) REFERENCES runtime_layer_revisions(id, layer_id)
);

CREATE TABLE runtime_reconcile_attempts (
  id text PRIMARY KEY,
  layer_id text NOT NULL,
  target_revision_id text NOT NULL,
  target_work_version bigint NOT NULL CHECK (target_work_version > 0),
  status reconcile_attempt_status NOT NULL,
  observed_before_hash text,
  observed_after_hash text,
  failure_code text,
  failure_detail text,
  started_at timestamptz NOT NULL,
  completed_at timestamptz,
  FOREIGN KEY (target_revision_id, layer_id) REFERENCES runtime_layer_revisions(id, layer_id)
);

CREATE TABLE runtime_netbird_object_maps (
  id text PRIMARY KEY,
  local_resource_type text NOT NULL,
  local_resource_id text NOT NULL,
  remote_object_type text NOT NULL,
  remote_object_id text NOT NULL,
  mapping_status netbird_mapping_status NOT NULL DEFAULT 'managed',
  last_applied_spec_hash text,
  last_observed_spec_hash text,
  last_observed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (local_resource_type, local_resource_id, remote_object_type),
  UNIQUE (remote_object_type, remote_object_id)
);
