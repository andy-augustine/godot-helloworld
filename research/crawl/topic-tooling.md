# Godot Tooling Intel — Jan–Jul 2026
*Generated: 2026-07-01 | Godot current stable: 4.7 (released June 18, 2026)*

---

## TL;DR — Top 3 Findings

1. **GdUnit4 has surged ahead of GUT in momentum.** It moved to a dedicated GitHub org (`godot-gdunit-labs`), shipped four releases in 2026 (v6.1.0 through v6.1.3), added Godot 4.7 compat, and is building toward a v7 API overhaul. GUT shipped one release in 2026 (9.7.0, June 19) tied to Godot 4.7 compatibility — maintained but not expanding.

2. **Free MCP alternatives to godot-mcp-pro have proliferated.** At least four production-grade free/open-source options now exist: godot-ai (hi-godot, 150+ ops, MIT, one-click Asset Store install), IvanMurzak/Godot-MCP (39 tools, C#, Apache-2.0), Coding-Solo/godot-mcp (lightweight, npm), and GDAI MCP. The $5 godot-mcp-pro still wins on tool count (163 tools) and live-engine access, but free competition is real.

3. **godot-ci (abarichello) is current-stable for CI/CD deployment.** It updated to 4.7-stable on June 19, 2026 — same day as the engine release. No new deployment tooling emerged in 2026; the Docker + GitHub Actions + butler-to-itch.io pattern remains standard.

---

## Per-Tool Entries

### Testing Frameworks

#### GUT (Godot Unit Test)
- **Role**: GDScript-native unit testing framework; write tests in GDScript
- **Current version**: 9.7.0
- **Last release**: June 19, 2026
- **2026 activity**: One release (9.7.0) addressing Godot 4.7's stricter type-checking for return values in Doubles; adjusted to return TYPE_ constant defaults. Compatibility-fix release rather than new features.
- **Verdict for this project**: Yes — still the default choice for pure GDScript testing. Minimal setup, well-documented, matches the project's GDScript-first convention. No blocking issues.
- **Godot 4.7 compat**: Yes (9.7.0 explicitly targets 4.7.x)
- **Citations**: https://github.com/bitwes/Gut | https://gut.readthedocs.io/

#### GdUnit4
- **Role**: Embedded testing framework for Godot 4 supporting GDScript and C#; more feature-rich than GUT (mocking, parameterized tests, scene runner, flaky-test detection, CI/CD action, HTML/JUnit reports)
- **Current version**: v6.1.3
- **Last release**: April 27, 2026
- **2026 releases**: v6.1.0 (Jan 27) — "run until failure", variadic `assert_signal`; v6.1.1 (Jan 30) — hotfix; v6.1.2 (Mar 20) — UI fixes; v6.1.3 (Apr 27) — CLI discovery, inspector fixes
- **Org move**: Migrated from `MikeSchulze/gdUnit4` → `godot-gdunit-labs/gdUnit4` (institutional backing signal)
- **In development**: v7.0.0 (API overhaul, milestone open on GitHub)
- **Verdict for this project**: Worth evaluating if CI/CD pipeline testing becomes a priority; overkill for small GDScript-only projects. GUT is simpler to adopt; GdUnit4 pays off at scale or with C#.
- **Godot 4.7 compat**: Yes (master branch tracks 4.7-rc2+)
- **Citations**: https://github.com/godot-gdunit-labs/gdUnit4 | https://godot-gdunit-labs.github.io/gdUnit4/latest/

---

### MCP / AI Editor Integrations

#### godot-mcp-pro (current project tool)
- **Role**: Paid MCP plugin connecting Claude/Cursor to live Godot editor via WebSocket
- **Current version**: In use — 163 tools, 23 categories
- **Price**: $5 one-time (itch.io)
- **Verdict**: Still the strongest live-engine MCP option. Lite Mode (76 tools) available for clients with tool count caps. No new competing paid tool has emerged.
- **Citation**: https://y1uda.itch.io/godot-mcp-pro | https://godotengine.org/asset-library/asset/4961

#### godot-ai (hi-godot)
- **Role**: Free MIT-licensed MCP server; connects Claude Code, Codex, Cursor, Windsurf, and 15+ other clients to live Godot editor
- **Current version**: v2.8.2
- **Last release**: June 30, 2026 (one day before this report)
- **Features**: 150+ operations, ~41 MCP tools; covers scenes, nodes, scripts, animations, UI, materials, particles, cameras, audio, input mapping, project settings; one-click install via Asset Store
- **Verdict for this project**: Strongest free alternative to godot-mcp-pro. The tool count (41 tools, 150+ ops) is lower than godot-mcp-pro's 163, but it's free and actively shipping. Worth benchmarking if godot-mcp-pro causes pain.
- **Citation**: https://github.com/hi-godot/godot-ai | https://store.godotengine.org/asset/dlight/godot-ai/

#### IvanMurzak/Godot-MCP
- **Role**: Apache-2.0 C# editor plugin + cloud backend (ai-game.dev) bridging AI agents to Godot editor; also supports self-hosted
- **Current version**: v0.15.0 (June 2026)
- **Features**: 39 built-in MCP tools across 11 families; viewport screenshots that LLMs can analyze; runtime mode for in-game AI control; reflection escape hatch for arbitrary C# calls; .NET 8 required
- **Verdict for this project**: Skip — requires C#/.NET mono build; this project is GDScript-only. Cloud backend adds a dependency. Lower tool count than alternatives.
- **Citation**: https://github.com/IvanMurzak/Godot-MCP

#### Coding-Solo/godot-mcp
- **Role**: Lightweight MIT MCP server (npm: `@coding-solo/godot-mcp`) for launching the editor, running projects, capturing debug output, managing scenes and nodes
- **Features**: Bundled GDScript approach (single `godot_operations.gd` file); no version pinned but ~60 commits on main
- **Verdict for this project**: Simpler than godot-mcp-pro, worse coverage. Useful as a fallback or for CI headless runs. Not a replacement for live-engine debugging.
- **Citation**: https://github.com/Coding-Solo/godot-mcp

#### GDAI MCP
- **Role**: Free file-level MCP server; best-regarded for Cursor and Claude Desktop setup simplicity
- **Limitation**: File-level only — edits scripts and scenes but cannot run the game or read live runtime values
- **Verdict for this project**: Lower capability than godot-mcp-pro for a workflow that needs live engine access. Fine for pure script editing sessions.
- **Citation**: https://forum.godotengine.org/t/godot-free-open-source-mcp-server-addon/133890

---

### Build / Deployment Tooling

#### godot-ci (abarichello)
- **Role**: Docker image + GitHub Actions / GitLab CI templates for exporting Godot games and deploying to GitHub Pages / GitLab Pages / itch.io (via butler)
- **Current version**: 4.7-stable release (June 19, 2026)
- **Stars**: 1.1k | 164 forks — healthy community usage
- **Verdict for this project**: Yes — standard tool for this exact workflow. Updated same day as Godot 4.7 stable. Use when ready to automate itch.io deploys.
- **Citation**: https://github.com/abarichello/godot-ci

#### gdUnit4-action (GitHub Action)
- **Role**: GitHub Action for running GdUnit4 tests in CI pipelines; generates HTML/JUnit reports
- **Verdict for this project**: Pair with GdUnit4 if you adopt it for CI. Not needed if staying with GUT.
- **Citation**: https://github.com/MikeSchulze/gdUnit4-action

---

### Profiling / Debug Tools

#### Built-in Godot 4.6+ Profiler
- **Role**: Debugger panel (now floatable as of 4.6) — script profiler, monitors, visual profiler
- **2026 note**: Godot 4.6 added Tracy / Perfetto / Apple Instruments tracing support for microsecond-level engine internals. 4.7 dev added folding to Visual Profiler tree.
- **Verdict**: Use the built-in first; no plugin needed for 2D platformer profiling.
- **Citation**: https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html

#### godot-debug-menu (Calinou / godot-extended-libraries)
- **Role**: In-game overlay showing FPS, frametime graphs (best/worst/avg over 150 frames), CPU/GPU time, hardware info; F3 cycles display modes; works in exported builds
- **Current version**: 1.2.0 (Dec 2023 original; Antz's Debug Menu fork updated June 12, 2026)
- **Verdict for this project**: Low-effort install, high value for frame-pacing QA in a platformer. Add when doing game-feel passes. Works in exported builds unlike editor-only profiler.
- **Citation**: https://github.com/godot-extended-libraries/godot-debug-menu

---

## Noteworthy Newcomers (First Release in 2026)

| Tool | What It Is | Date | Notes |
|------|-----------|------|-------|
| godot-ai (hi-godot) | Free MCP server, 150+ ops, Asset Store one-click | Active all 2026; v2.8.2 Jun 30 2026 | 76 total releases — rapid iteration |
| Godot AI Assistant (champ-gaming) | In-editor AI chat assistant | Listed on new Asset Store 2026 | Different from godot-ai MCP; generates GDScript/scene files from prompts |
| Godot official Asset Store | New storefront replacing editor's Asset Library | Launched with Godot 4.7, June 2026 | Discoverable from editor; MCP/AI now a visible category |

---

## Key Context

- **Godot contribution policy (2026)**: AI-authored code is banned from engine contributions. Does not affect game projects or plugins using AI tooling.
- **GodotCon Boston (July 20-22, 2026)**: Upcoming — watch for tooling announcements post-conference.
- **Project engine gap**: Project is on 4.6.2; current stable is 4.7. GUT 9.7.0 targets 4.7.x; GdUnit4 v6.1.3 supports 4.5–4.7; godot-ai requires 4.3+. No blocking upgrade concerns for any tooling listed here.
