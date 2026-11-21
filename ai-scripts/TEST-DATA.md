# Test Data & Test Accounts Registry

## Test Account Rules
All automated backend test scripts must strictly follow this naming and password convention (`N = 1, 2, 3, ...`):

| Type | Username | Password | Email |
| :--- | :--- | :--- | :--- |
| User | `testuserN` | `123456789@TestUserN` | `testuserN@test.com` |
| Admin | `testadminN` | `123456789@TestAdminN` | `testadminN@test.com` |

> **Rule:** Test accounts must ONLY exist in Development/Test environments. Seeders and test scripts must refuse to run if `ASPNETCORE_ENVIRONMENT=Production`.

## Active Test Values Log
| Category | Key / Identifier | Value | Created By Script | Notes |
| :--- | :--- | :--- | :--- | :--- |
| *No test data created yet* | | | | |
