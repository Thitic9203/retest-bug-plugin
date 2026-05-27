# Credit Port — Bug Retest Guide

Reference สำหรับรีเทสบัคใน Credit Port MHESI ผ่าน Claude Code

---

## Workflow

1. **ดึง Jira ticket** → Atlassian MCP `getJiraIssue`
2. **Login** → Playwright headless
3. **ทดสอบ** → `fetch()` ใน Playwright evaluate
4. **เทียบ Swagger** → `/api/json-docs` เป็น source of truth
5. **เก็บหลักฐาน** → cURL เต็ม + Response เต็ม ทุก case
6. **Draft comment** → แสดงให้ user อนุมัติก่อนเสมอ
7. **Post** → Atlassian MCP `addCommentToJiraIssue`
8. **ปิดงาน** → ปรับสถานะ Ready to Demo + assign กลับ dev + แจ้ง user พร้อมลิงก์

---

## 1. ดึง Jira Ticket

```
Tool: mcp__208b743d-c680-4a36-b054-1030bcf5548d__getJiraIssue
cloudId: humanintelligence.atlassian.net
issueIdOrKey: CP-XXXXX
responseContentFormat: markdown
```

**จับข้อมูล:** Env, Test Step, Expected Result, Actual Result, API endpoint

## 2. Environment

| Env | Admin Portal | Swagger |
|-----|-------------|---------|
| PD3 | `https://pd3-web-portal.mycreditport.com/admin` | `https://pd3-web-portal.mycreditport.com/api/docs` |
| dev | `https://dev-web-portal.mycreditport.com/admin` | `https://dev-web-portal.mycreditport.com/api/docs` |

**Credentials:** `admin@mhesi.com` / `admin123`

## 3. Login (Playwright)

```python
playwright_navigate(url="https://<env>-web-portal.mycreditport.com/admin")
playwright_fill(selector='input[type="email"]', value="admin@mhesi.com")
playwright_fill(selector='input[type="password"]', value="admin123")
playwright_click(selector='button[type="submit"]')
```

**Fallback:** ถ้า login ไม่ผ่าน (OTP, CF WAF) → ขอ Bearer token จาก user

## 4. ทดสอบ API

ใช้ `fetch()` ใน `playwright_evaluate` เรียก API — **ต้องใช้ full URL เสมอ** (ห้ามใช้ relative path)

**Pattern:**
1. **Baseline** — เรียก API แบบปกติ ยืนยันว่า API ทำงาน
2. **Bug case** — เรียก API ตาม test step ที่เคยเจอบัค
3. **Edge cases** — เทสกรณีขอบ (ถ้ามี)
4. **เทียบ Swagger** — ดึง spec จาก `/api/json-docs` เทียบ status code, error message, field name
5. **เทียบผล** — baseline vs bug case ต้องได้ผลตรงตาม Swagger spec (Swagger เป็น source of truth เดียว ไม่ใช่ ticket เพราะ ticket อาจไม่อัปเดต)

## 5. เก็บหลักฐาน

**บัค FE:** แนบรูป + bullet ไม่เกิน 3 ข้อ (พฤติกรรมที่เห็น vs คาดหวัง)

**บัค API — กฎเหล็ก:**
- **cURL เต็ม:** method, full URL, headers, body — copy แล้วรันซ้ำได้ทันที
- **Response เต็ม:** HTTP status, headers (Content-Type, Date, Server), body ทั้ง JSON ไม่ตัด field
- **Swagger reference:** แนบลิงก์ Swagger ของ endpoint ทุกครั้ง
- **ห้ามย่อ:** ห้ามเขียน "เหมือน case X แต่..." หรือ "same as above" — ต้อง cURL เต็มทุก case ไม่มีข้อยกเว้น
- **Date format:** ใช้ YYYY-MM-DD ใน Response headers

## 6. Draft Jira Comment

> **กฎ:** ห้าม post โดยไม่ได้รับอนุมัติจาก user — แสดง draft ก่อนเสมอ
> **กฎ:** ห้ามใส่หางเสียง (ครับ/ค่ะ) — ใช้ภาษากลางเสมอ
> **กฎ:** ห้ามใส่ "Retested by:" — ตัดออกเสมอ

**Template:**

