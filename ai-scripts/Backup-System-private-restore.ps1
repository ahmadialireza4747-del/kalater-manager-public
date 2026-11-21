# ai-scripts/Backup-System-private-restore.ps1
# Backup-System / PrivateRestore-Module: Restores files from a private backup snapshot into a target directory with overwrite confirmation and database restore warnings.

param(
    [Parameter(Mandatory = $true)]
    [string]$SnapshotName,

    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [string]$BackupRoot = "D:\projeh\1-kalate-manager-backup",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "=== Kalate Manager Private Backup Restore ===" -ForegroundColor Cyan
$snapshotDir = Join-Path -Path $BackupRoot -ChildPath $SnapshotName

if (-not (Test-Path -Path $snapshotDir -PathType Container)) {
    Write-Error "ERROR: Snapshot directory not found at '$snapshotDir'."
    exit 1
}

if (-not (Test-Path -Path $TargetPath -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
    Write-Host "[INFO] Created target directory: $TargetPath" -ForegroundColor Gray
}

$resolvedSnapshot = (Resolve-Path -Path $snapshotDir).Path.TrimEnd('\')
$resolvedTarget = (Resolve-Path -Path $TargetPath).Path.TrimEnd('\')

$allFiles = Get-ChildItem -Path $resolvedSnapshot -Recurse -File | Where-Object {
    $_.Name -ne "MANIFEST.md"
}

$filesToRestore = New-Object System.Collections.Generic.List[object]
$existingTargets = New-Object System.Collections.Generic.List[string]
$dbDumps = New-Object System.Collections.Generic.List[string]

foreach ($file in $allFiles) {
    $relPath = $file.FullName.Substring($resolvedSnapshot.Length).TrimStart('\')
    if ($relPath.StartsWith("db\", [System.StringComparison]::OrdinalIgnoreCase)) {
        $dbDumps.Add($relPath)
    }
    $destPath = Join-Path -Path $resolvedTarget -ChildPath $relPath
    if (Test-Path -Path $destPath -PathType Leaf) {
        $existingTargets.Add($destPath)
    }
    $filesToRestore.Add([PSCustomObject]@{
        SourcePath   = $file.FullName
        RelativePath = $relPath
        DestPath     = $destPath
    })
}

if ($existingTargets.Count -gt 0 -and -not $Force) {
    Write-Host "[WARNING] The following existing files in '$resolvedTarget' will be overwritten:" -ForegroundColor Yellow
    foreach ($et in $existingTargets) {
        Write-Host "  - $et" -ForegroundColor Yellow
    }
    $confirm = Read-Host "Type YES to confirm overwriting these files"
    if ($confirm -ne "YES") {
        Write-Host "Restore cancelled by user. No files were modified." -ForegroundColor Cyan
        exit 0
    }
}

$restoredCount = 0
foreach ($item in $filesToRestore) {
    $destParent = Split-Path -Path $item.DestPath -Parent
    if (-not (Test-Path -Path $destParent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    }
    Copy-Item -Path $item.SourcePath -Destination $item.DestPath -Force
    Write-Host "[RESTORED] $($item.RelativePath) -> $($item.DestPath)" -ForegroundColor Green
    $restoredCount++
}

if ($dbDumps.Count -gt 0) {
    Write-Host ""
    Write-Host "[DATA-LOSS WARNING] Database dump file(s) were copied to '$resolvedTarget\db\'." -ForegroundColor Red
    Write-Host "Restoring a PostgreSQL dump into a running database will overwrite existing tables and data." -ForegroundColor Red
    Write-Host "Review docs/08-PROJECT-COMMANDS.md before running manual pg_restore." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Restore Summary ===" -ForegroundColor Cyan
Write-Host "Snapshot Restored : $SnapshotName"
Write-Host "Target Directory  : $resolvedTarget"
Write-Host "Restored Files    : $restoredCount" -ForegroundColor Green
exit 0
