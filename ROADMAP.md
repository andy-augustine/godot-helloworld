# Roadmap

The single entry point for "what's going on with this project?" — read this first if you're a fresh Claude session, a new collaborator, or returning after time away.

Updated 2026-04-27 (post-visually-distinct-rooms ship).

---

## Current state at a glance

| | |
|---|---|
| **Active plans** | none — pick from [`backlog/gamedev.md`](backlog/gamedev.md), [`backlog/tooling-pipeline.md`](backlog/tooling-pipeline.md), or [`backlog/claude-collab.md`](backlog/claude-collab.md) |
| **Most recent ship** | **Visually distinct rooms — "Hollow Threshold" theme.** All 3 rooms got palette divergence + procedural-background gradient + per-room signature mechanic. SecondRoom got a plasma fissure (tick damage that bypasses iframes — failing the dash drops you in, walking out kills you). ThirdRoom got an energy tendril swing (AnimatableBody2D pendulum platform with sync_to_physics) + coolant pool slow-zone (32% speed). StartingRoom got cyan strip-lights as the institutional sci-fi accent. New systems: `hazards/` (PlasmaFissure, CoolantPool, SwingTendril) and `shaders/` (gradient_bg). Plan archived at [`plans/done/visually-distinct-rooms.md`](plans/done/visually-distinct-rooms.md). Commits [`add0827`](https://github.com/andy-augustine/godot-helloworld/commit/add0827) → [`8a40f0d`](https://github.com/andy-augustine/godot-helloworld/commit/8a40f0d). |
| **Previous ship** | Information-architecture refactor — startup → standardized. Plan archived at [`plans/done/refactor-info-architecture.md`](plans/done/refactor-info-architecture.md). |
| **Recent research artifacts** | Overnight Godot 4.6 / GDScript community intel crawl → [`research/tools/godot-4.6-current-intel.md`](research/tools/godot-4.6-current-intel.md) (refreshed monthly via `/refresh-godot-intel`). Synthetic-drag findings filed upstream as a godot-mcp-pro issue draft. |
| **Backlog top picks** | Enemies (gamedev #9) is now the highest-leverage next major capability — combat without progression is hollow, but combat without environments is a movement showcase, and we now have environments. Pairs with HUD ability indicators (gamedev #8 sub-pieces). Tilemaps (gamedev #2) once we want more than 3 rooms. AI-driven art pipeline spike (tooling-pipeline #10b) is unlocked since we have a real game to drive godot-ai-builder against. |
| **Stage** | Solo lead + side-Claude sessions. Team of 6 collaborators planned for onboarding. |
| **Workflow mode** | Sequential — one Claude actively using MCP at a time. See "Lifecycle" below. |

---

## Where things live

Folder layout and per-file responsibilities live in [`STRUCTURE.md`](STRUCTURE.md) — single source of truth, kept current via the post-ship docs sweep in [`CLAUDE.md`](CLAUDE.md). No separate tree here so the two don't drift apart.

---

## Lifecycle: how an idea becomes shipped code

Four states. Each state has exactly one home. Don't skip a state, don't duplicate across homes.

| State | Home | Audience | Mutability |
|---|---|---|---|
| **1. Raw / WIP / writer's room** | `backlog/<area>.md` bullet | Solo lead + Claude | High — rename, merge, delete freely |
| **2. Crystallized for team** | GitHub Issue *(later — see "Phases" below)* | Whole team | Medium — labels evolve, comments thread |
| **3. Active execution** | `plans/<feature>.md` | One claimer at a time | Low — locked while in flight |
| **4. Shipped** | `plans/done/<feature>.md` + commits in main | Historical record | Frozen |

**End-of-session ritual:** before stopping, walk `backlog/`. Anything that survived a session still useful + is detailed enough that another person could pick it up → graduates to a GitHub Issue (when team is on board) or stays as a refined backlog entry (for now). Half-formed thoughts we've moved past → delete from backlog.

**Claim before you start:** before starting a `plans/<feature>.md`, push the plan with `**Status:** in progress (claimed by <you>, branch <name>, YYYY-MM-DD)`. That commit is your "I've got this" flag — solves the "two Claudes start the same item" risk.

**Archive on completion:** when a plan ships, move to `plans/done/` with `**Status:** complete (YYYY-MM-DD)` plus the implementation commit hashes. Per the rule in [`CLAUDE.md`](CLAUDE.md#plan-archiving).

---

## Workflow phases

### Phase A — solo (now)

Just one person (you) plus side-Claude sessions on the same machine.

- **Commit directly to main.** No PRs, no feature branches per task. Branches only for genuinely risky changes.
- **No GitHub Issues yet.** Backlog lives in `backlog/*.md` files.
- **No project board yet.** This `ROADMAP.md` *is* the board.
- **One Claude with MCP at a time.** This is a **solo-dev-with-multiple-Claudes** problem only. The bottleneck is per-Godot-editor: one editor running, one MCP connection, two Claudes can't safely issue MCP commands simultaneously. **Multi-dev teams don't hit this** — each teammate runs their own Godot + MCP on their own laptop. Side-Claude sessions on the same machine can still run in parallel as long as only one is MCP-touching at a time (the others stick to script-only edits). See `plans/done/audio-foundations.md` for an example of clean sequential execution.

### Phase B — team onboarded (later, ~when 6 collaborators arrive)

When collaborators come online — same code, same `ROADMAP.md`, but layered process. Estimated ~one day of setup work the day before they arrive.

- **Branch protection on main** — all changes via PRs.
- **Backlog migrates to GitHub Issues** — gradual, item-by-item as they're picked up. Labels: `bug`, `enhancement`, `gamedev`, `tooling`, `research`, `discussion`.
- **Single GitHub Project board** — columns: `Backlog → In Progress → In Review → Done`. Auto-rules move cards on PR open/merge.
- **PR template** — short form (What does this do? Closes #X. Tested how?).
- **Branch naming** — `feature/<issue#>-<slug>` so branch ↔ issue is grep-able.
- **Update CLAUDE.md** with team-mode workflow notes.

A `WORKFLOW.md` will be drafted closer to the team-onboarding day; not premature today. Full setup checklist for that day is captured in [`backlog/tooling-pipeline.md` item #11](backlog/tooling-pipeline.md) — branch protection, labels, templates, board config, branch naming, CLAUDE.md updates, etc. — so the work is materialized and won't be re-derived under pressure.

---

## Recommended reading order for a fresh Claude

1. **This file** — orient
2. **CLAUDE.md** — project rules
3. **STRUCTURE.md** — code architecture
4. **tests/README.md** — only if planning to drive the running game via MCP
5. **GODOT_PRIMER.md** — only when GDScript / Godot construct uncertainty arises
6. **plans/** — current in-flight work; if any
7. **backlog/** — only when picking new work
8. **research/** — only when evaluating something new

Skip anything not relevant to the immediate task.

---

## Recommended reading order for a fresh human

1. **README.md** — what this project is
2. **SETUP.md** — install everything
3. **This file** — orient on what's going on
4. **STRUCTURE.md** — get the lay of the land
5. **GODOT_PRIMER.md** — if coming from Unreal/Unity background
6. Pick a backlog item or open plan and start

---

## Open questions / decisions pending

- **GitHub Issues + Project board setup** — deferred until ~1 day before team onboarding. Tracked here, not as a backlog item.
- **Forked-context skills (`context: fork` frontmatter)** — `tooling-pipeline.md` item #5 — needs a hands-on test to validate Claude Code honors it natively.
- **godot-api skill activation** — built and parked. Re-enable when GDScript hallucinations or API uncertainty become a real signal. See [`.claude/skills/godot-api/README.md`](.claude/skills/godot-api/README.md).
