# Future To-Do & Production Checklist

## PRODUCTION CHECKLIST
Every item below MUST be completed and verified before going live in Phase 4:
- [ ] Replace every development secret in `docs/07-DEV-SECRETS.md` and `.env` with strong production secrets via environment variables or a production secret store.
- [ ] Verify `docs/07-DEV-SECRETS.md` and all real `.env` files are excluded from Git and inspect full Git history for any leaked secrets.
- [ ] Delete or disable all test accounts (`testuserN`, `testadminN`) and remove all test/seed data.
- [ ] Change all default admin credentials.
- [ ] Disable debug mode, Swagger/OpenAPI public exposure (if applicable), and verbose development logging.
- [ ] Ensure development private-backup snapshots (`D:\projeh\1-kalate-manager-backup`) are never used for production and securely delete them once development secrets are rotated.
- [ ] Configure separate production backups (PostgreSQL database dumps, user-uploaded/plugin storage volumes, production secrets, off-machine storage) with a verified restore procedure.
- [ ] Remove any development-only or testing-only API endpoints listed in `docs/09-API-CONTRACT.md`.

## DEFERRED FEATURES & FUTURE TASKS
| ID | Item | Category | Priority | Notes |
| :--- | :--- | :--- | :--- | :--- |
| TODO-001 | Desktop applications for Windows, macOS, and Linux (using Tauri wrapper over React frontend) | Target Platforms | Medium | Deferred per user request until Web platform is complete |
| TODO-002 | Mobile application for Android (using Capacitor wrapper over React frontend) | Target Platforms | Medium | Deferred per user request until Web platform is complete |
| TODO-003 | Additional production infrastructure tools (e.g., Redis caching, background job queues) | Infrastructure | Low | To be evaluated and added as platform scaling requires |
| TODO-004 | Two-Factor Authentication (2FA) for user and admin accounts | Accounts & Access | Low | Deferred during Step 4 Feature Discovery ("not needed for now") |
| TODO-005 | Google OAuth Social Login integration | Accounts & Access | Medium | Deferred during Step 4 Feature Discovery; user plans to add Google login in a future phase |
| TODO-006 | Custom Drag-and-Drop Page & Navigation Builder for tenant sites | Core Platform | Medium | Deferred during Step 4 Feature Discovery ("no custom pages for now") |
| TODO-007 | Public External API & API Keys for third-party software integrations | Operations & Integrations | Low | Deferred during Step 4 Feature Discovery ("good to have, later") |
