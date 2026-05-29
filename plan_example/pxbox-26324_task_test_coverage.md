# PXBOX-26324 測試補強 Task-Only Plan

> 主 SD 文件：[pxbox-26324_plan.md](pxbox-26324_plan.md)（Req / Pre Design Sync / Design / Task 全 Done）
>
> **背景**：第一輪實作（原 plan T1-T13）已完成且 build + 既有測試綠燈，但測試覆蓋遠低於 TC 文件規格 — `CalculateDiscountService` 75 個 TC case 僅實作 ~18 個測試，折數 / 首購 / 均攤邊界整片缺漏。本 plan 依四份 TC 文件 1:1 補齊測試。
>
> **執行策略**：T1（訂單滿件）已走通並確立風格；T2 起比照辦理。

---

## 全域慣例（所有 Task 適用）

1. **預期值來源**：測試的預期值**一律抄自 TC 文件的「Then」**，**嚴禁從跑生產碼的結果反推**。
2. **可追溯性**：每個測試 `DisplayName` 掛 TC 編號（例：`"TC-滿件金-01 不累折"`）。
3. **失敗處理**：測試失敗 = 「測試抄錯」或「生產碼有 bug」。由 AI 調查分類後回報「具體 TC + 差異」，**程式碼 bug 不擅自修**，交由 user 決定修法方向。
4. **資料對照**：建構測試資料時須對照 TC 文件的 Given 與 enum / 術語對照。
5. **測試檔位置**：mirror 受測類別路徑，與受測類別同層級（例：`Test/Application/Service/CalculateDiscountServiceTests.cs`）。
6. **斷言風格**（T1 確立）：
   - **完整兩層**：TC 的 Then 含「活動結果」（折扣總額 / 欠缺）與「各商品折扣明細」時，兩層都驗。透過高階方法 `CalculatePromotionDiscounts` 串接真實流程後，驗回傳 `CheckPromoteConditionRes` + 驗 `ItemAssignModel` 攤提（`PromotionDiscountAmount` / `Amount` / `Discounts`）。
   - **FluentAssertions**（7.2.0，免費版）：斷言用 `.Should().Be()` / `.Should().ContainSingle(...)` / `.Should().NotContain(...)`。
   - **Given/When/Then 註解**：每個測試三段註解，對應 TC 的 Given / When / Then（含計算說明）。
7. **Commit**：每個 Task = 一個 commit，走 `git-commit` skill，需 user 同意後才 commit。

---

## Task Implementation Details

### T1 訂單滿件（金額 + 折數）✅ 已完成

- 目標檔：`Test/Application/Service/CalculateDiscountServiceTests.cs`（既有檔移至此並重生滿件區塊）
- 16 個測試（TC-滿件金-01~8 + TC-滿件折-01~8），完整兩層 + FluentAssertions + GWT
- 結果：全綠，滿件邏輯無 bug

### T2 訂單滿額（金額 + 折數）

- **目標檔**：`Test/Application/Service/CalculateDiscountServiceTests.cs`（取代既有 3 個滿額單層測試）
- **TC 來源**：「訂單滿額 — 現折金額」（7）+「訂單滿額 — 現折折數」（8）= 15 個測試
- **重點**：滿額以「折抵後金額」累計判定門檻；走高階方法（`OrderPrice` 在 SortDiscountPromotions 內），完整兩層
- **驗證**：`dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~CalculateDiscountServiceTests"`
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceTests.cs`

### T3 第N件（金額 + 折數）

- **目標檔**：同 T2（取代既有 3 個第N件單層測試）
- **TC 來源**：「第N件 — 現折金額」（6）+「第N件 — 現折折數」（9）= 15 個測試
- **重點**：per-unit 攤平取最便宜件、累折次數 = 總件數 / 門檻、逐件截斷至上限；完整兩層
- **驗證**：同 T2
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceTests.cs`

### T4 首購滿件（金額 + 折數）

