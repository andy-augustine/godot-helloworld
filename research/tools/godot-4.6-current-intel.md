# Godot 4.6/4.7 Current Intel — Synthesized Deliverable
*Synthesized: 2026-07-01 | Intel window: Jan 2026 – Jul 2026*
*Project context: 2D Metroidvania, Godot 4.6.2, GDScript, macOS Apple Silicon, GL Compatibility renderer, 960×540, CharacterBody2D + custom GameCamera room-lock, TileMapLayer rooms, AnimationPlayer rig, MCP-driven dev (godot-mcp-pro).*

---

## 1. TL;DR

- **Engine quirks:** Animation TrackCache hash collisions silently mis-target properties on 4.6.0–4.6.3 (numbered/procedural node names); root fix landed in 4.7 (GH-117030, Mar 14 2026).
- **GDScript:** Lambdas capturing `self` connected to signals on RefCounted classes leak the object — still unfixed in 4.7; use named method refs or `weakref` (GH-102327).
- **Tooling:** GUT 9.7.0 (Jun 19) is still the default GDScript test framework; GdUnit4 (v6.1.3) surged in momentum but is overkill for GDScript-only projects.
- **2D platformer:** `Input.parse_input_event` dropped button events in late-4.6/4.7-dev — directly hit our MCP synthetic-input tests; fixed in 4.7 stable (GH-119329, May 26 2026).
- **Performance:** GL Compatibility renderer got a 2D batching overhaul (1.1×–7× GPU) in 4.6 and is NOT affected by the open Apple-Silicon Metal FPS regression — our renderer choice is correct.

---

## 2. Active sources, ranked

### HIGH
- **godotengine/godot** (GitHub) — primary truth for behavior/PRs. https://github.com/godotengine/godot — *S/N note: contribution policy tightened Feb 2026 (AI-authored code banned), which raises signal quality.*
- **godotengine/godot-proposals** — what's coming; AI-written proposals banned. https://github.com/godotengine/godot-proposals
- **godotengine.org/blog** — authoritative release articles. https://godotengine.org/blog/ — *WebFetch returned HTTP 403; sourced via search snippets + third-party coverage.*
- **Godot Interactive Changelog** (YuriSizov) — fastest fix-landed-in-which-release check. https://godotengine.github.io/godot-interactive-changelog/
- **forum.godotengine.org** — practical GDScript/node Q&A; team monitors. https://forum.godotengine.org/
- **bitwes/Gut** — 9.7.0 (Jun 19 2026); authoritative for GDScript testing. https://github.com/bitwes/Gut
- **godot-gdunit-labs/gdUnit4** — v6.1.3 (Apr 27 2026); moved to dedicated org (institutional-backing signal). https://github.com/godot-gdunit-labs/gdUnit4

### MED
- **r/godot** — sentiment/showcases. https://reddit.com/r/godot
- **godotengine/godot-docs** — API nuance; lags master ~one cycle. https://github.com/godotengine/godot-docs
- **godotengine/awesome-godot** — plugin discovery. https://github.com/godotengine/awesome-godot
- **GamingOnLinux** — reliable same-day release coverage. https://www.gamingonlinux.com/
- **HackerNews** — meta/trajectory discussion. https://news.ycombinator.com/
- **Mastodon @godotengine@mastodon.gamedev.place** — official announcements, no algorithm noise. https://mastodon.gamedev.place/@godotengine
- **chickensoft-games** — C#-focused; low relevance to GDScript-only. https://github.com/chickensoft-games

### LOW
- **Official Godot Discord** — real-time help, not indexable. https://discord.me/godotgamedevelopment
- **godotforums.org** — split audience; prefer official forum. https://godotforums.org/
- **YouTube (general)** — poor for reference, good for onboarding.

*Skip: old Asset Library (replaced by Asset Store in 4.7), Godot 3.x docs, GUT 7.x, KidsCanCode (no confirmed 2026 content — but note its screen-shake/save recipes are still cited as canonical patterns), old QA site.*

