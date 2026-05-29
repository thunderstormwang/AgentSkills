# PXBOX-26324 測試檔 Refactor Task Plan

> **本檔位置**：`docs/pxbox-26324_task_refactor.md`
>
> **主 SD 文件**：[pxbox-26324_plan.md](pxbox-26324_plan.md)（Req / Pre Design Sync / Design / Task 全 Done）
>
> **相關 plan**：[pxbox-26324_task_test_coverage.md](pxbox-26324_task_test_coverage.md)（T1-T9 + F1/F2/F3 全 Review，228 通過 / 0 Skip / 0 失敗）
>
> **背景**：PXBOX-26324 測試補強 + 生產碼修正全部完成（212→228 通過 / 11→0 Skip / 0 失敗），但 `CalculateDiscountServiceTests.cs` 累積到 **2425 行**（含 helpers + 11 大區塊 TC），單檔過長影響閱讀與導航。本 plan 將其拆分為 partial class 多檔案，**零行為變更、零測試移除/新增、零生產碼動到**。
>
> **執行策略**：以 C# `partial class` 機制，依 ConditionType / 案型拆檔。每檔開頭重複 `public partial class CalculateDiscountServiceTests { ... }`，所有檔案共用同一個 class 內定義的 helpers 與斷言方法。實際就是純粹「把方法切到不同檔案」，無 logic 重構。

---

## 全域慣例

1. **零行為變更**：不改測試邏輯、不增減測試、不改 Display Name、不改 helper / DTO factory / Assert 方法簽章與內容
2. **partial class**：每檔頂端 `using` 後接 `namespace ...;` 與 `public partial class CalculateDiscountServiceTests { ... }`
3. **驗證**：拆完後跑 `dotnet test src/PXBox.Coupon.Test`，預期 **228 通過 / 0 Skip / 0 失敗**（與當前 HEAD 一致）
4. **檔名規則**：`CalculateDiscountServiceTests.<RegionName>.cs`（一致前綴 + 案型後綴，符合 VS Solution Explorer 的「nested file」展示慣例）
5. **Commit**：整個 refactor = **一個 commit**（mechanical refactor，diff 主要是 file moves），走 `git-commit` skill，**user approve plan 後**才動工

---

## 目標檔案結構

| 檔案 | 內容 | TC 數 | 預估行數 | 原始位置 |
|---|---|---|---|---|
| `CalculateDiscountServiceTests.cs` | partial class 宣告 + Helpers / DTO factory / Assert 方法 | — | ~260 | 原 L2169-2425 |
| `CalculateDiscountServiceTests.OrderQuantity.cs` | 滿件（金 8 + 折 8） | 16 | ~265 | 原 L14-278 |
| `CalculateDiscountServiceTests.OrderPrice.cs` | 滿額（金 7 + 折 8） | 15 | ~245 | 原 L281-525 |
| `CalculateDiscountServiceTests.FirstBuy.cs` | 首購（金 3 + 折 5） | 8 | ~135 | 原 L528-662 |
| `CalculateDiscountServiceTests.Nth.cs` | 第N件（金 6 + 折 9） | 15 | ~260 | 原 L664-923 |
| `CalculateDiscountServiceTests.BuyOneGetOne.cs` | 買一送一 | 5 | ~90 | 原 L926-1014 |
| `CalculateDiscountServiceTests.NItemsYPrice.cs` | N件Y元 | 11 | ~200 | 原 L1017-1214 |
| `CalculateDiscountServiceTests.Assign.cs` | 均攤（AssignPromotionDiscount 邊界） | 5 | ~90 | 原 L1217-1302 |
| `CalculateDiscountServiceTests.Integrated.cs` | 整合（六章：排序 / 累積 / 首購 / 篩選 / 結果 / 混合） | 36 | ~870 | 原 L1306-2169 |

**總計**：1 主檔（helpers）+ 8 案型分檔 = **9 個 partial 檔**，合計 ~228 行 helper + ~2185 行 TC = ~2415 行（與原 2425 行幾乎一致，差額為 partial class 宣告 + using 重複）

---

## Task Implementation Details

### R1 — 拆分 CalculateDiscountServiceTests.cs

