# PXBOX-26599 活動頁商品區塊增加 Appier 推薦選項

---

## Req — 需求分析

### Objective
在共用的樣板類型（活動頁、品牌頁、分類頁）的商品區塊（`TemplateBlockType.Products`）中，新增「**Appier 選品**」模式。讓後台管理者可選擇不手動指定商品，而改由第三方系統 Appier 依不同 app 動態推薦商品展示。

---

### Current State

**商品區塊寫入流程：**
```
SaveTemplateCommandHandler
  ├── CheckInputLogic()   → 商品區塊必須有 ≥1 個商品 (硬性驗證)
  └── SetBlockGroups()
        └── case Products:
              → template.SetGroupWithProduct(products: Dict<productId, sort>)
              → 資料存至 template_block_products 表
```

**前台讀取流程：**
```
GetAppGroupProductListQuery
  → Elasticsearch.SearchByMarketingAsync(TemplateGroupId, ProductMarketingType.TemplateGroupProduct)
  → 回傳 GroupProductListVo（所有人看同一份商品）
```

**ES 商品索引更新流程：**
```
RefreshTemplateCahceJob (每小時 :05 執行, cron: "5 */1 * * *")
  → GetTemplateGroupProductsAsync(groupIds)   ← 查 template_block_products
  → 組成 TemplateElasticsearchDto 存入 Redis
  → 商品被 re-index 時，ProductIndexModelConverter 讀 Redis
    → 寫入 ES 商品文件的 product_marketings:
      { id: TemplateBlockGroupId, type: TemplateGroupProduct, sort: N }
```

**Appier 現有整合 (Curating)：**
- `ScopeType.AppierProducts` 標記 Curating 排程使用 Appier 選品
- 排程存有 `PxPayScenarioId`、`PxGoScenarioId`
- `RefreshRedisCacheByAppierApiJob` 每 5 分鐘呼叫 Appier API → 依 app 各自存一份至 Redis
  - `Dict<CuratingScheduleId, Dict<SystemSourceType(PXPay/PXGo), AppierProductDto>>`

---

### Proposed Changes

1. 商品區塊的 group 新增「選品類型」欄位，支援 **手動選品 (0)** 與 **Appier 選品 (2)**（值 1 為 AI 推薦，由另一同事負責），適用範圍：活動頁、品牌頁、分類頁
2. Appier 選品模式下，使用者須填入 `PxpayScenarioId`、`PxgoScenarioId`，不需指定商品
3. 新增定時 Job，每 5 分鐘呼叫 Appier API，以 ScenarioId 分別取得 PXPay / PXGo 推薦商品（各最多 24 品），並更新快取
4. `GetAppGroupProductListQueryHandler` 在 Appier 選品模式下，須依據呼叫方是 **PXPay 或 PXGo** 回傳**不同的商品列表**；商品詳細資料須從 **Elasticsearch** 撈取最新內容（不直接回傳 Appier API 快取的商品資料）
5. Template 相關快取的其他更新頻率照舊，不影響
6. `GetAppGroupProductListQueryHandler` 中呼叫 `AppTemplateDtoCache` 的參數，須全部改由前端傳入，不得寫死（現有程式碼硬寫 `ProductMarketingType.TemplateGroupProduct = 4`，對品牌頁、分類頁會取到錯誤的 cache key）

---

### Constraints

- 現有資料（手動選品的 group）必須向下相容，`product_select_type` 預設值 = 0
- 系統須每 5 分鐘更新 Appier 推薦商品

---

### Acceptance Criteria

- 後台可在商品區塊選擇「Appier 選品」模式；選擇後，PxPay ScenarioId 與 PxGo ScenarioId 為必填欄位，且無需指定商品
- 後台手動選品模式下，商品區塊必須至少填入 1 個商品（現有驗證保持不變）
- 手動選品的既有商品區塊行為不變
- 前台在 Appier 選品模式下，PXPay / PXGo 各自取得 Appier 推薦的商品列表（最多 24 品）
- 商品詳細資料來自 Elasticsearch，非 Appier API 快取
- Appier 推薦商品每 5 分鐘自動更新
- `GetAppGroupProductListQueryHandler` 呼叫 `AppTemplateDtoCache` 時，`TemplateType`、`TopCategoryId`、`MidCategoryId` 三個參數由前端傳入，不得寫死