- **目標檔**：同 T2
- **TC 來源**：「首購滿件 — 現折金額」（3）+「首購滿件 — 現折折數」（5）= 8 個測試
- **重點**：首購活動只折在被標記 `IsUseNewMemberPromotion` 的單一商品上；高階方法須傳 `isFirstBuy: true`；完整兩層
- **驗證**：同 T2
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceTests.cs`

### T5 買一送一

- **目標檔**：同 T2（取代既有 4 個買一送一單層測試）
- **TC 來源**：「買一送一（新案型）」（5）
- **重點**：OverLimit 負 LackAmount、未達門檻、非倍數補差、達標取最便宜 triggerCount 件
- **⚠️ 已知 bug 預警**：`SortDiscountPromotions` 未列入 `BuyOneGetOne`，高階方法 `CalculatePromotionDiscounts` 會在排序階段丟掉此案型。
  - 走高階方法的「完整兩層 / 整合」測試**會 RED**，正好驗證並暴露此 bug → 依全域慣例 3 回報 user 決定修法
  - 單一案型計算邏輯（活動結果 + 攤提明細）可改以 `CheckPromoteCondition` + `AssignPromotionDiscount` 直接呼叫驗證（繞過排序），與整合測試分離
- **驗證**：同 T2
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceTests.cs`

### T6 N件Y元

- **目標檔**：同 T2（取代既有 5 個 N件Y元單層測試）
- **TC 來源**：「N件Y元（新案型）」（11）
- **重點**：OverLimit、未達門檻 / 非倍數 `target` 公式、達標取最便宜 triggerCount×N 件減 triggerCount×Y、反向折扣保護（折扣 ≤ 0 由高階方法跳過、不加入結果）
- **⚠️ 已知 bug 預警**：同 T5（`SortDiscountPromotions` 未列入 `NItemsYPrice`）
- **驗證**：同 T2
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceTests.cs`

### T7 共用均攤邊界（AssignPromotionDiscount）

- **目標檔**：同 T2
- **TC 來源**：「共用均攤邏輯（AssignPromotionDiscount 邊界）」（5）
- **重點**：按金額比例攤提、四捨五入餘額處理、保留 1 元、餘額二次分配；直接呼叫 `AssignPromotionDiscount` 驗證
- **驗證**：同 T2
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceTests.cs`

> **T8-T11 重組（2026-05-27）**：原 T8-T11 全走 Handler 層整合測試。實際偵察發現 tc_integrated 一~七章測的行為（排序、累積扣減、per-product 席位、首購、混合）邏輯全在 `CalculateDiscountService.CalculatePromotionDiscounts` 高階方法裡，Handler 僅是 plumbing。故重組為：**絕大多數下放 Service 層測（重用 T1-T7 helper、真實 service）**，Handler 層只保留「真正屬於 Handler 的行為」（回傳結構組裝 + cache 接線迴歸）。原 T10/T11 內容併入新 T8/T9 後取消。
>
> **逐章歸屬**：一、二、三、四篩選1-3、五結果1-3、六、七 → **Service**；四篩選4-6、五結果4-5、八 → **Handler**。

### T8 Service 整合測試（拆為 T8-1~T8-7，依 tc_integrated 一~七章）

> **共同事項**：透過真實 `CalculateDiscountService.CalculatePromotionDiscounts`（高階方法）跑整合流程；重用既有 `Run` / `RunFirstBuy` / `AssertActivity` / `AssertItem` helper（多活動 overload 已於本批新增）。預期值一律抄 TC Then。已於 commit `19a5c082` 一次寫完 40 測試（211 通過 / 11 Skip / 0 失敗），以下按章拆分追蹤進度與待決議卡點。
> **目標檔**：`Test/Application/Service/CalculateDiscountServiceTests.cs`（一~六）+ `CalculateDiscountServiceRebateTests.cs`（七）
> **驗證**：`dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~CalculateDiscountService"`

- **T8-1 排序與優先序**（11 測試）：per-product 席位、跨群組並存。**6 Skip → 待決議-A**（排序-2,3,4,5,6,7）
- **T8-2 累積扣減效應**（7 測試）：前活動扣減影響後活動門檻。全綠
- **T8-3 首購相關**（9 測試）：首購只折首購商品、買一送一首購排除、首購選擇器。**5 Skip → 待決議-B**（首購-4,5,8,9）**+ 待決議-C**（首購-7）
- **T8-4 商品篩選 1-3**（3 測試）：試算現折 disable / combo / qty=0 過濾。全綠
- **T8-5 結果回傳 1-3**（3 測試）：未達門檻仍回傳 + 差距件/額三態。全綠
- **T8-6 多案型混合**（3 測試）：多案型疊加 + 折價券。全綠
- **T8-7 現折對贈點**（4 測試，RebateTests）：先 `CalculatePromotionDiscounts` 再 `CheckPromoteCondition`(贈點) 串接，現折後 Amount 影響贈點。全綠

