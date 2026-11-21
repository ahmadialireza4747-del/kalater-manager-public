# Project Commands Reference

All commands are written for **Windows PowerShell** and executed from the project root `D:\projeh\1-kalate-manager` unless specified otherwise.

## Prerequisites
- **Working Directory:** `D:\projeh\1-kalate-manager`
- **Required Installed Software:**
  - Windows PowerShell (5.1 or 7+)
  - Git (`git version 2.55.0.windows.5` verified)
  - Docker Desktop (with Docker Compose v2)
  - OpenSSL (for generating local self-signed TLS certificates)

## Private Backup and Restore
- **Run Private Backup Snapshot (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  powershell -ExecutionPolicy Bypass -File .i-scripts\Backup-System-private-backup.ps1 -StageBranch "000-project-setup"
  ```
  *Success looks like:* Creates `D:\projeh\1-kalate-manager-backup\000-project-setup_<YYYY-MM-DD>\` with `MANIFEST.md` and copied files (printing a warning if PostgreSQL container is not yet running), ending with `Private backup completed successfully.`

- **Test Restore Snapshot into a Temporary Folder (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  $today = (Get-Date).ToString("yyyy-MM-dd")
  powershell -ExecutionPolicy Bypass -File .i-scripts\Backup-System-private-restore.ps1 -SnapshotName "000-project-setup_$today" -TargetPath "D:\projeh\1-kalate-manager-restore-test"
  Get-ChildItem -Recurse "D:\projeh\1-kalate-manager-restore-test"
  ```
  *Success looks like:* Restores `docs\07-DEV-SECRETS.md` (and any other backed-up items) into `D:\projeh\1-kalate-manager-restore-test` and lists the restored files without modifying the live project.

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

- **Commit and Push Completed Stage `000-project-setup` (UNVERIFIED):**
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
  *Success looks like:* Neither `git status` output lists `docs/07-DEV-SECRETS.md` or any `.env` file; commit is created on branch `000-project-setup`, pushed to `origin`, and `git log -1 --oneline` displays the commit hash and message.

- **Check current status, branch, and recent commits (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git status
  git branch --show-current
  git log --oneline -5
  ```
  *Success looks like:* Shows current branch name, clean or expected uncommitted working tree, and latest commits.
