# Debug Discipline — เมื่อ Bug ยังอยู่หลัง Retest

> ใช้เมื่อ retest แล้วพบว่า bug ยังไม่ถูกแก้ หรือแก้ไม่ครบ — ก่อนสรุป FAILED ต้องวินิจฉัยให้ชัดก่อน

## Mantra (ท่องก่อนเริ่ม debug ทุกครั้ง)

1. **Reproduce ให้ได้ก่อน** — bug ที่ทำซ้ำไม่ได้ = ยังวินิจฉัยไม่ได้
2. **รู้จัก fail path** — trace code path จริง ไม่ใช่เดา
3. **ตั้งคำถามกับ hypothesis** — อะไรจะพิสูจน์ว่าผิด?
4. **ทุก run คือ breadcrumb** — cross-reference ทุกผลทดสอบ

## เมื่อ Retest → FAILED

### Step 1: Reproduce ให้ชัด

- ทำตาม test steps จาก ticket **ตรงตัว** — ไม่ดัดแปลง
- บันทึก: exact input, exact URL, exact response
- ถ้า reproduce ไม่ได้ → ลองเปลี่ยน environment, user, data set
- ยังไม่ได้ → BLOCKED (ไม่ใช่ FAILED) + บอก user

### Step 2: แยกแยะว่า fix ไม่ครบหรือ bug คนละตัว

| สถานการณ์ | สรุปเป็น |
|-----------|---------|
| Bug case เดิมจาก ticket ยังพัง | FAILED — fix ไม่ได้ผล |
| Bug case เดิมผ่าน แต่เจอ bug ใหม่ | PASSED + เปิด ticket ใหม่สำหรับ bug ใหม่ |
| บาง case ผ่าน บาง case ไม่ผ่าน | FAILED — fix ไม่ครบ, ระบุ case ที่ยังพัง |

### Step 3: เก็บหลักฐานให้ครบ

FAILED ต้องมีหลักฐานมากกว่า PASSED:
- **Before fix behavior** (จาก ticket description)
- **After fix behavior** (จากการ retest)
- **Expected behavior** (จาก Swagger / ticket expected result)
- **Diff ชัดเจน** — อะไรเปลี่ยน อะไรไม่เปลี่ยน

### Step 4: Breadcrumb ledger

บันทึกทุกการทดสอบเป็นตาราง:

| # | Input | Expected | Actual | Pass? | Notes |
|---|-------|----------|--------|-------|-------|
| 1 | ... | ... | ... | ❌ | ... |
| 2 | ... | ... | ... | ✅ | ... |

ตารางนี้ใส่ใน Jira comment เป็น evidence

## Composition

ถ้าต้องการ debug เชิงลึกกว่านี้:
- **`superpowers:systematic-debugging`** — สำหรับ bug ซับซ้อนที่ต้อง bisect, instrument, isolate
- **`superpowers:verification-before-completion`** — สำหรับตรวจสอบว่า fix ครบทุก edge case