---

### Req 進度表

| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R1 | Objective | Done |
| R2 | Current State | Done |
| R3 | Proposed Changes | Done |
| R4 | Constraints | Done |
| R5 | Acceptance Criteria | Done |

---

## Pre Design Sync

> 以下問題會直接影響設計細節，請逐項確認後，再產出 Design 內容。

**Q1 — GetAppGroupProductListQuery 如何識別 PXPay / PXGo**

**結論：** 在 `GetAppGroupProductListQuery` 新增 `SystemSourceType` 欄位，比照 `GetAppCuratingListQuery`：
```csharp
/// <summary>
/// PxGo = 1, PxPay = 2
/// </summary>
public int SystemSourceType { get; set; } = 2;
```

**Q2 — ES 結構如何支援 PXPay / PXGo 各自一份商品**

目前 ES 每個商品的 `product_marketings` 在同一個 groupId 只有一筆：
`{ id: TemplateBlockGroupId, type: TemplateGroupProduct, sort: N }`

**方案比較：**

| 面向 | 方案 A：新增 ProductMarketingType 值 | 方案 B：ES 新增 app_type 欄位 |
| :--- | :--- | :--- |
| **做法** | 新增 `TemplateGroupProductPxPay = 10`、`TemplateGroupProductPxGo = 11` | ES `product_marketings` 增加 `app_type` 欄位，query 時帶入 filter |
| **ES mapping 異動** | 不需要 | 需要更新 ES mapping，並 re-index 全量商品 |
| **向下相容** | 現有 `TemplateGroupProduct = 4` 完全不動 | 舊資料 `app_type` 為 null，需特別處理 |
| **修改範圍** | `ProductMarketingType` enum、Query handler | ES mapping、`ProductMarketingChangedEventHandler`、Query handler |
| **風險** | 低 | 中（re-index 期間資料不一致） |

~~**結論：採用方案 A。** 新增兩個 `ProductMarketingType` 值：~~
~~- `TemplateGroupProductPxPay = 10`~~
~~- `TemplateGroupProductPxGo = 11`~~

**Cancel：** Q7 確認採用方案二（TopSelling-like bypass），Appier 選品不走 `product_marketings`，無需新增 ProductMarketingType 值。

**Q3 — Appier 商品更新後如何觸發 ES re-index**

~~目前手動選品的商品在被異動時透過 Kafka 事件 re-index。~~
~~Appier 每 5 分鐘商品清單可能完全不同（舊商品移除、新商品加入），~~
~~需要一個機制讓 ES 同步更新，否則前台會看到錯誤的商品。~~

**Cancel：** Appier 選品不走 `product_marketings`，查詢時直接從 Redis 取商品 ID → 以 ID 查 ES，ES 回傳的永遠是最新商品資料，與 re-index 機制無關。

**Q4 — SIT / UAT hardcode 商品**

**結論：** 比照 `CuratingDtoCache` 的現有做法，在新 Job 中以 `_sitProducts` / `_uatProducts` hardcode，PXPay / PXGo 各維護一份。

**Q5 — Appier 商品 ID 快取結構與 query handler 判斷路徑**

原本討論將 Appier 專用欄位加入 `TemplateGroupElasticsearchDto`，但 Q7 確認 Appier 路徑不寫 ES，該 DTO 語意是「準備寫進 ES product_marketings 的資料」，混入 Appier 欄位語意不符。

進一步討論比較兩種做法：

