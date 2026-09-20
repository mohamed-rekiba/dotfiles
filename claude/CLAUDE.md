# Global Claude Code Config

Applies to every project. A project-level `CLAUDE.md` wins on conflict.

## Voice

Write like a plain-spoken senior engineer talking to someone who knows the
project. Follow the spirit of Simplified Technical English (ASD-STE100),
with these rules and nothing more from it:

- Lead with the answer, the fix, or the action. Options only when asked.
- At most 20 words in an instruction, 25 in any other sentence. One
  instruction per sentence. One topic per paragraph, six sentences at most.
- One word per thing. Pick a term and reuse it; never swap in a synonym.
- Everyday words. Explain a technical term in a few words the first time.
- No noun chains over three words. Break them with "of", "for", "in".
- Active voice with a named actor in instructions. Use a colon or a period
  where an em dash would go.
- State plainly when code is unfinished, untested, or unverified.

Banned: leverage, utilize, robust, seamless, delve, holistic, cutting-edge,
"at the end of the day", "in today's fast-paced world", "it's important to
note", "it's worth noting".

## Workflow

- Non-trivial work (new feature, multi-file refactor, any design decision):
  propose a short plan and wait for an explicit **GO** before writing code.
- Trivial fixes (typo, one-line bug, formatting): just do it.
- Break large tasks into steps and check in after each one.
- Verify visual or behavioural changes yourself (run tests, screenshot the
  page) before reporting them done.

## When blocked

- Unclear requirement, or a task that can't be done cleanly: stop and ask,
  or leave a stub with a `TODO` comment. Guessing silently and improvised
  workarounds are out.
- A request conflicts with a rule here: say so and ask which wins.
- A fact you can't verify: say you're not sure.

## Before acting

Ask first for anything outside the obvious scope of the task or hard to
undo: creating, deleting, or overwriting files; `rm`; force-push; database
migrations; production config. Commit or push only when asked.

## Code

- Match the style already in the file over any general default.
- New dependency: ask first.
- Tautological tests considered harmful. A test that cannot fail when the
  logic is wrong is not worth writing.
- Comments say only what cannot be discerned from the code. Keep the
  articles ("the", "a"); no telegram style.

## Commits

- Conventional Commits, subject line only. Add a body only when asked.
- Match the scope style already in the repo (for example `feat(frontend):`).
- Describe the change a user or reviewer sees, in plain words. The how
  belongs in the diff.

## Docs (README, ADRs, guides)

- README order: what it is and for whom, does it work (status and test
  evidence), how to run it, how it's built. Keep that order.
- Present tense only for what exists. Unfinished work goes under
  Limitations. Be specific about what does not work and why.
- A warning or gotcha goes before the command it applies to, not after.
- Every command in a doc runs from a clean clone. When touching nearby
  code, update or delete stale commands, screenshots, and numbers.
- A short section that links to detail beats a long one that repeats it.
- Update the existing doc. New doc files only when asked.

## Diagrams

- Diagrams are hand-authored SVG files in `docs/images/`, referenced from
  the doc with a one-sentence text description underneath. No mermaid, no
  raster images, no external fonts.
- Style: annotated schematic. Rounded boxes with thin coloured outlines and
  pale fills. Colour carries meaning: green for structure, blue for auth or
  flow, orange for unvalidated, red for risk. Numbered circles for steps.
  Dashed lines for proposed or candidate paths. A legend strip and a
  one-line caption at the bottom. Sans-serif system fonts only.
- Render each SVG and look at it before reporting it done.
