# retest-bug

Claude Code plugin สำหรับรีเทสบัคจาก Jira ticket แบบ full workflow — ตั้งแต่ดึง ticket, login portal, ทดสอบ API/FE, เทียบ Swagger, draft Jira comment, post, transition ticket จนถึง assign กลับ dev

---

## Install

```
/install-plugin https://github.com/Thitic9203/retest-bug-plugin
```

---

## Usage

```
/retest-bug CP-12345
/retest-bug https://humanintelligence.atlassian.net/browse/CP-12345
```

---

## What it does

| Step | Action |
|------|--------|
| 0 | รับ ticket key + ตรวจ VPN + เช็ค Atlassian MCP |
| 1 | อ่าน retest guide |
| 2 | ดึงรายละเอียด ticket (MCP หรือ Playwright fallback) |
| 3 | **จำแนก Bug Type (API/FE) → กำหนด comment format (v2/v3) + เลือก skill** |
| 4 | Login portal + ทดสอบ API หรือ FE + เทียบ Swagger spec |
| 5 | เก็บหลักฐาน (cURL เต็ม / screenshot + embed inline) |
| 6 | Draft Jira comment + ขอ approve จาก user ก่อน post |
| 7 | **Pre-post checklist + dry-run** → Post comment |
| 8 | ปิดงาน: transition + assign กลับ dev |

---

## Step 8 — ปิดงาน

| ผลเทส | Transition | Assignee |
|-------|-----------|---------|
| PASSED ✅ | Ready to Demo | dev คนที่ move In Progress ล่าสุด |
| FAILED ❌ | In Progress | dev คนที่ move In Progress ล่าสุด |

---

## Files

```
commands/
  retest-bug.md          # /retest-bug command
skills/
  retest-bug-workflow/
    SKILL.md             # full workflow skill
```

---

## Environment

- **Jira:** humanintelligence.atlassian.net
- **Portal (BO/Admin):** pd3-web-portal.mycreditport.com
- **Portal (SP):** pd3-sp.mycreditport.com
- **VPN required:** ovpn.mycreditport.com

---

## Comment Format

| Bug Type | Format | API | Inline Image |
|----------|--------|-----|-------------|
| Bug API | v3 ADF | `/rest/api/3/.../comment` | ไม่ต้อง |
| Bug FE | **v2 wiki markup** | `/rest/api/2/.../comment` | `!filename.png\|width=600!` |

> ตัดสินใจ v2/v3 ตั้งแต่ Step 3 — ห้ามเปลี่ยนกลางทาง

---

## Fallback Chain

| ลำดับ | วิธี | ใช้เมื่อ |
|-------|------|---------|
| 1 | Atlassian MCP | MCP เชื่อมต่อได้ |
| 2 | JXA + Chrome browser session | MCP 403 → ใช้ Jira REST API ผ่าน `fetch()` ใน Chrome ของ user |

### JXA Encoding (ภาษาไทย + emoji)

Pipeline: **Thai text จริง → `JSON.stringify` → escape non-ASCII → save ASCII → JXA → Chrome decode `\uXXXX` → Jira**

> escape ต้องทำ **หลัง** `JSON.stringify` เท่านั้น — ถ้าทำก่อนจะได้ literal `\uXXXX` text

---

## Notes

- MCP mode (Atlassian MCP) ใช้ถ้าเชื่อมต่อได้ — fallback เป็น JXA + Chrome browser session อัตโนมัติ
- Portal ใช้ Playwright headless: false เพราะ Cloudflare WAF บล็อก headless
- Admin Bearer token หมดอายุ ~5 นาที — login ใหม่อัตโนมัติถ้าได้ 401
- Pre-post dry-run ตรวจ emoji + Thai + ticket key auto-link ก่อนโพสต์ทุกครั้ง
