---
name: pxbox-conventions
description: 使用者公司 repo（repo 名稱以 PXBox 或 PXEC 開頭，不分大小寫）的團隊慣例與默會知識。涵蓋無法從程式碼本身推導出的事項，例如檔案語言規則與團隊實務作法。在該 session 首次操作此類 repo 時載入，須早於任何程式碼、文件、指令檔或 commit 的撰寫。
---

# PXBox / PXEC 公司慣例

適用於任何名稱以 `PXBox` 或 `PXEC` 開頭（不分大小寫）的 repo。

## 檔案語言

這些 repo 中專案層級的指令檔／skill 檔——`CLAUDE.md`、`.claude/skills/*/SKILL.md`、
`.github/copilot-instructions.md`——一律使用**繁體中文**撰寫，而非英文。

理由：語言應跟隨讀者，而非檔案所在位置。這些 repo 會與團隊成員共用，因此其指令檔屬於團隊
文件，若用英文撰寫會迫使每位成員在閱讀時都要翻譯一次。

此規則不適用於 `~/.claude/` 下的檔案——那些檔案仍依全域 CLAUDE.md 的預設維持英文。

## Git branch 對應環境

| Branch | 環境 |
| :--- | :--- |
| `main` | Prod |
| `release` | UAT |
| `develop` | SIT |

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

## 資料庫讀寫分離

Prod MySQL 採主從式架構：主要 DB 負責寫入，次要 DB 負責讀取。UAT 與 SIT 各自只有單一 DB（沒有
主從分離）。慣例是寫入走 EF Core 對主要 DB，讀取走 Dapper 對次要 DB。

## Redis 拓樸

Prod Redis 以 **3 節點 cluster** 運作（hash-slot 分片）。UAT 與 SIT 各自只有單一 Redis
instance（沒有 cluster，也沒有 slot）。部分 key 使用 `{...}` hash tag，讓相關 key 落在同一個
slot 上——在 UAT/SIT 上這個做法沒有任何效果，因為根本沒有 slot 路由這回事；key 就只是以一般
string 的形式存在那唯一的 instance 上。

## 發票開立：依子單改為依母單

系統最初是**依子單**開立發票：一張訂單拆成幾個子單，就開出幾張發票。後來遭國稅局警告——消費者
只付了一次款卻收到多張發票，與實際交易行為不符。因此在 2014/01 中旬修改系統，改為**依母單**
開立：一次付款對應一張發票。

- `PXBox.Invoice.Service` 已棄用，由 `PXBox.InvoiceUnifier.Service` 取代。
- 依子單開立的處理邏輯**只在訂單成立時被完全拔除**，因此新成立的訂單不會再走到；其餘位置的
  依子單邏輯都還留在程式庫中，而且仍會執行。

所以讀到依子單開立或處理發票的程式碼時：它是活的程式碼，不是死碼，但只有改版前成立的訂單才走
得到。不要把它當成現行行為，也不要假設它永遠不會被執行。
