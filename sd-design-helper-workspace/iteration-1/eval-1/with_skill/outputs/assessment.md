# 點數過期提醒功能評估文件 (Point Expiration Reminder)

## 1. Req (需求分析)
- **目標 (Objective):** 實作自動化的點數過期提醒機制，於點數到期前透過推播 (Push Notification) 提醒用戶，提升點數使用率。
- **目前狀態 (Current State):** 系統尚無主動提醒點數即將過期的功能。
- **建議變更 (Proposed Changes):**
    - 實作每日排程任務 (Daily Job)，掃描即將過期的點數資料。
    - 將掃描結果（過期名單與金額）暫存於 Redis，以利非同步發送與效能優化。
    - 整合通知服務 (Notification Service) 進行推播發送。
- **結論 (Conclusions):** 
    - 需考量點數過期前 7 天或 3 天進行提醒。
    - 推播發送需具備等量限制與重試機制。
- **限制 (Constraints):**
    - 資料庫掃描需避免在高峰時段執行。
    - Redis 暫存資料需設定 TTL 以免佔用過多內存。

## 2. Design (技術設計)
### 技術決策 (Technical Decisions)
- **決策 1: 使用 Redis 作為非同步發送的緩衝區**
    - **脈絡 (Context):** 資料庫掃描可能產生數萬筆甚至更多的通知名單，若直接同步呼叫通知服務，會造成掃描 Job 執行時間過長且難以處理發送失敗的重試。
    - **決策 (Decision):** 掃描 Job 僅負責將名單寫入 Redis (如 Redis List 或 Set)，由另一個 Worker/Thread 負責從 Redis 領取任務並發送推播。
    - **後果 (Consequences):** 解耦了掃描與發送邏輯，提高了系統的可擴展性與容錯力。

### 服務變更 (Service Changes)
- **Point Service:** 負責排程掃描與 Redis 寫入。
- **Notification Service:** 接收推播請求。
- **Redis:** 作為資料傳遞與暫存的媒介。

### 詳細設計表 (Detailed Design Table)
| 組件 (Component) | 變更類型 (Change Type) | 詳細內容 (Details) |
| :--- | :--- | :--- |
| **Point DB** | Query | 搜尋 `points` 資料表，篩選條件為 `expiry_date = today + N days`。 |
| **Scanner Job** | Job | 每日 10:00 AM 觸發，執行 DB 掃描並寫入 Redis。 |
| **Redis** | Cache | Key: `queue:point_expiry_reminder` (List 類型)。 |
| **Push Worker** | Logic | 從 Redis LPOP 取得用戶 ID 與過期資訊，呼叫 Notification API。 |
| **Notification Service** | API | 呼叫 `POST /v1/notifications/push` 發送訊息。 |

---

## 3. Task (任務拆解)
| ID | 任務 (Task) | 實作細節 (Implementation Details) | 目標服務 | 狀態 (Status) |
| :--- | :--- | :--- | :--- | :--- |
| 1.1 | 撰寫 DB 掃描 SQL | 實作 Repository 層級的過期點數統計查詢 (GroupBy UserID)。 | Point Service | Pending |
| 1.2 | 整合 Redis 寫入邏輯 | 實作將 UserID 與金額封裝成 JSON 放入 Redis 隊列。 | Point Service | Pending |
| 1.3 | 實作推播發送 Worker | 撰寫循環消費 Redis 隊列並呼叫 Notification Client 的邏輯。 | Point Service | Pending |
| 1.4 | 設置排程觸發器 | 配置 cron 任務 (0 10 * * *) 啟動 Scanner Job。 | Point Service | Pending |
| 1.5 | 流程驗證與監控 | 建立整合測試，並在發送失敗時增加 Logging。 | Point Service | Pending |
