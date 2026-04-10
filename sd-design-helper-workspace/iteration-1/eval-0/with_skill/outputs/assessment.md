# 系統設計評估文件：會員服務取得個人資料 API 欄位擴充

## 1. Req (需求分析)

根據稽核需求，需要在現有的「取得個人資料 API」中增加顯示會員的「最後登入時間」欄位。

- **目標 (Objective):** 在會員個人資料查詢中提供最後登入時間，以滿足系統稽核與安全性追蹤需求。
- **現況 (Current State):**
    - 會員服務資料庫 (DB) 中已經有 `last_login_time` (或類似名稱) 的欄位。
    - 現行的「取得個人資料 API」在 Response Body 中並未返回此欄位。
- **建議變更 (Proposed Changes):**
    - 擴充 API Response DTO，新增 `last_login_time` 欄位。
    - 更新服務層 (Service Layer) 邏輯，確保從資料庫讀取的 Entity 欄位能正確映射到 DTO。
- **結論 (Conclusions):** 由於 DB 已有欄位，此變更屬純讀取擴充，風險較低。
- **限制 (Constraints):** 時間格式需遵循系統統一標準 (例如：ISO 8601 或 `yyyy-MM-dd HH:mm:ss`)。

---

## 2. Design (技術設計)

針對本次 API 欄位擴充的技術細節進行定義。

- **技術決策 (Technical Decisions):**
    - **欄位名稱:** `last_login_time`
    - **資料型態:** `DateTime` (映射為 API 字串輸出)
    - **映射規範:** 由 Entity 映射至 Response DTO。

- **服務變更表 (Service Changes):**

| 元件 | 變更類型 | 說明 |
| :--- | :--- | :--- |
| **Member API** | API | 在 `GetProfileResponse` 或相關 DTO 中增加 `last_login_time` 欄位。 |
| **Member Service** | Logic/Mapping | 在 DTO 映射 (Mapper) 中加入 `last_login_time` 欄位。 |
| **Member Repository**| DB Query | 確保 SQL 查詢或 Entity 定義中包含 `last_login_time` 欄位。 |

- **討論點 (Discussion Points):**
    - 若 `last_login_time` 為 NULL (例如新註冊且尚未登入過)，建議回傳 `null` 或預設值。

---

## 3. Task (任務分解)

將實作過程拆解為微小的、可單獨提交的任務。

| ID | Task | 實作細節 | 目標服務 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| 1.1 | **更新 DTO 與 Entity** | 在 `MemberEntity` (若缺) 與 `GetProfileResponse` 增加 `last_login_time` 欄位。 | Member Service | Pending |
| 1.2 | **更新 Repository 層** | 確保 `FindById` 或相關查詢方法能正確取得最後登入時間。 | Member Service | Pending |
| 1.3 | **更新 Service 映射邏輯**| 在 `GetProfile` 服務邏輯中，將 Entity 的最後登入時間填入 DTO。 | Member Service | Pending |
| 1.4 | **單元測試與 API 驗證** | 撰寫測試案例驗證 API 回傳內容是否包含正確的時間戳記。 | Member Service | Pending |
