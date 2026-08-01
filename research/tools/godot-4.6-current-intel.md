# Godot 4.6/4.7 Current Intel — Synthesized Deliverable
*Synthesized: 2026-08-01 | Intel window: Jul 2026 – Aug 2026*
*Project context: 2D Metroidvania, Godot 4.6.2 (4.7.1 upgrade under consideration), GDScript, macOS Apple Silicon, GL Compatibility renderer, 960×540, CharacterBody2D + custom GameCamera room-lock, TileMapLayer rooms, AnimationPlayer rig, MCP-driven dev (godot-mcp-pro).*
*Inputs: research/crawl/sourcemap.md + five topic crawls (engine-quirks, gdscript-language, tooling, 2d-platformer, performance), all crawled 2026-08-01.*

---

## 1. TL;DR

- **Engine:** 4.6.x is superseded and receives no further fixes. Target 4.7.1 (Jul 15, 2026); it carries 78 stability fixes and zero known incompatibilities for GL Compatibility projects.
- **GDScript:** `await` on a method of an object that gets freed mid-flight now hangs the caller forever in 4.7 (was released in 4.6). Guard every cross-object await.
- **Tooling:** hi-godot/godot-ai v3.0.7 (1.4k stars, MIT, 120+ ops) is a credible free replacement for godot-mcp-pro's paywall. GUT v9.7.1 stays our test framework.
- **2D platformer:** Camera2D `position_smoothing` renders a fully gray screen on macOS + Compatibility in 4.7.1 — our exact combo. Keep smoothing script-driven, never built-in.
- **Performance:** GL Compatibility avoids both active Apple Silicon Metal bugs (fence-timeout freeze, MetalFX launch crash). Renderer choice confirmed correct; no action.

---

## 2. Active sources, ranked

### HIGH
- **godotengine/godot** — primary ground truth for behavior and breaking changes. https://github.com/godotengine/godot — *S/N update: Foundation banned AI-authored contributions June 30, 2026. 4,681+ open PRs; PR-queue signal is still recovering, so prefer merged PRs and maintainer commits over open PRs.*
- **godotengine/godot-proposals** — where GDScript is heading. https://github.com/godotengine/godot-proposals/discussions — *S/N update: the load-bearing threads this window are #14652 (GDScript→GDExtension), #15279 (string-literal comments), #12639 (`@static`).*
- **godotengine.org/blog** + `/blog/release/` — authoritative release and policy articles. https://godotengine.org/blog/
- **forum.godotengine.org** — official Discourse; Help threads answered in 24–72 h. https://forum.godotengine.org/ — *S/N update: confirmed active on GDScript topics through Jul 31, 2026.*
- **bitwes/Gut** — v9.7.1 (Jul 10, 2026). Only GDScript-native test framework; author responsive. https://github.com/bitwes/Gut
- **godot-gdunit-labs/gdUnit4** — v6.2.0 (Jul 28, 2026). Richest CI integration. https://github.com/godot-gdunit-labs/gdUnit4
- **hi-godot/godot-ai** — *new this window.* Free MIT MCP server, v3.0.7 Jul 25, 2026, 690 commits. https://github.com/hi-godot/godot-ai
- **Godot Digest** — best single aggregator; 48+ issues. Use as finding index, not primary source. https://godotdigest.substack.com
- **GodotCon talks (Godot Foundation YouTube / talks.godotengine.org)** — Boston 2026 (Jul 20–22) recordings expected Aug 2026, incl. clayjohn renderer retrospective. https://talks.godotengine.org/godotcon-boston-2026/schedule/
- **Godot Contributors Chat** — maintainer design discussion; invitation-only, best route to core team.
- **GDQuest** — most technically rigorous free tutorials; FSM and design-pattern demos are production-quality reference. https://www.youtube.com/@Gdquest