---

## 3. Contributors to follow

1. **George Marques (@vnen)** — GDScript language maintainer. https://github.com/vnen — Most GDScript type-system PRs in 4.6–4.7 route through him. E.g. reference point for the untyped-override return-type change (GH-115763).
2. **dalexeev** — GDScript analyzer/static typing/runtime errors. https://github.com/dalexeev — Clarifies language semantics before docs; maintains gdscript-preprocessor. E.g. GH-99899 grouped analyzer/runtime error tests.
3. **Nathan Lovato / GDQuest (@NathanLovato)** — GDScript education, 2D patterns. https://github.com/NathanLovato / https://www.gdquest.com/ — Open-source demos model good GDScript architecture; hitbox/hurtbox + save-format guides cited here are canonical. E.g. "Learn GDScript From Zero".
4. **bitwes** — GUT maintainer (GDScript testing). https://github.com/bitwes/Gut — Ground truth for GUT behavior. E.g. GUT 9.6.0 added Singleton doubling, `assert_push_warning`, headless auto-exit.
5. **Mike Schulze (@MikeSchulze)** — GdUnit4 maintainer. https://github.com/godot-gdunit-labs/gdUnit4 — Sole maintainer; also gdUnit4-action CI. E.g. v6.1.0 "run until failure" + variadic `assert_signal`.
6. **KoBeWi** — Metroidvania-System plugin. https://github.com/KoBeWi/Metroidvania-System — Directly relevant: automated storable-object ID system for room/item state persistence (supports 4.6+).
7. **Remi Verschelde (@akien-mga)** — release engineering, contribution policy. https://github.com/akien-mga — Signals per-cycle priorities; authored 2026 contribution policy. E.g. manages every stable release tag.
8. **Juan Linietsky (@reduz)** — lead dev, architecture/rendering. https://github.com/reduz — Design intent for renderer/GDExtension decisions. E.g. LibGodot embedded mode (4.6).
9. **Yuri Sizov (@YuriSizov)** — editor UI + Interactive Changelog. https://github.com/YuriSizov — Owns the best release-tracking tool. E.g. godot-interactive-changelog.
10. **Aaron Franke (@aaronfranke)** — math types (Vector/Transform), stdlib. https://github.com/aaronfranke — Cited in coordinate/transform bug reports relevant to CharacterBody2D positioning.
11. **Calinou / godot-extended-libraries** — godot-debug-menu. https://github.com/godot-extended-libraries/godot-debug-menu — In-game FPS/frametime overlay that works in exported builds; low-effort game-feel QA.
12. **Signal Emitted (YouTube)** — weekly ecosystem digest. Search "Signal Emitted Godot" — Faster than the blog for in-progress features. E.g. Week 16 (Apr 2026) covered the "GDScript 3.0" proposal.
13. **abarichello** — godot-ci (CI/CD deploy). https://github.com/abarichello/godot-ci — Standard Docker + Actions + butler-to-itch.io pipeline; updated to 4.7 same-day.
14. **hi-godot** — godot-ai free MCP server. https://github.com/hi-godot/godot-ai — Strongest free MCP alternative to godot-mcp-pro; v2.8.2 (Jun 30 2026), 150+ ops, Asset Store one-click.

---

## 4. Findings

### 4.1 Engine quirks & regressions

