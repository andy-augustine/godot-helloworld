# Godot Current Intel — Synthesized Deliverable
*Synthesized: 2026-10-01 | Intel window: September 2026 (delta since the 2026-09-01 crawl)*
*Canonical path retained per backlog #12; the crawl tracks 4.7.x / 4.8-dev, not 4.6.x.*
*Project context (verified against the repo 2026-10-01): **Godot 4.6** (`config/features = ("4.6", "GL Compatibility")` in `project.godot`), GDScript-only, macOS Apple Silicon, `gl_compatibility` renderer, CharacterBody2D player, `GameCamera` room-lock, TileMapLayer rooms, AnimationPlayer rig, MCP-driven dev (godot-mcp-pro). The project is **still on 4.6**: last month's "upgrade to 4.7.2 now" has not been done.*
*Inputs: `research/crawl/sourcemap.md` plus five topic crawls (`topic-engine-quirks.md`, `topic-gdscript-language.md`, `topic-tooling.md`, `topic-2d-platformer.md`, `topic-performance.md`), all crawled 2026-10-01. Cited below as [SM], [EQ], [GD], [TL], [2D], [PF].*

**Provenance caveats (read before acting).**
- [2D] could not reach the GitHub API this session. Its issue-status claims (GH-121681, GH-121094, GH-121843) come from forum threads and changelog absence, not from the issues themselves. They are marked **provisional** below.
- [EQ] says 4.8 reached **dev7**, based on one issue (GH-124029, Sep 30) citing "4.8.dev7". Every other input says dev5. Treat dev7 as **provisional** until the blog posts it.
- The inputs disagree on when 4.8 stable ships: "late Q4 2026" [TL] vs "est. Q1 2027" [PF]. All inputs agree beta is likely in late October. This doc does not commit to a stable date.
- **Correction to last month's deliverable and to [2D] P-O.** Both said `GameCamera` uses a script-driven `lerp` and does not use built-in smoothing. That is wrong. `camera/GameCamera.gd:52` sets `position_smoothing_enabled = true`, and `World.gd:124,151` re-enables it after room transitions. The script only computes anchor plus lookahead (`GameCamera.gd:68`). This makes GH-121843 a live upgrade blocker; see §4.4.

---

## 1. TL;DR