- **Current state**：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceTests.cs` 為單檔 2425 行，含 11 大區塊測試 + 共用 helpers，過長不利導航。
- **Goal**：拆為 9 個 partial class 檔案（1 helpers 主檔 + 8 案型分檔），測試數量、編號、行為完全不變，全套件 228 通過 / 0 Skip / 0 失敗。
- **Approach**：
  - 採 C# `partial class` 機制，所有檔案共用同一個 `CalculateDiscountServiceTests` class
  - 每個案型分檔僅含該案型的 `[Fact]` 方法 + 對應 region 分隔註解；helpers 集中在主檔
  - 主檔 `CalculateDiscountServiceTests.cs` 保留 `using`、namespace、partial class 宣告、區段註解（`// Helpers`）、Helpers / DTO factory / Assert 方法
  - 分檔頂端統一以 `using` + namespace + `public partial class CalculateDiscountServiceTests { ... }` 包覆，內部維持原 region 註解（`// 滿件 — 現折金額` 等）
  - 不動 `[Fact(DisplayName = ...)]`、不動 GWT 註解、不動斷言內容、不動 Skip 屬性（雖然目前無 Skip）

- **Steps**：
  1. **建立 8 個分檔**（新檔，逐區複製對應 TC 方法 + 區段註解）：
     - `CalculateDiscountServiceTests.OrderQuantity.cs`：原 L14-278（滿件金 + 折 16 測試）
     - `CalculateDiscountServiceTests.OrderPrice.cs`：原 L281-525（滿額金 + 折 15 測試）
     - `CalculateDiscountServiceTests.FirstBuy.cs`：原 L528-662（首購金 + 折 8 測試）
     - `CalculateDiscountServiceTests.Nth.cs`：原 L664-923（第N件金 + 折 15 測試）
     - `CalculateDiscountServiceTests.BuyOneGetOne.cs`：原 L926-1014（5 測試）
     - `CalculateDiscountServiceTests.NItemsYPrice.cs`：原 L1017-1214（11 測試）
     - `CalculateDiscountServiceTests.Assign.cs`：原 L1217-1302（均攤 5 測試）
     - `CalculateDiscountServiceTests.Integrated.cs`：原 L1306-2169（整合六章 36 測試）
  2. **修改 `CalculateDiscountServiceTests.cs`**：刪除已移到分檔的所有 TC 方法與其區段註解，僅保留 `using` / namespace / partial class 宣告 / Helpers 區段
  3. **加 `partial` 關鍵字**：主檔的 `public class CalculateDiscountServiceTests` → `public partial class CalculateDiscountServiceTests`
  4. **編譯驗證**：`dotnet build src/PXBox.Coupon.Test`，必須無 error / warning
  5. **測試驗證**：`dotnet test src/PXBox.Coupon.Test`，預期 **228 通過 / 0 Skip / 0 失敗**（與當前 HEAD 一致）
  6. **單檔測試驗證**（保險）：`dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~CalculateDiscountServiceTests"`，預期該 class 既有測試數 = 188（總 228 - RebateTests 等其他檔測試數，實際 grep 確認）
  7. **更新本 plan 檔**（`docs/pxbox-26324_task_refactor.md`）：將檔尾 Task Progress Table 中 R1 的 Status 由 `Todo` → `Review`
  8. **commit**（git-commit skill，範圍 `refactor(test)`，message 含 ticket `#26324`）：commit 內容含 8 個新分檔 + 主檔 shrink + 本 plan 檔 status 更新