1. **`Input.parse_input_event` dropped Button events** (HIGH — hits our MCP synthetic-input test harness). Multitouch change added early `return`s that skipped button-press logic. Fixed 4.7 stable, GH-119329, merged May 26 2026. On 4.6.x workaround: call `Input.action_press()`/`action_release()` directly instead of routing button events through `parse_input_event`. https://github.com/godotengine/godot/pull/119329 (2026-05-26)
2. **Animation TrackCache hash collisions** (HIGH if nodes have numbered/procedural names; MED otherwise). New `AHashMap` in 4.6.0 let two node-path strings collide → tracks apply to wrong property or combine. Partial fix GH-115473 (Feb 13 2026); root fix (StringName pointer IDs) GH-117030 (merged Mar 14 2026), ships 4.7. On 4.6.x: rename colliding nodes. https://github.com/godotengine/godot/issues/116231 (2026-02) / https://github.com/godotengine/godot/pull/117030 (2026-03-14)
3. **CharacterBody2D slope jitter far from origin** (MED — large side-scrolling rooms). Movement on slopes (esp. 11–13°) gets choppy past ~30,000 px on X; Y unaffected. Open/untriaged, no fix. Workaround (standard Metroidvania mitigation): keep rooms near world origin, use chunk/room streaming to avoid large absolute coords. https://github.com/godotengine/godot/issues/118130 (2026-04)
4. **AnimatedSprite2D position offset regression 4.4→4.6** (MED — only affects migrations from 4.4.x). Transform handling changed; projects started on 4.6 unaffected. Milestone 4.7 (verify fix present before upgrading). https://github.com/godotengine/godot/issues/116132 (2026-02-10)
5. **GodotPhysics Area2D overlap missed after `area_set_space`** (MED — hazard/pickup detection). Reparenting/space-change at runtime can silently drop overlapping bodies. Fixed 4.7, GH-118420. On 4.6.x: hide + disable collision shapes individually rather than toggling `monitoring`/reparenting. https://github.com/godotengine/godot/pull/118420 (2026)
6. **`ResourceLoader.load_threaded_get` never unloads resources** (MED — if used for room streaming). Slow memory leak; also had deadlocks. Fixed 4.7 (GH-119394, GH-119757, GH-120077). On 4.6.x: use synchronous `load()` and manually free. https://github.com/godotengine/godot/pull/119394 (2026)
7. **Scene UID export non-determinism** (MED — breaks patch-PCK/diff workflows, noisy git). Per-node `unique_id` (GH-106837) regenerates every export for scenes saved ≤4.5.1. Milestone 4.8, unfixed as of Jul 2026. Workaround: open + re-save each `.tscn` once in the editor. https://github.com/godotengine/godot/issues/115971 (2026-02-06)
8. **Tree node mouse-drag regression in 4.7.0** (LOW gameplay / MED editor). Scene-dock drag misread as touch scroll on macOS/Linux. Fix GH-120728 cherry-picked to 4.7.1 (Jun 30 2026; 4.7.1 not yet released). https://github.com/godotengine/godot/pull/120728 (2026-06-30)
9. *(LOW, not applicable)* Sky/VoxelGI/SDFGI regression (GH-115599) — Forward+/Mobile only, GL Compatibility unaffected. BlendSpace negative-time-scale (GH-119089) — fixed pre-4.7, no action.

### 4.2 GDScript language

