# retest-bug

Claude Code plugin รีเทสบัคจาก Jira ticket แบบครบ flow — ทดสอบ, เม้น, transition, assign กลับ dev อัตโนมัติ

## Install

```
/install-plugin https://github.com/Thitic9203/retest-bug-plugin
```

## Usage

```
/retest-bug CP-12345
/retest-bug https://humanintelligence.atlassian.net/browse/CP-12345
```

## Flow

| Step | Action |
|------|--------|
| 0 | ตรวจ VPN + เช็ค Jira connection |
| 1-2 | ดึง ticket + อ่าน retest guide |
| 3 | จำแนก Bug Type (API/FE) → กำหนด comment format |
| 4 | Login portal + ทดสอบ + เทียบ Swagger |
| 5-6 | เก็บหลักฐาน + draft comment → **รอ user approve** |
| 7 | Post comment (พร้อม screenshot inline ถ้าเป็น Bug FE) |
| 8 | Transition + assign กลับ dev อัตโนมัติ |

## ผลเทส → Transition

| ผลเทส | Transition | Assignee |
|-------|-----------|---------|
| PASSED ✅ | Ready to Demo | dev คนที่ In Progress ล่าสุด |
| FAILED ❌ | In Progress | dev คนที่ In Progress ล่าสุด |

## Prerequisites

- **VPN:** OpenVPN Connect → `ovpn.mycreditport.com`
- **Jira:** ต้อง login `humanintelligence.atlassian.net` ใน Chrome (ขอครั้งเดียวต่อ session)