```markdown
**Retest Result: PASSED ✅**   ← หรือ   **Retest Result: FAILED ❌**

**Env:** <ENV> (`<url>`)
**API:** `<HTTP_METHOD> <endpoint>`
**Swagger:** <link to Swagger docs>
**Date:** <YYYY-MM-DD>

---

**Test Step (ตาม ticket):** <test step จาก ticket>
**Expected Result:** <expected result จาก ticket>

| Test Case | Input | Result | Status |
|---|---|---|---|
| Bug case | <bug input> | <result> | ✅/❌ |
| Baseline | <normal input> | <result> | ✅/❌ |
| Edge case | <edge input> | <result> | ✅/❌ |

---

**Evidence — API Response**

> ต้องมี Evidence ครบทุก Test Case ในตาราง — ทุก case ต้องมี cURL เต็ม + Response เต็ม

**1) Bug case**

cURL:
\```
curl -X <METHOD> '<FULL_URL>' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '<full body>'
\```

Response:
\```
HTTP/1.1 <status>
Content-Type: application/json
Date: <YYYY-MM-DD>
Server: <server>

<full JSON response body — ไม่ตัด ไม่ย่อ>
\```

**2) Baseline**

cURL:
\```
curl -X <METHOD> '<FULL_URL>' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '<full body>'
\```

Response:
\```
HTTP/1.1 <status>
Content-Type: application/json
Date: <YYYY-MM-DD>
Server: <server>

<full JSON response body — ไม่ตัด ไม่ย่อ>
\```

**N) Edge case N** ← เพิ่มจนครบทุก case ในตาราง (cURL เต็ม + Response เต็มทุก case)

**Before fix:** <old behavior>
**After fix:** <new behavior>
**ยืนยันข้อมูลเดิมไม่ถูกเปลี่ยนแปลง:** <ยืนยันว่า test data ไม่ถูกแก้ไขหลังเทส>
```

## ตัวอย่าง comment ใน Jira แบบที่ต้องการ — ผลการทดสอบ Bug API

> **กฎเหล็ก:** ใส่ผลการทดสอบ Bug API ให้ใช้ format ตามตัวอย่างด้านล่างนี้เท่านั้น — ห้ามแต่งแต้ม ห้ามเพิ่มเติม ห้ามปรับ layout
> ถ้าไม่แน่ใจให้ดูตัวอย่างนี้เป็น reference เสมอ

```markdown
**Retest Result: PASSED ✅**

**Env:** PD3 (`https://pd3-web-portal.mycreditport.com`)
**API:** `PUT /api/admin/questions/{id}`
**Swagger:** https://pd3-web-portal.mycreditport.com/api/docs#tag/Course-Exam
**Date:** 2026-05-20

---

**Test Step (ตาม ticket):** ระบุ isCorrect: false
**Expected Result:** ระบบควร return code 400 'Questions must have at least 1 correct answer'

**Test data:** question ID `27552444-fb55-42f5-b2b4-dd1be6954597`  (คำถามที่มีอยู่แล้วในระบบ PD3 ใช้เป็น test data สำหรับเทส)

| Test Case | Input | Result | Status |
|---|---|---|---|
| Bug case | answers: [{isCorrect: false}] (1 ข้อ) | 400 — "Questions must have at least 1 correct answer" | ✅ |
| Edge case | answers: [{isCorrect: false} x 3] (3 ข้อ ไม่มีข้อถูก) | 400 — "Questions must have at least 1 correct answer" | ✅ |

---

**Evidence — API Response**

**1) Bug case — 1 answer, isCorrect: false**

cURL:
\```
curl -X PUT 'https://pd3-web-portal.mycreditport.com/api/admin/questions/27552444-fb55-42f5-b2b4-dd1be6954597' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <BEARER_TOKEN>' \
  -d '{"type":"TEXT","question":"test question","explanation":"test","difficulty":"EASY","score":1,"answers":[{"isCorrect":false,"value":"answer1","imageMediaKey":null}]}'
\```

Response:
\```
HTTP/1.1 400
Content-Type: application/json
Date: Wed, 20 May 2026 12:05:48 GMT
Server: cloudflare

{"code":"QBK-8007","message":"Questions must have at least 1 correct answer","correlationId":"ef54edab322bdbc9c9486284b43a560","timestamp":1779278748}
\```

**2) Edge case — 3 answers ทั้งหมด isCorrect: false**

cURL:
\```
curl -X PUT 'https://pd3-web-portal.mycreditport.com/api/admin/questions/27552444-fb55-42f5-b2b4-dd1be6954597' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <BEARER_TOKEN>' \
  -d '{"type":"SINGLE","question":"test","explanation":"test","difficulty":"EASY","score":1,"answers":[{"isCorrect":false,"value":"answer1","imageMediaKey":null},{"isCorrect":false,"value":"answer2","imageMediaKey":null},{"isCorrect":false,"value":"answer3","imageMediaKey":null}]}'
\```

Response:
\```
HTTP/1.1 400
Content-Type: application/json
Date: Wed, 20 May 2026 12:43:56 GMT
Server: cloudflare

{"code":"QBK-8007","message":"Questions must have at least 1 correct answer","correlationId":"b1d3ce66cbd565a73539b7ec057c75f7","timestamp":1779281036}
\```

**Before fix:** PUT isCorrect: false → ได้ 200
**After fix:** PUT isCorrect: false → ได้ 400 "Questions must have at least 1 correct answer" (ทั้ง 1 ข้อและหลายข้อ)
**ยืนยันข้อมูลเดิม:** question ที่ใช้เทสยังคงข้อมูลเดิมทุกอย่างหลังเทสเสร็จ
```