- **Engine:** `Input.is_action_pressed()` returns the opposite value for Shift/Ctrl/Alt in 4.7.2 (GH-120528, open). Our Shift-bound dash uses `is_action_just_pressed`, so it is safe. Keep it that way.
- **GDScript:** An untyped function first called from several threads at once can crash the VM (#124010, open). Typed parameters avoid the code path. We use no threads today.
- **Tooling:** Beckett is a new MCP server that runs as a pure GDScript plugin (free MIT Lite tier, no Node sidecar). It is the strongest backup if godot-mcp-pro stalls.
- **2D platformer:** Before upgrading to 4.7, gate on GH-121843 (Camera2D built-in smoothing shows a gray screen on macOS + Compatibility). Our camera does use built-in smoothing.
- **Performance:** 4.7.1+ deadlocks on M4/M5 Macs under macOS 26 with Metal/Vulkan (GH-123481). GL Compatibility, which we use, avoids it. Don't switch renderers.

---

## 2. Active sources, ranked

S/N updates this month are in *italics*.

### HIGH

- **`godotengine/godot`**: main engine and ground truth for regressions. https://github.com/godotengine/godot [SM]
  *The September issue flow was dense and relevant: 10+ new issues touch our stack (GH-123846, GH-123189, GH-123593, GH-124010, GH-123481, and others). Still the single most valuable source. [EQ][GD][PF]*
- **`godotengine/godot-proposals`** (Discussions): shows where GDScript is heading. https://github.com/godotengine/godot-proposals/discussions [SM]
  *The unified type system (#11489) closed "not planned" in Sep 2026. The live threads are now nullable types (#162), structs (#7329), nonvirtual functions (#15491), and annotation plugins (#14940). [GD]*
- **`godotengine/godot-docs`**: doc PRs show behavior changes. 4.7 docs are current. https://github.com/godotengine/godot-docs [SM]
- **`godotengine.org/blog`**: authoritative channel for releases, dev snapshots and policy. 4.8-dev5 posted Sep 10, 2026. https://godotengine.org/blog [SM][PF]
- **`forum.godotengine.org`**: official Discourse. https://forum.godotengine.org [SM]
  *Upgraded in practice: [2D] got its Area2D, camera and TileMapLayer status from forum threads dated Sep 2026. Some regressions show up here before they reach the issue tracker.*
- **`bitwes/Gut`**: our test framework. v9.7.1 (Jul 11, 2026), no September release. https://github.com/bitwes/Gut [SM][TL]
- **`godot-gdunit-labs/gdUnit4`**: v6.2.0 (Jul 30, 2026), no September release. https://github.com/godot-gdunit-labs/gdUnit4 [SM][TL]
  *Effectively MED for us: a GDScript-only project gets nothing from its C#/JUnit strengths. [TL]*

### MED

- **Godot Asset Store**: `store.godotengine.org`, launched with 4.7. *Now the discovery channel for new plugins: Beckett, SaveKit, PhantomCamera and Godot MCP Toolkit all surfaced here this month. [TL][2D]*
- **`r/godot`**: 228k+ members per [SM]. *The growth figure (from ~88k) is **provisional**: [SM] gives no source for either number. Useful for trends, not for depth.* https://reddit.com/r/godot
- **Godot Digest** newsletter: weekly curated roundup, good as a cheap scan index. https://godotdigest.substack.com [SM]
- **Jettelly blog**: editorial "what shipped" breakdowns. https://jettelly.com/blog [SM]
- **Official Discord**: ~74–79k members. Answers disappear, so prefer the forum. https://discord.com/invite/godotengine [SM]
- **X `@godotengine`** / **Mastodon `@godotengine@mastodon.gamedev.place`**: release announcements. Mastodon carries more technical discussion (@clayjohn is active there). [SM]
- **GDQuest** (YouTube): accessible Godot 4 tutorials. https://www.youtube.com/c/gdquest [SM]
- **GameFromScratch**: fastest reliable news summaries. *It broke the W4Build discontinuation this month. [TL]* https://gamefromscratch.com [SM]
- **`chickensoft-games`**: C# tooling. GodotEnv is useful for pinning a CI binary. *No September activity. [TL]* https://github.com/chickensoft-games [SM]
- **`contributing.godotengine.org`**: area owners and team leads. https://contributing.godotengine.org/en/latest/organization/areas.html [SM]

### LOW

- **HackerNews**: only worth checking on releases. [SM]
- **Bastiaan Olij YouTube**: XR only, posts irregularly. [SM]
- **Old Asset Library** (`godotengine.org/asset-library`): being phased out. *Still lists Godot AI Workbench (#5353) and ProProfiler (#20244). [TL]* [SM]
- **`godotengine.itch.io` devlog**: duplicates the blog. [SM]
- **Third-party release summaries** (warp2search.net, opensourceforu.com): *[2D] and [SM] leaned on these for dev5 and 4.7.2 details. Accept them only as pointers to the official blog post.*

### SKIP

- `godotforums.org` (unofficial; easily confused with the official forum). KidsCanCode (no 2026 activity). The old `godot-contributing-docs` repo (archived). r/godot for deep technical answers. [SM]

---

## 3. Contributors to follow

| # | Name / handle | Domain | Primary link | Why useful | Example contribution |
|---|---|---|---|---|---|
| 1 | Rémi Verschelde (@akien-mga) | Release management; project policy | https://github.com/akien-mga | Triages every release. The best person to answer "did this fix land?" | Wrote the Jul 2026 AI-contribution ban announcement [SM] |
| 2 | George Marques (@vnen) | GDScript type system; GDExtension | https://github.com/vnen | Owns the GDScript language spec. The authority on typing, closures and annotations | Leads the Callable type-hint design [GD] |
| 3 | Lukas Tenbrink (@Ivorforce) | GDScript; compiler internals | https://github.com/Ivorforce | GDScript area maintainer; drives language-tooling proposals | Annotation plugins proposal #14940 [SM][GD] |
| 4 | Juan Linietsky (@reduz) | Core architecture; GDScript VM | https://github.com/reduz | Engine co-creator. Still commits, and shapes the type-system direction | Struct-like types proposal discussion [SM][GD] |
| 5 | Clay John (@clayjohn) | Rendering; shaders; Compatibility renderer | https://github.com/clayjohn | Rendering maintainer. Most relevant to the Metal deadlock and GL Compat questions. Active on Mastodon | SSR rewrite (4.6 per [SM]'s table; [SM] also mentions "4.7 SSR notes", so the version is ambiguous) [SM] |
| 6 | bitwes | GUT testing framework | https://github.com/bitwes | Sole GUT maintainer and responsive. Watch for a 4.8 compat release | GUT v9.7.1, Jul 2026 [SM][TL] |
| 7 | KoBeWi | 2D editor; TileMap; Metroidvania-System plugin | https://github.com/KoBeWi | The Metroidvania-System plugin is still our best-fit save/room-state option. Owns the 2D domain upstream | KoBeWi Metroidvania-System (room persistence, ability flags) [2D] |
| 8 | HP van Braam (@hpvb) | Physics (Jolt); build systems | https://github.com/hpvb | Contact for physics regressions such as RigidBody2D sleep and GH-118473 | Made Jolt the 3D default in 4.6 [SM] |
| 9 | Pāvels Nadtočajevs (@bruvzg) | Text/fonts; input; GDExtension | https://github.com/bruvzg | Owns text layout and input. Relevant to GH-122176 (RichTextLabel) and the modifier-key bug | GDExtension parent-class fix in 4.7.2 [SM] |
| 10 | David Snopek (@dsnopek) | Web/WASM export; networking | https://github.com/dsnopek | Owns the web export. Relevant to the heap-leak issue #123134 if we ever ship a web build | wasm64 export in 4.7 [SM][PF] |
| 11 | Mike Schulze (MikeSchulze) | GdUnit4; CI/CD | https://github.com/godot-gdunit-labs/gdUnit4 | Best reference for headless Godot testing in CI, even for GUT users | GdUnit4 v6.2.0 GitHub Actions templates [TL] |
| 12 | Jayden Sipe | 2D editor UI | https://github.com/godotengine/godot/pull/121080 (*provisional*: [2D] cites GH-121080 as an issue/PR number; no handle given) | Authored the 4.8 2D toolbar redesign. Any MCP tool that clicks toolbar buttons by position may break | 2D editor toolbar redesign, 4.8-dev5 [2D][TL] |
| 13 | GameFromScratch | Engine news | https://gamefromscratch.com | Fastest reliable summaries. Not a contributor, but the best fast index | W4Build discontinuation and W4 Series B coverage [TL][SM] |

---

## 4. Findings

Ranked within each subsection by relevance to this project. Cross-topic duplicates are listed once, in the most relevant subsection: the 4.8 property speedup is under Performance, the 4.8 toolbar change under Tooling, and 4.8-dev5 status under §7.

### 4.1 Engine — quirks and regressions

1. **`Input.is_action_pressed()` returns the opposite value for modifier keys (GH-120528, OPEN, 4.7.2).** In multi-scene projects, Shift/Ctrl/Alt start reading `true` at launch and flip on the first press. `is_action_just_pressed()` is unaffected. The bug is timing-dependent: adding a `print()` in `_ready()` hides it. Cause: a modifier event registered at startup with no matching release. A second user reproduced it on 4.7.2 (GH-122728, Aug 22). **Our exposure:** the `dash` action is bound to Shift (`physical_keycode 4194325`, `project.godot:64`) and is read with `Input.is_action_just_pressed("dash")` (`player/player.gd:348`), so it is safe today. Any future hold-to-run on Shift must track state with just_pressed/just_released, not `is_action_pressed`. This is distinct from the Shift simultaneous-release bug fixed in 4.7.2. https://github.com/godotengine/godot/issues/120528, https://github.com/godotengine/godot/issues/122728 [EQ]
2. **Saving a `.tscn` silently embeds external subresources as internal ones (GH-123846, OPEN, filed Sep 26).** Saving a parent scene can turn an `[ext_resource]` into an inline `[sub_resource]`. This corrupts diffs and breaks other scenes that share the resource. Our MCP-driven workflow saves scenes often, so exposure is high. After MCP scene edits, check `git diff` for new `[sub_resource]` blocks replacing `[ext_resource]` references. *Version scope is provisional:* [EQ]'s TL;DR says 4.8-dev, its body says "4.7.x and 4.8 dev", and 4.6 is untested. https://github.com/godotengine/godot/issues/123846 [EQ]
3. **RichTextLabel inside a Container freezes, then crashes (GH-122176, OPEN, 4.7 regression, not in 4.6).** The trigger is dynamically resizing the parent Container while the label is visible. It would hit dialog boxes and item-description HUDs after a 4.7 upgrade. Workaround: fixed `min_size`, or a plain `Label` for frequently resizing HUD text. We use no RichTextLabel today. https://github.com/godotengine/godot/issues/122176 [EQ]
4. **AnimationPlayer capture track segfaults when its target has been freed (GH-123593, OPEN, 4.8-dev; 4.7.x status unconfirmed).** Call `is_instance_valid()` on targets before `play()`. Relevant to the player rig and enemy death animations. https://github.com/godotengine/godot/issues/123593 [EQ]
5. **Relative paths inside binary resources resolve wrongly (GH-123189, OPEN, 4.8-dev).** Affects only binary `.res`/`.scn`; text `.tres`/`.tscn` are fine. We use text format, so no exposure. Keep it that way. https://github.com/godotengine/godot/issues/123189 [EQ]
6. **Carried forward, all still open:** the RigidBody2D sleep freeze (forum-only report), the AnimationPlayer editor freeze on tree edits (GH-120379), the RigidBody2D Frozen-Static shape desync (GH-118473), and TextureButton focus (GH-115782, no update). [EQ]
7. **Mouse-button actions fire twice when the mouse is moving (GH-122320, OPEN).** Keyboard actions are unaffected. Relevant only to mouse-driven menus. https://github.com/godotengine/godot/issues/122320 [EQ]
8. **Tab focus escapes a SubViewportContainer (GH-123744, OPEN).** Matters only if a menu renders inside a SubViewport. https://github.com/godotengine/godot/issues/123744 [EQ]

### 4.2 GDScript — language traps and proposals

1. **Untyped functions plus multi-threading can crash (#124010, OPEN, filed Sep 30).** The `OPCODE_OPERATOR` first-run cache writes its signature before its function pointer, without a lock. A second thread can call through an uninitialized pointer. Fixes: typed parameters (which route to `OPCODE_OPERATOR_VALIDATED`, with no cache), or pre-warming on the main thread. We use no `WorkerThreadPool` today. This becomes a rule the moment room streaming adds threads. https://github.com/godotengine/godot/issues/124010 [GD]
2. **Lambda capture depends on context (#117348, OPEN, labeled `documentation`).** Loop variables behave by reference (the classic "prints 2, 2, 2"). An outer local reassigned after the lambda is created stays snapshotted by value. Use a one-element Array for mutable accumulators. No VM change is expected. https://github.com/godotengine/godot/issues/117348 [GD]
3. **Hot-reload leaves newly added typed members as `nil` on live instances (#119057; fix in PR #123040).** This hits MCP hot-reload directly. After adding a new typed member declaration, stop and restart the scene before trusting a playtest. https://github.com/godotengine/godot/issues/119057 [GD]
4. **`:=` inference silently collapses to `Variant` when the right-hand side is untyped.** Intentional and unchanged in 4.7.2. Annotate explicitly: `var cam: GameCamera = ...`. [GD]
5. **Two older traps, unchanged.** `Callable.bind()` creates a new Callable on every call, so store the bound Callable for `disconnect()`. `await` inside a lambda body does not suspend the caller; move it into a named function (the same root cause blocks top-level `await` in MCP-injected scripts). [GD]
6. **Typed `Dictionary[K, V]` covariance tightened in 4.8-dev5 (#123383, closed "not planned").** `Dictionary[MyEnum, String]` no longer converts to `Dictionary[Variant, String]`. Match key types exactly or use an untyped `Dictionary`. Treat as permanent. https://github.com/godotengine/godot/issues/123383 [GD]
7. **String literals used as comments are deprecated in 4.8 (PR #121833) and become errors in 5.x.** Use `##`. **Our exposure: none.** No `"""` blocks exist in project `.gd` files (verified 2026-10-01). https://github.com/godotengine/godot/pull/121833 [GD]
8. **A self-referential typed `@export` array (`Array[NavNode]` inside NavNode) leaks a resource at exit (#122601, closed "not planned").** Use the parent type, `Array[Node]`. Matters for headless GUT runs that check for clean shutdown. https://github.com/godotengine/godot/issues/122601 [GD]
9. **A native `RefCounted` freed in the middle of a method call causes a use-after-free (#122367, OPEN).** Applies only to GDExtension objects. Hold a local strong reference. No exposure for us. https://github.com/godotengine/godot/issues/122367 [GD]
10. **Proposals:** nullable types (#162 / PR #76843) are on hold. Structs (#7329) and Callable type hints are active, with no milestone. Nonvirtual functions (#15491) were opened Sep 2026. The typed-Array `as`-cast (#54311) is still open; use the `Array[T](source)` constructor instead. The unified type system (#11489) was closed "not planned". Nothing is actionable before 4.8 stable. [GD]

### 4.3 Tooling

1. **Beckett (`beckettlab/beckett-godot-mcp`) is a new zero-sidecar MCP server (first listed Jul 13, 2026, Godot 4.2+).** It is a single GDScript plugin over local HTTP, with no Node or Python. The free Lite tier (MIT) covers running the game, screenshots, the live remote scene tree and node state, performance monitors, log tailing, and GDScript validation before write. Full is $15, and its contents are not publicly detailed. It is the best backup if godot-mcp-pro stalls. Less battle-tested than godot-mcp-pro. https://github.com/beckettlab/beckett-godot-mcp, https://store.godotengine.org/asset/beckett/beckett-godot-mcp/ [TL]
2. **The 4.8 2D editor toolbar redesign (GH-121080) and the move of main-screen plugins to EditorDock will break position-based MCP toolbar clicks and main-screen plugins.** godot-mcp-pro, GUT and Beckett will each need a 4.8 compat release. Don't upgrade the engine until all three ship one. [TL][2D][SM]
3. **GUT v9.7.1 is still current; no September release.** It is the right choice and is not under migration pressure. Note for the 4.7 upgrade: v9.7.0 made doubles return type-appropriate defaults instead of `null`. That breaks any test relying on `stub(...).to_do_nothing()` returning `null`. https://github.com/bitwes/Gut [TL]
4. **W4Build is discontinued.** Users were migrated by Jan 2026 and the code was open-sourced. For CI, the options are community GitHub Actions templates, `godot --headless --export`, or GodotEnv for binary pinning. [TL]
5. **godot-mcp-pro PR #25** (`youichi-uda/godot-mcp-pro/pull/25`), our in-flight local fork patch, has no status update this crawl. [TL]
6. **Godot AI Workbench** (Asset Library #5353) is a 129-tool local-first MCP connector with LSP diagnostics and UID repair. Its license is unconfirmed. Watch its adoption; don't adopt yet. https://godotengine.org/asset-library/asset/5353 [TL]
7. **GdUnit4 v6.2.0** added GitHub Actions templates. 4.7 compatibility is still unconfirmed. Low priority for a GDScript-only project. [TL]
8. **Low priority:** ProProfiler (#20244) adds convenience over the built-in profiler, not new capability. `erodenn/godot-mcp-runtime` has ~30 stars and no activity since May 2026. Godot MCP Toolkit (#23816) has no usable data yet. [TL]

### 4.4 2D platformer patterns

1. **GH-121843 (Camera2D built-in smoothing renders a gray screen on macOS + Compatibility) blocks a 4.7 upgrade for us.** `GameCamera.gd:52` and `World.gd:124,151` enable `position_smoothing_enabled`. That is our exact platform, renderer and code path. [2D] reports the issue is still open and absent from the 4.8-dev5 fix list. *Status is provisional:* the GitHub API was unavailable, so this rests on changelog absence. We see no gray screen on 4.6, so the bug appears to be 4.7-era. Before upgrading, either verify a fix or replace built-in smoothing with a script lerp in `_physics_process`. Community consensus in the Sep 2026 Metroidvania camera thread already favors the script lerp. https://github.com/godotengine/godot/issues/121843, https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882 [2D]
2. **GH-121681 (4.8-dev2 crash when RESET tracks reference missing node paths): the watch trigger fired with dev5, but status could not be verified.** *Provisional:* GitHub API unavailable. Don't assume it is fixed. Before any 4.8 migration, open the issue manually. If it is still open, make every RESET track cover every property path used by the player's other animations. https://github.com/godotengine/godot/issues/121681 [2D]
3. **Area2D `monitorable` toggle is a no-op on re-enable (GH-121094; open in 4.7.2/4.8-dev5 per Sep 2026 forum threads, provisional).** Toggle `collision_layer`/`collision_mask` instead. **Our exposure: none today.** `doors/Door.gd` does not touch `monitorable` (verified 2026-10-01). Keep the rule for the door re-entry refactor. https://forum.godotengine.org/t/whats-the-latest-status-on-area2d-not-detecting-staticbody2d-if-not-set-to-monitorable/140997 [2D]
4. **Carried pitfalls:** an AnimationPlayer at the scene root writes wrong paths (GH-120921); nest it one level down at the next rig revision. TileSet sources come up empty under threaded load (GH-120482); the 4.7.2 fix is unverified, so re-test before room streaming. DrawableTexture2D shows a blank image in `@tool` scripts (GH-121113); this matters before minimap editor-preview work. [2D]
5. **SaveKit** (fernforestgames, v0.1, MIT, Godot 4.5+) is a general save plugin: group-based, with JSON/binary serializers. KoBeWi Metroidvania-System is still the better fit for room/ability persistence. Consider SaveKit only if KoBeWi proves too opinionated. https://store.godotengine.org/asset/fernforestgames/savekit/ [2D]
6. **The TileMapLayer API is stable:** no changes in 4.7.2 or 4.8-dev5. Best practice: `set_cells_terrain_connect()` for bulk writes, never per-frame `set_cell()` loops, and `local_to_map()` before any call. https://forum.godotengine.org/t/best-architectual-practices-for-using-the-tilemaplayer-node-programmatically/116440 [2D]
7. **PhantomCamera** is the most-recommended third-party camera, but Metroidvania users report that a scripted Camera2D does the same job with less setup. Don't adopt it. [2D]

### 4.5 Performance and deployment

1. **CanvasShaderRD deadlocks on M4/M5 Macs under macOS 26.x (GH-123481, OPEN, 4.7.1+ regression, assessed for the 4.8 milestone, no 4.7.3 patch planned).** Metal and Vulkan/MoltenVK both freeze on the splash screen. GL Compatibility avoids it, and that is our renderer (`project.godot:73`). Don't switch renderers on macOS until 4.8 confirms a fix, and test on M-series hardware when you do. https://github.com/godotengine/godot/issues/123481 [PF]
2. **Typed GDScript is up to 59% faster for vector math.** On M2 Max: Vector2 distance 58.8% faster, multiply 35.9%, add 34.2% versus untyped. This is a stable path in 4.7. It is the cheapest `_physics_process` win available, and it also avoids #124010 (§4.2.1). https://essay.utwente.nl/essays/107857 [PF]
3. **4.8-dev4 makes object property access 1.6× faster and saves ~12 MB RAM by unifying property maps (GH-122596).** Hot-path property reads dominate a platformer's GDScript cost. Benchmark `_physics_process` against a 4.7 baseline before adopting 4.8. Not stable yet. [PF][SM]
4. **4.8-dev5 adds Frame Time and Information panels to the 2D editor.** Combined with dev4's Visual Profiler tree-folding, it is a real profiling upgrade over 4.7. Not stable. Mip-level texture streaming, also in dev5, is a 3D-only benefit. [PF]
5. **macOS distribution:** use ad-hoc signing for playtests (users right-click > Open). For public release, use a Developer ID, `notarytool`, and stapling. 4.7 templates include the entitlement structure. https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html [PF]
6. **The web export leaks JS heap memory (#123134, OPEN, 4.6 through 4.8-dev4, no workaround).** A minimal scene grew from ~128 to ~154 MB of typed arrays in 40 minutes. Relevant only if we add a web build. If we do, start single-threaded (no COOP/COEP), and wasm64 lifts the 4 GB ceiling. https://github.com/godotengine/godot/issues/123134 [PF]
7. **The Mobile renderer crashes on launch with no GL fallback (4.7.2, OPEN).** No exposure. [PF]

---

## 5. Open / unresolved issues we may hit

"Last-seen" is the most recent date any input confirmed the issue's status.

| Issue | Status | Last-seen | Re-scan trigger |
|---|---|---|---|
| GH-121843: Camera2D `position_smoothing` gray screen, macOS + Compat | Open (provisional; changelog-absence only) | 2026-10-01 | **Before the 4.7 upgrade.** Our camera uses built-in smoothing. Also every 4.7.x patch and 4.8 RC |
| GH-120528: `is_action_pressed()` inverted for modifier keys | Open, no ETA | 2026-09-14 | Any 4.7.x patch; before adding any hold-on-Shift mechanic |
| GH-123846: `.tscn` save embeds external subresources | Open, needs testing | 2026-09-26 | Every crawl; immediately if a `git diff` shows unexpected `[sub_resource]` blocks |
| GH-121681: 4.8 crash on RESET tracks with missing paths | Unverified (provisional) | 2026-09-01 (last verified) | **Fired.** Verify manually before any 4.8 beta trial |
| GH-122176: RichTextLabel/Container freeze and crash (4.7 regression) | Open, confirmed | 2026-09-22 | Before the 4.7 upgrade, if dialog or HUD text uses RichTextLabel |
| #124010: `OPCODE_OPERATOR` thread-race crash (untyped functions) | Open | 2026-09-30 | Before room streaming or any `WorkerThreadPool` use; 4.8 beta |
| GH-123481: CanvasShaderRD deadlock, M4/M5 + macOS 26 (Metal/Vulkan) | Open, 4.8 milestone | 2026-10-01 | Before any renderer switch; 4.8 stable |
| GH-120482: TileSet sources empty under threaded load | 4.7.2 fix unverified | 2026-10-01 | Before room-streaming work (manual test) |
| GH-121094: Area2D `monitorable` re-enable no-op | Open (provisional; forum-sourced) | 2026-09 (forum) | Before the door re-entry refactor |
| GH-123593: AnimationPlayer capture track segfault on freed target | Open, confirmed | 2026-09-18 | 4.8 beta; before capture-mode tracks on enemies |
| #119057 / PR #123040: hot-reload leaves new typed members `nil` | Fix in progress | 2026-10-01 | When PR #123040 merges (removes the MCP restart step) |
| GH-120921: AnimationPlayer at scene root writes wrong paths | Open | 2026-10-01 | Next player-rig revision |
| GH-120379: AnimationPlayer editor freeze on tree edits (4.7) | Open | 2026-10-01 | Each 4.8 dev snapshot |
| GH-118473: RigidBody2D Frozen-Static shape desync | Open since Apr 2026 | 2026-10-01 | Before physics props/crates |
| RigidBody2D sleep freeze (forum-only report) | Open, no fix | 2026-10-01 | Before physics props; each 4.7.x patch |
| GH-121113: DrawableTexture2D `@tool` blank image | Open | 2026-10-01 | Before minimap editor-preview work |
| GH-123189: binary resource relative paths broken | Open | 2026-09-04 | Only if we adopt binary `.res`/`.scn` |
| #123134: web export JS heap leak | Open, awaiting triage | 2026-10-01 | Only if a web build is planned |
| GUT 4.8 compat release (v9.8.x) | Not released | 2026-10-01 | 4.8 stable |
| godot-mcp-pro PR #25 | In flight, no update | 2026-10-01 | Every crawl |

---

## 6. Recurring scan recommendation

**Monthly, ~45 minutes. Keep the cadence, plus one event-driven re-scan when 4.8 beta lands (expected late October).**

Why monthly: September produced 10+ new open issues touching our stack, a GDScript crash class (#124010), a new MCP alternative (Beckett), and two to four 4.8 dev snapshots. Quarterly would miss the 4.8 beta window, where GH-121681 and the compat releases need checking. Weekly is not warranted: no 4.7.x patch shipped in September, and most of the delta is pre-release churn we won't adopt.

**Every month (core loop):**
- `godotengine/godot` issues filtered to `regression` plus `topic:2d`, `topic:input`, `topic:gdscript`, `topic:animation`, `topic:core` (resource saving).
- Every §5 row with no event trigger. Re-verify GH-121843, GH-121681 and GH-121094 directly on GitHub, because this month's statuses are provisional.
- `godotengine.org/blog` for 4.7.3, 4.8 beta/RC, and confirmation of dev6/dev7.
- GUT, GdUnit4, Beckett and godot-mcp-pro release pages.

**Watch for:** a 4.7.3 patch, and whether it fixes GH-121843, GH-120528 or GH-122176 (all three gate our 4.7 upgrade). The 4.8 beta announcement and any breaking API changes. `.tscn` serialization changes. Input modifier-key fixes.

**Weekly, cheap (~5 min):** use the Godot Digest as a scan index. Escalate to a full crawl only if it names a §5 row.

**Quarterly:** re-rank sources and contributors. Review the GDScript proposal landscape (@vnen, @Ivorforce). Re-evaluate MCP tools (Beckett adoption, Godot AI Workbench, Godot MCP Toolkit). Review GodotFest Munich (Nov 11–12, 2026) recordings in the Q4 pass.

**Event-driven, re-scan immediately when:**
- 4.8 beta or RC ships (GH-121681, GH-123593, GH-120379, compat releases, property-speedup benchmark).
- A 4.7.x patch ships (the 4.7 upgrade gate).
- Before the 4.7 upgrade itself (GH-121843, GH-122176, the GUT v9.7.0 doubles change).
- Before room streaming (GH-120482, #124010), the minimap (GH-121113), the next player-rig revision (GH-120921), or the door re-entry refactor (GH-121094).

**Who to ping if blocked:**
- GDScript semantics: @vnen, or the Programming category on `forum.godotengine.org`.
- "Did this fix land?" / release status: @akien-mga.
- 2D, TileMap, editor: KoBeWi.
- Input and text (GH-120528, GH-122176): @bruvzg.
- Physics (RigidBody2D): @hpvb.
- Rendering / Compatibility / Metal deadlock: @clayjohn (Mastodon).
- GUT: bitwes on GitHub issues.

**Standing constraint:** the Foundation's AI-contribution ban (since Jul 1, 2026) means anything filed upstream must be human-authored and say so. https://godotengine.org/article/contribution-policy-2026/ [SM]

---

## 7. Surprises

1. **Our own camera contradicts last month's guidance.** The prior deliverable said `GameCamera` uses a script lerp and "must not be simplified to `position_smoothing_enabled = true`". The code already uses built-in smoothing (`camera/GameCamera.gd:52`). That turns GH-121843 from "don't refactor" into "fix before upgrading to 4.7". It also argues for verifying topic-agent claims about our code against the repo every crawl.
2. **The project is still on Godot 4.6.** Last month's TL;DR said to upgrade to 4.7.2 now. It hasn't happened, and September added three 4.7-era upgrade gates (GH-121843 per item 1, GH-122176, and the GUT v9.7.0 doubles change), while 4.7.2's fixes are still unused. Decide this month whether to upgrade or wait for 4.7.3. Don't let it drift.
3. **4.8 may be at dev7, not dev5 (provisional).** It rests only on GH-124029 citing "4.8.dev7". If true, two snapshots shipped in September and beta (late October) is closer than [SM]'s picture. [EQ]
4. **W4Build is dead** even though W4 raised an $18M Series B (Tencent, Aug 2026). There is no managed Godot CI, so CI is self-hosted. [TL][SM]

The AI-contribution ban (Jul 1) and the W4 Series B (Aug) were surprises last month and are not repeated here.

---

## 8. Glossary

Terms new in this window.

- **Beckett**: a zero-sidecar Godot MCP server shipped as a pure GDScript editor plugin, reached over local HTTP. Free Lite tier (MIT) and a $15 Full tier.
- **Godot AI Workbench**: a local-first 129-tool MCP connector for the Godot 4 editor (Asset Library #5353).
- **Godot MCP Toolkit**: a new Asset Store MCP listing (#23816). Purpose not yet known.
- **SaveKit**: fernforestgames' MIT save plugin. Saves nodes in a `saveable` group through pluggable JSON/binary serializers.
- **PhantomCamera**: a third-party tween-based 2D/3D camera plugin, popular on the Asset Store.
- **ProProfiler**: an addon for log centralization and lightweight runtime profiling.
- **W4Build**: W4 Games' managed Godot CI/CD service. Discontinued by Jan 2026 and open-sourced.
- **`godot-mcp-runtime`**: erodenn's TypeScript MCP server that controls a running game through an injected UDP bridge.
- **`OPCODE_OPERATOR` / `OPCODE_OPERATOR_VALIDATED`**: GDScript VM opcodes for untyped and typed operator dispatch. Only the untyped one has the first-run cache behind #124010.
- **CanvasShaderRD**: the RenderingDevice (Metal/Vulkan) 2D canvas shader. Compiling its pipeline is where GH-123481 deadlocks.
- **Capture track**: an AnimationPlayer value-track mode that blends from the property's current value. It segfaults on freed targets (GH-123593).
- **GDType unification**: the 4.8-dev4 refactor that moves property maps from ClassDB into GDType. It is the source of the 1.6× property-access speedup.
- **Mip-level texture streaming**: the 4.8-dev5 `TextureStreaming` singleton that loads texture mips on demand to save VRAM. Benefits 3D only.
- **EditorDock (main screen)**: the 4.8 change that moves main-screen editor plugins into the dock system. Plugins need updating.
- **Nonvirtual GDScript functions**: proposal #15491, which would let GDScript functions skip virtual dispatch behind a project setting, enabling inlining.
- **`ResourceSaver.FLAG_RELATIVE_PATHS` / `FLAG_CHANGE_PATH`**: save flags that control how a resource writes its path references. Cited as stop-gaps for GH-123846 and GH-123189.
