# Retest Bug Plugin — Governance Rules

Rules สำหรับการพัฒนา plugin นี้ — AI และ contributor ต้องปฏิบัติตาม

## Skill Organization

Skills จัดเป็น bucket folders ภายใต้ `skills/`:

- `engineering/` — workflow หลักของ plugin (retest, debug, analysis)
- `productivity/` — เครื่องมือช่วยงานทั่วไป (handoff, reporting)
- `in-progress/` — draft ที่ยังไม่พร้อมใช้
- `deprecated/` — เลิกใช้แล้ว

**กฎ:**
- Skill ที่พร้อมใช้ (`engineering/`, `productivity/`) ต้องมี entry ใน `plugin.json` + ลิงก์ใน `README.md`
- Skill ใน `in-progress/` หรือ `deprecated/` ห้ามอยู่ใน `plugin.json` หรือ `README.md`
- ทุก skill ต้องมี `SKILL.md` พร้อม YAML frontmatter (`name`, `description`)

## Progressive Disclosure

- `SKILL.md` เก็บเฉพาะ flow หลัก (ไม่เกิน 500 บรรทัด)
- รายละเอียดเพิ่มเติม → แยกไปไฟล์ใน `references/`
- SKILL.md อ้างอิง reference ด้วย "ดูรายละเอียดใน `references/<file>`"

## Domain Language

ใช้ศัพท์ตาม `CONTEXT.md` เสมอ — ป้องกัน AI ตีความผิด

## Version Management

- Version อยู่ใน `plugin.json` + `marketplace.json` — ต้อง sync กันเสมอ
- **Auto-bump:** pre-commit hook bump patch ทุก commit อัตโนมัติ
- **Manual bump:** แก้ version ใน `plugin.json` ก่อน commit → hook จะ skip auto-bump + sync marketplace.json ให้
  - `minor` bump: เพิ่ม skill ใหม่ หรือ feature ใหม่
  - `major` bump: breaking change (เปลี่ยน flow, ลบ skill)

## Adding New Skills

1. สร้าง directory ใน bucket ที่เหมาะสม: `skills/<bucket>/<skill-name>/`
2. สร้าง `SKILL.md` พร้อม YAML frontmatter
3. เพิ่ม path ใน `plugin.json` → `skills` array
4. เพิ่มลิงก์ใน `README.md` section ที่ตรง
5. ถ้าต้องการ slash command → สร้าง `commands/<name>.md`
6. ดู template ที่ `references/new-skill-template.md`

## Skill Composition

Skills อ้างอิงกันได้ — ใช้ relative link ชี้ไปที่ `SKILL.md` ของ skill อื่น:
- `[debug-discipline](../references/debug-discipline.md)` สำหรับ reference ใน skill เดียวกัน
- ใช้ `Skill tool: <skill-name>` สำหรับเรียก skill อื่นใน runtime

## File Naming

- SKILL.md, CONTEXT.md, README.md → UPPERCASE
- Reference files → lowercase kebab-case (เช่น `debug-discipline.md`)
- Scripts → lowercase kebab-case (เช่น `link-skills.sh`)