| 面向 | 新 Appier Cache | AppTemplateDtoCache 加欄位 |
|---|---|---|
| **判斷方式** | 以 `TemplateGroupId` 查新 cache，有 key = Appier | 從已讀的 `AppTemplateDtoCache` 裡找 group，看 `ProductSelectType` |
| **額外 cache 讀取** | +1 次（新 cache） | 0（handler 已讀 `AppTemplateDtoCache`） |
| **寫入方維護** | 新 Appier Job 維護新 cache | `RefreshTemplateCahceJob` 與 Appier Job 各自更新同一份 cache 的不同欄位 |
| **資料耦合** | 完全解耦 | `ProductSelectType` 混在 template 結構 cache 裡 |
| **修改範圍** | 新增 cache class | 修改現有 DTO + cache |

**結論：**
1. `TemplateGroupElasticsearchDto` **完全不動**
2. `AppTemplateBlockGroup`（在 `AppTemplateDto`）新增 `ProductSelectType` 欄位（0=手動, 2=Appier），由 `RefreshTemplateCahceJob` 寫入
3. 新增 Appier Cache（以 `TemplateGroupId` 為 key），只存 Appier 模式 group 的 `{ PxPay: [productIds], PxGo: [productIds] }`，由新 Appier Job 每 5 分鐘更新
4. `GetAppGroupProductListQueryHandler` 從已讀的 `AppTemplateDtoCache` 取得 `ProductSelectType`：
   - `0` → 走原本 ES `SearchByMarketingAsync`
   - `1` → 從新 Appier Cache 取商品 ID → `SearchByIdsAsync`

**Q6 — Appier 商品移除後 ES product_marketings 的殘留問題**

**Cancel：** Q7 確認採用方案二（TopSelling-like bypass），Appier 選品不走 `product_marketings`，無需事件機制處理殘留問題。

> ~~比照 `ProductMarketingChangedEventHandler` 的現有機制，Appier Job 更新 Redis 前先讀出舊的商品列表，比對差異後，對異動的商品發布 `ProductMarketingChangedEvent`~~

**Q7 — Appier 選品查詢方式：更新 ES product_marketings vs TopSelling-like bypass**

現有 TopSelling / Curating Appier 已採用 bypass 做法（Redis ID → `SearchByIdsAsync`），不寫 product_marketings。
調查確認，整個 codebase 中用 `group_id + TemplateGroupProduct` 查 ES 且會走到 Appier 選品 group 的，只有 `GetAppGroupProductListQueryHandler`。`FlashSaleDtoCache`（限時必搶）雖然也用相同的查詢方式，但限時必搶有自己的一套 API，不走 `SaveTemplateHandler`，其 group 永遠不會被設為 Appier 模式，故不在考慮範圍內。

**方案比較：**

| 面向 | 方案一：更新 ES product_marketings | 方案二：TopSelling-like bypass |
| :--- | :--- | :--- |
| **做法** | Job 比對差異 → publish `ProductMarketingChangedEvent` → ES `product_marketings` 寫入 `TemplateGroupProductPxPay/PxGo` | Job 取 Appier 商品 ID 只存 Redis；查詢時從 Redis 取 ID → `SearchByIdsAsync` in ES |
| **ES 資料異動** | 是，product_marketings 需寫入 / 移除 | 否，product_marketings 完全不動 |
| **Q2 新 enum 是否需要** | 是 | 否 |
| **Q6 事件機制是否需要** | 是 | 否 |
| **受影響查詢** | `GetAppGroupProductListQueryHandler` | `GetAppGroupProductListQueryHandler`（加 Appier 分支） |
| **現有範例** | 無 | `TopSellingCache`、`CuratingDtoCache`（Appier 模式） |
| **修改複雜度** | 高 | 低，比照現有模式 |
| **風險** | 中（事件機制、ES partial update） | 低 |

**結論：** 採用方案二（TopSelling-like bypass）。Job 取得 Appier 商品 ID 後只存 Redis；查詢時從 Redis 取 ID → `SearchByIdsAsync` in ES，`product_marketings` 完全不動。比照 `TopSellingCache` / `CuratingDtoCache`（Appier 模式）現有實作。

**Q8 — `SaveTemplateCommandHandler` 商品驗證在 Appier 模式下的處理**

