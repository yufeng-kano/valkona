# 文件索引

最後更新：2026-08-30

**這個檔案說明 `docs/` 的結構和規則。想讀懂 Valkona，從 [`tw/index.md`](tw/index.md) 的導讀開始。**

## 三個資料夾的用途

| 資料夾 | 用途 | 狀態 |
| --- | --- | --- |
| [`tw/`](tw/index.md) | 繁體中文規格。規格階段唯一維護中的版本，內容等同讀完整份 en。 | 維護中，規格以此為準 |
| [`en/`](en/index.md) | 原始英文概念文件（v0.11.4）。 | 已凍結，只讀不改 |
| [`dev/`](dev/index.md) | 實作文件。程式碼出現後才開始長。 | 空的骨架 |

## 優先序規則

- 規格階段（現在，還沒有程式碼）：`tw/` 是唯一真實來源。
- `en/` 是凍結的 archive。改規格只改 `tw/`，不用同步 `en/`。`tw/` 和 `en/` 衝突時以 `tw/` 為準。
- 程式碼出現後：實作行為以 `dev/` 為準。`dev/` 和 `tw/` 衝突時，先確認是 bug 還是規格改了，規格改了就更新 `tw/`。
- 開發完成後：`en/` 和 `tw/` 退場封存，只留 `dev/`。

## 檔名規則

- 新文件檔名用英文小寫（例如 `glossary.md`），標題和內文用繁體中文。

## 文件清單

| 路徑 | 摘要 |
| --- | --- |
| [`tw/index.md`](tw/index.md) | 導讀：先看哪份、照什麼順序讀 |
| [`tw/glossary.md`](tw/glossary.md) | 黑話對照表：文件術語與產品詞彙的人話解釋 |
| [`tw/product.md`](tw/product.md) | 產品是什麼、給誰用、不做什麼 |
| [`tw/architecture.md`](tw/architecture.md) | 模組怎麼切、安全機制、交易邊界 |
| [`tw/core.md`](tw/core.md) | Core 模組：使用者、Peer 歸屬、Enrollment、庫存同步 |
| [`tw/topology.md`](tw/topology.md) | Topology 模組：Layer 內的存取意圖 |
| [`tw/runtime.md`](tw/runtime.md) | Runtime 模組：編譯、對齊 NetBird、Explain |
| [`tw/netbird.md`](tw/netbird.md) | NetBird adapter：唯一碰 NetBird API 的地方 |
| [`tw/audit.md`](tw/audit.md) | Audit 模組：append-only 稽核紀錄 |
| [`tw/http-api.md`](tw/http-api.md) | HTTP API：路由、錯誤格式、驗證規則 |
| [`tw/operations.md`](tw/operations.md) | 設定、啟動流程、NetBird 實證、實作順序、使用者旅程 |
| [`tw/decisions.md`](tw/decisions.md) | 五個架構決策（ADR）摘要 |
| [`tw/review.md`](tw/review.md) | 架構疑慮與建議，非規格 |
| [`en/index.md`](en/index.md) | 凍結英文文件的索引 |
| [`dev/index.md`](dev/index.md) | 實作文件的角色說明與規則 |
