# PXBOX-26599 Phase 2 — 重構與優化任務清單

此文件已簡化為純任務清單，直接由 `implementation-agent` 或 `implementation` 技能執行。

---

### Task 進度表

| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| T1 | TemplateElasticsearchDtoCache: 實作過期清理方法 | Todo |
| T2 | AppierTemplateGroupCache: 重構與邏輯集中化 (TTL/RefreshAsync) | Todo |
| T3 | Startup.cs: 更新 DI 注入 | Todo |
| T4 | RefreshAppierTemplateProductJob: 移除重複邏輯 (瘦身) | Todo |
| T5 | RefreshTemplateCahceEventHandler: 改呼叫 RefreshAsync | Todo |
| T6 | RefreshTemplateCahceJob: 實作原子更新與定時清理邏輯 | Todo |
| T7 | AppierTemplateGroupCache: 實作 L1 MemoryCache 層 (版本感知) | Todo |

---

### Task 實作細節

#### T1 — TemplateElasticsearchDtoCache: 實作過期清理方法
- **檔案**: `src/PXBox.Spu.Infrastructure/Cache/Template/TemplateElasticsearchDtoCache.cs`
- **內容**:
  - 新增 `public async Task RemoveExpiredTemplateIdsAsync()`
  - 邏輯: 遍歷 `_hasProductTemplateIdsKey` Set 中的 templateId，透過 `KeyExistsAsync` 檢查對應商品快取是否存在，不存在則移除。
- **驗證**: Build 通過。

#### T2 — AppierTemplateGroupCache: 重構與邏輯集中化 (TTL/RefreshAsync)
- **檔案**: `src/PXBox.Spu.API/Caches/Template/AppierTemplateGroupCache.cs`
- **內容**:
  - 注入 `AppierGroupIdCache`, `IAppierApiService` 與 `AppierSetting`。
  - `_ttl` 改為 2 小時。
  - 實作 `RefreshAsync()`: 集中處理 SIT/UAT hardcode 商品與 Prod API 呼叫邏輯。
  - 實作 `ExistsAsync(int templateGroupId)` 供清理邏輯使用。
- **驗證**: Build 通過。

#### T3 — Startup.cs: 更新 DI 注入
- **檔案**: `src/PXBox.Spu.API/Startup.cs`
- **內容**: 確保 `AppierTemplateGroupCache` 能正確透過 DI 解析新加入的依賴項。
- **驗證**: 啟動無 DI 解析錯誤。

#### T4 — RefreshAppierTemplateProductJob: 移除重複邏輯 (瘦身)
- **檔案**: `src/PXBox.Spu.API/Jobs/RefreshAppierTemplateProductJob.cs`
- **內容**: 移除所有商品組裝與 hardcode 邏輯，改為僅呼叫 `_appierTemplateGroupCache.RefreshAsync()`。
- **驗證**: Build 通過。

#### T5 — RefreshTemplateCahceEventHandler: 改呼叫 RefreshAsync
- **檔案**: `src/PXBox.Spu.API/Application/IntegrationEvents/EventHandling/RefreshTemplateCahceEventHandler.cs`
- **內容**: 移除 `IAppierApiService` 依賴，改呼叫 `_appierTemplateGroupCache.RefreshAsync()`。
- **驗證**: Build 通過。

#### T6 — RefreshTemplateCahceJob: 實作原子更新與定時清理邏輯
- **檔案**: `src/PXBox.Spu.API/Jobs/RefreshTemplateCahceJob.cs`
- **內容**:
  - 將 `SetAllAsync` 改為 `AddOrUpdateAsync` 以消除快取空窗期。
  - 在 Job 結尾依序執行 `CleanStaleAppierGroupsAsync()` 與 `CleanStaleTemplateIdsAsync()`。
- **驗證**: Build 通過，確認無空窗期。

#### T7 — AppierTemplateGroupCache: 實作 L1 MemoryCache 層 (版本感知)
- **檔案**: `src/PXBox.Spu.API/Caches/Template/AppierTemplateGroupCache.cs`
- **內容**:
  - Redis 儲存格式加入 `WrittenAt` timestamp。
  - `GetRecommendProductAsync` 優先讀取 L1 (30s TTL)。
  - 若 L1 到期則讀 Redis，若 Redis `WrittenAt` 未更新則沿用 L1 並延長 TTL，否則更新 L1。
  - 使用 `SemaphoreSlim` 防止 Thundering herd。
- **驗證**: 通過 L1 命中測試（不觸及 Redis）。
