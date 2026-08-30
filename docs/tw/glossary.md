# 黑話對照表

**看文件卡住的詞，先來這裡查。**
分兩區：第一區是文件寫作用的工程術語，第二區是產品概念的人話對照。

## 文件術語

**這些詞在原文件到處出現，每個用一兩句話講清楚。**

- **contract（契約）**：一個模組對外承諾的介面。包含有哪些操作、吃什麼參數、回什麼結果、會丟什麼錯誤。別的模組只能依賴 contract，不能偷看內部實作。
- **module（模組）**：程式碼裡的邊界，例如 Core、Topology、Runtime。全部跑在同一個 process、同一個資料庫，不是微服務。
- **modular monolith**：上面那句的正式名稱。一個程式，內部切乾淨。
- **adapter**：翻譯層。inbound adapter 把外面的請求翻成內部操作（例如 HTTP），outbound adapter 把內部操作翻成外部服務的 API（例如 NetBird）。
- **port**：模組宣告的「我需要外面幫我做這件事」的介面。adapter 負責實作 port。
- **composition（組合層）**：跨模組流程的總指揮。一個動作要同時改兩個模組的資料時，由它包成一個 transaction。
- **transaction（交易）**：資料庫的「全有或全無」。裡面的修改要嘛一起成功，要嘛一起消失。
- **idempotency（冪等）**：同一個請求重送不會做出第二份。靠 client 帶 idempotency key 實現。
- **snapshot**：某一刻資料的完整複本，拿去計算時不怕中途被改。
- **compare-and-swap（CAS）**：更新前先比對「還是不是我當初看到的版本」，不是就放棄更新。用來防舊的工作蓋掉新的。
- **advisory lock**：PostgreSQL 提供的全域鎖。Valkona 用它保證同時只有一個 process 在跑。
- **fail-closed**：出事就停下來，不猜、不硬跑。Valkona 的安全設計都是這個方向。
- **drift（飄移）**：NetBird 上的實際狀態跟 Valkona 認知的不一樣了，例如有人手動去 NetBird 改東西。
- **migration**：資料庫 schema 的版本化修改腳本。
- **fixture**：預先錄好的真實 API 回應，拿來當測試的比對基準。
- **NetBird 實證**：動工前的第一個里程碑：對真實 NetBird 錄 fixture，驗證安全設計依賴的九項假設。`en/` 凍結文件稱它 Phase 0。後續里程碑依序是骨架、Core、Topology、Runtime。
- **acceptance（驗收條件）**：一份 checklist，列出實作必須通過的行為檢查。
- **needs_attention**：系統判斷「這個狀況我不敢自動處理」，停下來等管理員裁決的狀態。
- **outcome_uncertain**：對外部服務發了寫入請求，但不確定到底成功沒有（例如 timeout）。這種情況禁止自動重試，因為可能做出重複的東西。

## 產品詞彙對照

**原則：能沿用 NetBird 的詞就沿用，能講人話就講人話。**
只有 Valkona 自己多出來的概念才需要新名字。

| 文件用語 | 人話 | 實際在講什麼 |
| --- | --- | --- |
| Peer | NetBird 裝置 | NetBird 上真實存在的那台機器 |
| Node | 藍圖中的裝置 | 某張藍圖裡「放了哪台裝置」的引用，不是裝置本體 |
| Layer | 連線藍圖 | 一組「誰能連誰」的工作區 |
| Personal Layer | 我的連線藍圖 | 成員自己的藍圖 |
| System Layer | 系統連線藍圖 | 管理員維護的共用藍圖 |
| Group（Topology） | 藍圖內群組 | Layer 內的靜態 Node 集合，跟 NetBird Group 不同層 |
| Service | 服務 | 某裝置上要被連的目標，例如 22/tcp |
| Exposure | 服務曝光 | 把某個 Service 掛進藍圖，供規則使用 |
| AccessEdge | 允許連線規則 | 「A 可以連 B 的這個服務」 |
| Enrollment | 認領裝置 | 發一次性 Setup Key，把新裝置歸給自己 |
| Setup Key | Setup Key | NetBird 原生的一次性加入金鑰，沿用原名 |
| attribution | 歸屬狀態 | 這台裝置有沒有明確主人 |
| resolved | 已歸屬 | 有主人，可以放進藍圖 |
| unresolved | 未歸屬 | 還沒有主人 |
| ambiguous | 歸屬衝突 | 證據互相矛盾，要管理員處理 |
| owner_source | 歸屬來源 | 為什麼判定是這個人的：enrollment、binding 或管理員指定 |
| identity binding | 綁定 NetBird 使用者 | 把 NetBird user 對到 Valkona 使用者，管理員操作 |
| inventory | 裝置清單 | 從 NetBird 同步回來的 Peer 和身分快照 |
| projection | 套用到 NetBird | 把藍圖編譯後寫進 NetBird |
| reconciliation | 對齊 | 持續讓 NetBird 的狀態符合藍圖 |
| Explain | 為什麼能連 | 解釋某兩台裝置之間目前為什麼通或不通 |
| ObjectMap | 遠端物件對照表 | Valkona 物件對 NetBird 物件的權威對應 |
| sealed | 已封鎖寫入 | 安全檢查失敗，停止所有寫入直到修復並重啟 |
| work_version | 工作版本號 | 每個 Layer 的待辦計數器，只會變大 |

## 最容易搞混的兩組

**Peer 和 Node 不是同一個東西。**
Peer 是真實機器，Node 是藍圖裡對機器的引用。
同一台 Peer 可以被很多張藍圖引用成不同的 Node。

**Topology Group 和 NetBird Group 不是同一個東西。**
Topology Group 是 Valkona 藍圖內的 Node 集合。
NetBird Group 是 NetBird 後端的物件，只在 projection 和 Enrollment 過程中出現。
