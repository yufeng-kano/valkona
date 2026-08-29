# 架構疑慮與建議

**這份是意見，不是規格。**
由 AI 在重整文件時寫下，讀完全部規格後的判斷。
每點都標了嚴重度：高（建議動手前處理）、中（實作時注意）、低（記著就好）。

## 總評

**架構本身是健康的，問題出在文件儀式和 MVP 範圍。**
modular monolith、fail-closed 安全、ObjectMap 權威、work_version 加 CAS，這四個核心設計都站得住。
但這是一個零程式碼的個人專案，文件的精細度是大團隊等級，維護成本會吃掉開發動能。

## 高：文件儀式遠超過專案規模

**問題：**52 個檔案、100 多個 `Xxx.Yyy.v1` 契約編號、每個模組拆五個檔，全部在程式碼存在之前寫完。
契約編號在單一 repo 單人開發下沒有版本協商的對象，`v1` 後綴是純儀式。
**建議：**程式碼開始後，型別和介面以程式碼為準（`dev/`），不要回頭維護契約編號表。
en 那份 `CONTRACTS.md` 的大表格和 `MANIFEST.json`、`MANIFEST.md` 的 hash 清單直接放掉，不要再更新。

## 高：Phase 0 是唯一正確的起點，先做它

**問題：**整套安全設計壓在「NetBird API 有穩定的帳號身分欄位」和「全通規則可以被程式辨識」兩個未驗證的假設上。
文件自己也承認：假設不成立，開機安全檢查就不成立。
**建議：**在寫任何模組程式碼之前，先花時間跑完 Phase 0 的九項證據。
證據不成立的話，影響的是架構核心，越晚知道改越大。

## 中：Enrollment 狀態機對 MVP 偏重

**問題：**11 個內部狀態、staging Group、一次性 Setup Key、冪等、當機邊界，這是整份規格裡最複雜的單一流程。
**判斷：**設計本身是對的，密鑰不落地和 fail-closed 都有道理，砍掉會留安全洞。
**建議：**不簡化設計，但把它列為測試優先級最高的區域。狀態機轉移和當機窗口要有完整的 pytest 覆蓋。

## 中：projection 的 NetBird 物件數量線性成長

**問題：**一個 Node 一個單成員 Group，一張 Layer 一個 Policy，一條 AccessEdge 一條 Rule。
裝置和規則多起來，NetBird 上的物件數量和 API 呼叫量會線性成長，rate limit 和對齊時間都會有感。
**建議：**MVP 不用改設計，但 reconciliation 要一開始就做好 rate limit 的退讓處理，Phase 0 的第 8 項證據要認真錄。

## 中：sealed 只能重啟恢復，運維體驗差

**問題：**安全條件恢復後（例如誤開的全通規則被關回去），process 仍要人工重啟才回 active。
文件明確拒絕 HTTP unseal，理由是安全。
**判斷：**MVP 接受。單人自架的場景，重啟成本低。
**建議：**之後若要改善，加「重跑開機檢查」的本地 CLI 指令就好，不要開 HTTP unseal。

## 低：Explain 的雙 basis 可以延後

**問題：**`desired` 和 `applied` 兩種 basis 的 Explain 是進階診斷功能，實作成本不低。
**建議：**MVP 先做 `applied` 一種，`desired` 留到有真實需求再補。這是範圍調整，不是設計缺陷。

## 低：Audit 沒有查詢介面

**問題：**MVP 的稽核紀錄只能直接下 SQL 查。
**判斷：**文件是有意識的取捨，可接受。
**建議：**維持現狀，等真的需要再補查詢 contract。

## 低：技術棧尚未指定

**問題：**整份規格語言中立，沒有指定後端語言和框架。
**建議：**依開發規則，後端用 Python 加 FastAPI、SQLAlchemy、Alembic，套件管理用 `uv`。
決定後寫進 [`../dev/index.md`](../dev/index.md)，第一個 scaffold 用官方指令建立。

## 建議的下一步順序

1. 跑 Phase 0，錄 fixture，把結果寫進 `dev/`。
2. 用 `uv init` 建 backend 骨架，照 Phase 1 清單做。
3. 從 fake adapter 加 Core 的測試開始，Enrollment 狀態機優先。
