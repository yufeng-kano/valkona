-- Cross-module persistence integration for Valkona v0.11.4.
-- Apply after Core, Topology, Runtime and Audit module schemas. REFERENCE ONLY.

ALTER TABLE topology_layers
  ADD CONSTRAINT topology_layers_owner_user_fk
  FOREIGN KEY (owner_user_id) REFERENCES core_users(id) ON DELETE RESTRICT;

ALTER TABLE topology_nodes
  ADD CONSTRAINT topology_nodes_peer_fk
  FOREIGN KEY (peer_id) REFERENCES core_peers(id) ON DELETE RESTRICT;

ALTER TABLE runtime_layer_projection_states
  ADD CONSTRAINT runtime_projection_layer_fk
  FOREIGN KEY (layer_id) REFERENCES topology_layers(id) ON DELETE CASCADE;

ALTER TABLE runtime_layer_revisions
  ADD CONSTRAINT runtime_revision_observation_fk
  FOREIGN KEY (core_observation_id) REFERENCES core_observations(id) ON DELETE RESTRICT;

ALTER TABLE runtime_layer_revisions
  ADD CONSTRAINT runtime_revision_creator_fk
  FOREIGN KEY (created_by_user_id) REFERENCES core_users(id) ON DELETE SET NULL;

ALTER TABLE audit_entries
  ADD CONSTRAINT audit_actor_user_fk
  FOREIGN KEY (actor_user_id) REFERENCES core_users(id) ON DELETE SET NULL;
