# 營運與實作

**這份合併四件事：設定檔、啟動流程、NetBird 實證、實作順序，最後是使用者旅程。**

## 設定檔

**設定在 HTTP listener 啟動前載入完成，範例在 [`../en/contracts/configuration.example.yaml`](../en/contracts/configuration.example.yaml)。**

必要的設定群組：

- 資料庫連線、migration 政策、advisory lock 的 key。
- OIDC 的 issuer、client、audience，和精確的 bootstrap admin 身分。
- NetBird API URL 和 token 來源。
- 預期的 NetBird 帳號身分（`expected_account_identity`）。
- Peer 在線判定的新鮮度和同步間隔。
- Enrollment 的過期時間和輪詢間隔。
- 對齊和資料保存的上下限。

密鑰用環境變數或 secret 檔引用，不寫進版本控制的設定檔。

## 啟動流程

```text
載入設定和資料庫
→ 搶 PostgreSQL advisory lock（搶不到就退出）
→ NetBird adapter 做安全檢查
→ 比對帳號身分
→ 確認預設 all-to-all 規則已關
→ 通過：開 HTTP、跑 worker
→ 失敗：結構化 log、非零退出
```

啟動失敗的診斷走 CLI 和 log，因為 HTTP 根本沒開。
另外有一個 `RunStartupDoctor` 的本地 CLI 操作可以單獨跑診斷。

## NetBird 實證：先拿證據再寫程式

這是第一個里程碑（`en/` 凍結文件稱它 Phase 0）。
**動手實作前，要先用真實 NetBird 錄下 fixture，證明這九件事：**

1. 帳號身分有穩定的證據欄位，以及不符時的行為。
2. 預設 all-to-all 規則怎麼辨識。
3. 內建 All Group 怎麼拿到，不靠猜名字。
4. Policy 和 Rule 讀回來的格式和排序。
5. Group 和 Policy 的建立、更新、刪除，以及巢狀 Rule 的身分行為。
6. Setup Key 的 one-off、usage limit、auto-group、過期行為。
7. Peer 和 User 清單的分頁和不完整時的失敗樣態。
8. API 的錯誤碼、status 和 rate limit 行為。
9. create timeout 之後結果不確定的案例。

adapter contract 不准發明 NetBird 沒有的保證。
證據拿不到就 fail closed。
如果實證結果顯示 API 沒有可靠的帳號身分欄位，必須先設計並驗證替代的證據機制，開機安全檢查才能成立。

## 實作順序

NetBird 實證之後，四個里程碑照序做：

- 骨架：模組邊界、migration runner、模組 schema 加 integration FK、advisory lock、設定和 startup doctor、Audit sink、stateful fake adapter。
- Core：OIDC 和 admin bootstrap、觀察生命週期、庫存套用和 Layer 失效的共用 transaction、presence、歸屬、binding、Enrollment 狀態機和冪等。
- Topology：command 和 read port、operation gate 接上應用層邊界、HTTP CRUD、transaction 內的刪除資格、引用和權限驗證。
- Runtime：編譯器和 revision、work_version 掃描、CAS 完成、ObjectMap 和對齊、safety monitor 和 sealed 取消、Explain 和診斷。

**實作鐵律：**先照 contract 介面寫消費方，用 fake 測過，再接 production adapter。
不做通用後端抽象層，不重複定義 HTTP 和 domain 型別，不在 domain 簽名裡傳安全 token。

## 使用者旅程

### 先分清楚兩件事

| 目的 | 在哪做 | 證明什麼 |
| --- | --- | --- |
| 使用 Valkona 管藍圖 | Valkona，OIDC 登入 | 你是哪個 member 或 admin |
| 裝置加入 VPN | NetBird client（SSO 或 Setup Key） | 這台機器成為某個 Peer |

**登入 Valkona 不會自動讓任何裝置變成你的。**
裝置要 `attribution = resolved` 才能放進藍圖。

### member 主旅程：認領裝置

```text
1. OIDC 登入 Valkona
2. 建立 Enrollment
3. 拿到一次性 Setup Key 明文（只出現一次）
4. 在目標裝置跑 NetBird 原生指令：netbird up --setup-key <plaintext>
5. Valkona 偵測到裝置出現，寫入歸屬（resolved，owner 是你）
6. Valkona 自動清理 Setup Key 和 staging Group
7. 在「我的裝置」看到它
8. 建 Personal Layer，放 Node、Service、允許規則
9. 看 projection 和 Explain 結果
```

member 看不到別人的裝置，也不能把不明裝置指定給自己。

### admin 旅程：處理例外

- **identity binding**：裝置走 NetBird 原生 SSO 進來、帶有 netbird_user_id 時，admin 把 NetBird user 綁到 Valkona 使用者。
- **手動指定 owner**：舊機器或 binding 蓋不到的情況，直接 AssignPeerOwner。
- **System Layer 和診斷**：管理共用藍圖，處理 ambiguous 和 needs_attention。

### SSO 和 Setup Key 的差別

| 裝置怎麼進 NetBird | member 能自助完成歸屬嗎 | 能進 Personal Layer 嗎 |
| --- | --- | --- |
| Valkona Enrollment（Setup Key） | 能，這是主路徑 | 能 |
| NetBird 原生 SSO | 不能，要 admin 介入 | admin 完成歸屬後才能 |

不要求關閉 NetBird 原生 SSO。
但組織要接受：SSO 進來的裝置需要 admin 補歸屬。
想讓 member 完全自助，就把 Enrollment 當標準路徑。

### 藍圖管到哪些裝置

**只要 Peer 已 resolved，不管歸屬來源是什麼，都能當 Node。**
不是只有 Setup Key 進來的機器才受管。
Personal Layer 的 Node 額外要求 owner 是 Layer 擁有者本人，System Layer 沒有這個限制。
