# Godot 4 Community Sourcemap
*Generated: 2026-07-01 | Intel window: Jan 2026 – Jul 2026*

---

## Surprises

- **Godot 4.7 shipped June 18, 2026** — this is current stable; the project should target 4.7, not 4.6.
- **Official new Asset Store** launched with 4.7, replacing the old Asset Library in the editor.
- **AI contribution ban**: Godot officially prohibited AI-authored code contributions in early 2026 (see contribution policy below). Notable policy signal if using AI tooling in a PR workflow.
- **GodotCon Boston** is upcoming July 20-22, 2026 — watch for announcements.

---

## 1. Active Venues (ranked by signal)

### HIGH signal

**GitHub — godotengine/godot**
- URL: https://github.com/godotengine/godot
- Activity: 309 contributors / 1,265 fixes since 4.6-stable for 4.7 beta 1 (April 2026). 4.7 stable released June 18, 2026.
- Why useful: Primary source of truth for engine changes, bug tracking, release notes, and PR review patterns.
- Dated sample: 4.7 stable release June 18, 2026; 4.6.3 maintenance release May 21, 2026.

**GitHub — godotengine/godot-proposals**
- URL: https://github.com/godotengine/godot-proposals/discussions
- Activity: Ongoing discussions; active in 2026.
- Why useful: Where feature proposals are debated before implementation. Watch for 2D/physics/tilemap threads relevant to this project.

**Godot Forum (official)**
- URL: https://forum.godotengine.org
- Activity: Active in 2026; community growth thread posted May 2026 with stats going "steadily up."
- Why useful: Best Q&A signal after GitHub issues. Self-organized, indexed, persistent (better than Discord for search).
- Dated sample: Thread "Godot usage and engine growth 2026" posted May 2026.

**Reddit — r/godot**
- URL: https://www.reddit.com/r/godot
- Activity: Maintained by Godot Foundation; active 2026 posting.
- Why useful: High-volume community showcase and troubleshooting. Good for sentiment, plugin discovery, and "what are people building" signals.
- Note: Subreddit is officially maintained by the Godot Foundation.

**GDQuest (YouTube + tutorials)**
- URL: https://www.youtube.com/@Gdquest | https://www.gdquest.com
- Activity: Active in 2026 (appearing in best-courses roundups, tutorials indexed on site).
- Why useful: Best beginner-to-intermediate Godot 4 tutorial content; open-source demos; GDScript-first. Covers 2D platformer patterns directly relevant to this project.
- Note: "Godot Tours" interactive learning launched inside Godot editor — unique format.

**Godot Engine Blog (godotengine.org/article/)**
- URL: https://godotengine.org/article/
- Activity: Consistent release posts, dev snapshots, policy articles through 2026.
- Why useful: Primary source for release announcements, migration notes, contribution policy changes.
- Dated sample: Contribution policy 2026 article; 4.7 beta 1 April 2026; 4.7 stable June 2026.

### MED signal

**Godot Discord — Official**
- URL: https://discord.com/invite/godotengine
- Members: ~74,000 (as of 2026)
- Why useful: Fast real-time answers; channels for 2D, GDScript, editor. Not indexed well for search.
- Limitation: Ephemeral — answers disappear; prefer forum for persistent knowledge.

**Godot Discord — Godot Café (community-run)**
- URL: https://discord.com/invite/zH7NUgz
- Members: ~84,800 (largest Godot Discord)
- Why useful: More relaxed; good for community showcase and finding collaborators.

**Mastodon — @godotengine@mastodon.gamedev.place**
- URL: https://mastodon.gamedev.place/@godotengine
- Activity: 22,300 followers; actively maintained by Foundation.
- Why useful: Official announcements and dev updates, especially from devs who left Twitter/X.

**GodotCon Conference**
- URLs: https://conference.godotengine.org/2026/ | https://talks.godotengine.org/godotcon-boston-2026/cfp
- Events in 2026: Amsterdam (April 23-24, 2026, completed); Boston (July 20-22, 2026, upcoming); Munich (November 2026, announced).
- Why useful: Core dev talks, roadmap signals, networking. Recordings posted post-event.

**Jettelly blog**
- URL: https://jettelly.com/blog/
- Activity: Published 4.6 and 4.7 feature summaries in 2026 (multiple articles dated Jan-Jun 2026).
- Why useful: Solid mid-depth feature overviews with concrete details; good first stop before reading full changelogs.

**Phoronix (Linux game dev news)**
- URL: https://www.phoronix.com/news/Godot-4.7-Released
- Activity: Covered 4.7 release June 2026.
- Why useful: Quick release signal; Linux-angle coverage of each stable Godot release.

**KidsCanCode (kidscancode.org)**
- URL: https://kidscancode.org/godot_recipes/4.x/
- Activity: Recipes site still indexed; 2D platform character recipe is maintained for Godot 4.x.
- Why useful: Concise, well-structured recipes for common 2D patterns (CharacterBody2D, platforms, etc.). Direct relevance to this project.

### LOW / skip

