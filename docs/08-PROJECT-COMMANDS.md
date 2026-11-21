# Project Commands Reference

All commands are written for **Windows PowerShell** and executed from the project root `D:\projeh\1-kalate-manager` unless specified otherwise.

## Prerequisites
- **Working Directory:** `D:\projeh\1-kalate-manager`
- **Required Installed Software:**
  - Windows PowerShell (5.1 or 7+)
  - Git (`git version 2.55.0.windows.5` verified)
  - Docker Desktop (with Docker Compose v2)
  - OpenSSL (for generating local self-signed TLS certificates)

## Git Quick Reference
- **Check Git version, repository status, and remotes (Step 3b — VERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git --version
  git rev-parse --is-inside-work-tree
  git remote -v
  ```
  *Success looks like:* Displays `git version 2.55.0.windows.5`, `true`, and `origin` pointing to `https://github.com/ahmadialireza4747-del/kalater-manager-public.git`.

- **Check current status, branch, and recent commits (UNVERIFIED):**
  ```powershell
  # Working directory: D:\projeh\1-kalate-manager
  git status
  git branch --show-current
  git log --oneline -5
  ```
  *Success looks like:* Shows current branch name, clean or expected uncommitted working tree, and latest commits.
