# Handoff Template

> ใช้เมื่อ retest ยังไม่จบ session แต่ต้องส่งต่อให้ session ถัดไป

## เมื่อไหร่ต้องทำ Handoff

- Retest หลาย ticket แต่ session จะหมด context
- ติด blocker (รอ VPN, รอ OTP, รอ dev แก้) ต้องกลับมาทำต่อ
- เปลี่ยนเครื่อง/environment

## Template

```markdown
# Retest Handoff — <DATE>

## Tickets in progress

| Ticket | Status | Step ที่ค้าง | Blocker |
|--------|--------|-------------|---------|
| PROJ-XXXXX | Step 4 (testing) | รอ OTP | ขอ token จาก user |
| PROJ-YYYYY | Step 6 (draft ready) | รอ approve | — |

## Environment State

- **Portal:** <URL ที่ login อยู่>
- **Token:** <หมดอายุแล้ว / ยังใช้ได้ถึง ~HH:MM>
- **Browser tab:** <Jira tab เปิดอยู่ที่ ticket ไหน>

## Evidence Collected

### PROJ-XXXXX
- cURL: <collected / not yet>
- Response: <collected / not yet>
- Screenshot: <uploaded / not yet>
- Swagger compared: <yes / no>

## Decisions Made

- Bug type: <API / FE>
- Comment format: <v2 / v3>
- Test data: <ID ที่สร้าง / ใช้อยู่>

## Next Steps

1. <สิ่งที่ต้องทำต่อเป็นอย่างแรก>
2. <สิ่งถัดไป>

## Suggested Skills

- `retest-bug-workflow` — ทำต่อจาก step ที่ค้าง
- `superpowers:systematic-debugging` — ถ้า bug ยังอยู่ต้อง investigate
```

## กฎ

- ห้าม duplicate evidence ที่เก็บไว้แล้ว — อ้างอิง path/URL แทน
- ระบุ blocker ให้ชัด — session ถัดไปจะได้ไม่เสียเวลา discover ใหม่
- Token state สำคัญ — session ถัดไปต้องรู้ว่าต้อง login ใหม่หรือไม่
- Save handoff ไปที่ OS temp directory ไม่ใช่ workspace