- **Affected Files**：
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceTests.cs`（2425 → ~260 行）
  - 新增：8 個 `CalculateDiscountServiceTests.<Region>.cs` 分檔

- **驗證指令**：
  ```bash
  dotnet build src/PXBox.Coupon.Test
  dotnet test src/PXBox.Coupon.Test
  ```

- **預期結果**：
  - Build 綠燈、無 warning
  - 全套件 228 通過 / 0 Skip / 0 失敗（與當前 HEAD 一致）
  - 各檔案行數符合「目標檔案結構」表格

---

### R2 — TC 編號統一改為 2 位數零填補

- **Current state**：所有 TC 編號目前使用單位數（如 `TC-N件Y元-1`、`TC-整合-排序-11`），但 N件Y元（11）、整合-排序（11）、整合-首購（9，未來可能增加）等案型逼近或超過 10 個 TC，依字串排序時會出現 `1, 10, 11, 2, 3, ...` 的錯誤排序，閱讀與比對不便。
- **Goal**：所有 TC 編號統一使用 2 位數零填補格式（`TC-N件Y元-1` → `TC-N件Y元-01`、`TC-滿件金-3` → `TC-滿件金-03`），讓字串排序符合自然數字順序，並維持跨案型一致性。
- **Approach**：純機械式 rename，逐一找所有形如 `TC-<案型>-<個位數>`（或 `TC-整合-<子章>-<個位數>`）的字串，補零為 2 位數。**僅補個位數 1-9，已是兩位數的 10、11 等不動**。
- **Steps**：
  1. **依賴 R1 完成**才動工（避免拆檔過程中的合併衝突）
  2. **取基準**：跑 `dotnet test src/PXBox.Coupon.Test` 確認 228/0/0
  3. **逐檔 rename**：
     - 8 個 partial 測試分檔的 `[Fact(DisplayName = "TC-...-N ...")]`（N 為 1-9）
     - `docs/pxbox-26324_tc_discount_promotion.md`：所有形如 `TC-<案型>-<個位數>` 的引用
     - `docs/pxbox-26324_tc_integrated.md`：所有形如 `TC-整合-<子章>-<個位數>` 的引用
  4. **跨檔一致性檢查**：`grep -rn "TC-.*-[1-9]\b"` 整個 `docs/` 與 `src/PXBox.Coupon.Test/`，確認個位數引用全部清零。手動排除：
     - 已是兩位數的 10、11 等
     - 在範圍外的 `tc_rebate_promotion.md`、`tc_coupon.md`（與其對應的 `CalculateDiscountServiceRebateTests.cs`、`AssignCouponDiscountTests.cs`）
     - 引用 plan 檔（`task_test_coverage.md`）若有 TC 編號需同步更新
  5. **build + 全套件驗證**：`dotnet test src/PXBox.Coupon.Test`，預期 **228 通過 / 0 Skip / 0 失敗**（編號變更不應影響執行結果）
  6. **更新本 plan 檔尾 Task Progress Table** R2 Status: Todo → Review
  7. **commit**（git-commit skill，範圍 `chore(test)`，message 含 ticket `#26324`）

- **Affected Files**：
  - 修改：8 個 partial 測試分檔（R1 產出，DisplayName 內字串 rename）
  - 修改：`docs/pxbox-26324_tc_discount_promotion.md`
  - 修改：`docs/pxbox-26324_tc_integrated.md`
  - 修改：`docs/pxbox-26324_task_test_coverage.md`（若內文有 TC 編號引用）
  - 修改：`docs/pxbox-26324_task_refactor.md`（本 plan 檔，更新 R2 status）

- **Dependency**：**R1**（必須先完成檔案拆分）

- **不在範圍**：
  - `CalculateDiscountServiceRebateTests.cs` 的 TC（滿件點/百 / 滿額點/百 / 期額/期件 / 贈點上限 / 現折影響贈點）— 因 R1 未拆分該檔，本次不動，保持「同檔內編號規則一致」
  - `AssignCouponDiscountTests.cs` 的 TC — 同上
  - 對應的 `tc_rebate_promotion.md`、`tc_coupon.md` — 同上

---

### R3 — 測試方法名稱編號統一改為 2 位數零填補

