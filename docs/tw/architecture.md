# 架構

**一個 process、一個 PostgreSQL 資料庫，裡面切成五個模組加一個組合層。**
模組是程式碼邊界，不是可以獨立部署的服務。

## 模組圖

```text
                     interfaces/http
                           │
                           ▼
                  integration/composition
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
          Core          Topology        Runtime
            │              │              │
            └───────┬──────┴──────┬──────┘
                    ▼             ▼
                 Audit.Sink    outbound ports
                                  │
                                  ▼
                              NetBird adapter
```

## 每個模組管什麼

| 模組 | 負責 | 文件 |
| --- | --- | --- |
| Core | 使用者、Peer、歸屬、Enrollment、裝置清單同步 | [`core.md`](core.md) |
| Topology | Layer 和裡面的存取規則 | [`topology.md`](topology.md) |
| Runtime | 編譯 Layer、對齊 NetBird、Explain | [`runtime.md`](runtime.md) |
| NetBird adapter | 唯一碰 NetBird API 的地方 | [`netbird.md`](netbird.md) |
| Audit | append-only 稽核紀錄 | [`audit.md`](audit.md) |
| Integration（組合層） | 跨模組交易、process 安全、operation gate | 本文件下方 |
| HTTP | 對外 API，翻譯請求成內部操作 | [`http-api.md`](http-api.md) |

## 依賴規則

**模組之間只能透過對方的公開 contract 溝通，不能碰對方的資料表或內部型別。**

- Core 不依賴 Topology 和 Runtime。
- Topology 只用 Core 公開的 user 和 Peer contract。
- Runtime 用 Core 的 reader 和 Topology 的 snapshot。
- Audit 是共用的寫入口，只存信封，不管事件語意。
- NetBird adapter 實作 Core、Runtime、System 宣告的 outbound port。
- HTTP 只呼叫應用層介面，模組本身不定義路由。

## 資料誰擁有

**一份資料只有一個模組是老大。**

| 老大 | 資料 |
| --- | --- |
| Core | User、Peer、PeerRuntimeState、IdentityBinding、Enrollment、CoreObservation |
| Topology | Layer、Node、Group、Service、Exposure、AccessEdge |
| Runtime | LayerRevision、LayerProjectionState、ReconcileAttempt、NetBirdObjectMap |
| Audit | AuditEntry |
| 組合層 | 跨模組 FK 和交易編排，沒有自己的資料 |
| System composition | process 內的 SafetyState 和 instance lock |

每個模組的 schema 只建自己的表。
跨模組的 foreign key 由 `integration/schema.sql` 事後加上，這樣資料庫有完整性，模組程式碼又不用查別人的表。

## 組合層：跨模組交易

**只要一個動作要同時動兩個模組的資料，就由組合層包成一個 transaction。**
標準流程長這樣：

```text
OperationGate.Authorize(topology_write)
→ Topology 修改，generation 加一
→ Runtime.MarkPending，work_version 加一
→ commit
→ 順便叫醒 reconciler（叫不醒也沒關係）
```

queue 只是加速用的，真正的待辦來源是資料庫裡的 `work_version` 和 ProjectionState。
process 掛掉重啟後，掃資料庫就能找回全部待辦。

## 安全機制

**核心概念是 fail-closed：條件不滿足就停，不猜。**

process 有三種模式：

- `starting`：還在開機檢查，不開 HTTP、不跑 worker。
- `active`：檢查通過，正常服務。
- `sealed`：執行中發現安全問題，唯讀模式，修好要重啟。

操作分成六類（operation class）：`read`、`diagnostic`、`topology_write`、`identity_write`、`enrollment_issue`、`backend_write`。
`active` 全放行，`sealed` 只放行 read 和 diagnostic。

**OperationGate 在兩個地方檢查。**
第一次在應用層邊界，開始本地寫入之前。
第二次在每一個 NetBird 寫入的前一刻，再檢查一次。
中間不傳任何 capability token，這是刻意的簡化。

**sealed 的誠實邊界：**已經開始的本地 transaction 可以 commit 完，結果留在資料庫當 pending 的期望狀態。
但它到不了 NetBird，要等下次 active 的 process 來對齊。

## 開機安全檢查

**兩個證據都拿到才開始服務。**

1. 連上的 NetBird 帳號身分，跟設定檔的 `expected_account_identity` 完全一致。
2. NetBird 預設的 all-to-all 全通規則已關閉或不存在。

證據拿不到（unknown）也算失敗。
執行中定期重驗，發現不對就進 sealed，取消進行中的 backend 寫入。

## 單一 process

**一套安裝同時只准一個 Valkona process 在跑。**
開機先搶 PostgreSQL advisory lock，搶到才做安全檢查，鎖持有到 process 結束。
搶不到就直接退出，沒有分散式選主。

## 併發模型

**每個 Layer 有一個只增不減的 `work_version`，用 compare-and-swap 防止舊工作蓋新工作。**
細節在 [`runtime.md`](runtime.md)。
一個 process 內同時只有一個 NetBird writer 在跑。

## 文件對應（給讀英文原版的人）

- `contract.md` 等於公開 header：操作、型別、保證、錯誤。
- `design.md` 是內部實作建議，不能推翻 contract。
- `schema.sql` 是該模組資料表的參考版，正式以 migration 為準。
- `acceptance.md` 是 contract 的驗收 checklist。
