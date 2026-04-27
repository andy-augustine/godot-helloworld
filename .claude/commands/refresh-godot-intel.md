---
description: Re-run the Godot 4.x / GDScript community intel crawl. Delete prior crawl scratch, dispatch the runbook at research/crawl/PLAN.md, produce a fresh deliverable.
---

Refresh the Godot / GDScript community intel by re-running the crawl described at [`research/crawl/PLAN.md`](research/crawl/PLAN.md). The plan is self-contained — read it in full before doing anything.

## What this command does

1. Confirm with the user that they want to refresh the intel now (the run is ~2 hours wall clock and dispatches multiple background agents — non-trivial cost).
2. Preserve the previous deliverable as a historical snapshot:
   ```
   git mv research/tools/godot-4.6-current-intel.md research/tools/godot-current-intel-archive-YYYY-MM-DD.md
   ```
   (Use today's date. Skip if no previous deliverable exists.)
3. Delete the previous crawl scratch so agents write fresh:
   ```
   rm -f research/crawl/sourcemap.md research/crawl/topic-*.md
   ```
   Keep `PLAN.md`.
4. Commit the cleanup ("Refresh Godot intel: archive previous deliverable, clear scratch").
5. Execute `research/crawl/PLAN.md` exactly as written — Phase 0 → Phase 1 (parallel) → Phase 2 → cleanup. The plan has pre-authorized decisions baked in (5 parallel agents OK, auto-proceed on surprise, output path fixed). No mid-run user prompts needed.
6. After synthesis lands, update memory files (`feedback_gdscript_practices.md`, `feedback_godot_mcp_scene_editing.md`) per the plan's "Final cleanup" step.
7. Mark the appropriate backlog item (currently #12 in `backlog/tooling-pipeline.md`) as **complete (date)** if it's still listed.
8. Commit + push.
9. Report a summary: deliverable path, how long the crawl took, top findings, recommended next re-scan date based on the synthesis's own recommendation.

## When to use this

- A few months have passed and we suspect the Godot ecosystem has moved (4.7 release, GUT major version bump, anything similar).
- About to start a new major capability and want fresh intel before designing it.
- The synthesis output's "recurring scan recommendation" says it's time.

## When NOT to use this

- The current deliverable is less than ~30 days old — recent enough to trust.
- We're mid-build on a plan that's already in progress — finish that first.
- The user is asking a specific question that's faster to answer with a single targeted query than a full crawl.

## Note on the runbook

The plan at `research/crawl/PLAN.md` is calendar-agnostic. Each run fetches "what's new since the last run" automatically — no plan edits needed. If the plan itself needs updating (because tools/sources have shifted enough that the briefs are stale), edit `PLAN.md` first, then run.