- **Current state**：R2 完成後 `[Fact(DisplayName = "TC-N件Y元-01 ...")]` 已補零，但 C# 測試方法名稱仍是單位數（例：`TC_OrderQuantityMoney_1_NotCumulate`）。當測試清單依方法名排序時（如 IDE Test Explorer、CI 輸出），仍會出現 `1, 10, 11, 2, ...` 的錯誤排序。
- **Goal**：所有測試方法名稱形如 `TC_<Region>_<個位數>_<Description>` 統一補零為 `TC_<Region>_<兩位數>_<Description>`（例：`TC_OrderQuantityMoney_1_NotCumulate` → `TC_OrderQuantityMoney_01_NotCumulate`、`TC_FirstBuyDiscount_5_RoundDown` → `TC_FirstBuyDiscount_05_RoundDown`）。
- **Approach**：純機械式 rename，**只動 C# 方法名識別碼**，不動 `DisplayName` 字串（R2 已處理）、不動 GWT 註解、不動測試邏輯。
- **Steps**：
  1. **依賴 R1 完成**（需作用於 partial 分檔結構）；R2 不是嚴格依賴但已完成，順序 R1 → R2 → R3 較清楚
  2. **取基準**：跑 `dotnet test src/PXBox.Coupon.Test` 確認 228/0/0
  3. **逐檔 rename**：8 個 partial 測試分檔的方法宣告，將所有 `public void TC_<Region>_<N>_<Description>()`（N 為 1-9）的 N 補零為 2 位數
     - **已是 2 位數的 10、11 等不動**
     - 排除其他符號（如 `Tests` class 名、helper 方法）— pattern 必須是 `TC_<...>_<個位數>_<...>` 才動
  4. **跨檔一致性檢查**：`grep -rn "TC_.*_[1-9]_" src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceTests*.cs` 確認個位數方法名全部清零。手動排除：
     - `CalculateDiscountServiceRebateTests.cs`、`AssignCouponDiscountTests.cs`（不在 R1 範圍）
     - Handler 測試檔（`Application/Queries/Frontend/*`、`Application/Commands/ServiceCommands/*`）— 若方法名有 `TC_*_<個位數>_*` 形式，順手 rename；無則不動
  5. **build + 全套件驗證**：`dotnet test src/PXBox.Coupon.Test`，預期 **228 通過 / 0 Skip / 0 失敗**（rename 不影響執行結果）
  6. **更新本 plan 檔尾 Task Progress Table** R3 Status: Todo → Review
  7. **commit**（git-commit skill，範圍 `chore(test)`，message 含 ticket `#26324`）

- **Affected Files**：
  - 修改：8 個 partial 測試分檔（方法名 rename）
  - 修改（如有匹配）：Handler 測試檔（T9 新增的測試方法若用此命名 convention）
  - 修改：`docs/pxbox-26324_task_refactor.md`（本 plan 檔，更新 R3 status）

- **Dependency**：**R1**（必須先完成檔案拆分）。R2 已完成，但 R3 不依賴 R2 的內容變更（兩者作用於不同層面：R2 是 DisplayName 字串、R3 是 C# 方法名識別碼）

- **不在範圍**：
  - `CalculateDiscountServiceRebateTests.cs`、`AssignCouponDiscountTests.cs`（R1 未拆分範圍）
  - 任何 `[Fact(DisplayName = ...)]` 屬性內容（R2 已處理）
  - 測試邏輯、helper、Assert 方法

---

### R4 — 拆分 CalculateDiscountServiceRebateTests.cs

