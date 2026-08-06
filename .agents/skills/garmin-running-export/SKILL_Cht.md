---
name: garmin-running-export
description: 從 Garmin Connect 取得跑步活動、回報標準跑步指標與心率區間持續時間，並下載分段 CSV。每當使用者要求取得、檢查、摘要、匯出或下載 Garmin 跑步資料時，都應使用此 Skill，包括「抓 Garmin 今天的資料」、「Garmin 8/6」或「下載今天跑步紀錄」等簡短要求。只有日期不是今天時，使用者才需要提供日期；不要要求使用者重複指定欄位或輸出格式。
compatibility: Windows 或 macOS、playwright-cli、Chrome，以及既有的 Garmin Connect 儲存狀態檔案。
---

# Garmin 跑步資料匯出

使用 Playwright CLI 從 Garmin Connect 取得一筆跑步活動。除了下載要求的分段 CSV 外，工作流程應保持唯讀。

## 固定設定

- Garmin 網址：`https://connect.garmin.com/`
- 儲存狀態：`<home>/.playwright-cli/garmin-auth.json`
- 瀏覽器工作階段名稱：`garmin`
- 預設日期：使用者目前的本機日期
- 活動類型：跑步
- 目的地：目前使用者的下載資料夾
- CSV 檔名：`YYYY-MM-DD_<activity-name>_分段.csv`

將儲存狀態檔案視為憑證。絕不顯示、檢查、摘要或傳送其內容。

## 必要結果

使用以下確切順序，將活動摘要回報於同一行：

```text
<distance>k / <average pace> min/km / <average heart rate> bpm / <maximum heart rate> bpm / <average cadence> spm
```

下一行依區間遞增順序回報非零心率區間，保留 Garmin 顯示的持續時間與百分比，不要重新計算：

```text
zone1 <duration> min(<percent>), zone2 <duration> min(<percent>), ...
```

接著回報下載之 CSV 的絕對路徑。

## 工作流程

1. 解析目標日期。
   - 使用使用者提供的日期。
   - 若未提供，使用對話內容中的目前本機日期。
   - 瀏覽前先解析今天、昨天等相對日期。

2. 安全地準備驗證資訊。
   - 解析路徑或執行 Shell 指令前，先偵測主機是 Windows 還是 macOS。
   - 從目前使用者的家目錄解析 `<home>`：
     - Windows PowerShell：使用 `$HOME`；僅在 `$HOME` 無法使用時，才改用 `$env:USERPROFILE`。
     - macOS Shell：使用 `$HOME`。
   - 將儲存狀態檔案解析為 `<home>/.playwright-cli/garmin-auth.json`，並使用平台原生的路徑分隔符號。
   - 確認解析後的儲存狀態檔案存在。
   - Playwright CLI 只能讀取允許之工作根目錄下的檔案。將狀態檔案複製到 `<cwd>/.playwright-cli/garmin-auth.json`，並使用平台原生的路徑分隔符號。
   - 此副本僅供本次執行使用，完成或操作失敗後都要刪除。
   - 絕不修改或刪除原始狀態檔案。

3. 開啟 Garmin Connect。
   - 若存在過期的 `garmin` Playwright 工作階段，先將其關閉。
   - 使用 `garmin` 工作階段，以無介面模式開啟 Chrome。
   - 載入暫存儲存狀態，接著前往 `https://connect.garmin.com/modern/activities`。
   - 若載入狀態後 Garmin 重新導向登入頁面，說明登入已過期。為使用者開啟有介面的工作階段以完成驗證；不要在聊天中要求使用者提供密碼或驗證碼。

4. 找出活動。
   - 尋找本機日期符合目標日期的跑步活動。
   - 開啟其活動詳細資料頁面。
   - 若找不到符合的跑步活動，清楚回報，且不要下載其他日期的活動。
   - 若有多筆符合的跑步活動，顯示其名稱與開始時間，並請使用者選擇。不要自行猜測。

5. 從詳細資料頁面擷取固定指標：
   - 距離
   - 平均配速
   - 平均心率
   - 最大心率
   - 平均步頻
   使用活動詳細資料中顯示的數值。僅針對必要結果統一單位標籤；不要變更精確度或計算替代數值。

6. 開啟 `區間持續時間` 分頁，擷取 zone 1 至 zone 5 顯示的心率區間。
   - 使用心率區間，不要使用功率區間。
   - 若區間顯示的持續時間是 `0:00`，或顯示的百分比是 `0%`，則略過該區間。
   - 其餘區間維持遞增順序，且不要為略過的區間保留預留位置。
   - 不要根據活動總時間推算缺少的百分比。

7. 下載分段 CSV。
   - 開啟活動工具列的 `更多...` 齒輪選單。
   - 選擇 `匯出分段資料的 CSV 檔案`。
   - 等待 Playwright 下載事件，並先將檔案儲存於允許的工作根目錄下。
   - 根據主機解析目的地：
     - Windows：從以下位置讀取 Downloads Known Folder：
       `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders`
       值 `{374DE290-123F-4565-9164-39C4925E467B}`。
     - macOS：使用 `$HOME/Downloads`。
   - 複製前先確認解析後的下載資料夾存在。若無法解析，應回報錯誤，不要在未告知的情況下寫入其他位置。
   - 使用固定檔名格式將檔案複製至該處。將活動名稱中不允許用於檔名的字元替換為 `_`。
   - 回報成功前，確認目的檔案存在且大小不為零。

8. 清理。
   - 關閉 `garmin` 瀏覽器工作階段。
   - 刪除暫存儲存狀態副本及任何中繼下載檔案。
   - 僅在診斷失敗時保留 Playwright 快照與 Console 記錄；否則刪除本次執行所建立的檔案。

## 失敗處理方式

- 不要在未告知的情況下切換日期、活動、欄位或匯出格式。
- 若頁面標籤已變更，檢查目前的無障礙快照，並透過角色及可見文字找出對應控制項。
- 若 CSV 匯出失敗，仍要回傳已驗證的指標，但需明確說明 CSV 未下載。
- 在確認最終目的檔案前，絕不宣稱下載成功。

## 範例

使用者：

```text
抓 Garmin 8/6
```

回應：

```text
6.37k / 5:34 min/km / 153 bpm / 170 bpm / 186 spm

zone1 3:59 min(11%), zone2 1:14 min(3%), zone3 10:27 min(29%), zone4 17:18 min(48%)

CSV：D:\Users\Roody_Wang\Downloads\2026-08-06_節奏跑_分段.csv
```