Current State 的 `CheckInputLogic()` 有「商品區塊必須有 ≥1 個商品」的硬性驗證，`SetBlockGroups()` 也會呼叫 `SetGroupWithProduct()` 寫入 `template_block_products`。Appier 選品模式下使用者不指定商品，這兩處的行為需要確認。

**結論：** Appier 選品模式下，`CheckInputLogic()` 跳過「商品區塊必須有 ≥1 個商品」的驗證；`SetBlockGroups()` 改儲存 `PxPayScenarioId` / `PxGoScenarioId`，不呼叫 `SetGroupWithProduct()`。

Req 提到「使用者須填入 PxpayScenarioId、PxgoScenarioId」，但 `SaveTemplateCommandHandler` 目前 input 只有商品列表，儲存 ScenarioId 的後台 API 改動是否也在此次範疇？

**結論：** 在此次範疇內。`SaveTemplateCommandHandler` 的 command input 需新增 `PxPayScenarioId`、`PxGoScenarioId`，並存至 `template_block_groups`（或對應欄位），後台 API 需同步調整以支援 Appier 模式的輸入。

**Q10 — Appier 推薦商品數量上限的計算方式**

Req 說「各最多 24 品」，確認是 PxPay 最多 24 品、PxGo 最多 24 品（各自獨立計算），而非合計 24 品。

**結論：** PxPay 最多 24 品、PxGo 最多 24 品，各自獨立計算，不合併。

---

**Q11 — `GetAppGroupProductListQuery` 新增 `AppTemplateDtoCache` 所需參數的向下相容策略**

目前 Handler 寫死 `type = (int)ProductMarketingType.TemplateGroupProduct = 4` 呼叫 `AppTemplateDtoCache.GetCacheAsync()`，導致品牌頁（type=1）、分類頁（type=3）會取到錯誤 cache key（會落入 else 分支，以 `template.{templateId}` 當 key，而非正確的 `brand.{topCategoryId}`）。

修正方向：在 `GetAppGroupProductListQuery` 新增 `TemplateType`、`TopCategoryId`、`MidCategoryId` 三個欄位，由前端傳入。

需確認：這三個新欄位是**必填**，還是可為 null（null 時跳過 PrivateSale 判斷）？

**結論：** `TemplateType`、`TopCategoryId`、`MidCategoryId` 為 int，預設值 0；任一欄位為 0 時，跳過封閉賣場（PrivateSale）判斷。

---

### Pre Design Sync 進度表

| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| Q1 | Query 識別 PXPay/PXGo | 新增 `SystemSourceType` 欄位，PxGo=1, PxPay=2 | Done |
| Q2 | ES 結構方案 | Q7 採方案二，Appier 不走 product_marketings，新 enum 值不需要 | Cancel |
| Q3 | Appier 更新後 ES re-index 機制 | Appier 不走 product_marketings，直接 Redis ID → ES 查詢，機制無關 | Cancel |
| Q4 | SIT/UAT hardcode 商品 | 比照 CuratingDtoCache，PXPay / PXGo 各一份 hardcode | Done |
| Q5 | TemplateGroupElasticsearchDto 快取結構 | `TemplateGroupElasticsearchDto` 不動；`AppTemplateBlockGroup` 加 `ProductSelectType`；新 Appier Cache 存商品 ID | Done |
| Q6 | Appier 商品移除後 ES product_marketings 殘留 | Q7 採方案二，bypass 路徑不寫 product_marketings，殘留問題不存在 | Cancel |
| Q7 | Appier 查詢方式：ES 更新 vs bypass | 採方案二：Redis ID → SearchByIdsAsync，比照 TopSelling/Curating 模式 | Done |
| Q8 | SaveTemplateCommandHandler 商品驗證 Appier 模式處理 | Appier 模式跳過商品數驗證；改儲存 ScenarioId，不呼叫 SetGroupWithProduct() | Done |
| Q9 | 後台 API 修改範圍 | 在此次範疇內，command input 新增 PxPayScenarioId / PxGoScenarioId | Done |
| Q10 | Appier 推薦商品數量上限計算方式 | PxPay 最多 24 品、PxGo 最多 24 品，各自獨立計算 | Done |
| Q11 | AppTemplateDtoCache 新增參數的向下相容策略 | TemplateType/TopCategoryId/MidCategoryId 為 int 預設 0；任一為 0 則跳過封閉賣場判斷 | Done |