---

## 7. Post Comment

```
Tool: mcp__208b743d-c680-4a36-b054-1030bcf5548d__addCommentToJiraIssue
cloudId: humanintelligence.atlassian.net
issueIdOrKey: CP-XXXXX
contentFormat: markdown
commentBody: <approved comment>
```

---

## 8. ปิดงาน — ปรับสถานะ + Assign กลับ Dev

> **กฎ:** หลังจาก user อนุมัติให้โพสต์ comment แล้ว → ต้องทำ 3 อย่างต่อเนื่องทันทีโดยไม่ต้องถามซ้ำ

### ขั้นตอน

1. **Transition → Ready to Demo**
   ```
   Tool: transitionJiraIssue
   issueIdOrKey: CP-XXXXX
   transition: { id: "<Ready to Demo transition ID>" }
   ```
   > ดึง transition ID จาก `getTransitionsForJiraIssue` ก่อน — หา transition ที่ชื่อ "Ready to Demo"

2. **หาคนที่ปรับ In Progress คนล่าสุด** (dev ที่ทำเรื่องนี้)
   ```
   Tool: getJiraIssue
   issueIdOrKey: CP-XXXXX
   expand: changelog
   ```
   > ค้นหา changelog history ที่ `field: "status"` + `toString: "In Progress"` → เอา `author.accountId` ของ entry ล่าสุด

3. **Assign กลับไปหา dev คนนั้น**
   ```
   Tool: editJiraIssue
   issueIdOrKey: CP-XXXXX
   fields: { assignee: { accountId: "<dev accountId จากข้อ 2>" } }
   ```

4. **แจ้ง user** — พิมพ์ข้อความ:
   ```
   เรียบร้อยแล้ว รีวิวผลงานได้ที่ https://humanintelligence.atlassian.net/browse/CP-XXXXX
   ```
   > ใส่ลิงก์ ticket จริง ให้กดได้เลย

---

## เทียบผลกับ Swagger Spec

> **Swagger เป็น source of truth ล่าสุดของ API spec**

> **กฎเหล็ก:** ถ้า response (status code หรือ message) ไม่ตรงกับ Swagger spec → **FAILED เสมอ ไม่มีข้อยกเว้น** แม้บัคจะเป็นเรื่อง response code แต่ถ้า message ไม่ตรงก็ถือว่าไม่ผ่าน (ใช้ Swagger เป็น source of truth เดียว ไม่ใช้ expected result จาก ticket เพราะ ticket อาจไม่อัปเดต)

### วิธีดึง

```javascript
fetch('https://<env>-web-portal.mycreditport.com/api/json-docs')
  .then(r => r.json())
  .then(spec => {
    var ep = spec.paths['/api/admin/<endpoint>'];
    return JSON.stringify({ responses: ep.put.responses, schema: ep.put.requestBody.content['application/json'].schema }, null, 2);
  })
```

### Checklist เทียบ

| ตรวจสอบ | ดูจาก Swagger | ตัวอย่าง |
|---------|--------------|---------|
| Status code | `responses` → `200`, `400`, `500` | ticket คาดหวัง 400 แต่ได้ 200 |
| Field constraints | `schema.properties.<field>` → `maxLength`, `enum` | `title` มี `maxLength: 50` หรือไม่ |
| Error message | response จริง vs spec | ถ้า spec ไม่กำหนด → validation อยู่ที่ application layer |
| Required fields | `schema.required` | field ไหนบังคับส่ง |
| additionalProperties | `additionalProperties: false` | ส่ง field แปลกปลอมจะโดน reject หรือ strip |

### ข้อควรระวัง

