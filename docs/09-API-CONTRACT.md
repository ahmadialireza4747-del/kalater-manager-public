# API Contract

## 1. CONVENTIONS

### 1.1 API Style, Base URL & Versioning (`D-016`)
- **Style:** RESTful JSON over HTTPS (HTTP port `50001` redirects to HTTPS port `50000` in Nginx).
- **Development Base URL:** `https://192.168.100.100:50000/api/v1` (also reachable via `https://localhost:50000/api/v1`).
- **Versioning Scheme:** Explicit URL path versioning (`/api/v1/...`). Breaking changes require either user-approved endpoint updates or a new `/api/v2/...` path.

### 1.2 Authentication & Hierarchical Authorization (`D-004`, `D-005`, `D-006`)
- **Identity Header:** `Authorization: Bearer <accessToken>`
- **Token Lifecycle:**
  - `accessToken`: Short-lived JWT (`30` minutes in dev), signed with `JWT_SECRET_KEY`, carrying `sub` (`userId`), `role`, `permVer` (`PermissionVersion`), and scope claims.
  - `refreshToken`: Opaque random token (`7` days in dev), stored hashed in PostgreSQL `RefreshTokens` table with single-use rotation on `POST /api/v1/auth/refresh`.
- **Roles:** Four fixed hierarchical tiers: `SuperAdmin`, `BaseManager`, `BranchManager`, `User`.
- **Permission & Scope Verification:**
  - `SuperAdmin` holds unrestricted platform-wide permissions and dynamically configures permissions for `BaseManager`, `BranchManager`, and `User` (`PermissionVersion` increments on every change, forcing token refresh/revalidation).
  - Tenant-scoped endpoints validate both the caller's granular permission key and organizational scope (`BaseId` -> `BranchId` -> `SiteId`), enforced at query level via EF Core Global Query Filters (`SiteId`).

### 1.3 Request & Response Format (`D-017`)
- **Content-Type:** `application/json; charset=utf-8`
- **Property Naming:** `camelCase` for all JSON request and response fields.
- **Identifier Format:** `UUID v4` strings (e.g., `"3fa85f64-5717-4562-b3fc-2c963f66afa6"`), mapped to `Guid` in C# and `uuid` in PostgreSQL.
- **Date & Time Format:** All timestamps are stored and transmitted in **UTC ISO 8601** format (e.g., `"2026-11-21T06:58:00Z"`). The frontend converts timestamps to **Jalali** calendar when UI language is Persian (`fa`) and **Gregorian** calendar when UI language is English (`en`).
- **Null & Missing Values:** Optional or empty fields are explicitly serialized as `null` (never omitted inconsistently).
- **Localization Rule:** The backend never returns translated UI prose for errors or system alerts. It returns stable `errorCode` / `titleKey` identifiers and structured `params`, which the React frontend translates using `fa` / `en` translation files. User-authored content is returned as stored.

### 1.4 Standard Error Response Envelope (`D-018`)
All `4xx` and `5xx` error responses return the following JSON envelope:
```json
{
  "errorCode": "AUTH_INVALID_CREDENTIALS",
  "message": "Invalid email or password.",
  "traceId": "0HN8K2L9P4Q1R:00000001",
  "validationErrors": {
    "email": ["VALIDATION_EMAIL_INVALID"]
  }
}
```
- `errorCode` (`string`, required): Stable machine-readable code mapped to frontend i18n keys.
- `message` (`string`, required): English technical description for developers and test scripts.
- `traceId` (`string`, required): Request correlation ID matching Serilog logs.
- `validationErrors` (`object | null`, optional): Map of `camelCase` field names to arrays of validation error codes.

### 1.5 Error Code List
*Error codes never change meaning once an endpoint reaches `VERIFIED`.*

| Error Code | HTTP Status | Meaning |
| :--- | :--- | :--- |
| `VALIDATION_FAILED` | `400` | One or more request fields failed validation (`validationErrors` populated) |
| `AUTH_INVALID_CREDENTIALS` | `401` | Email or password is incorrect |
| `AUTH_TOKEN_EXPIRED` | `401` | JWT access token has expired |
| `AUTH_TOKEN_INVALID` | `401` | JWT access token or refresh token is malformed, revoked, or reused |
| `AUTH_EMAIL_NOT_VERIFIED` | `403` | Account email address has not been verified yet |
| `AUTH_FORBIDDEN` | `403` | Authenticated user lacks required role permission or organizational scope |
| `RESOURCE_NOT_FOUND` | `404` | Requested entity (user, base, branch, site, plugin, domain) or route does not exist or is outside caller scope |
| `RESOURCE_CONFLICT` | `409` | Duplicate unique value (e.g., email, site slug, domain name, or already installed plugin) |
| `DOMAIN_VERIFICATION_FAILED` | `422` | Custom domain DNS TXT verification check failed |
| `PLUGIN_CONFIG_INVALID` | `422` | Submitted plugin configuration JSON does not satisfy `PluginConfigSchema` |
| `RATE_LIMIT_EXCEEDED` | `429` | Too many requests from client IP or authenticated user |
| `INTERNAL_SERVER_ERROR` | `500` | Unexpected unhandled server error (logged with `traceId`) |

