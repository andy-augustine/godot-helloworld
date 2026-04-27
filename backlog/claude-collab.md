# Claude collaboration backlog

Process / pipeline / tooling improvements specifically about **how Claude works alongside the human developer**, not about the game and not about general game-dev tooling. Items here mature into reusable artifacts (slash commands, memory rules, session protocols, doc conventions) that should eventually be portable to *any* Claude-Code-driven project — not just Godot, not just games.

If `tooling-pipeline.md` is "tools that help me build this game faster," `claude-collab.md` is "tools that help us collaborate as a human–AI pair across any project." See [`README.md`](README.md) for backlog conventions.

Ordered roughly by ROI; pick whatever's most relevant.

---

## 1. `/wrapup` slash command — interactive session-end pipeline

**Why:** Sessions currently end ad-hoc. Lessons learned, doc drift, backlog graduation, and memory rule additions all happen if-I-remember rather than as a pipeline step. The post-ship docs sweep covers the case where a *plan* shipped, but doesn't cover the broader end-of-session checks (pushed? playtest stopped? scheduled tasks still running? new memory rule warranted by the bugs we caught?).
**Source:** Internal — proposed during the 2026-04-27 info-arch refactor.
**Effort:** ~45 min.
**Deliverable:** `.claude/commands/wrapup.md` implementing the 8-step process described in `plans/refactor-info-architecture.md` P7. Interactive — surfaces candidates for backlog graduation and memory-rule additions, waits for go/skip per item, no auto-commits. Memory rule additions require evidence (commit hash, repro, test result) attached.
**Notes:** Lands as part of the same refactor that produces this backlog file. After it ships, this entry will be marked complete with a link to the command.

---

## 2. `/preflight` command — risk check before risky ops

**Why:** Some operations should not happen if state is wrong — e.g. starting a new plan when an old one is still in `plans/`, force-pushing without explicit auth, deleting `_audio_workshop/` without `.gdignore` cleanup, running the intel crawl while one is already in flight. A preflight command verifies the obvious things before letting the model proceed.
**Source:** Internal — recurring pattern noted in the post-ship docs sweep rule (verify state before declaring done).
**Effort:** ~30 min.
**Deliverable:** `.claude/commands/preflight.md`. Takes an argument (the operation about to run) and runs the matching checklist — e.g. `/preflight new-plan`, `/preflight force-push`, `/preflight delete-asset-dir`. Returns "ok to proceed" or a list of blockers.
**Notes:** Sequence after `/wrapup` so the wrapup pattern is settled before generalising. Some preflight checks may overlap with wrapup; design so they share helpers.

---

## 3. "Skills earned" inventory file — positive affordances for future-me

**Why:** The auto-memory feedback files are *negative* (rules to avoid bugs). There's no positive-framing companion that says "in this codebase: `load()` over `preload()` for active dev, `set_deferred()` for in-callback property mutations, `get_node_or_null('/root/X')` over symbolic autoload reference if X was added mid-session, `Array[1] = 0` for lambda accumulator." A future-Claude reading the negative rules has to invert them to know *what to do*. A positive doc would be faster.
**Source:** Internal — observed during the 2026-04-27 refactor.
**Effort:** ~1.5 hr to derive from existing memory files.
**Deliverable:** `skills.md` or similar (auto-memory file? or project doc?) with the positive affordances pulled from the feedback files. Format as a quick-reference card, not prose.
**Notes:** Open question: lives in auto-memory (only Claude reads it) or project root (humans see too)? Probably auto-memory, since it duplicates the negative rules from a different angle.

---

## 4. Periodic "session retrospective" remote agent

**Why:** Even with `/wrapup`, some lessons get missed. A monthly background agent that scans recent commits for missed memory updates ("we fixed three lambda-signal bugs in the last month — should rule 15 be sharpened?", "we keep restoring autoload entries to project.godot — is rule 6 stronger than the one-line warning?") would catch slow-drift patterns.
**Source:** Internal — proposed during the 2026-04-27 refactor.
**Effort:** ~1 hr to write the prompt + RemoteTrigger config (similar shape to `/refresh-godot-intel`'s monthly agent).
**Deliverable:** A scheduled remote agent on the same cadence as the intel crawl (monthly, 02:00 EDT) that reads the last month of commits + the current memory files, identifies patterns, and proposes memory updates. Output: a draft issue or commit-on-a-branch that the user can review.
**Notes:** Sequence after `/wrapup` lands and we have ~2 months of post-wrapup data to scan.

---

## 5. Bug-pattern memory consolidation pass

**Why:** Memory files are topic-split by intent (gdscript-practices, godot-mcp-scene-editing, etc.). Over time some bugs sit awkwardly across categories — the air-dash refresh bug from 2026-04-27 is *both* a GDScript practice (rising-edge state interactions are fragile) AND an MCP/scene-editing concern (verifying via test rather than assuming). When the feedback files reach a critical mass (~30+ rules each), a consolidation pass would refactor them into more coherent topic boundaries or a positive-affordances split.
**Source:** Internal — anticipated.
**Effort:** ~2 hr when triggered.
**Deliverable:** Reorganized memory files. Possibly a new positive/negative split (rules vs affordances). Possibly a new dimension (per-system: physics, GUI, animation, ...).
**Notes:** Don't trigger prematurely. The bar is "the existing topic split is genuinely making it hard to find the right rule." We're not there yet — both files are well-organized.

---

## 6. CLAUDE.md ↔ memory cross-reference linter

**Why:** CLAUDE.md states the high-level rules (plan-archive, post-ship sweep, polish mode, etc.). The auto-memory feedback files state the per-Claude reflexive habits. There's overlap — and risk of drift if they're updated independently.
**Source:** Internal — drift risk noted during refactor.
**Effort:** ~1 hr.
**Deliverable:** A pre-commit hook OR a `/wrapup` sub-step that scans both CLAUDE.md and the auto-memory directory, flags rules that contradict each other or that are restated in a way that's drifted.
**Notes:** Lower priority — drift hasn't actually happened yet. Deferred until we see the first real instance.