### T9 Handler 迴歸：cache 接線 + 回傳結構對照

- **目標檔**：`Test/Application/Queries/Frontend/GetCalculateDiscountResultQueryHandlerTests.cs` + `Test/Application/Commands/ServiceCommands/CalculatePromotionDiscountCommandHandlerTests.cs`（既有檔移入 mirror 路徑）
- **TC 來源**：`tc_integrated.md`「四、篩選-4,5,6」+「五、結果-4,5」+「八、Handler 回傳結構對照」
- **測試方式**：Handler 注入**真實** `CalculateDiscountService`，只 mock `PromotionCalculateDtoCache`（反射）/ `IDisableDiscountCacheRepository` 資料來源。既有 5 個「假整合」測試（mock service + 重寫 fake 計算）定位為 Handler plumbing 測試，保留但不算整合主防線
- **重點**：成單階段 disable 迴歸（Bug 1，Command Handler 接線）、試算贈點段 disable/combo 迴歸（Bug 2，Frontend Handler）、Frontend `lack_amount < 0` 訊號欄位、Service `OverLimitPromotionIds` 清單組裝、兩 Handler 回傳結構欄位對照
- **驗證**：`dotnet test src/PXBox.Coupon.Test`
- **Affected Files**：上述兩個 Handler 測試檔

### T10、T11 ~~整合~~（已取消）

內容已併入 T8（Service 整合）與 T9（Handler 迴歸），不再獨立成 Task。

### T12 贈點：訂單滿件 + 訂單滿額（點數 + 百分比）

- **目標檔**：`Test/Application/Service/CalculateDiscountServiceRebateTests.cs`（**新檔** — 贈點走 `CheckPromoteCondition` 共用方法，單層活動結果驗證）
- **TC 來源**：`tc_rebate_promotion.md`「訂單滿件 — 贈點數 / 贈百分比」+「訂單滿額 — 贈點數 / 贈百分比」
- **重點**：贈點數固定值、贈百分比計算、累贈上限、單筆福利點上限（MaxPointsPerOrder）
- **驗證**：`dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~CalculateDiscountServiceRebateTests"`
- **Affected Files**：`Test/Application/Service/CalculateDiscountServiceRebateTests.cs`

### T13 贈點：期間累積滿額贈 + 滿件贈 + 上限邊界

- **目標檔**：同 T12
- **TC 來源**：`tc_rebate_promotion.md`「期間累積滿額贈」「期間累積滿件贈」（各點數 + 百分比）+「上限與邊界（共用）」
- **重點**：Duration / DurationQuantity 路由、累積上限、邊界
- **驗證**：同 T12
- **Affected Files**：同 T12

### T14 折價券攤回

- **目標檔**：`Test/Application/Service/AssignCouponDiscountTests.cs`（**新檔**）
- **TC 來源**：`tc_coupon.md`「折價券攤回（共用邏輯）」（6）
- **重點**：`AssignCouponDiscount` 攤提、達使用門檻、折抵上限、保留 1 元
- **驗證**：`dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~AssignCouponDiscountTests"`
- **Affected Files**：`Test/Application/Service/AssignCouponDiscountTests.cs`

---

## 待決議事項（測試暫標 Skip，等 user 回憶案例後決定）

> 由 T3/T4 測試補強暴露，user 要求先擱置、跑測試先回綠（暫標 `Skip`），待回憶案例後再處理。

