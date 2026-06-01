# Godot Tooling — What's New Since January 2026

**Crawl date:** 2026-06-01 | **Window:** post-January 2026

---

## TL;DR — Top 3 Findings

1. **GdUnit4 has overtaken GUT in momentum.** v6.1.3 dropped April 27 2026; active release cadence with flaky-test detection, session hooks, and HTML/XML reports. GUT is still on v9.6.0 (Feb 2025 — over 15 months stale). For a new test suite, GdUnit4 is the stronger bet unless you need the doubling-of-Godot-singletons GUT added in 9.6.
2. **A new class of in-editor AI agents landed in 2026.** Ziva (launched ~Feb 2026) is the most capable: live scene-tree manipulation via editor API, GUT integration, screenshot context, sprite generation, 50+ Godot integrations. It is a paid subscription but has a free tier. AI Assistant Hub (free, Ollama/Gemini) is the no-cost alternative. Summer Engine (open-source Godot 4 plugin) embeds an AI-native MCP-compatible layer directly into the engine.
3. **godot-ci is tracking Godot 4.6.3 and is the de-facto GitHub Actions CI standard.** It is the best-maintained export automation path; no credible challenger has emerged. GodotEnv (Chickensoft) is a useful companion for version management but is C#-focused.

---

## Per-Tool Entries

### Testing Frameworks

---

#### GUT (Godot Unit Testing)

| Field | Value |
|---|---|
| Role | GDScript unit testing, in-editor or headless CLI |
| Current version | v9.6.0 |
| Last release | February 24, 2025 (over 15 months ago as of this crawl) |
| Godot compatibility | 4.6 confirmed |
| Maintainer | bitwes (sole) |

**v9.6.0 highlights** (all still current — no v10 announced):
- `assert_push_warning` / `assert_push_warning_count`
- `push_warning` no longer fails tests as unexpected errors
- Can double Godot singletons (Input, Time, OS, etc.)
- `wait_idle_frames`; `wait_frames` → `wait_physics_frames` (alias kept)
- Time tracking: `get_elapsed_sec/msec/usec`

**Verdict: Yes, use it — but watch for signs of stagnation.** It is already in our project's test patterns. The singleton-doubling feature is unique and valuable for physics/input tests. The 15-month release gap is a yellow flag; if GUT goes another 6 months without a release, migrating to GdUnit4 should be on the backlog.

