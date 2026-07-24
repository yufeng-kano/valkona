# 文件索引

最後更新：2026-07-24

本索引紀錄 `docs/` 內所有文件的路徑與摘要。每次執行任務前，先閱讀本檔，確認是否已有相關文件。

`docs/` 是本專案唯一真實來源。寫任何程式碼或功能改動前，必須先新增或更新對應文件，再依文件實作。

## 文件清單

| 路徑 | 摘要 |
| --- | --- |
| [`adr/0001-modular-monolith-and-contract-ownership.md`](adr/0001-modular-monolith-and-contract-ownership.md) | 模組化單體與契約擁有權 |
| [`adr/0002-per-layer-reconciliation.md`](adr/0002-per-layer-reconciliation.md) | 獨立的 per-Layer reconciliation |
| [`adr/0003-netbird-safety-and-object-authority.md`](adr/0003-netbird-safety-and-object-authority.md) | fail-closed NetBird safety / ObjectMap 權威 |
| [`adr/0004-application-contracts-and-adapters.md`](adr/0004-application-contracts-and-adapters.md) | 可呼叫應用契約與適配器邊界 |
| [`adr/0005-monotonic-work-and-gate-boundaries.md`](adr/0005-monotonic-work-and-gate-boundaries.md) | 單調 Layer work 與 safety-gate 邊界 |
| [`adr/index.md`](adr/index.md) | Architecture Decision Records：設計決策與理由（不重新定義現行行為）。 |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | 模組圖、適配器與組合層 |
| [`CHANGELOG.md`](CHANGELOG.md) | 版本變更紀錄 |
| [`CONTRACTS.md`](CONTRACTS.md) | 公開契約總索引 |
| [`contracts/backend.md`](contracts/backend.md) | 後端錯誤類別等共用 outbound 契約 |
| [`contracts/configuration.example.yaml`](contracts/configuration.example.yaml) | 設定檔範例 |
| [`contracts/index.md`](contracts/index.md) | 共用系統安全、後端錯誤與設定契約。 |
| [`contracts/system.md`](contracts/system.md) | 系統安全、閘道與診斷契約 |
| [`DOCUMENTATION.md`](DOCUMENTATION.md) | 文件規則與契約層級 |
| [`integration/acceptance.md`](integration/acceptance.md) | 整合層驗收測試 |
| [`integration/contract.md`](integration/contract.md) | 跨模組應用交易與組合契約 |
| [`integration/flows.md`](integration/flows.md) | 整合流程說明（不重新定義行為） |
| [`integration/index.md`](integration/index.md) | 組合層契約、跨模組交易、流程與 FK schema。 |
| [`integration/schema.sql`](integration/schema.sql) | 跨模組 FK schema |
| [`interfaces/http/acceptance.md`](interfaces/http/acceptance.md) | HTTP 介面驗收測試 |
| [`interfaces/http/contract.md`](interfaces/http/contract.md) | HTTP 介面契約 |
| [`interfaces/http/index.md`](interfaces/http/index.md) | HTTP inbound 適配器：契約、路由對應與驗收。 |
| [`interfaces/http/routes.md`](interfaces/http/routes.md) | 路由到操作的對應 |
| [`interfaces/index.md`](interfaces/index.md) | 對外介面適配器（目前為 HTTP）。 |
| [`MANIFEST.json`](MANIFEST.json) | 套件檔案完整性清單（JSON） |
| [`MANIFEST.md`](MANIFEST.md) | 套件檔案完整性清單（Markdown） |
| [`modules/audit/acceptance.md`](modules/audit/acceptance.md) | Audit 驗收測試 |
| [`modules/audit/contract.md`](modules/audit/contract.md) | Audit 僅追加事件 sink 契約 |
| [`modules/audit/design.md`](modules/audit/design.md) | Audit 實作設計 |
| [`modules/audit/index.md`](modules/audit/index.md) | Audit 模組：append-only audit sink。 |
| [`modules/audit/schema.sql`](modules/audit/schema.sql) | Audit 持久化 schema |
| [`modules/core/acceptance.md`](modules/core/acceptance.md) | Core 驗收測試 |
| [`modules/core/contract.md`](modules/core/contract.md) | Core：使用者、Peer、歸屬與 Enrollment |
| [`modules/core/design.md`](modules/core/design.md) | Core 實作設計 |
| [`modules/core/index.md`](modules/core/index.md) | Core 模組：使用者、Peers、attribution 與 Enrollment。 |
| [`modules/core/schema.sql`](modules/core/schema.sql) | Core 持久化 schema |
| [`modules/index.md`](modules/index.md) | 領域模組：Core、Topology、Runtime、NetBird、Audit。 |
| [`modules/netbird/acceptance.md`](modules/netbird/acceptance.md) | NetBird 適配器驗收測試 |
| [`modules/netbird/contract.md`](modules/netbird/contract.md) | NetBird outbound 適配器契約 |
| [`modules/netbird/design.md`](modules/netbird/design.md) | NetBird 適配器設計 |
| [`modules/netbird/index.md`](modules/netbird/index.md) | NetBird 模組：outbound 適配器。 |
| [`modules/runtime/acceptance.md`](modules/runtime/acceptance.md) | Runtime 驗收測試 |
| [`modules/runtime/contract.md`](modules/runtime/contract.md) | Runtime：編譯、reconciliation、投影與 Explain |
| [`modules/runtime/design.md`](modules/runtime/design.md) | Runtime 實作設計 |
| [`modules/runtime/index.md`](modules/runtime/index.md) | Runtime 模組：編譯、reconciliation、投影與 Explain。 |
| [`modules/runtime/schema.sql`](modules/runtime/schema.sql) | Runtime 持久化 schema |
| [`modules/topology/acceptance.md`](modules/topology/acceptance.md) | Topology 驗收測試 |
| [`modules/topology/contract.md`](modules/topology/contract.md) | Topology：Layer 本地存取意圖 |
| [`modules/topology/design.md`](modules/topology/design.md) | Topology 實作設計 |
| [`modules/topology/index.md`](modules/topology/index.md) | Topology 模組：Layer-local access intent。 |
| [`modules/topology/schema.sql`](modules/topology/schema.sql) | Topology 持久化 schema |
| [`operations/configuration.md`](operations/configuration.md) | 執行期設定載入與必要群組 |
| [`operations/implementation-plan.md`](operations/implementation-plan.md) | 實作階段與順序 |
| [`operations/index.md`](operations/index.md) | 營運文件：設定、Phase 0 證據與實作順序。 |
| [`operations/phase0-validation.md`](operations/phase0-validation.md) | Phase 0 NetBird 證據驗證清單 |
| [`PRODUCT.md`](PRODUCT.md) | 產品邊界與 MVP 成果 |

