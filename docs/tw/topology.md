# Topology 模組

**Topology 管「使用者想要的連線關係」，也就是藍圖本身。**
它不碰 NetBird、不做對齊、不定義 HTTP 路由。
寫進去的只是意圖，實際生效由 Runtime 負責。

## 資料模型

**一張 Layer 裡面有六種東西。**

- Layer：藍圖本身。分 `personal`（有 owner）和 `system`（admin 管理，沒有 owner）。有 `enabled` 開關和只增不減的 `generation`。
- Node：對某台 Peer 的引用。同一 Layer 內一台 Peer 只能出現一次。
- Group：Node 的靜態集合。
- Service：協定加埠號，例如 22/tcp。protocol 限 `tcp`、`udp`、`icmp`。
- Exposure：把某個 Service 掛在某個 Node 或 Group 上，代表「這個東西開放被連」。
- AccessEdge：允許規則。來源是 Node、Group 或 `selector: all`，目的是某個 Exposure，有 `enabled` 開關。

## 硬規則

**這些規則由 domain 驗證加資料庫 constraint 雙重保證。**

- 所有引用都限同一張 Layer 之內，沒有跨 Layer 引用。
- Personal Layer 的 Node 只能引用「已 resolved 且 owner 是 Layer 擁有者」的 Peer。
- System Layer 的 Node 可以引用任何 resolved 的 Peer。
- TCP/UDP 的 Service 埠號必須是 1 到 65535 的正規化埠或範圍，不能是空的。ICMP 不帶埠號。
- `selector: all` 只能當來源，語意是「這個 NetBird 帳號現在和未來的所有 Peer」。它不展開成員清單。
- Node 是持久的意圖。Peer 之後離線或狀態變化，Node 不會自己消失。

## 權限

**Personal Layer 由擁有者或 admin 管理，System Layer 只有 admin 能管。**
Layer 內的資源繼承 Layer 的權限。
權限判斷透過 `LayerAuthority` 回傳的 boolean，呼叫方不自己查表。

## 修改行為

- 每次成功的修改都讓 Layer 的 `generation` 加一，並回傳 MutationResult 給組合層。
- 所有修改都在組合層給的 transaction 裡執行。安全檢查（operation gate）在組合層做，Topology 只管資源權限和資料規則。
- 刪除被引用中的資源會回 `resource_in_use`，不會連鎖刪除。
- 只有 Layer 和 AccessEdge 有 enable 開關。關 Layer 代表申請退場（retire），關 AccessEdge 代表暫停那一條允許規則。

## Layer 刪除

**硬刪除只能走組合層的專用流程。**
流程：鎖住 Layer 和 ProjectionState、Runtime 確認刪除資格（狀態是 inactive 且沒有殘留的遠端物件對應）、才執行刪除。
資格判斷不能在 transaction 外面先算好再拿來用。

## 給 Runtime 的介面

- `LayerSnapshot`：整張 Layer 的不可變快照，當編譯輸入。
- `FindLayersReferencingPeers`：給一批 Peer ID，回傳有引用到的 Layer 清單。Peer 歸屬變動時用來標記受影響的 Layer。
- Peer 的資訊透過 Core 的 `PeerReader` 拿，Topology 不自己實作歸屬判斷。

## 錯誤

```text
invalid_argument
forbidden
resource_not_found
resource_in_use
peer_not_resolved
cross_layer_reference
invalid_service_ports
```

## 驗收重點

- 每次修改都回傳新的 generation。
- 同 Layer 引用由驗證和複合 FK 同時保證。
- 埠號正規化結果是決定性的。
- `selector: all` 保持語意化，不展開成員。
- 刪除資格只在組合層的 transaction 內判斷。
