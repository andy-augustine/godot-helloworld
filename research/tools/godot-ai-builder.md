# godot-ai-builder — research notes

| | |
|---|---|
| Repo | https://github.com/HubDev-AI/godot-ai-builder |
| License | MIT |
| Status | **Likely abandoned** — last push 2026-02-18, 5 stars, ~2 months stale |
| Researched | 2026-04-25 |

## Verdict

**Mine specific skills; do not adopt the runtime.** GDScript-aligned (no .NET requirement) and the polish/distiller/director skills are directly useful, but the runtime (HTTP-bridge MCP plugin, 28 tools) is a strict subset of godot-mcp-pro (~170 tools) so there's no reason to swap. Lift the Markdown skills, ignore the plugin.

## Hard constraints

None for our purposes — the project enforces GDScript-only as a hard rule:

> *"YOU ARE A GODOT 4 GAME BUILDER. THE ONLY CODE YOU WRITE IS GDSCRIPT. THE ONLY FILES YOU CREATE ARE .gd, .tscn, .tres, .cfg, .svg, .godot FILES."* (`skills/godot-builder/SKILL.md`, `skills/godot-director/SKILL.md`)

## What's actually in there

### Architecture

Router (`godot-builder`) → Director (`godot-director`) → 14 specialist skills. Director runs a **6-phase build protocol** with quality gates: PRD → Foundation → Abilities → Enemies → UI → Polish → QA. A `Stop` hook (`hooks/stop-guard.sh`) prevents the agent from bailing mid-build by blocking the `Stop` event until `.claude/.build_in_progress` is cleared.

### Skill catalog (14)

| Skill | Role |
|---|---|
| `godot-builder` | Router, top-level entry |
| `godot-director` | 6-phase build protocol, quality gates |
| `godot-polish` | **Action → visual feedback → audio → camera shake table** (juice/feel) |
| `godot-init` | Project bootstrap |
| `godot-gdscript` | Syntax patterns and idioms |
| `godot-scene-arch` | Programmatic vs `.tscn` decision rules |
| `godot-player` | Character controllers |
| `godot-enemies` | AI / spawning patterns |
| `godot-physics` | Collision layer conventions |
| `godot-ui` | HUD / menus |
| `godot-effects` | Particles / tweens |
| `godot-assets` | Procedural visual quality tiers (no flat shapes rule) |
| `godot-ops` | MCP run/stop/errors loop, dock progress logging |
| `godot-templates` | Genre templates |
| `godot-distiller` | **Multi-doc GDD → one-session scope (12-15 scripts)** |
| `godot-dev` | Modifying the builder itself |

### MCP plugin

Their `mcp-server/src/tools.js` exposes ~28 MCP tools including `godot_evaluate_quality_gates` and `godot_score_poc_quality` (objective phase-gate scoring with rubric reports). godot-mcp-pro is a strict superset on count; the **scoring tools are conceptually unique** but I did not read the implementation — could be substantive or 50 lines of placeholder.

### Hooks

`hooks/stop-guard.sh` + `hooks.json`: claude-code stop-event hook that touches `.claude/.build_in_progress` at start, blocks `Stop` until phases complete. Self-contained shell script, ~portable.

### Build resumption

`.claude/build_state.json` written on each phase boundary. On restart, the agent reads it and offers to continue. Implemented via `godot_save_build_state` MCP tool but the *concept* (a JSON checkpoint file the agent reads itself) doesn't require their MCP.

## What's worth lifting (concept-by-concept)

| Concept | Translatable? | Effort | Value |
|---|---|---|---|
| `godot-polish` juice/feedback table | **Yes — verbatim**, plus Metroid-specific rows | 1 hr | **High** |
| `godot-distiller` (multi-doc GDD → scope) | **Yes** — useful for card/rogue-like backlog when GDDs come in | 2 hr | Medium-high |
| `stop-guard.sh` hook | **Yes** — for major capability builds, not for tweaks | 30 min | Medium |
| `.claude/build_state.json` checkpoint convention | **Yes** — agent-written, no MCP needed | 1 hr (when first long build needs it) | Medium |
| 6-phase Director protocol | **Partial** — phases are too linear for our project; the *concept* of named phase gates is useful | 30 min note in CLAUDE.md | Low-medium |
| Procedural visual quality tiers (`godot-assets`) | **Yes** — body+outline+shadow+highlight+animation rule | 1 hr | Medium |
| Hard-rule guardrails ("NO HTML/JS/Unity" on every skill) | **No** — we don't have stack confusion | — | — |
| HTTP-bridge MCP plugin | **No** — godot-mcp-pro is a strict superset | — | — |
| Router skill (`godot-builder`) | **No** — single project, no need to route | — | — |

## Caveats / what wasn't verified

- I read `SKILL.md` files; did not deeply inspect `mcp-server/src/tools.js` source for tool quality.
- `godot_evaluate_quality_gates` and `godot_score_poc_quality` look like genuinely interesting additions (scoring builds against a rubric) but I did not verify they do anything meaningful at runtime.
- 5 stars + 2 months stale suggests this won't get upstream improvements. Concept extraction now is fine; long-term reliance is not.