### 1.6 Pagination, Sorting & Filtering (`D-018`)
- **Query Parameters:**
  - `page` (`int`, default `1`, minimum `1`)
  - `pageSize` (`int`, default `20`, minimum `1`, maximum `100`)
  - `sortBy` (`string`, optional, `camelCase` allowed field name)
  - `sortDir` (`string`, optional, `asc` or `desc`, default `desc`)
  - `search` (`string`, optional, trimmed substring filter)
- **Paginated Response Envelope:**
```json
{
  "items": [],
  "page": 1,
  "pageSize": 20,
  "totalCount": 0,
  "totalPages": 0
}
```

### 1.7 Rate Limiting, CORS & Custom Domain Headers (`D-009`, `D-011`)
- **Rate Limiting:** Two-layer enforcement via Nginx `limit_req_zone` and ASP.NET Core `AddRateLimiter` (strict IP fixed window on `/api/v1/auth/*`, IP/user fixed window on `/api/v1/*`). Exceeded limits return HTTP `429` with `RATE_LIMIT_EXCEEDED`.
- **CORS:** Configured via environment variables allowing `https://192.168.100.100:50000`, `https://localhost:50000`, and verified custom domains.
- **Tenant Resolution Headers:** Nginx forwards original `Host` via `X-Forwarded-Host`; clients may also pass `X-Site-Slug` when resolving a site under `/s/{siteSlug}`.

---

## 2. ENDPOINTS

### Foundation-System / Scaffold-Module

#### API-001: GET /api/v1/health
- **Purpose:** Returns platform API health status, service name, version, environment, and current UTC timestamp.
- **Feature / Stage:** `F-08` / `Stage 001`
- **Auth:** `public`
- **Request:** No headers, path params, query params, or body required.
- **Success response:** `200 OK`
  - `status` (`string`): Health status (`"Healthy"`)
  - `service` (`string`): Service identifier (`"KalateManager.Api"`)
  - `version` (`string`): Platform version string
  - `environment` (`string`): Active ASP.NET Core environment (`"Development"` / `"Production"`)
  - `timestampUtc` (`string`): Current UTC timestamp in ISO 8601 format
  ```json
  {
    "status": "Healthy",
    "service": "KalateManager.Api",
    "version": "1.0.0",
    "environment": "Development",
    "timestampUtc": "2026-11-21T07:30:00Z"
  }
  ```
- **Errors:**
  - `429` | `RATE_LIMIT_EXCEEDED` | Client IP exceeded public API rate limit window
  - `500` | `INTERNAL_SERVER_ERROR` | Unexpected unhandled server error
- **Notes:** Enforces `PublicApiPolicy` rate limiter (`D-011`). Used by reverse proxy verification and Stage 001 smoke test.
- **Status:** `IMPLEMENTED`
- **Test script:** `ai-scripts/Foundation-System-test.ps1`
- **Used by pages:** *(Infrastructure health check only)*

---

## 3. REAL-TIME EVENTS
*Not applicable — per Decision `D-013`, in-app notifications use REST + Smart Polling rather than WebSockets.*

---

## 4. PAGE-TO-ENDPOINT MAP
| Page or Popup | Endpoints / Events Used | Notes |
| :--- | :--- | :--- |
| *To be populated during Phase 1 / Phase 3 as UI designs are mapped* | | |

---

## 5. CONTRACT CHANGES
| Date | Endpoint / Event | What Changed | Breaking (yes/no) | Decision ID | Stage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 2026-11-21 | Section 1 (`CONVENTIONS`) | Defined REST `/api/v1` conventions, JWT+Refresh auth, UUID v4 + camelCase format, error envelope & initial error codes, and page/pageSize pagination | no | D-016, D-017, D-018 | Stage 000 |
| 2026-11-21 | `API-001` (`GET /api/v1/health`) | Added public health check endpoint specification (`IMPLEMENTED`) | no | D-011, D-016 | Stage 001 |
