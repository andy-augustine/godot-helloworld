# Plan: information-architecture refactor — startup → standardized

**Status:** in progress (claimed by Andy + Claude, branch `main`, 2026-04-27)

This plan refactors the project's *metadata* (docs, folders, conventions) — NOT the code. The goal is to move from the "grinding through startup + learning" phase, where useful artifacts accumulated wherever was convenient, into a "we know what we're doing" baseline that's:

- Free of duplications that drift out of sync
- Slim enough that a fresh Claude session or new GitHub contributor can orient quickly
- Set up for clean `/orient` and `/wrapup` session bookends
- Portable in shape (so the artifacts can extract into a starter kit later with mostly file moves, not re-authoring)

---

## Steelman of what we have today

### Working well
- **Memory rules transfer reliably across sessions.** Verified this session — rules 1-18 in `feedback_gdscript_practices.md` caught the in-callback-monitoring bug and prevented lambda-signal-multiplication.
- **Plan archive with commit hashes** = trivial reconstruction of "what shipped when."
- **Topic-split memory** is more navigable than a single lessons.md would be (user-confirmed).
- **`/orient` + `/refresh-godot-intel` + monthly remote agent** form a clean *entry* into a session.
- **Post-ship docs sweep rule** (added this session) genuinely keeps ROADMAP from drifting.
- **Research crawl outputs (`research/tools/godot-4.6-current-intel.md`)** are durable, source-cited, and refreshable.

### Drift / duplication / scope creep
1. **TESTING.md is bloated.** Originally it documented an MCP frame-timing issue. Most of that content is now in `tests/RESULTS.md` (the working drag recipe), `research/tools/` (the analysis), and the memory rules (the reflexive habits). TESTING.md was 135 lines; should be a short pointer.
2. **ROADMAP.md "Where things live" duplicates STRUCTURE.md folder map.** Two folder trees that need to be kept in sync. The post-ship sweep rule has to update both. Pure overhead.
3. **GODOT_NOTES.md scope-crept beyond its original "Godot for Unreal/Unity devs" purpose.** It picked up "Common gotchas" (duplicates memory + research) and "Where this maps in the codebase" (duplicates STRUCTURE). Should be pruned back to its original audience: my son Cole, who knows Unreal/Unity but not Godot.
4. **`early-requirements/` is obsolete.** It was a retrospective experiment in capturing "what would a perfect prompt look like." The output was too pseudocode-heavy and not the kind of thing a creative game dev would actually feed in. The user is unhappy with it, it's not load-bearing for any current workflow, and it's referenced from README.md as "see this for prompt examples" which is misleading.
5. **No `/wrapup` slash command.** Session ends are ad-hoc. Lessons learned, doc drift, backlog graduation, and memory rule additions all currently happen if-I-remember rather than as a pipeline step.
6. **No third backlog category for meta-collab process.** Items like `/orient`, the intel crawl runbook, the `/wrapup` command itself currently sit in `backlog/tooling-pipeline.md` mixed with game-helping skills (visual-qa, polish-checklist). Different audiences.
7. **`research/godot-mcp-pro-issue-draft.md`** lives at `research/` root rather than `research/tools/` like all other research. Inconsistent.

### NOT changing
- **Memory file structure** (topic-split). User explicitly preferred topic-split over a single consolidated file.
- **Code architecture or folder layout.** This refactor is metadata-only.
- **`backlog/gamedev.md` and `backlog/tooling-pipeline.md` content.** They stay as the project-feature and game-tooling backlogs respectively.
- **Plan archiving discipline.** Already working.
- **`research/` structure** beyond moving the one stray file.

---

## Target architecture

### Root project docs (5 instead of 7)

| File | Purpose | Audience | Cadence |
|---|---|---|---|
| `README.md` | Project front door + doc TOC | Anyone landing on the repo | Stable |
| `ROADMAP.md` | "What's going on right now?" — active plans, recent ship, backlog top picks, open questions | Returning contributor / fresh Claude | Updated each ship |
| `STRUCTURE.md` | Folder layout + runtime architecture + data flow. **The** canonical folder tree. | Someone directing changes | Updated on new top-level dirs |
| `CLAUDE.md` | Rules every Claude session follows. References `/orient` and `/wrapup` as session bookends. | Every Claude session | Stable, evolves slowly |
| `SETUP.md` | Install steps for macOS and Windows | New human contributor | Stable |

