# Project Stages & Plan

## 1. CURRENT POSITION
- **Current Phase:** Phase 1 — Backend (Transitioning from completed Stage 000 Project Setup)
- **Active System / Module / Stage:** Stage 000 — `Project-Setup` (`000-project-setup`) is `DONE`; awaiting user execution of Stage 000 Git commit/push, initial Private Backup, and Test Restore before starting Stage 001 (`Foundation-System / Scaffold-Module / docker-nginx-api-skeleton`).
- **NEXT STEP:** Run the Stage 000 Git commands (`000-project-setup`), run `ai-scripts/Backup-System-private-backup.ps1`, run a test restore of that snapshot into a temporary folder using `ai-scripts/Backup-System-private-restore.ps1`, and paste the outputs so Stage 001 can begin.

## 2. FEATURES
| ID | Name | Description | Priority | Status |
| :--- | :--- | :--- | :--- | :--- |
| F-01 | User Authentication & Account Lifecycle | Registration, email/password login, email verification, and password reset flow | MUST | DECIDED |
| F-02 | Hierarchical RBAC & Dynamic Permission Control | Four-tier role system (Super Admin, Base Manager, Branch Manager, User) where Super Admin dynamically manages and modifies permissions of all other roles | MUST | DECIDED |
| F-03 | Multi-Site / Multi-Tenant Management | Users and managers can create, configure, and manage independent sites/systems within the platform | MUST | DECIDED |
| F-04 | Plugin & Module Catalog & Engine | Platform catalog of modules/plugins that can be browsed, installed, activated/deactivated, and removed per site | MUST | DECIDED |
| F-05 | Per-Site Plugin Configuration | Isolated configuration and settings management for each installed plugin/module on a specific site | MUST | DECIDED |
| F-06 | Custom Domain Mapping | Ability to bind and configure custom domains for user-created sites (Host-header routing in dev; full DNS/TLS in Phase 4) | MUST | DECIDED |
| F-07 | Security Audit Logs | Automated logging of sensitive actions (role permission changes, plugin installs/removals, site creation, failed logins) | MUST | DECIDED |
| F-08 | API & Auth Rate Limiting | Request throttling to protect authentication endpoints and APIs against brute-force and abuse | MUST | DECIDED |
| F-09 | System Email Notifications | Automated transactional emails for account verification, password resets, invitations, and system alerts via SMTP/Mailpit | MUST | DECIDED |
| F-10 | In-App Notifications | Notification center inside the dashboard for site, plugin, and role events | MUST | DECIDED |
| F-11 | Analytics & Overview Dashboard | Summary metrics and health overview of sites, active plugins, users, and recent activity for Super Admin and site managers | MUST | DECIDED |
| F-12 | User Profile, Theme & Localization Settings | Profile management, password change, runtime Light/Dark theme switching, and bilingual Persian RTL / English LTR with Jalali/Gregorian dates | MUST | DECIDED |