---

## Design

### D1 — DB Schema

`template_block_groups` 新增 3 欄位：

| 欄位 | 型別 | 預設 | 說明 |
| :--- | :--- | :--- | :--- |
| `product_select_type` | TINYINT NOT NULL | DEFAULT 0 | 0 = 手動選品, 1 = AI 推薦（另一同事負責）, 2 = Appier 選品 |
| `px_pay_scenario_id` | VARCHAR(100) NULL | NULL | Appier PxPay Scenario ID |
| `px_go_scenario_id` | VARCHAR(100) NULL | NULL | Appier PxGo Scenario ID |

---

### D2 — Domain: TemplateBlockGroupEntity

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `TemplateBlockGroupEntity` | 新增屬性 | `ProductSelectType` (int), `PxPayScenarioId` (string), `PxGoScenarioId` (string) |
| `TemplateBlockGroupEntity.CreateWithAppier()` | 新增靜態工廠 | 建立 Appier 模式 group；不設定 TemplateBlockProducts |
| `TemplateBlockGroupEntity.UpdateWithAppier()` | 新增方法 | 更新 ScenarioId；`ProductSelectType = 2` |
| `TemplateBlockGroupEntity.Update()` (現有) | 補充說明 | 切換回手動時，由 `SetGroupWithProduct()` 呼叫，需同時清除 `PxPayScenarioId` / `PxGoScenarioId`（domain method 內處理） |
| `TemplateEntity.SetGroupWithAppier()` | 新增方法 | 供 CommandHandler 呼叫；不呼叫 `SetGroupWithProduct()`；呼叫 `CreateWithAppier()` 或 `UpdateWithAppier()` |
| `SaveTemplateCommand.TemplateBlockGroupModel` | 新增欄位 | `ProductSelectType`, `PxPayScenarioId`, `PxGoScenarioId` |

**模式切換清理規則（domain 層保證）：**
- 手動 → Appier：`SetGroupWithAppier()` 不建立 `TemplateBlockProductEntity`（不影響現有商品資料，交由舊版索引自然過期）
- Appier → 手動：`SetGroupWithProduct()` 覆寫商品清單，同時 `PxPayScenarioId` / `PxGoScenarioId` 清為 null

---

### D3 — Infrastructure: EntityConfig

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `TemplateBlockGroupEntityConfig` | 新增欄位對應 | `product_select_type`, `px_pay_scenario_id`, `px_go_scenario_id` |

---

### D3b — Infrastructure: Cache

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| **新增** `AppierGroupIdCache` | Redis Hash | Key: `spu://pxbox.appier_group_ids`；Field: `TemplateGroupId`（string）；Value: JSON `{ PxPayScenarioId, PxGoScenarioId }`；無固定 expiry（由 Job 全量覆寫）；方法：`ExistsAsync(groupId)`, `GetAllAsync()` → `List<AppierTemplateGroupDto>`, `SetAllAsync(groups)`, `AddOrUpdateAsync(group)`, `RemoveAsync(groupId)` |
| **新增** `AppierTemplateGroupCache` | Redis String (JSON) | Key: `spu://pxbox.appier_template_group_products`；型別：`Dictionary<int, Dictionary<int, AppierProductDto>>`（TemplateGroupId → SystemSourceType → AppierProductDto）；Expiry: 15 min；方法：`GetAsync(templateGroupId, systemSourceType)`, `SetAsync(dict)` |

**AppierTemplateGroupDto / AppierProductDto 結構：**
```csharp
public class AppierTemplateGroupDto {
    public int TemplateGroupId { get; set; }
    public string PxPayScenarioId { get; set; }
    public string PxGoScenarioId { get; set; }
}

public class AppierProductDto {
    public List<int> ProductIds { get; set; }
}
```

