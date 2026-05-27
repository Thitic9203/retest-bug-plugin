# retest-bug

A Claude Code plugin that turns Jira bug retesting into a **single command**. Hand it a ticket — it handles the rest.

## Why Use This

| Without plugin | With plugin |
|----------------|-------------|
| Open ticket → login portal → test manually → collect evidence → write comment → paste into Jira → move status → assign dev | Type `/retest-bug PROJ-123` and approve the comment |
| **30–60 min** per ticket | **5–10 min** per ticket |
| Inconsistent format, forgotten transitions, missed assignments | Consistent output, every step completed, every time |

## What You Get

- **Automated testing** — logs into the portal, calls APIs, compares against Swagger spec, captures screenshots for UI bugs
- **Ready-to-post comment** — full evidence, consistent format, just approve and it posts for you
- **Auto-close workflow** — transitions the ticket (PASSED → Ready to Demo / FAILED → In Progress) and assigns it back to the dev
- **Zero memorization** — reads the retest guide, picks the right test strategy, collects all evidence automatically

## Install

```
/install-plugin https://github.com/Thitic9203/retest-bug-plugin
```

## Usage

```
/retest-bug PROJ-123
/retest-bug https://your-org.atlassian.net/browse/PROJ-123
```

## Prerequisites

- **VPN:** Connect to your project's VPN if the test environment requires it
- **Jira:** Log in to your Atlassian workspace in Chrome (once per session)

## Skills

### Engineering

- **[retest-bug-workflow](./skills/retest-bug-workflow/SKILL.md)** — Full retest flow: read ticket → login → test API/FE → compare Swagger → draft comment → post → transition → assign

## Reference Files

| File | Purpose |
|------|---------|
| [credit-port-retest-guide.md](./skills/retest-bug-workflow/references/credit-port-retest-guide.md) | Full retest guide — workflow, templates, credentials, gotchas |
| [gotchas.md](./skills/retest-bug-workflow/references/gotchas.md) | Known pitfalls (encoding, v2 wiki markup, JXA) |
| [post-mortem-log.md](./skills/retest-bug-workflow/references/post-mortem-log.md) | Lesson learned log |
| [post-mortem-template.md](./skills/retest-bug-workflow/references/post-mortem-template.md) | Template สำหรับบันทึก post-mortem |
| [debug-discipline.md](./skills/retest-bug-workflow/references/debug-discipline.md) | Debugging discipline เมื่อ bug ยังอยู่ |
| [handoff-template.md](./skills/retest-bug-workflow/references/handoff-template.md) | Template สำหรับส่งต่อ session |
| [new-skill-template.md](./skills/retest-bug-workflow/references/new-skill-template.md) | Template สำหรับสร้าง skill ใหม่ |

## Domain Language

ดู [CONTEXT.md](./CONTEXT.md) สำหรับ glossary ของศัพท์เฉพาะ (retest, Bug API/FE, PD3, ADF, wiki markup ฯลฯ)

## Scripts

```bash
./scripts/link-skills.sh   # Symlink skills ไป ~/.claude/skills/
./scripts/list-skills.sh   # List ทุก SKILL.md ใน repo
```

## Contributing

ดู [CLAUDE.md](./CLAUDE.md) สำหรับ governance rules — skill organization, version management, naming conventions