- **Current state**：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceRebateTests.cs` 仍為單檔約 950 行，含贈點單體 TC、上限邊界、現折影響贈點整合 TC 與 helpers；R1 只拆了現折測試，尚未處理贈點測試檔。
- **Goal**：將 `CalculateDiscountServiceRebateTests.cs` 依贈點案型拆成 partial class 多檔，測試數量、DisplayName、方法名、helper 簽章與行為完全不變。
- **Approach**：
  - 採 C# `partial class` 機制，與 R1 相同；所有分檔維持同 namespace、同 class 名稱。
  - 主檔保留 using / namespace / partial class 宣告 / helpers；案型測試搬到分檔。
  - 不動 `AssignCouponDiscountTests.cs`，該檔仍維持單檔。
- **目標檔案結構**：
  - `CalculateDiscountServiceRebateTests.cs`：helpers / DTO factory / Assert 方法。
  - `CalculateDiscountServiceRebateTests.OrderQuantity.cs`：訂單滿件贈點數 + 贈百分比。
  - `CalculateDiscountServiceRebateTests.OrderPrice.cs`：訂單滿額贈點數 + 贈百分比。
  - `CalculateDiscountServiceRebateTests.DurationPrice.cs`：期間累積滿額贈點數 + 贈百分比。
  - `CalculateDiscountServiceRebateTests.DurationQuantity.cs`：期間累積滿件贈點數 + 贈百分比。
  - `CalculateDiscountServiceRebateTests.Limit.cs`：贈點上限與邊界。
  - `CalculateDiscountServiceRebateTests.Integrated.cs`：現折對贈點影響整合 TC。
- **Steps**：
  1. **取基準**：跑 `dotnet test src/PXBox.Coupon.Test`，確認當前綠燈。
  2. **建立 6 個分檔**：逐區複製對應 TC 方法與區段註解，分檔只含 public test methods。
  3. **修改主檔**：`public class CalculateDiscountServiceRebateTests` → `public partial class CalculateDiscountServiceRebateTests`，刪除已搬到分檔的 TC，只保留 helpers。
  4. **跨檔檢查**：確認每個分檔都是 file-scoped namespace + `public partial class CalculateDiscountServiceRebateTests`，且 helpers 可跨 partial class 使用。
  5. **build + 全套件驗證**：`dotnet test src/PXBox.Coupon.Test`，預期測試數與結果不變。
  6. **更新本 plan 檔尾 Task Progress Table** R4 Status: Todo → Review。
  7. **commit**（git-commit skill，範圍 `refactor(test)`，message 含 ticket `#26324`）。

- **Affected Files**：
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceRebateTests.cs`
  - 新增：6 個 `CalculateDiscountServiceRebateTests.<Region>.cs` 分檔
  - 修改：`docs/pxbox-26324_task_refactor.md`（本 plan 檔，更新 R4 status）

- **Dependency**：R1（沿用 partial class 拆檔策略）

---

### R5 — Rebate / Coupon TC 編號統一改為 2 位數零填補

- **Current state**：R2 已完成 `CalculateDiscountServiceTests*.cs` 與現折 / 整合 TC 文件的 DisplayName / 文件 TC 編號補零，但 `CalculateDiscountServiceRebateTests.cs`、`AssignCouponDiscountTests.cs` 與其對應文件仍維持單位數（如 `TC-滿件點-1`、`TC-折價券攤回-6`）。
- **Goal**：將贈點與折價券攤回相關 TC 編號同步改為 2 位數零填補格式（`TC-滿件點-1` → `TC-滿件點-01`、`TC-折價券攤回-6` → `TC-折價券攤回-06`），讓所有 PXBOX-26324 TC 文件與 DisplayName 命名規則一致。
- **Approach**：純機械式 rename，只改 `[Fact(DisplayName = ...)]` 與文件中的 TC 編號引用，不改測試方法名、不改測試邏輯、不改 helper / Assert。
- **Steps**：
  1. **取基準**：跑 `dotnet test src/PXBox.Coupon.Test`，確認當前綠燈。
  2. **逐檔 rename DisplayName / 文件引用**：
     - `CalculateDiscountServiceRebateTests*.cs`：所有 `DisplayName` 內 `TC-<案型>-<個位數>` 補零。
     - `AssignCouponDiscountTests.cs`：所有 `DisplayName` 內 `TC-折價券攤回-<個位數>` 補零。
     - `docs/pxbox-26324_tc_rebate_promotion.md`：所有贈點 TC 標題與內文引用補零。
     - `docs/pxbox-26324_tc_coupon.md`：所有折價券攤回 TC 標題與內文引用補零，包含 `與 -6` 這類延續引用需同步成 `與 -06`。
  3. **跨檔一致性檢查**：`rg "TC-[^\r\n]+-[1-9](\D|$)"` 限定上述 4 個檔案，確認無個位數 TC 編號殘留；手動排除目錄占位如 `TC-案型-N`。
  4. **build + 全套件驗證**：`dotnet test src/PXBox.Coupon.Test`，預期測試數與結果不變。
  5. **更新本 plan 檔尾 Task Progress Table** R5 Status: Todo → Review。
  6. **commit**（git-commit skill，範圍 `chore(test)`，message 含 ticket `#26324`）。

