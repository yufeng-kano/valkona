# Runtime 模組

**Runtime 把藍圖變成現實：一次編譯一張 Layer，把結果寫進 NetBird，驗證有寫成功，並記錄狀態。**
它也負責回答 Explain（為什麼能連或不能連）。
它不擁有 Topology 或 Core 的資料，也不管 process 安全狀態。

## 三種核心紀錄

**LayerRevision：編譯結果，不可變。**

- 記錄輸入快照的 hash、編譯出的 policy、狀態是 `valid` 或 `blocked`。
- action 分 `apply`（套用）和 `retire`（撤場）。
- 編譯是決定性的，過程中不碰 NetBird。
- 編譯失敗（blocked）只影響那一張 Layer，不會影響別張，也不會蓋掉之前已套用的版本。

**LayerProjectionState：每張 Layer 一列，代表目前進度。**

- `work_version`：只增不減的待辦計數器。
- `desired_revision_id` 和 `applied_revision_id`：想要的版本和實際套用的版本。
- status：`pending`、`applied`、`blocked`、`inactive`、`needs_attention`。
- 這一列是待辦的真實來源。queue 掉了沒關係，掃這張表就能找回工作。

**ReconcileAttempt：一次對齊執行的紀錄。**

- 只在真的開始執行時建立，記錄目標 revision、目標 work_version、前後觀察到的 hash、成功或失敗。

## work_version 規則

**這是整個併發設計的核心，防止舊工作蓋掉新工作。**

- 任何會弄髒 Layer 的事件都讓 `work_version` 加一。包括 Peer 歸屬變動這種不改 Layer generation 的事件。
- 對齊開始前先記下 `target_work_version`。
- 完成時用 compare-and-swap：現在的 work_version 還等於目標值，才能把狀態改成 `applied`、`blocked` 或 `inactive`。
- 版本已經變新：revision 和 attempt 照存，驗證過的套用可以更新 `applied_revision_id`，但狀態保持 `pending`，留給新工作。
- 遠端寫入結果不確定（outcome_uncertain）一律變 `needs_attention`，就算有更新的工作也一樣。

## 對齊流程

```text
挑一張 pending 的 Layer 並鎖住
→ 記下 target_work_version
→ 讀最新的 Topology LayerSnapshot
→ 透過 Core 解析 Peer
→ 存 valid 或 blocked 的 Revision
→ valid：建立 running 的 ReconcileAttempt
→ 讀取 NetBird 上目前對應的物件
→ 記憶體內算差異
→ 每個遠端寫入前先過 operation gate，逐一寫入並讀回驗證
→ 更新 ObjectMap
→ 用 CAS 完成
```

一次只有一個 NetBird writer 在跑。
不同 Layer 互相獨立，一張壞掉不擋其他張。
retire 的 revision 只刪除 ObjectMap 精確對應到的自有物件，並確認真的消失才標 `inactive`。

## ObjectMap：遠端物件的唯一權威

**只有 ObjectMap 裡的精確對應，才授權 Valkona 去改或刪 NetBird 上的物件。**
名稱、描述、hash、correlation ID 都只是診斷線索，不是所有權證明。
有相關線索但沒有正式對應的物件，一律標 `needs_attention`，不自動認領、不自動刪除、不自動重建。

每筆對應記錄本地資源、遠端物件、狀態（`managed`、`drifted`、`remote_missing`、`conflict`）和最近的 hash。

## 當機和 sealed 的行為

- ReconcileAttempt 在遠端寫入前就存在。重啟後重新觀察遠端，不靠斷點續傳。
- 發出去的請求可能成功但對應沒存到：attempt 和 projection 都變 `needs_attention`。
- sealed 發生時取消進行中的寫入 context，之後不再開始新的遠端寫入。已 commit 的本地期望狀態留著等下次對齊。

## Retry

**Retry 是排工作，不是在 HTTP 請求裡直接寫 NetBird。**
Retry 會重新驗證 ObjectMap 和可疑的遠端候選物件。
不確定性已排除：work_version 加一、狀態變 `pending`。
還在：維持 `needs_attention`，等管理員處理。

## Explain

**輸入來源 Peer、目的 Peer、protocol 和埠號，回答能不能連和為什麼。**

- decision：`granted`、`not_granted`、`indeterminate`。
- basis：`desired`（照藍圖）或 `applied`（照實際套用的狀態）。
- 回傳比對到的每一條允許規則和相關的 Layer、revision。
- `not_granted` 只代表 Valkona 沒有這條授權。Valkona 管不到的 NetBird Policy 不在保證範圍內。

權限：跨 Layer 的 Explain 只有 admin 能用。單一 AccessEdge 的 Explain 開放給 Personal Layer 擁有者。

## 對 NetBird 的邊界型別

**Runtime 定義 Group 和 Policy 的 spec 與 canonical 型別，adapter 負責實作。**

- GroupSpec 和 PolicySpec：Valkona 想要的樣子。
- CanonicalGroup 和 CanonicalPolicy：讀回來後正規化的樣子，含 spec_hash 供比對。
- create 操作要帶 correlation ID。delete 遇到 not_found 只有在 ObjectMap 證明目標身分時才算冪等成功。

## 錯誤

```text
invalid_argument
forbidden
resource_not_found
reconciliation_blocked
runtime_sealed
remote_mapping_missing
remote_conflict
remote_readback_mismatch
remote_create_outcome_uncertain
needs_attention
backend_unavailable
```

## 驗收重點

- ProjectionState 是持久待辦來源，queue 掉了無害。
- 每個弄髒事件都原子性地讓 work_version 加一。
- 舊的 attempt 不能清掉新的 pending。
- 每個遠端寫入前一刻都要過 gate。
- 標 applied 或 inactive 前一定要讀回驗證。
- 只有 ObjectMap 授權遠端修改。
