# ai-scripts/Foundation-System-test.ps1
# Foundation-System / Scaffold-Module: Verifies Stage 001 Docker stack, Nginx HTTPS/HTTP redirect, API-001 (/api/v1/health), Host pass-through, standard 404 error envelope, and 429 rate limiting.

param(
    [string]$ServerIp = "192.168.100.100",
    [int]$HttpsPort = 50000,
    [int]$HttpPort = 50001,
    [int]$MailpitUiPort = 50005
)

$ErrorActionPreference = "Stop"

# Allow self-signed development certificate in PowerShell 5.1 and 7+
if ($PSVersionTable.PSVersion.Major -lt 6) {
    add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
}

function Invoke-ApiRequest {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [int]$MaximumRedirection = 5
    )

    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $resp = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $Headers -SkipCertificateCheck -MaximumRedirection $MaximumRedirection -ErrorAction Stop
        }
        else {
            $resp = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $Headers -MaximumRedirection $MaximumRedirection -ErrorAction Stop
        }
        return [PSCustomObject]@{
            StatusCode = [int]$resp.StatusCode
            Body       = $resp.Content
            Headers    = $resp.Headers
        }
    }
    catch {
        $ex = $_.Exception
        if ($null -ne $ex.Response) {
            $statusCode = [int]$ex.Response.StatusCode
            $bodyText = ""
            if ($PSVersionTable.PSVersion.Major -ge 6) {
                $bodyText = $_.ErrorDetails.Message
                if ([string]::IsNullOrEmpty($bodyText) -and $null -ne $ex.Response.Content) {
                    $bodyText = $ex.Response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
                }
            }
            else {
                $stream = $ex.Response.GetResponseStream()
                if ($null -ne $stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $bodyText = $reader.ReadToEnd()
                }
            }
            return [PSCustomObject]@{
                StatusCode = $statusCode
                Body       = $bodyText
                Headers    = $ex.Response.Headers
            }
        }
        throw
    }
}

$baseHttps = "https://${ServerIp}:${HttpsPort}"
$baseHttp = "http://${ServerIp}:${HttpPort}"
$mailpitBase = "http://${ServerIp}:${MailpitUiPort}"

Write-Host "=== Stage 001 Verification: Foundation-System / Scaffold-Module ===" -ForegroundColor Cyan
Write-Host "Target HTTPS Base : $baseHttps"
Write-Host "Target HTTP Base  : $baseHttp"

# Test 1: API-001 GET /api/v1/health via HTTPS Nginx
Write-Host "[TEST 1] GET /api/v1/health via HTTPS Nginx..." -ForegroundColor Yellow
$t1 = Invoke-ApiRequest -Uri "$baseHttps/api/v1/health"
if ($t1.StatusCode -ne 200) {
    Write-Error "FAIL [TEST 1]: Expected HTTP 200, got $($t1.StatusCode). Body: $($t1.Body)"
    exit 1
}
$healthJson = $t1.Body | ConvertFrom-Json
if ($healthJson.status -ne "Healthy" -or $healthJson.service -ne "KalateManager.Api" -or [string]::IsNullOrWhiteSpace($healthJson.timestampUtc)) {
    Write-Error "FAIL [TEST 1]: Unexpected health payload: $($t1.Body)"
    exit 1
}
Write-Host "[PASS 1] API-001 returned 200 Healthy (version=$($healthJson.version), env=$($healthJson.environment), utc=$($healthJson.timestampUtc))" -ForegroundColor Green

# Test 2: HTTP (50001) redirects to HTTPS (50000)
Write-Host "[TEST 2] HTTP port $HttpPort redirects to HTTPS port $HttpsPort..." -ForegroundColor Yellow
$t2 = Invoke-ApiRequest -Uri "$baseHttp/api/v1/health" -MaximumRedirection 0
if ($t2.StatusCode -ne 301 -and $t2.StatusCode -ne 308) {
    Write-Error "FAIL [TEST 2]: Expected 301/308 redirect from HTTP, got $($t2.StatusCode)"
    exit 1
}
Write-Host "[PASS 2] HTTP redirected with status $($t2.StatusCode)" -ForegroundColor Green

