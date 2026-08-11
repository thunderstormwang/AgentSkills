<#
.SYNOPSIS
    將 Windows 使用者暫存資料夾中，一年以上未修改的檔案移到資源回收筒。

.DESCRIPTION
    預設清理目前使用者的 %LOCALAPPDATA%\Temp。

    若舊資料夾內的所有項目都早於日期門檻，腳本會將整個資料夾一次移到
    資源回收筒，以減少逐檔操作。含有較新項目的資料夾會保留，只有其中
    符合日期條件的檔案會逐一移到資源回收筒。

    符號連結及其他 Reparse Point 不會被處理，避免清理到暫存資料夾以外
    的位置。使用中的檔案、權限不足的項目也不會強制刪除。

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Scripts\Clean-Temp.ps1

    使用 Windows PowerShell 5.1 正式執行清理。

.EXAMPLE
    pwsh.exe -ExecutionPolicy Bypass -File .\Scripts\Clean-Temp.ps1

    使用 PowerShell 7 正式執行清理。
#>

[CmdletBinding()]
param(
    # 預設為目前登入使用者的 Windows 暫存資料夾。
    [Parameter()]
    [string]$Path = (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Temp'),

    # 項目最後修改時間必須早於這個年數，才會被處理。
    [Parameter()]
    [ValidateRange(1, 100)]
    [int]$OlderThanYears = 1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 沒有內建「移到資源回收筒」指令，
# 因此使用隨 Windows 提供的 Microsoft.VisualBasic 元件。
Add-Type -AssemblyName Microsoft.VisualBasic

$resolvedPath = (Resolve-Path -LiteralPath $Path).ProviderPath
$rootPath = [System.IO.Path]::GetPathRoot($resolvedPath)

# 防止誤把 C:\ 之類的磁碟根目錄當成清理目標。
if ($resolvedPath.TrimEnd('\') -eq $rootPath.TrimEnd('\')) {
    throw "拒絕清理磁碟根目錄：$resolvedPath"
}

if (-not (Test-Path -LiteralPath $resolvedPath -PathType Container)) {
    throw "指定的路徑不是資料夾：$resolvedPath"
}

$cutoff = (Get-Date).AddYears(-$OlderThanYears)

Write-Host "清理路徑：$resolvedPath"
Write-Host "日期門檻：$($cutoff.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host '執行模式：移到資源回收筒'
Write-Host ''

# 一次掃描所有項目，避免為每個資料夾重複遞迴搜尋。
$items = @(Get-ChildItem -LiteralPath $resolvedPath -Force -Recurse)

$directories = @(
    $items | Where-Object {
        $_.PSIsContainer -and
        -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
    }
)

$files = @(
    $items | Where-Object {
        -not $_.PSIsContainer -and
        $_.LastWriteTime -lt $cutoff -and
        -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
    }
)

# 若某個項目太新或是 Reparse Point，它本身所在的資料夾及所有上層
# 資料夾都不能整批移除。這個索引可快速找出安全的整批清理候選項目。
$unsafeDirectoryPaths = @{}
$rootPrefix = $resolvedPath.TrimEnd('\') + '\'

foreach ($item in $items) {
    $isReparsePoint = $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint

    if ($item.LastWriteTime -lt $cutoff -and -not $isReparsePoint) {
        continue
    }

    if ($item.PSIsContainer) {
        $currentDirectoryPath = $item.FullName
    }
    else {
        $currentDirectoryPath = $item.DirectoryName
    }

    while (
        $null -ne $currentDirectoryPath -and
        $currentDirectoryPath.StartsWith(
            $rootPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    ) {
        $unsafeDirectoryPaths[$currentDirectoryPath] = $true
        $parentDirectory = [System.IO.Directory]::GetParent($currentDirectoryPath)
        $currentDirectoryPath = if ($null -eq $parentDirectory) {
            $null
        }
        else {
            $parentDirectory.FullName
        }
    }
}

# 候選資料夾由淺到深處理。若上層已符合條件，就只需回收上層一次，
# 不必再為其中每一個子資料夾呼叫資源回收筒 API。
$batchDirectories = @()
$batchDirectoryPaths = @{}

foreach (
    $directory in (
        $directories |
            Where-Object {
                $_.LastWriteTime -lt $cutoff -and
                -not $unsafeDirectoryPaths.ContainsKey($_.FullName)
            } |
            Sort-Object -Property { $_.FullName.Length }
    )
) {
    $ancestor = $directory.Parent
    $isAlreadyCovered = $false

    while ($null -ne $ancestor -and $ancestor.FullName -ne $resolvedPath) {
        if ($batchDirectoryPaths.ContainsKey($ancestor.FullName)) {
            $isAlreadyCovered = $true
            break
        }

        $ancestor = $ancestor.Parent
    }

    if (-not $isAlreadyCovered) {
        $batchDirectories += $directory
        $batchDirectoryPaths[$directory.FullName] = $true
    }
}

$fileCount = 0
$batchDirectoryCount = 0
$emptyDirectoryCount = 0
$failureCount = 0
$recycledDirectoryPaths = @{}

# 優先整批回收完全過期的資料夾。若失敗，稍後仍會嘗試逐檔處理。
foreach ($directory in $batchDirectories) {
    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
            $directory.FullName,
            [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
            [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
        )

        $recycledDirectoryPaths[$directory.FullName] = $true
        $batchDirectoryCount++
    }
    catch {
        $failureCount++
        Write-Warning "無法整批處理資料夾：$($directory.FullName)；$($_.Exception.Message)"
    }
}

foreach ($file in $files) {
    $ancestorPath = $file.DirectoryName
    $isAlreadyRecycled = $false

    while (
        $null -ne $ancestorPath -and
        $ancestorPath.StartsWith(
            $rootPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    ) {
        if ($recycledDirectoryPaths.ContainsKey($ancestorPath)) {
            $isAlreadyRecycled = $true
            break
        }

        $parentDirectory = [System.IO.Directory]::GetParent($ancestorPath)
        $ancestorPath = if ($null -eq $parentDirectory) {
            $null
        }
        else {
            $parentDirectory.FullName
        }
    }

    if ($isAlreadyRecycled) {
        continue
    }

    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
            $file.FullName,
            [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
            [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
        )

        $fileCount++
    }
    catch {
        $failureCount++
        Write-Warning "無法處理檔案：$($file.FullName)；$($_.Exception.Message)"
    }
}

# 混合新舊內容的資料夾不能整批回收；逐檔處理後，再由深到淺移除
# 已經變空且本身也早於日期門檻的資料夾。
foreach (
    $directory in (
        $directories |
            Where-Object { $_.LastWriteTime -lt $cutoff } |
            Sort-Object -Property { $_.FullName.Length } -Descending
    )
) {
    $ancestor = $directory
    $isAlreadyRecycled = $false

    while ($null -ne $ancestor -and $ancestor.FullName -ne $resolvedPath) {
        if ($recycledDirectoryPaths.ContainsKey($ancestor.FullName)) {
            $isAlreadyRecycled = $true
            break
        }

        $ancestor = $ancestor.Parent
    }

    if ($isAlreadyRecycled -or -not (Test-Path -LiteralPath $directory.FullName)) {
        continue
    }

    try {
        $firstChild = Get-ChildItem -LiteralPath $directory.FullName -Force |
            Select-Object -First 1

        if ($null -ne $firstChild) {
            continue
        }

        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
            $directory.FullName,
            [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
            [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
        )

        $emptyDirectoryCount++
    }
    catch {
        $failureCount++
        Write-Warning "無法處理空資料夾：$($directory.FullName)；$($_.Exception.Message)"
    }
}

Write-Host ''
Write-Host (
    "處理完成：整批資料夾 $batchDirectoryCount 個，" +
    "個別檔案 $fileCount 個，空資料夾 $emptyDirectoryCount 個，" +
    "失敗 $failureCount 個。"
)
