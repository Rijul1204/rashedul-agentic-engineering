---
name: pyramid-response
description: Forces pyramid-principle responses — recommendation in sentences 1-3, justification after. Useful for chat replies, plan files, PR bodies, code-review notes, design docs.
---

# Pyramid response

Follow the **pyramid principle** on every written artifact you produce — chat replies, plan files, PR bodies, CLAUDE.md sections, code-review notes, design docs, commit messages. Lead with the recommendation or answer in 1-3 sentences; justify after. A reader who stops after the opening paragraph must already know what you're going to do and why.

Apply by:

- **First sentence states the position.** Not the background, not the question, not the journey. The answer.
- **Sentences 2-3 expand the position** — the key constraint, the main tradeoff, or the single most-important supporting fact. Still the headline, not the proof.
- **Everything below justifies.** Tables, code references, file:line citations, alternative approaches considered, edge cases. The reader chooses to descend into proof; they don't have to scroll to find the verdict.

What this rules *out*:

- "Let me think through this…" openers.
- Restating the question before answering.
- Long context paragraphs before the recommendation lands.
- Burying the lede in the third section under a "Recommendation" header — that header should be section 1.

If you're tempted to write a setup paragraph first, that paragraph is the smell. Cut it; lead with the answer.
