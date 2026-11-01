# Godot Tooling — What's New Since October 2026

**Crawl date:** 2026-11-01  
**Window:** 2026-10-01 and recent prior context (Godot 4.7/4.8 era)

---

## TL;DR — Top 3 Findings

1. **GdUnit4 jumped to v6.x** — not v5.1.0 as the pre-scan expected. v6.2.2 (latest stable, Oct 7, 2026) targets Godot 4.8 dev builds. Full stack traces, reworked Inspector, orphan-node detail reporting, and CLI improvements landed across v6.1–6.2. This is a significant momentum shift vs. GUT.

2. **godot-agent-loop is a serious new MCP entrant (July 2026)** — MIT-licensed, installs via npm, requires Godot 4.7+. v3.0.0 (Aug 4) restructured to 16 default tools + 40 hidden. Includes a `game_performance` profiler audit and `analyze_project_integrity`. More tooling surface than any previously cataloged alternative.

3. **A wave of in-editor AI plugins arrived in early 2026** — GodotAI (Mar), Godot AI (Apr), Gamedev AI (Apr) all landed on the Asset Library. All support Claude/GPT/Gemini; one supports Ollama. These run inside the stock Godot editor (no external IDE required), but given the July 2026 AI-code-ban sentiment in the community, adoption is cautious.

---

## Per-Tool Entries

### GUT (bitwes/Gut)

| Field | Value |
|---|---|
| Role | GDScript unit testing framework (embedded in editor) |
| Current version | v9.7.1 |
| Last release date | July 10, 2026 |
| Target engine | Godot 4.7.x |
| Repo | https://github.com/bitwes/Gut |

**Recent changes (v9.7.x):**
- v9.7.0 (Jun 19): Godot 4.7 compatibility. **Breaking:** doubles now return the default value for their declared return type instead of `null` — existing tests may silently change behaviour. `stub().to_do_nothing()` returns the typed default.
- v9.7.1 (Jul 10): Fixed double-parsing errors on some OS (GH-841); fixed "Compiler bug: Unresolved return" during double generation (GH-842).
- No changelog was published for v9.7.1 on the Asset Store — check GitHub releases directly.

**Should we look into it?** We already use GUT. These are maintenance releases, not feature drops. The `null`→default stub change is the one migration risk when upgrading from 9.6.x — audit any stubs that previously relied on `null` returns.

---

### GdUnit4 (MikeSchulze/gdUnit4)

| Field | Value |
|---|---|
| Role | Full-featured unit testing framework; GDScript + C# |
| Current stable | v6.2.2 |
| Last release date | October 7, 2026 |
| Pre-scan expected | v5.1.0 RC4 — this was wrong; a major version jump happened |
| Repo | https://github.com/MikeSchulze/gdUnit4 |

**Recent changes (2026 v6.x series):**
- v6.1.0 (Jan 27): Godot 4.6 upgrade, variadic `assert_signal`, "run until failure" context menu, rebuilt command execution, orphan detection.
- v6.2.0 (Jul 28): Reworked Inspector UI, full stack traces in failure reports, orphan node details, `is_valid()` on `GdUnitObjectAssert`, signal crash and spy/mock crash fixes.
- v6.2.2 (Oct 7): Fixes for orphan reporting (queued-free children), console suite status, large-string diff OOM, and CI upgraded to Godot 4.8 dev7.

**Should we look into it?** Worth a second look for CI scenarios — the CLI runner, JUnit XML output, and full stack traces are ahead of GUT's reporting. The v6 jump is substantial but GDScript API is stable. If automated test reports in CI matter to us, GdUnit4 is now clearly ahead on tooling breadth.

---

### godot-agent-loop (beremaran)

| Field | Value |
|---|---|
| Role | MCP server — full agent loop for Godot 4 (scene, script, profiler, integrity audits) |
| Current version | v3.0.0 (Aug 4, 2026); v1.0.0 tagged earlier |
| Last release date | August 4, 2026 |
| License | MIT |
| Install | `claude mcp add godot-agent-loop -- npx -y @beremaran/godot-agent-loop@1.0.0` |
| Requires | Godot 4.7+ |

**Capabilities:** 16 default tools + 40 hidden-catalog tools. Includes `game_performance` (live + static profiler audit), `analyze_project_integrity`, scene/script/asset generation, and verified profiler/leak/localization/accessibility audits.

