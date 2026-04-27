---
description: End-of-session pipeline — verify clean tree, archive shipped plans, surface backlog candidates and memory-rule additions, doc-drift sweep. Interactive (low touch) — surfaces, you confirm.
---

End-of-session wrapup. Walks the post-ship checklist and a few extra session-end checks. **Interactive but low-touch** — surfaces candidates with rationale, asks you to confirm or skip per item. Never auto-commits.

Run this when you're about to close the session, after the active feature work has shipped or paused.

## The eight steps

Walk these in order. For each step, do the work, then SHOW me the findings (concise) and wait if confirmation is needed before proceeding.

### 1. State-of-tree check

- `git status` — should be clean. Flag any untracked or modified files (especially anything under `screenshots/`, `_audio_workshop/`, or scratch dirs that aren't gitignored).
- `git log origin/main..HEAD` — should be empty (everything pushed).
- If either is non-empty, STOP and surface the exact files / commits before proceeding. Don't silently auto-fix.

### 2. Playtest stopped

Reflexive paranoid check — even if you think no playtest is running, call `mcp__godot-mcp-pro__stop_scene` once. The play window covers the user's screen and they can't tell from the window alone whether you're done. Per memory rule 7 in `feedback_godot_mcp_scene_editing.md`.

### 3. Plan reconciliation

Read `plans/` (the active directory):
- For each file: is the underlying work fully shipped this session?
  - Yes → run the **post-ship docs sweep** (CLAUDE.md "Post-ship docs sweep" section). Update ROADMAP "Most recent ship" + "Updated YYYY-MM-DD", update STRUCTURE.md if any new top-level dirs, update backlog status lines. Move plan to `plans/done/<feature>.md` with status line + commit hashes.
  - Still in progress (touched this session, not done) → leave in `plans/`, update its in-progress status line if the description has drifted.
  - Stale (no commits this session, no recent activity) → SURFACE to user: "plan X has been in flight since DATE, no activity. Still active, or archive as paused?"

### 4. Backlog graduation

Walk the session conversation transcript. Identify items that came up as "we'll do X later" / "TODO add Y" / deferred decisions / observed-but-not-acted-on issues. For each:
- Propose adding it to the appropriate backlog (`gamedev.md`, `tooling-pipeline.md`, or `claude-collab.md`) with a one-paragraph entry.
- SURFACE each candidate to the user with: the one-liner, your proposed backlog file, and your rationale.
- Wait for **go / skip / move-to-different-backlog** per item. Don't batch-confirm — each gets a yes/no.

### 5. Lessons-learned retrospective

Same scan, looking specifically for **memory rule additions**. Surface candidates only if they meet the high bar:

- **Reproducible** — happened more than once, OR has a documented repro.
- **Root-caused** — we know why, not just symptomatic.
- **Tested** — the fix has been verified to work (linked commit / test).

For each candidate, surface: the proposed rule (including **Why:** and **How to apply:** lines per the memory format), the matching `feedback_*.md` file, and the **evidence** (commit hash + repro link + test result). Wait for **confirm / skip / refine** per rule.

**Critically: do NOT propose memory rules for one-off issues that might have been playtest frame-timing artifacts misclassified as code/Godot/MCP bugs.** When in doubt, skip — the cost of a bad memory rule is losing capability.

### 6. Doc drift sweep

Scan these docs for stale claims relative to what shipped this session:

- `ROADMAP.md` — does the "Most recent ship" row match reality? Is "Active plans" correct? Are "Backlog top picks" still right after this session's changes? Are any "Open questions" now resolved?
- `STRUCTURE.md` — folder map current? Per-file responsibilities still accurate for any scripts touched?
- `tests/README.md` — any new test patterns this session that should be documented?
- `GODOT_PRIMER.md` — only check if a Godot/GDScript construct used this session was novel (rare). Don't add gotchas; those go in memory.
- `CLAUDE.md` — any new convention emerged this session that should be a rule?

Surface each drift candidate with the proposed one-line fix. Wait for **confirm / skip** per item.

### 7. Background tasks verify

- `mcp__scheduled-tasks__list_scheduled_tasks` and `RemoteTrigger list` — confirm the monthly Godot intel refresh is still scheduled.
- Check `mcp__ccd_session__spawn_task` history if any tasks were spawned this session — confirm they completed.
- Surface anything unexpected (failed tasks, missing schedules).

### 8. Final summary

Write a short summary message for the user with:
- **Shipped this session** — bullet list of features / fixes that landed (with commit hashes for the major ones).
- **Plans archived** — anything moved to `plans/done/`.
- **Backlog additions** — what got added to which file.
- **Memory rule additions** — what got encoded.
- **Open / queued** — what's next, recommended `/orient` entry point for the next session.

After the summary, this turn ends. Don't start new work; the session is wrapping.

## Hard rules

- **No auto-commits.** Every commit is a separate explicit op the user can review. If multiple steps produce changes, batch them into logically-named commits per area (e.g. one for the docs sweep, one for the backlog additions).
- **Memory rules require evidence.** Never propose a rule without commit hash + repro + test result attached.
- **Surface, don't act, on judgment calls.** Steps 4, 5, 6 surface candidates; the user confirms each. Steps 1, 2, 3, 7, 8 are mechanical and run without confirmation needed.
- **Low touch.** If nothing comes up in steps 4-6, skip them silently and proceed to 7-8. Don't manufacture findings to be busy.
