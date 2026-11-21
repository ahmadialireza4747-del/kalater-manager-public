// backend/src/KalateManager.Api/Foundation-System-Program.cs
// Foundation-System / Scaffold-Module: Configures ASP.NET Core 8.0 host, Serilog structured logging, forwarded headers, CORS, two-layer Rate Limiting (D-011), standard error envelopes (D-018), and Swagger UI.

using System.Diagnostics;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using KalateManager.Api.Contracts;
using KalateManager.Api.Middleware;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Serilog;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog((context, services, configuration) => configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console());

    builder.Services.Configure<ForwardedHeadersOptions>(options =>
    {
        options.ForwardedHeaders =
            ForwardedHeaders.XForwardedFor |
            ForwardedHeaders.XForwardedProto |
            ForwardedHeaders.XForwardedHost;
        options.KnownNetworks.Clear();
        options.KnownProxies.Clear();
    });

    var allowedOriginsRaw = builder.Configuration["CORS_ALLOWED_ORIGINS"]
        ?? "https://192.168.100.100:50000,https://localhost:50000";
    var allowedOrigins = allowedOriginsRaw
        .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("KalateCorsPolicy", policy =>
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
    });

    var publicLimitPerMinute = int.TryParse(builder.Configuration["RATE_LIMIT_PUBLIC_PER_MINUTE"], out var pubLim)
        ? pubLim
        : 60;
    var authLimitPerMinute = int.TryParse(builder.Configuration["RATE_LIMIT_AUTH_PER_MINUTE"], out var authLim)
        ? authLim
        : 10;

    var jsonSerializerOptions = new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.Never
    };

    builder.Services.AddRateLimiter(options =>
    {
        options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

        options.AddPolicy("PublicApiPolicy", httpContext =>
        {
            var clientIp = httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            return RateLimitPartition.GetFixedWindowLimiter(
                partitionKey: $"public:{clientIp}",
                factory: _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = publicLimitPerMinute,
                    Window = TimeSpan.FromMinutes(1),
                    QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                    QueueLimit = 0
                });
        });

        options.AddPolicy("AuthStrictPolicy", httpContext =>
        {
            var clientIp = httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            return RateLimitPartition.GetFixedWindowLimiter(
                partitionKey: $"auth:{clientIp}",
                factory: _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = authLimitPerMinute,
                    Window = TimeSpan.FromMinutes(1),
                    QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                    QueueLimit = 0
                });
        });

        options.OnRejected = async (context, cancellationToken) =>
        {
            var traceId = Activity.Current?.Id ?? context.HttpContext.TraceIdentifier;
            context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.HttpContext.Response.ContentType = "application/json; charset=utf-8";

            var error = new ApiErrorResponse(
                ErrorCode: "RATE_LIMIT_EXCEEDED",
                Message: "Too many requests. Please retry after the rate limit window resets.",
                TraceId: traceId,
                ValidationErrors: null
            );

            await context.HttpContext.Response.WriteAsync(
                JsonSerializer.Serialize(error, jsonSerializerOptions),
                cancellationToken);
        };
    });

    builder.Services
        .AddControllers()
        .AddJsonOptions(opts =>
        {
            opts.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
            opts.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.Never;
        })
        .ConfigureApiBehaviorOptions(options =>
        {
            options.InvalidModelStateResponseFactory = context =>
            {
                var traceId = Activity.Current?.Id ?? context.HttpContext.TraceIdentifier;
                var validationErrors = context.ModelState
                    .Where(entry => entry.Value?.Errors.Count > 0)
                    .ToDictionary(
                        entry => string.IsNullOrEmpty(entry.Key)
                            ? "request"
                            : char.ToLowerInvariant(entry.Key[0]) + entry.Key[1..],
                        entry => entry.Value!.Errors
                            .Select(e => string.IsNullOrWhiteSpace(e.ErrorMessage) ? "VALIDATION_INVALID" : e.ErrorMessage)
                            .ToArray()
                    );

                var error = new ApiErrorResponse(
                    ErrorCode: "VALIDATION_FAILED",
                    Message: "One or more validation errors occurred.",
                    TraceId: traceId,
                    ValidationErrors: validationErrors
                );

                return new BadRequestObjectResult(error);
            };
        });

    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    var app = builder.Build();

    app.UseForwardedHeaders();
    app.UseMiddleware<FoundationExceptionMiddleware>();
    app.UseSerilogRequestLogging();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseCors("KalateCorsPolicy");
    app.UseRateLimiter();

    app.MapControllers();

    // Standard JSON 404 envelope for unmatched /api/* routes (D-018)
    app.Map("/api/{**catchAll}", (HttpContext context) =>
    {
        var traceId = Activity.Current?.Id ?? context.TraceIdentifier;
        var error = new ApiErrorResponse(
            ErrorCode: "RESOURCE_NOT_FOUND",
            Message: $"API route '{context.Request.Path}' was not found.",
            TraceId: traceId,
            ValidationErrors: null
        );
        return Results.NotFound(error);
    });

    Log.Information("KalateManager.Api starting in {Environment} environment", app.Environment.EnvironmentName);
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "KalateManager.Api terminated unexpectedly");
    throw;
}
finally
{
    Log.CloseAndFlush();
}
