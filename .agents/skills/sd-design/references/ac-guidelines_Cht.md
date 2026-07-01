# AC / TC 撰寫指南

## AC 撰寫原則

  1. **每條 AC 對齊事實來源（source of truth）**：
     - **重構或擴充既有程式碼**：以現行程式碼為事實來源。撰寫每條 AC 前先 trace 相關程式碼路徑，反映實際行為。若程式碼有已知缺陷與規格不符，標 `⚠️ 已知缺陷：...` 並維持 AC 描述現行行為 —— 不要為了配合壞掉的程式碼而修改 AC。
     - **全新開發（greenfield）**：以 spec / PRD 為事實來源。AC 對齊 spec 語言，發現矛盾或漏洞要先讓使用者裁決再下筆。

  2. **一條 AC 只測一個 concern**：不要把多個測試重點（例如：混合價格 + 上限截斷邊界 + 平手規則）擠進同一條。寧可多寫幾條簡單的，每條 AC 應該只為一個原因 fail。

  3. **邊界值要有獨立 AC**：對每個條件分支，問自己：off-by-one 在哪？常見要明確覆蓋的邊界：
     - 相等 vs 嚴格大於（`>= threshold` vs `> limit`）
     - Stable sort 平手規則（多筆並列時的取捨）
     - 四捨五入到零讓某筆分配低於最小單位
     - 多輪分配：第一輪殘餘進入第二輪
     - 單筆下限保留（如「每件至少留 $1」）
     - 提早離開的分支（例如 `if (remainder == 0) break;`）

  4. **AC ID 用 `AC-{案型}-{序號}`，不用全域連續編號**：在單一案型中新增或刪除 AC 時，不應該影響其他案型的編號。案型前綴也可以當作測試類別 / 方法命名的提示（例如 `AC-滿件金-01` 對應到 `OrderQuantity_Money_NoCumulate_Test`）。

  5. **驗 observable behavior，不耦合 internal pipeline**：描述結果（達標 / 跳過 / 折扣）時，使用**外部可觀察的條件**（例如「首購商品 A 存在於購物車」），不要描述內部 pipeline 狀態（例如「checkItems 縮減後總件數 3」、「進入 CheckPromoteCondition 看到 itemQtyTotal=2」）。AC 應能在 pipeline 階段、helper 方法、或命名被重構後仍然有效。
     - 違反例：寫「總件數 3 ≥ 門檻 1 達標」，但 `3` 是 pipeline 前的件數，Handler 內部已把 `checkItems` 縮減為 2。改用觀察到的觸發條件（如「首購商品 A 存在於購物車 → 達標」），AC 才能在 `checkItems` 被移除/改名的重構中存活。

  6. **規則名稱必須對應 SPEC 1:1**：當 AC 描述觸發行為的規則時，使用 SPEC 中**規則的精確名稱**；不要把多個不同規則收斂成籠統術語。AC 標題與內容必須與底層欄位 / 規則一致。
     - 違反例：用「per-product 規則」描述實際是「買一送一首購商品排除規則」的行為 — 兩者的觸發條件與適用範圍不同（per-product 是同群組跨活動規則；買一送一首購排除是單一活動內的規則）。
     - 違反例：AC 標題「滿件滿額不適用商品排除」，但底層欄位是 `IsComboShipment`（組合商品）。標題應為「組合商品（IsComboShipment）排除」。

  7. **跨案型共用規則抽到章節序言**：同樣規則套用到多個 AC 章節時，在各章節序言一次說明；不要在每筆 AC 的 Then 段重複註記。
     - 例：「折數型 IsCumulate flag 不讀，但 CumulateLimit > 0 仍作單筆上限截斷」套用到 滿件折 / 滿額折 / 首購折 / 贈點百分比。在每個章節序言寫一次即可，AC 主體只需引用此規則，不需重新解釋。

  8. **AC 章節內不夾「📝 待釐清」段落**：AC 章節只能包含**最終、可執行的 AC 項目**。未敲定的事項處理方式：
     - 已釐清 → 改寫為具體的規則陳述
     - 未釐清 → 列入 Pre Design Sync 作為 Q 項目
     - 未來範圍 → 移到 plan.md（或相關 ticket）的 follow-up note，不放 AC 章節
     - AC 章節若出現 `📝 待釐清` 段落代表工作未完成，且 reviewer 容易直接跳過。

  9. **前提聲明放章節前文**：每個 AC 章節的前文必須聲明：
      - 本章 AC 假設的 spec / plan 前提（例如「本章假設輸入符合 plan.md L67 前提」）
      - **不需測試的違規組合 + 由誰擋住**（例如「人工+人工 由衝突檢核擋下、系統+系統 由 plan L67 擋下」），避免讀者誤以為要為這些組合寫測試。
      - 引用 source-of-truth 文件（例如：現況案型分析、新增案型分析）。
      - 這可防止讀者推論「違規組合需要被測試」，並把上游驗證的責任歸屬說清楚。

  10. **兩層 artifact 結構（高階 AC + 詳細 TC）**：當需求含非典型的計算規則時，將驗收標準拆成兩個獨立 artifact：

      **高階 AC**（`{topic}_ac.md`）：供 PM / stakeholder validate spec 的規則摘要。**主要讀者：PM** — 以平易的業務語言撰寫；避免類別 / 方法名稱、欄位名稱與實作術語；以功能性描述取代技術用詞（例如 "LINQ stable sort" →「依輸入順序取第一件」）；平手規則與排序方式明確以自然語言說明。**不含 Given/When/Then。**
      - 內容：規則陳述、公式（如 `折扣 = totalAmount × (100 − 折數) / 100`）
      - **不寫**具體數值、計算追蹤、商品攤提明細
      - ID 格式：`AC-{group}-N`（例如：`AC-現折-01`、`AC-贈點-01`）
      - 案型 heading 加 ID prefix（例如：`## AC-現折-01 訂單滿件 — 現折金額`）
      - 共用 fields 抽到頂層「共用欄位定義」，分子組（共通 / 案型群組）
      - 每個案型章節必須包含兩個子段：
        - **系統欄位定義**：將領域 / 中文欄位名稱對應到英文系統欄位名稱（例如：觸發上限 → `CumulateLimit`、折扣金額 → `DiscountAmount`）
        - **核心驗收標準**：構成 AC 主體的規則陳述（純中文，不含 Given/When/Then）
      - 主體一律使用純中文；英文欄位名稱僅出現在「系統欄位定義」中，規則陳述不夾雜英文技術名詞
      - 無 emoji；公式用 plain text（如 `floor(x / y)`）
      - 檔案超過 5 章節時，加目錄（TOC）

      **詳細實例化 TC（Spec by Example）**（`{topic}_tc_{layer}.md` — 可拆多檔）：**主要讀者：RD / QA / 單元測試撰寫者。必須使用 Given/When/Then 格式並附具體數值。禁止使用 `$X`、`$Y` 或「視設定而定」等占位符 — 若值依情境而異，拆成多筆具體 case。**
      - 內容：具體 Given/When/Then 含實際數值、計算追蹤、商品攤提明細
      - **Heading 格式：`{MethodUnderTest}_{Scenario}_{ExpectedBehavior}`**（例如：`Handle_MemberHasOldCard_DisablesOldCardAddsNewCardAndClearsCache`）— 可直接作為單元測試的方法名稱。Heading 下方緊接一行 blockquote（`> ...`）作為中文描述。
      - 開頭引用對應的 AC 章節（例如：「對應 AC-現折-01」）
      - **術語對照**：文件開頭加一張對照表，將領域術語映射到系統欄位名稱（例如：活動結果 → `DiscountPromotions`、達標 → `IsApplied = true`）。讓文件自給自足，AI 可直接生成測試程式碼，無需另查 spec。
      - **驗收欄位對照**：以短表格或列表說明 Then 段所斷言的可觀察輸出結構（例如：「活動結果（DiscountPromotion）：IsApplied、LackAmount、DiscountAmount」；「各商品折扣明細（DiscountDetail）：ProductId、DiscountAmount」）。避免測試斷言了錯誤欄位或遺漏欄位。

      **Cross-references**：
      - TC 檔頂部說明對應 AC 章節（AC 不需反向列出 TC 檔）
      - **規則變動時 MUST cross-check 既有 TC 是否衝突**（不要等 user 抓）

      **何時用單層 vs 兩層**：
      - 計算規則簡單、邊界 case 少 → 單層 AC 即可（Spec by Example 適度）
      - 計算規則含複雜算法、攤提、多 case → **必拆兩層**（PM 才看得懂 AC，工程師才能寫測試）

  11. **為共用元件補充回歸覆蓋（Regression coverage）**：當功能擴充或新增了共用計算邏輯時（例如：所有案型共用的 `AssignPromotionDiscount`），即使該方法本次未修改，仍需在 TC 文件中加入一個專屬的回歸 TC 章節，覆蓋共用方法的現行行為。這可防止未來的重構在不知不覺中破壞新功能 TC 未覆蓋的既有行為。
      - 位置：獨立 TC 章節（例如：`## 共用邏輯回歸 — AssignPromotionDiscount`），不與案型章節混在一起。
      - 範圍：覆蓋共用方法的可觀察合約（如：兩輪攤提、$1 下限、按比例分配）——不測試實作細節。
      - 判斷訊號：若共用方法在功能上線後仍無任何 TC 覆蓋，視為覆蓋缺口。
