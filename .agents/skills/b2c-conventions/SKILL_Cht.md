---
name: b2c-conventions
description: 使用者 B2C 電商系統的團隊慣例與默會知識——涵蓋任何名稱以 `PXBox` 或 `PXEC` 開頭（這個系統的兩條專案命名脈絡，不分大小寫）的 repo，也涵蓋只要對話中提到 B2C 本身（相對於 B2E 或 3PL 而言，使用者所屬的部門／系統）就該載入的情況，即使當下不在這類 repo 裡也一樣。B2C API gateway 防火牆異動、Redmine 申請內容或 API 開放需求也適用。涵蓋無法從程式碼推導出的事項——檔案語言規則、團隊實務作法，以及 PXEC 到 PXBox 的沿革。在該 session 首次接觸此類 repo，或首次談到 B2C 時載入，須早於任何程式碼、文件、指令檔或 commit 的撰寫。
---

# B2C 慣例

適用於任何名稱以 `PXBox` 或 `PXEC` 開頭（不分大小寫）的 repo，也適用於任何談到 B2C——使用者
所屬部門與系統——的討論，即使 session 當下並不在這類 repo 裡。

## 檔案語言

這些 repo 中專案層級的指令檔／skill 檔——`CLAUDE.md`、`.claude/skills/*/SKILL.md`、
`.github/copilot-instructions.md`——一律使用**繁體中文**撰寫，而非英文。

理由：語言應跟隨讀者，而非檔案所在位置。這些 repo 會與團隊成員共用，因此其指令檔屬於團隊
文件，若用英文撰寫會迫使每位成員在閱讀時都要翻譯一次。

此規則不適用於 `~/.claude/` 下的檔案——那些檔案仍依全域 CLAUDE.md 的預設維持英文。

## 公司與系統背景

全聯是總公司，全電商隸屬於全聯，是一套電商平台。全電商內含三個分屬不同部門的系統：

- **B2C**：使用者所屬部門，系統採微服務架構。
- **B2E**
- **3PL**

全聯旗下另有下列會與全電商協作、但不隸屬於全電商的單位與系統：

- **PXPay**：金流服務商。
- **全支付**：金流服務商。
- **資訊部**：負責帳務、會員資料與中介 DB。

## 沿革：PXEC 到 PXBox，以及 B2C／B2E／3PL 的拆分

這個電商平台原本是由 `PXEC` 開頭的專案組成，同樣採微服務架構。在 `PXEC` 還在積極開發的同時，
另外並行啟動了一條 `PXBox` 開頭的專案線——同樣是微服務，但架構較簡單、上線也較快。

後來為了加速開發，`PXEC` 停止開發，其職責拆成三塊——B2C、B2E、3PL——各自的去向不同：

- **B2C** 職責完全交給 `PXBox` 這條專案線，這就是為什麼使用者所屬的部門（B2C）現在實際運作的
  系統就是 `PXBox`。
- **B2E** 與 **3PL** 則分別由另外兩個團隊從無到有各自做出來。

所以 `PXBox` 跟 `PXEC` 不是同一套東西的新舊版本——它們是源自同一個原始平台、卻各自獨立的兩條
專案脈絡，而且只有 `PXBox` 延續了下來，承接了 `PXEC` 原本屬於 B2C 的那一份職責。

## 部署環境對應

環境變數值有大小寫之分，請使用表中所列的全小寫值。

| 環境 | Branch | 環境變數值 |
| :--- | :--- | :--- |
| Prod | `main` | `prod` |
| UAT | `release` | `uat` |
| SIT | `develop` | `sit` |

## API 路由前綴

路由格式為 `<prefix>/<version>/<service name>/<name>`，其中 `<service name>` 是該 endpoint 所屬的
微服務。前綴代表呼叫方是誰：

| Prefix | 呼叫方 |
| :--- | :--- |
| `app` | 前台（面向顧客）畫面 |
| `backend` | 後台（內部管理）畫面 |
| `service` | 其他後端微服務 |

`<service name>` 多半取自專案名稱 `PXBox.<Name>.Service`，將 `<Name>` 轉為全小寫並以底線
分隔單字：