| # | 暫 Skip 的測試 | 議題 | 處理 |
| :--- | :--- | :--- | :--- |
| 待決議-1 | TC-N件金-03、TC-N件折-04 | **確認為真 prod bug**：第N件累折「上限不限(0)」折扣歸零。`GetNthDiscountAmount` 累折分支缺 `cumulateLimit > 0` 守衛，`(0+discount)>0` 恆真使折扣歸零。TC line 327/385 已預警 | ✅ **已修**（user 核可修 prod）：兩處累折分支內層條件加 `cumulateLimit > 0 &&`，Skip 移除，2 測試轉綠 |
| 待決議-3 | TC-首購金-02 | 活動層 `res.DiscountAmount` = 名目 $50 vs TC 期望實際 $29（攤提層 A 折 $29 正確）。層級定義落差 | ✅ **採用 (b)**（user 決定修 prod）：固定金額現折的活動層也依可折商品總額截斷，保留每品項 $1，Skip 移除，測試轉綠 |
| 待決議-A | TC-整合-排序-02,3,4,5,6,7（6）| **設計有、程式沒做**：per-product 同群組席位互斥未實作。`CalculatePromotionDiscounts`（L208-212）checkItems 篩選未排除「已被前活動折抵的商品」。設計依據：ac L394（AC-整合-排序-同群組互斥）、plan L92/L95。已驗證生產碼 + TC 忠實 | ✅ **已修**（F3）：`CalculatePromotionDiscounts` 維護 `seatedProductIds` HashSet，商品現折群組（非 IsFirstBuy 且非 OrderPrice）的 checkItems 排除席位內商品；活動 IsPass 後將其 checkItems productId 併入席位；6 個 Skip 解除並轉綠 |
| 待決議-B | TC-整合-首購-04,5,8,9（4，全買一送一）| **設計有、程式沒做**：買一送一未排除首購商品。生產僅在 `promotion.IsFirstBuy` 時過濾 `IsUseNewMemberPromotion`（L214-217、L249-250），非首購的買一送一不排除。設計依據：ac L281（AC-買一送一-首購商品排除）、L283（排除後0件不回傳）。註：N件Y元 依 ac L322 本就不排除，程式正確 | ✅ **已修**（F2）：`CalculatePromotionDiscounts` 基本篩選後對 `BuyOneGetOne` 過濾 `IsUseNewMemberPromotion`，並對 `BuyOneGetOne / NItemsYPrice` 排除後 0 件直接 continue 不加入結果；4 個 Skip 解除並轉綠 |
| 待決議-C | TC-整合-首購-07（1）| **Design 內部矛盾**：AC（ac L236/L413）說「首購標記=是+無首購商品時活動仍達標 lack=0」，但 Design 流程虛擬碼（plan L965）「先用 IsUseNewMemberPromotion 過濾 checkItems」→ 0 件 → 門檻不過 → IsPass=false。生產照 L965 | ✅ **已修**（commit `ba910cb4`，門檻 vs 折扣用不同 item 集合）：首購活動 `CheckPromoteCondition` 呼叫兩次，門檻用整車 checkItems、折扣用 firstBuyItems（無則 fallback 整車取名目額度）。`TC-整合-首購-07` Skip 移除並轉綠 |

## Task Progress Table

| ID | Task Description | 引用 | Status | Dependency |
| :--- | :--- | :--- | :--- | :--- |
| T1 | 訂單滿件（金額 8 + 折數 8）| tc_discount_promotion | Review | — |
| T2 | 訂單滿額（金額 7 + 折數 8）| tc_discount_promotion | Review | — |
| T3 | 第N件（金額 6 + 折數 9）| tc_discount_promotion | Review | — |
| T4 | 首購滿件（金額 3 + 折數 5）| tc_discount_promotion | Review | — |
| T5 | 買一送一（5）⚠️ 預期暴露 Sort bug | tc_discount_promotion | Review | — |
| T6 | N件Y元（11）⚠️ 預期暴露 Sort bug | tc_discount_promotion | Review | — |
| T7 | 共用均攤邊界 AssignPromotionDiscount（5）| tc_discount_promotion | Review | — |
| T8-1 | 排序與優先序（11，6 Skip→A）| tc_integrated 一 | Review | — |
| T8-2 | 累積扣減效應（7）| tc_integrated 二 | Review | — |
| T8-3 | 首購相關（9，5 Skip→B/C）| tc_integrated 三 | Review | — |
| T8-4 | 商品篩選 1-3（3）| tc_integrated 四篩選1-3 | Review | — |
| T8-5 | 結果回傳 1-3（3）| tc_integrated 五結果1-3 | Review | — |
| T8-6 | 多案型混合（3）| tc_integrated 六 | Review | — |
| T8-7 | 現折對贈點（4）| tc_integrated 七 | Review | — |
| T9 | Handler 迴歸：cache 接線 + 回傳結構對照 | tc_integrated 四篩選4-6、五結果4-5、八 | Review | — |
| ~~T10~~ | ~~整合：結果回傳 + 多案型混合~~（併入 T8）| — | Cancel | — |
| ~~T11~~ | ~~整合：現折對贈點 + Handler 回傳結構對照~~（併入 T8/T9）| — | Cancel | — |
| T12 | 贈點：訂單滿件 + 滿額（點數 + 百分比）| tc_rebate_promotion | Review | — |
| T13 | 贈點：期間累積滿額/滿件贈 + 上限邊界 | tc_rebate_promotion | Review | — |
| T14 | 折價券攤回（6）| tc_coupon | Review | — |
| F1 | 待決議-C：移除首購門檻前過濾（迴歸）| 待決議-C | Review | — |
| F2 | 待決議-B：買一送一首購排除 + 0件不回傳 | 待決議-B | Review | — |
| F3 | 待決議-A：per-product 同群組席位追蹤 | 待決議-A | Review | F2 |

