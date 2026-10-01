# Godot Tooling Ecosystem — October 2026 Intel

**Crawl date:** 2026-10-01
**Target window:** September 2026 onward (previous crawl: 2026-09-01)
**Agent:** Topic C — Tooling ecosystem

---

## TL;DR — Top 3 Findings

1. **Beckett (beckettlab/beckett-godot-mcp) is the most interesting new MCP option** — a zero-sidecar Godot 4 MCP server that ships as a pure GDScript plugin (no Node.js, no Python), released July 13, 2026. Free Lite (MIT) includes scene inspection, live scene tree, screenshots of the running game, and performance monitor reads. Full edition ($15) adds deeper capabilities. The architecture — single GDScript plugin, local HTTP — is simpler than godot-mcp-pro's Node.js sidecar. Worth evaluating as an alternative or backup.

2. **GUT is still the right choice; no release since v9.7.1 (July 2026)** — nothing new landed in September 2026. The Godot 4.8 dev5 snapshot (September 2026, feature freeze imminent) will require a GUT compatibility release after 4.8 stable ships. That watch item from last crawl remains open.

3. **W4Build is dead** — W4 Games killed off their managed Godot CI product; users were migrated by January 2026 and the core code was open-sourced. The replacement landscape is: self-hosted GitHub Actions (several community templates exist), chickensoft-games toolchain patterns (GDScript-applicable for binary management), or rolling your own with `godot --headless --export`.

---

## Per-Tool Entries

### GUT (Godot Unit Testing)

| Field | Value |
|---|---|
| Role | GDScript unit test framework; runs in-editor or headless via CLI |
| Current version | **v9.7.1** |
| Last release date | July 11, 2026 |
| Maintainer | bitwes (`github.com/bitwes`) |
| License | MIT |
| Godot compat | 4.7.x confirmed; 9.x series = Godot 4.x series |
| URL | https://github.com/bitwes/Gut |

**What changed since last crawl:** No new release since v9.7.1. Still current stable. v9.7.0 (June 2026) added Godot 4.7 compatibility; doubles now return type-appropriate defaults instead of null, which is a **breaking change** if tests relied on `stub(...).to_do_nothing()` returning null. v9.7.1 fixed invalid-class parsing errors and "Compiler bug: Unresolved return" in double generation.

**Should we look into it?** YES — **already in use and the right choice**. No migration pressure. Watch for a v9.8.x release after Godot 4.8 stable ships (feature freeze September/October 2026, beta likely late October).

---

### GdUnit4

| Field | Value |
|---|---|
| Role | GDScript + C# test framework; strong CI/CD focus; JUnit XML output |
| Current version | **v6.2.0** |
| Last release date | July 30, 2026 |
| Maintainer | MikeSchulze / godot-gdunit-labs org |
| License | MIT |
| Godot compat | Built on Godot 4.5 stable; 4.7.x compat unconfirmed as of this crawl |
| URL | https://github.com/godot-gdunit-labs/gdUnit4 |

**What changed since last crawl:** No new release in September 2026. v6.2.0 (July 30) added GitHub Actions workflow templates out of the box and improved JUnit XML export. v6.1.3 (April 2026) introduced ProjectSettings isolation (auto-snapshot/restore per test) and CLI parse error detection with non-zero exit codes for CI. Momentum continues but the 4.7 compat watch item from last crawl is still open.

**Should we look into it?** LOW priority for our GDScript-only project. GUT covers our needs. GdUnit4's differentiator is C# parity and JUnit CI dashboards — irrelevant here. Revisit if we ever add a structured CI pipeline.

---

### Beckett (beckettlab/beckett-godot-mcp) ★ NEW

| Field | Value |
|---|---|
| Role | Zero-sidecar MCP server embedded as a GDScript plugin in the Godot editor |
| Current version | Lite (free/MIT) + Full ($15 one-time) |
| First listed | July 13, 2026 (Godot Asset Store + MCP directories) |
| Godot compat | Godot 4.2+ |
| URL | https://github.com/beckettlab/beckett-godot-mcp; https://store.godotengine.org/asset/beckett/beckett-godot-mcp/ |

**What it does:** Beckett installs as a single GDScript plugin — no Node.js, no Python, no secondary process, no cloud. An MCP-capable AI client (Claude Code, Cursor, Windsurf, VS Code with Cline/Copilot) connects to the editor over local HTTP. The free Lite edition covers: inspect + author + run + see loop — the AI can run the game, screenshot it, read the live remote scene tree and live node state, read performance monitors, and tail game logs. Validates GDScript before writing (prevents committing broken scripts). Full edition ($15) adds deeper capabilities not fully disclosed in public summaries.

**Should we look into it?** YES — **evaluate as godot-mcp-pro backup**. The architecture is simpler and lower-maintenance than godot-mcp-pro's Node.js sidecar (no `node` binary dependency, no npm updates). The free tier covers the inspect/author/run/screenshot loop that we rely on most. Risk: less battle-tested than godot-mcp-pro; smaller community. Not a replacement if youichi-uda/godot-mcp-pro/pull/25 lands, but a strong fallback.

---

### Godot AI Workbench ★ NEW

