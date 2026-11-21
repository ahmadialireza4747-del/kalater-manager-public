# Project Commands Reference

All commands are written for **Windows PowerShell** and executed from the project root `D:\projeh\1-kalate-manager` unless specified otherwise.

## Prerequisites
- **Working Directory:** `D:\projeh\1-kalate-manager`
- **Required Installed Software:**
  - Windows PowerShell (5.1 or 7+)
  - Git (`git version 2.55.0.windows.5` verified)
  - Docker Desktop (with Docker Compose v2 running)
  - OpenSSL (optional — `Foundation-System-generate-certs.ps1` uses local OpenSSL if installed or falls back to Dockerized `alpine/openssl`)

## Environment & Certificates Setup (Stage 001)
- **Initialize git-ignored `.env` and `docs/07-DEV-SECRETS.md` (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  powershell -ExecutionPolicy Bypass -File .i-scripts\Foundation-System-init-env.ps1
  ```
  *Success looks like:* Creates `.env` from `.env.example` with generated development credentials and updates `docs/07-DEV-SECRETS.md`.

- **Generate Self-Signed TLS Certificates in `certs/` (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  powershell -ExecutionPolicy Bypass -File .i-scripts\Foundation-System-generate-certs.ps1
  ```
  *Success looks like:* Creates `certs\kalate-dev.crt` and `certs\kalate-dev.key` for `192.168.100.100` and `localhost`.

## Containers (Docker Compose)
- **Build and Start Full Development Stack (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  docker compose up -d --build
  docker compose ps
  ```
  *Success looks like:* Containers `kalate-postgres`, `kalate-mailpit`, `kalate-api`, `kalate-frontend`, and `kalate-nginx` are `Up` (`kalate-postgres` healthy); HTTPS entry is at `https://192.168.100.100:50000` and Mailpit UI at `http://192.168.100.100:50005`.

- **View Container Logs (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  docker compose logs -f --tail=100
  ```
  *Success looks like:* Streams structured Serilog logs from `kalate-api` and access/error logs from `kalate-nginx`.

- **Stop Containers (Preserves Database Volume) (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  docker compose down
  ```
  *Success looks like:* Stops and removes containers while keeping `kalate_postgres_data` volume intact.

## Run the Backend Test Scripts
- **Stage 001 — Foundation-System / Scaffold-Module Test (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  powershell -ExecutionPolicy Bypass -File .i-scripts\Foundation-System-test.ps1
  ```
  *Success looks like:* Prints `[PASS 1]` through `[PASS 7]` and ends with `ALL STAGE 001 TESTS PASSED SUCCESSFULLY.`

## Private Backup and Restore
- **Run Private Backup Snapshot (VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  powershell -ExecutionPolicy Bypass -File .i-scripts\Backup-System-private-backup.ps1 -StageBranch "000-project-setup"
  ```
  *Success looks like:* Creates `D:\projeh\1-kalate-manager-backup\000-project-setup_<YYYY-MM-DD>\` with `MANIFEST.md` and copied files, ending with `Private backup completed successfully.`

- **Test Restore Snapshot into a Temporary Folder (VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  $today = (Get-Date).ToString("yyyy-MM-dd")
  powershell -ExecutionPolicy Bypass -File .i-scripts\Backup-System-private-restore.ps1 -SnapshotName "000-project-setup_$today" -TargetPath "D:\projeh\1-kalate-manager-restore-test"
  Get-ChildItem -Recurse "D:\projeh\1-kalate-manager-restore-test"
  ```
  *Success looks like:* Restores backed-up files into `D:\projeh\1-kalate-manager-restore-test` without modifying the live project.

## Git Quick Reference
- **Check Git version, repository status, and remotes (Step 3b — VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git --version
  git rev-parse --is-inside-work-tree
  git remote -v
  ```
  *Success looks like:* Displays `git version 2.55.0.windows.5`, `true`, and `origin` pointing to `https://github.com/ahmadialireza4747-del/kalater-manager-public.git`.

- **Untrack `docs/07-DEV-SECRETS.md` from Git index without deleting local file (VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git rm --cached docs/07-DEV-SECRETS.md
  git status
  ```
  *Success looks like:* Output shows `rm 'docs/07-DEV-SECRETS.md'` (staged deletion from index only; local file remains on disk and is ignored by `.gitignore`).

- **Commit and Push Completed Stage `000-project-setup` (VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git status
  git checkout -b 000-project-setup
  git add .
  git status
  git commit -m "[Stage 000] Project-Setup / Setup / 000-project-setup: setup confirmed 2026-11-21"
  git push -u origin 000-project-setup
  git log -1 --oneline
  ```
  *Success looks like:* Commit `d7b9fa8` created on branch `000-project-setup` and pushed to `origin`.

- **Check current status, branch, and recent commits (VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git status
  git branch --show-current
  git log --oneline -5
  ```
  *Success looks like:* Shows current branch name, working tree status, and latest commits.
