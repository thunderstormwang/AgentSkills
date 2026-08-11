<#
.SYNOPSIS
    將 Windows 使用者暫存資料夾中，一年以上未修改的檔案移到資源回收筒。

.DESCRIPTION
    預設清理目前使用者的 %LOCALAPPDATA%\Temp。

    腳本會先處理舊檔案，再由最深層開始處理舊資料夾。為避免誤刪仍含有
    新檔案的資料夾，只有「一年前就已存在且目前為空」的資料夾才會移到
    資源回收筒。

    捷徑、符號連結及其他 Reparse Point 不會被處理，避免清理到暫存資料夾
    以外的位置。使用中的檔案、權限不足的項目也不會強制刪除。

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Clean-Temp.ps1 -Preview

    使用 Windows PowerShell 5.1 預覽；不移動任何檔案或資料夾。

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Clean-Temp.ps1

    使用 Windows PowerShell 5.1 正式執行清理。

.EXAMPLE
    pwsh.exe -ExecutionPolicy Bypass -File .\Clean-Temp.ps1 -Preview

    使用 PowerShell 7 預覽；不移動任何檔案或資料夾。

.EXAMPLE
    pwsh.exe -ExecutionPolicy Bypass -File .\Clean-Temp.ps1

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
    [int]$OlderThanYears = 1,

    # 加上此參數時只顯示清單，不會移動任何項目。
    [Parameter()]
    [switch]$Preview
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
Write-Host "執行模式：$(if ($Preview) { '僅預覽' } else { '移到資源回收筒' })"
Write-Host ''

# 必須在刪除檔案前先記錄候選資料夾，因為增刪子項目可能改變資料夾的
# LastWriteTime。依完整路徑長度反向排序，可確保先處理最深層資料夾。
$directories = @(
    Get-ChildItem -LiteralPath $resolvedPath -Directory -Force -Recurse |
        Where-Object {
            $_.LastWriteTime -lt $cutoff -and
            -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        } |
        Sort-Object -Property { $_.FullName.Length } -Descending
)

$files = @(
    Get-ChildItem -LiteralPath $resolvedPath -File -Force -Recurse |
        Where-Object {
            $_.LastWriteTime -lt $cutoff -and
            -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        }
)

$fileCount = 0
$directoryCount = 0
$failureCount = 0
$previewRemovalPaths = @{}

foreach ($file in $files) {
    try {
        if ($Preview) {
            Write-Host "[預覽][檔案] $($file.FullName)"
            $previewRemovalPaths[$file.FullName] = $true
        }
        else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
                $file.FullName,
                [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
                [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
            )
        }

        $fileCount++
    }
    catch {
        $failureCount++
        Write-Warning "無法處理檔案：$($file.FullName)；$($_.Exception.Message)"
    }
}

foreach ($directory in $directories) {
    try {
        # 只移除已經為空的舊資料夾。若其中仍有新檔案、被鎖定的舊檔案，
        # 或不符合條件的子資料夾，便保留整個資料夾。
        if ($Preview) {
            # 預覽不會真的刪除檔案，因此把前面列出的項目視為已移除，
            # 才能正確預測清理後會變空的資料夾。
            $firstChild = Get-ChildItem -LiteralPath $directory.FullName -Force |
                Where-Object { -not $previewRemovalPaths.ContainsKey($_.FullName) } |
                Select-Object -First 1
        }
        else {
            $firstChild = Get-ChildItem -LiteralPath $directory.FullName -Force |
                Select-Object -First 1
        }

        if ($null -ne $firstChild) {
            continue
        }

        if ($Preview) {
            Write-Host "[預覽][資料夾] $($directory.FullName)"
            $previewRemovalPaths[$directory.FullName] = $true
        }
        else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
                $directory.FullName,
                [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
                [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
            )
        }

        $directoryCount++
    }
    catch {
        $failureCount++
        Write-Warning "無法處理資料夾：$($directory.FullName)；$($_.Exception.Message)"
    }
}

Write-Host ''
Write-Host "處理完成：檔案 $fileCount 個，空資料夾 $directoryCount 個，失敗 $failureCount 個。"

if ($Preview) {
    Write-Host '這次只是預覽；移除 -Preview 參數後才會正式執行。'
}
