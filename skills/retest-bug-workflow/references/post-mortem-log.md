# Post-Mortem Log — Retest Bug Workflow

> บันทึก lesson learned จาก session ที่เจอปัญหา — ป้องกันไม่ให้ซ้ำ

## PM-1: CP-11507 Comment Format พังซ้ำ 4 รอบ (2026-05-26)

**ปัญหา:** โพสต์ comment 4 ครั้ง แต่ละครั้งพังคนละจุด (Thai encoding, emoji literal, auto-link) เสียเวลา ~2 ชม.

**Root cause:**
1. ไม่ได้จำแนก Bug FE ตั้งแต่ Step 3 → เริ่มด้วย v3 ADF → ต้องเปลี่ยนมา v2 wiki markup กลางทางเมื่อ inline image ทำไม่ได้ใน ADF
2. v2 wiki markup มี gotcha ชุดใหม่ (emoji escape, auto-link) ที่ไม่เคยเจอใน v3
3. ไม่มี dry-run → โพสต์แล้วค่อยเห็นปัญหา → delete + re-post วนซ้ำ

**Fixes applied:**
- Step 3a: เพิ่ม Bug Type classification → กำหนด comment format (v2/v3) ทันที
- Step 7: เพิ่ม pre-post checklist + dry-run verification script
- Gotchas: เพิ่มตาราง v2 wiki markup gotchas + วิธีแก้

**Lesson:** ตัดสินใจ format ตั้งแต่ต้น + validate ก่อนส่ง = ไม่ต้อง re-post