| 專案 | `<service name>` |
| :--- | :--- |
| `PXBox.Spu.Service` | `spu` |
| `PXBox.Coupon.Service` | `coupon` |
| `PXBox.ShoppingCart.Service` | `shopping_cart` |
| `PXBox.MarketingOperate.Service` | `marketing_operate` |

## API HTTP 方法

API endpoint 只使用 `GET` 與 `POST`。唯讀操作使用 `GET`；新增、更新、刪除或其他會改變狀態的
操作使用 `POST`。不要新增 `PUT`、`PATCH` 或 `DELETE` endpoint。

## API gateway 防火牆申請

B2C 的 `app` 與 `backend` API 對外開放，需要調整防火牆；`service` API 供其他後端服務呼叫，
不需要調整防火牆。使用者手動提出 Redmine 申請；主管核准後，Infra 才會調整防火牆。
提醒使用者在 Redmine 下拉選單選擇：

- **專案**：`PXEC 系統與設備維運需求`
- **追蹤標籤**：`網路設備異動`

使用者要求準備申請時，檢視指定範圍內實際的 API 異動，產出可直接貼到 Redmine 的主旨與
Markdown 概述。區分新增與刪除的路由，並將 `service` 路由排除於防火牆申請。依現有證據核對每筆
method、完整路由、授權及功能用意。需要但尚未確認的資訊，包括適用環境、JIRA、開發人員或授權，
應詢問使用者；不可從範例推定或悄悄猜填。**Infra設定編號**未知時留空。
`SIT、UAT、UAT2、PROD` 是範例，不是每次申請的預設值。不要代使用者提交申請。

使用以下主旨與概述格式，將佔位符替換為已核實的值。主旨若包含數量，應與表格列數一致。
刪除時若適用，保留使用者指定的刪除原因，以及 Infra 從未設定過的 API 應跳過的說明；
不要假設每次刪除都有此條件。

**主旨——新增：** `B2C(全電商):ApiGateway - <微服務> 增加 <數量> 支 API`

**主旨——刪除：** `B2C(全電商):ApiGateway - <微服務> 刪除 API`

**概述：**

```markdown
微服務： <微服務>
新增／刪除以下 API
環境： <適用環境>

<刪除原因及未設定時的處理方式，僅在適用時填寫>

| Method | Route | Authorization | Infra設定編號 | JIRA | 開發人員 | 功能用意 |
|--------|-------|---------------|--------------|------|---------|---------|
| <GET 或 POST> | <完整路由> | <授權> | <設定編號，未知留空> | <票號> | <開發人員> | <功能用意> |
```

應選擇 `新增` 或 `刪除`，不要保留合併的佔位文字。按微服務與操作分組各列，讓主旨與概述的內容
一致。

## 資料庫讀寫分離

Prod MySQL 採主從式架構：主要 DB 負責寫入，次要 DB 負責讀取。UAT 與 SIT 各自只有單一 DB（沒有
主從分離）。慣例是寫入走 EF Core 對主要 DB，讀取走 Dapper 對次要 DB。

## Redis 拓樸

Prod Redis 以 **3 節點 cluster** 運作（hash-slot 分片）。UAT 與 SIT 各自只有單一 Redis
instance（沒有 cluster，也沒有 slot）。部分 key 使用 `{...}` hash tag，讓相關 key 落在同一個
slot 上——在 UAT/SIT 上這個做法沒有任何效果，因為根本沒有 slot 路由這回事；key 就只是以一般
string 的形式存在那唯一的 instance 上。

現有的 Master／Replica 讀取分流是刻意保留的設計：它能分散讀取負載，避免所有流量集中在 Master。
應保留這項分流，而不是只因 Replica 可能延遲，就將所有讀取改走 Master。若特定路徑需要強一致，
應在該路徑明確優先讀取 Master，而不改變所有讀取的預設行為。

## Kafka consumer group 識別

訂閱 Kafka 事件時，底層共用套件 `PXGo.EventBus` 以 **EventHandler** 的完整類別名稱決定 consumer
group 名稱：`{namespace}.{class name}`，即 `{命名空間}.{類別名稱}`。使用的是 handler 型別，而非
事件型別。

