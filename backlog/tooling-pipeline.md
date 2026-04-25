# Tooling / Pipeline backlog

Skills, hooks, doc conventions, and dev-loop improvements. Items here should be **portable** — the goal is that working ones eventually graduate into a Claude-Code-driven Godot starter kit usable on any new project. See [`README.md`](README.md) for conventions.

Ordered roughly by ROI (effort vs. value), but pick whatever's most relevant.

---

## 1. Add `visual-qa.md` skill (Static / Dynamic / Question modes)

**Why:** Today, anyone running visual QA has to remember the right MCP tool names (`get_game_screenshot`, `compare_screenshots`, `capture_frames`) AND the timing pitfalls in TESTING.md. A single skill collapses that into a one-liner. Highest immediate ROI, especially with 6 new collaborators who don't know the timing rules yet.
**Source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — the Static / Dynamic / Question taxonomy from `claude/skills/visual-qa/SKILL.md`.
**Effort:** 2–4 hours.
**Deliverable:** `.claude/skills/visual-qa/SKILL.md` (or wherever Claude Code looks for project-local skills) with three modes:
- **Static**: 1 reference image + 1 current screenshot, diff and report.
- **Dynamic**: reference + 2 FPS sequence (catches motion bugs that single-frame misses).
- **Question**: no reference, just describe what's on screen.

Should cite TESTING.md for the `simulate_action` + `capture_frames` timing pitfall, and wrap the existing godot-mcp-pro tools.
**Notes:** This skill is a good first test of whether `context: fork` frontmatter from godogen actually works in our Claude Code setup — that experiment is item #5. Build the skill without the fork field first; layer fork on after #5 confirms it works.

---

## 2. Add `polish-checklist.md` skill

**Why:** Formalizes the polish-mode behavior currently only in memory (`feedback_major_capability_polish.md`). Gives the team a structured action → visual feedback → audio → camera-shake table to consult when a feature feels flat. Maps cleanly onto a Metroidvania.
**Source:** [`research/tools/godot-ai-builder.md`](../research/tools/godot-ai-builder.md) — `skills/godot-polish/SKILL.md` table.
**Effort:** 1 hour.
**Deliverable:** `.claude/skills/polish-checklist/SKILL.md` with the godot-ai-builder table lifted verbatim, plus Metroid-specific rows added: heavy landing (already shipped), room transition, ability acquired, save room ambient, hit reaction. Triggers on "polish", "make it feel better", "add juice".
**Notes:** Update the existing `feedback_major_capability_polish.md` memory entry to point at this skill instead of holding the rule itself.

---

## 3. Adopt the document protocol — `PLAN.md` + `MEMORY.md`

