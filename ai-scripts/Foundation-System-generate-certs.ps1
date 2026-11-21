# ai-scripts/Foundation-System-generate-certs.ps1
# Foundation-System / Scaffold-Module: Generates self-signed TLS certificates in git-ignored certs/ for 192.168.100.100 and localhost.

param(
    [string]$ProjectRoot = "D:\projeh\1-kalate-manager",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$certsDir = Join-Path -Path $ProjectRoot -ChildPath "certs"
$crtPath = Join-Path -Path $certsDir -ChildPath "kalate-dev.crt"
$keyPath = Join-Path -Path $certsDir -ChildPath "kalate-dev.key"

if (-not (Test-Path -Path $certsDir -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $certsDir | Out-Null
}

if ((Test-Path -Path $crtPath -PathType Leaf) -and (Test-Path -Path $keyPath -PathType Leaf) -and -not $Force) {
    Write-Host "[INFO] TLS certificates already exist in '$certsDir'. Use -Force to regenerate." -ForegroundColor Yellow
    exit 0
}

$opensslCmd = Get-Command openssl -ErrorAction SilentlyContinue
if ($null -ne $opensslCmd) {
    Write-Host "[INFO] Generating self-signed TLS certificate using local OpenSSL..." -ForegroundColor Cyan
    & openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
        -keyout "$keyPath" `
        -out "$crtPath" `
        -subj "/C=IR/ST=Dev/L=Local/O=KalateManager/CN=192.168.100.100" `
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:192.168.100.100"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: Local OpenSSL failed with exit code $LASTEXITCODE."
        exit 1
    }
}
else {
    Write-Host "[INFO] Local OpenSSL not found in PATH; using Dockerized alpine/openssl..." -ForegroundColor Cyan
    docker run --rm -v "${certsDir}:/certs" alpine/openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
        -keyout /certs/kalate-dev.key `
        -out /certs/kalate-dev.crt `
        -subj "/C=IR/ST=Dev/L=Local/O=KalateManager/CN=192.168.100.100" `
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:192.168.100.100"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: Dockerized alpine/openssl failed with exit code $LASTEXITCODE."
        exit 1
    }
}

if (-not (Test-Path -Path $crtPath) -or -not (Test-Path -Path $keyPath)) {
    Write-Error "ERROR: Certificate files were not created in '$certsDir'."
    exit 1
}

Write-Host "[OK] Self-signed TLS certificate created at '$crtPath' and '$keyPath'." -ForegroundColor Green
exit 0