**X/Twitter (@godotengine)**
- URL: https://twitter.com/godotengine
- Signal: Low — most core devs (including reduz) have reduced activity or left for Mastodon. Official account still exists but is secondary.

**godotforums.org (third-party)**
- URL: https://godotforums.org
- Signal: Low — separate unofficial forum; lower traffic than official forum.godotengine.org. Easy to confuse with the official one.

**Facebook groups**
- Signal: Low — outdated posts; community has largely moved to Discord and Reddit.

---

## 2. High-Signal Individual Contributors (~15)

| Handle | Domain | Primary Venue | Why Useful | Example |
|--------|--------|---------------|------------|---------|
| @reduz (Juan Linietsky) | Engine architecture, core systems | GitHub / Mastodon | Co-creator; still actively merges core PRs. Vision setter. | Lead on LibGodot (embedded engine) in 4.6 |
| @akien-mga (Rémi Verschelde) | Release management, project management | GitHub | Release manager; every stable release goes through him. Contribution policy author. | Authored 2026 AI contribution ban policy |
| @clayjohn (Clay John) | Rendering, shaders | GitHub | Rendering maintainer; SSR rewrite in 4.6, HDR output in 4.7 | Rewrote Screen Space Reflections for 4.6 |
| @vnen (George Marques) | GDScript, language | GitHub | GDScript language maintainer; if GDScript breaks, he fixes it | GDScript type system improvements across 4.x |
| @Calinou (Hugo Locurcio) | Docs, editor UX, CI | GitHub | Prolific reviewer; writes godot docs; great at catching regressions | godotengine.org website contributions; docs reviews |
| @BastiaanOlij | XR, OpenXR, rendering | GitHub | XR subsystem lead; Android XR in 4.7 | Steam Frame / Android XR support in 4.7 |
| @aaronfranke (Aaron Franke) | Math, geometry, file formats | GitHub | Deep geometry/math fixes; GLB/GLTF imports | Frequent author of precision-fix PRs |
| @KoBeWi (Tomasz Chabora) | Editor tools, 2D editor | GitHub | Editor behavior; 2D tilemap and editor UX fixes | Tilemap editor improvements |
| @dsnopek (David Snopek) | GDExtension, web export | GitHub | GDExtension and HTML5/web platform lead | Web export reliability fixes |
| @fire (K.S. Ernest Lee) | CI, build system, Godot org | GitHub | Keeps CI and build infra running; frequent triage | Build system improvements across releases |
| @bitwes | GUT testing framework | GitHub (bitwes/Gut) | Sole maintainer of GUT; responsive to issues; released 9.6.0 for Godot 4.6 in Feb 2026 | GUT 9.6.0: assert_push_warning, Godot 4.6 compat |
| @MikeSchulze | GdUnit4 testing framework | GitHub (MikeSchulze/gdUnit4) | Maintains GdUnit4 (GDScript + C# testing); CI/CD GitHub Action | gdUnit4 v6.x+ rebuilt for Godot 4.5+ API changes |
| @nathanhoad | Godot Dialogue Manager plugin | GitHub / forum | Most-used dialogue plugin for Godot 4; active in 2026 | Dialogue Manager widely referenced in 2026 plugin roundups |
| @segregate (GDQuest team) | Tutorials, open-source demos | YouTube / GitHub | GDQuest lead; produces the highest-quality Godot 4 tutorial content | Godot Tours interactive learning system |
| @jsingh (Chickensoft) | C# Godot architecture | GitHub (chickensoft-games) | Godot + C# tooling; GodotGame template, LogicBlocks state machines, AutoInject DI | SaveFileBuilder and GodotGame both updated June 10, 2026 |

---

## 3. Recent Milestones (Jan 2026+)

### Engine Releases

**Godot 4.6 — stable released January 26, 2026**
- Source: https://godotengine.org/releases/4.6/ | https://digitalproduction.com/2026/01/28/godot-4-6-arrives-with-major-cg-friendly-updates/
- Key changes for this project:
  - New "Modern" theme default in editor
  - Editor docks/panels now movable and floatable
  - Jolt Physics now default for new 3D projects
  - LibGodot: embed engine in other apps
  - Nodes get unique internal IDs (scene refactor tracking)
  - Screen Space Reflections rewrite
  - Delta encoding for patch PCKs (smaller updates)

**Godot 4.6.3 — maintenance release May 21, 2026**
- Source: https://gamedev.net/news/3473/
- 86 fixes from 41 contributors
- Covers: 2D/3D editor behavior, animation crashes, Android/iOS export, C# deps, input quirks, physics overlap, rendering fixes.

**Godot 4.7 — stable released June 18, 2026** ← CURRENT STABLE
- Sources: https://www.gamingonlinux.com/2026/06/godot-engine-4-7-is-out-bringing-a-new-asset-store-hdr-support-steam-frame-support/ | https://www.phoronix.com/news/Godot-4.7-Released | https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/
- 1,265 fixes from 309 contributors since 4.6-stable
- Key features:
  - **HDR output support**
  - **New official Asset Store** (replaces Asset Library in editor; threaded background loading)
  - **AreaLight3D** — rectangular light source node
  - **Steam Frame + Android XR** support
  - **DrawableTexture2D** — draw on a texture at runtime
  - Virtual joysticks built in
  - Collapsible animation tracks
  - Vertex snapping, Path3D collider snapping
  - Searchable popups, category-level property copy/paste

### Testing Frameworks

**GUT 9.6.0 — released February 24, 2026**
- Source: https://github.com/bitwes/Gut/releases | https://gut.readthedocs.io/
- Compatible with Godot 4.6
- New: `assert_push_warning`, `assert_push_warning_count`; ability to double Godot Singletons (Input, Time, OS); push_warning no longer fails tests unexpectedly
- Note: GUT 9.x = Godot 4.x; GUT 7.4.2 = Godot 3.x

**GdUnit4 v6.x+ (2026)**
- Source: https://github.com/MikeSchulze/gdUnit4 | https://github.com/MikeSchulze/gdUnit4/releases
- Rebuilt for Godot 4.5+ API (breaking API change required full rebuild from v5.x)
- Supports GDScript and C#; CI/CD GitHub Action available: https://github.com/MikeSchulze/gdUnit4-action
- v7.0.0 referenced as in-development milestone

### Community / Ecosystem

**GodotCon Amsterdam — April 23-24, 2026 (completed)**
- Source: https://godotengine.org/article/godotcon-2026/ | https://tickets.godotengine.org/foundation/godotcon-ams-2026/
- Partnered with Dutch Games Association

**GodotCon Boston — July 20-22, 2026 (upcoming)**
- Source: https://conference.godotengine.org/ | https://talks.godotengine.org/godotcon-boston-2026/cfp
- CFP open; workshops July 20, talks July 21-22

**GodotFest Munich — November 2026 (announced)**
- Source: https://www.gamesmarket.global/godotfest-munich-returns-november-2026/

**Godot Contribution Policy (2026)**
- Source: https://godotengine.org/article/contribution-policy-2026/
- AI-authored code **explicitly banned** from the Godot engine repo
- New contributors (<3 merged PRs) must fix bugs before submitting features
- Rationale: growing AI-slop PR volume overwhelming volunteer reviewers

**Godot Vision Statement 2026**
- Source: https://godotengine.org/article/godot-vision-statement-2026/
- Stated focus: small-to-medium teams; no paid tiers; completeness over breadth; reliability over feature count

**Godot AI / MCP tooling ecosystem (2026)**
- **Godot MCP Pro** (used in this project): 163 tools, 23 categories — https://godotengine.org/asset-library/asset/4961
- **Godot AI plugin**: MCP-compatible, 150+ operations — https://godotengine.org/asset-library/asset/5050
- Both listed on new Asset Store; MCP tooling for Godot editors is a new active category in 2026

### Notable Plugin Releases (2026)

- **Godot Dialogue Manager** — widely cited in 2026 roundups; maintained by @nathanhoad
- **Chickensoft suite updated June 10, 2026**: GodotGame template, GameDemo, SaveFileBuilder — https://github.com/chickensoft-games
- **awesome-godot** curated list: https://github.com/godotengine/awesome-godot (maintained)

---

## 4. Dead / Low-Signal Sources to Skip

| Source | Reason |
|--------|--------|
| X/Twitter @godotengine | Most core devs on Mastodon; official account secondary; noise ratio high |
| godotforums.org | Third-party, low traffic; easy to confuse with official forum |
| Facebook Godot groups | Outdated; community has moved on |
| YouTube: kidscancode channel | Site recipes are maintained but YouTube channel has low 2026 activity; prefer kidscancode.org recipe pages directly |
| Any Godot 3.x resources | Engine is Godot 4.4+; GDScript and scene APIs differ substantially |
| LLM-generated "Godot tutorials" (Medium, etc.) | Many 2026 Medium posts are low-quality LLM output; verify against official docs |

---

## 5. Key URLs Quick Reference

| Resource | URL |
|----------|-----|
| Official docs (stable = 4.7) | https://docs.godotengine.org/en/stable/ |
| Interactive changelog | https://godotengine.github.io/godot-interactive-changelog/ |
| GDQuest tutorials | https://www.gdquest.com/tutorial/godot/ |
| KidsCanCode Godot 4 recipes | https://kidscancode.org/godot_recipes/4.x/ |
| GUT docs | https://gut.readthedocs.io/ |
| GUT releases | https://github.com/bitwes/Gut/releases |
| GdUnit4 repo | https://github.com/MikeSchulze/gdUnit4 |
| Chickensoft org | https://github.com/chickensoft-games |
| awesome-godot | https://github.com/godotengine/awesome-godot |
| Godot proposals | https://github.com/godotengine/godot-proposals/discussions |
| godot-prs-by-file | https://godotengine.github.io/godot-prs-by-file/ |
| Asset Store (new, 4.7) | https://store.godotengine.org/ |
| Asset Library (legacy) | https://godotengine.org/asset-library/asset |
| GodotCon Boston 2026 | https://conference.godotengine.org/ |
| Godot Foundation | https://godot.foundation/ |
