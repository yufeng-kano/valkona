# Audit 模組

**Audit 是一個只能追加、不能改不能刪的稽核紀錄槽。**
它只擁有信封格式和保存期限，事件的意義由來源模組自己定義。

## 事件信封

```text
event_id
occurred_at
principal（user 或 system worker，worker 不假冒管理員）
source_module
kind
resource_type / resource_id（可空）
metadata（結構化物件）
```

## 寫入規則

- 安全性和管理性的修改，audit 事件跟狀態變更在同一個 transaction 裡 commit，不會只成功一半。
- sink 只有 Append 一個操作。
- metadata 禁止放任何密鑰明文。

## 記什麼、不記什麼

**記：**使用者角色和狀態變更、identity binding 和 owner 變更、Enrollment 最終結果、使用者的藍圖修改、needs_attention 的管理員處置、系統進入 sealed。

**不記：**一般成功的對齊。那個已經有 ReconcileAttempt 在記了，不重複。

## MVP 範圍

**MVP 只有寫入，沒有查詢 API、沒有 HTTP 路由。**
要看紀錄，管理員直接用資料庫工具查。
之後要開查詢介面，必須先有意識地補 contract。

保存期限由設定檔控制。
安全政策要求的事件不過期，一般營運紀錄可以按時間清掉。
