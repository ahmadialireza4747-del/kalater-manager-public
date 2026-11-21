# ai-scripts/Foundation-System-init-env.ps1
# Foundation-System / Scaffold-Module: Initializes git-ignored .env from .env.example with generated development secrets and records them in docs/07-DEV-SECRETS.md.

param(
    [string]$ProjectRoot = "D:\projeh\1-kalate-manager",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$envExamplePath = Join-Path -Path $ProjectRoot -ChildPath ".env.example"
$envPath = Join-Path -Path $ProjectRoot -ChildPath ".env"
$secretsDocPath = Join-Path -Path $ProjectRoot -ChildPath "docs\07-DEV-SECRETS.md"

if (-not (Test-Path -Path $envExamplePath -PathType Leaf)) {
    Write-Error "ERROR: .env.example not found at '$envExamplePath'."
    exit 1
}

if ((Test-Path -Path $envPath -PathType Leaf) -and -not $Force) {
    Write-Host "[INFO] .env already exists at '$envPath'. Use -Force to regenerate." -ForegroundColor Yellow
    exit 0
}

function New-RandomSecret {
    param([int]$Length = 40)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $bytes = New-Object byte[] $Length
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $sb = New-Object System.Text.StringBuilder
    foreach ($b in $bytes) {
        [void]$sb.Append($chars[$b % $chars.Length])
    }
    return $sb.ToString()
}

$devDbPassword = "KalateDevDb_" + (New-RandomSecret -Length 20)
$devJwtSecret = "KalateDevJwt_" + (New-RandomSecret -Length 48)

$content = Get-Content -Path $envExamplePath -Raw
$content = $content.Replace("CHANGE_ME_DEV_DB_PASSWORD", $devDbPassword)
$content = $content.Replace("CHANGE_ME_DEV_JWT_SECRET_AT_LEAST_32_CHARS_LONG", $devJwtSecret)

Set-Content -Path $envPath -Value $content -Encoding UTF8
Write-Host "[OK] Created git-ignored .env at '$envPath'." -ForegroundColor Green

$secretsContent = @(
    "# Development Secrets & Credentials (GIT-IGNORED)"
    ""
    "> **WARNING:** Development values only — must be replaced with strong production secrets before Phase 4 deployment."
    ""
    "| Name | Value | Used In | Environment Variable |"
    "| :--- | :--- | :--- | :--- |"
    "| PostgreSQL Dev Password | ``$devDbPassword`` | PostgreSQL 16.6 container & ASP.NET Core connection string | ``POSTGRES_PASSWORD`` |"
    "| JWT Signing Secret Key | ``$devJwtSecret`` | ASP.NET Core JWT Bearer signing & validation | ``JWT_SECRET_KEY`` |"
)

Set-Content -Path $secretsDocPath -Value $secretsContent -Encoding UTF8
Write-Host "[OK] Updated git-ignored docs/07-DEV-SECRETS.md." -ForegroundColor Green
Write-Host "REMINDER: Development values only, must be changed before production." -ForegroundColor Yellow
exit 0