---

### D4 — Application Command: SaveTemplateCommandHandler

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `CheckInputLogic()` - Products 區塊 group 驗證 | 邏輯修改 | `ProductSelectType == 2`：驗證 `PxPayScenarioId` 與 `PxGoScenarioId` 不可為空；`ProductSelectType == 0`：維持原本商品不為空驗證 |
| `SetBlockGroups()` - `case Products` | 邏輯修改 | `ProductSelectType == 2` → 呼叫 `template.SetGroupWithAppier(...)` ；`ProductSelectType == 0` → 原邏輯不動 |
| `Handle()` 存檔後 | 新增邏輯 | 遍歷所有 Products 區塊的 group：`ProductSelectType == 2` → `AppierGroupIdCache.AddOrUpdateAsync(group)`（含 ScenarioId）；`ProductSelectType != 2` → `AppierGroupIdCache.RemoveAsync(groupId)`（確保路由快取即時反映） |

---

### D5 — AppTemplateDto + RefreshTemplateCahceJob + RefreshTemplateCahceEventHandler

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `AppTemplateBlockGroup` | 新增欄位 | `ProductSelectType` (int) |
| `ITemplateQuery.GetAppTemplateByActiveAsync()` 對應 SQL | 新增欄位 | SELECT 加入 `tbg.product_select_type AS ProductSelectType` |
| `RefreshTemplateCahceJob.Run()` | 邏輯修改 | 建立 `TemplateElasticsearchDto.Groups` 時，過濾 `ProductSelectType == 2` 的 group；同時呼叫 `AppierGroupIdCache.SetAllAsync()` 全量覆寫（傳入含 ScenarioId 的 `List<AppierTemplateGroupDto>`） |
| `RefreshTemplateCahceEventHandler.GetTemplateGroupProductForElasticsearchDto()` | 邏輯修改 | 同上，`Groups` 過濾 Appier groups（`groupEntity.ProductSelectType == 2`），避免寫入空的 `product_marketings` 條目 |

---

### D6 — GetAppGroupProductListQuery + QueryHandler

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `GetAppGroupProductListQuery` | 新增欄位 | `SystemSourceType` (int, 預設 2 = PxPay) |
| `GetAppGroupProductListQueryHandler` | 路由邏輯 | 1. 呼叫 `AppTemplateDtoCache.GetCacheAsync(request.TemplateType, request.TopCategoryId, request.MidCategoryId, request.TemplateId)`（D9 新增欄位）取得樣板結構 <br/> 2. 從結構中找到對應 `TemplateGroupId` 的 group，讀取 `ProductSelectType` <br/> 3. `ProductSelectType == 2` → Appier path；否則 → 現有 ES Marketing path |
| Appier path | 新增邏輯 | `AppierTemplateGroupCache.GetAsync(groupId, systemSourceType)`；取前 24 筆 `SearchByIdsAsync()`；`TotalCount` = 實際商品數；不支援 filter；不分頁（最多 24 品）；cache 無資料 → 回傳空 list，**不 fallback** |
| 封閉賣場判斷 | 調整 | 原 PrivateSale check 改用同一次 `AppTemplateDtoCache` 讀取結果判斷，不重複呼叫；`TemplateType == 0` 時跳過（D9 結論） |

---

### D7 — Backend Detail: GetBackendTemplateDetailQueryHandler + TemplateBlockGroupDto

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `GetBackendTemplateDetailQueryHandler` 群組 SQL | 新增欄位 | SELECT 加入 `GRO.product_select_type`, `GRO.px_pay_scenario_id`, `GRO.px_go_scenario_id` |
| `TemplateBlockGroupDto` | 新增屬性 | `ProductSelectType`, `PxPayScenarioId`, `PxGoScenarioId` |

---

### D8 — New Job: RefreshAppierTemplateProductJob

