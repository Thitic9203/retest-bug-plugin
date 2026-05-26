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
