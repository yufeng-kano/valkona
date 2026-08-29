# NetBird adapter

**整個系統只有這一個地方碰 NetBird 的 HTTP API。**
認證、分頁、DTO、timeout、重試、錯誤翻譯全部關在這裡。
其他模組永遠拿不到 NetBird 的原始 JSON。

## 職責邊界

- adapter 實作 Core、Runtime、System 宣告的 outbound port，回傳的型別完全依照那些模組定義的邊界型別。
- NetBird 的 DTO、分頁 token、專屬欄位不外流。
- 一個 adapter 實例綁一個設定好的帳號身分。

## 清單語意

**回傳結果只有兩種：完整，或錯誤。**
分頁是 adapter 內部的事。
任何一頁失敗、格式不對，整個結果就是錯誤，絕不偽裝成「成功但少一點」。

## 錯誤翻譯

**所有錯誤翻成 `Backend.Error.v1` 的固定分類，呼叫方只看分類。**

```text
unauthenticated | forbidden | not_found | conflict | rate_limited
timeout | unavailable | invalid_response | outcome_uncertain
```

`outcome_uncertain` 是最重要的一類：非冪等的寫入可能已經成功了。
遇到它不准自動重試、不准自動認領、不准再建一份。

重試只允許兩種情況：操作本身冪等，或已確定遠端沒有執行。

## Projection 對應

**Valkona 概念到 NetBird 物件的翻譯規則：**

- 一張 enabled 的 Layer 對應一個 Valkona 擁有的 Policy。
- 一條 enabled 的 AccessEdge 對應該 Policy 裡的一條 Rule。
- 一個 Node 對應一個 Valkona 擁有的單成員 Group。
- 一個 Topology Group 對應一個 Valkona 擁有的 Group。
- `selector: all` 在投影時解析成 NetBird 內建的 All Group，不複製成員清單。

Rule 一律是單向的 accept。明確 deny 不在 MVP。

## Canonicalization（正規化）

**讀回來的 Group 和 Policy 要先正規化，才能算穩定的 hash。**
用途：判斷有沒有變化、驗證寫入結果、偵測 drift。
哪些欄位忽略、哪些唯讀，以 Phase 0 錄下的 fixture 為準，不用猜的。

## 安全檢查

**adapter 只負責提供證據，不做決策。**
回傳兩件事：連線帳號的穩定身分證據，和預設 all-to-all 規則的狀態。
證據拿不到就回 `unknown` 或錯誤。
要不要啟動或封鎖，是 System composition 的事。

## 診斷用 metadata

Valkona 建立的物件，名稱和描述會帶本地資源和 correlation 的提示。
這些只是給人看的線索，永遠不構成修改或刪除的授權。
授權只看 Runtime 的 ObjectMap。

## 測試用 fake

**同一套 contract 有一個 stateful fake 實作。**
fake 存 User、Peer、Group、Setup Key、Policy 和帳號身分。
測試可以直接改 fake 的狀態，模擬 drift、帳號不符、timeout、create 到一半當機這些情境。

## 驗收重點

- 每個 outbound 介面都有 production 和 fake 兩份實作。
- 原始 DTO 不跨過 adapter 邊界。
- 分頁失敗不可能回傳成功的部分清單。
- `outcome_uncertain` 絕不自動重試。
- 正規化對 Phase 0 fixture 是決定性的。