---

## 生產碼修正 Plan（待決議 A/B/C → 對齊既有規格，不改 Req/Design）

> **共同事項**：唯一動的生產檔 `src/PXBox.Coupon.API/Application/Service/CalculateDiscountService.cs`（`CalculatePromotionDiscounts` 方法）。三項皆為「讓實作對齊既有 AC/Design」——A/B 補做設計要求但第一版漏掉的行為、C 修回被第一版改壞的既有行為，**不更動 Req/Design 內容**（plan L965 虛擬碼謄寫錯誤已於 commit `f8b59af0` 更正）。每項 = 一個 commit，修完即解除對應 Skip 並跑全套件驗證綠燈。

### F1 — 待決議-C：首購活動門檻判定 vs 折扣計算用不同 item 集合

> **方案演進註記**：原 Approach「單純刪除首購過濾」於 implementation 階段實測證明不可行（會讓 `TC-首購金-02 / TC-首購折-01/4/5` 共 4 個既有測試回歸，因為 `GetPromotionRebateAmount` / `GetNthDiscountAmount` 的折扣基數依賴 checkItems 只含首購商品這個前提）。改採 memory `pxbox-26324-pending-decisions` 預警的 fallback 方向：**門檻與折扣用不同 item 集合**。

- **Current state**：`CalculatePromotionDiscounts` L214-217 在 `CheckPromoteCondition` 前用一道過濾把 checkItems 縮成「只首購商品」，下游同一份 checkItems 被用來做門檻判定（IsPass / LackAmount）+ 折扣計算（DiscountAmount）+ 攤提範圍三件事。整車門檻判定不到 → `TC-整合-首購-07` Skip 中。
- **Goal**：對首購活動把三個職責拆開——
  - **門檻判定**（IsPass / LackAmount）→ 用整車 `checkItems`（基本篩選後未再縮）
  - **折扣計算**（DiscountAmount）→ 用 `firstBuyItems`（`IsUseNewMemberPromotion` 過濾）；無首購商品時 fallback 用整車取「名目額度」（給前端首購選擇器資料用，符合 `TC-整合-首購-07` 期望 discountAmount=100）
  - **攤提範圍**（`AssignPromotionDiscount`）→ 用 `firstBuyItems`（空集合也行，`AssignPromotionDiscount` 內部已有 `IsUseNewMemberPromotion` 過濾）

  讓 `TC-整合-首購-07` 轉綠且 `TC-首購金-02 / TC-首購折-01/4/5` 全部維持綠。
- **Approach**：`CalculatePromotionDiscounts` 的迴圈內，首購活動 branch 多算一份 `firstBuyItems`，呼叫 `CheckPromoteCondition` **兩次**：
  1. 用整車 checkItems → 取 `IsPass` + `LackAmount`
  2. 若 IsPass 為 true，用 `firstBuyItems`（無則 fallback 整車）再呼一次 → 取 `DiscountAmount` 蓋上去
  3. 攤提階段把 checkItems 換成 `firstBuyItems`（後續 `promotion.ProductIds = checkItems.Select(...)` 邏輯不動）

  ```csharp
  CheckPromoteConditionRes res;
  if (promotion.IsFirstBuy)
  {
      var firstBuyItems = checkItems.Where(x => x.IsUseNewMemberPromotion).ToList();
      res = CheckPromoteCondition(promotion, checkItems);  // 門檻
      if (res.IsPass)
      {
          var discountItems = firstBuyItems.Count > 0 ? firstBuyItems : checkItems;
          res.DiscountAmount = CheckPromoteCondition(promotion, discountItems).DiscountAmount;
      }
      checkItems = firstBuyItems;  // 攤提
  }
  else
  {
      res = CheckPromoteCondition(promotion, checkItems);
  }
  ```

  `CheckPromoteCondition` 簽章不動；`AssignPromotionDiscount` 不動；`GetPromotionRebateAmount` / `GetNthDiscountAmount` 不動。