EventHandler 上線後若更改命名空間或類別名稱，其 consumer group 也會改變。
新 group 不會沿用舊 group 已提交的 offset；依共用套件的消費行為，會從 offset 0 開始重播事件
（若較早的紀錄已過期刪除，則從仍保留的最早 offset 開始）。

這類更名應視為消費行為的變更，而不只是單純的名稱整理，並須考量重播已處理事件所帶來的影響。

## Kafka 訂閱進度

訂閱同一 topic 的不同 EventHandler 對應不同 consumer group，各自維護已提交的 offset。
即使 topic 只有一個 partition，該 partition 內的訊息順序也不會同步各 group 的進度，亦不保證
不同 handler 之間的處理順序。

合併或移除 handler 時，應比較新舊 group 的識別與消費進度，以辨識可能漏掉或重播的事件。
topic 與 partition 數量不變，不代表訂閱的處理進度會被保留。

## 查詢服務 log

每個 B2C 服務都透過 NLog 把 log 寫進同一個共用的 log 叢集 `prod-log-es`——名稱中的 `prod` 是沿用
下來的歷史名稱；SIT、UAT 與 Prod 都寫進這個叢集，只以 index 區分：
`log-backend-{sit|uat|prod}-yyyy.MM.dd`。

- **這個叢集是 OpenSearch 2.15，不是 Elasticsearch。** `GET /` 回報的 `version.number` 是
  `7.10.2`，因為為了 Elastic 用戶端開啟了相容設定（NLog 使用 `Elastic.NLog.Targets`）；從
  tagline（`The OpenSearch Project`）與 `lucene_version`（`9.10.0`）可以看出真身。團隊仍然習慣稱它為「ES」。
- **優先使用 `opensearch-log` MCP server。** 它是官方的 `opensearch-mcp-server-py`
  （固定 `==0.12.0`，透過 `uvx` 執行），註冊在 user scope，指向下方的叢集，
  帳密取自 `${OSD_USER}`／`${OSD_PASS}`。只啟用三個唯讀工具——`SearchIndexTool`（每次呼叫最多
  100 筆）、`CountTool` 與 `MsearchTool`；三者都在使用者的 `permissions.allow` 中，因此**即使查詢
  Prod 的 index** 也不會跳出確認——下方的 Prod 規則是唯一的防線。其搜尋工具的說明要求先讀
  mapping；忽略這點，改以 HTTP 呼叫 `_field_caps`（見下方）。
  - 它啟動需要 16–23 秒（Python 載入大型套件，而非網路），因此使用者的設定中設了
    `MCP_TIMEOUT=60000`。若 session 回報 `opensearch-log` 以 `CONNECT_TIMEOUT` 連線失敗，
    此 session 改用 HTTP 並告知使用者；重開 session 通常即可解決。執行 `uv cache clean` 會刪除
    它的快取環境，下次啟動會重新下載，可能逾時一次。
- **在 MCP server 無法使用時，或要呼叫它沒有提供的 API（`_field_caps`）時，改以 HTTP 呼叫叢集
  API**：`http://prod-log-es-01.pxec.com.tw:9200`（`02` 與 `03` 是同一個叢集的節點），
  使用 HTTP Basic 認證——需在公司網路或 VPN 上。不要透過 OpenSearch Dashboards：過去透過
  Dashboards 以瀏覽器查詢曾把它的流量打爆，這正是團隊改為直接打 API 的原因（PXBOX-28776）。
  基於同樣的理由，查詢要壓小：先 `_count` 再 `_search`、`size` 要有上限，`_source` 只取需要的欄位。
- **帳密是使用者本人的 Dashboards 登入帳號**，存放在使用者環境變數 `OSD_USER`／`OSD_PASS`；
  同一組帳號可直接用於 9200 port。在指令中以 `$env:OSD_USER`／`$env:OSD_PASS` 引用；絕不印出，
  也不要請使用者貼上。權限與使用者本人相同：`GET /`、`_search`、`_count` 與 `_field_caps` 可用；
  `_cat/indices` 與 `_mapping` 會回 403。各 repo nlog 設定裡的 `backend_log` 帳密是用來寫入 log 的——
  不要拿來查詢。
