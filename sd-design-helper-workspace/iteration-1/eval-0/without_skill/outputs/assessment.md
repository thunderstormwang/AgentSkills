# 20250603 會員服務 - 取得個人資料 API 增加「最後登入時間」欄位

## 想法

- **需求背景**：為了符合稽核需求，會員的個人資料 API 需要顯示「最後登入時間」。
- **現況分析**：資料庫（DB）中已經存在該欄位（假設欄位名為 `LastLoginTime`），但目前的後端程式碼在讀取資料及回傳 API 時，並未將此欄位包含在內。
- **影響範圍**：主要影響會員服務（Member Service）的取得個人資料 API 及其相關的資料模型（Entity/DTO）。

---

## 評估卡片

### 後端 - Member - 調整資料模型 (Entity/DTO)

- 確認 `Member` Entity 中已正確對應 DB 的 `LastLoginTime` 欄位。
- 在 API 的回傳模型（例如 `UserProfileResponse`）中新增 `last_login_time` 欄位。
- 確保欄位型別與專案內的時間格式（如 `DateTime` 或 `string` ISO 8601）一致。

2h

### 後端 - Member - 調整 API 邏輯與 Service 層

- 檢查 Repository 層的查詢邏輯，確保有選取 `LastLoginTime` 欄位（若非使用自動映射的全欄位查詢）。
- 在 Service 層將 Entity 的資料轉換至 DTO 時，補上 `LastLoginTime` 的賦值邏輯。
- 若有時區轉換需求（例如 DB 存 UTC，API 需回傳本地時間），需在此階段處理。

2h

### 後端 - Member - 單元測試與 API 整合測試

- 撰寫/更新單元測試，驗證 Service 層能正確映射最後登入時間。
- 進行 API 整合測試（Postman/Swagger），確認回傳 JSON 包含預期欄位。
- 測試邊界情況：若會員從未登入（`LastLoginTime` 為 NULL）時的回傳表現。

2h

6h
