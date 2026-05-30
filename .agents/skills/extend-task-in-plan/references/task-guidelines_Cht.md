# Mode A —— Task 排序與類別規則 (Mode A Task Ordering & Category Rules)

本指南適用於 `extend-task-in-plan` skill 的 **Mode A —— 初始 Task 生成**。涵蓋從 Design 生成 task 的排序與類別專屬規則。

**Task 區塊格式**（欄位、範本、共用限制）請見 `task-format.md`。

---

## Task 排序 (優先順序)

生成 Mode A Task 列表時，請務必遵循以下順序，以利於並行開發與順暢整合：

1. **DB Schema 變更**：務必優先產生 SQL 腳本。
2. **Entity / Domain 變更**：核心業務邏輯與資料結構。
3. **API 骨架與欄位**：優先定義 Request/Response 模型與 Controller 端點 (Endpoints)。
4. **API 摘要 (API Summary)**：在定義 API 合約後立即提供前端摘要（僅限文件的 task）。
5. **驗證任務 (測試任務)**：為進入點建立獨立的測試 task。此時介面已定義；先撰寫測試以定義預期行為（測試先行/失敗先行）。
6. **功能實作 (Functional Implementation)**：詳細邏輯與優化，持續開發直到測試通過。

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
