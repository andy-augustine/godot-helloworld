# Godot Tooling — What's New Since Jan 2026

**Generated:** 2026-04-26  
**Baseline:** Godot 4.6.2  
**Source:** `research/crawl/sourcemap.md` (crawled 2026-04-26)  
**Excludes:** godot-mcp-pro internals, godogen, the four MCP tiers in `mcp-alternatives.md`

---

## TL;DR — Top 3 Findings

1. **GUT 9.6.0 (Feb 2026) adds real async-testing primitives** — `wait_idle_frames`, elapsed-time helpers, and singleton doubling (Input, Time, OS). These close the gap on the timing pitfalls documented in TESTING.md. Worth adopting now.
2. **GdUnit4 has split into two parallel lines** (v5 for Godot 4.4, v6 for Godot 4.5+), both actively maintained, but the project is heavier and more C#-oriented than GUT; no compelling reason to switch for a pure-GDScript project.
3. **NVIDIA shipped an RTX-powered Godot fork at GDC 2026** — experimental, not upstream, not relevant to our 2D platformer but a signal that the engine is attracting tier-1 tooling investment.

---

## Per-Tool Entries

### GUT (Godot Unit Test)

| Field | Value |
|---|---|
| Role | Primary GDScript unit + integration test framework |
| Current version | **9.6.0** (Godot 4.x branch) |
| Last release | 2026-02-24 |
| GDScript native | Yes (plugin, no C# dependency) |
| Citation | https://github.com/bitwes/Gut/releases · https://gut.readthedocs.io/en/v9.6.0/ |

**Since Jan 2026:**
- `assert_push_warning` / `assert_push_warning_count` — assert that code pushes (or does not push) a specific warning string; useful for negative-path tests.
- Singleton doubling — `double("Input")`, `double("Time")`, `double("OS")` now work; previously input simulation in tests required manual workarounds.
- `wait_idle_frames(n)` — yield inside a test for exactly N idle frames; bridges the round-trip-latency gap described in TESTING.md for lightweight frame-counting scenarios.
- `get_elapsed_sec` / `get_elapsed_msec` — per-test elapsed time; useful for performance regression guards.
- GUT 7.4.2 remains the Godot 3.x branch (no changes relevant to us).

**Should we look into it?** **Yes — adopt now.** The new async helpers directly address the timing issues in TESTING.md. Singleton doubling means we can write unit tests for code that calls `Input.is_action_pressed()` without running the full scene.

---

### GdUnit4

| Field | Value |
|---|---|
| Role | Alternative test framework; broader feature surface, CI-first design |
| Current version | **v5.0.4** (Godot 4.4) / **v6.0.0** (Godot 4.5+) |
| Last release | v5.0.4 updated 2026-04-21; v6.0.0 targeting Godot 4.5 |
| GDScript native | Yes, plus GdUnit4Net for C# |
| Org | godot-gdunit-labs (reorg from MikeSchulze/gdUnit4 in late 2025) |
| Citation | https://github.com/godot-gdunit-labs/gdUnit4/releases |

**Since Jan 2026:**
- v6 represents an API-breaking split tracking Godot 4.5 node changes. v5 is still actively patched for 4.4.
- The project reorganized under a labs org, signaling it is treating itself as a more formal product.
- Momentum is real (frequent releases), but the tooling leans heavier than GUT: more configuration, separate CI runner binary, stronger C# story.

**Should we look into it?** **No — not now.** GUT 9.6.0 covers our needs, has a lighter footprint, is purely GDScript, and the new version/org split means we'd be chasing a moving target. Revisit if GUT stalls or we add C# modules.

---

### godot-rust / gdext v0.5

| Field | Value |
|---|---|
| Role | Rust GDExtension bindings; not a test framework but shapes GDExtension API surface |
| Current version | **v0.5** |
| Last release | March 2026 |
| Citation | https://godot-rust.github.io/dev/march-2026-update/ |

**Since Jan 2026:**
- Typed dictionaries (`Dictionary<K,V>`), `AnyArray`, three safeguard tiers (permissive / standard / strict).
- GDExtension crate dependencies now supported — extensions can compose.

**Should we look into it?** **No (GDScript project).** Useful only to understand GDExtension API surface if a performance-critical node becomes a candidate for a Rust extension. File and ignore for now.

---

### MCP Integrations Beyond godot-mcp-pro

Per `research/tools/mcp-alternatives.md` (the definitive file for this topic), four tiers are already covered. New signals from the Jan 2026+ window not in that file:

| Tool | Stars | Last push | Notes |
|---|---|---|---|
| **shameindemgg/godot-catalyst** | 1 | 2026-04-20 | Claims 240+ tools; too new, 1 star — watch, don't adopt |
| **ryanmazzolini/minimal-godot-mcp** | 29 | 2026-04-24 | LSP-only: GDScript validate + DAP console buffer. Niche complement, not a replacement. |

**Should we look into these?** **No.** godot-catalyst is unproven; minimal-godot-mcp's validate-only scope is already covered by godot-mcp-pro's `validate_script`. See `mcp-alternatives.md` for full decision matrix.

---

### AI / LLM Helpers for Godot

| Tool | Notes |
|---|---|
| **GDQuest GDTour framework** | Updated April 23–25, 2026. Interactive in-editor tutorials; not an AI tool but useful as a pattern for guided onboarding. |
| **NVIDIA RTX Godot fork** | Announced GDC March 13, 2026. Adds hardware ray tracing. Not upstream, not stable, 3D-only. |
| **godot-ai-builder** (internal research) | Covered in `research/tools/godot-ai-builder.md`. |
| **Chickensoft LogicBlocks** | Updated April 22, 2026. C# state machine library; architecture reference only — not GDScript. |

No new AI-specific LLM helper targeting GDScript production in this window. The "AI slop" maintainer complaint (Feb 2026) reflects volume of AI-generated PRs, not any tooling release.

**Should we look into these?** **Not for 2D platformer work.** RTX fork is 3D-only and experimental. GDTour is interesting for docs/onboarding if we ever open-source or collaborate.

---

### Profilers and Build Tooling

| Tool | Notes |
|---|---|
| **Godot built-in profiler** | No new external profiler emerged; Godot 4.6+ editor profiler remains the standard approach. |
| **`get_editor_performance` / `get_performance_monitors`** | Available in godot-mcp-pro already; covers per-frame metrics without external tools. |
| **`--export-release` CLI** | Documented in `mcp-alternatives.md`; no new CI tooling surfaced in Jan–Apr 2026. |
| **`--write-movie`** | Deterministic frame recording flag; useful for automated visual regression; no new wrapper emerged. |

**Should we look into these?** **Not immediately.** Our project is early-stage; the built-in profiler + MCP `get_performance_monitors` is sufficient. Revisit when frame-time budgets become a concern.

---

## Noteworthy Newcomers (First Release in 2026)

| Name | Category | First seen | Status |
|---|---|---|---|
| **shameindemgg/godot-catalyst** | MCP server | Apr 2026 | 1 star; unproven; monitor only |
| **GdUnit4 v6.0.0** | Test framework | 2026 Q1 | API-breaking from v5; tracks Godot 4.5 |
| **NVIDIA RTX Godot fork** | Rendering | Mar 2026 (GDC) | Experimental; not upstream; 3D only |
| **GodotCon Amsterdam talks** | Learning | Apr 23–24, 2026 | Videos expected on official YouTube soon |

No category-defining new tool emerged in this window. The tooling ecosystem is maturing and consolidating around existing frameworks rather than spawning replacements.

---

*All data sourced from `research/crawl/sourcemap.md`. No independent crawl performed.*
