# ai-scripts/Backup-System-private-backup.ps1
# Backup-System / PrivateBackup-Module: Creates immutable timestamped snapshots of git-ignored secrets, env files, TLS certificates, local volumes, and PostgreSQL dumps.

param(
    [string]$StageBranch = "000-project-setup",
    [string]$ProjectRoot = "D:\projeh\1-kalate-manager",
    [string]$BackupRoot = "D:\projeh\1-kalate-manager-backup"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Kalate Manager Private Backup ===" -ForegroundColor Cyan
Write-Host "Project Root : $ProjectRoot"
Write-Host "Backup Root  : $BackupRoot"
Write-Host "Stage Branch : $StageBranch"

if (-not (Test-Path -Path $ProjectRoot -PathType Container)) {
    Write-Error "ERROR: Project root directory not found at '$ProjectRoot'."
    exit 1
}

# Safety check: refuse if BackupRoot is inside ProjectRoot and not ignored by Git
$resolvedProject = (Resolve-Path -Path $ProjectRoot).Path.TrimEnd('\')
$fullBackupPath = [System.IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')

if ($fullBackupPath.StartsWith($resolvedProject + "\", [System.StringComparison]::OrdinalIgnoreCase) -or
    $fullBackupPath.Equals($resolvedProject, [System.StringComparison]::OrdinalIgnoreCase)) {
    $relativeBackup = $fullBackupPath.Substring($resolvedProject.Length).TrimStart('\')
    Push-Location $resolvedProject
    try {
        git check-ignore -q $relativeBackup 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "SECURITY REFUSAL: Backup path '$fullBackupPath' is inside '$resolvedProject' and is NOT ignored by .gitignore."
            exit 1
        }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path -Path $fullBackupPath -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $fullBackupPath | Out-Null
    Write-Host "[INFO] Created backup root directory: $fullBackupPath" -ForegroundColor Gray
}

$dateStamp = (Get-Date).ToString("yyyy-MM-dd")
$snapshotName = "${StageBranch}_${dateStamp}"
$snapshotDir = Join-Path -Path $fullBackupPath -ChildPath $snapshotName

if (Test-Path -Path $snapshotDir) {
    Write-Error "REFUSED: Snapshot folder '$snapshotDir' already exists. Existing snapshots are never overwritten."
    exit 1
}

New-Item -ItemType Directory -Force -Path $snapshotDir | Out-Null
Write-Host "[INFO] Created snapshot directory: $snapshotDir" -ForegroundColor Green

$copiedItems = New-Object System.Collections.Generic.List[object]
$skippedItems = New-Object System.Collections.Generic.List[string]
$failedItems = New-Object System.Collections.Generic.List[string]

function Copy-RelativeFile {
    param(
        [string]$RelativePath
    )
    $sourcePath = Join-Path -Path $resolvedProject -ChildPath $RelativePath
    if (-not (Test-Path -Path $sourcePath -PathType Leaf)) {
        Write-Host "[SKIP] Missing file: $sourcePath" -ForegroundColor Yellow
        $skippedItems.Add("$RelativePath (not present)")
        return
    }

    try {
        $destPath = Join-Path -Path $snapshotDir -ChildPath $RelativePath
        $destParent = Split-Path -Path $destPath -Parent
        if (-not (Test-Path -Path $destParent -PathType Container)) {
            New-Item -ItemType Directory -Force -Path $destParent | Out-Null
        }
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        $fileInfo = Get-Item -Path $destPath
        Write-Host "[COPIED] $RelativePath ($($fileInfo.Length) bytes)" -ForegroundColor Green
        $copiedItems.Add([PSCustomObject]@{
            RelativePath = $RelativePath.Replace('\', '/')
            SizeBytes    = $fileInfo.Length
            ModifiedUtc  = $fileInfo.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        })
    }
    catch {
        $errMsg = "$RelativePath -> $($_.Exception.Message)"
        Write-Host "[FAILED] $errMsg" -ForegroundColor Red
        $failedItems.Add($errMsg)
    }
}

function Copy-RelativeDirectory {
    param(
        [string]$RelativeDir
    )
    $sourceDir = Join-Path -Path $resolvedProject -ChildPath $RelativeDir
    if (-not (Test-Path -Path $sourceDir -PathType Container)) {
        Write-Host "[SKIP] Missing directory: $sourceDir" -ForegroundColor Yellow
        $skippedItems.Add("$RelativeDir/ (directory not present)")
        return
    }

    $files = Get-ChildItem -Path $sourceDir -Recurse -File
    if ($files.Count -eq 0) {
        Write-Host "[SKIP] Empty directory: $sourceDir" -ForegroundColor Yellow
        $skippedItems.Add("$RelativeDir/ (empty directory)")
        return
    }

    foreach ($f in $files) {
        $rel = $f.FullName.Substring($resolvedProject.Length).TrimStart('\')
        Copy-RelativeFile -RelativePath $rel
    }
}

# 1. Backup secrets file
Copy-RelativeFile -RelativePath "docs\07-DEV-SECRETS.md"

# 2. Backup real .env files (excluding .env.example)
$envFiles = Get-ChildItem -Path $resolvedProject -File -Filter ".env*" | Where-Object { $_.Name -ne ".env.example" }
if ($envFiles.Count -eq 0) {
    Write-Host "[SKIP] No active .env files found in $resolvedProject" -ForegroundColor Yellow
    $skippedItems.Add(".env* (no active .env files yet)")
}
else {
    foreach ($ef in $envFiles) {
        Copy-RelativeFile -RelativePath $ef.Name
    }
}

# 3. Backup local TLS certificates and persistent local volumes
Copy-RelativeDirectory -RelativeDir "certs"
Copy-RelativeDirectory -RelativeDir "storage"
Copy-RelativeDirectory -RelativeDir "uploads"

# 4. Backup PostgreSQL development database if container is running
$pgDb = "kalate_manager_dev"
$pgUser = "kalate_dev_user"
$dotEnvPath = Join-Path -Path $resolvedProject -ChildPath ".env"
if (Test-Path -Path $dotEnvPath -PathType Leaf) {
    foreach ($line in Get-Content -Path $dotEnvPath) {
        if ($line -match '^\s*POSTGRES_DB\s*=\s*(.+)\s*$') { $pgDb = $Matches[1].Trim() }
        if ($line -match '^\s*POSTGRES_USER\s*=\s*(.+)\s*$') { $pgUser = $Matches[1].Trim() }
    }
}

$pgContainer = $null
try {
    $runningContainers = docker ps --filter "status=running" --format "{{.Names}}" 2>$null
    if ($LASTEXITCODE -eq 0 -and $runningContainers) {
        $pgContainer = ($runningContainers | Where-Object { $_ -match "postgres" } | Select-Object -First 1)
    }
}
catch {
    $pgContainer = $null
}

if ([string]::IsNullOrWhiteSpace($pgContainer)) {
    Write-Host "[WARNING] PostgreSQL container is not running; skipping database dump." -ForegroundColor Yellow
    $skippedItems.Add("db/${pgDb}.dump (PostgreSQL container not running)")
}
else {
    try {
        $dbDir = Join-Path -Path $snapshotDir -ChildPath "db"
        New-Item -ItemType Directory -Force -Path $dbDir | Out-Null
        $dumpRelPath = "db/${pgDb}.dump"
        $dumpHostPath = Join-Path -Path $snapshotDir -ChildPath $dumpRelPath
        $containerTmpPath = "/tmp/${pgDb}_${dateStamp}.dump"

        docker exec $pgContainer pg_dump -U $pgUser -d $pgDb -F c -f $containerTmpPath
        if ($LASTEXITCODE -ne 0) {
            throw "pg_dump exited with code $LASTEXITCODE inside container '$pgContainer'."
        }

        docker cp "${pgContainer}:${containerTmpPath}" "$dumpHostPath"
        if ($LASTEXITCODE -ne 0) {
            throw "docker cp failed copying '$containerTmpPath' to '$dumpHostPath'."
        }

        docker exec $pgContainer rm -f $containerTmpPath 2>$null | Out-Null

        $dumpInfo = Get-Item -Path $dumpHostPath
        Write-Host "[COPIED] $dumpRelPath ($($dumpInfo.Length) bytes)" -ForegroundColor Green
        $copiedItems.Add([PSCustomObject]@{
            RelativePath = $dumpRelPath
            SizeBytes    = $dumpInfo.Length
            ModifiedUtc  = $dumpInfo.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        })
    }
    catch {
        $errMsg = "db/${pgDb}.dump -> $($_.Exception.Message)"
        Write-Host "[FAILED] $errMsg" -ForegroundColor Red
        $failedItems.Add($errMsg)
    }
}

# 5. Write MANIFEST.md (never contains secret values)
$manifestPath = Join-Path -Path $snapshotDir -ChildPath "MANIFEST.md"
$manifestLines = New-Object System.Collections.Generic.List[string]
$manifestLines.Add("# Private Backup Manifest")
$manifestLines.Add("")
$manifestLines.Add("- **Snapshot Name:** ``$snapshotName``")
$manifestLines.Add("- **Stage Branch:** ``$StageBranch``")
$manifestLines.Add("- **Created (UTC):** ``$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))``")
$manifestLines.Add("- **Copied File Count:** ``$($copiedItems.Count)``")
$manifestLines.Add("")
$manifestLines.Add("## Copied Files")
$manifestLines.Add("| Relative Path | Size (Bytes) | Last Modified (UTC) |")
$manifestLines.Add("| :--- | :--- | :--- |")
foreach ($item in $copiedItems) {
    $manifestLines.Add("| ``$($item.RelativePath)`` | $($item.SizeBytes) | $($item.ModifiedUtc) |")
}
$manifestLines.Add("")
$manifestLines.Add("## Skipped Items")
if ($skippedItems.Count -eq 0) {
    $manifestLines.Add("- None")
}
else {
    foreach ($s in $skippedItems) {
        $manifestLines.Add("- $s")
    }
}
$manifestLines.Add("")
$manifestLines.Add("## Failed Items")
if ($failedItems.Count -eq 0) {
    $manifestLines.Add("- None")
}
else {
    foreach ($f in $failedItems) {
        $manifestLines.Add("- $f")
    }
}

Set-Content -Path $manifestPath -Value $manifestLines -Encoding UTF8

# 6. Verify file count check
$actualFilesOnDisk = (Get-ChildItem -Path $snapshotDir -Recurse -File).Count
$expectedFilesOnDisk = $copiedItems.Count + 1 # +1 for MANIFEST.md

Write-Host ""
Write-Host "=== Backup Summary ===" -ForegroundColor Cyan
Write-Host "Snapshot Path       : $snapshotDir"
Write-Host "Copied Items        : $($copiedItems.Count)" -ForegroundColor Green
Write-Host "Skipped Items       : $($skippedItems.Count)" -ForegroundColor Yellow
Write-Host "Failed Items        : $($failedItems.Count)" -ForegroundColor $(if ($failedItems.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Disk File Check     : $actualFilesOnDisk actual vs $expectedFilesOnDisk expected (including MANIFEST.md)"

if ($failedItems.Count -gt 0 -or $actualFilesOnDisk -ne $expectedFilesOnDisk) {
    Write-Error "Backup completed with errors or file count mismatch."
    exit 1
}

Write-Host "Private backup completed successfully." -ForegroundColor Green
exit 0