| Field | Value |
|---|---|
| Role | MCP-capable AI agent connector to the Godot 4 editor; 129 built-in tools |
| Current version | Listed in old Asset Library (asset #5353); also in new Store |
| License | Not confirmed (appears free/local-first) |
| URL | https://godotengine.org/asset-library/asset/5353 |

**What it does:** 129 MCP tools in grouped families: scene/node/script/resource operations; runtime play/stop/input simulation/assertions/screenshots; LSP diagnostics for AI-assisted debugging; UID repair helpers for stale resource references; 2D and 3D workflow helpers. No cloud backend — bridge listens on 127.0.0.1 only.

**Should we look into it?** LOW-MED — the tool count (129) is between Beckett Lite and godot-mcp-pro (162 tools). Less name recognition than the others. No clear differentiator over Beckett or godot-mcp-pro for our use case. Monitor adoption in the community before investing time.

---

### chickensoft-games toolchain (GodotEnv, AutoInject)

| Field | Value |
|---|---|
| Role | C# toolchain: multi-version Godot install manager (GodotEnv), DI (AutoInject) |
| Last known activity | August 19–20, 2026 |
| Maintainer | chickensoft-games org |
| License | MIT |
| URL | https://github.com/chickensoft-games |

**What changed since last crawl:** No new activity in September 2026 found. GodotEnv remains useful for pinning a specific Godot binary in CI even for GDScript projects.

**Should we look into it?** MED for CI patterns only. GodotEnv's binary-pinning model is the right approach if we add headless test runs to CI. Skip AutoInject/GameDemo (C# only).

---

### ProProfiler

| Field | Value |
|---|---|
| Role | Runtime profiling and log centralization addon for Godot 4 |
| Current version | Multiple asset library edits visible (assets #20244, #20223); active as of 2026 |
| URL | https://godotengine.org/asset-library/asset/20244 |

**What it does:** Lightweight addon that centralizes logs, inspects disk usage, and provides simple runtime profiling for development. Separate from the engine's built-in profiler tab.

**Should we look into it?** LOW — built-in Godot profiler (Debugger > Profiler tab) is sufficient for our current scale. ProProfiler adds convenience, not capability. Revisit when we hit a specific performance puzzle that needs custom runtime instrumentation.

---

### W4Build (DEAD)

| Field | Value |
|---|---|
| Role | Managed cloud CI/CD for Godot (builds, exports, multi-platform) |
| Status | **DISCONTINUED** — users migrated by January 2026; code open-sourced |
| URL | https://www.w4games.com/w4build (defunct) |

**What happened:** W4 Games killed off W4Build before January 2026. The core technology was open-sourced for the community to fork. Despite W4 raising $18M Series B in August 2026 (Tencent), the CI product was not in their go-forward strategy. Replacement: self-hosted GitHub Actions with community templates (several active in 2026), or godot-ci open-source templates.

**Should we look into it?** NO — product is gone. If we need CI automation, look at community GitHub Actions templates or the open-sourced W4Build code.

---

### erodenn/godot-mcp-runtime

| Field | Value |
|---|---|
| Role | Lightweight TypeScript MCP server for runtime Godot control via UDP bridge |
| Stars | ~30 (as of October 2026) |
| Last known activity | May 2026 |
| URL | https://github.com/erodenn/godot-mcp-runtime |

**What it does:** Runtime-focused MCP: inject a UDP bridge, simulate inputs, take screenshots, execute live GDScript while the game is running.

**Should we look into it?** LOW — low star count, no September 2026 activity, smaller scope than godot-mcp-pro. The runtime-injection approach may have compatibility fragility. Skip unless godot-mcp-pro gaps become painful.

---

## Noteworthy Newcomers (First Release in 2026)

### Beckett (beckettlab/beckett-godot-mcp)
- **First listed:** July 13, 2026
- **What it is:** Zero-sidecar GDScript MCP plugin (see full entry above)
- **Verdict:** Evaluate as godot-mcp-pro backup. Free tier covers our core loop.

### Godot AI Workbench
- **First listed:** 2026 (exact date unclear, visible in Asset Library edits)
- **What it is:** 129-tool MCP connector, local-first, free
- **Verdict:** Monitor community traction before adopting.

### Godot MCP Toolkit (asset #23816)
- **First listed:** 2026 (edit accepted in Asset Library)
- **What it is:** Unclear — appeared in Asset Store as "Godot MCP Toolkit"
- **Verdict:** Insufficient data. Check at next crawl.

---

## Godot 4.8 dev5 (September 2026) — Tooling Relevance

| Feature | Impact on Tooling |
|---|---|
| Mip-level texture streaming | Reduces VRAM for open-world scenes; affects any profiling baselines |
| 2D editor toolbar redesign | Any MCP tool that clicks toolbar buttons by position may break |
| Main screen plugins → EditorDock | Plugins that used main screen real estate need updating for 4.8 compat |
| Feature freeze imminent | GUT + GdUnit4 + Beckett will each need 4.8 compat releases after stable ships |

**Action:** No action yet. When 4.8 stable ships (likely late Q4 2026), re-check GUT, GdUnit4, and Beckett for compatibility releases before upgrading the project engine version.

---

## Watch List (Updated)

| Item | Why watch | Re-scan trigger |
|---|---|---|
| GUT v9.8.x | Godot 4.8 stable will require compat release | When Godot 4.8 stable ships |
| GdUnit4 4.7 compat | v6.2.0 targets 4.5+; 4.7 compat still unconfirmed | Check GitHub releases page |
| Beckett Full edition details | $15 paid tier; unclear if it covers anything we need | Evaluate if godot-mcp-pro becomes unmaintained |
| youichi-uda/godot-mcp-pro/pull/25 | In-flight local fork patch | Check if merged or stalled |
| Godot MCP Toolkit (#23816) | New Store listing, no data yet | Check at next crawl |
| Community GitHub Actions CI templates | W4Build dead; replacement landscape forming | Search `godot ci github actions` next crawl |

---

*Sources: research/crawl/sourcemap.md; web search via Claude Code session 2026-10-01; enterprisedna.co/directories/mcp/* (MCP tool listings); store.godotengine.org (asset listings); gamefromscratch.com (W4Build discontinuation); github.com/bitwes/Gut releases page; github.com/godot-gdunit-labs/gdUnit4 releases.*
