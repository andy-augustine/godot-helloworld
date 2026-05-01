# Godot Tooling — What's New Since Jan 2026

**Generated:** 2026-05-01 (updated from 2026-04-26 draft)
**Baseline:** Godot 4.6.2
**Source:** `research/crawl/sourcemap.md` (crawled 2026-05-01) + live fetches 2026-05-01
**Excludes:** godot-mcp-pro internals, godogen, the four MCP tiers in `mcp-alternatives.md`

---

## TL;DR — Top 3 Findings

1. **GUT 9.6.0 (Feb 24, 2026) adds singleton doubling and async timing helpers** — you can now double `Input`, `Time`, `OS` and yield `wait_idle_frames(n)` in tests. These directly address the timing pitfalls in `tests/README.md`. Adopt now.
2. **GdUnit4 is at v6.1.3 (Apr 27, 2026), Godot 4.6-compatible, org renamed** — active and well-maintained, but heavier than GUT with more C# focus. No compelling reason to switch for a pure-GDScript project.
3. **Three new open/freemium Godot MCP servers launched in April 2026** — godot-mcp-core (CrucibleAI, Apr 21), GDAI MCP (32 tools, freemium), and hi-godot/godot-ai (Apr 29, MIT, 120+ tools, from the MCP for Unity team). None replace godot-mcp-pro for our workflow but worth monitoring.

---

## Per-Tool Entries

### GUT (Godot Unit Test)

