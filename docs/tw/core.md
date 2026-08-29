# Core 模組

**Core 管「人」和「機器是誰的」：使用者、Peer、歸屬、Enrollment、從 NetBird 同步回來的裝置清單。**
它不管藍圖，也不管 Policy 投影。

## 使用者

- 身分唯一性看 OIDC 的 `(issuer, subject)` 組合。
- role 分 `member` 和 `admin`，status 分 `active` 和 `disabled`。
- bootstrap admin 是設定檔裡寫死的精確身分組合。第一個登入的人不會自動變 admin。
- 最後一個 active 的 admin 受保護，不能被降級或停用。
- disabled 的使用者不能開新 session 或做任何修改，但他的 Layer 不會自動退場。

## Peer 與歸屬

**每台 Peer 有一個歸屬狀態（attribution），決定它能不能被放進藍圖。**

- `resolved`：有明確主人，可以當 Node 用。
- `unresolved`：沒有主人。
- `ambiguous`：證據衝突，要 admin 裁決。

**歸屬的判定順序：**已有的持久 owner、完成的 Enrollment、明確的一對一 identity binding，都沒有就是 unresolved。
email 或名字長得像不算證據。
證據互相矛盾就標 ambiguous，不做自動轉移。

**ambiguous 的細節：**本來 resolved 的 Peer 變 ambiguous 時，原本的 owner 欄位留著當歷史，但不能再被當 resolved 使用。
從來沒有 owner 的 ambiguous Peer，owner 欄位是 null。

**presence（在線狀態）獨立於歸屬。**
`online`、`offline`、`unknown` 只看 NetBird 的連線回報新不新鮮。
裝置離線不影響它是誰的。

## 裝置清單同步（inventory sync）

**設計目標是當機安全：不管在哪一步掛掉，都不會留下錯誤狀態。**

流程分四步：

- StartObservation：先開一筆觀察紀錄。
- FetchInventory：在資料庫 transaction 外面，抓完整的身分和 Peer 清單。抓到一半失敗就整筆算失敗。
- ApplyInventory：在組合層給的共用 transaction 裡套用變更、完成觀察。同一個 transaction 內，組合層把受影響的 Layer 全部標 pending。
- 失敗路徑：記一筆失敗的觀察，絕不把 Peer 標成 missing。

**兩條鐵律：**

- 只有完整的觀察才能證明某台 Peer 消失了。抓一半的清單不算數。
- 純粹的上線下線變化不算 topology 相關變更，不會弄髒 Layer。

process 掛掉留下的 running 觀察，重啟時標成 failed。

## Enrollment（認領裝置）

**一次 Enrollment 等於：開一個專屬 staging Group，發一把只能用一次的 Setup Key。**
Setup Key 的 auto-group 只包含那個 staging Group。

規則：

- 明文只在建立成功的第一個回應出現一次。Valkona 不存明文也不存密文，之後不能重看。
- 同一組 idempotency key 加相同內容重送，回傳既有的 Enrollment，不會重複建立，也不會重放明文。
- Enrollment 迴圈發現 staging Group 裡出現 Peer，就把 ownership 寫進資料庫（owner_source = `valkona_enrollment`）。
- ownership 先 commit，才做遠端清理（撤銷 Setup Key、刪 staging Group）。
- 每一個遠端寫入前一刻都要過 `backend_write` 的 gate。

**當機邊界：**每拿到一個遠端 ID 就立刻存。
如果 create 的結果不確定而且 ID 還沒存到，Enrollment 變 `needs_attention`，不自動重試、不憑 metadata 認領或刪除。

內部狀態是一組封閉集合（11 種），對外簡化成 `creating`、`issued`、`peer_detected`、`completed`、`expired`、`revoked`、`failed`、`needs_attention`。

## 會影響藍圖的身分操作

**改 Peer 的 owner 或 identity binding，必須跟受影響 Layer 的失效標記在同一個 transaction 裡 commit。**
這類操作走專門的 command port，回傳所有歸屬事實有變的 Peer 清單。
組合層拿這份清單找出引用中的 Layer，逐一 MarkPending，然後一起 commit。
這樣當機不可能出現「owner 改了但藍圖沒重算」的狀態。

三個操作：AssignPeerOwner、CreateIdentityBinding、DeleteIdentityBinding，都是 admin 專用。

## 對 NetBird 的介面

- 清單類：ListIdentities、ListPeers，結果一律「完整或錯誤」。
- Enrollment 類：建立和刪除 staging Group、建立和撤銷 Setup Key、列 staging Group 內的 Peer。
- create 都要帶 correlation ID。`outcome_uncertain` 代表遠端可能已經建立成功，自動重試不安全。

## 錯誤

```text
invalid_argument
forbidden
resource_not_found
conflict
idempotency_payload_mismatch
enrollment_secret_not_replayable
remote_create_outcome_uncertain
backend_unavailable
```

## 驗收重點

- 失敗或不完整的清單絕不把 Peer 標 missing。
- Setup Key 明文不出現在資料庫、log、audit 或任何 GET 回應。
- 歸屬只認明確證據，衝突變 ambiguous，不自動轉移。
- ownership 先 commit 才清理遠端。
- `outcome_uncertain` 產生 needs_attention，不自動重試。
