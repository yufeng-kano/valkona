# 導讀

**這份文件告訴你先看哪一份、照什麼順序讀。**
`tw/` 是目前唯一維護中的規格，讀完等於把英文版全部讀過一次。
英文原版凍結在 [`../en/`](../en/index.md)，只當歷史對照。

## 閱讀順序

**照這個順序讀，前面的看不懂再往下會更看不懂。**

1. [`glossary.md`](glossary.md)，黑話對照表。先掃過一次，之後看到不懂的詞就回來查。
2. [`product.md`](product.md)，這個產品是什麼、給誰用、明確不做什麼。
3. [`architecture.md`](architecture.md)，模組怎麼切、安全機制怎麼運作。
4. [`topology.md`](topology.md)，使用者實際在編輯的東西：Layer 和存取規則。
5. [`runtime.md`](runtime.md)，Layer 怎麼變成真的 NetBird 設定。
6. [`core.md`](core.md)，使用者、裝置歸屬、認領裝置的流程。
7. [`netbird.md`](netbird.md)，唯一碰 NetBird API 的邊界。
8. [`audit.md`](audit.md)，稽核紀錄，很短。
9. [`http-api.md`](http-api.md)，對外 API 長什麼樣。
10. [`operations.md`](operations.md)，設定、啟動、實作順序、使用者旅程。
11. [`decisions.md`](decisions.md)，為什麼架構長這樣，五個決策的摘要。
12. [`review.md`](review.md)，對這套架構的疑慮和建議。這份是意見，不是規格。

## 快速任務指引

**不想全讀的話，按目的挑。**

- 想知道產品在幹嘛：讀 2 就好。
- 想開始寫程式：讀 2、3，然後讀你要做的那個模組，最後看 [`operations.md`](operations.md) 的實作順序。
- 想接 API：讀 9，配 [`glossary.md`](glossary.md) 查詞。
- 想評估架構合不合理：讀 3、11、12。

## 這批文件的共同規則

- 一件事只有一份文件是老大，其他文件只引用不重抄。
- 每個模組一份文件，把原本拆開的 contract、design、schema、acceptance 重點合併。
- 資料表細節以 `../en/` 內各模組的 `schema.sql` 為準，本區只講重點欄位和規則。
- 程式碼出現後，實作細節寫到 [`../dev/`](../dev/index.md)，不回寫這裡。
