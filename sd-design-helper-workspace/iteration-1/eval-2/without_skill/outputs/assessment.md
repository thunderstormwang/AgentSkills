# 商品庫存遷移至 Redis 評估文件

## 1. 需求背景與目標
- **背景**：商品庫存目前存放於關聯式資料庫 (RDBMS)，在高併發（如限時搶購、促銷活動）時，資料庫的 Row Lock 會造成嚴重的效能瓶頸，甚至導致連線數耗盡。
- **目標**：
  - 提升讀取與扣減庫存的吞吐量 (Throughput)。
  - 確保在高併發場景下庫存不超賣（原子性）。
  - 維護 Redis 與 DB 之間的資料最終一致性。

---

## 2. 系統架構設計

### 2.1 資料結構選擇
建議使用 Redis 的 **Hash** 或 **String** 類型：
- **方案 A (String)**：Key 為 `stock:{product_id}`，Value 為整數。優點是操作極快，適合單一數值。
- **方案 B (Hash)**：Key 為 `product:{product_id}`，欄位包含 `stock`, `version`, `status`。優點是擴充性強。

**最終建議**：若僅處理庫存扣減，使用 **String** 配合 `DECRBY` 或 **Lua 腳本** 即可。

### 2.2 高併發下的扣減邏輯 (一致性保證)
為了避免超賣，禁止「先讀取 Redis -> 在 Application 判斷 -> 再寫回 Redis」的非原子操作。應採用的方案：

#### **方案：Lua 腳本 (推薦)**
將「讀取、判斷、扣減」封裝在 Lua 腳本中，利用 Redis 的單執行緒特性保證原子性。
```lua
-- Lua Script for atomic decrement
local product_id = KEYS[1]
local amount = tonumber(ARGV[1])
local current_stock = tonumber(redis.call('get', product_id))

if current_stock >= amount then
    redis.call('decrby', product_id, amount)
    return 1 -- 成功
else
    return 0 -- 庫存不足
end
```

---

## 3. 回寫 DB 機制 (Write-Behind)
為確保效能，採用**非同步回寫**策略：

1. **Redis 更新成功**：Lua 腳本執行成功後，回傳成功訊號給 Application。
2. **傳送訊息至 MQ**：Application 將「訂單 ID、商品 ID、扣減數量」發送至 Message Queue (如 Kafka 或 RabbitMQ)。
3. **DB 消費者執行更新**：
   - 消費者訂閱 MQ 訊息。
   - 執行 `UPDATE product_stock SET stock = stock - ? WHERE id = ?`。
   - 這裡使用資料庫自帶的 `stock = stock - ?` 確保不會因為並發更新導致數據錯誤。
4. **回寫失敗處理**：若 DB 更新失敗，訊息進入死信隊列 (DLQ)，由人工或補償機制處理。

---

## 4. 資料一致性與補救方案

### 4.1 最終一致性
- **快取預熱**：活動開始前，將 DB 庫存同步至 Redis，並設置永不過期（或直到活動結束）。
- **核對機制 (Reconciliation)**：每日離峰時段執行 Job，對比 Redis 與 DB 的庫存差值，以 DB 為準進行校正。

### 4.2 異常情境處理
- **Redis 宕機**：配置 Redis Sentinel 或 Cluster 模式保證高可用。若 Redis 全線崩潰，系統應具備降級機制，暫時將請求導向 DB (須配合限流)。
- **MQ 遺失訊息**：開啟 MQ 的持久化機制與 ACK 確認模式。

---

## 5. 實施步驟
1. **開發環境測試**：驗證 Lua 腳本的併發壓力測試。
2. **影子庫存觀察**：雙寫模式，僅以 DB 為準，但同步寫入 Redis 並比對正確性。
3. **正式遷移**：切換為 Redis 扣減 + MQ 非同步回寫。
4. **監控報警**：監控 Redis 延遲、MQ 積壓量、DB 更新成功率。

---

## 6. 結論
透過 Redis Lua 腳本保證庫存扣減的原子性，並搭配 MQ 非同步回寫機制，能有效解決資料庫在高併發下的負載問題。雖然此方案存在極短時間的資料不一致，但透過 MQ 重試與定期核對，可達成最終一致性，平衡了效能與資料安全。
