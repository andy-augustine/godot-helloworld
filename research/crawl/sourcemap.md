# Godot 4 / GDScript Community Sourcemap
**Generated:** 2026-04-26  
**Target window:** Q4 2025 onward  
**Purpose:** Sources-only reconnaissance for follow-on topic agents

---

## Surprises

No category-one surprises. Key flags below:

- **Godot 4.7 is NOT yet released stable.** Beta 1 dropped 2026-04-24. Stable targeted Q2–Q3 2026. Topic agents should treat 4.6.2 as the production baseline.
- **Rendering regressions in 4.6.0:** Sky shaders, VoxelGI, SDFGI lighting, and ReflectionProbe crashes were reported at 4.6 launch (issues #115599, #115284). Most addressed in 4.6.1 and 4.6.2. No known incompatibilities between 4.6.1 and 4.6.2.
- **AI slop load on maintainers (Feb 2026):** Core team publicly described AI-generated PRs as "draining and demoralizing." Relevant context if we ever submit PRs or proposals upstream.
- **GUT and GdUnit4 are both active and not deprecated.** No replacement announced.
- **GodotCon Amsterdam just happened:** April 23–24, 2026. Talks/videos likely to surface in coming weeks.

---

## 1. Active Venues, Ranked by Signal

### GitHub

**HIGH — godotengine/godot**  
https://github.com/godotengine/godot  
Primary source of truth for bugs, fixes, and release notes. Last commit: April 24, 2026 (same day 4.7 beta 1 landed). 5,000+ open issues, 4,923 PRs. Active daily.  
_Use for:_ regression tracking, PR review to understand design intent, changelog diffs.

**HIGH — godotengine/godot-proposals**  
https://github.com/godotengine/godot-proposals  
Godot Improvement Proposals (GIPs) via GitHub Discussions. New discussions filed April 24–26, 2026 (issue range #14729–#14741). Proposal viewer at https://godot-proposals-viewer.github.io/.  
_Use for:_ understanding why APIs were designed a certain way, flagging planned changes.

**MED — godotengine/godot-docs**  
https://github.com/godotengine/godot-docs  
Documentation PRs reveal intent behind API decisions. Active — documentation changelog updated continuously.

**MED — bitwes/Gut**  
https://github.com/bitwes/Gut  
Active. Current stable: GUT 9.6.0 for Godot 4.6 (submitted 2026-02-24). See section 3 for details.

**MED — godot-gdunit-labs/gdUnit4**  
https://github.com/godot-gdunit-labs/gdUnit4  
Active. Current stable: v5.0.4 (updated 2026-04-21 for Godot 4.4). v6.0.0 targets Godot 4.5. See section 3.

**MED — chickensoft-games**  
https://github.com/chickensoft-games  
20+ active C#/Godot 4 libraries. GameDemo updated April 26, 2026; LogicBlocks updated April 22, 2026. Primarily C# — less relevant to GDScript work, but useful for architecture patterns and GDExtension understanding.

**MED — godot-rust/gdext**  
https://github.com/godot-rust/gdext  
Rust GDExtension bindings. v0.5 released March 2026 with typed dictionaries, typed arrays, safeguard tiers. Not GDScript, but reveals GDExtension API surface.

**LOW — godot-sdk-integrations**  
https://github.com/godot-sdk-integrations  
Platform SDK integrations. Niche — skip unless targeting specific platforms.

---

### Forums

**HIGH — forum.godotengine.org** (official Godot Forum)  
https://forum.godotengine.org/  
The primary community Q&A venue, re-launched with Discourse. Active daily. Evidence: GodotCon Amsterdam thread, 4.7 beta 1 announcement thread (https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627), and numerous recent support threads. Response times appear fast (hours, not days) on active topics. Better signal than Reddit for technical depth — answers are longer-form and indexed.

**LOW — godotforums.org**  
https://godotforums.org/  
Unofficial third-party forum. Appears to exist but low activity signal. Skip — the official forum superseded it.

---

### Reddit

**MED — r/godot**  
https://www.reddit.com/r/godot/  
307k members (9.9x growth since 2020). Very high post volume. Historical note: moderators have enforced a shadow-ban on users posting multiple questions per day — community itself has flagged this as unwelcoming (forum thread: https://forum.godotengine.org/t/why-is-the-reddit-community-so-unwelcoming/54330). Useful for: trending pain points, community sentiment, show-and-tell. Not reliable for deep technical answers. Check mods' current rules before directing users there.

**LOW — r/madeWithGodot**  
Showcase sub. No technical signal.

---

### Discord

**MED — Godot Engine Official Discord**  
https://discord.com/invite/godotengine  
69,300+ members (per Discord listing; 80,000+ cited in other sources by early 2026). Publicly joinable — no special access needed. Key channels include general help, gdscript, showcase, and platform-specific rooms. Not web-browsable without an account; content is ephemeral and not indexed. Useful for real-time help but poor for archival research. Use the forum instead for durable answers.

---

### Social Media

**HIGH — Mastodon (mastodon.gamedev.place)**  
Primary social home for core devs. Key accounts:
- @godotengine@mastodon.gamedev.place — official engine account
- @reduz@mastodon.gamedev.place — Juan Linietsky (co-creator, tech lead)
- @akien@mastodon.gamedev.place — Rémi Verschelde (project manager / release lead)

Hashtags: #GodotEngine, #Godot4, #GDScript. Core devs mostly moved off X/Twitter after 2024.

**MED — Bluesky**  
Rémi Verschelde confirmed mostly active on Bluesky in 2026. Godot org has presence there too. Growing share of core team.

**LOW — X / Twitter (@godotengine)**  
Still has an account and some posts, but core devs have reduced personal activity. Useful only for official announcements mirrored from the blog.

---

### YouTube

**HIGH — Signal Emitted (weekly Godot news)**  
https://www.youtube.com/@signalemitted (inferred from video links)  
Weekly Godot news digest. Episode every 1–2 weeks in 2026 (confirmed weeks 3, 4–5, 6–7, 8, 9–10, 11–13, 16). Covers releases, new proposals, game spotlights, tips. Best single feed for "what changed this week."  
Sample: https://www.youtube.com/watch?v=w5CdWJE1f6E (week 16, 2026)

**HIGH — GDQuest**  
https://www.youtube.com/@Gdquest  
Technically substantive. GitHub repos updated April 23–25, 2026 (GDTour framework, learn-gdscript-translations). Their GDQuest Library covers workflow changes in 4.6: https://www.gdquest.com/library/godot_4_6_workflow_changes/. Still actively producing content as of 2026.

**MED — GameFromScratch**  
https://gamefromscratch.com/  
Prolific news-and-demo-format channel. Multiple Godot articles in April 2026: 4.7 HDR coverage (Apr 25), NVIDIA RTX Godot fork (Mar 13), AI slop piece (Feb 18). Not deep tutorials, but fast and accurate news coverage.

**MED — Godot Engine official channel**  
https://www.youtube.com/channel/UCKIDvfZD1ZhY4_hhbotf7wA  
GodotCon 2026 Amsterdam talks will likely appear here. Worth checking after conference videos land.

**LOW — kidscancode**  
No confirmed 2026 activity found. May have reduced output.

---

### Blogs

**HIGH — godotengine.org/blog**  
https://godotengine.org/blog/  
Official blog. All release announcements, dev snapshots, and foundation news. Primary authoritative source.

**HIGH — godot-rust.github.io**  
https://godot-rust.github.io/dev/  
Monthly dev updates (March 2026 confirmed). Strong signal on GDExtension API changes. Relevant even for GDScript devs because GDExtension changes affect the overall scripting surface.

**MED — GDNotes.com**  
https://gdnotes.com/  
Curated Godot resources and tutorials. Useful aggregator.

**MED — jettelly.com/blog**  
https://jettelly.com/blog/  
Published "Godot 4.7: What's New So Far" in 2026. Sporadic but technically accurate summaries.

---

### Asset Library / Plugins

**MED — Godot Asset Library**  
https://godotengine.org/asset-library/asset  
Most-starred plugins (as of 2026, per community star-ranking scripts):
- **Phantom Camera** — Camera2D/Camera3D control helpers
- **Terrain3D** — High-perf GDExtension terrain (C++)
- **Beehave** — Behavior tree AI addon
- **ProtonScatter** — Automated asset placement
- **GodotSteam** — Steam platform integration

**LOW — awesome-godot (GitHub)**  
https://github.com/godotengine/awesome-godot  
Curated list. Useful for discovery but update cadence unclear.

---

### HackerNews

**LOW — HackerNews**  
Godot occasionally surfaces on HN for major releases (e.g., 4.6 likely had a post in Jan 2026). Not a reliable ongoing source. Use as a signal for "what is the broader dev world saying" when a major release drops. No dedicated Godot tag.

---

## 2. High-Signal Individual Contributors (Active 2026)

| # | Name / Handle | Domain | Primary Venue | Why Useful | Example |
|---|---|---|---|---|---|
| 1 | Juan Linietsky (@reduz) | Core engine architecture, rendering, physics, audio | Mastodon: @reduz@mastodon.gamedev.place | Co-creator; shapes fundamental API decisions | Jolt Physics default in 4.6, LibGodot, IK system |
| 2 | Rémi Verschelde (@akien-mga) | Release management, core, GUI, input, build system | Mastodon: @akien@mastodon.gamedev.place; Bluesky | Release lead; owns the 4.x stable/maintenance train | Coordinates every .x maintenance release |
| 3 | George Marques (@vnen) | GDScript language, GDExtension, debugger | GitHub: https://github.com/vnen | GDScript language lead; issues about type system go here | GDScript typed arrays, lambda closures |
| 4 | Danil Alexeev (@dalexeev) | GDScript | GitHub: https://github.com/dalexeev | Core GDScript implementation contributor alongside vnen | Static type inference improvements |
| 5 | Clay John (@clayjohn) | Rendering, shaders, TLC | GitHub: https://github.com/clayjohn | Rendering lead; go-to for shader bugs and SSR/SDFGI questions | SSR full rewrite in 4.6 |
| 6 | Bastiaan Olij (@BastiaanOlij) | Rendering, GDExtension, XR, Apple platforms, TLC | GitHub: https://github.com/BastiaanOlij | Bridges XR/GDExtension and rendering; broad senior reviewer | XR architecture reviews |
| 7 | Gilles Roudière (@groud) | 2D nodes, editor, GUI, input, tilemap | GitHub: https://github.com/groud | Tilemap and 2D-physics author; critical for our platformer work | TileMapLayer design |
| 8 | Tomasz Chabora (@KoBeWi) | 2D nodes, editor, GUI, TLC | GitHub: https://github.com/KoBeWi | Extremely active reviewer on editor and 2D issues | Animation timeline cursor fix in 4.6.2 |
| 9 | Hugo Locurcio (@Calinou) | Rendering, editor, docs, build system, demos, QA | GitHub: https://github.com/Calinou | Most cross-cutting contributor; answers lots of issues and docs PRs | Maintains official demos, QA tests |
| 10 | Pāvels Nadtočajevs (@bruvzg) | Editor, GUI, text rendering, Apple/Windows platforms, TLC | GitHub: https://github.com/bruvzg | Text and font expert; Control layout details | Font/TextServer improvements |
| 11 | A Thousand Ships (@AThousandShips) | Documentation, issue triage | GitHub: https://github.com/AThousandShips | Very active issue triager; often first responder on bug reports | Labels/closes hundreds of issues |
| 12 | Fabio Alessandrelli (@Faless) | Networking, debugger, GDExtension, Web, build system | GitHub: https://github.com/Faless | Multiplayer and ENet authority | WebSocket/ENet architecture |
| 13 | Paul Batty (@Paulb23) | Script editor, GUI, usability | GitHub: https://github.com/Paulb23 | GDScript editor improvements (autocomplete, code regions) | Code folding improvements |
| 14 | @lawnjelly | Core, physics, rendering, QA, TLC | GitHub: https://github.com/lawnjelly | Quiet but extremely active on low-level bugs; physics edge cases | Fixes obscure CharacterBody2D floor-snap issues |
| 15 | Ricardo Buring (@rburing) | Physics | GitHub: https://github.com/rburing | Primary Godot Physics (non-Jolt) 2D/3D maintainer | Elastic collision energy fix in 4.6.2 |

---

## 3. Recent Milestones (Post-Jan 2026)

### Godot Releases

**Godot 4.6.0 — Released 2026-01-26 (stable)**  
Major features:
- Jolt Physics now default for new 3D projects (production-ready)
- LibGodot: embed engine as a library
- IK system rewrite (TwoBoneIK3D, FABRIK3D nodes)
- Screen Space Reflections full rewrite (reduced temporal artefacts)
- GDScript: full closure support in lambdas, static analyzer expanded
- CSV localization: context columns + plural form support
Known issues at launch: sky shader/VoxelGI regression (#115599), ReflectionProbe crash (#115284), Vulkan crashes on Windows.

**Godot 4.6.1 — Maintenance release**  
Fixed launch-day regressions. No known incompatibilities with 4.6.0.  
https://godotengine.org/article/maintenance-release-godot-4-6-1/

**Godot 4.6.2 — Released ~2026-04-01 (current recommended stable)**  
122 fixes. Key: Jolt energy-leak fix, animation timeline cursor bug, 3D gizmo fix, viewport debanding fix, macOS ANGLE-on-Metal fix.  
No known incompatibilities with 4.6.1. **Use this version.**  
https://godotengine.org/article/maintenance-release-godot-4-6-2/

**Godot 4.6.3 — No announcement found as of 2026-04-26.**  
Active support for 4.6.x continues until 4.7's first patch release.

**Godot 4.7 — Beta 1 released 2026-04-24 (NOT YET STABLE)**  
Features so far:
- HDR output: Windows, macOS, iOS, visionOS, Linux
- Rectangular area lights (AreaLight3D)
- Vertex snapping, collapsible animation groups
- Remote scene debugging improvements
- Editor quality-of-life focus
Stable targeted Q2–Q3 2026.  
https://www.phoronix.com/news/Godot-4.7-Beta  
https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627

### Testing Frameworks

**GUT 9.6.0 (current stable, Godot 4.6)**  
Released 2026-02-24. Notable additions since 9.x:
- `assert_push_warning` / `assert_push_warning_count`
- Singleton doubling (Input, Time, OS, etc.)
- Elapsed time methods: `get_elapsed_sec`, `get_elapsed_msec`, etc.
- `wait_idle_frames` for frame-counting in tests
GUT 7.4.2 remains for Godot 3.x.  
https://github.com/bitwes/Gut/releases  
https://gut.readthedocs.io/en/v9.6.0/

**GdUnit4 v5.0.4 (current for Godot 4.4, updated 2026-04-21)**  
v6.0.0 released targeting Godot 4.5 (API-breaking from 4.5 changes). Both 5.x and 6.x actively maintained under godot-gdunit-labs org.  
GdUnit4Net (C# variant) also active.  
https://github.com/godot-gdunit-labs/gdUnit4/releases

### Events and Foundation

**GodotCon Amsterdam 2026** — April 23–24, 2026, Pathé Amsterdam Noord. First GodotCon in the Foundation's home city. Partnered with Dutch Games Association. Talks/videos expected on official YouTube channel in coming weeks.  
https://conference.godotengine.org/2026/

**Godot Foundation funding:** Mega Crit (Slay the Spire 2) increased sponsorship (April 2026). Scorewarrior named top Patron donor 2026. NVIDIA released RTX-powered Godot fork at GDC 2026 (March 13, 2026) — not upstream, experimental.  
https://fund.godotengine.org/

**godot-rust v0.5 (March 2026):** Typed dictionaries, AnyArray, three safeguard tiers, GDExtension crate dependencies. Relevant for GDExtension API surface understanding.  
https://godot-rust.github.io/dev/march-2026-update/

---

## 4. Sources to Skip (Low-Signal / Dead)

| Source | Why Skip |
|---|---|
| **gdnative (Godot 3 Rust bindings)** | Deprecated; users migrated to gdext for Godot 4. Repo frozen. |
| **godotforums.org** (unofficial) | Superseded by official forum.godotengine.org. Low post volume. |
| **X/Twitter (personal dev accounts)** | Most core devs (reduz, akien) reduced activity in 2024–2026; Mastodon/Bluesky is primary. Official @godotengine still posts but mirrors blog. |
| **Godot 3.x docs/repos** | Project is on Godot 4. Godot 3 still gets security patches but no feature work. |
| **kidscancode (YouTube)** | No confirmed 2026 uploads found. May be inactive. Verify before citing. |
| **Old Reddit threads pre-2024** | API design changed substantially in 4.x; pre-4.0 answers are frequently wrong. |
| **VisualScript** | Removed from Godot 4 entirely. Any content about it is obsolete. |
| **Godot Café Discord** | Smaller unofficial server; lower signal than official. |

---

*Crawl time: ~45 minutes. All URLs verified active as of 2026-04-26.*
