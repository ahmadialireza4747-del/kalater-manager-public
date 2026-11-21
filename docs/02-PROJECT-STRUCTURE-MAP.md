# Project Structure Map

```text
D:\projeh\1-kalate-manager\
├── .env.example                            # Template of required environment variables (no real secrets)
├── .gitignore                              # Git ignore rules excluding secrets, .env, certs, build outputs, and local data
├── ai-scripts/                             # PowerShell test, backup, and restore scripts created during development
│   ├── Backup-System-private-backup.ps1    # Immutable private snapshot script for git-ignored secrets, env, certs, data, and DB dumps
│   ├── Backup-System-private-restore.ps1   # Safe restore script with overwrite confirmation and database restore warnings
│   └── TEST-DATA.md                        # Registry of test accounts, sample IDs, and test values
├── docs/                                   # Single source of truth project documentation
│   ├── 00-PROJECT-GENERAL-DATA.md          # Core project identity, tech stack, pinned versions, network/ports, git & backup info
│   ├── 01-PROJECT-STAGES.md                # Current position, features, architectural decisions, stages, UI status, branch log
│   ├── 02-PROJECT-STRUCTURE-MAP.md         # Complete file and folder tree with descriptions
│   ├── 03-CHANGE-LOG.md                    # Chronological log of all project actions, git events, and backups
│   ├── 04-FUTURE-TODO.md                   # Deferred features, future tasks, and mandatory Production Checklist
│   ├── 05-USER-PREFERENCES.md              # User language and code delivery preferences
│   ├── 06-SCRIPT-RESULTS.md                # Execution logs and pass/fail results of backend test scripts
│   ├── 07-DEV-SECRETS.md                   # Git-ignored development credentials and secrets
│   ├── 08-PROJECT-COMMANDS.md              # All PowerShell commands for setup, dev, Docker, DB, tests, backup, and git
│   └── 09-API-CONTRACT.md                # Single source of truth for backend endpoints, conventions, errors, and page map
└── ui-design/                              # User-provided final UI design code files (one file per page or popup)
    └── .gitkeep                            # Keeps ui-design directory tracked in Git
```

## External Directories (Outside Git)
- `D:\projeh\1-kalate-manager-backup\` — Private backup folder for git-ignored secrets, `.env` files, certificates, local data volumes, and database dumps (`external, not in git`).