| 項目 | 說明 |
| :--- | :--- |
| 執行頻率 | 每 5 分鐘 |
| 繼承 | `JobBase` |
| 注入 | `AppierGroupIdCache`, `AppierTemplateGroupCache`, `IAppierApiService`, `AppierSetting`, `IWebHostEnvironment` |
| **邏輯流程** | 1. 呼叫 `AppierGroupIdCache.GetAllAsync()` 取得所有有效的 Appier 模式 group（含 ScenarioId）；若清單為空則直接結束 |
| | 2. SIT/UAT env → 使用 hardcode product ID 清單（比照 `CuratingDtoCache` 模式） |
| | 3. Prod → 依序（bounded-sequential）對每個 group 呼叫 Appier API（PxPay + PxGo 各一次）；各取前 24 品 |
| | 4. 組成 `Dictionary<int, Dictionary<int, AppierProductDto>>` 寫入 `AppierTemplateGroupCache` |
| 並發控制 | Prod 模式下使用 `SemaphoreSlim` 限制同時呼叫數（建議上限 3）避免 rate limit |
| 部分失敗處理 | 單一 group 呼叫失敗 → log error，跳過該 group，不影響其他 group |

### D9 — GetAppGroupProductListQuery：修正 AppTemplateDtoCache 參數寫死問題

| 變動點 | 類型 | 說明 |
| :--- | :--- | :--- |
| `GetAppGroupProductListQuery` | 新增欄位 | `TemplateType` (int, 預設 0), `TopCategoryId` (int, 預設 0), `MidCategoryId` (int, 預設 0) |
| `GetAppGroupProductListQueryHandler` | 邏輯修正 | 封閉賣場判斷改為：若 `request.TemplateType == 0`（或任一必要欄位為 0）則跳過；否則以 `(request.TemplateType, request.TopCategoryId, request.MidCategoryId, request.TemplateId)` 呼叫 `AppTemplateDtoCache.GetCacheAsync()`，取代現有寫死的 `type=4` |

---

### Design 進度表

| 編號 | 項目 | 狀態 |
| :--- | :--- | :--- |
| D1 | DB Schema | Done |
| D2 | Domain: TemplateBlockGroupEntity | Done |
| D3 | Infrastructure: EntityConfig | Done |
| D3b | Infrastructure: Cache | Done |
| D4 | Application Command: SaveTemplateCommandHandler | Done |
| D5 | AppTemplateDto + RefreshTemplateCahceJob + RefreshTemplateCahceEventHandler | Done |
| D6 | GetAppGroupProductListQuery + QueryHandler | Done |
| D7 | Backend Detail: GetBackendTemplateDetailQueryHandler + TemplateBlockGroupDto | Done |
| D8 | New Job: RefreshAppierTemplateProductJob | Done |
| D9 | GetAppGroupProductListQuery：修正 AppTemplateDtoCache 參數寫死 | Done |

---

## Task

