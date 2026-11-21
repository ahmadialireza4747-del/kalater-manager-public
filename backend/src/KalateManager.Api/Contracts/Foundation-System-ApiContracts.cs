// backend/src/KalateManager.Api/Contracts/Foundation-System-ApiContracts.cs
// Foundation-System / Scaffold-Module: Standard API error envelope (D-018), pagination envelope, and Stage 001 health DTOs matching docs/09-API-CONTRACT.md.

using System.Text.Json.Serialization;

namespace KalateManager.Api.Contracts;

public sealed record ApiErrorResponse(
    [property: JsonPropertyName("errorCode")] string ErrorCode,
    [property: JsonPropertyName("message")] string Message,
    [property: JsonPropertyName("traceId")] string TraceId,
    [property: JsonPropertyName("validationErrors")] IDictionary<string, string[]>? ValidationErrors = null
);

public sealed record PagedResult<T>(
    [property: JsonPropertyName("items")] IReadOnlyList<T> Items,
    [property: JsonPropertyName("page")] int Page,
    [property: JsonPropertyName("pageSize")] int PageSize,
    [property: JsonPropertyName("totalCount")] int TotalCount,
    [property: JsonPropertyName("totalPages")] int TotalPages
);

public sealed record HealthResponse(
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("service")] string Service,
    [property: JsonPropertyName("version")] string Version,
    [property: JsonPropertyName("environment")] string Environment,
    [property: JsonPropertyName("timestampUtc")] string TimestampUtc
);