- **Affected Files**：
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceRebateTests*.cs`
  - 修改：`src/PXBox.Coupon.Test/Application/Service/AssignCouponDiscountTests.cs`
  - 修改：`docs/pxbox-26324_tc_rebate_promotion.md`
  - 修改：`docs/pxbox-26324_tc_coupon.md`
  - 修改：`docs/pxbox-26324_task_refactor.md`（本 plan 檔，更新 R5 status）

- **Dependency**：R4（先拆贈點檔，再對分檔後的 DisplayName 補零）

---

### R6 — Rebate / Coupon 測試方法名稱編號統一改為 2 位數零填補

- **Current state**：R3 已完成 `CalculateDiscountServiceTests*.cs` 的測試方法名補零，但 `CalculateDiscountServiceRebateTests.cs`、`AssignCouponDiscountTests.cs` 仍有 `TC_<Region>_<個位數>_<Description>` 方法名。
- **Goal**：將贈點與折價券攤回測試方法名同步改為 2 位數零填補格式（`TC_OrderQuantityPoint_1_NotCumulate` → `TC_OrderQuantityPoint_01_NotCumulate`、`TC_CouponProration_6_DropsRemainingDiscountWhenAllItemsKeepOneDollar` → `TC_CouponProration_06_DropsRemainingDiscountWhenAllItemsKeepOneDollar`）。
- **Approach**：純機械式 rename，只改 C# 方法名識別碼；不動 `DisplayName`（R5 已處理）、不動測試邏輯、不動 helper / Assert。
- **Steps**：
  1. **依賴 R5 完成**，避免 DisplayName 與方法名規則分散在不同狀態。
  2. **取基準**：跑 `dotnet test src/PXBox.Coupon.Test`，確認當前綠燈。
  3. **逐檔 rename 方法名**：
     - `CalculateDiscountServiceRebateTests*.cs`：所有 `public void TC_<Region>_<個位數>_<Description>()` 補零。
     - `AssignCouponDiscountTests.cs`：所有 `public void TC_CouponProration_<個位數>_<Description>()` 補零。
     - 已是兩位數的 `10`、`11` 等不動。
  4. **跨檔一致性檢查**：`rg "TC_.*_[1-9]_"` 限定上述 2 個測試檔，確認無個位數方法名殘留。
  5. **build + 全套件驗證**：`dotnet test src/PXBox.Coupon.Test`，預期測試數與結果不變。
  6. **更新本 plan 檔尾 Task Progress Table** R6 Status: Todo → Review。
  7. **commit**（git-commit skill，範圍 `chore(test)`，message 含 ticket `#26324`）。