**Should we look into it?** Maybe — it covers profiling ground that godot-mcp-pro doesn't. However: (a) v3.0.0 reorganized the surface significantly and community adoption data is thin; (b) it requires npm-based install alongside our existing node-based godot-mcp-pro. Low priority unless we hit a profiling or audit gap.

---

### gdt (monkeymonk/gdt)

| Field | Value |
|---|---|
| Role | Go CLI — Godot Developer Toolchain (version manager, export automation, CI config gen) |
| Current version | v0.2.2 |
| Last release date | July 21, 2026 |
| License | MIT |
| Install | `go install github.com/monkeymonk/gdt/cmd/gdt@latest` (requires Go 1.25+) |

**Capabilities:** Manages engine versions and export templates, `gdt export [preset]` with debug/verbose flags, plugin hooks (before_export/after_export), LSP/DAP proxy for AI tools, generates CI configs for GitHub Actions / GitLab CI / shell script.

**Should we look into it?** Low priority for now. We don't have CI export pipelines yet. Useful when we hit that need — check again at v1.0.

---

### GodotAI / Godot AI / Gamedev AI (in-editor AI plugins)

| Tool | Version | Date | License |
|---|---|---|---|
| GodotAI (PurpleJelly) | 1.0.0 | Mar 16, 2026 | Proprietary |
| Godot AI | 0.1.0 | Apr 2026 | MIT |
| Gamedev AI | (unlisted) | Apr 2026 | MIT |

**Role:** Chat panels docked inside the Godot editor that can insert code into open scripts, add nodes, fix console errors. Support Claude/GPT/Gemini; Godot AI also supports Ollama.

**Should we look into it?** No — we use Claude Code + godot-mcp-pro externally, which has more control. These are editor-internal tools with less agentic reach. The AI-code-ban sentiment in the Godot community (July 2026) also means AI-generated code carries reputation risk in open-source contributions from this project.

---

### better-godot-mcp / godot-mcp (community servers)

| Tool | Approach | License | Notes |
|---|---|---|---|
| better-godot-mcp (n24q02m) | 17 mega-tools (TypeScript) | — | Small community, consolidates common ops |
| godot-mcp (tugcantopaloglu) | Autoload on 127.0.0.1:9090, JSON | MIT | Runtime control |
| godot-mcp (tomyud1) | 42 tools, 6 categories | — | Scene + script + asset gen |
| godot-ai (hi-godot) | FastMCP Python, 39 tools / 120+ ops | MIT | EditorInterface + SceneTree APIs |

**Should we look into them?** No action needed. These are alternatives to godot-mcp-pro we already evaluated. No new entrant clearly surpasses godot-mcp-pro's 162-tool surface for GDScript-only projects.

---

## Noteworthy Newcomers (first release 2026)

| Tool | Type | First Release | Why Notable |
|---|---|---|---|
| godot-agent-loop | MCP server | ~Jul 2026 | Profiler/audit tools; 173 tested tools at v1.0; npm-installable |
| gdt | CLI (Go) | Mar 2026 (v0.1.x) | Version mgr + export automation + CI gen; v0.2.2 Jul 2026 |
| GodotAI (PurpleJelly) | Editor AI plugin | Mar 16, 2026 | First proprietary in-editor LLM panel on Asset Library |
| Godot AI (MIT) | Editor AI plugin | Apr 2026 | Ollama support + editor actions (add nodes, create files) |

---

## Sources

- https://github.com/bitwes/Gut/releases
- https://github.com/MikeSchulze/gdUnit4/releases
- https://gut.readthedocs.io/en/v9.7.0/
- https://store.godotengine.org/asset/bitwes/gut/
- https://packages.nuget.org/packages/gdUnit4.api/5.1.0-rc5
- https://enterprisedna.co/directories/mcp/n24q02m-better-godot-mcp
- https://cdn.jsdelivr.net/gh/beremaran/godot-agent-loop@main/README.md
- https://github.com/beremaran/godot-agent-loop/releases/tag/v1.0.0
- https://pkg.go.dev/github.com/monkeymonk/gdt
- https://www.summerengine.com/blog/best-ai-tools-for-godot
- https://www.sourcepulse.org/projects/29675853 (godot-ai)
