# Project Retest Config — Template

> ตั้งชื่อไฟล์ว่า `<project-name>-retest-guide.md` แล้ววางไว้ใน `references/` ของ skill
> SKILL.md จะ detect ไฟล์ที่ match pattern `*-retest-guide.md` ใน Step 1 อัตโนมัติ

---

## Project Info

| Key | Value |
|-----|-------|
| Project name | `<ชื่อโปรเจกต์>` |
| Jira Cloud ID | `<your-org>.atlassian.net` |
| Ticket prefix | `<PREFIX>` (เช่น CP, PROJ, WEB) |
| Confluence docs | `<URL ถ้ามี>` |

## Environments

| Env name | Base URL | Swagger / API Docs |
|----------|----------|-------------------|
| `<env1>` | `https://<env1-url>` | `https://<env1-url>/api/docs` |
| `<env2>` | `https://<env2-url>` | `https://<env2-url>/api/docs` |

## Portals & Login

| Portal | URL Pattern | Login method | Token type |
|--------|-------------|-------------|------------|
| Admin | `https://<env>-<admin-url>` | email/password | Admin token |
| SP/User | `https://<env>-<sp-url>` | OTP flow / SSO | User token |

## Credentials

> ⚠️ ใส่เฉพาะ test/staging credentials — ห้ามใส่ production credentials

| Portal | Username | Password |
|--------|----------|----------|
| Admin | `<test-admin@example.com>` | `<password>` |
| SP/User | `<test-user@example.com>` | `<password>` |

## Test Accounts (ถ้ามี)

| Account | Password | Notes |
|---------|----------|-------|
| `<account1>` | `<password>` | `<notes>` |

## API Architecture

```
<อธิบาย architecture สั้นๆ — เช่น portal ไหนเรียก API ตรง, อันไหนผ่าน gateway>
```

## Token Notes

- **Admin token:** `<วิธีได้มา + ข้อจำกัด>`
- **SP/User token:** `<วิธีได้มา + ข้อจำกัด>`
- **Token expiry:** `<ระยะเวลา>`

## Error Documentation (ถ้ามี)

| Source | URL |
|--------|-----|
| Confluence Error Docs | `<URL>` |
| API Error Code Reference | `<URL>` |

## Swagger Comparison Rules

> ปรับตามโปรเจกต์ — default ใช้ rules จาก SKILL.md

1. Response code ต้องตรง Swagger
2. Response message → เทียบกับ Error Documentation (ถ้ามี)
3. ทั้งคู่ตรง → PASSED
4. Code ไม่ตรง → FAILED
5. Code ตรงแต่ message ไม่ตรง → FAILED
6. ทั้ง Swagger + Error Docs ไม่ระบุ → BLOCKED

## Project-Specific Gotchas

- `<gotcha 1>`
- `<gotcha 2>`