| Field | Value |
|---|---|
| Role | Primary GDScript unit + integration test framework |
| Current version | **9.6.0** |
| Last release | 2026-02-24 |
| GDScript native | Yes (plugin, no C# dependency) |
| Godot 4.6 support | Yes |
| Citation | https://github.com/bitwes/Gut/releases · https://gut.readthedocs.io/en/v9.6.0/ |

**What's new since Jan 2026:**
- Singleton doubling: `double("Input")`, `double("Time")`, `double("OS")` now work. Previously input simulation in tests required manual workarounds.
- `wait_idle_frames(n)` — yield inside a test for exactly N idle frames; relevant to the round-trip-latency problem in `tests/README.md` for lightweight frame-count scenarios.
- `get_elapsed_sec` / `get_elapsed_msec` / `get_elapsed_usec` — per-test timing; useful for performance regression guards.
- `assert_push_warning` / `assert_push_warning_count` — assert that code pushes a specific warning.
- **Breaking:** `assert_push_error` and `assert_engine_error` now accept only a single string (previously accepted multiple parameter types). Use new `assert_push_error_count` / `assert_engine_error_count` for multi-error assertions. Existing tests using old multi-param form will break on upgrade.
- `print_tracked_errors` — diagnostic helper for test-generated errors.
- Scene-changing methods no longer break tests when run from editor.

**Should we look into it? Yes — adopt now.** The singleton doubling and async frame helpers directly solve problems in our test harness. The `assert_push_error` breaking change is the only migration cost.

---

### GdUnit4

| Field | Value |
|---|---|
| Role | Alternative test framework; broader feature surface, CI-first design |
| Current version | **v6.1.3** |
| Last release | 2026-04-27 |
| GDScript native | Yes; GdUnit4Net is separate C# variant |
| Godot 4.6 support | Yes (v6.1.x supports 4.5, 4.5.1, 4.6, 4.6.1, 4.6.2) |
| Org | godot-gdunit-labs (reorg from MikeSchulze/gdUnit4 in late 2025) |
| Citation | https://github.com/godot-gdunit-labs/gdUnit4/releases |

**What's new since Jan 2026:**
- v6.1.0 (Jan 27): variadic `assert_signal` args, "run until failure" context menu, improved orphan detection, Godot 4.6 compatibility.
- v6.1.1 (Jan 30): hotfix for compile errors, error monitor respects `push_error` report settings.
- v6.1.2 (Mar 20): context menu shortcut fix, VBoxContainer row rendering replaces Tree-based hooks.
- v6.1.3 (Apr 27): test script parse error detection in CLI discovery, inspector freeze fix, backslash handling in function bodies, HTML report href quoting, editor crash on string settings.
- v6.0.0 (Oct 2024, baseline): requires Godot 4.5 minimum — API-breaking from v5. Introduced session hooks, Unicode test names, variadic assert args.
- Master branch (upcoming v6.2) already claims Godot 4.7-beta1 support.

**Should we look into it? No — not now.** GUT 9.6.0 covers our needs with a lighter footprint. GdUnit4 is heavier, more configuration-intensive, and its C# story is irrelevant to a pure-GDScript project. Revisit if GUT stalls or we add C# modules.

---

### GodotEnv (Chickensoft)

| Field | Value |
|---|---|
| Role | CLI tool to manage Godot engine installs and addon versions from the command line |
| Current version | **v2.16.2** |
| Last release | 2026-01-19 |
| Language | C# / .NET tool (cross-platform: Windows, macOS, Linux) |
| Citation | https://github.com/chickensoft-games/GodotEnv/releases · https://www.nuget.org/packages/Chickensoft.GodotEnv/ |

**What's new since Jan 2026:**
- v2.16.2 (Jan 19): support for subdirectory in addon key — more flexible addon organization within projects.
- (No further releases in 2026 as of 2026-05-01; sourcemap note about "April 25 update" may have been a repo activity, not a release.)
- Earlier landmark: v2.15.0 (Jul 2025) added a `pin` command for locking specific Godot versions per project.

**Should we look into it? Low priority.** GodotEnv is primarily a C# / Chickensoft-ecosystem tool. It can install/switch Godot engine versions and manage addons from the CLI, which is useful for CI pipelines. Not a blocker for our GDScript workflow, but worth knowing exists if we automate CI builds. Note: no 2026 releases beyond January.

---

### godot-ci (abarichello/godot-ci)

| Field | Value |
|---|---|
| Role | Docker image + GitHub Actions templates for exporting and deploying Godot games |
| Current version | **4.6.2-stable** (latest Docker tag) |
| Last release | 2026-04-01 |
| Citation | https://github.com/abarichello/godot-ci |

**What's new since Jan 2026:**
- Docker image updated to track Godot 4.6.2-stable. Ships templates for GitHub Actions → GitHub Pages and Itch.io deployment.
- 35 releases total; actively maintained alongside Godot point releases.

**Should we look into it? Yes, when we need CI/CD.** Not urgent for current solo dev phase, but godot-ci is the de facto standard for automated Godot builds. Set up when we target a public release on Itch.io or need nightly builds.

---

### Tracy Profiler Integration (Godot 4.7 build system)

| Field | Value |
|---|---|
| Role | Native profiler integration — no manual engine code changes required |
| Godot version | 4.7 (beta; NOT yet stable) |
| Status | Available in 4.7-beta1 builds via SCons `tracy_enable=yes` |
| Citation | https://github.com/godotengine/godot/pull/113279 · https://forum.godotengine.org/t/does-new-godot4-6-tracy-profiler-support-works-with-gdextension-dlls/132830 |

**What's new:**
- Build system now auto-detects and integrates Tracy/Perfetto when `tracy_enable=yes` is passed to SCons — no manual engine patching needed.
- GDScript profiling via Tracy is now supported (PR #113279 by Lukas/Samuel Nicholas).
- Known issue: memory leak in Tracy builds as of Feb 2026 (issue #115798); still being tracked.
- Godot 4.6 does NOT have this integration; it requires a custom engine build.

**Should we look into it? Not yet.** Requires building from source with a 4.7 dev snapshot, which we are not doing (production baseline is 4.6.2). Flag for revisit when 4.7 goes stable. The built-in editor profiler + MCP `get_performance_monitors` is sufficient for our current scale.

---

### godot-rust / gdext v0.5

| Field | Value |
|---|---|
| Role | Rust GDExtension bindings; shapes GDExtension API surface |
| Current version | **v0.5** (March 2026) |
| Citation | https://godot-rust.github.io/dev/march-2026-update/ |

Typed dictionaries, `AnyArray`, three safeguard tiers, composable GDExtension crates. **No — GDScript project; ignore.**

---

### MCP Integrations Beyond godot-mcp-pro

Per `research/tools/mcp-alternatives.md` (definitive file for this topic). Three **new** 2026 entrants not in that file:

#### godot-mcp-core (CrucibleAI)

| Field | Value |
|---|---|
| Role | Lightweight free MCP bridge: scene tree inspection, node queries, optional GDScript execution |
| First release | 2026-04-21 (Godot Asset Library submission date) |
| Tools | 32 tools |
| Cost | Free (details unclear; asset library listing is free) |
| Security | Local-only (127.0.0.1), API key auth, GDScript exec disabled by default |
| Citation | https://github.com/crucibleaiapp/godot-mcp-core · https://godotengine.org/asset-library/asset/4767 |

**Should we look into it? Low priority.** Narrower feature set than godot-mcp-pro. Scene tree inspection is the key capability, but godot-mcp-pro already covers this. Worth watching if we need a lightweight fallback without the paid plugin.

#### hi-godot/godot-ai

| Field | Value |
|---|---|
| Role | Free/open-source MCP server (Python + WebSocket plugin); 120+ tools |
| First release | 2026-04-29 (Godot Asset Library submission) |
| Tools | 120+ (scenes, nodes, scripts, animations, UI, materials, particles, audio, input mapping) |
| Cost | Free, MIT license |
| Clients | Claude Code, Codex, Cursor, Zed, 15+ MCP clients |
| Provenance | Made by the team behind MCP for Unity (8,500+ GitHub stars) |
| Citation | https://github.com/hi-godot/godot-ai · https://godotengine.org/asset-library/asset/5050 |

**Should we look into it? Watch, don't adopt yet.** First released April 29, 2026 — very new. The Unity-MCP pedigree is a positive signal (battle-tested patterns), but it's too early to assess stability vs. godot-mcp-pro. Check again after one month of community feedback.

#### GDAI MCP

| Field | Value |
|---|---|
| Role | Freemium MCP server for Godot 4.2+; 32 tools with scene, script, asset, debug, and 2D-asset generation |
| First release | Unknown (site live as of 2026-05-01) |
| Tools | 32 tools |
| Cost | Freemium (some features gated) |
| Unique feature | 2D asset generation (AI-generated sprites from MCP) |
| Citation | https://gdaimcp.com/ |

**Should we look into it? No.** First-release date unknown, freemium pricing unclear, 32-tool scope is a subset of godot-mcp-pro. The 2D asset generation angle is interesting but untested. Skip for now.

---

### AI / LLM Helpers for Godot (General)

No new LLM helper targeting GDScript production workflows emerged in this window beyond what's in `mcp-alternatives.md` and `godot-ai-builder.md`. Notable non-events: NVIDIA RTX Godot fork (GDC Mar 13, 2026 — experimental, 3D-only, not upstream); Chickensoft LogicBlocks updated Apr 22 (C# only, irrelevant); GDQuest GDTour updated Apr 23–25 (tutorial framework, not AI).

---

## Noteworthy Newcomers (First Release in 2026)

| Name | Category | First seen | Status | Should we watch? |
|---|---|---|---|---|
| **hi-godot/godot-ai** | MCP server (free, MIT) | Apr 29, 2026 | Very new; 120+ tools; Unity-MCP pedigree | Yes — re-check in 4–6 weeks |
| **godot-mcp-core (CrucibleAI)** | MCP server (free?) | Apr 21, 2026 | 32 tools; narrow scope | Low priority |
| **GDAI MCP** | MCP server (freemium) | Unknown 2026 | 32 tools; 2D asset gen angle | Skip |
| **GUT 9.6.0** | Test framework | Feb 24, 2026 | Stable; directly relevant | Adopt now |
| **GdUnit4 v6.1.3** | Test framework | Apr 27, 2026 | Godot 4.6 ready | Monitor; no need to switch |
| **NVIDIA RTX Godot fork** | Rendering | Mar 2026 (GDC) | Experimental; 3D only; not upstream | Ignore |
| **GodotCon Amsterdam talks** | Learning | Apr 23–24, 2026 | Videos arriving on official YouTube | Check official channel |

*Data sourced from `research/crawl/sourcemap.md` + live web fetches on 2026-05-01. All claims cited inline.*
