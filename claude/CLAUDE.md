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

### 5. Idiomatic project structure
Follow the established conventions of each language and framework (e.g. Next.js `src/app` · `src/components` · `src/lib`, Maven `src/main/java`, Python `src/<package>`), never transplant one ecosystem's layout into another. Group a feature's code in one folder within that convention. When I question a structure, explain what the ecosystem's norm is before proposing changes.

## Docs & files

- **`CLAUDE.md` is an index, not a log (at most 120 lines, test-enforced).** It holds what the project is, the rules every agent must read before any change, a **map** of every topic file, and a "where new information goes" rule. New knowledge goes into the matching topic file under `docs/` (or `docs/architecture/`, `docs/venues/`); unfinished work into `Work Items.md`; closed work and long write-ups into `Technical Archive.md`. `CLAUDE.md` changes only to add a file to the map or to change a cross-cutting rule. Every repo carries a guard test (`src/docs-index.test.ts`, or the language's equivalent) that checks the line limit, that every link resolves, and that every `docs/**/*.md` file is listed. When moving text, move it verbatim and check that no heading is lost; preserve item numbering across files so cross-references still resolve. Don't stuff repo technical detail into personal-notes / "second brain" files; those are a business/vision layer that delegates technical detail to the repo.
- Both `CLAUDE.md` and `README.md` are living docs — update them proactively as work progresses, edit in place, stay concise, and don't add timestamps (document state, not history).
- Don't add emojis to files unless explicitly requested.

## Superpowers model routing

- Controller (the session driving `subagent-driven-development` / `executing-plans`): Opus 5.5 (`claude-opus-5-5`).
- Implementers, a fallback chain for every implementation dispatch including fix rounds. No relay agent: the controller runs the script itself.
  1. `~/.claude/scripts/external-implementer codex <repo> <prompt-file> --verify "<cmd>"... --commit-msg-file <file>` (GPT-6.1-Sol via Codex), via Bash with `run_in_background`, then read its JSON result. The prompt file is controller-written: task text plus the brief, never relay instructions. Pass the repo's checks as `--verify` (unit tests, `test:db` when the DB is touched, lint, one build); the script runs them outside the model's sandbox, serialises builds, and retries once with the failure appended.
  2. A `general-purpose` agent on `model: sonnet` (Sonnet 5.5) — only when the script reports `BLOCKED_QUOTA` (usage limit reached).
  The switch is triggered by a quota/usage-limit result, not by a failed task; tell me when the chain moves down, and move back up as soon as OpenAI has quota again. Never Haiku or Opus as implementer. Kimi / OpenCode is unavailable — its subscription is cancelled; never use it. The old relay agents (`openai-implementer`, `kimi-implementer`) are retired; never dispatch them.
- **Prove the external model ran** on every external dispatch: the script's JSON is the proof (`models` contains `gpt-6.1-sol`, `cwd_ok` true, a `session` id, `strays` empty). `NO_PROOF` → block implementation and tell me; that is not a quota report, so it does not move the chain down on its own. `provenance.unmatched` > 0 means added lines the model's record does not contain: read those lines before accepting. Always read the full diff and tests (they can be weakened to match the code); a `DONE` is not a review.
- Reviewers follow the skill's Model Selection.

## Skill routing (superpowers + mattpocock)

Superpowers is the spine; Matt's skills plug into specific stages. One feature branch = one sprint.

1. **Shape** — `brainstorming` is the gate, but ask in `grilling`'s round format (numbered questions, each with a recommended answer). A design question that can't be settled on paper → `prototype` first.
2. **Spec → grill → plan → build** — once the spec is written, run `grilling` on it with me until its frontier is empty, then `writing-plans` → `subagent-driven-development`. Never use Matt's to-spec / to-tickets / implement / triage / wayfinder.
3. **TDD** — superpowers `test-driven-development` for the discipline + Matt's `tdd` for test quality; agree the seams in the plan, not mid-run.
4. **Bugs** — Matt's `diagnosing-bugs` (build a red-capable repro command first; never Playwright), keeping superpowers' no-fix-without-root-cause rule.
5. **Review** — per-task reviews as SDD runs them; at branch end, Matt's `code-review` against the spec **plus** a branch-level correctness + security pass (superpowers `requesting-code-review` reviewer, most capable model; Matt's two axes don't hunt bugs or security), then `finishing-a-development-branch`.
6. **Retro (sprint close)** — after the merge, offer `/retro` on the controller session. Present the improvements ranked; I pick which to keep. Land accepted items on a separate `chore/` branch, never the feature branch. Prefer an automated check (lint rule, hook, CI job, guard test) over a new CLAUDE.md line.
- **Decisions** — a hard-to-reverse decision with a real trade-off becomes an ADR (`domain-modeling`), not prose in CLAUDE.md.

## Git

- Merging a feature branch with more than one commit: always `git merge --no-ff` (a merge commit), never fast-forward.
- Long-running feature work (anything run through `subagent-driven-development`) gets its own git worktree, so parallel sessions never share a checkout. After the feature is merged into master, remove the worktree (`git worktree remove`) and delete the branch.
- A long-running feature branch (anything run through `subagent-driven-development`) merges `master` into itself at the start of every session and after every few tasks, resolving conflicts as they appear and re-running tests before continuing, so it never drifts far from `master`. Never rebase it.
- Do not commit or push on my behalf without an explicit request — I commit when ready, except when working on long feature developments which use sub-agent driven development and branch git history is important to track individual task's changes.
- End commit messages with a `Co-Authored-By` trailer for the assisting model when committing on my request.
