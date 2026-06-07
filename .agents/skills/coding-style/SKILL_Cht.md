---
name: coding-style
description: 提供強制性的程式碼風格標準與架構模式. 撰寫或重構程式碼時啟用此 skill,以確保符合專案特定慣例.
---

# coding-style

管理與套用各程式語言特定程式碼風格的中央樞紐.

## 使用方式

啟用此 skill 時,必須判斷當前處理的副檔名,並從 `references/` 目錄讀取對應的參考檔案.

### 支援語言
- **C# (.cs)**: 讀取 `references/csharp.md`

## 準則
- 一律優先遵循語言特定參考檔案中的規則.
- 若 `references/` 中尚未支援該語言,則遵循一般整潔程式碼原則及程式碼庫中的現有模式.
