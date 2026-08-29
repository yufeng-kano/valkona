-- Audit schema reference for Valkona v0.11.4. REFERENCE ONLY.

CREATE TYPE audit_actor_kind AS ENUM ('user', 'system');

CREATE TABLE audit_entries (
  id text PRIMARY KEY,
  actor_kind audit_actor_kind NOT NULL,
  actor_user_id text,
  actor_system_component text,
  source_module text NOT NULL,
  event_type text NOT NULL,
  resource_type text,
  resource_id text,
  metadata_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (actor_kind = 'user' AND actor_user_id IS NOT NULL AND actor_system_component IS NULL)
    OR (actor_kind = 'system' AND actor_user_id IS NULL AND actor_system_component IN ('peer_sync', 'enrollment_reconciler', 'topology_reconciler', 'safety_monitor', 'startup_doctor'))
  )
);
