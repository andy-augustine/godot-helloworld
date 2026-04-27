# Overnight Godot 4.6 / GDScript community intel crawl — RUNBOOK

| | |
|---|---|
| Drafted | 2026-04-26 |
| Trigger | backlog item #12 (`backlog/tooling-pipeline.md`) |
| Knowledge cutoff being patched | January 2026 (assistant training cutoff) |
| Today | 2026-04-26 — so target window for "new" intel is ~Q4 2025 forward |
| Final deliverable path | `research/tools/godot-4.6-current-intel.md` |

This is a self-contained runbook. A fresh Claude session reading it should be able to execute the entire crawl without any conversation context. If anything in the briefs is ambiguous, prefer following the brief as written — DON'T add scope.

## Pre-authorized decisions (don't re-ask the user)

1. **Five parallel topic agents are OK.** General-purpose agents with web access. Token cost is bounded.
2. **Auto-proceed on surprise.** If the pre-scan finds something concerning (e.g., Godot 4.7 just released, a major regression announced), DO NOT pause to ask the user. Note the surprise prominently in the synthesis output and proceed with the plan as written. The user explicitly chose this default so they don't get woken up.
3. **Output path is fixed.** `research/tools/godot-4.6-current-intel.md`.

## Project context (for the agents)

A 2D Metroidvania platformer in Godot 4.6.2 using GDScript. Driven via the godot-mcp-pro MCP plugin from Claude Code. Already-encoded knowledge that agents should NOT re-discover and re-document:

- The synthetic drag-and-drop recipe (works in 4.6.2 with `relative_x/y` populated + addon patches; documented in `tests/RESULTS.md` and `research/tools/godot-4.6-drag-test-current-intel.md`). Not a research target.
- godogen GDScript practices (filed in `feedback_gdscript_practices.md` memory).
- godot-mcp-pro internals (filed in `research/tools/godot-mcp-pro-internals.md`).

If the crawl finds *contradictions* with any of the above, surface them prominently. Otherwise no need to repeat known material.

---

## Phase 0 — Pre-scan (single agent, ~30 min, foreground)

**Dispatch as**: `subagent_type: general-purpose`

**Output file**: `research/crawl/sourcemap.md`

**Brief (verbatim — copy into agent prompt):**