- **Steps**：1) 改 `CalculatePromotionDiscounts` 首購 branch（如上）。2) 解除 `TC-整合-首購-07` Skip。3) 跑 `dotnet test src/PXBox.Coupon.Test --filter "FullyQualifiedName~CalculateDiscountService"`，目標 `TC-整合-首購-07` 轉綠 + `TC-首購金-02 / TC-首購折-01/4/5` 保持綠。4) 跑全套件驗證 212 通過 / 10 Skip / 0 失敗。
- **解 Skip**：首購-7（1）。**Dependency**：無。
- **Tech debt（Refactor 階段處理）**：`Count > 0 ? firstBuyItems : checkItems` 的 fallback 屬於 Green 階段的權宜設計，語意是「給首購選擇器看的名目額度」。未來 Refactor 可考慮拆 `EvaluateThreshold` / `CalculateDiscountAmount` 兩介面或在 `CheckPromoteConditionRes` 加 `NominalAmount` 欄位顯式化此職責，**本次 F1 不做**。

### F2 — 待決議-B：買一送一排除首購商品 + 排除後 0 件不回傳

- **Current state**：僅 `promotion.IsFirstBuy` 時過濾首購商品；非首購的買一送一不排除首購商品。且 checkItems 經排除後為 0 件時，活動仍會被加進結果列表。
- **Goal**：買一送一（`ConditionType == BuyOneGetOne`）的 checkItems 排除 `IsUseNewMemberPromotion` 商品（ac L281）；買一送一 / N件Y元 經排除後 checkItems = 0 件時整個活動跳過、不加入結果（ac L283/L322/L434）。N件Y元 **不**排除首購商品（ac L322，現況正確）。
- **Approach**：基本 checkItems 篩選後加兩段——(a) `if (ConditionType == BuyOneGetOne) checkItems = checkItems.Where(x => !x.IsUseNewMemberPromotion)`；(b) `if ((BuyOneGetOne || NItemsYPrice) && checkItems 為空) continue;`（0 件不回傳；此規則同時供 F3 席位排除後 0 件使用）。
- **Steps**：1) 加上述兩段。2) 解除 `TC-整合-首購-04,5,8,9` Skip。3) 驗證轉綠。
- **解 Skip**：首購-4,5,8,9（4）。**Dependency**：無。

### F3 — 待決議-A：per-product 同群組席位追蹤

- **Current state**：checkItems 篩選未排除「已被同群組前活動折抵的商品」→ 同群組（商品現折群組）內同商品被重複折上折。
- **Goal**：商品現折群組內，某商品被前活動生效折抵後，後續同群組活動對該商品跳過（ac L394、plan L92/L95）；跨群組（會員 / 商品現折 / 訂單滿額）仍各自並存。
- **Approach**：
  - **群組判定**：會員群組 = `IsFirstBuy`；訂單滿額群組 = `ConditionType == OrderPrice`；其餘（滿件非首購 / 第N件 / 買一送一 / N件Y元）= 商品現折群組。席位只需在商品現折群組內追蹤（其他群組由前提保證最多 1 活動）。
  - 維護 `HashSet<int>` 記錄「已被商品現折群組折抵的 productId」；處理商品現折群組活動時，checkItems 排除已在席位集合內的商品；活動 `IsPass` 後將其 checkItems 的 productId 併入席位集合。
  - 排除後 0 件的買一送一 / N件Y元 由 F2 的 0 件規則跳過；滿件 / 第N件 排除後若不足門檻照常回傳 lack（與 TC 一致）。
- **Steps**：1) 加群組判定 + 席位集合。2) 商品現折群組 checkItems 排除席位。3) `IsPass` 後 populate 席位。4) 解除 `TC-整合-排序-02,3,4,5,6,7` Skip。5) 跑全套件驗證 211 通過 / 0 Skip / 0 失敗。
- **解 Skip**：排序-2,3,4,5,6,7（6）。**Dependency**：F2（共用「0 件不回傳」規則）。
