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

**Why:** godogen's stage-to-stage communication via versioned files is robust against context compaction. We already have `STRUCTURE.md` / `tests/README.md` / `GODOT_PRIMER.md` and a `plans/` folder; adding the missing two pieces matches the full protocol. `MEMORY.md` is especially valuable — it's the engine-quirks accumulator.
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

## 11. Team-mode GitHub setup (Phase B from ROADMAP.md)

**Why:** When the 6 collaborators come online, we want a working team workflow ready on day one — not improvised under pressure. This item captures the exact configuration so it can be executed in ~1 day once the timing is right, without re-deriving the design.

**Source:** Internal — designed in the session that produced [`ROADMAP.md`](../ROADMAP.md) (Phase B section). Influenced by standard practice in successful small OSS game projects (Mindustry, Cataclysm: DDA, OpenRCT2, Godot itself).

**Effort:** ~1 day of focused setup work. Schedule the day BEFORE collaborators arrive so the workflow is in place when they clone.

**Deliverable:** Concrete configuration in this order — each step ~30-60 min:

1. **Branch protection on main**
   - GitHub repo settings → Branches → add rule for `main`
   - Require pull request before merging (1 reviewer)
   - Require status checks to pass (when we have CI later)
   - No direct commits to main (you can self-PR if solo)

