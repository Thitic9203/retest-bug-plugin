---
name: retest-bug-workflow
description: This skill should be used when retesting a bug from a Jira ticket, verifying a bug fix, or checking whether an issue is resolved on CreditPort environments. Handles the full retest flow — reading the ticket, logging into the portal, running API or FE tests, comparing responses against Swagger spec, drafting a Jira comment with full evidence, posting the comment, transitioning the ticket, and assigning it back to the dev. Common triggers — "retest this bug", "verify the fix on CP-12345", "check if CP-12345 is fixed", "retest bug CP-12345".
---

# Retest Bug Workflow

## Overview

Skill สำหรับรีเทสบัคจาก Jira ticket แบบครบ flow — ดึง ticket, login, ทดสอบ, เทียบ Swagger, draft comment, post, ปิดงาน

## Step 0 — รับ Ticket

ถ้า user ยังไม่ได้ระบุ ticket:

> ต้องการให้รีเทสบัคไหนครับ กรุณาระบุลิงก์หรือ ticket key (เช่น CP-12345 หรือ https://humanintelligence.atlassian.net/browse/CP-12345)

**รอ user ตอบก่อน** — ห้ามทำอะไรจนกว่าจะได้ ticket

เมื่อได้ ticket แล้ว → แยก issue key (เช่น `CP-12345`) จากลิงก์หรือข้อความ

---

## Step 1 — อ่าน Retest Guide

อ่าน guide ก่อนเริ่มทำงานเสมอ:

```
Read file: /Users/thitichaya/Documents/Claude/credit-port-bug-retest-guide.md
```

> **Prerequisite:** ไฟล์ guide ต้องอยู่ที่ path ด้านบน — ถ้าใช้เครื่องอื่นให้ปรับ path ให้ตรง

**กฎเหล็ก:** ปฏิบัติตาม guide ทุกข้อ — template, format, กฎเหล็กทุกข้อ ห้ามข้าม ห้ามดัดแปลง

---

## Step 2 — ดึง Jira Ticket

ใช้ Atlassian MCP ดึงรายละเอียด ticket:

```
Tool: Atlassian MCP → getJiraIssue
cloudId: humanintelligence.atlassian.net
issueIdOrKey: <TICKET_KEY>
responseContentFormat: markdown
```
> MCP tool ID อาจต่างกันในแต่ละ session — ใช้ ToolSearch หา "getJiraIssue" เพื่อหา tool ID จริง

**จับข้อมูลจาก ticket:**
- Environment (PD3 / dev)
- Test Steps
- Expected Result
- Actual Result
- API endpoint
- Bug type tag: `[SP]` = SP token, `[BO]`/`[Admin]` = Admin token

---

## Step 3 — จำแนก Bug Type + เลือก Skill + กำหนด Comment Format

> **⚠️ ตัดสินใจ 3 อย่างพร้อมกันตั้งแต่ Step นี้ — ห้ามเปลี่ยนกลางทาง**

### 3a. จำแนก Bug Type → กำหนด Comment Format ทันที

| Bug Type | ต้อง screenshot? | Comment Format | API Endpoint |
|----------|-----------------|----------------|-------------|
| **Bug API** | ไม่ | v3 ADF | `/rest/api/3/.../comment` |
| **Bug FE / UI** | **ต้อง** | **v2 wiki markup** | `/rest/api/2/.../comment` |

> **กฎเหล็ก:** ถ้า ticket เป็น Bug FE → ตั้ง flag `COMMENT_FORMAT=v2` ตั้งแต่ตรงนี้ แล้วใช้ตลอด session
> ห้ามเริ่ม v3 แล้วเปลี่ยนมา v2 ทีหลัง — format ต่างกันหมด เสียเวลาทำซ้ำ

### 3b. เลือก Skill ที่เหมาะสม

1. **Bug API (เป้าหมายหลัก)** → ใช้ **Playwright MCP** (`mcp__playwright__*`)
   - Login ผ่าน Playwright
   - เรียก API ผ่าน `playwright_evaluate` + `fetch()`
   - เทียบ Swagger spec

2. **Bug FE / UI** → ใช้ **Playwright MCP** + **superpowers-chrome** (Chrome ของ user)
   - ถ้าต้องดู UI จริง → ใช้ `superpowers-chrome:browsing` skill เปิดหน้าจอใน Chrome ของ user
   - ถ้า headless พอ → ใช้ Playwright MCP ตรง

3. **Bug ที่ต้องทดสอบหลาย case ซับซ้อน** → ใช้ skill `superpowers:systematic-debugging`
   - วิเคราะห์ root cause อย่างเป็นระบบ
   - วาง test cases ให้ครบทุก edge case

4. **Bug ที่ต้องตรวจ code** → ใช้ skill `superpowers:verification-before-completion`
   - ตรวจสอบว่า fix ครบจริง

### การเรียก Skill

```
Skill tool: <skill-name>
```

หลังจากเรียก skill แล้ว → กลับมาทำ Step 4-8 ต่อเสมอ

---

## Step 4 — Login + ทดสอบ

### 4a. ระบุ Environment

| Tag ใน ticket | Portal | Base URL | Token type |
|---|---|---|---|
| `[BO]` / `[Admin]` / ไม่มี tag | Admin Portal | `https://<env>-web-portal.mycreditport.com` | Admin token |
| `[SP]` | SP Portal | `https://<env>-sp.mycreditport.com` | SP token (ต้อง OTP flow) |

### 4b. Login ผ่าน Playwright

**Admin (BO):**
```
playwright_navigate → <env>-web-portal.mycreditport.com/admin
playwright_fill → email: <ดู credentials ใน retest guide>
playwright_fill → password: <ดู credentials ใน retest guide>
playwright_click → submit button
```
> Credentials อยู่ใน retest guide section "Environment" — ห้ามใส่ password ตรงๆ ใน skill file

**SP:** ต้อง login ผ่าน UI + OTP flow (ดูรายละเอียดใน guide section "SP token")

**Fallback:** ถ้า login ไม่ผ่าน (OTP, CF WAF) → ขอ Bearer token จาก user แล้วรอ

### 4c. จัดเตรียม Test Data

> **กฎเหล็ก:** ห้ามบอกว่า "ทดสอบไม่ได้เพราะไม่มีข้อมูล" — ต้องหาทางสร้าง/จัดเตรียมข้อมูลเพื่อทดสอบมาให้ได้เสมอ

**ลำดับหา test data:**

1. **ใช้ข้อมูลที่มีอยู่** — GET list API เพื่อหา record ที่ใช้ทดสอบได้
2. **สร้างข้อมูลใหม่** — ถ้าไม่มี record ที่เหมาะ → POST/CREATE ผ่าน API สร้างขึ้นมาเอง
3. **ใช้ Swagger schema เป็นแนวทาง** — ดู required fields + constraints จาก `/api/json-docs` แล้วสร้าง payload ที่ถูกต้อง
4. **Clone จาก record ที่มี** — GET record ที่มีอยู่ → แก้ field ที่ต้องการ → POST เป็น record ใหม่
5. **ถาม user เป็นทางเลือกสุดท้าย** — เฉพาะกรณีที่ต้องใช้ข้อมูลเฉพาะทางจริงๆ ที่สร้างเองไม่ได้ (เช่น ข้อมูลจาก external system)

**ข้อควรระวัง:**
- ใช้ชื่อที่ระบุชัดว่าเป็น test data (เช่น prefix `[TEST]` หรือ `test-retest-`)
- ห้ามแก้ไข/ลบข้อมูลจริงในระบบ — สร้างใหม่เสมอ
- บันทึก ID ของ test data ที่สร้าง เพื่อยืนยันข้อมูลเดิมไม่ถูกเปลี่ยนแปลงหลังเทส

### 4d. ทดสอบ API

ใช้ `playwright_evaluate` + `fetch()` เรียก API — **ต้องใช้ full URL เสมอ**

**Pattern ทดสอบ:**
1. **Baseline** — เรียก API แบบปกติ
2. **Bug case** — เรียกตาม test step ที่เคยเจอบัค
3. **Edge cases** — กรณีขอบ (ถ้ามี)

### 4e. เทียบ Swagger

ดึง spec จาก `/api/json-docs`:

```javascript
fetch('https://<env>-web-portal.mycreditport.com/api/json-docs')
  .then(r => r.json())
  .then(spec => { /* เทียบ responses, schema */ })
```

**ลำดับเทียบ:**
1. Response code → ต้องตรง Swagger
2. Response message → ถ้า Swagger ไม่ระบุ → ดู Confluence Error Documentation
3. ทั้งคู่ตรง → PASSED
4. Code ไม่ตรง → FAILED
5. Code ตรงแต่ message ไม่ตรง → FAILED
6. ทั้ง Swagger + Confluence ไม่ระบุ → BLOCKED

**Confluence Error Documentation:** `https://humanintelligence.atlassian.net/wiki/spaces/CPM/pages/65273857/Error+Documentation`

---

## Step 5 — เก็บหลักฐาน

### Bug API — กฎเหล็ก:
- **cURL เต็ม:** method, full URL, headers, body — copy แล้วรันซ้ำได้ทันที
- **Response เต็ม:** HTTP status, headers (Content-Type, Date, Server), body ทั้ง JSON ไม่ตัด field
- **Swagger reference:** แนบลิงก์ Swagger ของ endpoint ทุกครั้ง
- **ห้ามย่อ:** ห้ามเขียน "เหมือน case X" หรือ "same as above" — cURL เต็มทุก case
- **Date format:** ใช้ YYYY-MM-DD ใน Response headers

### Bug FE — กฎเหล็ก:
- **ต้องแนบ screenshot ทุก test case** — upload เป็น attachment ของ issue ก่อน แล้ว embed inline ใน comment
- **ชื่อไฟล์ชัดเจน** — ตั้งชื่อตาม pattern `tc<N>-<description>.png` (เช่น `tc1-toast-schedule.png`, `tc2-toast-delete.png`)
- **bullet ไม่เกิน 3 ข้อต่อ case** — อธิบายพฤติกรรมที่เห็น vs คาดหวัง
- **ห้ามละรูป** — ถ้าเทสหน้าเว็บ/UI ต้องมีภาพประกอบทุก case ไม่มีข้อยกเว้น
- **embed ภาพ inline** — ใช้ `!filename.png|width=600!` ใน wiki markup (ดู Step 7c)

**วิธี upload screenshot ผ่าน Jira REST API (browser session):**
```javascript
// อ่านไฟล์เป็น base64 ด้วย Node.js แล้วสร้าง JS ที่ upload ผ่าน Chrome
var b64 = '<base64 data>';
var binary = atob(b64);
var arr = new Uint8Array(binary.length);
for (var j = 0; j < binary.length; j++) arr[j] = binary.charCodeAt(j);
var blob = new Blob([arr], {type: 'image/png'});
var fd = new FormData();
fd.append('file', blob, 'tc1-toast.png');
fetch('/rest/api/3/issue/<TICKET>/attachments', {
  method: 'POST',
  headers: {'X-Atlassian-Token': 'no-check'},
  credentials: 'include',
  body: fd
});
```

---

## Step 6 — Draft Jira Comment

> **กฎ:** ห้าม post โดยไม่ได้รับอนุมัติจาก user — แสดง draft ก่อนเสมอ
> **กฎ:** ห้ามใส่หางเสียง (ครับ/ค่ะ) — ใช้ภาษากลาง
> **กฎ:** ห้ามใส่ "Retested by:" — ตัดออกเสมอ

### Template:

```markdown
**Retest Result: PASSED ✅**   ← หรือ   **Retest Result: FAILED ❌**

**Env:** <ENV> (`<url>`)
**API:** `<HTTP_METHOD> <endpoint>`
**Swagger:** <link>
**Date:** <YYYY-MM-DD>

---

**Test Step (ตาม ticket):** <test step จาก ticket>
**Expected Result:** <expected result จาก ticket>

| Test Case | Input | Result | Status |
|---|---|---|---|
| Bug case | <input> | <result> | ✅/❌ |
| Baseline | <input> | <result> | ✅/❌ |
| Edge case | <input> | <result> | ✅/❌ |

---

**Evidence — API Response**

> cURL เต็ม + Response เต็มทุก case (ดู guide สำหรับ format)

**Before fix:** <old behavior>
**After fix:** <new behavior>
**ยืนยันข้อมูลเดิมไม่ถูกเปลี่ยนแปลง:** <ยืนยัน>
```

**แสดง draft ให้ user อนุมัติก่อน — รอจนกว่าจะได้คำตอบ**

---

## Step 7 — Post Comment

หลัง user อนุมัติแล้ว:

### เลือก API version ก่อนโพสต์ (ตัดสินใจตั้งแต่ต้น ห้ามเปลี่ยนกลางทาง)

| เงื่อนไข | API | เหตุผล |
|----------|-----|--------|
| Bug FE / มี screenshot ที่ต้อง embed inline | **v2** wiki markup | v3 ADF ไม่มี `mediaApiFileId` → embed ภาพ inline ไม่ได้ |
| Bug API / ไม่มี screenshot | **v3** ADF | format สมบูรณ์กว่า, MCP รองรับ |

> **กฎ:** ตัดสินใจ v2 หรือ v3 ตั้งแต่ Step 6 (draft) แล้วใช้ตลอด — ห้ามเริ่ม v3 แล้วเปลี่ยนมา v2 ทีหลัง เพราะ format ต่างกันหมด

### Pre-post checklist + Dry-run (ตรวจก่อนโพสต์ทุกครั้ง — ข้ามไม่ได้)

**Checklist (ตรวจใน code ก่อน save JS file):**
- [ ] emoji ❌ ✅ เป็นตัวจริงใน template literal (ไม่ใช่ `\\u274c`)
- [ ] ไม่มี ticket key (เช่น `CP-12345`) ใน free text ที่จะโดน auto-link
- [ ] JS file เป็น ASCII ล้วน (`/[^\x00-\x7F]/.test(js)` = false)
- [ ] endpoint ตรงกับ format (v2 = wiki markup, v3 = ADF)

**Dry-run (ตรวจ output หลัง save JS file — ก่อนโพสต์จริง):**
```javascript
// อ่าน JS file กลับมา → decode \uXXXX → ตรวจว่า content ถูกต้อง
const saved = fs.readFileSync('/tmp/jira-comment.js', 'utf-8');
const decoded = saved.replace(/\\u([0-9a-f]{4})/gi, (_, hex) =>
  String.fromCharCode(parseInt(hex, 16))
);
// ตรวจสอบ:
// 1. ❌ ✅ เป็น emoji จริง (ไม่ใช่ ❌ literal)
console.log('Has real emoji:', /[❌✅]/.test(decoded));
// 2. ไม่มี ticket key ที่จะ auto-link
console.log('Has ticket key:', /[A-Z]+-\d+/.test(decoded));
// 3. ภาษาไทยอ่านได้
console.log('Thai sample:', decoded.match(/[฀-๿]+/)?.[0]);
```
> ถ้า dry-run fail → แก้ template แล้ว re-generate ก่อนโพสต์ — ห้ามโพสต์แล้วค่อยแก้ทีหลัง

### 7a. ลอง Atlassian MCP ก่อน
```
Tool: Atlassian MCP → addCommentToJiraIssue
cloudId: humanintelligence.atlassian.net
issueIdOrKey: <TICKET_KEY>
contentFormat: markdown
commentBody: <approved comment>
```
> ใช้ ToolSearch หา "addCommentToJiraIssue" เพื่อหา tool ID จริง

### 7b. Fallback — JXA + Chrome (ถ้า MCP 403)

> **⚠️ ขั้นตอนนี้มี gotcha เรื่อง encoding ภาษาไทย — ดู section "JXA + ภาษาไทย" ด้านล่างเสมอ**

**Pipeline ที่ถูกต้อง (ต้องทำตามนี้ทุกครั้ง ห้ามลัด):**

**Step A — Node.js: สร้าง ADF body + escape เป็น ASCII-safe JS file**
```javascript
// 1. สร้าง ADF body ด้วยภาษาไทยจริงๆ
const body = { type:'doc', version:1, content:[...] }; // Thai text ตรงๆ

// 2. JSON.stringify ก่อน (ได้ JSON string ที่มี Thai chars)
const bodyStr = JSON.stringify({ body });

// 3. escape non-ASCII หลัง JSON.stringify เพื่อสร้าง JS string literal ที่ปลอดภัย
const safe = bodyStr
  .replace(/\\/g, '\\\\')
  .replace(/'/g, "\\'")
  .replace(/[^\x00-\x7F]/g, c => '\\u' + c.charCodeAt(0).toString(16).padStart(4,'0'));

// 4. สร้าง JS code ที่จะรันใน Chrome
const js = "window.__cr=null;fetch('https://humanintelligence.atlassian.net/rest/api/3/issue/<TICKET>/comment',"
  + "{method:'POST',headers:{'Content-Type':'application/json','X-Atlassian-Token':'no-check'},"
  + "credentials:'include',body:'" + safe + "'}).then(r=>r.json().then(b=>{"
  + "window.__cr={status:r.status,id:b.id};})).catch(e=>{window.__cr={err:e.toString()};});";

// 5. บันทึกด้วย ascii encoding + ตรวจสอบ
fs.writeFileSync('/tmp/jira-fetch.js', js, 'ascii');
const hasNonAscii = /[^\x00-\x7F]/.test(js);
if (hasNonAscii) throw new Error('STILL HAS NON-ASCII!');
```

**Step B — JXA: อ่าน JS file แล้วรันใน Chrome Jira tab**
```bash
# trigger
osascript -l JavaScript << 'EOF'
var app = Application.currentApplication(); app.includeStandardAdditions = true;
var jsCode = app.read("/tmp/jira-fetch.js");
var chrome = Application('Google Chrome');
var wins = chrome.windows();
var jiraTab = null;
for (var wi=0;wi<wins.length;wi++){var tabs=wins[wi].tabs();
  for (var ti=0;ti<tabs.length;ti++){if(tabs[ti].url().includes('atlassian.net')){jiraTab=tabs[ti];}}}
jiraTab ? (jiraTab.execute({javascript: jsCode}), "triggered") : "NO_JIRA_TAB";
EOF

# wait + read result
sleep 4
osascript -l JavaScript << 'EOF2'
var chrome = Application('Google Chrome');
var wins = chrome.windows();
var jiraTab = null;
for (var wi=0;wi<wins.length;wi++){var tabs=wins[wi].tabs();
  for (var ti=0;ti<tabs.length;ti++){if(tabs[ti].url().includes('atlassian.net')){jiraTab=tabs[ti];}}}
jiraTab ? jiraTab.execute({javascript: "JSON.stringify(window.__cr)"}) : "NO_TAB";
EOF2
```

**ห้ามลัดขั้นตอน — ถ้าข้าม Step A ข้อ 3 จะได้ฟ้อนท์ต่างดาวทันที**

### 7c. Bug FE ที่มี screenshot — ใช้ v2 API + wiki markup (แทน v3 ADF)

> **⚠️ ใช้ v2 เมื่อต้อง embed ภาพ inline** — v3 ADF ต้องใช้ `mediaSingle` node + `mediaApiFileId` ซึ่ง Jira REST API ไม่ return → ใช้ v2 wiki markup `!filename.png|width=600!` แทน

**Pipeline (เหมือน 7b แต่เปลี่ยน body format + endpoint):**

```javascript
// Node.js: สร้าง wiki markup body
const wikiBody = `*Retest Result: FAILED ❌*

*Env:* PD3 ({{https://pd3-web-portal.mycreditport.com/admin}})
*Date:* 2026-05-26

----

||Test Case||Action||Result||Status||
|TC1|...|...|❌|

----

*Evidence*

*TC1 — description:*
Toast ที่ปรากฏ: {{ข้อความจริง}}

!tc1-screenshot.png|width=600!
`;

// JSON.stringify → escape → save
const payload = JSON.stringify({ body: wikiBody });
const safe = payload
  .replace(/\\/g, '\\\\')
  .replace(/'/g, "\\'")
  .replace(/[^\x00-\x7F]/g, c => '\\u' + c.charCodeAt(0).toString(16).padStart(4,'0'));

// ⚠️ ใช้ /rest/api/2/ ไม่ใช่ /rest/api/3/
const js = "fetch('https://humanintelligence.atlassian.net/rest/api/2/issue/<TICKET>/comment',"
  + "{method:'POST',headers:{'Content-Type':'application/json','X-Atlassian-Token':'no-check'},"
  + "credentials:'include',body:'" + safe + "'})...";

fs.writeFileSync('/tmp/jira-v2-comment.js', js, 'ascii');
```

**กฎเหล็ก v2 wiki markup:**
- **emoji/icon ใช้ตัวจริงเท่านั้น** — เขียน `❌` ตรงๆ ใน template literal, ห้ามเขียน `\\u274c` (double backslash) เพราะจะกลายเป็น literal text
- **Jira auto-links issue keys** — `CP-12345` ใน text จะโดน expand เป็น ticket link ทั้งดุ้น. แก้โดยเลี่ยงใส่ ticket key ใน toast text / table cell หรือครอบด้วย `{{CP-12345}}` (monospace)
- **`!filename.png|width=600!`** — ไฟล์ต้อง upload เป็น attachment ก่อน (Step 5) ถึงจะ embed ได้
- **endpoint ต้องเป็น v2** — `/rest/api/2/issue/<TICKET>/comment` (v3 ไม่รับ wiki markup)

---

## Step 8 — ปิดงาน (ทำต่อเนื่องทันทีหลัง post comment ไม่ต้องถามซ้ำ)

### 8a. Transition ตามผลเทส

| ผลเทส | Transition target |
|-------|------------------|
| PASSED | Ready to Demo |
| FAILED | In Progress |

ดึง transition ID ก่อน:
```
Tool: getTransitionsForJiraIssue → หา transition ตามตารางด้านบน
Tool: transitionJiraIssue → ใช้ transition ID ที่ได้
```

### 8b. หา dev ที่ทำเรื่องนี้ (คนที่ move → In Progress ล่าสุด)

```
Tool: getJiraIssue (expand: changelog)
→ ค้น changelog: field="status", toString="In Progress"
→ เอา author.accountId ของ entry ล่าสุด
```

### 8c. Assign กลับ dev คนนั้น (ทั้ง PASSED และ FAILED)

```
Tool: editJiraIssue
fields: { assignee: { accountId: "<dev accountId>" } }
```

### 8d. แจ้ง user

```
เรียบร้อยแล้ว รีวิวผลงานได้ที่ https://humanintelligence.atlassian.net/browse/<TICKET_KEY>
```

---

## Gotchas

> รายละเอียดเต็มอยู่ใน `references/gotchas.md` — อ่านเมื่อเจอปัญหา encoding, v2 wiki markup, หรือ JXA Thai chars

**สรุปสั้น:**
- `about:blank` หลัง evaluate → เช็ค `window.location.href` ก่อนทุก step
- ใช้ full URL เสมอ (ห้าม relative path)
- Admin token ใช้กับ Gateway ไม่ได้ — ต้องใช้ SP token
- v2 wiki markup: emoji ใช้ตัวจริง, ticket key ครอบด้วย `{{...}}`, endpoint ต้องเป็น v2
- JXA Thai: `JSON.stringify` ก่อน → escape non-ASCII หลัง → save เป็น ASCII

---

## Critical Rules

1. **อ่าน guide ก่อนเริ่มเสมอ** — `/Users/thitichaya/Documents/Claude/credit-port-bug-retest-guide.md`
2. **ห้าม post comment โดยไม่ได้อนุมัติ** — draft ก่อนเสมอ
3. **cURL + Response เต็มทุก case** — ห้ามย่อ ห้าม "same as above"
4. **Swagger = source of truth** — ไม่ใช่ ticket (ticket อาจไม่อัปเดต)
5. **ห้ามใส่ ครับ/ค่ะ ใน Jira comment** — ใช้ภาษากลาง
6. **ห้ามใส่ "Retested by:"** — ตัดออกเสมอ
7. **ใช้ "Retest Result: PASSED ✅" หรือ "Retest Result: FAILED ❌" เท่านั้น** — ห้ามรูปแบบอื่น
8. **Step 8 ทำต่อเนื่องหลัง post** — ไม่ต้องถามซ้ำ (transition + assign + แจ้ง user)
9. **ห้ามบอกว่าทดสอบไม่ได้เพราะไม่มีข้อมูล** — ต้องหาทางสร้าง/จัดเตรียม test data มาให้ได้เสมอ (ดู Step 4c)
10. **ตัดสินใจ v2/v3 ตั้งแต่ Step 3** — Bug FE → v2 wiki markup, Bug API → v3 ADF (ห้ามเปลี่ยนกลางทาง)
11. **Dry-run ก่อนโพสต์ทุกครั้ง** — decode \uXXXX กลับมาตรวจ emoji + Thai + ticket key ก่อนส่งจริง (ดู Step 7 Pre-post checklist)

---

## Post-Mortem Log

> รายละเอียดเต็มอยู่ใน `references/post-mortem-log.md`
>
> **สรุป PM-1 (CP-11507):** ตัดสินใจ v2/v3 ตั้งแต่ต้น + dry-run ก่อนส่ง = ไม่ต้อง re-post
