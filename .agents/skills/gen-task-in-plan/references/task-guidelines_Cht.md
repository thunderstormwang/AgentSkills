# Mode A —— Task 排序與類別規則 (Mode A Task Ordering & Category Rules)

本指南適用於 `gen-task-in-plan` skill 的 **Mode A —— 初始 Task 生成**。涵蓋從 Design 生成 task 的排序與類別專屬規則。

**Task 區塊格式**（欄位、範本、共用限制）請見 `task-format.md`。

---

## Task 排序 (優先順序)

依實際前置條件排序 task。適用時使用以下類別優先原則，不將它們視為必須分開的 task 或固定流水線。完整的契約/實作改動及其驗證必須同步生效時，應放在一起：

1. **DB Schema 變更**：後續改動依賴 schema 時，優先產生 SQL 腳本。
2. **Entity / Domain 變更**：核心業務邏輯與資料結構。
3. **API 骨架與欄位**：優先定義 Request/Response 模型與 Controller 端點 (Endpoints)。
4. **API 摘要 (API Summary)**：在定義 API 合約後立即提供前端摘要（僅限文件的 task）。
5. **包含驗證的功能實作**：每個實作 task 都依已確認策略，納入對應測試的新增/修改與適用檢查。

先寫測試可在實作 task 內進行，不必另開獨立驗證任務。只有獨立驗證目的，或需要等待多個 task 完成的檢查，才另開驗證 task，並記錄實際依賴。共用驗證規則請見 `task-format.md`。

---

## 類別專屬規則 (Category-specific Rules)

### DB Schema 變更
- 涉及資料庫變更的 task 必須包含產生 SQL 腳本。
- **儲存：** 儲存至專案根目錄的 `sql/` 資料夾。
- **檔名：** `PXBOX-{jira ticket no}.sql`。
- **單號：** 如果不知道 Jira 單號，請詢問使用者確認。

### API 合約變更
- 這是一個 **僅限文件** 的 task（不涉及程式碼變更）。
- **目的：** 為前端開發人員提供清晰、可直接複製貼上的摘要。
- **內容：** 包含 API 路由、變更類型（新增/修改/刪除）以及 Request/Response 中的具體欄位變更。