- **Affected Files**：
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceRebateTests*.cs`
  - 修改：`src/PXBox.Coupon.Test/Application/Service/AssignCouponDiscountTests.cs`
  - 修改：`docs/pxbox-26324_task_refactor.md`（本 plan 檔，更新 R6 status）

- **Dependency**：R5

---

### R7 — 新案型不可累折超過有效上限時改判定 OverLimit

- **Current state**：規格文件已於 `7a0040af` 更新：買一送一與 N件Y元這兩個新案型在 `is_cumulate = false` 時，固定觸發 1 組且同時視為「有效觸發上限 = 1 組」。目前生產碼仍以 `cumulate_limit > 0 ? cumulate_limit × 每組件數 : int.MaxValue` 判斷 OverLimit，導致不可累折時超過 `1 × 每組件數` 仍可能通過並折抵。
- **Goal**：讓買一送一與 N件Y元在不可累折時，購買件數超過 `1 × 每組件數` 會回傳 OverLimit（折扣 0、負 LackAmount），與 `TC-買一送一-02`、`TC-N件Y元-09` 新文件預期一致。
- **Approach**：
  - 在 `CalculateDiscountService` 內統一新案型的有效觸發上限計算：`IsCumulate = false` → 1 組；`IsCumulate = true && CumulateLimit > 0` → `CumulateLimit`；`IsCumulate = true && CumulateLimit = 0` → 不限。
  - `CheckBuyOneGetOne` 與 `CheckNItemsYPrice` 都使用同一套有效上限，避免兩案型規則再度分岔。
  - 更新既有單體測試預期，不新增重複案例；Handler OverLimit 既有案例仍可作回歸。
- **Steps**：
  1. **取基準**：跑 `dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~CalculateDiscountServiceTests"`，確認修改前僅新規格對應案例會紅。
  2. **修改測試預期**：
     - `CalculateDiscountServiceTests.BuyOneGetOne.cs`：`TC-買一送一-02` 改為 OverLimit，預期 `IsPass = false`、`LackAmount = -2`、`DiscountAmount = 0`、商品金額不變。
     - `CalculateDiscountServiceTests.NItemsYPrice.cs`：`TC-N件Y元-09` 改為 OverLimit，預期 `IsPass = false`、`LackAmount = -4`、`DiscountAmount = 0`、商品金額不變。
  3. **修改生產碼**：
     - 在 `CalculateDiscountService.cs` 萃取私有 helper，例如 `GetEffectiveTriggerLimit(ProductPromotionDto promotion)` 或等價命名。
     - `CheckBuyOneGetOne`：`maxValid = effectiveLimit == null ? int.MaxValue : effectiveLimit.Value * promotion.PerNQty`。
     - `CheckNItemsYPrice`：同上；保留 OverLimit 判定優先於未達門檻 / 非倍數判定。
     - 保持 `triggerCount` 計算原語意：不可累折通過上限後仍固定 1，累折才依總件數 / 上限計算。
  4. **驗證**：
     - `dotnet build PXBox.Coupon.Service.sln --nologo --verbosity:minimal`
     - `dotnet test src/PXBox.Coupon.Test --no-build --filter "FullyQualifiedName~CalculateDiscountServiceTests" --nologo --verbosity:minimal`
     - `dotnet test src/PXBox.Coupon.Test --no-build --nologo --verbosity:minimal`
  5. **更新本 plan 檔尾 Task Progress Table** R7 Status: Todo → Review。
  6. **commit**（git-commit skill，範圍 `fix(api)` 或 `fix(service)`，message 含 `(R7)` 與 ticket `#26324`）。

- **Affected Files**：
  - 修改：`src/PXBox.Coupon.API/Application/Service/CalculateDiscountService.cs`
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceTests.BuyOneGetOne.cs`
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceTests.NItemsYPrice.cs`
  - 修改：`docs/pxbox-26324_task_refactor.md`（本 plan 檔，更新 R7 status）

- **Dependency**：文件規格 commit `7a0040af`

---

### R8 — 整合測試 篩選-04 下放 Service 層

- **Current state**：`TC-整合-篩選-04`（全站排除快取於成單階段現折計算生效）目前在 `CalculatePromotionDiscountCommandHandlerTests.cs`（Handler 層）測試，但測的是 Service 行為（`CalculatePromotionDiscounts` 接 `disableDiscountProductIds` 後現折商品被過濾）。Handler 端只是 plumbing 從 cache 讀後傳入。
- **Goal**：依「Service 負責計算 / Handler 專注 Vo」原則，將該測試下放到 `CalculateDiscountServiceTests.Integrated.cs`，直接驗 Service 層行為；Handler 層不留對應測試（信任 wiring）。
- **Approach**：
  - 在 `CalculateDiscountServiceTests.Integrated.cs` 篩選章節（與 篩選-01/02/03 同區）加新測試，重用既有 `Run` / `AssertActivity` / `AssertItem` helper
  - 從 `CalculatePromotionDiscountCommandHandlerTests.cs` 刪除原 `RealService_TC_Integrated_Filter_04_DisableAllDiscountAppliedOnOrderStage`
  - 不動 `tc_integrated.md` 內容（TC 仍在文件中，只是換層測試）
- **Steps**：
  1. 取基準：`dotnet test src/PXBox.Coupon.Test`，預期 228/0/0
  2. 在 `CalculateDiscountServiceTests.Integrated.cs` 加 `TC-整合-篩選-04` 測試（呼叫 `Run` 並傳入 disable set）
  3. 從 Command Handler 測試檔刪除原 篩選-04 測試
  4. 跑全套件，預期 **228/0/0**（一加一刪）
  5. 更新本 plan 檔尾 Task Progress Table R8 Status: Todo → Review
  6. commit（git-commit skill，範圍 `refactor(test)`）