> Targeted reconnaissance task — under 45 minutes. Identify currently-active venues for Godot 4 / GDScript discussion, rank by signal quality, and identify high-signal individual contributors. Do NOT investigate technical content; that's for follow-on agents. This is sources-only.
>
> ## What to find
>
> 1. **Active venues, ranked by signal**:
>    - GitHub orgs/repos: `godotengine/godot` (issues, PRs, recent activity); `godotengine/godot-proposals`; `godotengine/godot-docs`; bitwes/Gut; MikeSchulze/gdunit4; chickensoft-games orgs; any active Godot-tooling orgs.
>    - Forums: `forum.godotengine.org` (the official re-launched forum). Note post volume and median response time.
>    - Reddit: r/godot — note mod policy on tech support, recent activity.
>    - Discord: Godot Engine official server — note publicly accessible via web (yes/no), key channels.
>    - X / Mastodon: useful hashtags (#godot4, #godotengine), check if core devs are active there.
>    - YouTube: creators with technically substantial 2026 content (NOT beginner tutorials). GDQuest, kidscancode, etc — verify they're still posting.
>    - Blogs: list any individual dev blogs with recent (2026) Godot content.
>    - Asset Library: top-starred plugins released or updated in 2026.
>    - HackerNews: any Godot tag activity, or just submissions.
>
>    For each: rank as **HIGH** (load-bearing for our needs) / **MED** (worth checking) / **LOW** (skip unless desperate). Justify rankings briefly.
>
> 2. **High-signal individual contributors active in 2026** — aim for ~15:
>    - Core maintainers: who's reviewing PRs, who's shipping commits to godotengine/godot, who's answering proposals.
>    - Community: prolific issue-resolvers on the forum, Reddit power-users with deep technical answers, plugin authors who respond well to issues.
>    - For each: name (or handle), domain (e.g., "GUI / Control hit-testing", "GDScript type system", "rendering pipeline"), primary venue link, why useful (1 sentence), one example contribution if you can find it.
>
> 3. **Recent milestones (post-Jan 2026)**:
>    - Godot 4.6 release notes — 4.6.0, 4.6.1, 4.6.2 — what changed, what's known broken
>    - 4.6.3 / 4.7 announcements or roadmap mentions
>    - GUT 9.x / 10.x current version + recent changelog
>    - GdUnit4 current version + recent changelog
>    - GodotCon or Godot Foundation announcements 2026
>    - Major library/framework releases dated 2026
>
> 4. **Sources to skip** — venues that *used* to be good but are now low-signal (gone, abandoned, replaced). Saves topic agents from chasing dead links.
>
> ## Output format
>
> One markdown file at `research/crawl/sourcemap.md` (~150-250 lines). Sections matching the four areas above. Cite every source with URL + dated activity sample.
>
> ## Surprise reporting
>
> If you discover any of the following, prepend a **⚠️ Surprise** section at the top of the sourcemap:
> - Godot 4.7 has been released
> - Major regression in 4.6.x specifically affecting input, GUI, or 2D rendering
> - GUT or GdUnit4 has been deprecated or replaced
> - Anything else that meaningfully changes the topic agents' scope
>
> Do NOT pause; just flag it.
>
> ## Reporting back
>
> Under 200 words. Where the file is, top-3-most-useful venues you found, top-3-most-useful people you found, and any surprises.

**After this agent returns**: read `research/crawl/sourcemap.md`, sanity-check it (no obvious broken sources, a reasonable number of contributors identified, no missing major venues), then proceed to Phase 1.

---

## Phase 1 — Five parallel topic agents (~45 min each, background, dispatched together)

**Dispatch all five in a single message** as `subagent_type: general-purpose` with `run_in_background: true`. Pass each agent the path to `research/crawl/sourcemap.md` and tell them to use it as their source list.

When all five have signaled completion (you'll get notifications), proceed to Phase 2.

### Topic A — Engine quirks & regressions

**Output file**: `research/crawl/topic-engine-quirks.md`

**Brief (verbatim):**

> Find what's *new since Jan 2026* in Godot 4.5/4.6 engine quirks and regressions affecting: input system, GUI dispatch (Control hit-testing, focus, drag-drop), animation, physics (2D and 3D), rendering pipeline, save/load (resource system, .tscn quirks). Use the source map at `research/crawl/sourcemap.md`. Cite every claim with URL + date. Surface 5–10 highest-impact findings; punt the rest.
>
> Already known and documented; do NOT re-discover unless contradicted: synthetic drag works in 4.6.2 via `Input.parse_input_event` with `relative_x/y` populated; godot-mcp-pro's auto-promotion of `unhandled` on motions has a local patch upstreamed at github.com/youichi-uda/godot-mcp-pro/pull/25; `force_drag` + synthetic release is by design a dead end. References in TESTING.md Pattern 4.
>
> Output a single markdown file ≤200 lines with: (1) TL;DR of the top 3 findings; (2) per-finding entries with title, severity (HIGH/MED/LOW for our 2D platformer), description, repro/citation, workaround if any, related issues; (3) "watch list" of issues currently open that are worth re-scanning periodically.
>
> Reporting back to the orchestrator: under 150 words.

### Topic B — GDScript language

**Output file**: `research/crawl/topic-gdscript-language.md`

**Brief (verbatim):**

> Find what's new since Jan 2026 about GDScript language traps, gotchas, and proposals: the `:=` type-inference system, await / coroutine semantics, lambda capture rules, signal connection patterns, weakref usage, Variant interactions, performance considerations. Source: `research/crawl/sourcemap.md`. Especially scan `godotengine/godot-proposals` for accepted/closed/active proposals dated 2026.
>
> Already known; do NOT re-discover: explicit types over `:=` for Variant returns, `String()` wrap before mixed-type ternaries, 1-element Array for lambda accumulators, no top-level `await` in MCP-injected scripts. References in `feedback_gdscript_practices.md` (memory file).
>
> Output a single markdown file ≤200 lines with: (1) TL;DR of top 3 findings; (2) per-trap entries with title, what compiles vs runtime, fix/workaround, citation; (3) summary of accepted/in-progress GDScript-language proposals worth tracking.
>
> Reporting back: under 150 words.

### Topic C — Tooling ecosystem

**Output file**: `research/crawl/topic-tooling.md`

**Brief (verbatim):**

> Find what's new since Jan 2026 in Godot tooling: GUT (current version, recent improvements), GdUnit4 (state and momentum vs GUT), other test frameworks emerging in 2026, MCP integrations beyond godot-mcp-pro, AI / LLM helpers for Godot, profilers, build tooling, deployment automation. Source: `research/crawl/sourcemap.md`.
>
> Already known; do NOT re-discover: godot-mcp-pro internals, godogen capabilities, the four MCP alternatives covered in `research/tools/mcp-alternatives.md`. The local-fork patch at github.com/youichi-uda/godot-mcp-pro/pull/25 is in flight.
>
> Output a single markdown file ≤200 lines with: (1) TL;DR of top 3 findings; (2) per-tool entries with name, role, current version + last release date, "should we look into it?" verdict for our project, citation; (3) noteworthy newcomers (first release in 2026).
>
> Reporting back: under 150 words.

### Topic D — 2D platformer patterns

**Output file**: `research/crawl/topic-2d-platformer.md`

**Brief (verbatim):**

> Find what's new since Jan 2026 in current best-practice for 2D platformer-specific patterns in Godot 4.6: camera systems (Camera2D, room locking, screen shake), TileMapLayer (replaced TileMap in 4.3), collision/hitbox layering (Area2D vs CharacterBody2D), animation state machines (AnimationTree state machine vs script-driven), room transitions, save/load. Source: `research/crawl/sourcemap.md`.
>
> Project context: Metroidvania-style, room-based with door transitions, CharacterBody2D player, custom GameCamera with room locking, AnimationPlayer-based rig (NOT AnimationTree), TileMapLayer rooms.
>
> Already known and shipped; do NOT re-discover: the project's room/camera architecture (see STRUCTURE.md), HUD/health system (plans/done/hud-health.md), audio foundations (plans/done/audio-foundations.md), skill cards (plans/done/skill-cards.md).
>
> Output a single markdown file ≤200 lines with: (1) TL;DR of top 3 findings; (2) per-pattern entries with title, the new approach or refinement, citation, applicability to our project (HIGH/MED/LOW); (3) any pitfalls reported in 2026 that we might already be hitting.
>
> Reporting back: under 150 words.

### Topic E — Performance & deployment

**Output file**: `research/crawl/topic-performance.md`

**Brief (verbatim):**

> Find what's new since Jan 2026 about Godot 4.6 performance and deployment: frame budget, GDScript execution speed, refcount/leak patterns, export presets (especially macOS, Windows, web), mobile/web caveats, profiler updates, GPU compatibility issues. Source: `research/crawl/sourcemap.md`.
>
> Project context: macOS-only desktop development (Apple Silicon), 960×540 viewport, Godot 4.6.2 GL Compatibility renderer. No mobile target yet but worth knowing.
>
> Output a single markdown file ≤200 lines with: (1) TL;DR of top 3 findings; (2) per-finding entries with title, impact, recommended action, citation; (3) any 4.6-specific performance regressions reported.
>
> Reporting back: under 150 words.

---

## Phase 2 — Synthesis (single agent, ~30 min, foreground after all 5 finish)

**Dispatch as**: `subagent_type: general-purpose`

**Output file**: `research/tools/godot-4.6-current-intel.md` (the canonical deliverable per backlog #12)

**Brief (verbatim):**

> Synthesize five topic-research outputs into a single canonical deliverable for the user. Inputs:
>
> - `research/crawl/sourcemap.md`
> - `research/crawl/topic-engine-quirks.md`
> - `research/crawl/topic-gdscript-language.md`
> - `research/crawl/topic-tooling.md`
> - `research/crawl/topic-2d-platformer.md`
> - `research/crawl/topic-performance.md`
>
> Read all six. Produce one markdown file at `research/tools/godot-4.6-current-intel.md`, ≤500 lines, with these sections in order:
>
> 1. **TL;DR** — exactly 5 bullets, one most-important finding from each topic. Each bullet ≤30 words.
> 2. **Active sources, ranked** — pulled from the sourcemap, with any S/N updates the topic agents noted. HIGH / MED / LOW tiers.
> 3. **Contributors to follow** — name/handle, domain, primary link, why useful, one example contribution. Aim for 8–15.
> 4. **Findings** — five subsections, one per topic. Within each, deduped (cross-topic duplicates fold into the most relevant subsection only) and ranked by relevance to our 2D platformer project. Cite every claim.
> 5. **Open / unresolved issues we may hit** — table with columns: issue, status, last-seen-date, what triggers a re-scan. Pull from the topic agents' watch lists.
> 6. **Recurring scan recommendation** — frequency (weekly / monthly / quarterly), which sources, what to watch for, who to ping if blocked. The user wants a self-recommendation here for how often to refresh this intel.
> 7. **Surprises** — anything the pre-scan or topic agents flagged as a major scope-changer (Godot 4.7 release, regression announcement, etc). If nothing surprising, state "none."
> 8. **Glossary** — projects/terms encountered for the first time, with one-line definitions.
>
> Tone: terse, factual, source-cited. No hedging. If a finding is provisional, say "provisional" and explain why; otherwise state it as fact.
>
> When finished, post under 200 words: file path, top 3 highest-relevance findings (one sentence each), top 3 contributors to follow, recommended re-scan frequency.

---

## Final cleanup (after synthesis lands)

The orchestrating session should:

1. Read the synthesis output and verify it covers the eight required sections.
2. Update `feedback_gdscript_practices.md` and `feedback_godot_mcp_scene_editing.md` memory files with any of the synthesis's strongest claims that fit (per the rule "fold its strongest claims into this file" already in the GDScript memory).
3. Commit + push the entire `research/crawl/` directory + the canonical deliverable.
4. Mark backlog item #12 as **complete (date)** with a one-line note pointing at the deliverable.
5. Report final summary to the user: where the deliverable is, how long the crawl took, the recommended re-scan frequency.

## Estimated total time

~2 hours wall clock. ~30 min pre-scan + ~45 min topic-agents-in-parallel + ~30 min synthesis + ~15 min cleanup. User can sleep through it.

## On rerun

Re-running this crawl in N months: just delete `research/crawl/*.md` (keep this PLAN.md) and re-execute. The plan is intentionally calendar-agnostic — the agents will fetch what's new since *that* run, not since this one.
