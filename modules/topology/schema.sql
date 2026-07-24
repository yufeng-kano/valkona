-- Topology schema reference for Valkona v0.11.4.
-- Cross-module foreign keys are added by integration/schema.sql. REFERENCE ONLY.

CREATE TYPE layer_kind AS ENUM ('personal', 'system');
CREATE TYPE source_kind AS ENUM ('node', 'group', 'selector');

CREATE TABLE topology_layers (
  id text PRIMARY KEY,
  kind layer_kind NOT NULL,
  owner_user_id text,
  name text NOT NULL,
  description text,
  enabled boolean NOT NULL DEFAULT true,
  generation bigint NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((kind = 'personal' AND owner_user_id IS NOT NULL) OR (kind = 'system' AND owner_user_id IS NULL))
);

CREATE TABLE topology_nodes (
  id text PRIMARY KEY,
  layer_id text NOT NULL REFERENCES topology_layers(id) ON DELETE RESTRICT,
  peer_id text NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (layer_id, peer_id),
  UNIQUE (id, layer_id)
);

CREATE TABLE topology_groups (
  id text PRIMARY KEY,
  layer_id text NOT NULL REFERENCES topology_layers(id) ON DELETE RESTRICT,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (layer_id, name),
  UNIQUE (id, layer_id)
);

CREATE TABLE topology_group_members (
  layer_id text NOT NULL,
  group_id text NOT NULL,
  node_id text NOT NULL,
  PRIMARY KEY (group_id, node_id),
  FOREIGN KEY (group_id, layer_id) REFERENCES topology_groups(id, layer_id) ON DELETE RESTRICT,
  FOREIGN KEY (node_id, layer_id) REFERENCES topology_nodes(id, layer_id) ON DELETE RESTRICT
);

CREATE TABLE topology_services (
  id text PRIMARY KEY,
  layer_id text NOT NULL REFERENCES topology_layers(id) ON DELETE RESTRICT,
  name text NOT NULL,
  protocol text NOT NULL CHECK (protocol IN ('tcp', 'udp', 'icmp')),
  ports_json jsonb NOT NULL DEFAULT '[]'::jsonb,
  CHECK (jsonb_typeof(ports_json) = 'array'),
  CHECK ((protocol = 'icmp' AND jsonb_array_length(ports_json) = 0) OR (protocol IN ('tcp', 'udp') AND jsonb_array_length(ports_json) > 0)),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (layer_id, name),
  UNIQUE (id, layer_id)
);

CREATE TABLE topology_exposures (
  id text PRIMARY KEY,
  layer_id text NOT NULL REFERENCES topology_layers(id) ON DELETE RESTRICT,
  name text NOT NULL,
  destination_node_id text,
  destination_group_id text,
  service_id text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (layer_id, name),
  UNIQUE (id, layer_id),
  CHECK ((destination_node_id IS NOT NULL)::int + (destination_group_id IS NOT NULL)::int = 1),
  FOREIGN KEY (destination_node_id, layer_id) REFERENCES topology_nodes(id, layer_id) ON DELETE RESTRICT,
  FOREIGN KEY (destination_group_id, layer_id) REFERENCES topology_groups(id, layer_id) ON DELETE RESTRICT,
  FOREIGN KEY (service_id, layer_id) REFERENCES topology_services(id, layer_id) ON DELETE RESTRICT
);

CREATE TABLE topology_access_edges (
  id text PRIMARY KEY,
  layer_id text NOT NULL REFERENCES topology_layers(id) ON DELETE RESTRICT,
  name text NOT NULL,
  source_kind source_kind NOT NULL,
  source_node_id text,
  source_group_id text,
  source_selector_type text,
  exposure_id text NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (layer_id, name),
  CHECK (
    (source_kind = 'node' AND source_node_id IS NOT NULL AND source_group_id IS NULL AND source_selector_type IS NULL)
    OR (source_kind = 'group' AND source_node_id IS NULL AND source_group_id IS NOT NULL AND source_selector_type IS NULL)
    OR (source_kind = 'selector' AND source_node_id IS NULL AND source_group_id IS NULL AND source_selector_type = 'all')
  ),
  FOREIGN KEY (source_node_id, layer_id) REFERENCES topology_nodes(id, layer_id) ON DELETE RESTRICT,
  FOREIGN KEY (source_group_id, layer_id) REFERENCES topology_groups(id, layer_id) ON DELETE RESTRICT,
  FOREIGN KEY (exposure_id, layer_id) REFERENCES topology_exposures(id, layer_id) ON DELETE RESTRICT
);
