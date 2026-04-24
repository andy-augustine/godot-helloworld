# early-requirements

This folder holds detailed specifications of the game at specific checkpoints. Each version captures everything — mechanics, art, exact numbers, scope — in enough detail that an AI could rebuild it from the spec in a single prompt.

## Why these exist

**1. They teach what a good prompt looks like.**
The quality of what an AI builds tracks the quality of what you hand it. Vague prompts ("make a metroid game") give you vague output. Specific prompts with numbers, geometry, and explicit scope give you what you actually wanted. These specs are examples of that level of specificity.

**2. They're snapshots in case we ever want to start over.**
If the codebase gets tangled or we want to try a different architecture, a spec is a target we can rebuild toward.

## Where to start

Open `v1-animated-platformer.md` and read it top-to-bottom, slowly. It captures the project after the animated-player phase (commit `3fcc600`). The appendix at the end pulls out the patterns that make the document itself effective.

## Patterns worth copying when you write your own prompt

- **Numbers beat adjectives.** `MOVE_SPEED = 220` is executable; "feels snappy" isn't.
- **State what's NOT in scope.** Without a scope fence, AIs will helpfully add features you didn't ask for. The "Intentional scope limits" section at the end of v1 is load-bearing.
- **Explain any non-obvious decision.** If something looks weird but is intentional, say why — otherwise the AI will "fix" it during rebuild.
- **Tables beat prose** for anything repetitive and structured (list of body parts, list of platforms).
- **Exact geometry.** Polygon points and positions stated explicitly so the rebuild looks like the original, not approximately like it.
- **State logic as pseudocode.** Ambiguity gets resolved by you once, not guessed by the model over and over.
- **Rule of thumb:** if you couldn't hand the spec to a new human and get a recognizable version back, it's too vague.

## Rule: don't edit old specs

Each spec is frozen to a specific commit. When the game evolves, add a new spec (`v2-*.md`, `v3-*.md`) — don't rewrite old ones. The value of a snapshot is that it's accurate about a specific moment; editing it later erases that.
