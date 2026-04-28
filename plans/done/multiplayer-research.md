# Plan: Multiplayer-for-Godot research crawl

**Status:** complete (2026-04-28). Delivered `research/multiplayer/survey.md` plus 5 topic files + sourcemap. Recommended path: GodotSteam + Steam Networking Sockets transport, netfox for client-side prediction, defer dedicated-server until PvP is on the table. Implementation commit: [`65c4768`](https://github.com/andy-augustine/godot-helloworld/commit/65c4768).

**Owner:** Whichever fresh Claude session picks this up next. Should be Opus 4.7 in the orchestrating role — see model selection in the runbook.

**Goal:** Produce a decision-grade survey of options for adding multiplayer to this 2D Metroidvania, covering Godot's built-in multiplayer stack, architectural patterns, cloud / managed services, shipped-game case studies, and key contributors / sample repos. Deliverable lands at `research/multiplayer/survey.md`.

## How to pick this up

1. Read `research/multiplayer/PLAN.md` — that's the full self-contained runbook. It mirrors the structure of `research/crawl/PLAN.md` (the 2026-04-26 Godot-intel crawl that already ran successfully).
2. Confirm the user-decisions checklist at the top of the runbook still matches the user's intent. If the user updated the file, follow what's there. Otherwise the pre-authorized defaults stand:
   - Co-op weighted ~70/30 over PvP
   - 2-8 player target
   - Exploratory survey (not active implementation)
   - Cover the cost spectrum (free → managed)
   - No hosting preference assumed
3. Execute the three phases in `PLAN.md`:
   - Phase 0: pre-scan agent (sonnet, foreground, ~30 min) → `research/multiplayer/sourcemap.md`
   - Phase 1: 5 parallel topic agents (sonnet, background, ~45 min each) → 5 topic files
   - Phase 2: synthesis agent (opus, foreground, ~45 min) → `research/multiplayer/survey.md`
4. Final cleanup per the runbook: commit + push, archive this plan to `plans/done/`, update ROADMAP, report summary.

## Why this is a separate plan and not just a research crawl

Because the user explicitly requested it as a "research project" and asked that we drop it into its own folder — `research/multiplayer/`. The pattern is the same as the previous Godot intel crawl, but the topic is broad enough that the deliverable is decision-grade (architecture + service comparison) rather than reference-grade (engine quirks list).

## Estimated time

~2.5 hours wall clock total. User can sleep through it.

## Output paths

- Runbook: `research/multiplayer/PLAN.md`
- Pre-scan: `research/multiplayer/sourcemap.md`
- Phase 1 topics: `research/multiplayer/topic-{godot-builtin,architecture,cloud-services,2d-coop-patterns,kols-tooling}.md`
- Canonical deliverable: `research/multiplayer/survey.md`

## Cross-references

- The previous-research pattern: `research/crawl/PLAN.md` (executed 2026-04-26, deliverable at `research/tools/godot-4.6-current-intel.md`).
- Project context for the agents: `STRUCTURE.md`, `ROADMAP.md`.