- **Affected Files**：
  - 修改：`src/PXBox.Coupon.Test/Application/Service/CalculateDiscountServiceTests.Integrated.cs`
  - 修改：`src/PXBox.Coupon.Test/Application/Commands/ServiceCommands/CalculatePromotionDiscountCommandHandlerTests.cs`
- **Dependency**：R1（partial class 結構）

---

### R9 — 補 整合測試 篩選-05（試算階段贈點全站排除）

- **Current state**：`tc_integrated.md:396-400` 已定義 `TC-整合-篩選-05`（全站排除快取於試算階段贈點計算生效），但測試碼遺漏未補。
- **Goal**：在 `GetCalculateDiscountResultQueryHandlerTests.cs` 補上對應測試，與旁邊的 篩選-06（贈點 IsComboShipment 排除）同類型 / 同 pattern。
- **Approach**：因贈點 orchestration 仍在 Handler（見 memory `pxbox_26324_current_state` Q8/D4），這個贈點段過濾測試必須在 Handler 層補。仿照 篩選-06 的測試結構（試算階段、Frontend Handler、贈點活動結果驗證）。
- **Steps**：
  1. 取基準：`dotnet test src/PXBox.Coupon.Test`，預期 228/0/0（或 R8 已完成時的狀態）
  2. 在 `GetCalculateDiscountResultQueryHandlerTests.cs` 加 `TC-整合-篩選-05` 測試：disable cache 含某商品、贈點活動適用該商品 → 期望贈點活動結果只算未被排除的商品
  3. 跑全套件，預期 **229/0/0**（+1 新測）
  4. 更新本 plan 檔尾 Task Progress Table R9 Status: Todo → Review
  5. commit（git-commit skill，範圍 `test`）
- **Affected Files**：
  - 修改：`src/PXBox.Coupon.Test/Application/Queries/Frontend/GetCalculateDiscountResultQueryHandlerTests.cs`
- **Dependency**：無（不需等 R8）

---

## Risk & Notes

1. **partial class 重複定義限制**：所有分檔必須在**同一個 namespace**、**同一個 assembly** 下宣告同名 partial class，否則編譯失敗。本 plan 所有檔案皆位於 `src/PXBox.Coupon.Test/Application/Service/` 同目錄，namespace 一致，無風險。
2. **Helpers 可見性**：所有 helpers 都是 `private static`，partial class 內可跨檔互呼，無問題。
3. **Git blame**：被搬到分檔的 TC 方法，blame 會記為新 commit（mechanical refactor commit hash）；真正歷史需透過 `git log --follow` 或 `git blame -C` 追溯。本次接受該代價（mechanical refactor 標準現象）。
4. **不在範圍內**：
   - `AssignCouponDiscountTests.cs`（165 行）— 已夠小，不拆檔；僅在 R5 / R6 做編號補零
   - 生產碼 — **完全不動**
5. **R2 跨檔一致性**：grep 結果如有遺漏（例如未來新增的 doc 引用 TC 編號），可能造成編號不一致。Step 4 的全域 grep 為主要防線。

---

## Task Progress Table

| ID | Task Description | Status | Dependency |
|:---|:---|:---|:---|
| R1 | 拆分 CalculateDiscountServiceTests.cs 為 9 個 partial class 檔 | Review | — |
| R2 | TC 編號統一改為 2 位數零填補 | Review | R1 |
| R3 | 測試方法名稱編號統一改為 2 位數零填補 | Review | R1 |
| R4 | 拆分 CalculateDiscountServiceRebateTests.cs 為 partial class 檔 | Review | R1 |
| R5 | Rebate / Coupon TC 編號統一改為 2 位數零填補 | Review | R4 |
| R6 | Rebate / Coupon 測試方法名稱編號統一改為 2 位數零填補 | Review | R5 |
| R7 | 新案型不可累折超過有效上限時改判定 OverLimit | Done | 文件規格 `7a0040af` |
| R8 | 整合測試 篩選-04 下放 Service 層 | Review | R1 |
| R9 | 補 整合測試 篩選-05（試算階段贈點全站排除） | Review | — |