Sources: [bitwes/Gut releases](https://github.com/bitwes/Gut/releases) | [GUT Asset Library](https://godotengine.org/asset-library/asset/1709)

---

#### GdUnit4

| Field | Value |
|---|---|
| Role | GDScript + C# unit testing, embedded inspector, mocking, scene runners |
| Current version | v6.1.3 (GDScript) / gdUnit4Net maintained separately for C# |
| Last release | April 27, 2026 |
| Godot compatibility | 4.5+ required (API break from 4.4) |
| Maintainer | godot-gdunit-labs org (MikeSchulze + org) |

**2026 additions since Jan 2026 (v6.0 → v6.1.3):**
- Requires Godot 4.5+ (v6.0 was the compatibility-break release)
- Detects test script parse errors during CLI discovery
- Flaky test detection with configurable retry counts
- Custom session hooks (default: HTML + XML test reports)
- Unicode character support in test names
- Variadic argument support (no more array wrappers)
- Bug fixes: inspector responsiveness, backslash handling, context menu visibility
- v7.0.0 tracked in issues — active roadmap

**Verdict: Evaluate for new subsystems.** GdUnit4 has stronger reporting (HTML/XML out of the box), flaky-test detection, and active 2026 development. The Godot 4.5+ requirement is not a problem for us (running 4.6.2). Main trade-off: existing GUT tests would need migration. Not worth switching mid-project, but GdUnit4 is the better choice for a greenfield test suite.

Sources: [gdUnit4 releases](https://github.com/godot-gdunit-labs/gdUnit4/releases) | [GdUnit4 Asset Library](https://godotengine.org/asset-library/asset/4390)

---

### AI / LLM Helpers

---

#### Ziva

| Field | Value |
|---|---|
| Role | In-editor AI agent: scene creation, GDScript gen, debug, sprite/asset gen |
| Current version | Subscription SaaS; plugin in Asset Library (asset/4879) |
| Launched | ~February 2026 (Product Hunt listing Feb 24 2026) |
| Pricing | Free tier ($3/mo AI credit); paid plans above |

**Capabilities:** Manipulates live scene tree via editor API (not raw .tscn edits), writes and runs GUT tests, reads debugger errors, takes editor screenshots for visual context, generates pixel art sprites and TileMap assets. Supports Claude, Gemini, ChatGPT backends. 50+ Godot integrations.

**Verdict: Worth a trial.** The live scene-tree manipulation via editor API (vs. patching .tscn files) is a meaningful improvement over our current MCP approach for scene authoring tasks. Screenshot-as-context is directly complementary to godot-mcp-pro's `capture_frames`. Main unknown: how it interacts with an existing godot-mcp-pro workflow — likely additive, not a replacement.

Sources: [ziva.sh](https://ziva.sh/) | [Ziva Asset Library](https://godotengine.org/asset-library/asset/4879) | [Product Hunt](https://www.producthunt.com/products/ziva-sh-ai-agent-for-game-engines)

---

#### AI Assistant Hub (FlamxGames)

| Field | Value |
|---|---|
| Role | In-editor AI assistant; Ollama (local) or Gemini API |
| Asset Library | asset/3427 |
| Cost | Free, open-source |
| Launched | 2025 (active in 2026) |

**Verdict: Low-priority for us.** We already have godot-mcp-pro for the lead seat. Useful if a collaborator wants free AI-assisted editing without MCP setup. File under backlog.

Sources: [FlamxGames/godot-ai-assistant-hub](https://github.com/FlamxGames/godot-ai-assistant-hub) | [Asset Library](https://godotengine.org/asset-library/asset/3427)

---

#### Summer Engine

| Field | Value |
|---|---|
| Role | Open-source Godot 4 plugin adding AI-native layer + MCP integration |
| GitHub | github.com/SummerEngine/summer |
| Cost | Free, open-source; hosted plans available |
| Launched | 2025–2026 |

Drop-in layer on Godot 4 that enables AI agents (Claude Code, Cursor, etc.) to create scenes, write scripts, and generate assets via MCP. Has a migration guide from vanilla Godot. Competes with our existing godot-mcp-pro setup.

**Verdict: Monitor only.** Interesting architecture (MCP built into engine vs. plugin), but adds a layer between us and vanilla Godot — risky for a project already mid-development. The migration path from Godot → Summer Engine is not zero-cost. Revisit if godot-mcp-pro support lags 4.7.

Sources: [SummerEngine/summer](https://github.com/SummerEngine/summer) | [summerengine.com](https://www.summerengine.com/)

---

### Profilers

---

#### Built-in Godot Profiler + zprofiler

| Field | Value |
|---|---|
| zprofiler | CPU time profiler by Zylann; in-editor; GitHub: Zylann/zprofiler |
| GDProfiler | Simple in-editor profiler; Asset Library asset/3055 |
| Built-in | Godot 4.6 profiler improved with ObjectDB debugger (memory snapshots/diffs) |

No new dominant profiler plugin emerged since Jan 2026. The engine's built-in profiler plus the ObjectDB debugger added in 4.6.0 covers the primary use cases. Arm Performance Studio integration is available for mobile targets but not relevant for our desktop/2D project.

**Verdict: Use built-in + ObjectDB for now.** No action needed.

---

### Build Tooling & CI/CD

---

#### godot-ci (abarichello)

| Field | Value |
|---|---|
| Role | Docker image for headless export + GitHub Actions / GitLab CI templates |
| Current image tag | 4.6.3-stable (tracking latest stable) |
| GitHub | github.com/abarichello/godot-ci |
| GitHub Marketplace | godot-ci Action |

De-facto standard for Godot CI. Supports export to all platforms, deploy to itch.io / GitHub Pages / GitLab Pages. Updated to track 4.6.3. No significant architecture change in 2026 — it continues to work and is well-maintained.

**Verdict: Adopt when CI is prioritized.** Already in our backlog. No reason to evaluate alternatives.

Sources: [abarichello/godot-ci](https://github.com/abarichello/godot-ci) | [GitHub Marketplace](https://github.com/marketplace/actions/godot-ci)

---

#### GodotEnv (Chickensoft)

| Field | Value |
|---|---|
| Role | CLI for managing Godot versions + addons on Windows/macOS/Linux |
| Current version | 2.16.2 (NuGet) |
| Last release | April 29, 2026 |
| Language | C# (.NET tool) |

Manages `addons.json`-based addon installs, Godot version symlinks, and local addon dev symlinks. C#-ecosystem tool — the GDScript addon management story is Godot's built-in Asset Library or manual git.

**Verdict: Skip for our GDScript project.** Useful for C# teams; overhead not justified for a pure-GDScript setup.

Sources: [chickensoft-games/GodotEnv](https://github.com/chickensoft-games/GodotEnv)

---

## Noteworthy Newcomers (First Release in 2026)

| Tool | Role | Launched | Notes |
|---|---|---|---|
| **Ziva** | In-editor AI agent (scene + code + assets) | ~Feb 2026 | Most capable new AI tool; free tier available |
| **GD-Sync** | Multiplayer backend addon | Apr 24, 2026 | Not relevant to our project |
| **Summer Engine** | AI-native Godot 4 fork/plugin | 2025–2026 | MCP-integrated; monitor but don't adopt mid-project |
| **Agent Tools plugin** (asset/5070) | MCP agent surface for editor + perf measurement | Apr 2026 | Low star count; experimental |

---

## What We Are NOT Re-covering

Per task instructions, the following are out of scope for this document:
- godot-mcp-pro internals → `research/godot-mcp-pro-internals.md`
- godogen capabilities → `research/godogen.md`
- MCP alternatives (Coding-Solo, tomyud1, hi-godot/godot-ai, ryanmazzolini/minimal-godot-mcp) → `research/tools/mcp-alternatives.md`
- youichi-uda/godot-mcp-pro PR #25 (in-flight patch) — tracked separately
