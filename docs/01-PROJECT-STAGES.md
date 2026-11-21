# Project Stages & Plan

## 1. CURRENT POSITION
- **Current Phase:** Setup (First-Time Project Setup)
- **Active System / Module / Stage:** Stage 000 — Project Setup (Step 4 Feature Discovery complete — awaiting explicit user confirmation of the final FEATURES table before starting Step 5 Implementation Options)
- **NEXT STEP:** Explicitly confirm the complete `FEATURES` table (`F-01` through `F-12`) and dependency notes so all features transition from `PROPOSED` to `AGREED` and Step 5 begins.

## 2. FEATURES
| ID | Name | Description | Priority | Status |
| :--- | :--- | :--- | :--- | :--- |
| F-01 | User Authentication & Account Lifecycle | Registration, email/password login, email verification, and password reset flow | MUST | PROPOSED |
| F-02 | Hierarchical RBAC & Dynamic Permission Control | Four-tier role system (Super Admin, Base Manager, Branch Manager, User) where Super Admin dynamically manages and modifies permissions of all other roles | MUST | PROPOSED |
| F-03 | Multi-Site / Multi-Tenant Management | Users and managers can create, configure, and manage independent sites/systems within the platform | MUST | PROPOSED |
| F-04 | Plugin & Module Catalog & Engine | Platform catalog of modules/plugins that can be browsed, installed, activated/deactivated, and removed per site | MUST | PROPOSED |
| F-05 | Per-Site Plugin Configuration | Isolated configuration and settings management for each installed plugin/module on a specific site | MUST | PROPOSED |
| F-06 | Custom Domain Mapping | Ability to bind and configure custom domains for user-created sites (Host-header routing in dev; full DNS/TLS in Phase 4) | MUST | PROPOSED |
| F-07 | Security Audit Logs | Automated logging of sensitive actions (role permission changes, plugin installs/removals, site creation, failed logins) | MUST | PROPOSED |
| F-08 | API & Auth Rate Limiting | Request throttling to protect authentication endpoints and APIs against brute-force and abuse | MUST | PROPOSED |
| F-09 | System Email Notifications | Automated transactional emails for account verification, password resets, invitations, and system alerts via SMTP/Mailpit | MUST | PROPOSED |
| F-10 | In-App Notifications | Notification center inside the dashboard for site, plugin, and role events | MUST | PROPOSED |
| F-11 | Analytics & Overview Dashboard | Summary metrics and health overview of sites, active plugins, users, and recent activity for Super Admin and site managers | MUST | PROPOSED |
| F-12 | User Profile, Theme & Localization Settings | Profile management, password change, runtime Light/Dark theme switching, and bilingual Persian RTL / English LTR with Jalali/Gregorian dates | MUST | PROPOSED |

## 3. DECISIONS
| ID | Date | Related Feature/System | Question | Options Offered | User Choice | Reason | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| D-001 | 2026-11-21 | Version Control / Setup | Version control verification and branching strategy | Git with one numbered branch per completed stage | Git (`git version 2.55.0.windows.5`) with remote `origin` (`https://github.com/ahmadialireza4747-del/kalater-manager-public.git`) and numbered stage branches | Verified active Git repository and GitHub remote | ACTIVE |
| D-002 | 2026-11-21 | Private Backup / Setup | Where to store git-ignored private backups and whether to keep off-machine copies | A: Folder next to project on same drive (`D:\projeh\1-kalate-manager-backup`); B: Separate/external drive; C: Git-ignored folder inside project root | Option A (`D:\projeh\1-kalate-manager-backup`) with no off-machine backup | User selected external folder on `D:` drive, confirmed folder exists, and stated off-machine backup is not needed | ACTIVE |
| D-003 | 2026-11-21 | Workflow / Delivery | How files and code updates are delivered by assistant | Chat snippets, ZIP archive matching project structure, Git patches | ZIP archive matching exact project folder structure (`D:\projeh\1-kalate-manager\`) for direct copy/replace, paired with local Git commands | Assistant cannot push directly to user GitHub remote; ZIP archive allows clean drop-in replacement | ACTIVE |

## 4. PHASES / SYSTEMS / MODULES / STAGES
*To be populated in Step 6 after all MUST features are confirmed and DECIDED in Step 5.*

## 5. UI PAGES AND POPUPS
| System / Module | Page or Popup Name | Purpose | Design Status |
| :--- | :--- | :--- | :--- |
| *To be populated after Step 6* | | | |

## 6. STAGE BRANCH LOG
| Branch Number | Branch Name | Stage | Date | Commit Hash | Pushed (yes/no) | Private Backup (yes/no) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| *Pending Stage 000 completion (after Steps 4–6)* | | | | | | |
