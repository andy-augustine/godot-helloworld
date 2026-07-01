# Godot 4 Community Sourcemap
**Crawl date:** 2026-07-01
**Target window:** January 2026 – July 2026

---

## SURPRISE: Godot 4.7 Released June 18, 2026

Godot 4.7 stable is now the current release. Key changes affecting 2D/GDScript devs: built-in VirtualJoystick node, gyro controller aiming, DrawableTexture, new Asset Store replacing the Asset Library, HDR output on all desktop platforms (Linux requires Wayland). No regressions in input/GUI/2D rendering found for 4.6.x or 4.7 as of crawl date. GUT and GdUnit4 are both active — neither is deprecated.

---

## 1. Active Venues — Ranked by Signal Quality

### HIGH Signal

**GitHub: godotengine/godot**
- URL: https://github.com/godotengine/godot
- Activity: 4,600+ open PRs; daily commits through June 2026. 309 contributors contributed between 4.6 and 4.7-beta1 alone.
- Signal: Primary source of truth for engine behavior, bug reports, and feature PRs. Merge discussions reveal intent better than docs.
- Note (2026): Contribution policy tightened Feb 2026. New contributors restricted to bug fixes and docs before feature PRs. AI-authored code explicitly banned. Policy article: https://godotengine.org/article/contribution-policy-2026/

**GitHub: godotengine/godot-proposals**
- URL: https://github.com/godotengine/godot-proposals
- Activity: 4.7 milestone was 97% complete (129 closed, 3 open) as of May 2026. 5.0 milestone is open and active.
- Signal: Best place to understand what is coming. Proposals link to implementation PRs and carry maintainer commentary.
- Note: AI-written proposals explicitly prohibited, which keeps signal quality high.
- Discussions: https://github.com/godotengine/godot-proposals/discussions
- Milestones: https://github.com/godotengine/godot-proposals/milestones

**godotengine.org/blog**
- URL: https://godotengine.org/blog/
- Activity: Release articles for every milestone: 4.6 (Jan 26), 4.6.1 (Feb 16), 4.6.2 (Apr 1), 4.6.3 (May 20), 4.7 (Jun 18, 2026).
- Signal: Authoritative, written by maintainers. Every release article names contributors and highlights PRs.
- Releases index: https://godotengine.org/releases/4.7/

**Godot Interactive Changelog**
- URL: https://godotengine.github.io/godot-interactive-changelog/
- Activity: Updated with every release; maintained by YuriSizov.
- Signal: Searchable, filterable commit log by area (GDScript, Physics, Editor, etc.). Fastest way to confirm whether a specific bug was fixed or a feature landed in a given release.

**forum.godotengine.org**
- URL: https://forum.godotengine.org/
- Activity: Active June 2026. Recent example threads: "Godot usage and engine growth 2026" (May 2026); "Can Godot handle AAA fidelity in 2026?" (recent); active 4.7 migration Q&A.
- Signal: High for practical GDScript and node-system Q&A. Engine team monitors and responds here. Preferred over godotforums.org.

**GitHub: bitwes/Gut**
- URL: https://github.com/bitwes/Gut
- Activity: GUT 9.6.0 released 2026-02-24. Issue #799 filed 2026 for a null pointer regression in 4.6, showing active maintenance.
- Signal: Essential if you write GDScript tests. Changelog and issues are authoritative reference.
- Docs: https://gut.readthedocs.io/en/v9.6.0/
- Releases: https://github.com/bitwes/Gut/releases

**GitHub: MikeSchulze/gdUnit4 (org: godot-gdunit-labs)**
- URL: https://github.com/MikeSchulze/gdUnit4
- Activity: v5.0.4 released June 8, 2026. Compatible with Godot 4.0.3 through 4.7. Also available on new Asset Store.
- Signal: Active; supports GDScript and C#; has CI/CD GitHub Action in gdUnit4-action repo.
- Asset Store: https://store.godotengine.org/asset/mikeschulze/gdunit4/
- Releases: https://github.com/MikeSchulze/gdUnit4/releases

### MED Signal

