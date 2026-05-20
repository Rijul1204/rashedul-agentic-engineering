---
name: html-output
description: Convert the current plan, spec, design doc, or other markdown context into a single self-contained, share-able HTML file with rich visual structure (tables, SVG diagrams, code blocks, responsive layout, navigation). Use when the user invokes /html-output, asks to "export as HTML", "make a web version", "render this as HTML", "share this as a link", or wants a long plan or spec converted from markdown into something visually scannable.
---

# html-output

Render the current plan, spec, design doc, or conversation context as **one self-contained HTML file** that conveys the information more densely than markdown can — tables, inline SVG diagrams, semantic structure, in-page navigation, mobile-responsive layout, no external runtime dependencies. Background: Thariq Shihipar, *"Using Claude Code: The Unreasonable Effectiveness of HTML"* — markdown caps out around ~100 lines of readability; HTML scales further and is easy to share.

This skill owns *what* to convert and *where* to put the file. Visual quality (typography, color, motion, layout polish) is delegated to the `frontend-design` skill — if it's installed, treat this skill as composing on top of it. Otherwise default to a clean modern editorial style.

## When to invoke

Fire on any of:

- The user types `/html-output` (optionally followed by a path).
- The user asks to "make this an HTML page", "render as HTML", "export to HTML", "give me a shareable version", "make a web version of this".
- The user finishes a long plan / spec / design doc and wants a more readable artifact.

Do **not** fire on:

- Source < 30 lines (ask first — HTML overhead is rarely worth it).
- Source is already HTML (refuse, point at the existing file).
- Live dashboards needing data refresh (out of scope — redirect to a real Next.js page).

## Source selection

Pick the source in this order; stop at the first match:

1. **Explicit path passed as argument.** `/html-output /path/to/file.md` → that file. Resolve relative paths against the cwd. If the file doesn't exist or isn't readable, stop and tell the user.
2. **`@`-referenced markdown file** in the user's most recent message → that file.
3. **Most recently modified plan file** under `/Users/rijul/.claude/plans/*.md` — but only if a plan-mode session just exited or the user explicitly says "the plan". Pick by `mtime`, not name.
4. **Conversation context** (last resort): assemble a synthesis from the recent conversation. Only use this branch when the prior three failed AND the conversation contains enough material (≥ ~30 substantive turns). Otherwise ask the user what to convert.

Once the source is picked, read the *whole* file (or the relevant conversation slice) before starting the design pass. Don't skim.

## Output location

- Source is a file on disk → write the HTML as a **sibling** with the same basename and a `.html` extension. Example: `~/.claude/plans/foo.md` → `~/.claude/plans/foo.html`. Project doc `project-management/ai-secretary/foo-design.md` → `project-management/ai-secretary/foo-design.html`.
- Source is conversation context (no file) → write to `~/.claude/plans/<short-kebab-slug>.html`, where the slug summarizes the topic in 3-5 words. Create the dir if it's missing.
- Overwrite if the target already exists — but only after a quick read of the existing file to confirm it's a previous output from this skill (look for the `data-generator="html-output"` attribute on `<html>`, see below). If it looks like unrelated content, append `-v2`, `-v3`, etc.

Always print the **absolute path** of the written file in the final reply.

## Design pass (mandatory before writing)

Before emitting a single line of HTML, decide:

1. **Visual direction.** Pick one: *editorial* (long-form, prose-heavy), *technical-doc* (API ref / spec), *dashboard* (decision matrices, comparison-heavy), *deck* (slide-like sections). Pick from the source's actual shape, not your favorite default.
2. **Typography.** System UI stack by default (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`) + a monospace stack for code. Use a CDN font (Google Fonts) **only** if the source clearly calls for one and the user is okay with one network reference.
3. **Color palette.** 3-5 colors at `:root`: background, text, muted text, primary accent, optional secondary accent. Aim for AA contrast (≥ 4.5:1 body text). Dark mode via `@media (prefers-color-scheme: dark)`.
4. **Layout.** Single long-scroll with sticky TOC is the safe default. Use tabs only when sections are genuinely independent (e.g. comparing options). Use a deck layout only when the user asks.
5. **What becomes what.** Walk through the source and tag each section: prose → `<section>` with `<h2>`; matrix/comparison → `<table>`; flow/architecture → inline `<svg>`; code → `<pre><code>`; warnings/asides → `<aside>` callouts; lists of decisions → definition lists.

If `frontend-design` skill is available, defer aesthetic decisions to it; this skill's job is the structural map.

## HTML structure rules (non-negotiable)

- **Single `.html` file.** Inline everything: `<style>` in `<head>`, inline `<svg>` for diagrams. No external CSS/JS. A CDN font link is the only allowed network reference.
- **Self-identifying.** Add `data-generator="html-output"` to the root `<html>` tag so future invocations can detect a regenerable file.
- **Semantic HTML.** `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`. Headings nest properly (one `<h1>` per page, then `<h2>` for sections, `<h3>` for subsections).
- **CSS custom properties at `:root`** for color + spacing tokens. Use `clamp()` for responsive type sizes.
- **Mobile responsive.** Layout collapses cleanly at ≤ 768px (sidebar → top nav, multi-column → single column). Test by visualizing.
- **Print-friendly.** Include `@media print` block — hide nav, hide interactive elements, force light colors, ensure tables don't break mid-row where avoidable.
- **In-page nav.** Every `<section>` gets a stable `id`. Build a TOC of anchor links to those ids. Smooth-scroll via `scroll-behavior: smooth` on `:root`.
- **Code blocks.** `<pre><code>` with monospace + a subtle background. Minimal syntax highlighting via hand-emitted `<span class="kw|str|cmt|num">` if it adds value; otherwise leave code unhighlighted. **No** Prism.js, highlight.js, or any runtime script for highlighting.
- **`file://` clean.** The file must open from disk with zero fetches or module imports. No `<script type="module">`, no `import`, no `fetch()`.

## Required element checklist (for sources ≥ 50 lines)

The output **must** include:

- At least one **table** — decision log, comparison matrix, file-list, schema, etc.
- At least one **inline SVG diagram** — architecture, data flow, sequence, state machine. Pick whichever the source content actually justifies. No PNG, no Mermaid runtime — emit the SVG directly with proper `<title>` + `<desc>` for accessibility.
- An **anchor-linked TOC** (sidebar nav or top nav).
- A **`<footer>`** with: the source file path, the generation date (ISO), and a small "Generated by html-output" line.

## Forbidden patterns

- External script tags or stylesheets to anything off-host (except one CDN font).
- ASCII art diagrams when an SVG is feasible — that's the markdown trap this skill exists to escape.
- Emoji unless the source file used emoji.
- `<details open>` collapsing critical content — readers shouldn't have to hunt.
- Markdown-via-library renders (no `marked`, no `markdown-it`, no `pandoc` calls). Write the HTML directly.
- Auto-open in browser without asking.

## After write

1. Print the absolute path.
2. Print the byte size (one line, e.g. `42 KB`) so the user can sanity-check that it's a single shareable artifact.
3. Sanity-check size: a 100-line markdown plan should produce **≲ 50 KB** of HTML. If it's larger, the design pass got bloated — note this in the reply.
4. Ask: *"Open it now? (`open <path>`)"* — wait for confirmation before running `open`. Don't auto-open.

## Examples of triggering inputs

- `/html-output` — convert the most recent plan file.
- `/html-output ./project-management/ai-secretary/background-tasks-design.md` — convert that specific file.
- "Can you make this an HTML page?" (right after writing a long plan) — same as `/html-output`.
- "Render the SRS as a shareable HTML doc" with a path in context — convert that path.

## Out of scope (deferred, not denied)

- S3 / public-link upload — revisit when manual sharing becomes a pain.
- Interactive playgrounds (sliders, knobs, copy-prompt-back-to-Claude) — revisit when the user asks for an interactive plan.
- Diff / PR rendering — would be a separate `/html-review` skill.
- Bundled design-system stylesheet — revisit if outputs start visually drifting.
- Always-auto-open — current design asks first per the *"executing actions with care"* rule.
