# New Skill Template

> ใช้เป็น starting point เมื่อสร้าง skill ใหม่ใน plugin นี้

## Directory Structure

```
skills/<bucket>/<skill-name>/
├── SKILL.md              # Main instructions (required)
└── references/           # Detail docs (if needed)
    ├── gotchas.md        # Known pitfalls
    └── examples.md       # Usage examples
```

## SKILL.md Template

```markdown
---
name: <skill-name>
description: <Brief description. Use when [specific triggers]. Trigger on /<skill-name> and proactively when [conditions].>
---

# <Skill Name>

## Overview

<1-2 ประโยค อธิบายว่า skill นี้ทำอะไร>

## When to use

- <trigger condition 1>
- <trigger condition 2>

## When NOT to use

- <exclusion condition>

## Workflow

### Step 1 — <ชื่อ step>

<instructions>

### Step 2 — <ชื่อ step>

<instructions>

---

## Critical Rules

1. <rule>
2. <rule>

---

## Composition

ถ้าต้องการความสามารถเพิ่มเติม:
- **`<other-skill>`** — <เมื่อไหร่ใช้>
```

## Checklist ก่อนส่ง

- [ ] SKILL.md มี YAML frontmatter (`name`, `description`)
- [ ] `description` ระบุ trigger conditions ชัดเจน
- [ ] เพิ่ม path ใน `plugin.json` → `skills` array
- [ ] เพิ่มลิงก์ใน `README.md`
- [ ] Reference files (ถ้ามี) อยู่ใน `references/`
- [ ] ไม่เกิน 500 บรรทัดใน SKILL.md — ถ้าเกินแยกไป references
- [ ] ใช้ศัพท์ตาม `CONTEXT.md`
