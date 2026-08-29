# HTTP API

**HTTP 層只做四件事：驗證身分、驗證輸入格式、呼叫應用層操作、把結果和錯誤翻成 HTTP。**
它沒有任何 domain 邏輯、安全政策或 NetBird 邏輯。

## 通用規範

- base path 是 `/api/v1`，只有 `/livez` 和 `/readyz` 例外。
- 請求和回應都是 JSON，除了帶密鑰的特殊回應。
- command body 出現不認識的欄位直接拒絕。
- 分頁用不透明的 cursor 加上限的 limit。
- 時間一律 RFC 3339 UTC。
- 資源 ID 是不透明字串。
- `Idempotency-Key` 只在該操作宣告需要時才必填。
- `/livez` 和 `/readyz` 不用驗證，只回健康狀態的形狀。
- 其他所有 `/api/v1` 路由都要驗證，除非文件明講不用。

## 錯誤格式

```json
{
  "error": {
    "code": "resource_in_use",
    "message": "The resource is referenced.",
    "details": {}
  }
}
```

**domain 錯誤碼永遠保留在信封裡。**
就算多個錯誤碼共用同一個 HTTP status，也不能把具體的碼換成籠統的。

| HTTP status | 錯誤碼 |
| --- | --- |
| 400 | invalid_argument |
| 401 | unauthenticated |
| 403 | forbidden、runtime_sealed |
| 404 | resource_not_found |
| 409 | resource_in_use、conflict、layer_not_retired、idempotency_payload_mismatch、enrollment_secret_not_replayable、reconciliation_blocked、needs_attention、remote_conflict、remote_create_outcome_uncertain |
| 429 | rate_limited |
| 500 | internal_error、audit_unavailable |
| 502 | invalid_response、remote_readback_mismatch |
| 503 | backend_unavailable、unavailable |
| 504 | timeout |

## 路由總表

**Core：使用者、裝置、綁定、認領。**

```text
GET    /api/v1/core/me
GET    /api/v1/core/users
GET    /api/v1/core/users/{user_id}
PATCH  /api/v1/core/users/{user_id}
GET    /api/v1/core/peers
GET    /api/v1/core/peers/{peer_id}
POST   /api/v1/core/peers/{peer_id}/assign-owner
GET    /api/v1/core/netbird-identity-bindings
POST   /api/v1/core/netbird-identity-bindings
GET    /api/v1/core/netbird-identity-bindings/{binding_id}
DELETE /api/v1/core/netbird-identity-bindings/{binding_id}
POST   /api/v1/core/enrollments
GET    /api/v1/core/enrollments/{enrollment_id}
POST   /api/v1/core/enrollments/{enrollment_id}/revoke
```

assign-owner 和 binding 的建立刪除走組合層，因為要跟 Layer 失效標記一起 commit。

**Topology：藍圖 CRUD，六種資源都是同一個模式。**

```text
GET/POST                /api/v1/topology/layers
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}
GET/POST                /api/v1/topology/layers/{layer_id}/nodes
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/nodes/{node_id}
GET/POST                /api/v1/topology/layers/{layer_id}/groups
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/groups/{group_id}
GET/POST                /api/v1/topology/layers/{layer_id}/services
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/services/{service_id}
GET/POST                /api/v1/topology/layers/{layer_id}/exposures
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/exposures/{exposure_id}
GET/POST                /api/v1/topology/layers/{layer_id}/access-edges
GET/PATCH/DELETE        /api/v1/topology/layers/{layer_id}/access-edges/{edge_id}
```

**Runtime 查詢和 Explain：**

```text
POST /api/v1/topology/explain?basis=applied|desired
GET  /api/v1/topology/access-edges/{edge_id}/explain
GET  /api/v1/topology/layers/{layer_id}/projection
GET  /api/v1/topology/layers/{layer_id}/revisions
GET  /api/v1/topology/layers/{layer_id}/revisions/{revision_id}
GET  /api/v1/topology/reconcile-attempts/{attempt_id}
POST /api/v1/topology/layers/{layer_id}/retry-reconciliation
```

retry 只排工作，不在請求裡直接寫 NetBird。

**System：狀態和健康檢查。**

```text
GET /api/v1/system/status
GET /api/v1/system/netbird/diagnostics
GET /livez
GET /readyz
```

status 給所有登入的使用者，NetBird diagnostics 只給 admin。
`readyz` 在 sealed 時回 false。
沒有任何 HTTP 路由可以解除 sealed 或重跑開機檢查。

## 驗收重點

- domain 錯誤碼在 HTTP 信封裡保持穩定。
- 不認識的欄位在進應用層之前就拒絕。
- HTTP 不建立也不傳遞任何安全 capability。
