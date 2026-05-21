# Automated Review Guidelines — rashedul-agentic-engineering

**Context:** This repo is a personal collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) artifacts — skills under `skills/<name>/SKILL.md`, agent definitions under `agents/<name>.md`, and supporting docs. It does NOT contain application source code. The "code" you are reviewing is almost always markdown with YAML frontmatter.

**CRITICAL:** Review ONLY the changes shown in the diff below. Do NOT review files that weren't changed. Do NOT propose refactors of unchanged files.

---

## What to check

### 1. Skill files (`skills/<name>/SKILL.md`)

- **Frontmatter validity.** Must be valid YAML between leading `---` lines. Required fields: `name` (kebab-case, matches folder name), `description` (one paragraph that names concrete triggers users would type).
- **Folder/name match.** If `name: foo-bar` then the folder must be `skills/foo-bar/`. Flag mismatches.
- **Description is trigger-rich.** A good `description:` lists specific phrases the user would say (e.g. "make this an HTML page", "structure your response as HTML"). Vague descriptions ("does HTML stuff") fail this check.
- **`rules/` references resolve.** If the SKILL.md body links to `rules/foo.md`, that file must exist under the skill's folder.
- **One H1 in the body.** The first heading after frontmatter should be a single `#` heading matching the skill `name`.

### 2. Agent files (`agents/<name>.md`)

- **Frontmatter validity.** Required: `name` (matches filename), `description`, `tools` (comma-separated list), `model` (one of `haiku`, `sonnet`, `opus`).
- **`tools:` is realistic.** A read-only reporter should not list `Edit` or `Write`. Flag mismatches between the body's claimed behavior (e.g. "never edits code") and the declared `tools:`.
- **`description:` names *when to delegate*.** The parent agent reads this to decide routing — so it must describe the situation, not just the agent's mechanics.

### 3. README.md

- **Live links.** Every `[text](path)` link to a file in this repo must point to a file that exists in the current diff. Flag broken links.
- **"What's here" table stays accurate.** If a new top-level folder was added (e.g. `hooks/`), the table must move it from "Planned" to "Live" in the same PR.
- **Skills/Agents sections list every entry.** A new `skills/<x>/` or `agents/<x>.md` in the diff must also appear in the relevant README section.

### 4. Workflows (`.github/workflows/*.yml`)

- **Pinned actions.** Third-party actions should use a commit SHA or major version (`@v4`), never `@master`.
- **No secret echoing.** No `echo "$SECRET"`, no secret values in `run:` blocks outside of `env:` injection.
- **Reasonable timeouts.** Jobs that call external APIs should have `timeout-minutes:` set.

### 5. Always

- **No secrets, tokens, or API keys** in any file — flag if `sk-…`, `ghp_…`, AWS access-key patterns, or `BEGIN PRIVATE KEY` appear.
- **No machine-local paths** like `/Users/rijul/…` in committed files (they're fine in shell snippets that document the local install, but not in skill/agent bodies that other people would copy).
- **No emojis added** unless the source/PR explicitly used them. House style is emoji-free.
- **Commit messages.** If commits are in scope, prefer Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`) for skim-ability.

---

## What NOT to flag

- Long markdown files. Skills are intentionally detailed; line count is not a smell here.
- Lack of tests — this repo doesn't have a test suite, and skill/agent markdown isn't testable in that sense.
- Lack of TypeScript / Next.js / framework patterns — the boilerplate Cursor templates often suggest. This is a markdown-and-yaml repo.
- Project-specific paths inside `skills/fizzy-product-manager/rules/` and `agents/quality-gates.md` — those are deliberately scoped to specific projects (Fizzy / RIXUL-AI) and flagged as such in the README. Don't suggest "generalize this" unless the diff itself is trying to generalize.

---

## Grading & Verdict

At the end of the review provide:

**Overall Grade:** (A+, A, A-, B+, B, B-, C+, C, C-, D, F)
- A+ / A: Clean, conforms to all conventions, no broken links, no missing README updates.
- B: Minor issues — e.g. one missing README entry, one ambiguous trigger phrase in a `description:`.
- C: Multiple convention misses, broken links, or frontmatter problems.
- D / F: Secrets leaked, machine paths committed, or large amounts of unrelated drift.

**Verdict:** (Choose one)
- APPROVE: Ready to merge as-is.
- APPROVE WITH MINOR COMMENTS: Small suggestions, can merge.
- REQUEST CHANGES: Issues must be fixed first.
- REJECT: Secrets, broken structure, or large unintended changes.

**Summary:** 2–3 sentences justifying the grade and verdict.

**Action items:** Concrete fixes with file paths and line references. Skip if A / A+.
