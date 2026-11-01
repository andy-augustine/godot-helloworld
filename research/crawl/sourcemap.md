# Godot 4 / GDScript Community Sourcemap
**Crawl date:** 2026-11-01  
**New-since window:** 2026-10-01 forward

---

## ⚠️ Surprises

**1. Godot 4.7 is stable and already has two maintenance releases.**  
4.7 stable shipped June 18-19, 2026. 4.7.1 (rendering fixes, July 14) and 4.7.2 RC1 (August 3) followed. This is the current production line, not 4.6.x. The previous crawl's "4.6 is current stable" framing is outdated. Topic agents should target 4.7.x.  
Source: <https://godotengine.org/article/maintenance-release-godot-4-7-1/>, <https://godotengine.org/article/release-candidate-godot-4-7-2-rc-1/>

**2. Godot 4.8 beta 1 shipped October 15, 2026 — within this crawl window.**  
Feature freeze declared. 4.8 dev cycle added symbol renaming (editor), multi-bounce AO, Trail3D, docked game view, AccessKit on iOS/Android. Stable expected Q4 2026 (imminent). Topic agents investigating cutting-edge APIs should check 4.8 betas.  
Source: <https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/>

**3. Godot officially banned AI-authored code contributions (July 2026).**  
Policy published ~June 30 / July 2, 2026. Fully AI-generated PRs are rejected outright; limited AI assistance (single-line completion, regex, translation) is tolerated. Maintainers described the surge of AI submissions as "draining and demoralizing." This narrows the pool of contributors whose GitHub comments and PRs are trustworthy signals — prioritize accounts with a track record of human-reviewed work.  
Source: <https://www.gamingonlinux.com/2026/07/godot-engine-to-get-stricter-on-ai-contributed-code/>, <https://pcgamer.com/gaming-industry/open-source-game-engine-godot-will-no-longer-accept-ai-authored-code-contributions-we-cant-trust-heavy-users-of-ai-to-understand-their-code-enough-to-fix-it>

**4. 4.7 has known breaking changes; migration guide required.**  
Linuxiac notes breaking changes requiring a migration guide read before upgrading. Input regression (high-polling-rate mouse on Windows, GH-109639) patched in 4.7.2 RC1.  
Source: <https://linuxiac.com/godot-4-7-open-source-game-engine-released-with-linux-wayland-hdr-support/>

---

## 1. Active Venues (ranked by signal quality)

### GitHub

**godotengine/godot** — `HIGH`  
Primary repo. 4.8 beta 1 is live; 4.7.2 RC1 from August. Issues, PRs, and the releases page are the authoritative source for bugs, fixes, and version history. Commit velocity is high (~300+ fixes per dev snapshot).  
URL: <https://github.com/godotengine/godot>  
Activity sample: 4.8 dev 1 had 135 contributors submit 314 fixes (August 2026).

**godotengine/godot-proposals** — `HIGH`  
Central hub for feature proposals (both issues and discussions). Architecture decisions are made here. Worth watching for GDScript type system, 2D API, and state machine proposals relevant to this project.  
URL: <https://github.com/godotengine/godot-proposals>  
Activity sample: Active discussion threads noted in forum crawl through October 2026.

**godotengine/godot-docs** — `MED`  
Docs contributions. Useful for checking whether a new API is documented. PRs here are often first to reflect stable behaviour.  
URL: <https://github.com/godotengine/godot-docs>

**bitwes/Gut** — `HIGH` (for this project specifically)  
GUT v9.7.0/v9.7.1 targets Godot 4.7. GUT version numbering tracks Godot minor: 9.7.x = Godot 4.7.x. bitwes (Tom Wright) actively responds to issues.  
URL: <https://github.com/bitwes/Gut>  
Asset Store: <https://store.godotengine.org/asset/bitwes/gut/>

**MikeSchulze/gdUnit4** — `HIGH` (for this project specifically)  
GdUnit4 v5.0.x is current stable; v5.1.0 was in RC as of April 2026 (last confirmed push April 28, 2026). v5.x targets Godot 4.4+.  
URL: <https://github.com/MikeSchulze/gdUnit4>

