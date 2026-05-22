---
name: docs-probe-before-code
description: Pre-arms a third-party-integration conversation to follow docs → probe → fixture → code instead of guessing schemas from training-data memory.
---

# Docs → probe → fixture → code

For any third-party integration, **READ THE VENDOR'S CURRENT DOCUMENTATION FIRST.** Before writing or modifying code that talks to an external API (OpenAI, Anthropic, Recall.ai, Google, Stripe, Svix, Vercel, Supabase, anyone), the order of operations is:

1. **Docs** — open the vendor's current API reference page for the exact endpoint you're calling. Read it end-to-end. Capture the live URL and the date.
2. **Fixture** — build a test fixture from a real wire capture, not from your assumed schema. For event streams or paginated APIs, the fixture must exercise the cumulative / multi-event shape, not just one happy-path event.
3. **Probe** — hit the sandbox endpoint with a fully-populated payload. Don't probe with a minimal `{type, model}` first — a "field is required" error only proves *presence* is missing, not whether the *type* of the field you'd send next is also wrong. Surface every validation error in one round.
4. **Code** — translate the validated wire shape back into the route. Every new or modified call site gets a comment with today's date + the doc URL: `// [Doc check YYYY-MM-DD: <URL>]`.

What this rules *out*:

- Inferring schemas from training-data memory ("I remember this endpoint takes…").
- Inferring schemas from sibling endpoints ("the create endpoint nests `data`, so update probably does too").
- Trusting last quarter's mental model ("this is what it used to be").
- Probing with `{}` and adding one field at a time across many requests.

Why this matters: vendor schemas change without notice. The bug only ever surfaces in production on the first real invocation, and the post-mortem always traces back to "code was written from intuition instead of from the live doc + a probe." Whatever time you save by skipping docs is paid back at 10x when the schema-drift outage lands.

Apply this rule to every PR that touches a third-party boundary, no exceptions.