- **Swagger อาจไม่มี validation ทั้งหมด** — บาง validation อยู่ที่ application layer (เช่น `isLexicalTextValid`) ไม่ปรากฏใน schema
- **Swagger กำหนดแต่ API ไม่ validate** → bug ชัดเจน
- **Swagger ไม่กำหนดกรณีนี้ไว้** → ใช้ status **BLOCKED** แล้วระบุเหตุผลว่า "Swagger {{URL of swagger}} ไม่ได้ระบุกรณีนี้ไว้"

### เทียบ Response Message กับ Confluence Error Documentation

> **กฎ:** Swagger ไม่ได้ระบุ error message เฉพาะเจาะจง (ระบุแค่ status code เช่น 400, 404) — ให้ใช้ [Confluence Error Documentation](https://humanintelligence.atlassian.net/wiki/spaces/CPM/pages/65273857/Error+Documentation) เป็น source of truth สำหรับ response message แทน **ภายใต้เงื่อนไขว่า response code ที่ได้จริงต้องตรงกับทั้ง Swagger และ Confluence**

**ลำดับการเทียบ:**
1. **Response code** → เทียบกับ Swagger spec ก่อน (ต้องตรง)
2. **Response message** → ถ้า Swagger ไม่ได้ระบุ message → ดู Confluence Error Documentation (Error Code table ของแต่ละ service)
3. **ถ้า response code ตรง Swagger + response message ตรง Confluence** → **PASSED**
4. **ถ้า response code ไม่ตรง Swagger** → **FAILED** (ไม่ว่า message จะตรง Confluence หรือไม่)
5. **ถ้า response code ตรง Swagger แต่ message ไม่ตรง Confluence** → **FAILED** พร้อมระบุ message ที่คาดหวัง (จาก Confluence) vs ที่ได้จริง
6. **ถ้าทั้ง Swagger และ Confluence ไม่ได้ระบุกรณีนี้** → **BLOCKED**

**Confluence Error Documentation:** `https://humanintelligence.atlassian.net/wiki/spaces/CPM/pages/65273857/Error+Documentation`

> **กฎเหล็ก:** เมื่ออ้างอิง Confluence ใน Jira comment → **ต้องแปะลิงก์ Confluence ที่อ้างอิงมาด้วยเสมอ** ห้ามอ้างลอยๆ โดยไม่มีลิงก์

**ตัวอย่าง:** Question Bank Service → QBK-8030 = "Question is required" — ถ้า API return 400 + message "Question is required" → เทียบ Swagger (400 อยู่ใน responses) + เทียบ Confluence (QBK-8030 ตรง) = PASSED

---

## Gotchas

### Playwright

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|------|
| `about:blank` หลัง evaluate หลายรอบ | Session หาย | เช็ค `window.location.href` ก่อนทุก step → ถ้าหาย navigate + login ใหม่ |
| `SyntaxError: await` | evaluate ไม่รองรับ top-level await | ใช้ `.then()` chain หรือ wrap ด้วย `(async () => { ... })()` |
| Screenshot timeout | Font loading ของ Payload CMS | ใช้ `fetch()` เก็บ API response แทน (เร็วกว่า + ชัดกว่า) |
| Thai chars ใน URL พัง | `encodeURIComponent` กับ Thai | ใส่ Thai ตรงๆ ใน URL — browser จัดการ encoding เอง |

### Authentication

| ปัญหา | แก้ไข |
|-------|------|
| OTP (2FA) | ถาม user ดึง OTP จาก email/DB |
| CF WAF block headless | ใช้ `x-test-bypass` header หรือขอ token จาก user |
| Token หมดอายุ (15-30 นาที) | Login ใหม่ — ทำเทสให้จบเร็วที่สุด |

### Jira Comment

| ปัญหา | แก้ไข |
|-------|------|
| ไม่มี edit/delete comment tool | Draft ให้ครบในรอบเดียว ให้ user อนุมัติก่อน post |
| Inline code strips spaces | ใช้ code block แทน |
| MCP เชื่อมผิด site | ต้องเชื่อม `humanintelligence.atlassian.net` — เทส `getJiraIssue` ก่อนเริ่มงาน |

---

## Postmortem — บทเรียนและแนวทางแก้ปัญหาที่พบบ่อย

### ปัญหา: ใช้ผิด service / ผิด token realm

- **Web-portal ≠ API Gateway** — endpoint ที่ขึ้นต้น `/api/courses/...`, `/api/learning/...` ไม่ได้อยู่บน web-portal แต่อยู่บน **API Gateway** (`pd3-api-gateway.mycreditport.com/api`)
- **Admin token ใช้กับ Gateway ไม่ได้** — Gateway รับเฉพาะ SP token จาก Keycloak realm `mhesi-pd3` เท่านั้น ไม่ใช่ realm `mhesi-bo-pd3` (admin/BO)
- **ดูจาก ticket ว่า role ไหน** — ถ้า ticket ระบุ "SP JWT token" หรือมี tag `[SP]` → ต้องใช้ SP token ห้ามใช้ admin token

### วิธีเช็คที่เร็วที่สุด: ดู tag ใน ticket title ก่อนเริ่ม

- `[SP]` → SP portal + API Gateway + SP token (realm `mhesi-pd3`)
- `[BO]` / `[Admin]` → web-portal + admin token (realm `mhesi-bo-pd3`)
- ถ้าไม่มี tag → ดู test step ใน ticket ว่าใช้ token แบบไหน

### ปัญหา: หา SP token ไม่ได้

- **Keycloak direct grant ใช้ไม่ได้** — ไม่รู้ client_id ของ realm `mhesi-pd3` ลองไป 25+ ชื่อก็ invalid ทั้งหมด
- **NextAuth `password` provider ไม่ได้ให้ JWT** — login ผ่าน NextAuth callback สร้างแค่ session cookie ไม่ได้สร้าง Keycloak JWT
- **ต้อง login ผ่าน UI เต็ม flow** — กรอก email/password → submit → รับ OTP จาก email → verify OTP → JWT เก็บใน `localStorage.access_token`

### แนวทางที่ได้ผลสูงสุดสำหรับ SP token

1. เปิด SP portal (`pd3-sp.mycreditport.com`) ด้วย Playwright
2. กรอก email/password (ใช้ yopmail test accounts เช่น `creditport-mhesi-09@yopmail.com` / `P@ssw0rd`)
3. Submit form → ระบบส่ง OTP ไป yopmail
4. เปิด yopmail inbox ด้วย Playwright → อ่าน OTP จาก email
5. กรอก OTP ใน SP portal → login สำเร็จ
6. ดึง JWT จาก `localStorage.access_token`
7. ใช้ JWT นี้เรียก API Gateway

### ปัญหา: SP form submit ไม่ทำงาน

- React form บน SP portal อาจไม่ trigger submit ถ้า fill แบบ programmatic เฉยๆ
- **ต้อง click input field ก่อน fill** — click `#email` → fill → click `#password` → fill → click submit button
- NextAuth provider ID คือ `password` ไม่ใช่ `credentials` (ดูได้จาก `/api/auth/providers`)

### Architecture สรุป

```
SP Frontend → API Gateway (pd3-api-gateway.mycreditport.com/api) → Learning Service / Question Bank Service
                ↑ ต้องใช้ SP token (realm mhesi-pd3)

BO/Admin Frontend → Web Portal (pd3-web-portal.mycreditport.com/api) → ตรงไป backend
                ↑ ต้องใช้ Admin token (realm mhesi-bo-pd3)
```

### SP Test Accounts (yopmail)

| Account | Password |
|---------|----------|
| `creditport-mhesi-09@yopmail.com` | `P@ssw0rd` |
| `creditport-mhesi-20@yopmail.com` | `P@ssw0rd` |
| `creditport-mhesi-21@yopmail.com` | `P@ssw0rd` |
| `creditport-mhesi-99@yopmail.com` | `P@ssw0rd` |
| `pd3-skl-qa-001@yopmail.com` | `P@ssw0rd` |
| `pd3-skl-qa-002@yopmail.com` | `P@ssw0rd` |
| `pd3-skl-qa-003@yopmail.com` | `P@ssw0rd` |

---

## Quick Reference

| Key | Value |
|-----|-------|
| Jira CloudId | `humanintelligence.atlassian.net` |
| Confluence Technical Doc | [page 12157803](https://humanintelligence.atlassian.net/wiki/spaces/CPM/pages/12157803/Technical+Document) |
| Confluence Ticket & Workflow | [page 14483746](https://humanintelligence.atlassian.net/wiki/spaces/CPM/pages/14483746) |
| Admin credentials | `admin@mhesi.com` / `admin123` |
| Keycloak | `keycloak.mycreditport.com` |
| Swagger (PD3) | `https://pd3-web-portal.mycreditport.com/api/docs` |
| Swagger (dev) | `https://dev-web-portal.mycreditport.com/api/docs` |
| Swagger JSON (PD3) | `https://pd3-web-portal.mycreditport.com/api/json-docs` |
