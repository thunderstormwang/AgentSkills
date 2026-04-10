# 點數過期提醒功能評估文件 (Point Expiration Reminder)

## 1. 需求分析 (Requirement Analysis)
- **背景 (Background):** 為了提升用戶點數使用率並減少點數失效產生的客訴，系統需要主動提醒即將有點數到期的用戶。
- **目標 (Objective):** 實作每日自動化掃描機制，篩選出 7 天內即將過期的點數，並發送推播通知 (Push Notification)。
- **核心需求:**
    - 每日排程掃描點數資料表。
    - 使用 Redis 暫存待發送名單，避免掃描與發送過程相互阻塞。
    - 串接現有的通知服務 (Notification Service) 進行發送。

## 2. 系統架構設計 (System Architecture)
### 2.1 整體流程圖
1. **[Scanner Job]**: 每日離峰時段觸發，自資料庫撈取即將過期的點數資料。
2. **[Redis Buffer]**: Scanner 將「用戶 ID、過期點數金額、到期日」封裝成任務放入 Redis List/Stream。
3. **[Notification Worker]**: 多個輕量級 Worker 持續從 Redis 取得任務，並呼叫 Notification Service。
4. **[Notification Service]**: 負責將訊息推送至行動裝置。

### 2.2 技術決策 (Technical Decisions)
- **Redis 資料結構:** 建議使用 `LPUSH` / `RPOP` (List) 作為任務隊列。若需更高的可靠性與訊息追蹤，可考慮 Redis Stream (`XADD`)。
- **批次處理:** 掃描 Job 應採取批次查詢 (Batch Fetch) 與批次寫入 (Batch Insert to Redis)，避免單次載入過多資料造成記憶體壓力。
- **併發控制:** 設定掃描 Job 為單一實例執行 (Single Instance)，避免多個排程同時掃描相同資料導致重複推播。

## 3. 詳細技術規格 (Technical Specifications)

### 3.1 Redis 設計
- **Key 命名:** `queue:notification:point_expiry:{yyyyMMdd}`
- **資料格式:** JSON 格式
  ```json
  {
    "user_id": "U12345678",
    "points": 500,
    "expiry_date": "2023-12-31",
    "retry_count": 0
  }
  ```
- **TTL (存活時間):** 設定為 48 小時，確保任務執行完畢或過時後自動清除，不佔用空間。

### 3.2 資料庫查詢優化
- **索引優化:** 確保 `points` 資料表在 `expiry_date` 欄位上有索引。
- **篩選條件:** `WHERE expiry_date = CURRENT_DATE + 7 DAYS AND balance > 0`。

### 3.3 通知發送策略
- **流控 (Throttling):** 考慮通知服務的承載能力，Worker 應具備每秒發送頻率限制 (Rate Limit)。
- **重試機制:** 若 Notification Service 回傳 5xx 錯誤，Worker 將任務重新放入 Redis 隊列，並增加 `retry_count`。

## 4. 任務拆解 (Task Breakdown)
| 階段 | 任務名稱 | 內容說明 | 狀態 |
| :--- | :--- | :--- | :--- |
| **Phase 1** | SQL 與 Repository 實作 | 撰寫高效能的點數過期查詢 API。 | Pending |
| **Phase 2** | Redis 整合開發 | 實作將查詢結果序列化並推送至 Redis 隊列的邏輯。 | Pending |
| **Phase 3** | Notification Worker | 實作消費 Redis 隊列並串接 Notification Service API。 | Pending |
| **Phase 4** | 排程設定 | 配置每日 10:00 AM (或離峰時段) 觸發的 Cron Job。 | Pending |
| **Phase 5** | 監控與日誌 | 實作發送成功率統計與失敗日誌記錄。 | Pending |

## 5. 效益評估
- **效能提升:** 透過 Redis 異步處理，掃描 Job 可在短時間內完成，不會因為通知服務的延遲而卡住。
- **穩定性:** 任務緩衝區可應對通知服務的突發流量或短暫斷線，具備故障隔離能力。
- **可擴展性:** 若名單量極大，可輕鬆增加 Notification Worker 的數量來加速發送。
