---
name: trading-next
description: Use when the user asks what's next, what to work on, or for priorities across their trading projects (RSI Bounce Pro, SuperTrend, trading-server, trading-dashboard, prop seats, M5 ladder), from any directory.
---

# Trading next

One ranked "what's next" across every trading repo, so the user doesn't run it per repo and merge it in their head. Works from any cwd: all paths are absolute. Read-only: no edits, commits, ssh or ledger queries.

## Sources (read all of them, every run)

Repos under `/Users/mae/repositories/`:

| Repo | Files |
|---|---|
| `rsi-bounce-pro` | `Work Items.md`, `Deployment Decision Framework.md`, `docs/project-status.md` |
| `supertrend-ai-adaptive` | `Work Items.md` |
| `trading-server` | `Work Items.md` |
| `trading-dashboard` | `Work Items.md` |

For each repo also run `git -C <repo> status -sb`; its `[ahead N]` gives unpushed commits (no upstream: say so).

Read each `Work Items.md` in full with the Read tool (`offset`/`limit` chunks; these files exceed 70 KB, and `cat` output gets truncated). A truncated read is not a read. Status lives in a task index table where one exists (Now / Next / Parked), otherwise in section headings and prose ("In flight", "Open", "Parked"). Dates found anywhere (Work Items, fills logs, framework) count; if two sources disagree, report both.

To add a repo, add a row to the table above.

## Ranking

Rank across repos by tier, then by date within a tier:

1. **Live safety and hard deadlines**: anything that blocks live trading, risks an unprotected or doubled position, a permanent prop-rule breach, or a dated external expiry (prop inactivity clocks, paid seats).
2. **Marked "Now"** in a Work Items index.
3. **Unblocked or due**: an item whose prerequisite just cleared, or whose pre-registered gate/date is reached.
4. **Recurring operations** due this week (Saturday pass, ladder reads).
5. **Everything else open**, then parked.

Gates follow the pre-committed framework, never recent P&L. Within tier 1, the earliest deadline first. Weeks run Sunday-Saturday.

Merge an item that spans repos (a strategy item that needs a `trading-server` build) into one entry naming both sections; if the target repo has no entry yet, say "no item in <repo> yet" as part of the first step.

Live state you cannot see read-only (did a keep-alive fire, has a signal reset a clock) is stated as "unverified since <doc date>" with the check that would confirm it, never assumed.

## Output (in chat, no file)

1. One line: the single top item.
2. **Top 3-5**, each: `repo §N - title`, why it is next (tier + reason), first concrete step, and whether it needs the user (browser, money, decision) or can be delegated.
3. **Housekeeping**: dirty trees and unpushed commits, one line per repo; omit if clean.
4. **Waiting on data / parked**: one line each with what unblocks it.
5. **Not verified**: anything you could not read fully.
