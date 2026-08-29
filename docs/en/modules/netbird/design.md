# NetBird Adapter Design

The production adapter owns token injection, deadlines, bounded retry, pagination, DTO conversion and canonical error mapping. Retry is permitted only where idempotent or where the backend outcome is known not to have occurred; uncertain create is returned explicitly.

The stateful fake stores Users, Peers, Groups, Setup Keys, Policies and account identity. Tests can alter remote state to exercise drift, safety mismatch, timeouts and create-crash windows.

`selector: all` is resolved at projection time. Compiler revisions retain semantic `all`; membership is never copied.
