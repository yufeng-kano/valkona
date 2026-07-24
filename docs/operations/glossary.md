# 詞彙對照（抽象名稱 → 人話）

本表把契約／內部用語對到對外說明與 UI 可用的白話。  
**契約識別名與 API 欄位暫不因此改名**；對外文件、網頁文案、導引優先用人話或沿用 NetBird 既有詞。

規範語意仍以各模組 `contract.md` 為準。使用者流程見 [`user-journeys.md`](user-journeys.md)。

## 命名原則

1. **能沿用 NetBird 的就沿用**（Device、Setup Key、Group、Policy）。
2. **能用白話就用白話**（我的裝置、允許連線、認領裝置）。
3. **只有 Valkona 多出來的關係才需要名字**，優先用「舊詞組合」描述，避免再造平行宇宙專有名詞。
4. 產品名「Valkona」放在產品層即可；不要每個概念都加 `Valkona …` 前綴。

## 對照表

| 契約／內部用語 | 對外／人話（建議） | 實際在講什麼 | 備註 |
| --- | --- | --- | --- |
| Peer | NetBird 裝置（NetBird device） | NetBird 上真實存在的那台機器 | 對外優先沿用 NetBird；避免只說 Peer |
| Node | 藍圖中的裝置／裝置引用（device reference） | 某一張存取藍圖裡「放了哪台裝置」 | **不是**裝置本體；同一 Peer 可被多張藍圖引用。勿與 Peer 都叫「裝置」而不加限定 |
| Layer | 連線藍圖／存取藍圖（access map） | 一組「誰能連誰」的工作區 | 勿用過長全名；也勿暗示還要手動 Plan／Apply |
| Personal Layer | 我的連線藍圖 | 成員自己的藍圖 | |
| System Layer | 系統連線藍圖 | 管理員維護的共用藍圖 | |
| Group（Topology） | 藍圖內群組 | Layer 內靜態節點集合 | 與 NetBird Group 不同層；對使用者說明時要標「藍圖內」 |
| Service | 服務／開放的服務埠 | 某裝置上要被連的目標（如 22/tcp） | 詞已夠日常 |
| Exposure | 服務曝光 | 把某個 Service 掛在藍圖裡供規則使用 | 若 UI 可合併進「服務」步驟則不必單獨強調 |
| Access edge | 允許連線／允許規則（allow rule） | A 可以連 B 這個服務 | 少用「edge」 |
| Enrollment | 認領裝置（claim device） | 發一次性 Setup Key 並把新裝置歸給自己 | 對外當動詞流程，不必當炫專有名詞 |
| Setup Key | Setup Key（NetBird 入場券） | NetBird 原生一次性／限次加入金鑰 | **沿用 NetBird 名稱**；client 指令不變 |
| Attribution | 歸屬狀態 | 這台裝置有沒有明確主人 | |
| resolved | 已歸屬 | 可當作藍圖中的裝置使用 | |
| unresolved | 未歸屬 | 還不能當 Personal Layer 的裝置 | |
| ambiguous | 歸屬衝突 | 證據衝突；需管理員處理 | |
| owner_source | 歸屬來源 | 為何判定是誰的 | enrollment／binding／admin 指定 |
| Identity binding | 綁定 NetBird 使用者 | 把 NetBird user 對到 Valkona 使用者 | **管理員**操作 |
| AssignPeerOwner | 指定裝置擁有者 | 管理員手動指定 Peer 的 owner | **管理員**操作 |
| Projection | 套用到 NetBird | 把藍圖編譯後寫入／對齊 NetBird | 對一般使用者可說「套用狀態」 |
| Reconciliation | 對齊／同步 | 持續讓 NetBird 狀態符合藍圖 | 運維向；UI 可用「同步中／已同步」 |
| Explain | 為什麼能／不能連 | 解釋目前存取結果的原因 | |
| Inventory | 裝置清單（同步自 NetBird） | 從 NetBird 觀察到的 Peer／身分快照 | |
| ObjectMap | 遠端物件對照 | Valkona 與 NetBird 物件的權威對應 | 偏內部／診斷 |
| Sealed | 已封寫入 | 安全條件失敗，停止寫入直到修復重啟 | 對運維說明即可 |

## 容易混的兩組

### Peer vs Node

- **Peer／NetBird 裝置**：真實機器。  
- **Node／藍圖中的裝置**：藍圖裡的引用。  
對外若都簡稱「裝置」，必須帶上下文（「我的 NetBird 裝置」vs「這張藍圖裡的裝置」）。

### Topology Group vs NetBird Group

- **Topology Group**：Valkona 藍圖內的靜態成員集合。  
- **NetBird Group**：NetBird 後端物件；projection／Enrollment staging 會碰到。  
對使用者預設講藍圖語意；診斷／對齊畫面才暴露 NetBird Group。

## 使用方式

- 寫 [`user-journeys.md`](user-journeys.md)、UI 文案、README 導引：優先用「人話」欄。  
- 寫契約、acceptance、程式識別名：維持現有契約用語，必要時括號補人話一次。  
- 若要新增對外概念名：先確認表中是否已有對應；沒有則先更新本表，再寫入其他文件。