2. **Issue labels** (delete defaults you don't want, create the project-specific ones)
   - Keep: `bug`, `enhancement`, `documentation`, `good first issue`
   - Add: `gamedev`, `tooling`, `research`, `discussion`, `polish`, `audio`, `ui`
   - Color discipline: gamedev = green, tooling = blue, research = purple, discussion = grey, bug = red

3. **Issue templates** in `.github/ISSUE_TEMPLATE/`
   - `feature_request.md` — short form, prompts for "what" and "why"
   - `bug_report.md` — repro steps, expected vs. actual
   - `idea_discussion.md` — for `discussion`-labeled exploration items
   - All templates pre-fill the appropriate label

4. **PR template** in `.github/pull_request_template.md`
   - 5-line form: What does this do? / Closes #X / How tested? / Screenshots if UI / Anything reviewers should know

5. **Single GitHub Project (board view)**
   - Name: "Game Development"
   - View: board layout
   - Status field options: `Backlog` / `In Progress` / `In Review` / `Done`
   - Auto-add: any new issue or PR to this repo lands in Backlog
   - Auto-status: PR opened linking issue → In Review; PR merged → Done

6. **Branch naming convention** documented in WORKFLOW.md
   - Pattern: `feature/<issue#>-<short-slug>` (e.g., `feature/12-audio-foundations`)
   - Other prefixes: `fix/`, `chore/`, `docs/`

7. **WORKFLOW.md** — new file at project root
   - Lifecycle from `ROADMAP.md` codified with concrete commands
   - "Claim before you start" — assign issue + push plan with status header
   - "Fetch before you start" — `git fetch && gh issue list --assignee @me`
   - PR closing keywords (`Closes #X` in PR body)
   - End-of-session backlog flush ritual (promote ripe items to issues)

8. **Update CLAUDE.md** with a "Team mode" section
   - Reference WORKFLOW.md
   - Note: branches not direct-to-main, PRs required
   - Note: when starting work, check `gh issue list` not just `plans/`

9. **Migrate 2-3 high-confidence backlog items to issues as a test**
   - Pick: polish-checklist skill, audio music+transition stingers, visually distinct second room
   - Validate the labels, templates, and board automation work end-to-end
   - Don't bulk-migrate — gradual is fine

10. **One round of self-review**
    - Open a small test PR yourself to verify the flow
    - Confirm board automation moves the card on PR open / merge
    - Confirm closing keywords auto-close the linked issue

11. **Onboarding doc for collaborators**
    - Could be a section in WORKFLOW.md or a separate `CONTRIBUTING.md`
    - "Clone the repo, run SETUP.md, claim an issue with `good first issue` label, create branch `feature/<#>-<slug>`, work it, open PR"
    - Walk-through of one complete cycle

**Notes:**
- Don't do this prematurely. The setup is overhead with zero benefit while you're solo. Right time = "collaborators are arriving in the next 1-2 weeks."
- When starting this item, write `plans/team-mode-github-setup.md` first per the project plan-archiving convention.
- The CLAUDE.md "Plan archiving" rule extends naturally: post-onboarding, plans archive in the same PR that completes the work.
- ROADMAP.md Phase B section will be partially deleted when this is executed — the workflow becomes "live" in WORKFLOW.md, ROADMAP.md just points at it.

---

## 12. Overnight crawl — current Godot 4.6 / GDScript community knowledge — **complete (2026-04-26)**

**Status:** Shipped. Deliverable at [`research/tools/godot-4.6-current-intel.md`](../research/tools/godot-4.6-current-intel.md). Runbook preserved at [`research/crawl/PLAN.md`](../research/crawl/PLAN.md) for re-runs (re-execute via the `/refresh-godot-intel` slash command). Recommended re-scan cadence: monthly.

**Why:** Our training data and research-doc sources (Godot stable docs, GUT issue #608 May 2024) are stale relative to current Godot. The user identified this explicitly during the 2026-04-26 skill-cards build: "training data is likely missing all this info." A focused crawl of *current* community sources (forums, Discord, recent GitHub issues, Reddit, blog posts dated 2025–2026) for Godot 4.6 quirks would close the gap. godogen's docs explicitly do NOT cover Control GUI / drag-and-drop testing — that domain is uncharted in their work too. (The narrow drag-test question that triggered this item is now resolved — see [`research/tools/godot-4.6-drag-test-current-intel.md`](../research/tools/godot-4.6-drag-test-current-intel.md), [`tests/RESULTS.md`](../tests/RESULTS.md), and `feedback_gdscript_practices.md` rules 12–13. The broader knowledge-gap remains.)

**Source:** Triggered by user request during the 2026-04-26 skill-cards build. Cross-references `research/tools/godogen.md` (godogen migrated to C# partly because of GDScript paper-cuts — they didn't solve them, they avoided them; we need to learn how others *stayed* in GDScript).

**Effort:** One overnight remote agent run (estimated 4–8 hours of crawl + synthesis). Run via `/schedule` at idle hours.

**Deliverable:** `research/tools/godot-4.6-current-intel.md` containing:
- **GDScript quirks (current):** `:=` Variant traps beyond what godogen documented; current state of `await` / coroutines / `_cmd_execute_script`-style wrappers; type-system gotchas in 4.6 specifically.
- **Why does `Input.parse_input_event` from inside `_cmd_execute_script` not reach `_gui_input`?** This was the one open question we couldn't isolate during the skill-cards build. MCP `simulate_*` tools work; direct `Input.parse_input_event` from `execute_game_script` doesn't. Community knowledge or maintainer intuition welcome.
- **Frame-rate-dependent code patterns:** the godogen quirks doc had a few but only those they hit. What others does the community currently warn about?
- **Test harness patterns beyond godogen's:** GUT current state, GdUnit4 status, any newer frameworks. What do top-100-stars Godot repos use?
- **Known 4.6 regressions or breaking changes** vs. 4.4/4.5 that we should be aware of.
- **Source pointers:** every claim cites a forum post, GitHub issue, Discord screenshot, or recent video, with the date. We should be able to follow the trail back to the primary source.
- **Test scenarios to validate:** for any non-obvious claim, a small reproducible test harness we can run locally to confirm. Don't trust unverified secondhand info.

**Crawl sources (seed list):**
- Godot Discord `#help` and `#contributors-chat` archives (last 6 months)
- godotengine/godot GitHub issues + closed PRs filtered by `4.6` label / milestone
- godotforums.org (last year)
- r/godot Reddit (top + new, last 6 months)
- Hacker News submissions tagged Godot (last year)
- github.com/topics/godot-4 — top 100 repos, prioritize ones with `tests/` dirs
- Recent blog posts via Google with `"godot 4.6" filetype:md` etc.
- bitwes/Gut issues + recent commits (post-#608 era)
- chickensoft-games/GodotTestDriver — patterns even though it's C#
- Godot Steamworld dev twitch streams / YouTube post-mortems

**How to execute:** Use `/schedule` to spawn a background remote agent with the spec above. Agent should produce a single artifact at `research/tools/godot-4.6-current-intel.md`, properly formatted, source-cited, and scenario-rich enough that the user can run a few small tests in the morning to validate the highest-value claims before encoding any of them.

**Notes:** This is the kind of thing that decays — a crawl run today is more valuable than a crawl run six months from now. Re-run quarterly while we're actively in this project.

---

## 13. Eventually: extract reusable artifacts to a portable starter kit

**Why:** When several items above are stable and used routinely, the team's time savings compound by re-using them on a new project (card/rogue-like, future Metroidvania) without re-authoring.
**Source:** Internal — see `research/README.md` long-term vision.
**Effort:** Days; trigger when a second Godot project starts and we want to bootstrap it from this one's conventions.
**Deliverable:** A separate repo (e.g. `claude-godot-toolkit`) containing: skills, hooks, conventions, doc templates, MCP usage notes, with a one-page README on how to drop them into any Godot project. Skills/hooks/conventions are written portably (no project-specific cross-references) per the README.md convention so this extraction is mostly file-moves.
**Notes:** Don't extract prematurely. The bar is "I'd copy this into a brand-new project tomorrow and use it day one." Items that haven't earned that bar stay in this project.
