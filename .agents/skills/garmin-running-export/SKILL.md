---
name: garmin-running-export
description: Retrieve a Garmin Connect running activity, report its standard running metrics and heart-rate zone durations, and download its lap CSV. Use this skill whenever the user asks to fetch, check, summarize, export, or download Garmin running data, including short requests such as "抓 Garmin 今天的資料", "Garmin 8/6", or "下載今天跑步紀錄". The user only needs to provide a date when it is not today; do not ask them to repeat the fields or output format.
compatibility: Windows or macOS, playwright-cli, Chrome, and an existing Garmin Connect storage-state file.
---

# Garmin Running Export

Use Playwright CLI to retrieve one running activity from Garmin Connect. Keep the workflow read-only except for downloading the requested lap CSV.

## Fixed configuration

- Garmin URL: `https://connect.garmin.com/`
- Storage state: `<home>/.playwright-cli/garmin-auth.json`
- Browser session name: `garmin`
- Default date: the user's current local date
- Activity type: running
- Destination: the current user's Downloads folder
- CSV filename: `YYYY-MM-DD_<activity-name>_分段.csv`

Treat the storage-state file as a credential. Never display, inspect, summarize, or transmit its contents.

## Required result

Report the activity summary on one line in this exact order:

```text
<distance>k / <average pace> min/km / <average heart rate> bpm / <maximum heart rate> bpm / <average cadence> spm
```

Report the non-zero heart-rate zones on the next line in ascending zone order, preserving Garmin's displayed durations and percentages rather than recalculating them:

```text
zone1 <duration> min(<percent>), zone2 <duration> min(<percent>), ...
```

Then report the absolute path of the downloaded CSV.

## Workflow

1. Resolve the target date.
   - Use the date supplied by the user.
   - If omitted, use the current local date from the conversation context.
   - Resolve relative dates such as today and yesterday before navigating.

2. Prepare authentication safely.
   - Detect whether the host is Windows or macOS before resolving paths or running shell commands.
   - Resolve `<home>` from the current user's home directory:
     - Windows PowerShell: `$HOME`, falling back to `$env:USERPROFILE` only when `$HOME` is unavailable.
     - macOS shell: `$HOME`.
   - Resolve the storage-state file as `<home>/.playwright-cli/garmin-auth.json`, using the platform's native path separator.
   - Confirm the resolved storage-state file exists.
   - Playwright CLI only reads files under its allowed working roots. Copy the state file to `<cwd>/.playwright-cli/garmin-auth.json`, using the platform's native path separator.
   - Reuse the copy only for this invocation and remove it when finished, including after a failed operation.
   - Never alter or remove the original state file.

3. Open Garmin Connect.
   - Close a stale `garmin` Playwright session if one exists.
   - Open Chrome in headless mode under the `garmin` session.
   - Load the temporary storage state, then navigate to `https://connect.garmin.com/modern/activities`.
   - If Garmin redirects to sign-in after loading the state, explain that the login expired. Open a headed session for the user to authenticate; do not request their password or verification code in chat.

4. Locate the activity.
   - Find the running activity whose local date matches the target date.
   - Open its activity detail page.
   - If there is no matching running activity, report that plainly and do not download another date.
   - If multiple running activities match, show their names and start times and ask the user to select one. Do not guess.

5. Extract the fixed metrics from the detail page:
   - Distance
   - Average pace
   - Average heart rate
   - Maximum heart rate
   - Average cadence
   Use values displayed in the activity details. Normalize only the unit labels for the required result; do not change precision or calculate substitute values.

6. Open the `區間持續時間` tab and extract the displayed heart-rate zones from zone 1 through zone 5.
   - Use heart-rate zones, not power zones.
   - Omit a zone when its displayed duration is `0:00` or its displayed percentage is `0%`.
   - Keep the remaining zones in ascending order without leaving placeholders for omitted zones.
   - Do not infer missing percentages from total activity time.

7. Download the lap CSV.
   - Open the activity toolbar's `更多...` gear menu.
   - Select `匯出分段資料的 CSV 檔案`.
   - Wait for the Playwright download event and save the file under the allowed working root first.
   - Resolve the destination according to the host:
     - Windows: read the Downloads known folder from
       `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders`
       value `{374DE290-123F-4565-9164-39C4925E467B}`.
     - macOS: use `$HOME/Downloads`.
   - Confirm the resolved Downloads directory exists before copying. Surface an error if it cannot be resolved rather than silently writing elsewhere.
   - Copy the file there using the fixed filename pattern. Replace filename-invalid characters in the activity name with `_`.
   - Confirm the destination file exists and has nonzero size before reporting success.

8. Clean up.
   - Close the `garmin` browser session.
   - Delete the temporary storage-state copy and any intermediate download.
   - Keep Playwright snapshots and console logs only when needed to diagnose a failure; otherwise remove files created by this invocation.

## Failure behavior

- Do not silently switch dates, activities, fields, or export formats.
- If a page label has changed, inspect the current accessible snapshot and locate the equivalent control by role and visible text.
- If CSV export fails, still return any metrics already verified, but state that the CSV was not downloaded.
- Never claim a download succeeded until the final destination file has been verified.

## Example

User:

```text
抓 Garmin 8/6
```

Response:

```text
6.37k / 5:34 min/km / 153 bpm / 170 bpm / 186 spm

zone1 3:59 min(11%), zone2 1:14 min(3%), zone3 10:27 min(29%), zone4 17:18 min(48%)

CSV：D:\Users\Roody_Wang\Downloads\2026-08-06_節奏跑_分段.csv
```