**r/godot**
- URL: https://reddit.com/r/godot
- Activity: +82k members (31.2% growth). Maintained by the Godot Foundation. Active daily posting.
- Signal: Good for community sentiment, "made with Godot" showcases, beginner questions. Lower signal-to-noise than the forum for technical issues. Useful for discovering what problems newcomers hit most.
- Companion subreddit: r/madeWithGodot
- Stats: https://subredditstats.com/r/godot

**GitHub: chickensoft-games**
- URL: https://github.com/chickensoft-games
- Activity: Active 2026. NuGet packages updated through June 2026 (e.g., Chickensoft.Log.Godot 1.0.64; Chickensoft.GoDotTest 2.0.35).
- Signal: Med-High for C#/Godot devs. GodotEnv is useful for any project managing addon versions from CLI. GDScript-only projects: low relevance.
- Docs: https://chickensoft.games/docs

**GitHub: godotengine/godot-docs**
- URL: https://github.com/godotengine/godot-docs
- Activity: Continuously updated; community doc PRs accepted.
- Signal: Med for API nuances. Stable docs often lag behind master branch by a release cycle. Cross-check with the interactive changelog.

**GitHub: godotengine/awesome-godot**
- URL: https://github.com/godotengine/awesome-godot
- Activity: Updated within last week as of crawl date. Curated plugin list.
- Signal: Med for plugin discovery. High-star entries (recent): Phantom Camera (3.4k), Terrain3D (4k), ProtonScatter (2.9k), Script-IDE (1k).
- Weekly tracker: https://www.trackawesomelist.com/godotengine/awesome-godot/week/

**X/Twitter: @godotengine + #GodotEngine**
- URL: https://x.com/godotengine
- Activity: Posted 4.7 dev snapshots (March 2026), 4.7 stable (June 18, 2026). Community uses #GodotEngine and #godot4.
- Signal: Med for announcements; follow individual contributor accounts for higher signal.

**Mastodon: @godotengine@mastodon.gamedev.place**
- URL: https://mastodon.gamedev.place/@godotengine
- Activity: 1.02k posts, 22.3k followers. Juan Linietsky (@reduz@mastodon.gamedev.place) also active there.
- Signal: Med for official announcements without algorithm noise. gamedev.place is the highest-concentration Mastodon instance for Godot devs.

**GamingOnLinux**
- URL: https://www.gamingonlinux.com/
- Activity: Covered 4.6 (Jan 2026) and 4.7 (Jun 2026) on release day. Example: "Godot Engine 4.7 is out bringing a new Asset Store, HDR support, Steam Frame support."
- Signal: Med — reliable same-day release coverage with solid feature summaries.

**Phoronix**
- URL: https://www.phoronix.com/
- Activity: Covered 4.7 release with focus on Linux/Wayland HDR details.
- Signal: Med-Low for GDScript work; Med for platform and render backend specifics.

