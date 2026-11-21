// backend/src/KalateManager.Api/Middleware/Foundation-System-ExceptionMiddleware.cs
// Foundation-System / Scaffold-Module: Global exception handler converting unhandled errors into the standard ApiErrorResponse envelope with traceId correlation.

using System.Diagnostics;
using System.Net;
using System.Text.Json;
using KalateManager.Api.Contracts;

namespace KalateManager.Api.Middleware;

public sealed class FoundationExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<FoundationExceptionMiddleware> _logger;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.Never
    };

    public FoundationExceptionMiddleware(
        RequestDelegate next,
        ILogger<FoundationExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            var traceId = Activity.Current?.Id ?? context.TraceIdentifier;
            _logger.LogError(
                ex,
                "Unhandled exception in FoundationExceptionMiddleware at {Path} (TraceId: {TraceId})",
                context.Request.Path,
                traceId);

            if (context.Response.HasStarted)
            {
                throw;
            }

            context.Response.Clear();
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.ContentType = "application/json; charset=utf-8";

            var errorPayload = new ApiErrorResponse(
                ErrorCode: "INTERNAL_SERVER_ERROR",
                Message: "An unexpected internal server error occurred.",
                TraceId: traceId,
                ValidationErrors: null
            );

            await context.Response.WriteAsync(JsonSerializer.Serialize(errorPayload, JsonOptions));
        }
    }
}
