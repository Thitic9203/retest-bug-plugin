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
| 3 | Login portal (Admin/SP ตาม ticket tag) |
| 4 | ทดสอบ API หรือ FE + เทียบ Swagger spec |
| 5 | เก็บหลักฐาน (cURL เต็ม + Response เต็ม) |
| 6 | Draft Jira comment + ขอ approve จาก user ก่อน post |
| 7 | Post comment (MCP หรือ Jira REST API fallback) |
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

## Notes

- MCP mode (Atlassian MCP) ใช้ถ้าเชื่อมต่อได้ — fallback เป็น Jira REST API ผ่าน browser session อัตโนมัติ
- Portal ใช้ Playwright headless: false เพราะ Cloudflare WAF บล็อก headless
- Admin Bearer token หมดอายุ ~5 นาที — login ใหม่อัตโนมัติถ้าได้ 401