**chickensoft-games** org — `LOW` (GDScript project, not C#)  
Active C# tooling org (LogicBlocks state machines, AutoInject, GodotEnv). NuGet packages updated June 2026. Not relevant to this GDScript project.  
URL: <https://github.com/chickensoft-games>

---

### Official Forum

**forum.godotengine.org** — `HIGH`  
The re-launched official forum (Discourse-based). Active through at least October 25, 2026 (confirmed cached page). Contains announcements (4.6.3, 4.7, 4.8 snapshots posted here), general Q&A, and showcases. Better signal-to-noise than Reddit for technical GDScript questions. Response times are typically within hours for popular threads.  
URL: <https://forum.godotengine.org/>  
Activity sample: Thread on "Possibly an ECS-powered SceneTree for Godot" was active in 2026.

---

### Reddit

**r/godot** — `MED`  
Estimated ~228k members (one source), actively posting. Good for general community pulse and discovering problems users are hitting in the wild. Lower signal for deep technical GDScript questions vs. the official forum. Godot Foundation noted it migrated official support emphasis toward the forum and Lemmy.  
URL: <https://www.reddit.com/r/godot/>  
Policy note: The Foundation acknowledges r/godot as community-run; no recent mod policy changes found.

---

### Discord

**Godot Engine (official)** — `MED`  
~76.7k members (Discord Bot List listing). The server is moderated by Foundation-vetted volunteers. No web-accessible channel listing found; channels must be viewed after joining. The `#help` channel is the primary tech-support channel; contributor-specific discussion is at chat.godotengine.org (Rocket.Chat).  
Join: <https://discord.gg/4JBkykG> (user-sourced; verify before relying on it)  
Listing: <https://discordbotlist.com/servers/godotengine>

**Godot Contributors Chat (Rocket.Chat)** — `HIGH` for finding core devs  
Self-hosted Rocket.Chat at chat.godotengine.org. Intended for engine contributors, not user support. Core maintainers active here. Area-specific channels (e.g., `#rendering`, `#gdscript`).  
URL: <https://chat.godotengine.org/>

---

### Mastodon / X / Social

**@godotengine@mastodon.gamedev.place** — `MED`  
Official Mastodon account. Posted through at least early 2026 (4.6 release, GodotCon 2026 announcement). Primary social announcement channel alongside the blog.  
URL: <https://mastodon.gamedev.place/@godotengine>  
Hashtags to watch: `#GodotEngine`, `#Godot4`, `#GDScript`

**X (formerly Twitter)** — `LOW`  
No evidence found of an active official Godot X presence in 2026. Core devs (reduz, akien-mga) have not been confirmed active on X. Skip.

**Bluesky / Lemmy** — `LOW–MED`  
Godot Foundation acknowledged Lemmy as a Reddit alternative community space, but no dedicated high-signal instance found. Bluesky activity unverified.

---

### YouTube

**Brackeys** — `MED` (beginner-heavy, high reach)  
~1.94M subscribers. Returned to Godot content in 2024. Subscriber count suggests continued uploads but 2026 upload specifics unconfirmed. Primarily beginner-facing.  
Channel: <https://www.youtube.com/@Brackeys>

**GDQuest** — `HIGH` (technical depth)  
~320K subscribers. Officially recommended by Godot docs. Covers intermediate-to-advanced topics (shaders, ECS patterns, 3D). Still listed as top-ranked in July 2026 directory. Verify recent upload dates directly.  
Channel: <https://www.youtube.com/@GDQuest>  
Site: <https://gdquest.com>

**KidsCanCode (Chris Bradfield)** — `MED` (recipes-style, solid technical)  
Short, precise tutorials. Contributor to official Godot docs ("Your First Game"). GDScript recipes at kidscancode.org. Unconfirmed 2026 upload activity.  
URL: <https://kidscancode.org/godot_recipes/>

---

### Blogs & Written Content

**Official Godot Blog** — `HIGH`  
godotengine.org/blog — The authoritative source for release notes, dev snapshots, and policy updates. Posted 4.8 dev 3 on August 7, 2026. Highest trust.  
URL: <https://godotengine.org/blog/>

**gamedev.net Godot topic** — `MED`  
Aggregates Godot news. Good for tracking release timing without monitoring every source.  
URL: <https://gamedev.net/news/topic/godot/>

**Godot Digest (Substack)** — `MED`  
Community newsletter; issues 39 and 40 confirmed from 2026.  
URL: <https://godotdigest.substack.com/>

**Godot Weekly (curated.co)** — `MED`  
Curated weekly links. Issue 40 confirmed in results.  
URL: <https://godot-weekly.curated.co/>

**GodotFest / GodotCon talks** — `MED`  
Talk recordings from GodotCon Boston 2026 (July 21-22) likely posted on talks.godotengine.org. Topics included rendering, Android, XR, low-spec optimization.  
URL: <https://talks.godotengine.org/godotcon-boston-2026/>

---

### Events (2026)

| Event | Dates | Status |
|---|---|---|
| GodotCon Amsterdam | April 23-24, 2026 | Completed |
| GodotCon Boston | July 21-22, 2026 (workshops July 20) | Completed |
| GodotFest Munich | **November 3-4, 2026** | **Upcoming (2 days away)** |

GodotFest Munich is independently organized, business-focused, with MeetToMatch networking. Not an official GodotCon. Source: <https://godotengine.org/article/godotfest-2026/>

---

## 2. High-Signal Individual Contributors (2026)

| # | Handle | Full name | Domain | Venue | Why useful |
|---|---|---|---|---|---|
| 1 | @reduz | Juan Linietsky | Core engine, architecture, low-level nodes, Viewport | GitHub, blog, Rocket.Chat | Co-creator; makes or approves all major architectural decisions |
| 2 | @akien-mga | Rémi Verschelde | Release management, contribution policy, CI | GitHub, blog, Mastodon | Gatekeeper for PRs; authored June 2026 AI policy clarification; reply author on proposals |
| 3 | @vnen | George Marques | GDScript lead — type system, parser, VM | GitHub, Rocket.Chat | Single most authoritative source on GDScript internals; typed arrays, typed instructions |
| 4 | @dalexeev | Danil Alexeev | GDScript — docs, type inference, static analysis | GitHub, forum | Active GDScript team member; strong on edge cases in type checking and exports |
| 5 | @adamscott | Adam Scott | GDScript — async, runtime behaviour | GitHub | GDScript team; involved in async/coroutine behaviour |
| 6 | @Repiteo | Thaddeus Crews | Release management, tests, build system | GitHub, blog | Authored 4.7.1, 4.7.2 RC1, and 4.8 dev 3 posts; triages release-blocking regressions |
| 7 | @hpvb | HP van Braam | Core — low-level, memory, templates | GitHub, Rocket.Chat | Core team; Object/Variant/RefCounted internals |
| 8 | @RandomShaper | Pedro J. Estébanez | Core, threading, signals | GitHub | Core team; threading model, signal dispatch |
| 9 | @lawnjelly | lawnjelly | Rendering pipeline, 2D rendering, geometry | GitHub | Handles 2D batching and rendering edge cases; prolific reviewer |
| 10 | @Ivorforce | Lukas Tenbrink | Core, type system, areas meta | GitHub | Named in contributing areas page as Core co-maintainer |
| 11 | @vonagam | Dmitry Maganov | GDScript — parser, syntax | GitHub | GDScript team; syntax-level contributions |
| 12 | @anvilfolk | ocean | GDScript | GitHub | GDScript team member |
| 13 | @clayjohn | Clay John | Rendering — Vulkan, OpenGL, shaders | GitHub | Rendering sub-team; shaders and GPU-side features |
| 14 | bitwes | Tom Wright (bitwes) | Testing — GUT framework | GitHub, Asset Store | Author and maintainer of GUT; responds to issues; best contact for GUT bugs |
| 15 | MikeSchulze | Mike Schulze | Testing — GdUnit4 framework | GitHub, NuGet | Author of GdUnit4; v5.0.x stable as of mid-2026; active reviewer |

Sources: godotengine.org/teams, contributing.godotengine.org areas page (search-result snippets), godotengine.org/article/* release posts with contributor counts.

---

## 3. Recent Milestones (post-October 2026 or close)

### Godot Engine releases

| Version | Date | Fixes / Contributors | Notes |
|---|---|---|---|
| 4.6.3 stable | May 20, 2026 | 86 fixes / 41 contributors | Last 4.6.x maintenance; no breaking changes vs 4.6.2 |
| 4.7.0 stable | June 18-19, 2026 | Major release | HDR output (Windows/macOS/Wayland), AreaLight3D, new Asset Store, wasm64, one-way collision dir for CollisionShape2D, conic gradients, breaking changes → read migration guide |
| 4.7.1 stable | July 14, 2026 | 78 fixes / 42 contributors | Rendering focus (flickering lighting on scaled mesh instances) |
| 4.7.2 RC1 | August 3, 2026 | 43 fixes / 37 contributors | Input (high-polling-rate mouse Windows, GH-109639), rendering (PCSS shadows), multiplayer |
| 4.8 beta 1 | **October 15, 2026** | 314+ fixes since dev 1 | **Feature freeze.** Symbol renaming, multi-bounce AO, Trail3D, AccessKit iOS/Android, docked game view. Stable Q4 2026. |
| 4.8 dev 1 | Earlier 2026 | 135 contributors / 314 fixes | First 4.8 dev drop |

Note: 4.7.2 final stable status unconfirmed (RC1 August 3; may have released since). Check <https://github.com/godotengine/godot-builds/releases> for latest tags.

### 4.7 known / fixed regressions relevant to 2D / input / GUI

- **High-polling-rate mouse on Windows** degrades performance (GH-109639) — patched in 4.7.2 RC1 (August). Affects input-heavy 2D games.
- **Polygon2D stale bounding-box culling** after vertex edits (GH-119872) — fixed in 4.7 beta 5.
- **Popup menu tooltips** don't show with search bar enabled (GH-119407) — fixed in 4.7 betas.
- **General migration note:** 4.7 includes breaking changes. Official migration guide required for projects upgrading from 4.6.x.

Source: <https://godotengine.org/article/dev-snapshot-godot-4-7-beta-5/>, <https://godotengine.org/article/release-candidate-godot-4-7-2-rc-1/>

### GUT (bitwes/Gut)

- **Current version:** v9.7.1 (Godot 4.7), v9.7.0 also listed
- GUT version major = Godot major, minor = Godot minor (9.x = Godot 4.x)
- No itemized v9.7.x changelog found in public search; check <https://github.com/bitwes/Gut/releases>
- Docs: <https://gut.readthedocs.io/en/v9.7.0/>

### GdUnit4 (MikeSchulze/gdUnit4)

- **Current stable:** v5.0.x (built on Godot 4.4.1)
- **Pre-release:** v5.1.0 RC4 as of April 2026 (last confirmed push April 28, 2026)
- C# NuGet: `GdUnit4` package tracked under NuGet profile mschulze
- URL: <https://github.com/MikeSchulze/gdUnit4>

### GodotCon / Foundation events

- GodotCon Amsterdam (April 2026) and Boston (July 2026) both held.
- GodotFest Munich (Nov 3-4, 2026): independent event, business-focused, in 2 days.
- Godot Foundation published a **Vision Statement 2026** blog post (see godotengine.org/article/godot-vision-statement-2026/).
- Nintendo Switch 2 porting post appeared on official blog (2026).
- **AI contribution ban** (July 2026): AI-authored code PRs rejected; limited AI assistance tolerated.

---

## 4. Sources to Skip (low signal or defunct)

| Venue | Why skip |
|---|---|
| ask.godotengine.org (old Q&A) | Replaced by forum.godotengine.org; most links redirect or 404 |
| Old Asset Library (godotengine.org/asset-library) | Replaced in Godot 4.7 by the new Asset Store (store.godotengine.org). Old library pages still exist but new assets are going to the store. |
| X / Twitter for Godot tech discussion | No confirmed active official or core-dev presence; low signal |
| Godot 3.x channels / subreddits | Out of scope; 3.x is in maintenance-only mode |
| YouTube tutorials tagged "Godot 4" without checking upload date | Many tutorials are for 4.0–4.2 and predated key API changes; always check upload date vs. target version |
| Steam forums (Godot games' individual forums) | Highly fragmented, no aggregate signal |
| Older community Q&A threads on StackOverflow | GDScript questions are sparse and often outdated; forum + GitHub are better |
| ChatGPT / AI-generated "Godot docs" | Known to hallucinate API signatures, especially for 4.5+ changes |

---

*Crawl conducted 2026-11-01. godotengine.org and contributing.godotengine.org are blocked by this session's network policy — team pages were accessed via search-result snippets only. Verify team roster directly at <https://godotengine.org/teams> when network access is available.*
