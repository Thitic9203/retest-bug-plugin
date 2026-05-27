# Post-Mortem Template

> Template สำหรับบันทึก lesson learned จาก retest session ที่เจอปัญหา
> ใช้เมื่อเจอปัญหาที่ทำให้เสียเวลา/ทำซ้ำ — เขียนลงใน `post-mortem-log.md`

## เมื่อไหร่ต้องเขียน

- Comment format พังต้อง re-post
- Login/auth ล้มเหลวหลายรอบ
- เจอ gotcha ใหม่ที่ยังไม่มีใน `gotchas.md`
- ขั้นตอนใน SKILL.md ไม่ครบ ต้องหาทางแก้เอง

## เมื่อไหร่ไม่ต้องเขียน

- Retest ผ่านปกติ ไม่มีอะไรผิดพลาด
- ปัญหาเล็กน้อยที่แก้ได้ใน 1 นาที
- ปัญหาจาก external system (Jira down, VPN ล่ม)

## Template

```markdown
## PM-<N>: <TICKET_KEY> <ชื่อปัญหาสั้นๆ> (<DATE>)

**ปัญหา:** <อธิบายว่าเกิดอะไร เสียเวลาเท่าไหร่>

**Root cause:**
1. <สาเหตุหลัก — mechanism ที่ทำให้เกิด ไม่ใช่แค่อาการ>
2. <สาเหตุรอง (ถ้ามี)>

**Fixes applied:**
- <สิ่งที่แก้ใน SKILL.md / gotchas.md / references>
- <rule ใหม่ที่เพิ่ม>

**Lesson:** <สรุป 1 ประโยค — ทำอะไรต่างไปจะไม่เจอปัญหานี้>
```

## กฎ

- ใช้ ID ต่อเนื่อง: PM-1, PM-2, PM-3...
- Root cause ต้องเป็น **mechanism** ไม่ใช่อาการ ("ไม่ได้จำแนก Bug FE ตั้งแต่ Step 3" ไม่ใช่ "comment พัง")
- Fixes applied ต้องอ้างอิงไฟล์/step ที่แก้จริง
- Lesson ต้องเป็น **actionable** — ทำได้เลย ไม่ใช่แค่ "ระวังมากขึ้น"
