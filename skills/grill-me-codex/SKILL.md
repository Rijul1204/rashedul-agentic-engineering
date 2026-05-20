---
name: grill-me
description: Interview the user relentlessly about a plan or design until the important decisions are explicit and defensible. Use when the user wants to stress-test a plan, get grilled on a design, or says "grill me".
---

# Grill Me

Use this skill to pressure-test a plan, architecture, or delivery approach until the key decisions, constraints, and risks are explicit.

## Workflow

1. Restate the target briefly so both sides are aligned.
2. Explore the repo, docs, and current implementation for anything discoverable before asking questions.
3. Ask one high-signal question at a time. Every question must expose a real decision, dependency, ambiguity, or risk.
4. For each question, provide:
   - why it matters
   - your recommended answer
   - what changes if the opposite answer is chosen
5. Keep drilling until the following are explicit:
   - goal and success criteria
   - users or stakeholders
   - inputs, outputs, and interfaces
   - constraints and non-goals
   - edge cases and failure modes
   - testing and rollout expectations
6. End with either:
   - a concise decision-complete summary, or
   - a short list of unresolved decisions that still block implementation

## Rules

- Prefer repo exploration over questioning when the answer is discoverable.
- Challenge weak assumptions directly and concretely.
- Avoid filler, repetition, and generic brainstorming.
- If the user jumps to implementation before defining the problem, recover the problem statement first.
- If the plan already looks solid, focus on hidden coupling, omitted failure cases, vague acceptance criteria, and operational risk.

## Output Shape

Use a compact structure:

1. Current understanding
2. Questions and recommended answers
3. Decision summary or remaining blockers

Keep the conversation moving. The goal is not to admire the plan. The goal is to make it hard to ship something underspecified.