## 3. DECISIONS
| ID | Date | Related Feature/System | Question | Options Offered | User Choice | Reason | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| D-001 | 2026-11-21 | Version Control / Setup | Version control verification and branching strategy | Git with one numbered branch per completed stage | Git (`git version 2.55.0.windows.5`) with remote `origin` (`https://github.com/ahmadialireza4747-del/kalater-manager-public.git`) and numbered stage branches | Verified active Git repository and GitHub remote | ACTIVE |
| D-002 | 2026-11-21 | Private Backup / Setup | Where to store git-ignored private backups and whether to keep off-machine copies | A: Folder next to project on same drive (`D:\projeh\1-kalate-manager-backup`); B: Separate/external drive; C: Git-ignored folder inside project root | Option A (`D:\projeh\1-kalate-manager-backup`) with no off-machine backup | User selected external folder on `D:` drive, confirmed folder exists, and stated off-machine backup is not needed | ACTIVE |
| D-003 | 2026-11-21 | Workflow / Delivery | How files and code updates are delivered by assistant | Chat snippets, ZIP archive matching project structure, Git patches | ZIP archive matching exact project folder structure (`D:\projeh\1-kalate-manager\`) for direct copy/replace, paired with local Git commands | Assistant cannot push directly to user GitHub remote; ZIP archive allows clean drop-in replacement | ACTIVE |
| D-004 | 2026-11-21 | F-01 / Authentication | Authentication and session management strategy | A: Short-lived JWT Access Token + PostgreSQL-backed Refresh Token with rotation; B: Server-side cookie sessions; C: Stateless JWT only | Option A (JWT Access Token + PostgreSQL Refresh Token with rotation) | Supports Nginx reverse proxy, future desktop/mobile apps, immediate session revocation upon role/permission changes, and pinned JwtBearer 8.0.11 | ACTIVE |
| D-005 | 2026-11-21 | F-02 / Authorization & RBAC | Role hierarchy and dynamic permission control architecture | A: Granular Permission Matrix with hierarchical scope (Super Admin -> Base -> Branch -> User) and PermissionVersion tracking; B: Flat global RBAC without organizational scope; C: Full ABAC with unlimited custom roles | Option A (Granular Permission Matrix with hierarchical scope and PermissionVersion tracking) | Enables Super Admin to dynamically modify permissions of Base Manager, Branch Manager, and User roles while isolating data across bases, branches, and sites | ACTIVE |
| D-006 | 2026-11-21 | F-03 / Multi-Site Architecture | Database and tenant isolation model for user-created sites | A: Shared PostgreSQL database & schema with `SiteId` row-level isolation and EF Core Global Query Filters; B: Separate PostgreSQL schema per site; C: Separate PostgreSQL database per site | Option A (Shared database/schema with `SiteId` isolation and EF Core Global Query Filters) | Aligns with hierarchical Base/Branch scope (D-005), simplifies EF Core migrations and plugin installation, and keeps container resource usage low | ACTIVE |
| D-007 | 2026-11-21 | F-04 / Plugin Engine | Architecture for platform plugins and modules | A: In-process modular contract (`IPlatformPlugin` in C# + React module registry) with built-in starter modules; B: Dynamic runtime `.dll` / external JS bundle loading; C: Metadata toggle flags only | Option A (In-process modular contract `IPlatformPlugin` + React module registry + built-in starter modules) | Guarantees container security, deterministic EF Core migrations, seamless permission integration (D-005), and genuine modular functionality | ACTIVE |
| D-008 | 2026-11-21 | F-05 / Per-Site Plugin Configuration | Storage, schema definition, and validation strategy for per-site plugin settings | A: Plugin-defined `PluginConfigSchema` + PostgreSQL `JSONB` column in `SitePlugins` with server-side validation; B: Relational string Key-Value table; C: Dedicated PostgreSQL table per plugin | Option A (`PluginConfigSchema` + PostgreSQL `JSONB` in `SitePlugins` with server-side validation) | Enables dynamic plugin settings without per-plugin schema migrations, leverages PostgreSQL 16.6 JSONB via Npgsql 8.0.11, and enforces strict server validation | ACTIVE |
| D-009 | 2026-11-21 | F-06 / Custom Domain Mapping | Custom domain routing and ownership verification mechanism | A: Dynamic `Host` header resolution middleware in ASP.NET Core + Nginx default pass-through + DNS TXT verification token; B: Dynamic per-domain Nginx config generation and reload; C: Metadata-only storage until Phase 4 | Option A (Dynamic `Host` header resolution middleware + Nginx default pass-through + DNS TXT verification) | Avoids reloading Nginx or exposing Docker control sockets while enabling real Host-based site resolution in dev and Phase 4 SSL readiness | ACTIVE |
| D-010 | 2026-11-21 | F-07 / Security Audit Logs | Audit log storage and querying architecture | A: Dedicated `AuditLogs` table in PostgreSQL with `JSONB` before/after snapshots + concurrent Serilog structured logging; B: Rotating JSON log files only via Serilog; C: PostgreSQL PL/pgSQL CDC triggers on all tables | Option A (Dedicated `AuditLogs` PostgreSQL table + concurrent Serilog structured logging) | Enables searchable, scope-filtered audit history in dashboards (F-11) using existing PostgreSQL 16.6 and Serilog 8.0.3 with zero new dependencies | ACTIVE |
| D-011 | 2026-11-21 | F-08 / API & Auth Rate Limiting | Request throttling and brute-force protection strategy | A: Two-layer rate limiting combining .NET 8 built-in `AddRateLimiter` (IP-based on auth, UserId-based on API) + Nginx `limit_req_zone`; B: Nginx `limit_req_zone` only; C: Distributed rate limiting via Redis container | Option A (Two-layer .NET 8 `AddRateLimiter` + Nginx `limit_req_zone`) | Provides per-user and per-IP policies plus standardized JSON `429` error codes without adding Redis or extra NuGet packages | ACTIVE |
| D-012 | 2026-11-21 | F-09 / System Email Notifications | Transactional email delivery and queue architecture | A: PostgreSQL `EmailOutbox` table + .NET 8 `BackgroundService` + native `SmtpClient` (Mailpit in dev); B: Synchronous direct SMTP send inside HTTP requests; C: External broker (RabbitMQ/Redis + Hangfire) | Option A (PostgreSQL `EmailOutbox` + .NET 8 `BackgroundService` + native `SmtpClient`) | Non-blocking API responses, automatic retries, delivery status tracking, and zero extra containers or NuGet packages | ACTIVE |
| D-013 | 2026-11-21 | F-10 / In-App Notifications | In-app notification storage and client delivery mechanism | A: PostgreSQL `Notifications` table with i18n keys + Smart Polling in React; B: Real-time WebSockets via ASP.NET Core SignalR; C: Manual fetch only on bell click | Option A (PostgreSQL `Notifications` table with i18n keys + Smart Polling in React) | Avoids WebSocket/Nginx custom-domain upgrade complexity, uses zero new packages, and supports bilingual rendering | ACTIVE |
| D-014 | 2026-11-21 | F-11 / Analytics & Overview Dashboard | Dashboard metrics computation and caching strategy | A: Scope-aware real-time SQL aggregations in EF Core with short-lived `IMemoryCache`; B: Pre-aggregated daily/hourly rollup tables via background job; C: Client-side aggregation in browser | Option A (Scope-aware real-time SQL aggregations in EF Core + `IMemoryCache`) | Delivers live, role-scoped metrics (D-005/D-006) with zero extra database tables or NuGet packages | ACTIVE |
| D-015 | 2026-11-21 | F-12 / Profile, Theme & Localization | Persistence and synchronization of user language, theme, and calendar preferences | A: Hybrid persistence (PostgreSQL user profile columns + instant `localStorage` mirror + `i18next` & CSS tokens); B: Browser `localStorage` only; C: HTTP cookie with full-page reload | Option A (PostgreSQL persistence + instant `localStorage` mirror + `i18next` & CSS tokens) | Prevents flash of wrong theme/RTL on load, persists across devices, and informs backend email templates (D-012) of preferred language | ACTIVE |
| D-016 | 2026-11-21 | API Contract / Conventions | API communication style and URL versioning scheme | A: RESTful JSON API with URL path versioning (`/api/v1/...`); B: RESTful JSON with `X-Api-Version` header; C: GraphQL (`/graphql`) | Option A (RESTful JSON API with `/api/v1/...` URL versioning) | Simple Nginx routing, clean Swagger/PowerShell testing, and explicit non-breaking version evolution | ACTIVE |
| D-017 | 2026-11-21 | API Contract / Conventions | Resource ID format, JSON property casing, and null representation | A: `UUID v4` (`Guid`) IDs + `camelCase` JSON properties + explicit `null`; B: `BIGINT` sequential IDs + `camelCase`; C: `UUID v4` + `snake_case` | Option A (`UUID v4` IDs + `camelCase` JSON + explicit `null`) | Prevents sequential ID enumeration, aligns natively with ASP.NET Core and TypeScript, and keeps null semantics explicit | ACTIVE |
| D-018 | 2026-11-21 | API Contract / Conventions | Standard error envelope and list pagination format | A: Machine-readable `errorCode` + `traceId` + `validationErrors` envelope and page-number pagination (`page`, `pageSize`, `totalCount`, `totalPages`); B: RFC 7807 `ProblemDetails` + cursor pagination; C: Minimal `{ error }` without pagination | Option A (Machine-readable `errorCode` + `traceId` + `validationErrors` and page-number pagination) | Enables bilingual error translation in React (`F-12`), Serilog log correlation via `traceId`, and direct page jumps in admin tables | ACTIVE |

## 4. PHASES / SYSTEMS / MODULES / STAGES

### Setup Stage
- **Stage 000 — `Project-Setup` (`000-project-setup`)**
  - **Feature Traceability:** `F-01` through `F-12`, `D-001` through `D-018`
  - **Scope:** Complete project documentation baseline, Git & private backup setup, feature discovery, architecture decisions, API conventions, and phased stage breakdown.
  - **Status:** `DONE`

---

### Phase 1: Backend (ASP.NET Core 8.0 + PostgreSQL 16.6 + Docker + Nginx + Mailpit)

#### System 1: `Foundation-System` (Platform Infrastructure, Proxy & Core Database)
- **Module 1.1: `Scaffold-Module`**
  - **Stage 001 — `Foundation-System / Scaffold-Module / docker-nginx-api-skeleton`**
    - **Feature Traceability:** `F-08` (`D-011`), `D-006`, `D-009`, `D-016`, `D-017`, `D-018`
    - **Scope:** Docker Compose stack (PostgreSQL 16.6, Mailpit v1.21.4, ASP.NET Core 8.0 API, React Vite placeholder, Nginx 1.27.3), OpenSSL self-signed TLS script for `192.168.100.100`/`localhost`, Nginx reverse proxy (`50000`/`50001` + edge rate limit + `Host` pass-through), `.env` generation, Serilog logging, global exception/error-code middleware, .NET 8 Rate Limiter, and `/api/v1/health` endpoint + test script.
    - **Status:** `NOT_STARTED`
- **Module 1.2: `CoreInfra-Module`**
  - **Stage 002 — `Foundation-System / CoreInfra-Module / efcore-outbox-audit-base`**
    - **Feature Traceability:** `F-09` (`D-012`), `F-07` (`D-010`), `D-006`
    - **Scope:** EF Core 8.0.11 `AppDbContext` with Npgsql, base auditable entities (`UUID v4`, UTC timestamps), `EmailOutbox` table + bilingual (`fa`/`en`) templates + `BackgroundService` SMTP worker (Mailpit), `AuditLogs` persistence service, and test script verifying Mailpit email delivery.
    - **Status:** `NOT_STARTED`

#### System 2: `Identity-System` (Authentication, 4-Tier Hierarchical RBAC & User Profile)
- **Module 2.1: `Auth-Module`**
  - **Stage 003 — `Identity-System / Auth-Module / jwt-auth-lifecycle`**
    - **Feature Traceability:** `F-01` (`D-004`), `F-08` (`D-011`), `F-09` (`D-012`), `F-12` (`D-015`)
    - **Scope:** `Users` and `RefreshTokens` tables, registration, email verification via Mailpit, JWT login + refresh token rotation, logout, forgot/reset password, development-only test seeder (`testuserN`, `testadminN`), and auth test script.
    - **Status:** `NOT_STARTED`
- **Module 2.2: `Rbac-Module`**
  - **Stage 004 — `Identity-System / Rbac-Module / hierarchical-dynamic-permissions`**
    - **Feature Traceability:** `F-02` (`D-005`), `F-07` (`D-010`)
    - **Scope:** `Roles` (`SuperAdmin`, `BaseManager`, `BranchManager`, `User`), `Permissions`, `RolePermissions`, `OrganizationalBases`, `OrganizationalBranches`, and `UserScopeAssignments` tables; dynamic permission authorization handler with `PermissionVersion` checks; Super Admin permission matrix APIs; Base/Branch hierarchy assignment APIs; audit logging; and RBAC test script.
    - **Status:** `NOT_STARTED`
- **Module 2.3: `Profile-Module`**
  - **Stage 005 — `Identity-System / Profile-Module / profile-and-preferences`**
    - **Feature Traceability:** `F-12` (`D-015`), `F-01`
    - **Scope:** User profile retrieval and update (`displayName`, `preferredLanguage` `fa`/`en`, `preferredTheme` `light`/`dark`), password change with active token revocation, and profile test script.
    - **Status:** `NOT_STARTED`

#### System 3: `Tenant-System` (Multi-Site Workspaces & Custom Domains)
- **Module 3.1: `Site-Module`**
  - **Stage 006 — `Tenant-System / Site-Module / multisite-workspace-isolation`**
    - **Feature Traceability:** `F-03` (`D-006`), `F-02` (`D-005`), `F-07` (`D-010`)
    - **Scope:** `Sites` table linked to `BaseId`/`BranchId` and owner `UserId`, `ISiteScoped` EF Core Global Query Filters, site CRUD APIs scoped by role hierarchy, public site resolver (`/api/v1/public/sites/resolve`), and multi-site isolation test script.
    - **Status:** `NOT_STARTED`
- **Module 3.2: `Domain-Module`**
  - **Stage 007 — `Tenant-System / Domain-Module / custom-domain-host-routing`**
    - **Feature Traceability:** `F-06` (`D-009`), `F-03` (`D-006`), `F-07` (`D-010`)
    - **Scope:** `SiteDomains` table (`DomainName`, `VerificationToken`, `IsVerified`, `IsPrimary`), ASP.NET Core `Host`/`X-Forwarded-Host` tenant resolution middleware, custom domain CRUD + DNS TXT verification APIs, and Host-header routing test script.
    - **Status:** `NOT_STARTED`

#### System 4: `Plugin-System` (Modular Plugin Engine, Per-Site Config & Starter Modules)
- **Module 4.1: `PluginCore-Module`**
  - **Stage 008 — `Plugin-System / PluginCore-Module / catalog-install-jsonb-config`**
    - **Feature Traceability:** `F-04` (`D-007`), `F-05` (`D-008`), `F-02` (`D-005`), `F-03` (`D-006`)
    - **Scope:** `IPlatformPlugin` contract + `PluginConfigSchema` server validator, `Plugins` and `SitePlugins` (`ConfigurationJson` `jsonb`) tables, platform catalog APIs, per-site install/activate/deactivate/uninstall APIs, per-site JSONB configuration APIs, and plugin core test script.
    - **Status:** `NOT_STARTED`
- **Module 4.2: `StarterPlugins-Module`**
  - **Stage 009 — `Plugin-System / StarterPlugins-Module / announcements-contact-catalog`**
    - **Feature Traceability:** `F-04` (`D-007`), `F-05` (`D-008`), `F-03` (`D-006`)
    - **Scope:** Three built-in `IPlatformPlugin` modules isolated by `SiteId` and controlled by per-site config: `announcements` (news/announcements CRUD + public feed), `contact-form` (public contact submissions + manager inbox), and `catalog-items` (products/services showcase CRUD + public list), plus starter plugins test script.
    - **Status:** `NOT_STARTED`

#### System 5: `Ops-System` (In-App Notifications, Analytics Dashboard & Audit Viewer)
- **Module 5.1: `Notification-Module`**
  - **Stage 010 — `Ops-System / Notification-Module / inapp-notifications-center`**
    - **Feature Traceability:** `F-10` (`D-013`), `F-12` (`D-015`)
    - **Scope:** `Notifications` table (`TitleKey`, `ParamsJson`, `IsRead`), automatic notification generation on role, site, and plugin events, paginated notifications + unread count + mark-as-read APIs, and notifications test script.
    - **Status:** `NOT_STARTED`
- **Module 5.2: `Analytics-Module`**
  - **Stage 011 — `Ops-System / Analytics-Module / dashboard-metrics-and-audit-logs`**
    - **Feature Traceability:** `F-11` (`D-014`), `F-07` (`D-010`), `F-02` (`D-005`)
    - **Scope:** Role-scoped SQL aggregation metrics with `IMemoryCache` (platform overview + per-site metrics) and paginated/filtered `AuditLogs` viewer API, plus analytics & audit test script.
    - **Status:** `NOT_STARTED`

---

### Phase 2: Full Backend Test
#### System 6: `BackendQA-System`
- **Module 6.1: `FullBackendTest-Module`**
  - **Stage 012 — `BackendQA-System / FullBackendTest-Module / full-backend-integration-and-contract-audit`**
    - **Feature Traceability:** `F-01` through `F-12` (Section 10.5 & Section 11 Phase 2)
    - **Scope:** Master PowerShell runner executing all stage test scripts (`001`–`011`), end-to-end cross-role journeys (`SuperAdmin` -> `BaseManager` -> `BranchManager` -> `User`), cross-site data isolation checks, rate-limit checks, and full code-to-`09-API-CONTRACT.md` audit.
    - **Status:** `NOT_STARTED`

---

### Phase 3: Frontend (React 18.3.1 + TypeScript 5.6.3 + Vite 5.4.11 + Tailwind 3.4.15)
#### System 7: `WebApp-System`
- **Module 7.1: `AppShell-Module`**
  - **Stage 013 — `WebApp-System / AppShell-Module / theme-i18n-jalali-api-shell`**
    - **Feature Traceability:** `F-12` (`D-015`), `D-016`, `D-017`, `D-018`
    - **Scope:** Semantic Light/Dark CSS theme tokens, `i18next` bilingual dictionaries (`fa` RTL + Jalali calendar / `en` LTR + Gregorian calendar), `Vazirmatn` & `Inter` fonts, responsive dashboard layout shell, theme/language switchers, and typed API client with JWT refresh interceptor and `errorCode`-to-translation mapping.
    - **Status:** `NOT_STARTED`
- **Module 7.2: `AuthUI-Module`**
  - **Stage 014 — `WebApp-System / AuthUI-Module / auth-and-profile-pages`**
    - **Feature Traceability:** `F-01`, `F-12`
    - **Scope:** Login, Register, Verify Email, Forgot/Reset Password, and User Profile & Security Settings pages built from confirmed `ui-design/` code.
    - **Status:** `NOT_STARTED`
- **Module 7.3: `AdminUI-Module`**
  - **Stage 015 — `WebApp-System / AdminUI-Module / overview-rbac-hierarchy-audit-pages`**
    - **Feature Traceability:** `F-02`, `F-07`, `F-11`
    - **Scope:** Overview Analytics Dashboard, Super Admin Dynamic Permission Matrix editor, Base/Branch Hierarchy Manager, and Security Audit Logs pages built from confirmed `ui-design/` code.
    - **Status:** `NOT_STARTED`
- **Module 7.4: `SiteUI-Module`**
  - **Stage 016 — `WebApp-System / SiteUI-Module / sites-and-custom-domains-pages`**
    - **Feature Traceability:** `F-03`, `F-06`
    - **Scope:** My Sites list, Create Site modal/page, Site Workspace Settings, and Custom Domain Mapping & DNS TXT verification pages built from confirmed `ui-design/` code.
    - **Status:** `NOT_STARTED`
- **Module 7.5: `PluginUI-Module`**
  - **Stage 017 — `WebApp-System / PluginUI-Module / plugins-config-notifications-public-site`**
    - **Feature Traceability:** `F-04`, `F-05`, `F-10`
    - **Scope:** Plugin Catalog & Installer, Dynamic Per-Site Plugin Configuration form, In-App Notification drawer/page, and Live Public Tenant Site Shell (`/s/{siteSlug}` & custom domain host view) rendering installed starter modules (`announcements`, `contact-form`, `catalog-items`) built from confirmed `ui-design/` code.
    - **Status:** `NOT_STARTED`

---

### Phase 4: Completion and Production
- **Placeholder Only (Not Planned Yet):** Production deployment, secret rotation, public DNS & SSL certificates, production backups, and `docs/04-FUTURE-TODO.md` Production Checklist walkthrough — to be planned after Phase 3 is confirmed complete.

## 5. UI PAGES AND POPUPS
| System / Module | Page or Popup Name | Purpose | Design Status |
| :--- | :--- | :--- | :--- |
| `WebApp-System / AuthUI-Module` | `LoginPage` | Email/password sign-in with theme/language switchers | `PLANNED` |
| `WebApp-System / AuthUI-Module` | `RegisterPage` | New user registration and verification email trigger | `PLANNED` |
| `WebApp-System / AuthUI-Module` | `VerifyEmailPage` | Email verification token confirmation screen | `PLANNED` |
| `WebApp-System / AuthUI-Module` | `ForgotResetPasswordPage` | Password reset request and new password submission | `PLANNED` |
| `WebApp-System / AuthUI-Module` | `UserProfilePage` | Profile details, password change, language & theme settings | `PLANNED` |
| `WebApp-System / AdminUI-Module` | `OverviewDashboardPage` | Role-scoped KPIs, site health summary, and recent activity | `PLANNED` |
| `WebApp-System / AdminUI-Module` | `RolePermissionMatrixPage` | Super Admin dynamic permission matrix for Base/Branch/User roles | `PLANNED` |
| `WebApp-System / AdminUI-Module` | `HierarchyManagementPage` | Organizational Bases, Branches, and user scope assignments | `PLANNED` |
| `WebApp-System / AdminUI-Module` | `AuditLogsPage` | Filterable security audit log viewer | `PLANNED` |
| `WebApp-System / SiteUI-Module` | `SitesListPage` | List and filter user/manager accessible sites | `PLANNED` |
| `WebApp-System / SiteUI-Module` | `CreateSitePopup` | Modal popup to create a new site under a Base/Branch scope | `PLANNED` |
| `WebApp-System / SiteUI-Module` | `SiteSettingsPage` | Site metadata, status, and general workspace settings | `PLANNED` |
| `WebApp-System / SiteUI-Module` | `CustomDomainsPage` | Bind custom domains, view DNS TXT token, and trigger verification | `PLANNED` |
| `WebApp-System / PluginUI-Module` | `PluginCatalogPage` | Browse platform modules and install/toggle/remove per site | `PLANNED` |
| `WebApp-System / PluginUI-Module` | `PluginConfigPopup` | Schema-driven dynamic settings form for an installed site plugin | `PLANNED` |
| `WebApp-System / PluginUI-Module` | `NotificationsDrawer` | In-app notification list and mark-as-read controls | `PLANNED` |
| `WebApp-System / PluginUI-Module` | `PublicTenantSitePage` | Public-facing dynamic site shell rendering active site plugins | `PLANNED` |

## 6. STAGE BRANCH LOG
| Branch Number | Branch Name | Stage | Date | Commit Hash | Pushed (yes/no) | Private Backup (yes/no) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 000 | `000-project-setup` | `Stage 000 — Project Setup` | `2026-11-21` | *Pending user commit output* | `pending` | `pending` |
