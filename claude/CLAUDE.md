# Global Working Preferences

Applies to all repositories. Each repo's own `CLAUDE.md` adds project-specific detail on top of this.

## About me

Mae — Computer Scientist; background in software engineering; strong in architecture design, clean code, cloud development, and distributed systems. Still learning trading. Adjust the depth of every response to match this: never over-explain what I already know, never skip context I need.

Never open responses with filler ("Great question!", "Of course!", "Certainly!", or similar). Start with the actual answer — no preamble, no acknowledgment of the question.

## Behavioral Policy

### 1. Think before coding
Don't assume, don't hide confusion, surface tradeoffs. State assumptions explicitly; if multiple interpretations exist, present them rather than pick silently; if a simpler approach exists, say so and push back when warranted; if something is unclear, stop, name what's confusing, and ask.

### 2. Simplicity first
Minimum code that solves the problem, nothing speculative. No features beyond what was asked, no abstractions for single-use code, no unrequested "flexibility"/configurability, no error handling for impossible scenarios. If it's 200 lines and could be 50, rewrite it. The test: would a senior engineer call this overcomplicated?

### 3. Surgical changes
Touch only what you must; clean up only your own mess. Don't "improve" adjacent code, don't refactor what isn't broken, match existing style even if you'd do it differently. Remove orphans your change created; leave pre-existing dead code (mention it, don't delete it). Every changed line should trace directly to the request.

### 4. Goal-driven execution
Turn tasks into verifiable goals ("fix the bug" → "write a test that reproduces it, then make it pass"). For multi-step work, state a brief plan with a verify step for each.

## Docs & files

- **Keep `CLAUDE.md` lean (under ~500 lines): conventions, locked decisions, and open/active tasks only.** Migrate closed/tested/rejected experiments, superseded plans, and long status history to a separate **archive file in the same repo** (e.g. `Technical Archive.md`), keeping a one-line summary per closed item in CLAUDE.md that points to it. Prefer references over inlined content; preserve item numbering across both files so cross-references still resolve. Re-slim proactively when it drifts back over ~500 lines — don't wait to be asked. Don't stuff repo technical detail into personal-notes / "second brain" files; those are a business/vision layer that delegates technical detail to the repo.
- Both `CLAUDE.md` and `README.md` are living docs — update them proactively as work progresses, edit in place, stay concise, and don't add timestamps (document state, not history).
- Don't add emojis to files unless explicitly requested.

## Superpowers model routing

- Controller (the session driving `subagent-driven-development` / `executing-plans`): Opus 5.5 (`claude-opus-5-5`).
- Implementers: always the `kimi-implementer` agent (Kimi K3), for every implementation dispatch including fix rounds. Never a Claude model (haiku/sonnet/opus) as implementer.
- Reviewers follow the skill's Model Selection.

## Skill routing (superpowers + mattpocock)

Superpowers is the spine; Matt's skills plug into specific stages. One feature branch = one sprint.

1. **Shape** — `brainstorming` is the gate, but ask in `grilling`'s round format (numbered questions, each with a recommended answer). A design question that can't be settled on paper → `prototype` first.
2. **Spec → plan → build** — `writing-plans` → `subagent-driven-development`. Never use Matt's to-spec / to-tickets / implement / triage / wayfinder.
3. **TDD** — superpowers `test-driven-development` for the discipline + Matt's `tdd` for test quality; agree the seams in the plan, not mid-run.
4. **Bugs** — Matt's `diagnosing-bugs` (build a red-capable repro command first; never Playwright), keeping superpowers' no-fix-without-root-cause rule.
5. **Review** — per-task reviews as SDD runs them; at branch end, Matt's `code-review` against the spec **plus** a branch-level correctness + security pass (superpowers `requesting-code-review` reviewer, most capable model; Matt's two axes don't hunt bugs or security), then `finishing-a-development-branch`.
6. **Retro (sprint close)** — after the merge, offer `/retro` on the controller session. Present the improvements ranked; I pick which to keep. Land accepted items on a separate `chore/` branch, never the feature branch. Prefer an automated check (lint rule, hook, CI job, guard test) over a new CLAUDE.md line.
- **Decisions** — a hard-to-reverse decision with a real trade-off becomes an ADR (`domain-modeling`), not prose in CLAUDE.md.

## Git

- Merging a feature branch with more than one commit: always `git merge --no-ff` (a merge commit), never fast-forward.
- Do not commit or push on my behalf without an explicit request — I commit when ready, except when working on long feature developments which use sub-agent driven development and branch git history is important to track individual task's changes.
- End commit messages with a `Co-Authored-By` trailer for the assisting model when committing on my request.
