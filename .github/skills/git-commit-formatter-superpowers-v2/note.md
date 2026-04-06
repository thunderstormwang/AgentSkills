使用 model: Claude Haiku 4.5  
且加入 superpowers 的 writing-skills.  

檔案開頭的 metadata 有 Use ... When ... 的條件式敘述  
還未仔細看，底下是 AI 自己提供的比照表

## 改善對比表

| 項目 | 原版 | v2 版本 |
|-----|------|--------|
| **結構** | 簡單指令 | 完整 headline + body + footer 結構 |
| **Type 展示** | 純文字列表 | 表格格式含用例 |
| **Scope 指引** | 無 | 具體範例（auth, api, db 等）|
| **Copilot 簽名** | 無 | ✅ 每次都包含 Co-authored-by |
| **Body 說明** | 無 | ✅ 詳細指引（解釋 why、字元限制等）|
| **Breaking Changes** | 簡述 | ✅ 完整說明 + 遷移指南 |
| **實例數量** | 1 個 | ✅ 5 個多樣化例子 |
| **驗證清單** | 無 | ✅ 8 項確認清單 |
| **流程步驟** | 5 步 | ✅ 5 步（更詳細的說明）|

## 主要改善方向

- ✅ 提升專業性：從基礎格式到完整的企業級 commit 流程
- ✅ 增加可操作性：表格、例子、檢查清單
- ✅ 強化追溯性：Copilot 簽名、Breaking Change 標準化
- ✅ 改善可讀性：結構清晰、視覺化呈現
