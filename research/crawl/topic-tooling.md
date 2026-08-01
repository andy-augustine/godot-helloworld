# Godot Tooling — New Since July 2026

**Crawled:** 2026-08-01  
**Window:** July 2026 onward (prior crawl through ~July 1, 2026)  
**Project context:** GDScript-only Metroidvania, Godot 4.7.1, Claude Code + godot-mcp-pro

---

## TL;DR — Top 3 Findings

1. **hi-godot/godot-ai is now the dominant free MCP alternative** — 1.4k stars, 120+ editor operations, MIT, v3.0.7 shipped July 25, 2026; it offers a clear upgrade path away from godot-mcp-pro's $5 paywall.
2. **GDAgent launched as a paid in-editor AI terminal workspace** with a bundled MCP server and multi-agent support (Claude Code, Codex, Antigravity CLI) — a new category distinct from standalone MCP servers, Godot 4.6+ required, paid after 7-day trial.
3. **Two new E2E testing tools arrived in July 2026** — godot-e2e (out-of-process, no engine mods, GDScript addon + Python/pytest) and PlayGodot (Playwright-style Python, requires custom Godot fork) — neither replaces GUT for unit tests but fills a gap for integration-level testing.

---

## Per-Tool Entries

### Testing Frameworks

**GUT (Godot Unit Testing)**  
- Role: GDScript-native unit testing, the community standard  
- Version: v9.7.1 — July 10, 2026 (no new release since)  
- Godot compat: 4.6.1–4.7.1 confirmed  
- Verdict: **KEEP — our primary test tool.** No action needed; v9.7.1 stable on 4.7.1.  
- Citation: https://github.com/bitwes/Gut/releases (fetched 2026-08-01)

**GdUnit4**  
- Role: Embedded testing framework for GDScript + C#, richer CI integration than GUT  
- Version: v6.2.0 — July 28, 2026 (no new release since)  
- Godot compat: 4.5–4.7.1 (confirmed via compatibility matrix in repo)  
- Notes: Reworked inspector UI; full error stack traces; orphan node detection. Marked "unstable" on Asset Store (new major version label, not a quality issue). Requires Godot 4.5+ — a blocker if the project stays on 4.6.x, but fine for 4.7.1.  
- Verdict: **WORTH EVALUATING** for CI pipelines where full stack traces and orphan node detection matter; not a replacement for GUT in our workflow but complementary.  
- Citation: https://github.com/godot-gdunit-labs/gdUnit4/releases | https://store.godotengine.org/asset/mikeschulze/gdunit4-unit-testing-framework/ (fetched 2026-08-01)

**godot-e2e**  
- Role: Out-of-process E2E testing — GDScript addon + Python/pytest client  
- Version: v1.2.x — Godot 4.5+, Python 3.9+  
- Stars: 17  
- Notes: No engine modifications required; game runs in a separate process (crash-safe); synchronous Python API (no async/await in tests). Forum thread opened July 2026. Fills the integration-test gap that GUT's unit-test model leaves open.  
- Verdict: **WATCH — promising new approach for integration tests**, but very low star count and early. Revisit in 3 months.  
- Citation: https://github.com/RandallLiuXin/godot-e2e | https://forum.godotengine.org/t/godot-e2e-out-of-process-e2e-testing-for-godot-using-python-and-pytest/141476 (2026-07)

**PlayGodot**  
- Role: "Playwright for Godot" — Python-based E2E automation via Godot's debugger protocol  
- Version: v0.5.0 Beta (v1.0.0 on roadmap)  
- Stars: 37  
- Notes: Requires a custom Godot fork (automation branch). Language is Python, not GDScript — by design. No GDScript test writing.  
- Verdict: **SKIP for now.** Custom fork requirement is a dealbreaker for our workflow; no GDScript-native test authoring.  
- Citation: https://github.com/Randroids-Dojo/PlayGodot (fetched 2026-08-01)

---

### MCP / AI Editor Integration

**hi-godot/godot-ai**  
- Role: Free, production-grade MCP server for Godot — builds scenes, edits nodes/scripts, wires signals, configures UI/animations/particles  
- Version: v3.0.7 — July 25, 2026 (v3.0.0 released July 13; rapid cadence)  
- Stars: 1.4k | License: MIT | Install: snap, Asset Library, or GitHub ZIP  
- Supports: Claude Code, Codex, Grok Build, Antigravity, 17+ MCP clients  
- Notes: 120+ operations across ~43 MCP tools. 690 commits, active. Free alternative to godot-mcp-pro. Available on legacy Asset Library.  
- Verdict: **HIGH PRIORITY — evaluate as a free replacement for or supplement to godot-mcp-pro.** Active development, large star count for a Godot MCP tool.  
- Citation: https://github.com/hi-godot/godot-ai | https://pypi.org/project/godot-ai/ (fetched 2026-08-01)