| ID | Task | 實作說明 | 對應 Design | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| T1 | DB Migration | 在 `template_block_groups` 新增 `product_select_type` TINYINT NOT NULL DEFAULT 0、`px_pay_scenario_id` VARCHAR(100) NULL、`px_go_scenario_id` VARCHAR(100) NULL | D1 | Pending |
| T2 | Domain: TemplateBlockGroupEntity | 新增 `ProductSelectType`, `PxPayScenarioId`, `PxGoScenarioId` 屬性；新增 `CreateWithAppier()` 靜態工廠、`UpdateWithAppier()` 方法；修改 `Update()` 切回手動時清除 ScenarioId | D2 | Pending |
| T3 | Domain: TemplateEntity | 新增 `SetGroupWithAppier()` 方法，呼叫 `CreateWithAppier()` 或 `UpdateWithAppier()`，不觸發 `SetGroupWithProduct()` | D2 | Pending |
| T4 | Infrastructure: EntityConfig | `TemplateBlockGroupEntityConfig` 新增 `product_select_type`, `px_pay_scenario_id`, `px_go_scenario_id` 欄位對應 | D3 | Pending |
| T5 | Infrastructure: AppierGroupIdCache | 新增 Redis Hash cache 類別；方法：`ExistsAsync`, `GetAllAsync`, `SetAllAsync`, `AddOrUpdateAsync`, `RemoveAsync` | D3b | Pending |
| T6 | Infrastructure: AppierTemplateGroupCache | 新增 Redis String (JSON) cache 類別；方法：`GetAsync(groupId, systemSourceType)`, `SetAsync(dict)` | D3b | Pending |
| T7 | DI 註冊 | 在 `Startup.cs` 註冊 `AppierGroupIdCache`, `AppierTemplateGroupCache` | D3b | Pending |
| T8 | Command: SaveTemplateCommandHandler | `CheckInputLogic()`：Appier 模式驗證 ScenarioId 非空；`SetBlockGroups()`：Appier 分支呼叫 `SetGroupWithAppier()`；`Handle()` 存檔後更新 `AppierGroupIdCache` | D4 | Pending |
| T9 | AppTemplateDto + SQL | `AppTemplateBlockGroup` 新增 `ProductSelectType`；對應 SQL 加入 `tbg.product_select_type` | D5 | Pending |
| T10 | RefreshTemplateCahceJob | 過濾 Appier groups 不寫入 Elasticsearch；呼叫 `AppierGroupIdCache.SetAllAsync()` 全量覆寫 | D5 | Pending |
| T11 | RefreshTemplateCahceEventHandler | `GetTemplateGroupProductForElasticsearchDto()` 同樣過濾 Appier groups | D5 | Pending |
| T12 | Backend Detail Query | `GetBackendTemplateDetailQueryHandler` SQL 加入三個新欄位；`TemplateBlockGroupDto` 新增對應屬性 | D7 | Pending |
| T13 | Fix AppTemplateDtoCache 參數 | `GetAppGroupProductListQuery` 新增 `TemplateType`, `TopCategoryId`, `MidCategoryId`；QueryHandler 修正 `GetCacheAsync()` 呼叫，TemplateType == 0 時跳過封閉賣場判斷 | D9 | Pending |
| T14 | GetAppGroupProductListQuery Appier 路由 | QueryHandler 讀取 `ProductSelectType`，`== 2` 走 Appier path：`AppierTemplateGroupCache.GetAsync()` → `SearchByIdsAsync()`；cache 無資料 → 回傳空 list | D6 | Pending |
| T15 | New Job: RefreshAppierTemplateProductJob | 繼承 `JobBase`；`AppierGroupIdCache.GetAllAsync()` 取 groups；SIT/UAT hardcode；Prod 以 `SemaphoreSlim(3)` 對每組呼叫 Appier API（PxPay + PxGo）；寫入 `AppierTemplateGroupCache` | D8 | Pending |
| T16 | 註冊 RefreshAppierTemplateProductJob | `Startup.cs` Coravel 排程，每 5 分鐘執行 | D8 | Pending |

### Task 進度表

| ID | Task | 狀態 |
| :--- | :--- | :--- |
| T1 | DB Migration | Pending |
| T2 | Domain: TemplateBlockGroupEntity | Pending |
| T3 | Domain: TemplateEntity | Pending |
| T4 | Infrastructure: EntityConfig | Pending |
| T5 | Infrastructure: AppierGroupIdCache | Pending |
| T6 | Infrastructure: AppierTemplateGroupCache | Pending |
| T7 | DI 註冊 (Cache) | Pending |
| T8 | Command: SaveTemplateCommandHandler | Pending |
| T9 | AppTemplateDto + SQL | Pending |
| T10 | RefreshTemplateCahceJob | Pending |
| T11 | RefreshTemplateCahceEventHandler | Pending |
| T12 | Backend Detail Query | Pending |
| T13 | Fix AppTemplateDtoCache 參數 | Pending |
| T14 | GetAppGroupProductListQuery Appier 路由 | Pending |
| T15 | New Job: RefreshAppierTemplateProductJob | Pending |
| T16 | 註冊 RefreshAppierTemplateProductJob | Pending |

---

## 進度表

| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R1 | Req | Done |
| P1 | Pre Design Sync | Done |
| D1 | Design | Done |
| T1 | Task | Review |