**Why:** godogen's stage-to-stage communication via versioned files is robust against context compaction. We already have `STRUCTURE.md` / `TESTING.md` / `GODOT_NOTES.md` and a `plans/` folder; adding the missing two pieces matches the full protocol. `MEMORY.md` is especially valuable — it's the engine-quirks accumulator.
**Source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — `PROJECT.md` Document Protocol section.
**Effort:** 30 min for the convention, ongoing for content.
**Deliverable:** Two new files at the project root:
- `PLAN.md` — written by `decompose-feature.md` (item #6) before any major capability. May replace or complement `plans/`. Open question: when do we write a per-feature plan in `plans/<feature>.md` vs. a top-level `PLAN.md`? Probably: top-level `PLAN.md` summarizes current focus, `plans/<feature>.md` is a per-feature deep dive — `PLAN.md` points at the active one.
- `MEMORY.md` — engine quirks. **Seed from godogen's `claude/skills/godogen/quirks.md`**, drop C#-specific entries, keep the Camera2D / ArrayMesh / MultiMesh save bug / deferred collision rules (those apply to GDScript equally).
**Notes:** Document the convention in CLAUDE.md (when to write to PLAN.md, when to write to MEMORY.md).

---

## 4. Seed `MEMORY.md` from godogen's `quirks.md`

**Why:** godogen has accumulated real engine gotchas across 3,000 stars of usage. We'd otherwise re-discover them one painful playtest at a time. Free knowledge transfer.
**Source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — `claude/skills/godogen/quirks.md`.
**Effort:** 1 hour (read theirs, drop C#-only, write into ours).
**Deliverable:** Initial `MEMORY.md` content covering at minimum: Camera2D.MakeCurrent ordering, ArrayMesh GenerateNormals, MultiMesh save bug, deferred collision state changes, our own existing gotcha (the physics-flush bug fixed in commit 90bbb2f).
**Notes:** Sequenced after #3 (the convention).

---

## 5. Verify `context: fork` frontmatter actually works in Claude Code

**Why:** godogen's most architecturally interesting idea — heavy payloads (screenshots, API docs) load in a side context with their own model selection, keeping the main orchestrator lean. **Unverified**: may be godogen-specific tooling, not a native Claude Code feature.
**Source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — Forked-context skills section.
**Effort:** 1-hour spike.
**Deliverable:** A test skill with `context: fork` and `model: sonnet` frontmatter. Verify whether Claude Code routes it to a separate context with the named model, OR ignores those fields, OR errors. Document findings in this file (turn item into research note if it doesn't work, into a higher-priority refactor if it does).
**Notes:** If it works, this changes #1's design — visual-qa becomes a forked-context skill so screenshot bytes never enter the main context. If it doesn't, we need a different strategy (separate Sonnet sub-agent via `Agent` tool for visual diffing).

---

## 5b. ~~Add `godot-api` skill — local searchable Godot class reference~~ — **BUILT, PARKED**

**Status:** Built (commits `f9c4d5e` + `9cadb16` on `skill/godot-api`, merged to main as `e819c5e`) but **deliberately not active** — `SKILL.md` renamed to `SKILL.md.disabled` so Claude Code's discovery ignores it. See `.claude/skills/godot-api/README.md` for the full state and re-enable instructions.

**Why parked instead of active:** The team wants to first measure whether GDScript hallucinations or other in-session friction are common enough to justify changing how Claude works. The skill is preserved on disk and rebuildable; activation is one `git mv`.

**When to revisit:**
- A team member reports Claude inventing a Godot method/signal/property that doesn't exist
- Audio, tilemap, or save-system work hits API uncertainty Claude can't resolve from training memory
- Godot 4.7+ ships and we want Claude to know the new APIs immediately
- A new project (card/rogue-like) starts where API recall matters from day one

**Original research source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — `claude/skills/godot-api/SKILL.md`, `gdscript.md`, `tools/godot_api_converter.py`. Original files at https://github.com/htdt/godogen/tree/master/claude/skills/godot-api .

---

## 6. Add `decompose-feature.md` skill (risk-first PLAN.md generator)

**Why:** Before any major capability, isolate the genuinely hard parts (custom shaders, procgen, anything we haven't done before) and build everything routine in one pass. godogen's `decomposer.md` formalizes this.
**Source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — `claude/skills/godogen/decomposer.md`.
**Effort:** 1–2 hours.
**Deliverable:** `.claude/skills/decompose-feature/SKILL.md`. Trigger: user requests new subsystem (enemies, save system, audio system, etc.). Output: a `plans/<feature>.md` with risk-first decomposition. Risk taxonomy adapted from godogen — drop 3D-only entries (rigging, ArrayMesh procgen), keep the universal ones (state machines beyond simple, shaders, networking, save/load).
**Notes:** Sequenced after #3 (uses PLAN.md convention).

---

## 7. Add `scope-distiller.md` skill

**Why:** Useful for the future card/rogue-like backlog, when we'll get multi-doc design briefs that need shrinking to a one-session scope. Strips multi-doc GDDs to ~12-15 scripts of work.
**Source:** [`research/tools/godot-ai-builder.md`](../research/tools/godot-ai-builder.md) — `skills/godot-distiller/SKILL.md`.
**Effort:** 2 hours.
**Deliverable:** `.claude/skills/scope-distiller/SKILL.md`. Trigger: user dumps a multi-doc design in. Output: a session PLAN.md with the core loop, list of ≤12-15 scripts, explicit "not in scope" callouts.
**Notes:** Speculative until we have a multi-doc design to distill. Defer until the second project (card/rogue-like) starts.

---

## 8. Add `stop-guard.sh` hook for major capability builds

**Why:** Prevents the agent from declaring victory mid-build during long capability work (camera/room system, future enemies pass). Touches a flag file at start, blocks Claude Code's `Stop` event until the agent removes it. Pairs with polish-mode trigger.
**Source:** [`research/tools/godot-ai-builder.md`](../research/tools/godot-ai-builder.md) — `hooks/stop-guard.sh` + `hooks.json`.
**Effort:** 30 min.
**Deliverable:** `.claude/hooks/stop-guard.sh` + entry in `.claude/settings.json` hooks block. Active only while `.claude/.build_in_progress` exists.
**Notes:** Only activate manually for explicit major-capability work — don't make it always-on, or every bug fix becomes a multi-step ceremony.

---

## 9. Add procedural-visual-quality bar (`godot-assets`-style note)

**Why:** Currently the player rig is hand-authored polygons; future entities (enemies, NPCs, pickups) need a quality bar so they don't regress to flat shapes. godot-ai-builder's "body + outline + shadow + highlight + animation" rule is a good baseline.
**Source:** [`research/tools/godot-ai-builder.md`](../research/tools/godot-ai-builder.md) — `skills/godot-assets/SKILL.md`.
**Effort:** 1 hour.
**Deliverable:** A short doc — could be `STRUCTURE.md` addendum or a new `art-conventions.md` — covering: minimum visual elements per entity, color discipline (palette per project), animation expectations, references to the player rig as the existing example.
**Notes:** Lower priority; activates when we add the first new entity type.

---

## 10. Spike — animated 2D sprite pipeline via Grok video → frame extraction

**Why:** godogen's most genuinely novel 2D-applicable concept — generate animated sprites by prompting Grok video, extracting frames, trimming to a loop. If it works at acceptable cost, it could replace hand-authoring of every NPC/enemy animation.
**Source:** [`research/tools/godogen.md`](../research/tools/godogen.md) — `claude/skills/godogen/asset-gen.md`.
**Effort:** Half day spike.
**Deliverable:** A standalone test: pick one player-equivalent character, run reference → pose → video → frame extract → loop trim. Compare output quality and cost vs. hand-authoring. Document results in a new research note (`research/spikes/grok-video-sprites.md`) regardless of outcome — this is research, not feature work.
**Notes:** Cost-uncertain. Defer until we actually need a second character (enemies pass).

---

## 11. Eventually: extract reusable artifacts to a portable starter kit

**Why:** When several items above are stable and used routinely, the team's time savings compound by re-using them on a new project (card/rogue-like, future Metroidvania) without re-authoring.
**Source:** Internal — see `research/README.md` long-term vision.
**Effort:** Days; trigger when a second Godot project starts and we want to bootstrap it from this one's conventions.
**Deliverable:** A separate repo (e.g. `claude-godot-toolkit`) containing: skills, hooks, conventions, doc templates, MCP usage notes, with a one-page README on how to drop them into any Godot project. Skills/hooks/conventions are written portably (no project-specific cross-references) per the README.md convention so this extraction is mostly file-moves.
**Notes:** Don't extract prematurely. The bar is "I'd copy this into a brand-new project tomorrow and use it day one." Items that haven't earned that bar stay in this project.