### MED
- **godotengine/godot-docs** — doc PRs often reveal undocumented behavior. https://github.com/godotengine/godot-docs
- **Godot Asset Store** — *new in 4.7.* Threaded, versioned downloads, engine-version filtering. Fewer listings than legacy library. https://store.godotengine.org
- **Legacy Asset Library** — more listings; still the discovery surface for GUT, GdUnit4, LimboAI, TileMapDual. https://godotengine.org/asset-library
- **limbonaut/limboai** — v1.0 Jun 19, 2026, v1.8.0 Jun 21. Behavior-tree/FSM patterns. https://github.com/limbonaut/limboai
- **r/godot** — 359K members; good for surveying what breaks at scale, weak for depth. https://reddit.com/r/godot
- **Official Godot Discord** — 76,406+ members, #gdscript / #2d / #physics. Ephemeral; do not cite.
- **@godotengine on X** and **@godotengine@mastodon.gamedev.place** (22,600+ followers) — release timestamps; core-dev commentary (Calinou active on Mastodon).
- **StraySpark Studio** — real benchmarks (optimization guide, 4.7 features, GDScript-vs-C#). https://www.strayspark.studio/blog
- **KidsCanCode** / **HeartBeast** — recipe- and project-scale technical content. kidscancode.org/godot_recipes/4.x/
- **chickensoft-games** + chickensoft.games/blog — C#-only; useful for tooling architecture, not GDScript.
- **GamingOnLinux**, **80.lv**, **linuxcompatible.org** — reliable same-day release coverage; the fastest source for dev-snapshot summaries.

### LOW
- **godotengine/godot-builds** — snapshot download index, no discussion. https://github.com/godotengine/godot-builds/releases
- **HackerNews** — occasional traction (the AI-code ban story spread May–Jul 2026); not consistent.
- **godotforums.org** — superseded by the official forum; search-only.
- **Stack Overflow (godot tag)** — low volume, answers stale for 4.x, no maintainer presence.
- **Brackeys** — 1.9M subs, beginner-only. Not deep enough for architecture.
- **Redot Engine** — low-traction 2024 fork; do not conflate with upstream.
- **Dead/skip:** Godot Q&A (godotengine.org/qa, shut down, links broken), IRC #godotengine (abandoned), Godot Café Discord, BornCG / legacy GDScript Tutorials channels (stop at 3.x), any pre-2023 r/godot thread.

---

## 3. Contributors to follow

1. **Juan Linietsky (@reduz)** — engine architecture / feature prioritization. https://github.com/reduz
   Why: decides what gets accepted. Example: GodotCon Amsterdam 2026 talk on the Godot decision model (https://www.youtube.com/watch?v=LDSwP37y_W4, Jun 2, 2026); drove LibGodot in 4.6.
2. **Rémi Verschelde (@akien-mga)** — release management, PR review, quality policy. https://github.com/akien-mga
   Why: manages every stable cherry-pick, so he is the authority on "did the fix land in 4.7.x." Example: authored the Jun 30, 2026 AI-contribution policy.
3. **George Marques (@vnen)** — GDScript language maintainer. https://github.com/vnen
   Why: every type-system change (typed Callables, traits, `@static`) runs through his review. Example: PR #39093, the GDScript 2.0 rewrite. Watch his commit feed for movement on stalled proposals.
4. **Tomasz Chabora (@KoBeWi)** — editor, 2D tools, TileMap, physics. https://github.com/KoBeWi
   Why: most relevant single reviewer for our stack. Example: maintains the Metroidvania-System plugin (storable-object IDs + room-state serialization, 4.6+).
5. **Hugo Locurcio (@Calinou)** — docs, rendering QoL, CI. https://github.com/Calinou / @Calinou@mastodon.gamedev.place
   Why: his doc PRs are often the only written record of undocumented behavior; answers engine questions on Mastodon. Example: bulk of godot-docs merges this cycle.
6. **Clay John (@clayjohn)** — rendering lead (Forward+, Mobile, GLES3/Compatibility). https://github.com/clayjohn
   Why: the person to watch for any 2D Compatibility renderer work in 4.8. Example: GodotCon Boston 2026 renderer retrospective (recording pending); SSR overhaul in 4.6.
7. **bitwes** — GUT maintainer. https://github.com/bitwes / https://gut.readthedocs.io
   Why: ships a compat release for every Godot minor, so GUT release notes double as a 4.x behavior-change digest. Example: v9.7.0 added strict return-type-aware doubling for 4.7.
8. **MikeSchulze** — GdUnit4 lead. https://github.com/godot-gdunit-labs/gdUnit4
   Why: most CI-integrated Godot test framework; his release notes flag engine API breaks early. Example: v6.2.0 full error stack traces + orphan-node detection (Jul 28, 2026).
9. **Serhii Snitsaruk (@limbonaut)** — LimboAI (behavior trees + FSM). https://github.com/limbonaut / https://limboai.readthedocs.io
   Why: reference implementation for state machines in Godot 4; responsive on issues. Example: LimboAI v1.0 stable API, Jun 19, 2026.
10. **Nathan / GDQuest** — tutorials and open-source demos. https://github.com/gdquest-demos / https://www.gdquest.com
    Why: their node-based FSM and save-format guides are what we actually pattern-match against. Example: 2026 node-based FSM tutorial + demo repo; save-game-formats best-practice guide.
11. **@dalexeev** — GDScript proposals / language semantics. https://github.com/godotengine/godot-proposals/issues/14652
    Why: author of the GDScript-to-GDExtension migration proposal, the single largest long-term GDScript scope-changer. Example: proposal #14652 ("GDScript 3.0"), targeting Godot 5.0.
12. **Yuri Sizov (@pycbouh)** — editor UI / theme, Interactive Changelog. https://github.com/pycbouh
    Why: authoritative on editor Control/theme internals; his Interactive Changelog is the fastest fix-landed-where lookup. Example: Modern editor theme in 4.6.
13. **stuartcarnie** — Metal rendering backend. https://github.com/godotengine/godot/issues/119436
    Why: the only person to watch on Apple Silicon Metal correctness; gates any future Forward+ move. Example: confirmed patch + PR for the M-series fence-timeout freeze (#119436).
14. **pablogila** — TileMapDual. https://github.com/pablogila/TileMapDual
    Why: automatic dual-grid TileMapLayer autotiling — directly applicable to room tiling. Example: TileMapDual, active through 2026.
15. **Will Nations (@willnationsdev)** — GDScript meta-programming, editor plugins, script templates. https://github.com/willnationsdev
    Why: deepest community specialist on editor scripting APIs, which is what MCP tooling ultimately drives. Example: sustained GDScript tooling/education work across 4.x.

---

## 4. Findings

### 4.1 Engine — releases, quirks, regressions

**E1. Upgrade target is 4.7.1; 4.6.x is end-of-line. (HIGH)**
4.7 stable shipped Jun 18, 2026 ("Lights, Camera, Action!") — 1,265 fixes from 309 contributors. 4.7.1 followed Jul 15, 2026 with 78 stability fixes from 42 contributors (rendering artifacts, editor crashes, Jolt buffer overflows, Android virtual-keyboard regression, mbedtls 3.6.7 security bump) and **zero known incompatibilities** with 4.7. The 4.6.x line (4.6.3, May 20, 2026) gets no further updates. Migration risk for GL Compatibility 2D projects is low; back up, then verify tilemap behavior and physics callbacks.
https://godotengine.org/releases/4.7/ (2026-06-18) | https://godotengine.org/article/maintenance-release-godot-4-7-1/ (2026-07-15) | https://www.linuxcompatible.org/story/godot-471-released-quick-stability-patch-fixes-rendering-and-platform-bugs (2026-07)

**E2. Stale `.godot/uid_cache.bin` silently kills the running game during debugger inspection. (HIGH for MCP workflow)**
4.7 regression (introduced 4.7 RC2, absent in 4.6.3, unfixed in 4.7.1). Once a stale `uid_cache.bin` accumulates from project restructuring, opening the Remote Tree or the Video RAM tab on a running game closes the game instantly with nothing printed to Output. Fix: delete `.godot/uid_cache.bin`, restart the editor. Most likely after bulk scene renames or resource moves. This is squarely in our MCP playtest path — godot-mcp-pro inspects the scene tree of the running game.
https://github.com/godotengine/godot/issues/120306 (open as of 2026-08-01)

**E3. `AnimationNodeStateMachineTransition` with `switch_mode = Sync` floods the debugger. (MED)**
4.7 regression, milestone 4.8, not in 4.7.1. With Sync mode driving a Sprite2D `frame` property, the state machine interpolates a frame roughly double the valid range and emits `ERROR: index p_frame is out of bounds (N)` every physics tick. Animation looks correct; the debugger becomes unusable. Workaround: use Immediate or At End, or blend manually from AnimationPlayer. We are AnimationPlayer-only, so this is a gate on adopting AnimationTree for enemy AI.
https://github.com/godotengine/godot/issues/120480 (open as of 2026-08-01)

**E4. `AnimationNodeOneShot` "Abort on Reset" was a no-op in 4.7.0 — fixed in 4.7.1. (MED, resolved)**
One-shot clips played through `RESET` triggers in 4.7.0. Fixed in 4.7.1 with no API change. If we adopt one-shots for hit effects, pickups, or death, this is another reason to land on 4.7.1 rather than 4.7.0.
4.7.1 changelog (2026-07-15)

**E5. "Local to Scene" resource silently becomes an embedded sub-resource under Editable Children. (LOW)**
Behavior change introduced in 4.6, persisting in 4.7, no fix targeted. In 4.5.x the resource stayed an external file reference shared by all instances; in 4.6+ Godot embeds a per-scene copy while the inspector tooltip still shows the original path. Global inspector edits stop propagating. Avoid combining "Local to Scene" with Editable Children; use instanced subscenes for per-instance variation. Reported against GLB-imported meshes, so 2D exposure is limited.
https://github.com/godotengine/godot/issues/121428 (open as of 2026-08-01)

**E6. 4.8-dev2 "Upgrade Project Files" crashes on any scene with an AnimationPlayer + RESET track. (LOW, but blocks 4.8-dev migration)**
Editor crashes at 27–39% progress (EXC_BAD_ACCESS on macOS). Bisected to commit `bf898d1` in 4.8-dev2; reverting removes the crash. Our player rig has a RESET track, so do not attempt project migration from 4.8-dev2 — stay on 4.7.1 until 4.8 stable.
https://github.com/godotengine/godot/issues/121681 (open, 4.8-dev2 only)

**E7. Not currently exposed, tracked only. (LOW)**
Android Control nodes receive touch inside the letterbox border under `stretch/mode = canvas_items` (4.7 regression, marked 4.8 release blocker; desktop unaffected) — https://github.com/godotengine/godot/issues/121492. Forward+ hangs indefinitely on project close on some NVIDIA + Vulkan 1.4 combinations (4.7-dev1 regression, milestone 4.8) — https://github.com/godotengine/godot/issues/121503. Neither applies: no Android target, GL Compatibility renderer.

**Closed out this window:** Animation TrackCache hash collisions (GH-117030) — root fix landed in 4.7. `Input.parse_input_event` dropped button events (GH-119329) — fixed in 4.7 stable; this was the one that previously broke our MCP synthetic-input tests.

---

### 4.2 GDScript — language traps and proposals

**G1. `await` on a freed object's coroutine hangs the caller forever. (HIGH — silent deadlock)**
4.7 regression. If A does `await b.some_coroutine()` and B is `queue_free`'d mid-flight, the coroutine is correctly cancelled but A's `await` never resumes. No error, no timeout. In 4.6 the caller was released. Every cross-object await is now a potential deadlock.
```gdscript
await character.go_to(target)
if not is_instance_valid(character):
    return
```
Prefer signal-based notification across object boundaries; if you own the coroutine target, emit a "cancelled" signal before freeing so callers can await that and bail.
https://github.com/godotengine/godot/issues/120998 (opened 2026-07-06, open as of 2026-08-01)

**G2. `await` + untyped override prints "Compiler bug: Unresolved return" on every script load. (MED)**
Confirmed in both 4.7.0 and 4.7.1, no milestone set. Trigger: parent declares `func f() -> T`, child overrides with no return annotation, and the override body is `return await some_untyped_call()`. The compiler falls into a supposedly unreachable branch (`gdscript_byte_codegen.cpp:1846`). Code compiles and runs correctly, but the console spam breaks GUT/GdUnit4 double generation — doubles of `await`-containing typed methods hit the same path. Fix: annotate every override's return type.
https://github.com/godotengine/godot/issues/121584 (opened 2026-07-20, open as of 2026-08-01)

**G3. Lambda capturing `self` connected to a signal on a `RefCounted` leaks permanently. (MED, unfixed since Feb 2025)**
`my_signal.connect(func(): do_something())` inside a RefCounted subclass creates self → signal → lambda → self, a cycle RefCounted's free-tracking cannot break. No error, no warning. Still open; last activity Jul 5, 2026; no fix in 4.7. Use `Callable(self, &"method_name")`, disconnect in `_notification(NOTIFICATION_PREDELETE)`, or `CONNECT_ONE_SHOT` (narrows but does not close the window). Audit our codebase for `signal.connect(func(): ...)`.
https://github.com/godotengine/godot/issues/102327 (opened 2025-02-02, confirmed open 2026-07-05)

**G4. A script with `class_name` is silently rejected as an autoload. (LOW, usability)**
Adding a GDScript containing `class_name` as a Project → AutoLoad entry fails with a generic error that does not name the conflict. The script is otherwise valid. Fix: drop `class_name` from autoload scripts, or wrap the class in a `class_name`-free autoload shim.
https://github.com/godotengine/godot/issues/121744 (opened 2026-07-25, open/needs-testing as of 2026-08-01)

**G5. 4.7 GDScript surface changes to adopt. (MED)**
Variadic rest parameters (`func f(...args)`) are now supported — annotate the type or you get `UNTYPED_DECLARATION`. The `abstract` keyword (4.5+) is stable in 4.7, and GUT 9.7.0 added stricter return-type-aware doubling to match. Coroutine cancellation semantics changed (see G1). A double-fire of `UNTYPED_DECLARATION` on rest parameters in 4.8-dev was fixed and closed 2026-07-27.
https://github.com/godotengine/godot/issues/121838 (closed 2026-07-27)

**G6. String literals as block comments are on a deprecation path. (LOW now, mechanical later)**
Proposal #15279 (Jul 28, 2026) would add a `STANDALONE_EXPRESSION` warning in 4.x and forbid bare string literals entirely in 5.x. Not yet labelled accepted, but maintainer sentiment is cited as supportive — treat as directional, not final. Use `#` comments now; do not introduce `"""..."""` pseudo-comments.
https://github.com/godotengine/godot-proposals/issues/15279 (opened 2026-07-28, open)

**G7. Proposal landscape, Aug 2026. (informational)**
Open: **#14652** migrate GDScript to GDExtension ("GDScript 3.0", author @dalexeev, Godot 5.0 target, breaks-compat — would eliminate scripts-as-resources, `preload()`, runtime script attachment, possibly `static` var initializers); **#12639** `@static` annotation over the `static` keyword; **#1207** generic parameters / typed collections (`Array[T[U]]`, still unimplemented, active Jul 2026 discussion); **#4872** explicit interfaces; **#14487** stop suggesting abstract classes in autocomplete (labelled implementer-wanted). Rejected and archived in July: **#15144** forbid scripts inheriting their own inner classes (Jul 24), **#15139** narrowing type overrides in child classes (Jul 7; workaround is shadowing the property with a getter). **Provisional:** the trait system (#12567), typed Callables (#9286), unified type system (#11489) and strict mode (#6677) are all still open but showed no substantial activity in July 2026 — status is inferred from absence of activity, not from a maintainer statement. Watch @vnen's commit feed.
https://github.com/godotengine/godot-proposals (checked 2026-08-01)

---

### 4.3 Tooling

**T1. hi-godot/godot-ai is now the strongest free MCP option. (HIGH — evaluate)**
v3.0.7 shipped Jul 25, 2026 (v3.0.0 was Jul 13 — rapid cadence), 1.4k stars, MIT, 690 commits, ~43 MCP tools covering 120+ editor operations: scene building, node/script edits, signal wiring, UI/animation/particle config. Supports Claude Code plus 17+ MCP clients. Installable via snap, Asset Library, or ZIP. This is a clear path off godot-mcp-pro's paywall; worth a side-by-side on scene-tree read fidelity and error-log access, which are the two capabilities our workflow actually depends on.
https://github.com/hi-godot/godot-ai | https://pypi.org/project/godot-ai/ (fetched 2026-08-01)

**T2. GUT v9.7.1 stays our primary test framework. (HIGH — keep, no action)**
Jul 10, 2026; no release since. Confirmed compatible 4.6.1–4.7.1. v9.7.0 (Jun 19) added 4.7 compatibility and stricter return-type checking, and doubles now return type-appropriate defaults instead of `null`. v9.7.1 fixed OS-specific double parsing errors and spurious "Compiler bug" errors during double generation — note the overlap with G2.
https://github.com/bitwes/Gut/releases (fetched 2026-08-01)

**T3. GdUnit4 v6.2.0 requires Godot 4.5+ — a hard gate on staying at 4.6.x, fine at 4.7.1. (MED — worth evaluating)**
Jul 28, 2026. Reworked inspector UI, full error stack traces in reports, enhanced orphan-node detection. Compatible 4.5–4.7.1. The v6.0.x line broke backward compatibility with 4.4.x when it rebuilt on the 4.5 API. Complementary to GUT rather than a replacement: take it for CI where stack traces and orphan detection pay off. The "unstable" label on the Asset Store is a new-major-version convention, not a quality flag.
https://github.com/godot-gdunit-labs/gdUnit4/releases | https://store.godotengine.org/asset/mikeschulze/gdunit4-unit-testing-framework/ (fetched 2026-08-01)

**T4. Two new E2E testing tools; one is worth watching, one is not. (MED)**
**godot-e2e** v1.2.x (Godot 4.5+, Python 3.9+, 17 stars) runs the game out-of-process with a GDScript addon plus a synchronous Python/pytest client — no engine modifications, crash-safe, no async in tests. It fills exactly the integration-test gap GUT's unit model leaves open, which is where our MCP playtest sequences currently live. Very early; revisit in 3 months. **PlayGodot** v0.5.0 beta (37 stars) is "Playwright for Godot" via the debugger protocol, but requires a custom Godot fork and offers no GDScript-native test authoring — skip.
https://github.com/RandallLiuXin/godot-e2e | https://forum.godotengine.org/t/godot-e2e-out-of-process-e2e-testing-for-godot-using-python-and-pytest/141476 (2026-07) | https://github.com/Randroids-Dojo/PlayGodot (fetched 2026-08-01)

**T5. GDAgent is a new category: paid in-editor AI terminal workspace. (MED — trial only if multi-agent becomes a pain point)**
Asset Store update Jun 29, 2026. Rust backend (no Electron), bundles its own MCP, multi-agent split view (Claude Code, Codex, Antigravity, OpenCode, Aider, Copilot CLI, Mistral Vibe), sessions and layouts persist across restarts. Requires Godot 4.6+. Commercial after a 7-day trial. It positions as the IDE layer rather than an MCP server, so it is orthogonal to T1 — not urgent given godot-mcp-pro + Claude Code works today.
https://gdagent.dev/ | https://store.godotengine.org/asset/gdagent/gdagent/ (fetched 2026-08-01)

**T6. godot-ci is the CI answer when we need one. (MED — adopt on demand)**
abarichello/godot-ci, 1.1k stars, last updated ~May 2026. Docker image for headless exports with GitHub Actions and GitLab CI templates; deploys to GitHub Pages and itch.io; Windows/macOS/Web/Android with custom keystores. No 4.7 breaking changes reported. GdUnit4 slots into its pipeline patterns. No urgency until automated exports matter.
https://github.com/abarichello/godot-ci (fetched 2026-08-01)

**T7. Skip list and gaps. (LOW)**
**mkdevkit/godot-mcp** claims 173 tools across 26 categories with native UndoRedo integration and runtime IPC inspection, but has 4 commits and 7 stars (Asset Library submission 2026-07-28) — more tools on paper than godot-mcp-pro's 162, far less proven. Revisit above 100 stars. **Godot MCP Toolkit** (npgamedev) has insufficient public information to evaluate. **Profiling:** no new third-party Godot profilers emerged in July 2026; the story is still the built-in Profiler dock (moveable since 4.6), Tracy/Perfetto/Apple Instruments via custom builds (4.6), and CSV export. **Asset Store** notables beyond the above: YARD, Terrain3D, GodotSteam GDExtension; the headline consumer improvement is versioned downloads matched to your Godot minor.
https://github.com/mkdevkit/godot-mcp | https://godotengine.org/asset-library/asset/5245 (2026-07-28) | https://store.godotengine.org/asset/npgamedev/godot-mcp-toolkit/ (2026-08-01)

---

### 4.4 2D platformer patterns

**P1. Camera2D `position_smoothing` renders a fully gray screen on macOS + Compatibility in 4.7.1. (HIGH — our exact combo)**
Forward+ works; Windows Compatibility works; macOS Compatibility is broken. Our script-driven GameCamera follow already avoids this — do not "simplify" it to built-in smoothing while the issue is open. If smoothing is needed, `Tween`/`lerp()` in `_process` applied to `camera.offset`, not `global_position`, so it does not fight room limits.
https://github.com/godotengine/godot/issues/121843 (2026-07-28, open, needs testing)

**P2. Control offset transforms (new in 4.7) are the right way to animate the HUD. (HIGH)**
Control nodes gained offset transform animation, so `offset_left` / `offset_top` etc. can be animated in AnimationPlayer tracks without touching anchors or breaking anchor-based layout. Use this for health-bar slide-in, health-drain, damage-number popups, and status-icon entrances instead of `position`-based hacks.
https://godotengine.org/releases/4.7/ (2026-06-18)

**P3. Save/load: `Resource` subclass + JSON via `FileAccess` remains best practice. (HIGH, unchanged)**
`Resource` subclass with `@export` fields, `.tres` in development, `.res` binary for release. For Metroidvania room/item state, hold a `Dictionary` of discovered rooms and collected item IDs in an autoload and serialize with `FileAccess` + JSON — portable, and it avoids `ResourceLoader.load()` on untrusted data (Resources can embed executable scripts). KoBeWi's Metroidvania-System plugin automates storable-object ID assignment and room-state serialization for 4.6+, maintained as of mid-2026.
https://gdquest.com/tutorial/godot/best-practices/save-game-formats/ (2026)

**P4. Threaded room loading silently empties TileSet sources in 4.7. (HIGH if we add room streaming)**
Open regression since Jun 20, 2026, absent in 4.6.x. `ResourceLoader.load_threaded_request(path, "", true)` (sub-threads enabled) on a scene containing a TileMapLayer yields a TileSet with zero atlas sources at runtime: tiles do not render, collision is absent, `get_cell_tile_data()` errors. On-disk data is fine — the cache is poisoned. Workaround: synchronous `load()`, or `load_threaded_request(path, "", false)`; to avoid hitches, load the PackedScene async and instantiate synchronously in one frame. Document before any streaming work.
https://github.com/godotengine/godot/issues/120482 (2026-06-20, labeled regression, open)

**P5. Never toggle Area2D `monitorable` at runtime — toggle `collision_layer`. (MED)**
Confirmed across 4.3–4.7: changing `monitorable` while two areas already overlap does not re-evaluate the overlap and has no effect. Changing `collision_layer` / `collision_mask` does force re-evaluation and fires correct enter/exit signals. Also: toggling `monitoring` on the target while overlapping fires a spurious `area_exited` + `area_entered` pair. Use `collision_layer = 0` to disable, restore to re-enable. Applies to hurtboxes with invincibility frames, door sensors, and pickup zones — audit existing enable/disable code.
https://github.com/godotengine/godot/issues/121094 (2026-07-08, open, needs testing)

**P6. AnimationPlayer as a direct child of the scene root writes local paths instead of `%unique` paths. (MED — check our rig)**
Confirmed on 4.7 stable and 4.7.1 RC1. New tracks targeting a `%unique`-marked node get `MyNode` rather than `%MyNode`, so tracks for the same node with different path styles group separately and cross-animation sync breaks. Workaround: nest the AnimationPlayer one level down — `Root → AnimationRoot (Node2D) → AnimationPlayer`. If our player AnimationPlayer is a direct child of the CharacterBody2D root, apply this at the next rig revision.
https://github.com/godotengine/godot/issues/120921 (2026-07-04, open)

**P7. `DrawableTexture2D` (new in 4.7) is the minimap primitive — runtime only. (MED)**
Provides a texture you can draw into at runtime with the same `draw_*` API as `_draw()`, which is exactly the shape of a Metroidvania minimap that reveals rooms on exploration. Known bug: `get_image()` returns a blank Image inside `@tool` scripts (works at runtime), so editor-time map generation and editor preview are off the table until it is fixed.
https://godotengine.org/releases/4.7/ (2026-06-18) | https://github.com/godotengine/godot/issues/121113 (2026-07-08, open)

**P8. TileSet physics-layer painting spikes the GPU and freezes the editor. (MED, editor-only)**
Setting up or painting physics layers onto tiles in the TileSet editor spikes 3D GPU workload and hangs the editor on 4.7. No fix. Workaround: configure physics layers before drawing tiles, and exit physics-paint mode before returning to tile placement. No runtime impact; relevant during level-building sessions.
https://github.com/godotengine/godot/issues/120873 (2026-07-02, open)

**P9. Scene Paint Mode is the intended workflow for enemy and pickup placement. (MED, editor-only)**
New in 4.7, press `B` in the 2D editor: scatters real, editable scene instances across the viewport — instances carry their own scripts and signals, unlike baked tiles. Snap-offset and scaled-node behavior fixed Jun 24, 2026; in-editor instructions added in 4.8-dev1.
https://github.com/godotengine/godot/pull/120620 (2026-06-24) | https://github.com/godotengine/godot/pull/121227 (2026-07-11, merged to 4.8-dev1)

**P10. Screen shake pattern, confirmed stable through 4.7. (MED, unchanged)**
Apply shake to `camera.offset`, never `camera.global_position`. Square the trauma value for a natural decay curve. Use an additive model for overlapping shakes fired in rapid succession. Call `reset_smoothing()` after teleporting the player across a room boundary, or the camera slides in from the previous room's position.
https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424 (2026)

**P11. Low-relevance, tracked only. (LOW)**
HDR 2D (new in 4.7) breaks CanvasItemMaterial's `Subtract` blend mode — sprites render opaque over empty space. Do not enable HDR 2D — https://github.com/godotengine/godot/issues/121587 (2026-07-20, open). AnimationPlayer + AnimationTree on the same node have inconsistent editor-vs-runtime stop behavior, reinforcing that AnimationPlayer-only is the lower-risk path — https://github.com/godotengine/godot/issues/121885 (2026-07-29, open). TileMapLayer became an optional build module in 4.8-dev (`module_tilemap_enabled=no`) with no API or behavior change for standard builds; only matters if we ever ship a custom engine build — https://github.com/godotengine/godot/pull/121548 (2026-07-19, merged to 4.8-dev).

---

### 4.5 Performance and deployment

**R1. GL Compatibility avoids both active Apple Silicon Metal bugs. Renderer choice confirmed. (HIGH — no action)**
**#119436** (May 2026): 4.6.1+ games intermittently lock up with repeated `wait: timeout waiting for fence` from the Metal driver; reproduced on M1 Max, M2 MacBook Air, and M4 Ultra. The Metal maintainer (stuartcarnie) confirmed a patch and submitted a PR, but the fix status in 4.7.x is unconfirmed and the issue is tagged "For team assessment." **#120621** (Jun 2026): the 4.7 editor fails to launch on macOS 12 Monterey with `Library not loaded: MetalFX.framework`, across all 4.7.x builds; fix PR #121030 targets 4.8 and was **not** backported to 4.7.1. Both are Metal-path only (Forward+/Mobile). GL Compatibility uses OpenGL and never loads MetalFX. Do not switch to Forward+/Mobile on macOS until #119436 is confirmed fixed; if you must test Forward+, do it on macOS 13+.
https://github.com/godotengine/godot/issues/119436 (2026-05) | https://github.com/godotengine/godot/issues/120621 (2026-06)

**R2. No GDScript JIT in 4.7 or planned in 4.8 — typed GDScript remains the only lever. (MED)**
4.6 shipped bytecode-level wins on array iteration, dictionary access, and method-call overhead. 4.7 continues incremental VM work with no JIT and no interpreter rewrite; GDScript is still bytecode-interpreted. Neither 4.8-dev1 (Jul 6) nor 4.8-dev2 (Jul 21) announces GDScript speed work — both focus on editor UX and the Jolt Physics 5.6.0 upgrade. Bottleneck order for a 960×540 GL Compatibility Metroidvania: **draw calls > physics callbacks > `_process`/`_physics_process` node count > GDScript interpreter overhead.** GDScript is rarely the ceiling at our scope. Use explicit annotations (`var speed: float`, `Array[int]`, typed signatures), avoid untyped `Array` in hot paths, keep `_process` light, and profile before optimizing.
https://www.strayspark.studio/blog/gdscript-vs-csharp-godot-2026-choosing-scripting-language (2026) | https://dev.to/ziva/how-to-profile-gdscript-performance-in-godot-4-a-2026-guide-16jn (2026) | https://godotengine.org/article/dev-snapshot-godot-4-8-dev-1/ (2026-07-06) | https://www.linuxcompatible.org/story/godot-engine-48dev2-released-editor-qol-vcs-diffs-and-jolt-physics-update (2026-07-21)

**R3. Visual Profiler tree folding makes the profiler usable on real frames. (MED)**
Added in 4.7 dev 4. The profiler tree was previously unnavigable on frames with many draw calls or shader passes. After upgrading to 4.7.1, use it to confirm the 4.6 2D batching overhaul is producing correctly batched draw calls per frame. Profile exported builds, not the editor — editor overhead inflates timings. Budget is 16.67 ms at 60 fps.
https://godotengine.org/article/dev-snapshot-godot-4-7-dev-4/ (2026) | https://www.linuxcompatible.org/story/godot-47-dev-4-released/ (2026)

**R4. No new leak fixes in 4.7; detection got better instead. (LOW)**
The GDScript static-method memory leak (#86540) is not addressed in the 4.7 or 4.7.1 changelogs. A separate web-export memory leak was reported active in July 2026. GdUnit4 v6.2.0's enhanced orphan-node detection is the practical mitigation — it catches leaks in the test suite. Avoid static variables holding `RefCounted` objects unless deliberate; `queue_free()` spawned nodes before removing them from the tree. See also G3, which is the leak we are most likely to actually write.
https://github.com/godotengine/godot/issues/86540 (2024) | https://forum.godotengine.org/t/memory-leak-on-web-export/141309 (2026-07) | https://github.com/godot-gdunit-labs/gdUnit4/releases (2026-07-28)

**R5. Web export ceiling lifted: wasm64 + SIMD by default. (LOW — no web target)**
4.7 ships wasm64 templates, removing the 32-bit 4 GB browser memory ceiling, and enables WASM SIMD by default (previously opt-in) for a reported 1.5–2x gain on physics-heavy web builds with no code changes. Single-threaded export has been the default since 4.3, avoiding the SharedArrayBuffer header requirement. All modern evergreen browsers support wasm64 + SIMD.
https://godotengine.org/article/upcoming-serious-web-performance-boost/ (2026) | https://app.cinevva.com/news/2026-06-19-godot-4-7-released (2026-06)

**R6. GABE removes Android Studio only for on-device development. (LOW — no Android target)**
GABE (Godot Android Build Environment) shipped stable with 4.7: a companion app for the Godot Android editor that does full development including AAB/APK generation and direct publishing to Google Play and Meta Horizon Store, entirely on an Android/XR device. It does **not** change the macOS-side story — exporting to Android from the macOS editor still needs a locally configured Android SDK (Java/Gradle). When Android is added, use `sdkmanager` command-line tools rather than full Android Studio. 4.7 also added per-platform export template downloads, so you no longer pull one monolithic archive.
https://godotengine.org/article/gabe-stable-release/ (2026-06) | https://alternativeto.net/news/2026/6/godot-launches-gabe-companion-app-enabling-direct-android-and-xr-build-exports-on-device/ (2026-06)

---

## 5. Open / unresolved issues we may hit

| Issue | Status | Last seen | Re-scan trigger |
|---|---|---|---|
| **GH-121843** Camera2D `position_smoothing` gray screen, macOS + Compatibility | Open, needs testing | 2026-07-28 | Every 4.7.x patch and 4.8-dev snapshot — this is our exact hardware/renderer combo |
| **GH-120998** `await` across a freed object hangs caller forever | Open, no milestone | 2026-07-06 | 4.7.2 or 4.8-dev3, whichever ships first |
| **GH-120306** Stale `uid_cache.bin` silently crashes running game on debugger inspect | Open, no fix in 4.7.1 | 2026-08-01 | Monthly; also immediately after any bulk scene rename or resource move |
| **GH-121584** `await` + untyped override "Compiler bug: Unresolved return" | Open, no milestone; may slip to 4.8.1 | 2026-08-01 | 4.8 stable release; also on any GUT/GdUnit4 release that touches doubling |
| **GH-102327** Lambda captures `self`, leaks `RefCounted` | Open since 2025-02-02, no fix in 4.7 | 2026-07-05 | Quarterly, or when @vnen lands any Callable/lifetime work |
| **GH-120482** TileSet sources empty under `load_threaded_request(use_sub_threads = true)` | Open, labeled regression | 2026-06-20 | Before starting any room-streaming or background-preload work |
| **GH-121094** Area2D `monitorable` no-ops while overlapping | Open, needs testing (4.3–4.7) | 2026-07-08 | Quarterly; the `collision_layer` workaround is permanent, so low urgency |
| **GH-120921** AnimationPlayer at scene root writes local paths, not `%unique` | Open, confirmed 4.7 + 4.7.1 RC1 | 2026-07-04 | Next player-rig revision, or 4.7.2 |
| **GH-120480** AnimationStateMachine Sync mode error flood | Open, milestone 4.8 | 2026-08-01 | 4.8-dev3; blocks adopting AnimationTree for enemy AI |
| **GH-119436** Metal `wait: timeout waiting for fence` freeze on M-series | Open, "For team assessment"; patch PR submitted, merge unconfirmed | 2026-05 | Before any evaluation of Forward+/Mobile on macOS |
| **GH-120621** MetalFX launch crash, macOS 12 editor | Open; fix PR #121030 targets 4.8, not backported | 2026-06 | 4.8 stable; only if a macOS 12 machine enters the picture |
| **GH-121113** `DrawableTexture2D.get_image()` blank in `@tool` scripts | Open | 2026-07-08 | Before starting minimap work that wants editor-time preview |
| **GH-120873** TileSet physics-layer painting freezes editor | Open | 2026-07-02 | 4.7.2 / 4.8-dev3; nuisance only |
| **GH-121587** HDR 2D breaks CanvasItemMaterial `Subtract` blend | Open | 2026-07-20 | Only if we consider enabling HDR 2D |
| **GH-121681** 4.8-dev2 Upgrade Project Files crashes on RESET tracks | Open, 4.8-dev2 only, bisected to `bf898d1` | 2026-08-01 | 4.8-dev3; must be fixed before we migrate the project to 4.8 |
| **GH-121428** "Local to Scene" becomes embedded sub-resource | Open, no fix targeted, behavior change since 4.6 | 2026-08-01 | Quarterly |
| **GH-86540** GDScript static-method memory leak | Open, unaddressed in 4.7.x changelogs | 2024 (no 2026 activity found) | Quarterly, or if orphan-node counts climb in tests |
| **Proposal #15279** String literals as block comments to be warned/forbidden | Open, no acceptance label; maintainer sentiment supportive (provisional) | 2026-07-28 | Quarterly; act when a `STANDALONE_EXPRESSION` warning actually lands |
| **Proposal #14652** GDScript → GDExtension ("GDScript 3.0") | Open, breaks-compat, Godot 5.0 target | 2026-08-01 | Quarterly — long horizon, but it removes `preload()` and scripts-as-resources |
| **GH-121492 / GH-121503** Android letterbox touch; Forward+ close hang | Both open, milestone 4.8 (121492 is a release blocker) | 2026-08-01 | Only if we add an Android target or switch renderers |

---

## 6. Recurring scan recommendation

**Monthly (default cadence, ~45 min).** The July window produced 4 HIGH-relevance items and a full minor release in six weeks; quarterly would have missed the 4.7 release entirely, and weekly is not warranted while we are pre-content.

- **Every month:** `godotengine/godot` issues filtered to `regression` + `topic:2d` / `topic:gdscript` / `topic:animation`; godotengine.org/blog for releases and dev snapshots; GUT and GdUnit4 release pages; the §5 table rows marked monthly (GH-120306 especially).
- **Every month, watch for:** anything touching Camera2D + Compatibility on macOS (GH-121843); `await` / coroutine lifetime semantics (GH-120998, GH-121584); TileMapLayer or TileSet caching; new 4.7.x patch releases and whether our §5 rows landed.
- **Weekly, but cheap:** Godot Digest as a scan index — one issue read replaces a dozen queries. Escalate to a full crawl only if it names something in §5.
- **Quarterly:** proposal landscape (#14652, #15279, #1207, #12639) via @vnen's and @dalexeev's activity; MCP tooling re-evaluation (hi-godot/godot-ai star and release velocity, godot-e2e maturity); GodotCon recordings.
- **Event-driven, not calendar-driven:** re-scan immediately on any 4.8-dev snapshot (4.8-dev3 will resolve or confirm five §5 rows), before starting room streaming (GH-120482), before starting the minimap (GH-121113), and at the next player-rig revision (GH-120921).
- **If blocked:** GDScript semantics → @vnen (github.com/vnen) or the "Programming" category on forum.godotengine.org. Release/fix-landed questions → @akien-mga. 2D/TileMap/editor → @KoBeWi. macOS Metal → stuartcarnie on GH-119436. GUT → bitwes (responsive on GitHub issues). Deep engine design → Godot Contributors Chat, which requires an invitation, so file a GitHub issue first and let it route. Note that the Foundation's AI-contribution ban means **we do not file AI-authored issue text or PRs upstream** — write reports by hand.

---

## 7. Surprises

Four scope-changers this window.

1. **4.7 already shipped and 4.6.x is dead.** Godot 4.7 stable landed Jun 18, 2026 and 4.7.1 on Jul 15. Our 4.6.2 baseline is two minors behind a line that receives no further fixes. Every topic agent independently flagged the upgrade. This turns "4.7.1 upgrade under consideration" into a scheduling question, not a decision. https://godotengine.org/releases/4.7/
2. **4.7 introduced a cluster of regressions that land on our exact configuration.** Camera2D smoothing on macOS + Compatibility (GH-121843), `await` deadlock across freed objects (GH-120998), and the `uid_cache.bin` crash during debugger inspection (GH-120306) are all new in 4.7 and all touch code we run. The upgrade is correct but is not free — budget a verification pass, not a version bump.
3. **The Godot Foundation banned AI-generated code contributions on Jun 30, 2026.** Autonomous agent PRs, "vibe coding", substantial AI-generated code, and AI-generated PR body text are prohibited; limited assist (completions, regex, find-replace) remains allowed. Maintainers described the AI-slop PR flood as "demoralizing." This directly constrains how this project may contribute upstream — no agent-authored issues or PRs — and should improve review-queue signal over time. https://www.pcgamer.com/gaming-industry/open-source-game-engine-godot-will-no-longer-accept-ai-authored-code-contributions-we-cant-trust-heavy-users-of-ai-to-understand-their-code-enough-to-fix-it/
4. **A free MIT MCP server (1.4k stars) now rivals our paid one.** hi-godot/godot-ai v3.0.7 covers 120+ editor operations across ~43 tools with a weekly release cadence. Our entire dev workflow sits on godot-mcp-pro; a credible free alternative changes the tooling calculus and deserves a real evaluation rather than a note. https://github.com/hi-godot/godot-ai

*Also notable but not scope-changing:* Battlefield Studios (EA) began sponsoring Godot development in June 2026 — Godot Portal powers Battlefield Portal, the first major AAA publisher sponsorship. LimboAI reached v1.0 on Jun 19, 2026.

---

## 8. Glossary

- **GABE** — Godot Android Build Environment. Companion app (stable in 4.7) for full on-device Android/XR development and publishing, no PC required. Does not remove the Android SDK requirement for desktop-side export.
- **LibGodot** — 4.6 feature allowing Godot to be embedded as a library inside an external application.
- **Scene Paint Mode** — 4.7 2D-editor mode (key `B`) that scatters real, editable scene instances across the viewport, as opposed to painting baked tiles.
- **DrawableTexture2D** — 4.7 texture type you can draw into at runtime with the `draw_*` API. Minimap primitive.
- **HDR 2D** — 4.7 project setting enabling high-dynamic-range 2D rendering. Currently breaks CanvasItemMaterial `Subtract` blending.
- **Control offset transforms** — 4.7 capability to animate Control `offset_*` properties via AnimationPlayer without disturbing anchors.
- **UPF (Upgrade Project Files)** — Project → Tools editor action that rewrites project files for a newer engine version. Crashes on RESET animation tracks in 4.8-dev2.
- **uid_cache.bin** — `.godot/` cache mapping resource UIDs to paths. When stale, causes silent game crashes on debugger inspection in 4.7.x.
- **Jolt Physics** — 3D physics backend, default for new 3D projects since 4.6; upgraded to 5.6.0 in 4.8-dev2. No 2D relevance.
- **MetalFX** — Apple framework the Metal-linked Godot editor binary requires. Absent on macOS 12, hence the launch crash.
- **hi-godot/godot-ai** — free MIT MCP server for Godot; 120+ editor operations, ~43 MCP tools.
- **GDAgent** — commercial in-editor AI terminal workspace with a bundled MCP server and multi-agent split view. Rust backend.
- **godot-e2e** — out-of-process E2E test tool: GDScript addon plus a synchronous Python/pytest client, no engine modifications.
- **PlayGodot** — "Playwright for Godot" E2E automation over the debugger protocol; requires a custom engine fork.
- **godot-ci** — abarichello's Docker image and CI templates for headless Godot exports.
- **Metroidvania-System** — KoBeWi's plugin automating storable-object IDs and room-state serialization for 4.6+.
- **TileMapDual** — pablogila's addon providing automatic dual-grid autotiling for TileMapLayer.
- **LimboAI** — GDExtension behavior-tree + FSM framework; v1.0 Jun 19, 2026. **Beehave** is the lighter GDScript-native alternative with no GDExtension dependency.
- **YARD** — Yet Another Resource Database. Runtime resource query system with a table-view editor, on the new Asset Store.
- **Trauma-squared falloff** — screen-shake decay curve: square the trauma scalar before applying it to camera offset for a natural-feeling ramp-down.
- **`STANDALONE_EXPRESSION`** — proposed GDScript warning (#15279) for expressions with no effect, targeting the string-literal-as-block-comment idiom.
- **GDScript 3.0** — informal name for proposal #14652, migrating GDScript to a GDExtension for Godot 5.0. Would remove scripts-as-resources, `preload()`, and runtime script attachment.