**HackerNews**
- URL: https://news.ycombinator.com/
- Activity: Active Godot threads in 2026: AI slop PR discussion (Feb 2026, https://news.ycombinator.com/item?id=47059779); "Show HN: Claude Code skills for Godot games" (Mar 2026, id=47400868); 4.6 launch.
- Signal: Med for meta-discussions about Godot's trajectory. Engine maintainers occasionally comment. Not useful for technical GDScript Q&A.

### LOW Signal

**Discord: Official Godot Server**
- Activity: 66k+ members, 22k+ online. Invite: https://discord.me/godotgamedevelopment
- Signal: Low for research — ephemeral, not indexed. High velocity for real-time help but poor for asynchronous reference.
- Note: The Godot Contributors Chat (RocketChat) is used by the core team for PR coordination. More relevant than Discord for following maintainer discussions.

**godotforums.org** (community-run, separate from official forum)
- URL: https://godotforums.org/
- Signal: Low — prefer forum.godotengine.org. Still active but audience is split.

**YouTube (general)**
- Signal: Low for reference (can't search within videos, content gets stale). High for visual onboarding. See specific channels in section 5.

---

## 2. High-Signal Individual Contributors (Active 2026)

1. **Juan Linietsky (@reduz)**
   - Domain: Lead developer — engine architecture, rendering, GDExtension, LibGodot
   - Links: https://github.com/reduz | https://mastodon.gamedev.place/@reduz | https://twitter.com/reduzio
   - Why useful: Co-creator of Godot; architectural decisions trace back to him. His PRs and comments explain design intent better than docs.
   - Example contribution: LibGodot embedded library mode (4.6); Vulkan ray tracing foundation (4.7).

2. **Remi Verschelde (@akien-mga)**
   - Domain: Project manager, release engineering, contribution policy
   - Links: https://github.com/akien-mga
   - Why useful: Writes release articles; manages merge queue; signals what gets prioritized each cycle.
   - Example contribution: Authored 2026 contribution policy changes (Feb 2026); manages every stable release tag.

3. **Yuri Sizov (@YuriSizov)**
   - Domain: Editor UI, Inspector, theme system; maintainer of the Interactive Changelog tool
   - Links: https://github.com/YuriSizov
   - Why useful: Owns editor experience improvements. Also the person behind the interactive changelog — the most useful release-tracking tool.
   - Example contribution: godot-interactive-changelog; Inspector and Signal docks improvements (PR #81221).

4. **dalexeev**
   - Domain: GDScript language implementation — static typing, analyzer, runtime errors, doc generation
   - Links: https://github.com/dalexeev
   - Why useful: Go-to contributor for GDScript type system behavior. His PRs clarify language semantics before docs catch up. Also maintains gdscript-preprocessor plugin.
   - Example contribution: PR #99899 (Apr 2026) — grouped GDScript analyzer/runtime error tests; gdscript-compile-time-evaluations experiments.

5. **Aaron Franke (@aaronfranke)**
   - Domain: Math types (Vector, Transform, Quaternion), GDScript stdlib, documentation
   - Links: https://github.com/aaronfranke
   - Why useful: Prolific contributor to math and geometry APIs. Frequently cited in coordinate system and transform-related bug reports.
   - Example contribution: High commit count in AUTHORS.md; active across math-related issues and PRs.

6. **Fabio Alessandrelli (@Faless)**
   - Domain: Networking — WebSocket, WebRTC, multiplayer, ENet
   - Links: https://github.com/Faless
   - Why useful: Primary maintainer of Godot's networking layer. Essential reference for multiplayer and WebSocket work.
   - Example contribution: Core networking contributor; named in QA/testing team at contributing.godotengine.org.

7. **Raul Santos (@raulsntos)**
   - Domain: C# / .NET binding layer
   - Links: https://github.com/raulsntos | https://github.com/raulsntos/godot-dotnet
   - Why useful: Owns C# interop. Maintains godot-dotnet for framework-level C# compatibility with Godot 4.x.
   - Example contribution: godot-dotnet framework; C# binding updates for 4.6 and 4.7.

8. **smix8**
   - Domain: Navigation system — NavigationAgent, NavigationMesh, pathfinding
   - Links: https://github.com/smix8
   - Why useful: The primary contributor to Godot's navigation system. Navigation bugs should be diagnosed against their PRs first.
   - Example contribution: Maintains a navigation-focused fork of godot-docs; navigation mesh fixes across 4.x.

9. **K.S. Ernest Lee (@fire)**
   - Domain: Animation, IK, engine stability
   - Links: https://github.com/fire
   - Why useful: Core team member active across a wide range of PRs. Named in Animation and IK teams at contributing.godotengine.org.
   - Example contribution: Named maintainer in Animation/IK area teams; broad cross-domain contributions.

10. **Silc 'Tokage' Renew (@TokageItLab)**
    - Domain: Animation system, SkeletonModifier3D, IKModifier3D
    - Links: https://github.com/TokageItLab
    - Why useful: Led the IK system rewrite that shipped in Godot 4.6. Authoritative on procedural animation.
    - Example contribution: IKModifier3D / TwoBoneIK3D / FABRIK3D / CCDIK system in Godot 4.6.

11. **Pavels Nadtocajevs (@bruvzg)**
    - Domain: Text rendering, fonts, internationalization, platform text APIs
    - Links: https://github.com/bruvzg
    - Why useful: Owns the text rendering pipeline. Go-to for i18n, RTL text, and font system bugs.
    - Example contribution: Named in QA/testing and text teams at contributing.godotengine.org.

12. **Nathan Lovato (@NathanLovato / GDQuest)**
    - Domain: GDScript education, open-source demos, 2D game patterns
    - Links: https://github.com/NathanLovato | https://www.gdquest.com/ | https://x.com/nathangdquest
    - Why useful: 300k+ YouTube subscribers; "Learn GDScript From Zero" is the community-recommended free course. Open-source demos model good GDScript architecture.
    - Example contribution: gdquest.com tutorial library; active newsletter; courses updated for Godot 4.x.

13. **bitwes**
    - Domain: GUT testing framework (GDScript)
    - Links: https://github.com/bitwes/Gut
    - Why useful: Sole maintainer of GUT. Changelog and issue tracker are ground truth for test framework behavior.
    - Example contribution: GUT 9.6.0 (Feb 24, 2026) — added Singleton doubling, assert_push_warning, headless auto-exit, elapsed time accessors.

14. **Mike Schulze (@MikeSchulze)**
    - Domain: GdUnit4 testing framework (GDScript + C#)
    - Links: https://github.com/MikeSchulze/gdUnit4
    - Why useful: Sole maintainer of GdUnit4. v5.0.4 (Jun 8, 2026) supports Godot 4.0.3–4.7. Also maintains gdUnit4-action for GitHub Actions CI.
    - Example contribution: gdUnit4-action CI/CD integration for automated Godot test runs.

15. **Signal Emitted (YouTube channel)**
    - Domain: Weekly Godot ecosystem news digest
    - Links: Search "Signal Emitted Godot" on YouTube; published through week 17+ of 2026.
    - Why useful: Covers merged PRs, dev snapshots, community discussions, and release news in weekly ~10-minute videos. Faster than the blog for tracking in-progress features.
    - Example: Week 16 (Apr 2026) covered "GDScript 3.0 proposal"; Weeks 9-10 (Mar 2026) covered a major Godot game Steam launch.

---

## 3. Recent Milestones (Post-Jan 2026)

### Godot Engine Releases

| Version | Date | Highlights |
|---------|------|------------|
| 4.6-stable | 2026-01-26 | New "Modern" editor theme; floatable docks; Jolt Physics as default 3D engine; IKModifier3D (TwoBoneIK3D, FABRIK3D, CCDIK); SSR rewrite; LibGodot embedded mode; patch PCK delta encoding |
| 4.6.1-stable | 2026-02-16 | Stability and regression fixes |
| 4.5.2-stable | 2026-03-19 | Backport maintenance for 4.5 branch |
| 4.6.2-stable | 2026-04-01 | Maintenance fixes |
| 4.6.3-stable | 2026-05-20 | 86 fixes from 41 contributors; 2D/3D editor, animation crashes, Android/iOS export, C# dependencies, input quirks, physics overlap, rendering fixes |
| 4.7-stable | 2026-06-18 | HDR output (all desktop; Linux needs Wayland); AreaLight3D; built-in VirtualJoystick; DrawableTexture; Vulkan ray tracing foundation; new Asset Store; gyro controller aiming; Steam Frame support |

### Contribution Policy Change (Feb 2026)
- URL: https://godotengine.org/article/contribution-policy-2026/
- New contributors must do bug fixes and docs before feature PRs
- AI-authored code, agent-submitted PRs, AI-generated proposal text all explicitly banned
- Context: ~4,681 open PRs at time of announcement; AI slop described as "draining and demoralizing"
- Media coverage: The Register (Feb 18), PC Gamer, HN thread id=47059779

### GUT Current State
- Version: **9.6.0** (released 2026-02-24)
- Compatible with: Godot 4.6 (9.x series is Godot 4.x only; 7.x was Godot 3.x)
- Key 9.6.0 additions: `assert_push_warning` / `assert_push_warning_count`; Singleton doubling (Input, Time, OS, etc.); headless auto-exit; `print_tracked_errors`; elapsed time accessors (sec/msec/usec/idle-frames/process-frames/physics-frames)
- Docs: https://gut.readthedocs.io/en/v9.6.0/
- Status: Active; responsive to 4.6 regressions (issue #799 filed and tracked in 2026)

### GdUnit4 Current State
- Version: **5.0.4** (released 2026-06-08)
- Compatible with: Godot 4.0.3 through 4.7
- Caution: v6.0.0 referenced in some sources as Godot-4.5-based rebuild — verify on releases page before adopting
- Features: GDScript + C# support; embedded inspector; scene runner; CI via gdUnit4-action
- Releases: https://github.com/MikeSchulze/gdUnit4/releases

### GodotCon 2026
- Amsterdam: April 23-24, 2026 (Pathé Amsterdam Noord). First in Godot Foundation's home city; co-organized with Dutch Games Association.
- Boston: Announced for 2026 US; name change from prior year signaled.
- GodotFest Munich: November 2026.
- Info: https://conference.godotengine.org/2026/

### GDScript Proposals to Watch
- "GDScript 3.0" (informal): Proposal to migrate GDScript implementation to GDExtension mechanism (godot-proposals Issue #14652). Tagged for Godot 5.0 milestone. Not imminent but signals long-term language direction.
- Typed nested arrays/dicts: Multiple active proposals (e.g., Issue #12224 for Array[Array[String]] support). Watch the 4.8 and 5.0 milestones.

---

## 4. Sources to Skip (Abandoned / Replaced)

| Source | Status | Use Instead |
|--------|--------|-------------|
| Godot Asset Library (old) | Replaced in 4.7 by Asset Store (store.godotengine.org). Old library accessible for pre-4.7 projects. | New Asset Store |
| godotforums.org | Community-run, fragmented audience. Lower traffic than official forum. | forum.godotengine.org |
| Godot 3.x docs / GUT 7.x | Irrelevant for Godot 4.x projects. GUT 7.x is Godot 3 only. | Godot 4.x docs; GUT 9.x |
| KidsCanCode (kidscancode.org) | No confirmed 2026 content found; GitHub org appears inactive for new Godot 4 tutorials. | GDQuest, Heartbeast |
| Old Godot Q&A site (godotengine.org/qa) | Replaced by forum.godotengine.org in the Godot 4 era. | forum.godotengine.org |

---

## 5. Secondary Blogs and YouTube (Active 2026)

- **GameFromScratch** (gamefromscratch.com): Day-of coverage of 4.6 and 4.7 releases. Tracks Godot popularity vs. Unity/Unreal via SteamDB data. MED signal for release and market context.
- **Jettelly** (jettelly.com): Feature deep-dives on 4.6 and 4.7 dev snapshots through April 2026. Shader-heavy content. MED signal.
- **GDQuest** (gdquest.com + YouTube): 300k+ subscribers. Free "Learn GDScript From Zero" course. Open-source demos model good GDScript patterns. HIGH signal for learning.
- **Heartbeast** (youtube.com/c/uheartbeast): Godot and pixel art tutorials; ARPG series in Godot 4 ongoing. MED signal for 2D game patterns.
- **Firebelley Games** (firebelley.com + YouTube): Professional Godot developer; publishes Steam games; long-form tutorials on project structure. MED signal for practical architecture.
- **Signal Emitted** (YouTube): Weekly news digest. HIGH signal for tracking ecosystem pulse week-by-week.
- **80.lv**: Covered 4.6 RC, 4.7 dev snapshot, 4.7 stable. CG/industry-facing but catches rendering news early.
- **GamingOnLinux**: Same-day release coverage; reliable for 4.x release summaries.

---

*Crawl methodology: WebSearch + WebFetch via Claude research agent, 2026-07-01. URLs verified where accessible. godotengine.org returned HTTP 403 on direct WebFetch; information sourced from search result snippets and third-party coverage instead.*