- **連線檢查：** 不帶帳密執行 `curl.exe -v -sS --noproxy "*" --max-time 15
  http://prod-log-es-01.pxec.com.tw:9200/`，應幾乎立即回傳 `401 Unauthorized`
  （`Basic realm="OpenSearch Security"`）——401 代表叢集連得到。若 curl 顯示 `Connected` 與
  `Request completely sent off`，之後卻以收到 0 byte 逾時，那次發生（2026-11-20）的問題出在使用者
  本機——不是防火牆規則，因為同一時間、同一個 VPN 網段的同事拿到了 401，而且 infra 確認 VPN 規則
  不會依使用者而不同。重新連線 VPN 或重新開機即解決。
- **僅作為備案——Dashboards 的 Dev Tools 代轉端點**，在 9200 port 連不到且使用者同意使用時：
  ```
  POST https://prod-log-es-kibana.pxec.com.tw/api/console/proxy?path=<URL 編碼後的叢集路徑>&method=<GET|POST>
  Authorization: Basic <user:pass>
  osd-xsrf: true
  ```
  `path` 是在 Dev Tools 中會輸入的路徑，其中 `/` 要編碼為 `%2F`（例如
  `log-backend-sit-*%2F_search`，`?`／`=` 則編碼為 `%3F`／`%3D`）；request body 原樣傳遞。
- **以 `_field_caps` 而非 `_mapping` 查詢有哪些欄位**：`GET <index>/_field_caps?fields=*`
  會回傳每個欄位的名稱與型別。查詢尚未用過的
  欄位前先查一次——欄位來自許多服務，且每天不同。回應中有只差在大小寫的 key（例如 `labels.Date`
  與 `labels.date`），因此在 PowerShell 中要以 `ConvertFrom-Json -AsHashtable` 解析。
- **以 `service.name.keyword` 篩選服務**，其值為專案名稱，例如 `PXBox.Coupon.API`。text 欄位無法
  排序或聚合——請改用其 `.keyword` 子欄位。其他實用欄位：`@timestamp`、`log.level.keyword`、
  `log.logger.keyword`、`message`、`trace.id.keyword`（跨服務的同一個請求），以及 `error.type`／
  `error.message`／`error.stack_trace`。
- **結構化 log 的參數會成為欄位。** 像 `LogInformation("... {ProductId}", id)` 這種訊息範本寫法，
  每個參數都會存成 `labels.<Name>`（例如 `labels.ProductIds`、`labels.BatchId`），可精確篩選；
  未代入參數的範本則保留在 `MessageTemplate.keyword`，可用來統計同一句 log 出現的次數。字串插值
  寫法（`$"..."`）只會產生 `message`，因此要以 `match_phrase` 搜尋 `message`。
- 一律加上 `@timestamp` 範圍——index 是每天一個，不設範圍的查詢會掃過每一天。
- 發生錯誤時，回應會對每個 shard 重複同一個錯誤；只讀 `error.root_cause[0]`。
- **只查詢 SIT 與 UAT。** 只有在使用者明確要求時才查詢 Prod 的 index——其中可能含有會員資料。
- **顯示任何 log 文字前先遮蔽個資。** 原始 `message` 與記錄下來的 request／response 內容可能含有
  會員姓名、電話號碼、Email、地址、生日與 LINE UID——多數在 Prod，但 SIT／UAT 的測試資料也可能是
  真實資料。印出結果前先遮蔽這些欄位，且絕不放進回覆、Jira 或 commit。

## 發票開立：依子單改為依母單

系統最初是**依子單**開立發票：一張訂單拆成幾個子單，就開出幾張發票。後來遭國稅局警告——消費者
只付了一次款卻收到多張發票，與實際交易行為不符。因此在 2024/01 中旬修改系統，改為**依母單**
開立：一次付款對應一張發票。

- `PXBox.Invoice.Service` 已棄用，由 `PXBox.InvoiceUnifier.Service` 取代。
- 依子單開立的處理邏輯**只在訂單成立時被完全拔除**，因此新成立的訂單不會再走到；其餘位置的
  依子單邏輯都還留在程式庫中，而且仍會執行。

所以讀到依子單開立或處理發票的程式碼時：它是活的程式碼，不是死碼，但只有改版前成立的訂單才走
得到。不要把它當成現行行為，也不要假設它永遠不會被執行。