1. **Lambda-captures-`self` leaks RefCounted — UNFIXED in 4.7** (HIGH). `signal.connect(func(): self.do_thing())` keeps the RefCounted alive forever. Use a named method ref (`connect(_on_signal)`) or capture `weakref(self)` and null-check. https://github.com/godotengine/godot/issues/102327 (open through 4.7)
2. **Temporary-copy property mutation** (HIGH — silent no-op). `line2d.points[0] = v` mutates a returned copy; must read to a local, mutate, write back. 4.7 adds `CONFUSABLE_TEMPORARY_MODIFICATION` warning (GH-118002) — enable Treat Warnings as Errors. https://github.com/godotengine/godot/pull/118002 (2026)
3. **`await` on freed-node coroutine leaked GDScriptFunctionState — fixed in 4.7** (MED). Freeing a node mid-`await` orphaned the state pre-4.7. Fixed by GH-116711/117053/119755. On 4.6.x: guard with `if not is_instance_valid(self): return` after the await. https://github.com/godotengine/godot/pull/116711 (2026)
4. **`:=` widens to Variant on engine method returns** (MED — silent loss of type safety, hurts hot-path perf too). `var x := arr.pop_back()` infers Variant. Use explicit `var x: T =` or `as T`. 4.7 narrowed some cases (GH-117172, GH-118032). https://github.com/godotengine/godot/pull/117172 (2026)
5. **Untyped overrides now inherit parent return type in 4.7** (MED — silent behavioral change on upgrade). A child `func get_speed()` with no annotation now inherits parent's `-> float`; code relying on Variant widening type-checks stricter. GH-115763. https://github.com/godotengine/godot/pull/115763 (2026)
6. **MCP-specific: no top-level `await` in `run_script`** (project rule). godot-mcp-pro's runner drops `GDScriptFunctionState` continuations silently; use the `capture_frames` + action pattern in `tests/README.md`.
7. **Ternary with mixed types downcasts to Variant** (LOW). `INCOMPATIBLE_TERNARY` is warning-only by default; can throw at runtime. Set it to Error in Project Settings > Debug > GDScript. https://github.com/godotengine/godot/issues/80097 (longstanding)
8. **`type_exists()` deprecated in 4.7** (LOW). Use `ClassDB.class_exists()`. https://github.com/godotengine/godot/pull/116899 (2026)
9. *Proposals to watch:* Trait system (PR #107227, not in 4.7); Typed WeakRef `WeakRef[T]` (PR #109268, would fix the untyped-weakref gotcha); typed nested arrays (Issue #12224, 4.8/5.0). "GDScript 3.0"/GDExtension migration targeted at 5.0.

### 4.3 Tooling

1. **GUT 9.7.0 remains the default for GDScript-only testing** (HIGH relevance). Jun 19 2026 release, 4.7-compatible (compat fix for stricter Double return-type checking). Matches our GDScript-first convention, minimal setup. https://github.com/bitwes/Gut (2026-06-19)
2. **godot-mcp-pro is still the strongest live-engine MCP** (HIGH — our current tool). 163 tools / 23 categories; Lite Mode (76 tools) for tool-count-capped clients. No competing paid tool emerged. https://y1uda.itch.io/godot-mcp-pro
3. **Free MCP alternatives proliferated** (MED — fallback options). Strongest: **godot-ai** (hi-godot, MIT, 150+ ops, Asset Store one-click, v2.8.2 Jun 30 2026). Others: Coding-Solo/godot-mcp (lightweight npm, CI headless), GDAI MCP (file-level only). Skip IvanMurzak/Godot-MCP (needs C#/.NET). https://github.com/hi-godot/godot-ai (2026-06-30)
4. **GdUnit4 v6.1.3 surged but is overkill here** (MED). Moved to `godot-gdunit-labs` org; four 2026 releases; v7 API overhaul in dev; mocking/parameterized/scene-runner/CI. Adopt only if CI or C# becomes a priority. https://github.com/godot-gdunit-labs/gdUnit4 (2026-04-27)
5. **godot-ci (abarichello) is current-stable for deploy** (MED — future itch.io automation). 4.7-stable release Jun 19 2026 (same day as engine). Standard Docker + Actions + butler pattern. https://github.com/abarichello/godot-ci (2026-06-19)
6. **godot-debug-menu for in-build frame-pacing QA** (MED — game-feel passes). In-game FPS/frametime/CPU-GPU overlay, F3 cycles modes, works in exported builds (unlike editor profiler). Antz's fork updated Jun 12 2026. https://github.com/godot-extended-libraries/godot-debug-menu (2026-06-12)
7. **Built-in profiler + Apple Instruments** (see 4.5). Floatable debugger as of 4.6; use built-in first, no plugin needed.

### 4.4 2D platformer patterns

1. **TileMapLayer vanishes at certain Camera2D zoom (Compatibility mode) — fixed in 4.7** (HIGH — we use Camera2D room-lock + TileMapLayer + Compatibility). Affected 4.3–4.4.1; if tilemap flickers, upgrade. PR #117725. https://github.com/godotengine/godot/issues/105645 (fix 4.7)
2. **Area2D phantom `body_entered` on scene load** (HIGH — our door/room triggers + pickups). CharacterBody2D starting with a disabled CollisionShape2D enabled via `set_deferred()` makes nearby Area2Ds fire spurious enter/exit on load → could mis-fire room transitions. Open mid-2026. Workaround: initialize shapes enabled, or validate the hit in-handler (`is_inside_tree()` + distance). https://github.com/godotengine/godot/issues/88592 (open)
3. **Save/load: custom Resource + binary `.res`** (HIGH — not yet implemented; right foundation). `Resource` subclass with `@export` fields; `.tres` in dev, `.res` for release. For room/item state, track discovered rooms + collected items as a Dictionary in an autoload; KoBeWi's Metroidvania-System plugin automates storable-object IDs (4.6+). Avoid Resources for untrusted/shared saves (can embed executable scripts) — use FileAccess + JSON there. https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/ (2026)
4. **Camera `position_smoothing` not auto-reset across room/scene change** (MED — our room-lock camera). Call `reset_smoothing()` (or disable/re-enable) in the new room's `_ready()` after teleporting the player, else the camera slides in from the old room. By design, all 4.x. https://www.gdquest.com/tutorial/godot/2d/scene-transition-rect/ (2026)
5. **Runtime `set_cell` needs `notify_runtime_tile_data_update()`** (MED — future destructible tiles). Physics shapes stay stale until you call it once per batch (not per-cell); add `update_internals()` only for same-frame raycasts. https://forum.godotengine.org/t/tilemaplayer-notify-runtime-tile-data-update-doesnt-work-as-i-expect/99417 (2026)
6. **AnimationPlayer-only is fine for our rig** (LOW relevance — confirms current approach). Valid for ≤8 non-blended states (idle/run/jump/fall/attack); scattered `play()` calls are the accepted trade-off. Move to AnimationTree only when blending is a felt need. Note 4.7 BlendSpace internal compat break — irrelevant until we migrate. https://github.com/godotengine/godot/issues/92730
7. **CollisionShape2D one-way direction property (NEW in 4.7)** (MED — future rotating/conveyor hazards). Sets allowed pass-through direction relative or global; removes rotation hacks. Proposal #12093. https://github.com/godotengine/godot-proposals/issues/12093 (4.7 beta 1)
8. **Trauma-based screen shake on `camera.offset`** (MED — combat feedback). Square the trauma for falloff; use additive model for overlapping shakes; apply to `offset` NOT position (position fights room limits). https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424 (2026)
9. **Ghost tile-seam collision on flat floors** (MED). CharacterBody2D catches tile corners (issue #89458); fixed by polygon merge PR #102662 — verify in build; fallback is one merged StaticBody2D floor section. https://github.com/godotengine/godot/issues/89458
10. **4.7 Scene Paint Mode (press B)** (MED — future enemy/pickup placement). Scatters real editable node instances off-grid; complements TileMapLayer, no code impact. https://www.gamingonlinux.com/2026/06/godot-engine-4-7-is-out-bringing-a-new-asset-store-hdr-support-steam-frame-support/ (2026-06)

### 4.5 Performance & deployment

1. **GL Compatibility 2D batching overhaul (4.5/4.6): 1.1×–7× GPU** (HIGH — we're already on the benefiting renderer). Gains require shared texture atlas + material + blend mode + Z-index. Action: group nodes by atlas, single TileSet atlas, avoid mixing blend modes mid-batch. PR #92797. https://github.com/godotengine/godot/pull/92797 (2026)
2. **Apple-Silicon Metal FPS regression — NOT applicable to us** (HIGH context / no action). Metal backend (4.4+) dropped M1 FPS (~54→43–50) and stutters on render-target transitions; GL Compatibility uses OpenGL/ANGLE and is unaffected. Stay on Compatibility. https://github.com/godotengine/godot/issues/103723 (open)
3. **Typed GDScript bytecode: 5–150% runtime speedup (4.6+)** (MED-HIGH). Vector2 ops ~59% faster. Annotate params + returns in `_physics_process`/`_process`/signal handlers; `@static_unload` on rarely-used static classes. https://godotengine.org/article/gdscript-progress-report-typed-instructions/ (2026)
4. **Audio thread spikes cause frame drops in 4.6.2** (MED). Simultaneous AudioStreamPlayers spike audio thread 0.5→12 ms, blowing the 16.67 ms budget. Lower Max Voices 32→16, add ~50 ms cooldown on repeated triggers, pool/reuse players (don't create at runtime). https://github.com/godotengine/godot/issues/84157 (2026)
5. **Profiling on macOS: Apple Instruments + Tracy/Perfetto (4.6, no custom build)** (MED). Microsecond flame graphs for renderer/physics bottlenecks; Audio Thread section is collapsed by default — expand it. 4.7 adds Visual Profiler tree folding. https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html
6. **GPUParticles crash on GLES3 + Apple Silicon (historic, verify)** (LOW — not yet using). Use CPUParticles2D until verified fixed on 4.6.2/4.7; file a repro if it persists. https://github.com/godotengine/godot/issues/72469 (status unclear)
7. **Upgrade recommendation: stay on 4.6.2 for active dev.** 4.7 migration is low-risk for 2D but Visual Profiler folding / HDR are not urgent — upgrade when a 4.7 feature is specifically needed (e.g. the parse_input_event or TileMapLayer-camera fixes above) or at a new phase boundary. Breaking changes to test on upgrade: keyboard/mouse device IDs (input remapping), audio spectrum API, shader preprocessor. macOS first-export can take 15+ min on M3 (issue #115062, no fix; restart before first export). https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html (2026)

---

## 5. Open / unresolved issues we may hit

| Issue | Status | Last-seen | Re-scan trigger |
|-------|--------|-----------|-----------------|
| Lambda-captures-`self` RefCounted leak ([GH-102327](https://github.com/godotengine/godot/issues/102327)) | Open (unfixed in 4.7) | Jul 2026 | Any signal-heavy RefCounted subsystem; re-scan on each Godot release |
| Area2D phantom `body_entered` on scene load ([GH-88592](https://github.com/godotengine/godot/issues/88592)) | Open | mid-2026 | When adding item pickups / room-transition triggers |
| CharacterBody2D slope jitter far from origin ([GH-118130](https://github.com/godotengine/godot/issues/118130)) | Open, untriaged | Apr 2026 | If any room places geometry past ~30k px on X |
| Scene UID export non-determinism ([GH-115971](https://github.com/godotengine/godot/issues/115971)) | Milestone 4.8, unfixed | Feb 2026 | When 4.8 ships; when adopting patch-PCK/diff exports |
| GPUParticles crash GLES3 + Apple Silicon ([GH-72469](https://github.com/godotengine/godot/issues/72469)) | Status unclear | pre-2026 | Before adding any particle effects |
| macOS first-export 15+ min slowness ([GH-115062](https://github.com/godotengine/godot/issues/115062)) | Open, no fix | 4.6rc1 | First export attempt; on 4.7 upgrade |
| NavigationAgent2D never reaches target on TileMapLayer ([GH-110567](https://github.com/godotengine/godot/issues/110567)) | Open since 4.5 | 2026 | If we add 2D navigation/pathfinding enemies |
| Tree node mouse-drag regression ([GH-120728](https://github.com/godotengine/godot/pull/120728)) | Cherry-picked to 4.7.1 (unreleased) | Jun 30 2026 | If we upgrade to 4.7.0 before 4.7.1 lands |
| Ghost tile-seam collision ([GH-89458](https://github.com/godotengine/godot/issues/89458)) | Fixed PR #102662 — verify in build | 2026 | If CharacterBody2D catches on flat floors |

---

## 6. Recurring scan recommendation

**Frequency: monthly**, with an **event-driven trigger on each Godot point/stable release** (blog + interactive changelog).

- **Every release (event-driven):** Diff the CHANGELOG via the Interactive Changelog filtered to GDScript, Physics/2D, Animation, and Core; confirm status of the Section 5 watch-list items. Godot cadence has been roughly monthly (4.6.x every 2–5 weeks; 4.7 in Jun), so this and the monthly cadence largely coincide.
- **Monthly:** Re-scan HIGH sources only — godotengine/godot issues+PRs (labels `topic:gdscript`, `topic:2d`, `topic:physics`, `regression`, `crash`), godot-proposals 4.8/5.0 milestones, GUT + GdUnit4 releases, godot-ai / godot-mcp-pro changelogs.
- **Watch specifically:** the two still-open HIGH-relevance bugs (GH-102327 lambda leak, GH-88592 phantom Area2D); 4.7.1 release (Tree-drag fix); 4.8 milestone for the UID determinism fix; typed-WeakRef and trait proposals.
- **Quarterly:** Refresh the contributor list and re-rank sources; check for new MCP tooling and GodotCon Boston (Jul 20–22 2026) tooling/roadmap announcements.

---

## 7. Surprises

**Godot 4.7 shipped June 18 2026** — the crawl expected 4.6.x to be current. 4.7 is now stable (new Asset Store replacing the Asset Library, built-in VirtualJoystick, DrawableTexture, macOS HDR output, gyro aiming, Vulkan ray-tracing foundation). Scope impact is moderate, not a rework: 4.7 *fixes* several bugs that directly affect us (`Input.parse_input_event` button drop, TileMapLayer-camera vanish, animation hash collisions, threaded-loader leak) but migration is low-risk and non-urgent. Net effect: 4.7 is a recommended-when-convenient upgrade target rather than a forced move. Also notable (not scope-changing): the **Feb 2026 contribution policy banned AI-authored engine code** — this raises source signal quality but does not affect our AI-assisted game project or plugin usage.

---

## 8. Glossary

- **TrackCache / AHashMap** — AnimationPlayer's internal map from node-path to animation track; the 4.6 `AHashMap` rewrite caused the hash-collision bug (F1).
- **GDScriptFunctionState** — the object representing a suspended coroutine at an `await`; leaked pre-4.7 when its node was freed mid-await.
- **`CONFUSABLE_TEMPORARY_MODIFICATION`** — new 4.7 compiler warning flagging mutation of a returned temporary copy (e.g. indexing into a property-returned Packed array).
- **TileMapLayer** — per-layer tilemap node that replaced the monolithic TileMap (deprecated); one node per logical layer.
- **`notify_runtime_tile_data_update()`** — call after runtime `set_cell` batches so TileMapLayer physics shapes rebuild.
- **Metroidvania-System (KoBeWi)** — plugin providing map, room, and storable-object-ID systems for Metroidvania games (4.6+).
- **godot-mcp-pro** — our paid MCP plugin (163 tools) giving Claude live Godot editor access over WebSocket.
- **godot-ai (hi-godot)** — strongest free/MIT MCP alternative (150+ ops, Asset Store one-click).
- **GdUnit4 / GUT** — the two GDScript test frameworks; GUT is simpler/GDScript-native, GdUnit4 is feature-rich (mocking, CI, C#).
- **godot-ci (abarichello)** — Docker + GitHub Actions template for exporting and deploying Godot games (itch.io via butler).
- **Trauma-based screen shake** — Game-Feel-book shake model: accumulate `trauma`, square it for falloff, apply to `camera.offset`.
- **Interactive Changelog** — YuriSizov's searchable per-release, per-area commit-log tool.
- **Scene Paint Mode** — 4.7 2D-editor mode (key `B`) for scattering real scene instances off the TileMap grid.
- **Jolt Physics** — default 3D physics engine as of 4.6 (2D still uses GodotPhysics2D; noted for context only).
- **LibGodot** — 4.6 embedded-library mode letting Godot run as a library inside another app.
