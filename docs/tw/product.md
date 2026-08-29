# 產品

**Valkona 是架在 NetBird 上面的一層，讓你用「連線藍圖」描述誰能連誰，不用直接手搓 NetBird 的 Group 和 Policy。**
一套安裝只管一個 NetBird 帳號，透過官方公開 HTTP API 操作。
名字來自 falconer（馴鷹人）：引導 NetBird，不取代它。

## 兩種角色

- `member`：管理自己的裝置、自己的 Enrollment、自己的 Personal Layer。
- `admin`：管理全部裝置清單、identity binding、歸屬裁決、System Layer、系統診斷。

## MVP 要做到什麼

**member 走完這條路就算成功：**

- 用 OIDC 登入。
- 認領一台裝置，拿到 resolved 的 Peer。
- 建一個 Personal Layer，在裡面描述一個 Service。
- 從某個 Node、Group 或 `selector: all` 開放存取。
- 查看 projection 結果和 Explain。

**admin 走完這條路就算成功：**

- 看到完整的 Peer 清單。
- 手動裁決裝置歸屬。
- 管理 System Layer。
- 診斷 safety、drift、mapping 和 reconciliation 失敗。

## 安全前提

**兩個條件不滿足，Valkona 直接不服務。**

1. 連上的 NetBird 帳號要跟設定檔指定的帳號一致。
2. NetBird 預設的 all-to-all 全通規則必須是關閉或不存在。

執行中發現條件被打破，process 進入 sealed 狀態，停止所有寫入。
恢復需要管理員修好問題再重啟。

## 明確不做的事

**這個清單跟功能清單一樣重要，防止範圍暴走。**

- DNS。
- 多個 NetBird 帳號或其他後端。
- 多租戶、workspace、組織。
- 自訂 RBAC 或多人共編 Layer。
- Layer 階層、繼承、跨 Layer 引用。
- 動態 Group，或 `all` 以外的 selector。
- 明確 deny 規則或規則優先序。
- 手動 Plan/Apply 流程。
- 微服務、分散式 worker、通用事件平台。
- 完整封存 NetBird 狀態或裝置上線分析。
