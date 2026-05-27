# Retest Bug Plugin — Domain Language

Glossary ของศัพท์เฉพาะใน plugin นี้ — ป้องกัน AI ตีความผิด

## Core Concepts

**Retest**:
กระบวนการทดสอบซ้ำหลัง dev แก้ bug แล้ว เพื่อยืนยันว่า fix ใช้งานได้จริง
_Avoid_: re-check, verify (ใช้ "retest" เสมอในบริบทนี้)

**Bug API**:
Bug ที่เกิดจาก backend/API response ผิด — ทดสอบผ่าน HTTP request, เทียบกับ Swagger spec
_Avoid_: server bug, backend issue

**Bug FE**:
Bug ที่เกิดจาก frontend/UI แสดงผลผิด — ต้องมี screenshot ประกอบทุก case
_Avoid_: UI bug (ใช้ได้แต่ "Bug FE" เป็น canonical term ใน workflow)

**Ticket**:
Jira issue ที่ถูก assign มาให้ retest — มี test steps, expected result, actual result
_Avoid_: issue (ใช้ "ticket" เสมอใน retest context)

## Environment

**PD3**:
Pre-production environment สำหรับ CreditPort — ใช้ทดสอบก่อน deploy จริง
_URL pattern_: `pd3-*.mycreditport.com`

**Admin Portal (BO)**:
Back-office portal สำหรับ admin — login ด้วย email/password
_URL_: `<env>-web-portal.mycreditport.com/admin`

**SP Portal**:
Service Provider portal — login ด้วย OTP flow, token ใช้กับ Gateway เท่านั้น
_URL_: `<env>-sp.mycreditport.com`

## Authentication

**Admin token**:
Bearer token จาก Admin Portal login — ใช้เรียก API ตรงๆ ได้ (ไม่ผ่าน Gateway)
_Gotcha_: ใช้กับ Gateway ไม่ได้

**SP token**:
Bearer token จาก SP Portal login — ต้องผ่าน Gateway เท่านั้น
_Gotcha_: ต้อง OTP flow, หมดอายุเร็ว (15-30 นาที)

**Gateway**:
API Gateway ที่รับเฉพาะ SP token — Admin token ส่งมาจะ 401

## Jira Integration

**ADF (Atlassian Document Format)**:
JSON format สำหรับ Jira REST API v3 — structured content, ไม่รองรับ inline image embed ง่ายๆ

**Wiki markup**:
Text format สำหรับ Jira REST API v2 — ใช้ `!filename.png|width=600!` embed image ได้ตรงๆ
_Gotcha_: emoji ต้องเป็นตัวจริง, ticket key จะถูก auto-link

**v2 / v3**:
Jira REST API version — v2 รับ wiki markup, v3 รับ ADF
_Rule_: Bug FE → v2, Bug API → v3 (ตัดสินใจตั้งแต่ Step 3 ห้ามเปลี่ยน)

## Technical

**JXA (JavaScript for Automation)**:
macOS scripting — ใช้ run JS ใน Chrome tab ผ่าน `osascript -l JavaScript`
_Gotcha_: อ่านไฟล์เป็น Latin-1, Thai chars ต้อง escape เป็น `\uXXXX` ก่อน save

**Swagger spec**:
OpenAPI spec ของ CreditPort API — ดึงจาก `/api/json-docs`
_Role_: source of truth สำหรับ expected response (ไม่ใช่ ticket)

## Relationships

- **Ticket** ระบุ **Bug Type** (API หรือ FE) → กำหนด **Comment Format** (v3 ADF หรือ v2 wiki)
- **Admin token** ใช้กับ **Admin Portal** ตรง, **SP token** ใช้ผ่าน **Gateway**
- **Swagger spec** เป็น source of truth, **ticket** เป็น input เท่านั้น
