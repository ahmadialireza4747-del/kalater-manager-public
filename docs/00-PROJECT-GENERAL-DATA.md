# Project General Data

## 1. Project Identity
- **Project Name:** Kalate Manager (مدیریت کلاته)
- **Project Goal:** A web platform where users can create and manage their own websites and systems, and extend their capabilities by installing and configuring plugins and modules provided by the platform.
- **Project Root Directory:** `D:\projeh\1-kalate-manager`
- **Existing Files & Code:** None (greenfield project built from scratch)

## 2. Environment & Infrastructure
- **Development OS:** Windows
- **Preferred Shell:** PowerShell
- **Development Execution Model:** Containerized development using Docker & Docker Compose
- **Target Operating Systems (Current Scope):** Web (Desktop & Mobile responsive browsers)
- **Target Operating Systems (Deferred / Future):** Windows, macOS, Linux, Android (tracked in `docs/04-FUTURE-TODO.md`)
- **Production Tools:** Docker, Nginx, PostgreSQL (additional tools such as caching/queues to be added later as needed)
- **Development Tools:** Docker, Docker Compose, OpenSSL (local TLS certificates), Mailpit (local SMTP & web inbox), Git

## 3. Network, IP & Port Allocation
- **Server / Host IP Address:** `192.168.100.100`
- **Domain:** None (local IP-based development; self-signed OpenSSL certificate for `192.168.100.100` and `localhost`)
- **Port Allocation Map:**
  - `50000` — Nginx Reverse Proxy (HTTPS main entry point)
  - `50001` — Nginx Reverse Proxy (HTTP entry / redirect)
  - `50002` — Backend API (ASP.NET Core)
  - `50003` — Frontend Web App (Vite dev server)
  - `50004` — PostgreSQL Database
  - `50005` — Mailpit Web UI
  - `50006` — Mailpit SMTP Server

## 4. Tech Stack & Pinned Versions
All versions below are pinned to exact releases (no `^` or `~`) to ensure deterministic builds and mutual compatibility.

### Container Images
- **.NET SDK:** `mcr.microsoft.com/dotnet/sdk:8.0.404`
- **.NET Runtime:** `mcr.microsoft.com/dotnet/aspnet:8.0.11`
- **Node.js:** `node:22.11.0-alpine`
- **PostgreSQL:** `postgres:16.6-alpine`
- **Nginx:** `nginx:1.27.3-alpine`
- **Mailpit:** `axllent/mailpit:v1.21.4`

### Backend (C# / ASP.NET Core 8.0)
- **Target Framework:** `net8.0`
- `Microsoft.EntityFrameworkCore`: `8.0.11`
- `Microsoft.EntityFrameworkCore.Design`: `8.0.11`
- `Npgsql.EntityFrameworkCore.PostgreSQL`: `8.0.11`
- `Microsoft.AspNetCore.Authentication.JwtBearer`: `8.0.11`
- `Swashbuckle.AspNetCore`: `6.9.0`
- `Serilog.AspNetCore`: `8.0.3`
- `FluentValidation.AspNetCore`: `11.3.0`

### Frontend (TypeScript / React)
- `react`: `18.3.1`
- `react-dom`: `18.3.1`
- `react-router-dom`: `6.28.0`
- `typescript`: `5.6.3`
- `vite`: `5.4.11`
- `@vitejs/plugin-react`: `4.3.4`
- `tailwindcss`: `3.4.15`
- `postcss`: `8.4.49`
- `autoprefixer`: `10.4.20`
- `i18next`: `23.16.8`
- `react-i18next`: `15.1.1`
- `lucide-react`: `0.460.0`

## 5. UI Style Direction & Localization
- **Mood & Visual Style:** Not specified yet (custom UI designs will be provided by the user later)
- **Main Colors:** Not specified yet (semantic CSS theme tokens will be used for Light & Dark modes until custom designs arrive)
- **Reference Sites / Apps:** None
- **Logo & Typography:** No logo yet; default fonts set to `Vazirmatn` (Persian) and `Inter` (English)
- **Languages & Direction:** Bilingual UI — Persian (`fa`, RTL) and English (`en`, LTR) with runtime switching
- **Theme Support:** Light and Dark mode with runtime switching
- **Calendar System:** UTC ISO 8601 in backend/database; Jalali (Persian) calendar in Persian UI display and Gregorian calendar in English UI display (confirmed)

## 6. Secrets & Credentials
- Credentials and secrets are never stored in this file.
- All development secrets and credentials are stored in `docs/07-DEV-SECRETS.md` (git-ignored) and injected via environment variables (`.env`).

## 7. VERSION CONTROL
- **Status:** Verified (Step 3b)
- **Git Available:** Yes (`git version 2.55.0.windows.5`)
- **Repository Initialized:** Yes (`true`)
- **Remote URL:** `origin` -> `https://github.com/ahmadialireza4747-del/kalater-manager-public.git` (fetch & push)
- **Branching Strategy:** One numbered branch per completed stage (`000-project-setup`, `001-...`, etc.)

## 8. PRIVATE BACKUP
- **Status:** Configured (Step 3c)
- **Backup Folder Path:** `D:\projeh\1-kalate-manager-backup` (Option A — outside project root, same drive)
- **Off-Machine Backup Method:** None (declined by user for local development)

### PRIVATE BACKUP LIST
| Path | Why It Matters | How It Is Backed Up |
| :--- | :--- | :--- |
| `docs/07-DEV-SECRETS.md` | Development secrets and credentials (git-ignored) | Copied into snapshot root (`docs/07-DEV-SECRETS.md`) by `ai-scripts/Backup-System-private-backup.ps1` |
| `.env` (and any `.env.*` files) | Local runtime environment variables (git-ignored) | Copied into snapshot root by `ai-scripts/Backup-System-private-backup.ps1` |
| PostgreSQL development database | Persistent local database state and schemas | Dumped via `pg_dump` into `<snapshot>/db/` by `ai-scripts/Backup-System-private-backup.ps1` |
| `certs/` (OpenSSL TLS certificates & keys) | Local HTTPS self-signed certificates and private keys | Copied into snapshot root (`certs/`) by `ai-scripts/Backup-System-private-backup.ps1` |
| `storage/` & `uploads/` (local persistent volumes) | User-uploaded files, generated site assets, and plugin packages | Copied into snapshot root by `ai-scripts/Backup-System-private-backup.ps1` |
