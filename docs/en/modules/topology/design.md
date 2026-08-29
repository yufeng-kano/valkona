# Topology Design

Topology repositories operate on a caller-provided transaction. They validate Layer authority, same-Layer references and Peer eligibility through public Core contracts.

LayerSnapshot construction reads only Topology-owned tables and resolves Peer contract values through `Core.PeerReader.v1` at the application boundary.

Only Layer and AccessEdge are enableable: Layer disable requests retirement; AccessEdge disable suspends one grant.
