# Project Structure Map

```text
D:\projeh\1-kalate-manager\
├── .env.example                                            # Template of required environment variables (no real secrets)
├── .gitignore                                              # Git ignore rules excluding secrets, .env, certs, build outputs, and local data
├── docker-compose.yml                                      # Multi-container orchestration (PostgreSQL 16.6, Mailpit, ASP.NET Core 8 API, Vite, Nginx)
├── test-text.txt                                           # Initial repository bootstrap file (3 bytes) present from repo initialization
├── ai-scripts/                                             # PowerShell test, backup, setup, and restore scripts
│   ├── Backup-System-private-backup.ps1                    # Immutable private snapshot script for git-ignored secrets, env, certs, data, and DB dumps
│   ├── Backup-System-private-restore.ps1                   # Safe restore script with overwrite confirmation and database restore warnings
│   ├── Foundation-System-generate-certs.ps1                # Generates self-signed TLS certificates in git-ignored certs/ for 192.168.100.100 and localhost
│   ├── Foundation-System-init-env.ps1                      # Initializes git-ignored .env from .env.example and writes dev secrets to docs/07-DEV-SECRETS.md
│   ├── Foundation-System-test.ps1                          # Stage 001 verification test script (Nginx HTTPS/HTTP, API-001 health, Host pass-through, 404, 429)
│   └── TEST-DATA.md                                        # Registry of test accounts, sample IDs, and test values
├── backend/                                                # ASP.NET Core 8.0 Web API solution
│   ├── KalateManager.sln                                   # Visual Studio / dotnet solution file
│   └── src/
│       └── KalateManager.Api/
│           ├── Dockerfile                                  # Multi-stage Docker build for ASP.NET Core 8.0 API
│           ├── KalateManager.Api.csproj                    # Project file with pinned Serilog 8.0.3 and Swashbuckle 6.9.0
│           ├── appsettings.json                            # Base ASP.NET Core configuration
│           ├── appsettings.Development.json                # Development logging configuration
│           ├── Foundation-System-Program.cs                # Host startup, Serilog, CORS, Rate Limiter, standard error envelopes, and Swagger
│           ├── Contracts/
│           │   └── Foundation-System-ApiContracts.cs       # Standard ApiErrorResponse, PagedResult<T>, and HealthResponse DTOs
│           ├── Controllers/
│           │   └── Scaffold-Module-HealthController.cs     # API-001 (GET /api/v1/health) endpoint controller
│           └── Middleware/
│               └── Foundation-System-ExceptionMiddleware.cs # Global exception handler returning standard JSON error envelope
├── certs/                                                  # Git-ignored self-signed TLS certificates (kalate-dev.crt, kalate-dev.key)
├── docs/                                                   # Single source of truth project documentation
│   ├── 00-PROJECT-GENERAL-DATA.md                          # Core project identity, tech stack, pinned versions, network/ports, git & backup info
│   ├── 01-PROJECT-STAGES.md                                # Current position, features, architectural decisions, stages, UI status, branch log
│   ├── 02-PROJECT-STRUCTURE-MAP.md                         # Complete file and folder tree with descriptions
│   ├── 03-CHANGE-LOG.md                                    # Chronological log of all project actions, git events, and backups
│   ├── 04-FUTURE-TODO.md                                   # Deferred features, future tasks, and mandatory Production Checklist
│   ├── 05-USER-PREFERENCES.md                              # User language and code delivery preferences
│   ├── 06-SCRIPT-RESULTS.md                                # Execution logs and pass/fail results of backend test scripts
│   ├── 07-DEV-SECRETS.md                                   # Git-ignored development credentials and secrets
│   ├── 08-PROJECT-COMMANDS.md                              # All PowerShell commands for setup, dev, Docker, DB, tests, backup, and git
│   └── 09-API-CONTRACT.md                                # Single source of truth for backend endpoints, conventions, errors, and page map
├── frontend/                                               # React 18.3.1 + TypeScript 5.6.3 + Vite 5.4.11 frontend application
│   ├── Dockerfile                                          # Docker container for Vite dev server
│   ├── index.html                                          # Root HTML document
│   ├── package.json                                        # Pinned npm dependencies (React 18.3.1, Vite 5.4.11, Tailwind 3.4.15)
│   ├── tsconfig.json                                       # TypeScript strict configuration
│   ├── vite.config.ts                                      # Vite dev server configuration allowing custom domain Host headers
│   └── src/
│       ├── App.tsx                                         # Phase 1 placeholder screen confirming reverse proxy routing
│       └── main.tsx                                        # React root mount entry point
├── nginx/                                                  # Nginx reverse proxy configuration
│   └── Foundation-System-nginx.conf                        # HTTPS (50000), HTTP->HTTPS redirect (50001), edge rate limit, and Host pass-through
└── ui-design/                                              # User-provided final UI design code files (one file per page or popup)
    └── .gitkeep                                            # Keeps ui-design directory tracked in Git
```

## External Directories (Outside Git)
- `D:\projeh\1-kalate-manager-backup\` — Private backup folder for git-ignored secrets, `.env` files, certificates, local data volumes, and database dumps (`external, not in git`).