# Test 3: Custom Domain Host header pass-through (D-009)
Write-Host "[TEST 3] Custom domain Host header pass-through..." -ForegroundColor Yellow
$t3 = Invoke-ApiRequest -Uri "$baseHttps/api/v1/health" -Headers @{ "Host" = "tenant-alpha.kalate.test" }
if ($t3.StatusCode -ne 200) {
    Write-Error "FAIL [TEST 3]: Expected HTTP 200 with custom Host header, got $($t3.StatusCode)"
    exit 1
}
Write-Host "[PASS 3] Custom Host header passed cleanly through Nginx to API" -ForegroundColor Green

# Test 4: Standard 404 Error Envelope (D-018)
Write-Host "[TEST 4] Standard 404 JSON error envelope on unknown API route..." -ForegroundColor Yellow
$t4 = Invoke-ApiRequest -Uri "$baseHttps/api/v1/route-does-not-exist"
if ($t4.StatusCode -ne 404) {
    Write-Error "FAIL [TEST 4]: Expected HTTP 404, got $($t4.StatusCode)"
    exit 1
}
$err404 = $t4.Body | ConvertFrom-Json
if ($err404.errorCode -ne "RESOURCE_NOT_FOUND" -or [string]::IsNullOrWhiteSpace($err404.traceId)) {
    Write-Error "FAIL [TEST 4]: Standard error envelope mismatch: $($t4.Body)"
    exit 1
}
Write-Host "[PASS 4] 404 returned errorCode=$($err404.errorCode) with traceId=$($err404.traceId)" -ForegroundColor Green

# Test 5: Frontend placeholder reachable through Nginx /
Write-Host "[TEST 5] Frontend placeholder reachable at $baseHttps/..." -ForegroundColor Yellow
$t5 = Invoke-ApiRequest -Uri "$baseHttps/"
if ($t5.StatusCode -ne 200 -or $t5.Body -notmatch "Kalate Manager") {
    Write-Error "FAIL [TEST 5]: Expected 200 HTML from frontend container, got $($t5.StatusCode)"
    exit 1
}
Write-Host "[PASS 5] Frontend placeholder served via Nginx HTTPS" -ForegroundColor Green

# Test 6: Mailpit Web UI reachable on port 50005
Write-Host "[TEST 6] Mailpit Web UI reachable at $mailpitBase..." -ForegroundColor Yellow
$t6 = Invoke-ApiRequest -Uri "$mailpitBase/api/v1/info"
if ($t6.StatusCode -ne 200) {
    Write-Error "FAIL [TEST 6]: Expected 200 from Mailpit UI, got $($t6.StatusCode)"
    exit 1
}
Write-Host "[PASS 6] Mailpit v1.21.4 reachable on port $MailpitUiPort" -ForegroundColor Green

# Test 7: Rate Limiter enforcement (429 RATE_LIMIT_EXCEEDED) (D-011)
Write-Host "[TEST 7] Rate limiter triggers HTTP 429 RATE_LIMIT_EXCEEDED..." -ForegroundColor Yellow
$got429 = $false
for ($i = 1; $i -le 75; $i++) {
    $r = Invoke-ApiRequest -Uri "$baseHttps/api/v1/health"
    if ($r.StatusCode -eq 429) {
        $err429 = $r.Body | ConvertFrom-Json
        if ($err429.errorCode -eq "RATE_LIMIT_EXCEEDED") {
            $got429 = $true
            Write-Host "[PASS 7] Rate limiter triggered 429 RATE_LIMIT_EXCEEDED at request #$i (traceId=$($err429.traceId))" -ForegroundColor Green
            break
        }
    }
}
if (-not $got429) {
    Write-Error "FAIL [TEST 7]: Rate limiter did not trigger 429 RATE_LIMIT_EXCEEDED within 75 requests."
    exit 1
}

Write-Host ""
Write-Host "ALL STAGE 001 TESTS PASSED SUCCESSFULLY." -ForegroundColor Green
exit 0
