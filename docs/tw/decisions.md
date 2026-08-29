# 架構決策摘要

**五個 ADR 各壓成一段：當時的問題、選了什麼、代價是什麼。**
完整原文在 [`../en/adr/`](../en/adr/index.md)。
這些決策解釋理由，不重新定義行為。

## 0001 模組化單體，文件跟著模組走

**問題：**中央式大文件每個模組都描述一遍，一改就漂移。
**決定：**一個 process 切成模組，每個模組自己擁有 contract、design、schema、acceptance，別人只依賴公開 contract。
**代價：**檔案變多，但重複的事實變少。內部重構只要 contract 不動就不影響別人。

## 0002 每張 Layer 獨立對齊

**問題：**既然不做跨 Layer 引用和跨 Layer 原子性，全域版本快照就是假的。
**決定：**一次編譯、對齊一張 Layer。保留不可變的 LayerRevision 和每張一列的 ProjectionState。
**代價：**沒有全域一致的快照。換到的是一張壞掉不擋其他張，退場流程明確。

## 0003 fail-closed 安全與 ObjectMap 權威

**問題：**NetBird 預設全通規則還開著、或連錯帳號時，Valkona 寫什麼都沒意義。遠端的名稱和 hash 可以被複製，不能證明所有權。
**決定：**開機必須驗證帳號身分和全通規則已關。執行中被打破就 sealed。只有 ObjectMap 的精確對應能授權改遠端物件。
**代價：**管理員要先把 NetBird 整理好，孤兒物件要人工處理。換到的是 Valkona 永遠不會偷改不屬於它的東西。

## 0004 應用契約與 adapter 邊界

**問題：**domain contract 裡混了 HTTP 路由，跨模組流程沒有可呼叫的介面。
**決定：**domain 模組只出語言中立的操作、reader 和 outbound port。HTTP 是獨立的 inbound adapter。跨模組交易和 process 安全歸組合層。跨模組 FK 由 integration migration 加。
**代價：**多一層明確的組合層，但它只管編排不管規則。HTTP、CLI、排程都能重用同一套應用契約。

## 0005 單調工作版本與 gate 邊界

**問題：**Peer 變動不會改 Layer generation，進行中的對齊可能清掉更新的同代 dirty 事件。之前的 OperationPermit 在模組間傳一圈，卻不是真的 transaction lease。
**決定：**每張 Layer 一個只增不減的 `work_version`，完成時 CAS 比對。gate 在應用層邊界檢查一次、每個遠端寫入前再檢查一次，不傳 capability。
**代價：**安全介面對自己的保證很誠實：它擋新操作和遠端寫入，但不是分散式鎖。queue 掉了或對齊過期都不會丟工作。