### Removed / merged
- **`TESTING.md`** — content extracted into `tests/README.md` (developer-facing test guide, lives next to test code). Project root no longer has TESTING.md.
- **`GODOT_NOTES.md`** — kept, but pruned back to "Godot for Unreal/Unity devs" original scope. Removes "Common gotchas" (duplicates memory + research) and "Where this maps in the codebase" (duplicates STRUCTURE). Adds a one-line subtitle clarifying the audience.

### Folders changed
- **`early-requirements/`** — deleted. Replaced with a brief `plans/done/v1-animated-platformer.md` description-only entry (≤10 lines, links to the original commit `3fcc600`).
- **`backlog/`** — gains `claude-collab.md`.
- **`.claude/commands/`** — gains `wrapup.md`.
- **`research/godot-mcp-pro-issue-draft.md`** — moved to `research/tools/` for consistency.

### New stuff
- **`backlog/claude-collab.md`** — meta-collab backlog. Seed entries:
  - Build `/wrapup` slash command (item #1; closes itself when this plan ships)
  - Periodic "session retrospective" remote agent (monthly scan for missed memory updates)
  - "Skills earned" inventory file — positive-affordances (what *works* in this codebase) rather than rules
  - Pre-flight check command (`/preflight`) before risky ops
  - Bug-pattern memory consolidation pass (when the feedback files reach a critical mass)
- **`.claude/commands/wrapup.md`** — interactive 8-step wrapup. Surfaces candidates, waits for user confirmation per item, no auto-commits. Memory rule additions require evidence (commit hash, repro, test) per user constraint #2.
- **`tests/README.md`** — developer-facing "how we test" guide. Absorbs the durable patterns from TESTING.md.

### Decisions / non-decisions
- **`/wrapup` is interactive, not silent.** Surfaces candidates for backlog graduation and memory-rule additions; user confirms each. Per user constraint: "low touch during sessions, but okay with answering a few prompts at the end of a long session."
- **Memory rule bar is HIGH for /wrapup additions.** Per user constraint: must be reproducible, root-caused, tested. /wrapup attaches evidence (commit hash, repro link, test result) when proposing.
- **Memory file structure stays topic-split.** No consolidation pass in this plan.
- **`/wrapup` does NOT auto-commit.** It surfaces and waits. Easier to review the diff before it lands.

---

## Phases

### P0 — Plan committed (this file)
Already done by virtue of writing this. Commit and proceed.

### P1 — Delete `early-requirements/` + create description-only plans/done entry (~30 min)
- Create `plans/done/v1-animated-platformer.md` — short description (1-2 paragraphs) of what was built in the v1 phase, link to commit `3fcc600`, no pseudocode.
- Delete `early-requirements/README.md` and `early-requirements/v1-animated-platformer.md`.
- Remove `early-requirements/` directory.
- Update `README.md`: remove the early-requirements row from the doc table and the "see early-requirements/v1-animated-platformer.md" reference in the workflow section.
- Update `ROADMAP.md` if it references early-requirements anywhere.
- **Commit:** `Refactor: delete early-requirements, replace with plans/done description`

### P2 — Slim TESTING.md → tests/README.md (~30 min)
- Create `tests/README.md` with the durable content from TESTING.md:
  - Brief "MCP is async" explainer (root cause)
  - The four patterns with concise summaries
  - Pointer to memory rules for the reflexive habits
  - Pointer to `tests/RESULTS.md` for the working drag recipe + run instructions
- Delete root `TESTING.md`.
- Update `README.md` doc table: remove TESTING.md row, add "tests/" pointer.
- Update `CLAUDE.md` "Testing & QA" section to point at `tests/README.md`.
- Update any other doc that references TESTING.md (likely ROADMAP, possibly memory).
- **Commit:** `Refactor: TESTING.md -> tests/README.md, remove root duplication`

### P3 — Prune GODOT_NOTES.md back to original scope (~20 min)
- Remove "## Common gotchas (things that look wrong but aren't)" section.
- Remove "## Where this maps in the codebase" section.
- Add a one-line subtitle clarifying the audience: "For developers coming from Unreal or Unity. The Rosetta-stone Godot constructs that appear in this project."
- Title might shift to something more explicit (`GODOT_FOR_UNREAL_UNITY.md`?) — TBD per file rename risk; default to keeping `GODOT_NOTES.md` to avoid breaking links.
- **Commit:** `Refactor: prune GODOT_NOTES.md to original Unreal/Unity-dev scope`

### P4 — Remove ROADMAP/STRUCTURE folder-tree duplication (~15 min)
- Delete the "## Where things live" section in `ROADMAP.md`.
- Replace with a one-line link: "Folder layout: see [STRUCTURE.md](STRUCTURE.md)."
- Update CLAUDE.md "Post-ship docs sweep" rule: only STRUCTURE.md needs the folder-tree update, ROADMAP doesn't anymore. Drop one bullet from the checklist.
- **Commit:** `Refactor: ROADMAP folder tree -> STRUCTURE pointer (single source)`

### P5 — Move misplaced research file (~5 min)
- `git mv research/godot-mcp-pro-issue-draft.md research/tools/godot-mcp-pro-issue-draft.md`
- Update `research/README.md` table to include the moved file.
- Grep for references to the old path; fix them.
- **Commit:** `Refactor: move stray research file into research/tools/`

### P6 — Add `backlog/claude-collab.md` with seed entries (~30 min)
- Create the file with the seed entries enumerated above.
- Update `backlog/README.md` to include `claude-collab.md` in the table and the "why split them" rationale.
- **Commit:** `Add backlog/claude-collab.md (third category: meta-collab process)`

### P7 — Add `/wrapup` slash command (~45 min)
- `.claude/commands/wrapup.md` implementing the 8-step process:
  1. State-of-tree check (git status clean, all pushed)
  2. Playtest stopped (reflexive `stop_scene`)
  3. Plan reconciliation (any plans/ ready to archive? run post-ship sweep)
  4. Backlog graduation (surface candidates from session, user confirms each)
  5. Lessons-learned retrospective (surface candidates with evidence, user confirms each)
  6. Doc drift sweep (quick scan of ROADMAP/STRUCTURE/GODOT_NOTES/tests/README for stale claims)
  7. Background tasks verify (RemoteTrigger list, confirm monthly intel still scheduled)
  8. Final summary (what shipped, what's queued, recommended `/orient` for next session)
- Memory rule additions require evidence; commit hash + repro + test result attached.
- No auto-commits — surface and wait for go/skip per item.
- **Commit:** `Add /wrapup slash command — interactive end-of-session pipeline`

### P8 — Update CLAUDE.md to reference the new flow (~15 min)
- Mention `/wrapup` in the "Starting a session" or new "Ending a session" section.
- Update Plan archiving / Post-ship docs sweep checklist if anything shifted (P4 already drops one bullet).
- Update the "Testing & QA" section pointer to `tests/README.md`.
- **Commit:** `CLAUDE.md: reference /orient + /wrapup as session bookends`

### P9 — Self-test: run `/wrapup` to close out THIS refactor (~15 min)
- Eat our own dog food. The wrapup should:
  - Find this plan ready to archive
  - Find the new docs that need linking from README
  - Find any lingering uncommitted state
  - Propose memory rule additions if applicable (probably none — this was metadata work)
- Move `plans/refactor-info-architecture.md` to `plans/done/` with status line + commit hashes.
- **Commit:** `Refactor: post-ship sweep + plan archive`

---

## Acceptance criteria (the "we know what we're doing" baseline)

After this refactor:

1. A fresh Claude session running `/orient` reads exactly **5 root docs** (README, ROADMAP, STRUCTURE, CLAUDE, SETUP). No TESTING.md, no GODOT_NOTES at the root mental model. Cole-targeted GODOT_NOTES is still discoverable but not in the orient path.
2. The folder tree exists in **exactly one place** (STRUCTURE.md). Updating it is one file, not two.
3. The conversation has a clean **end** beat (`/wrapup`) that mirrors the start beat (`/orient`).
4. Memory rule additions go through a **vetted gate** — no fluke-driven additions that misclassify playtest-timing artifacts as code/MCP bugs.
5. The third backlog category (`claude-collab.md`) exists, is documented in `backlog/README.md`, and has a seeded list of "next things we might want to build."
6. `early-requirements/` is gone; the doc table in README is shorter; the v1 spec is preserved as a brief description in `plans/done/`.
7. Stray research file is in the consistent location.

---

## Estimated total

P1 30m + P2 30m + P3 20m + P4 15m + P5 5m + P6 30m + P7 45m + P8 15m + P9 15m ≈ **3.5 hours** of focused metadata work, plus MCP iteration overhead. Realistically a single sustained session.

---

## Explicitly NOT in scope this round

- Code refactor of any kind.
- Touching the existing `backlog/gamedev.md` or `backlog/tooling-pipeline.md` content (only adding `claude-collab.md` alongside).
- Building the `/preflight` command, the "skills earned" file, or the periodic retrospective agent — those become entries in the new `claude-collab.md` backlog.
- Memory file consolidation. Topic-split stays.
- Renaming any code files / autoloads / scripts.
- Migrating CLAUDE.md content into other docs. CLAUDE.md stays the rules file.
