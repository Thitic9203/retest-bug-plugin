# Gotchas — Retest Bug Workflow

## General

- `about:blank` หลัง evaluate หลายรอบ → เช็ค `window.location.href` ก่อนทุก step
- `SyntaxError: await` → ใช้ `.then()` chain หรือ wrap ด้วย IIFE
- ใช้ full URL เสมอ (ห้าม relative path)
- ดู project config สำหรับ token type + ข้อจำกัดเฉพาะโปรเจกต์ (เช่น token ใช้ข้าม portal ไม่ได้)
- Login ใหม่ถ้า token หมดอายุ (ดู expiry ใน project config)

## v2 Wiki Markup Gotchas

| ทำผิด | ผลลัพธ์ใน Jira |
|-------|---------------|
| ใช้ `\\u274c` (double backslash) ใน template literal | literal text `❌` แทน ❌ |
| ใส่ ticket key เช่น `PROJ-123` ใน text | Jira auto-link เป็น ticket ทั้ง title + status |
| ใช้ v3 endpoint (`/rest/api/3/`) กับ wiki markup body | Error / format ผิด |

**วิธีที่ถูก:**
- emoji: เขียนตัวจริง `❌` `✅` ใน template literal → escape step จัดการให้
- ticket key: เลี่ยงใส่ หรือใช้ `{{PROJ-123}}` monospace
- endpoint: ใช้ v2 เท่านั้น สำหรับ wiki markup

## JXA + ภาษาไทย — encoding พัง (สำคัญมาก ผิดซ้ำ = ฟ้อนท์ต่างดาว)

**สาเหตุ:** JXA `app.read(file)` อ่านไฟล์เป็น Latin-1 — ถ้า JS file มี Thai chars จะพัง 2 แบบ:

| ทำผิด | ผลลัพธ์ใน Jira |
|-------|---------------|
| ใส่ Thai chars ตรงๆ ใน JS file | อักขระแปลก `±πÅ±πÄ` |
| escape ด้วย `\uXXXX` **ก่อน** `JSON.stringify` | literal text `ตาม` |

**วิธีที่ถูกต้องเท่านั้น (ห้ามเปลี่ยน):**
1. สร้าง ADF body ด้วย **Thai text จริงๆ**
2. `JSON.stringify({body})` **ก่อน** — ได้ JSON string ที่มี Thai chars
3. `.replace(/[^\x00-\x7F]/g, ...)` **หลัง** — แปลง Thai เป็น `\uXXXX` ใน JS string literal
4. `fs.writeFileSync(path, js, 'ascii')` — ไฟล์ต้องเป็น ASCII ล้วน
5. ตรวจสอบ: `if (/[^\x00-\x7F]/.test(js)) throw 'STILL HAS NON-ASCII'`

**ทำไมถึงถูก:** Chrome decode `\uXXXX` ใน JS string literal กลับเป็น Thai chars จริงก่อนส่ง fetch → Jira รับ Thai text ถูกต้อง

**ดู Step 7b ใน SKILL.md สำหรับ code ตัวอย่างเต็ม**
