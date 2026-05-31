# pxbox-26325 — 促銷測試結構重組

> 重新組織 promotion 模組的測試結構，**零行為變更、零生產碼動到**。只允許動測試檔，prod code 一律不碰。

## Req

### R01 Objective
讓促銷模組測試結構與新的 handler 拓樸對齊，使新人 onboarding 與測試維護更容易。

### R02 Current State
- 促銷測試集中在 `CalculateDiscountServiceTest.cs`，沒有按 handler 分層。
- 部分 test 的 `[Trait("PromotionCondition", ...)]` 標註與實際案型不一致。

### R03 Proposed Changes
- 拆出 `OrderQuantityHandlerTest.cs`、`OrderPriceHandlerTest.cs`
- 從 ServiceTest 把對應 test case 搬過去
- 統一 `[Trait("PromotionCondition", ...)]` 標註
- prod code 完全不動

### R04 Constraints
- ❌ 不可改任何 prod 邏輯
- ❌ 不可改測試的 expected value
- ✅ 允許重新組織測試結構、調整 Trait / Category

### Req 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R01 | Objective | Done |
| R02 | Current State | Done |
| R03 | Proposed Changes | Done |
| R04 | Constraints | Done |

---

## Pre Design Sync

（無待決議題）

### Pre Design Sync 進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |

---

## Design

### D01 測試結構拆分

把 `CalculateDiscountServiceTest` 內各案型的 test 依 handler 搬到對應的 `*HandlerTest.cs`。每個 handler test class 套用 `[Trait("PromotionCondition", "<案型>")]`。

### Design 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| D01 | 測試結構拆分 | Done |

---

## Task

### T01 [建立 OrderQuantityHandlerTest 骨架]
- **Reference:** `[D01]`
- **Dependency:** `None`
- **Target:** `PXBox.Spu.Test` -> `OrderQuantityHandlerTest`
- **Implementation Details:**
    - 建立 `src/PXBox.Spu.Test/Handlers/OrderQuantityHandlerTest.cs`
    - 加上 xUnit class 骨架與 `[Trait("PromotionCondition", "OrderQuantity")]`
- **Affected Files:** `src/PXBox.Spu.Test/Handlers/OrderQuantityHandlerTest.cs`

### T02 [搬移 OrderQuantity 相關測試]
- **Reference:** `[D01]`
- **Dependency:** `T01`
- **Target:** `PXBox.Spu.Test` -> `CalculateDiscountServiceTest` / `OrderQuantityHandlerTest`
- **Implementation Details:**
    - 從 `CalculateDiscountServiceTest.cs` 把 OrderQuantity 相關 test case 搬到 `OrderQuantityHandlerTest.cs`
    - 不改任何 assertion 內容
- **Affected Files:**
    - `src/PXBox.Spu.Test/CalculateDiscountServiceTest.cs`
    - `src/PXBox.Spu.Test/Handlers/OrderQuantityHandlerTest.cs`

### Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| T01 | 建立 OrderQuantityHandlerTest 骨架 | D01 | None | Done |
| T02 | 搬移 OrderQuantity 相關測試 | D01 | T01 | Done |
