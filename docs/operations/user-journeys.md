# 使用者旅程

本文件說明一般使用者與管理員如何使用 Valkona，以及裝置歸屬如何成立。  
規範細節以 [`../PRODUCT.md`](../PRODUCT.md)、[`../modules/core/contract.md`](../modules/core/contract.md)、[`../modules/topology/contract.md`](../modules/topology/contract.md) 為準；本文件不重新定義契約。

用語對照見 [`glossary.md`](glossary.md)。內部流水線見 [`../integration/flows.md`](../integration/flows.md) 的 Enrollment 一節。

## 兩件分開的事

| 目的 | 在哪裡做 | 證明什麼 |
| --- | --- | --- |
| 使用 Valkona（管 Layer、Enrollment、Explain） | Valkona（HTTP API／未來網頁），OIDC 登入 | 這個人是哪個 `member`／`admin` |
| 裝置加入 NetBird VPN | NetBird client（SSO 或 Setup Key） | 這台機器成為某個 NetBird Peer |

OIDC 登入 Valkona **不會**自動讓任何 Peer 變成「我的」。  
Topology Node 需要 Peer `attribution = resolved`（見 Core／Topology 契約）。

## 角色

- **member**：管理自己擁有的 Peers、自己的 Enrollments、自己的 Personal Layers。
- **admin**：管理完整 Peer 庫存、identity bindings、明確指定 owner、System Layers、安全與對齊診斷。

## 一般使用者（member）主旅程

Member **自助**把 Peer 變成自己的、且可放進 Personal Layer 的路徑，是 **Enrollment（一次性 Setup Key）**。

```text
1. 以 OIDC 登入 Valkona
2. 建立 Enrollment（授權 enrollment_issue）
3. 取得一次性 Setup Key 明文（只在建立成功時可能出現一次；之後不可重放）
4. 在目標裝置執行 NetBird 原生流程，例如：
   netbird up --setup-key <plaintext>
5. Enrollment 迴圈偵測到 staging Peer → 持久化 ownership
   （owner_source = valkona_enrollment，attribution = resolved）
6. 清理：撤銷 Setup Key／刪除 staging Group
7. 在「我的裝置」看到已 resolved 的 Peer
8. 建立 Personal Layer：Nodes／Services／access edges
9. 檢視 projection／Explain（個人 Layer 範圍內）
```

重點：

- NetBird client **沒有** Valkona Enrollment 功能；它只用原生 Setup Key。
- Valkona 負責：代為建立專屬 staging Group + one-off Setup Key，並把因此出現的 Peer 歸給發 Enrollment 的使用者。
- Member 看得到的是自己擁有的 Peers／Enrollments，不是完整庫存。

### Member 不透過 admin 就做不到的事

- 把「別人／未知」的 Peer 指定給自己
- 建立或刪除 `netbird_identity_binding`
- 管理 System Layers
- 跨 Layer 的 Explain（契約限制為 admin）

## 管理員（admin）旅程

Admin 用來處理 **非 Enrollment** 進來的裝置，或營運例外。

### Identity binding

將 NetBird 使用者與 Valkona 使用者做成明確一對一綁定。  
常見於裝置以 **NetBird 原生 SSO** 加入、已帶有 `netbird_user_id` 的情況。

這是 **admin** 操作，不是 member 自助步驟。

### 手動指定 owner

對既有 Peer 執行 `AssignPeerOwner`。  
用於舊機器、例外歸屬、或 binding 無法涵蓋的情況。

### System Layer 與診斷

- 管理 System Layers
- 檢視完整 Peer 庫存、safety／drift／mapping／reconciliation 失敗
- 在證據衝突時處理 `ambiguous`／`needs_attention`

## NetBird SSO 與 Setup Key（避免誤解）

| 裝置如何加入 NetBird | 一般使用者能否自己完成 Valkona 歸屬 | 之後能否出現在 Personal Layer |
| --- | --- | --- |
| Valkona Enrollment → Setup Key | 能（member 主路徑） | 能（resolved 且 owner 是自己） |
| NetBird 原生 SSO（未先經 Valkona） | 不能；需 admin binding 或指定 owner | 僅在 admin 完成歸屬且 attribution = resolved 之後 |

文件 **不要求** 關閉 NetBird 原生 SSO。  
若組織讓員工筆電走 SSO，必須接受：這些 Peer 在進入 member 的 Personal Layer 前，需要 **admin 介入** 完成歸屬。

若組織希望 member **完全自助**（含筆電），應以 Enrollment／Setup Key 作為認領裝置的標準路徑。

## 「誰能連誰」管哪些裝置

Valkona 的 Layer 規則作用於 Layer 內、且 Peer 已 `resolved` 的 Nodes。  
**不是**只限 Setup Key 進來的機器。

只要 Peer 已 resolved（不論 `owner_source` 是 enrollment、identity binding 或 admin assignment），都可以依 Topology 契約成為 Node，並受該 Layer 的 access edges 約束。

Personal Layer 的 Node 還必須是 **該 Layer 擁有者所擁有** 的 resolved Peer；System Layer 可由 admin 引用任何 resolved Peer。

## 與產品 MVP 的對齊

[`PRODUCT.md`](../PRODUCT.md) 中 member 的「obtain a resolved Peer」在本文件定義為：

- **預設自助語意**：完成 Enrollment，取得 `owner_source = valkona_enrollment` 的 resolved Peer；
- **組織若採 SSO 筆電**：resolved Peer 由 admin 的 identity binding 或 assignment 取得後，member 才能在 Personal Layer 使用。

實作網頁或 API 導引時，member 主流程應導向 Enrollment；不要暗示「OIDC 登入後 SSO 裝置會自動變成我的」。
