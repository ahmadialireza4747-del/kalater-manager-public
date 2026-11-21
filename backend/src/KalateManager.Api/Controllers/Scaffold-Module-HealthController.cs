// backend/src/KalateManager.Api/Controllers/Scaffold-Module-HealthController.cs
// Foundation-System / Scaffold-Module: Exposes API-001 (GET /api/v1/health) for platform health verification and rate-limiter checks.

using KalateManager.Api.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace KalateManager.Api.Controllers;

[ApiController]
[Route("api/v1/health")]
public sealed class ScaffoldHealthController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _environment;

    public ScaffoldHealthController(
        IConfiguration configuration,
        IWebHostEnvironment environment)
    {
        _configuration = configuration;
        _environment = environment;
    }

    [HttpGet]
    [AllowAnonymous]
    [EnableRateLimiting("PublicApiPolicy")]
    [ProducesResponseType(typeof(HealthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiErrorResponse), StatusCodes.Status429TooManyRequests)]
    public ActionResult<HealthResponse> GetHealth()
    {
        var version = _configuration["PLATFORM_VERSION"] ?? "1.0.0";
        var response = new HealthResponse(
            Status: "Healthy",
            Service: "KalateManager.Api",
            Version: version,
            Environment: _environment.EnvironmentName,
            TimestampUtc: DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        );

        return Ok(response);
    }
}