**mkdevkit/godot-mcp**  
- Role: Open-source MCP server, 173 tools across 26 categories, native UndoRedo integration, runtime IPC inspection  
- Version: unknown (4 commits on master as of research date)  
- Stars: 7 | License: MIT  
- Notes: Listed on Godot Asset Library (submitted 2026-07-28). Very new — essentially a one-person weekend project at this stage. More tools on paper than godot-mcp-pro (173 vs 162), but far less proven.  
- Verdict: **SKIP for now** — too new, too few users to trust in production. Revisit if stars grow above 100.  
- Citation: https://github.com/mkdevkit/godot-mcp | https://godotengine.org/asset-library/asset/5245 (2026-07-28)

**GDAgent**  
- Role: Paid native AI terminal workspace embedded in the Godot editor; bundles its own MCP; multi-agent split-view (Claude Code, Codex, Antigravity, OpenCode, Aider, Copilot CLI, Mistral Vibe)  
- Version: updated June 29, 2026 on Asset Store  
- License: Commercial (7-day free trial, license required after)  
- Notes: Rust backend (no Electron/web views). Sessions/layouts persist across restarts. Godot 4.6+ required. Positions itself as "the IDE layer" rather than a standalone MCP server. Not yet available for Godot 4.4 or older.  
- Verdict: **INTERESTING — fills a different niche than bare MCP servers.** The trial is worth a test if multi-agent workflows become a pain point. Not urgent given our current godot-mcp-pro + Claude Code setup.  
- Citation: https://gdagent.dev/ | https://store.godotengine.org/asset/gdagent/gdagent/ (fetched 2026-08-01)

**Godot MCP Toolkit** (npgamedev)  
- Role: Editor plugin that connects AI coding assistants to the Godot editor (Asset Store listing)  
- Notes: Minimal public information; listed on new Asset Store. Distinct from the GitHub-based servers above.  
- Verdict: **SKIP — insufficient information to evaluate.**  
- Citation: https://store.godotengine.org/asset/npgamedev/godot-mcp-toolkit/ (2026-08-01)

---

### Build / CI / Export Tooling

**godot-ci** (abarichello)  
- Role: Docker image for headless Godot game exports; GitHub Actions + GitLab CI templates; deploys to GitHub Pages, itch.io  
- Stars: 1.1k | Last updated: ~3 months ago (approx. May 2026)  
- Notes: De-facto standard for Godot CI/CD. No breaking changes for 4.7 reported. Supports Android (custom keystores), Windows, macOS, Web. GdUnit4 integrates with its pipeline patterns.  
- Verdict: **ADOPT when CI becomes a priority.** Stable and well-documented; no urgency until we need automated exports.  
- Citation: https://github.com/abarichello/godot-ci (fetched 2026-08-01)

---

### Profiling

No new dedicated Godot profiling tools emerged in July 2026. The story remains: Godot's built-in Profiler dock (moveable since 4.6), Tracy/Perfetto/Apple Instruments support via custom engine builds (added in 4.6), and CSV export for offline analysis. No third-party profiler plugins have gained meaningful traction.

---

### Godot Asset Store (store.godotengine.org) — Notable Tools

Launched in Godot 4.7 (June 2026). Still relatively sparse vs. the legacy Asset Library, but notable tool-category entries as of August 2026:

- **GDAgent** (see above)
- **Godot MCP Toolkit** (see above)
- **GdUnit4** — listed; marked "unstable" label (new major version convention, not a quality flag)
- **GUT** — listed at https://store.godotengine.org/asset/bitwes/gut/
- **YARD (Yet Another Resource Database)** — runtime resource query system with table view editor
- **Terrain3D** — high-performance terrain system (not relevant for 2D but notable)
- **GodotSteam GDExtension** — Steam API integration

The new Asset Store's versioned-download and engine-version filtering (buyers get the build matched to their minor Godot version) is the headline workflow improvement for plugin consumers.

---

## Noteworthy Newcomers (first release or major milestone July 2026+)

| Tool | Milestone | Notes |
|------|-----------|-------|
| **hi-godot/godot-ai v3.0.7** | July 25, 2026 | Breakout free MCP server; 1.4k stars already |
| **mkdevkit/godot-mcp** | July 28, 2026 (Asset Library) | Very new 173-tool open MCP server; watch |
| **godot-e2e v1.2.x** | July 2026 | Out-of-process E2E; no engine mods; 17 stars |
| **GDAgent** | June 29, 2026 (Asset Store) | Paid in-editor AI terminal; new category |

---

*Sources: github.com/bitwes/Gut, github.com/godot-gdunit-labs/gdUnit4, github.com/hi-godot/godot-ai, github.com/mkdevkit/godot-mcp, github.com/Randroids-Dojo/PlayGodot, github.com/RandallLiuXin/godot-e2e, github.com/abarichello/godot-ci, gdagent.dev, store.godotengine.org, pypi.org/project/godot-ai, godotengine.org/asset-library, forum.godotengine.org, summerengine.com, linuxcompatible.org — crawled 2026-08-01.*
