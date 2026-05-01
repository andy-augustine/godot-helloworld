# Godot 4.6 Current Intel — Canonical Synthesis

**Generated:** 2026-05-01 (overwrites 2026-04-26 prior crawl)
**Baseline:** Godot 4.6.2-stable (released 2026-04-01)
**Window:** Jan 2026 – May 2026
**Sources:** `research/crawl/sourcemap.md` + five topic agents (engine quirks, GDScript, tooling, 2D platformer, performance)

---

## 1. TL;DR

- **Engine:** `is_action_just_pressed_by_event` / `is_action_just_released_by_event` always return false for mouse buttons in 4.6.2 — internal ID mismatch on event conversion (#118521, open). [engine-quirks §1]
- **GDScript:** `:=` type narrowing after `is` checks still doesn't propagate to the static analyzer in 4.6.2; manual `as` casts or temp typed vars are the only workaround (proposal #8530, open). [gdscript §1]
- **Tooling:** GUT 9.6.0 (Feb 24, 2026) added singleton doubling (`Input`/`Time`/`OS`) and `wait_idle_frames(n)` — directly addresses our test-harness MCP timing pitfalls. Adopt now. [tooling §GUT]
- **2D platformer:** TileMapLayer corner-seam stuck-player bug remains open in 4.6.2; workaround is `safe_margin = 0` and rectangular per-tile collisions, or use single-shape StaticBody2D platforms (our current pattern). [2d-platformer §5]
- **Performance:** Canvas renderer write-combined memory reads were a frame hog on Apple Silicon in 4.6.0/4.6.1 — fixed in 4.6.2 (GH-115757). 4.6.2 is the production baseline unless you use `TIME` in sky shaders (4.6.2 regression, fix in 4.6.3). [performance §1, §2]

---

## 2. Active Sources, Ranked

### HIGH

| Source | Why |
|---|---|
| **godotengine/godot** (GitHub) | Primary truth for bugs, fixes, release notes. Last commit 2026-04-24. 5,000+ open issues. |
| **godotengine/godot-proposals** | GIPs via discussions; new filings 2026-04-24/26 (#14729–#14741). Viewer at godot-proposals-viewer.github.io. |
| **forum.godotengine.org** | Official Discourse forum. Long-form, indexed, fast response. Best venue for technical depth. |
| **Mastodon (mastodon.gamedev.place)** | Core devs (@reduz, @akien, @godotengine) — primary social channel. |
| **Signal Emitted (YouTube)** | Weekly Godot news digest. Best single feed for "what changed this week." |
| **GDQuest (YouTube + library)** | Technically substantive; 4.6 workflow guide actively updated. |
| **godotengine.org/blog** | All release announcements and dev snapshots — primary authoritative source. |
| **godot-rust.github.io** | Monthly dev updates (Mar 2026 confirmed); reveals GDExtension API surface. |

### MED

| Source | Why |
|---|---|
| **godotengine/godot-docs** | Doc PRs reveal API design intent. |
| **bitwes/Gut** | GUT 9.6.0 (2026-02-24) — current and Godot 4.6 compatible. |
| **godot-gdunit-labs/gdUnit4** | v6.1.3 (2026-04-27); org renamed from MikeSchulze/gdUnit4. |
| **chickensoft-games** | C#-heavy; useful for GDExtension/architecture patterns only. |
| **godot-rust/gdext** | Rust GDExtension bindings (v0.5, March 2026). |
| **r/godot** | 307k members; trending pain points and sentiment. Not deep-tech. |
| **Godot Engine Discord** | 69–80k members; real-time help; ephemeral. |
| **Bluesky (@akien-mga)** | Rémi Verschelde primary in 2026; growing core team share. |
| **GameFromScratch** | Fast news; 4.7/HDR (Apr 25), NVIDIA RTX (Mar 13), AI slop (Feb 18). |
| **Godot Engine YouTube** | GodotCon Amsterdam talks landing soon. |
| **GDNotes.com / jettelly.com** | Curated aggregators; sporadic but accurate. |
| **Godot Asset Library** | Phantom Camera, Terrain3D, Beehave, ProtonScatter, GodotSteam top-starred. |
| **kidscancode.org/godot_recipes/4.x** | Best indexed reference for CharacterBody2D / TileMap / 2D physics, despite slow YouTube cadence. |

### LOW

| Source | Why |
|---|---|
| godotforums.org (unofficial) | Superseded by official forum. |
| X/Twitter | Core devs reduced personal activity. |
| godot-sdk-integrations | Niche platform SDKs. |
| awesome-godot | Curated list; cadence unclear. |
| HackerNews | Only surfaces on major releases. |
| r/madeWithGodot | Showcase only. |
| kidscancode YouTube | No confirmed 2026 uploads (recipes site is fine). |
| Godot 3.x docs / VisualScript / gdnative | Obsolete. |
| Pre-2024 Reddit threads | API drift. |

---

## 3. Contributors to Follow

| # | Name / Handle | Domain | Primary link | Why useful | Example contribution |
|---|---|---|---|---|---|
| 1 | Juan Linietsky / @reduz | Core engine, rendering, physics, audio | mastodon.gamedev.place/@reduz | Co-creator; shapes fundamental API decisions | Jolt Physics default in 4.6, LibGodot, IK system |
| 2 | Rémi Verschelde / @akien-mga | Release management, core, GUI, input, build | mastodon.gamedev.place/@akien (Bluesky too) | Release lead; owns the 4.x maintenance train | Coordinates every .x maintenance release |
| 3 | George Marques / @vnen | GDScript language, GDExtension, debugger | github.com/vnen | GDScript language lead | Typed arrays, lambda closures |
| 4 | Danil Alexeev / @dalexeev | GDScript | github.com/dalexeev | Core GDScript implementation alongside vnen | Static type inference, abstract methods (4.5) |
| 5 | Clay John / @clayjohn | Rendering, shaders, TLC | github.com/clayjohn | Rendering lead; shader / SSR / SDFGI bugs | SSR full rewrite in 4.6 |
| 6 | Bastiaan Olij / @BastiaanOlij | Rendering, GDExtension, XR, Apple | github.com/BastiaanOlij | Bridges XR / GDExtension / rendering | XR architecture reviews |
| 7 | Gilles Roudière / @groud | 2D nodes, editor, GUI, input, tilemap | github.com/groud | Tilemap and 2D-physics author — critical for our platformer | TileMapLayer design |
| 8 | Tomasz Chabora / @KoBeWi | 2D nodes, editor, GUI, TLC | github.com/KoBeWi | Active reviewer on editor/2D issues; author of MetSys plugin | Animation timeline cursor fix in 4.6.2 |
| 9 | Hugo Locurcio / @Calinou | Rendering, editor, docs, build, demos, QA | github.com/Calinou | Most cross-cutting contributor | Maintains demos and QA |
| 10 | Pāvels Nadtočajevs / @bruvzg | Editor, GUI, text, Apple/Windows, TLC | github.com/bruvzg | Text/font/Control layout expert | TextServer improvements |
| 11 | A Thousand Ships / @AThousandShips | Documentation, issue triage | github.com/AThousandShips | First responder on bug reports | Triages hundreds of issues |
| 12 | Fabio Alessandrelli / @Faless | Networking, debugger, GDExtension, Web | github.com/Faless | Multiplayer and ENet authority | WebSocket / ENet architecture |
| 13 | Paul Batty / @Paulb23 | Script editor, GUI, usability | github.com/Paulb23 | GDScript editor improvements | Code folding, autocomplete |
| 14 | @lawnjelly | Core, physics, rendering, QA, TLC | github.com/lawnjelly | Quiet but extremely active on low-level/physics edge cases | CharacterBody2D floor-snap fixes |
| 15 | Ricardo Buring / @rburing | Physics | github.com/rburing | Primary Godot Physics (non-Jolt) maintainer | Elastic collision energy fix in 4.6.2 |

---

## 4. Findings

### A. Engine quirks & regressions

Ranked by relevance to our 2D platformer. Citations inline.

1. **`is_action_just_pressed_by_event` / `_by_event` broken for mouse buttons (HIGH).** `xformed_by` creates a new event object with a different internal ID; the `_by_event` methods then fail ID comparison. Keyboard unaffected. Confirmed 4.6.2-stable. Workaround: use `Input.is_action_just_pressed(name)` or check `event is InputEventMouseButton && event.pressed` in `_unhandled_input`. Open, no milestone. — godotengine/godot#118521 (filed 2026-04-13).

2. **`move_and_slide()` treats wall corner as floor (MED).** When a CharacterBody2D's edge aligns with a StaticBody2D / tile collision corner, `is_on_floor()` reports inconsistently and falls stop. Workarounds: capsule collider; round / offset shapes to break 1:1 pixel alignment. Open, no milestone. — godotengine/godot#109926, related #87477.

3. **`@tool` script `_physics_process()` writes corrupted velocity to `.tscn` (MED).** Without an `Engine.is_editor_hint()` guard, gravity accumulates during edit time; resulting velocity is invisible in Inspector but launches the body at runtime. Survives `git` merges. Workaround: always early-return on `Engine.is_editor_hint()` in `@tool` physics callbacks. Open. — godotengine/godot#118263.

4. **AnimationPlayer manually-created events lost on 4.6.0 → 4.6.1 (HIGH if blocking upgrade).** Method-call tracks and custom signal tracks silently wiped on first open. Imported skeletal/blend animations survive. Workaround: stay on 4.6.0 or re-author events; back up `.tscn` before upgrading. Milestone 4.7. — godotengine/godot#116408.

5. **Animation path hash collision (FIXED in 4.6.2).** 4.6.1 hashing change caused two paths with equal hashes to drive the same property summed rather than overwriting — silent corruption. Fixed in 4.6.2 via PR #117030. — godotengine/godot#116231.

6. **`.tscn` exports non-deterministic after 4.5 → 4.6 migration (HIGH for patch PCK / CI).** `unique_id` (PR #106837) generated non-deterministically on first open of a 4.5 scene. Workaround: open + save every `.tscn` once, commit as a one-time upgrade commit. Milestone 4.7. — godotengine/godot#115971.

7. **Vulkan canvas_item_add_texture_rect_region performance collapse (FIXED in 4.6.2).** TileMapLayer rendering blew from ~18 to 24,000+ draw calls on Vulkan Forward+ in 4.6.dev3+. Pre-4.6.2 workaround: GLES3/Compatibility renderer. Fixed via GH-115757. — godotengine/godot#115431.

8. **Control / TextureButton loses focus on click — `hide_focus` regression (LOW for us — minimal menus).** Click anywhere clears focused button's Focus-state texture. Workaround: `grab_focus(false)` explicitly. Milestone 4.7. — godotengine/godot#117486.

9. **Sky shader / VoxelGI / SDFGI lighting broken in 4.6.0 (FIXED, irrelevant to 2D).** PR #116155 closed the regression. — godotengine/godot#115599.

10. **TSCN format change — `load_steps` removed, `unique_id` per node (operational only).** Run "Project > Tools > Upgrade Project Files" once; large one-time VCS diff. — godot-docs#11707, [migration guide](https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html).

### B. GDScript language

Ranked by daily friction in this codebase.

1. **`:=` type narrowing after `is` checks still doesn't propagate.** Static analyzer keeps the pre-check type even though autocomplete shows the narrowed type. Setting `unsafe_property_access` to Error produces spurious errors. Workaround: explicit downcast `var typed: MyClass = node` or `(node as MyClass).prop`. — godotengine/godot#115492 (dupe of #60499); proposal #8530 (open, last activity Apr 2026).

2. **Lambda signal connections silently multiply on scene reload.** Each `func()` literal is a fresh Callable, so the duplicate-connection guard never fires. After N `_ready()` calls, signal fires N times. Companion bug #116141 (Feb 2026, PR #117336 open) flips identity vs. equality the other way — false "already connected" errors. Workaround: use named methods; for required lambdas, store the Callable in a member var and `disconnect` in `_exit_tree`. — godotengine/godot#94641, #116141.

3. **`await` on a freed-node coroutine leaks `GDScriptFunctionState`.** Closed as not-planned. Debug builds print "resume after free"; release builds leak silently. Workaround: only `await` signals with shorter lifetime than `self`; use a `_is_alive` boolean guard checked at coroutine top. Related: queue_free + create_timer race (#93608, open). — godotengine/godot#72629, #93608.

4. **`preload()` pins resources for the entire game lifetime (relevant: rooms).** Compiled scripts hold an extra reference; resource cache cannot release. Affects 4.0.4 through 4.6.2. Workaround: `preload()` only lightweight always-needed assets; `load()` or `ResourceLoader.load_threaded_request()` for heavy room scenes. — godotengine/godot#118528 (filed 2026-04-13).

5. **Lambda captures: locals captured by-value at creation; members evaluated at call time.** Mutations inside a lambda don't propagate back. Closed as not-planned (intentional). Freed-object capture variant emits index-only error: `"Lambda capture at index N was freed."` — godotengine/godot#69014, #117840.

6. **Hot-reload: new Dictionary / Array members are NIL on live instances.** Adding a `var foo: Dictionary = {}` and hot-reloading shows the property in `get_property_list()` but value is `Variant::NIL`; calling `.has()`/`.size()` crashes. Workaround: defensive init in `_ready` / `_process`, or restart instead of hot-reload. — godotengine/godot#119057 (filed 2026-04-28).

7. **Typed vs. untyped 2–3× perf gap (4.6 JIT).** New pressure point, not a bug. Order: `PackedXxxArray` > `Array[T]` > bare `Array`. Plus: `abs(float)` etc. are flagged "unsafe code" silently with no message — use `absf()`/`absi()`/`snappedf()`. `UNTYPED_DECLARATION` warning highlights the wrong line in 4.7-dev (#118550, fix PR #118552 pending). — strayspark.studio benchmark; godotengine/godot#118550, #118557.

8. **`WeakRef.get_ref()` returns Variant.** No type parameter. Always cast: `_ref.get_ref() as MyNode`. Proposal #9174 + PR #109268 open. — godotengine/godot-proposals#9174, godot#109268.

9. **Multi-line lambda inside dict literal — parser error.** `"Unindent doesn't match the previous indentation level"` even with correct indentation in 4.6-stable. Workaround: extract lambda to a local var first. — godotengine/godot#116133.

10. **`GDScriptFunctionState` not exposed as a type.** `if state is GDScriptFunctionState:` fails. Workaround: `state.get_class() == "GDScriptFunctionState"`. — godotengine/godot#118425 (filed 2026-04-11).

11. **Underscored signals now hidden (intentional, 4.6).** `signal _internal` no longer in editor autocomplete, docs, or `get_signal_list()`. Convention now matches private methods. — PR #112770 (merged Nov 2025, ships 4.6).

**Active proposals to track:** #8530 type narrowing (HIGH); #10807 typed `Callable[Params, Return]` (HIGH for signals); #9174 `WeakRef[T]` (MED); #12567 traits (MED, PR #107227 active — most likely big 4.7 feature); #12928 GDType unified type system (MED, blocks structs); #13800 generics (LOW); #14106 `defer` (LOW); #7329 structs (BLOCKED on GDType); #12685 GDScript 3.0 (CLOSED — not a planned release).

### C. Tooling

Ranked by impact on our workflow.

1. **GUT 9.6.0 (Feb 24, 2026) — adopt now.** Singleton doubling (`double("Input")`, `Time`, `OS`); `wait_idle_frames(n)` yield helper that addresses MCP round-trip-latency timing pitfalls in `tests/README.md`; per-test elapsed-time methods; `assert_push_warning` / `assert_push_warning_count`; `print_tracked_errors`. **Breaking:** `assert_push_error` and `assert_engine_error` accept only a single string — use new `_count` variants for multi-error assertions. Scene-changing methods no longer break tests when run from editor. — github.com/bitwes/Gut/releases.

2. **GdUnit4 v6.1.3 (Apr 27, 2026) — monitor, don't switch.** Org renamed to godot-gdunit-labs/gdUnit4. Heavier than GUT; CI-first; C# variant separate. Recent: parse-error detection in CLI discovery, inspector freeze fix, backslash handling, HTML report quoting. Master branch already targets 4.7-beta1. v6.1.x supports 4.5 / 4.5.1 / 4.6 / 4.6.1 / 4.6.2.

3. **godot-ci 4.6.2-stable (Apr 1, 2026) — adopt when shipping.** Docker + GitHub Actions templates for export and Itch.io / GitHub Pages deploy. De facto standard. Not urgent during solo dev; set up at first public Itch release or nightly-build need. — github.com/abarichello/godot-ci.

4. **Tracy / Perfetto profiler integration in 4.7 — defer.** SCons `tracy_enable=yes` auto-detects; PR #113279. Memory leak in Tracy builds (#115798) still tracked. Requires a 4.7-dev build; skip until 4.7 stable. Editor profiler + MCP `get_performance_monitors` is sufficient at our scale.

5. **GodotEnv v2.16.2 (Jan 19, 2026) — low priority.** C# / .NET CLI. Manages Godot installs and addon versions; subdirectory-in-addon-key support. No further 2026 releases as of 2026-05-01. Useful for CI; not GDScript-native.

6. **godot-rust / gdext v0.5 (Mar 2026) — ignore.** Rust bindings; typed dictionaries, AnyArray, three safeguard tiers. GDScript project; no impact.

**MCP newcomers (2026):**
- **hi-godot/godot-ai** (Apr 29, 2026) — free, MIT, 120+ tools, made by the MCP-for-Unity team (8.5k stars). Watch; re-check in 4–6 weeks.
- **godot-mcp-core (CrucibleAI)** (Apr 21, 2026) — 32 tools, narrower than godot-mcp-pro, local-only with API-key auth. Low priority.
- **GDAI MCP** (date unknown, freemium) — 32 tools, 2D asset generation angle. Skip.

None replace godot-mcp-pro for our workflow.

### D. 2D platformer patterns

Ranked by relevance to current architecture.

1. **Camera limit-snap on room transition — workaround confirmed canonical (HIGH).** Pin camera at `get_screen_center_position()` before clearing `limit_*` while `position_smoothing_enabled = true`, then tween to target. No engine-level fix in 4.6.x. We already implement this (STRUCTURE.md transition step 5). — godotengine/godot#63330; forum.

2. **Hitbox / hurtbox layer convention (HIGH when combat lands).** GDQuest 4.6 canonical: hitbox = Layer 2, Mask 0, Monitoring OFF; hurtbox = Layer 0, Mask 2, fires `area_entered`; damage logic on receiver only; `monitorable = false` on inactive hitboxes (e.g. sheathed weapon). Commit layer numbering before combat work — changing later is painful. — gdquest.com/library/hitbox_hurtbox_godot4.

3. **ResourceSaver + nested subresources still broken in 4.6.x (HIGH when save system lands).** Sub-resources cross-referencing serialize as nulls. Workaround: `.duplicate(true)` each sub-resource before `ResourceSaver.save()`. Save to `user://` only in exports. Use Resource over JSON for native types; FileAccess.store_var for untrusted-source mitigation. — godotengine/godot#89961; forum.

4. **One-way collision direction — Vector2 (4.7 only, MED future).** PR #104736 merged 2026-02-10; `one_way_collision_direction` becomes a normalized Vector2. Relevant to grates, side-pass-through walls. Track for 4.7-stable upgrade (Q2–Q3 2026). Backwards-compatible. — godotengine/godot#104736, godot-proposals#12093.

5. **TileMapLayer corner-seam stuck-player bug still open (MED, future tile phase).** `safe_margin` mismatch at tile junctions catches CharacterBody2D. Workarounds: `safe_margin = 0`, rectangular per-tile collisions, or hand-built single-shape StaticBody2D platforms (our current). — forum / bugnet.io.

6. **AnimationPlayer pitfalls (MED).** `clear_queue()` called inside an `animation_started` signal handler crashes in 4.6.0/4.6.1, not confirmed fixed in 4.6.2 — defer the call. `queue()` silently skips if a looping animation is current — use `.play()` with a guard `if anim.current_animation != target`. Script-driven AnimationPlayer remains correct for discrete states; migrate to AnimationTree only when blending is needed. — godotengine/godot#116994, #93657.

7. **Camera2D screen shake — additive coroutine pattern (MED).** Single async coroutine owns shake; `add_shake(strength)` increments `current_strength`; lerp decay each frame; first call enters loop, repeated calls just add. Trauma-squared/cubed produces natural falloff. Verify our `GameCamera.add_shake` accumulates rather than resets. — forum / Alkaliii gist.

8. **Camera2D room locking — `Rect2i` per room is canonical; non-rectangular not supported (MED).** Phantom Camera (updated 2026-02-28) also rectangular-only. State-machine camera (follow / freeze / move-to-room / peek) emerging as best practice. Our pattern matches.

9. **Scene-per-room with door Area2D (LOW — already our pattern).** KoBeWi/Metroidvania-System now targets 4.6+ stable 1.6 branch; add when persistent room state (breakable walls, collected items, scroll transitions) becomes a requirement.

10. **TileMapLayer collision properties live on the TileSet's physics layers, not the node (LOW now).** Common trap: physics layer added but no collision polygon painted per tile. PR #108010 (4.6) lets scene tiles rotate in 90° increments — useful for room dressing. Becomes HIGH when we add tile art. — gdquest.com/library/cheatsheet_tileset_setup.

### E. Performance & deployment

Ranked by impact on our 2D / GL Compatibility / Apple-Silicon-friendly project.

1. **Canvas renderer write-combined memory reads (FIXED in 4.6.2, HIGH on Apple Silicon).** GH-111183 in 4.6 made `new_instance_data` return a pointer into a GPU buffer mapping; the `|=` accumulation then read from write-combined memory — catastrophically slow on M-series and discrete GPUs. Fix returns an intermediary pointer. Minor UMA regression (~200–300 µs/frame at 120k instances) negligible at 960×540. Must be on 4.6.2. — godotengine/godot#115757 (cherry-picked 2026-03-06).

2. **Sky shader `TIME` regression in 4.6.2 (HIGH if used; not us).** 8 layers allocated, shader fills 7 — last layer black, fully rough objects get black reflections. Cherry-pick to 4.6.3 confirmed (Repiteo 2026-04-13). Not a concern for 2D GL Compatibility. If using sky shaders with `TIME`: pin to 4.6.1 or wait for 4.6.3. — godotengine/godot#118110, #118317.

3. **macOS ANGLE-on-Metal forced in VMs (FIXED in 4.6.2, HIGH for CI).** GH-117371 detects macOS VM and forces ANGLE; passes on macOS 15 VM, macOS 26 VM, native macOS 26. Companion GH-117253 fixes Windows AMD ANGLE init crash (packHalf2x16 driver bug) — falls back to next driver instead of hanging. Confirm ANGLE libs in export template if setting up macOS CI. — godotengine/godot#117371, #117253, #117184.

4. **Shader material RAM 6.5× (FIXED before 4.6.0 stable).** Vulkan driver stored full SPIR-V bytecode in RAM unconditionally between 4.6dev5 and dev6. Gated on `pipeline_statistics` flag in GH-115049 (2026-01-19). Documented for forum-thread context. — godotengine/godot#115032, #115049.

5. **Tracy / Perfetto / Instruments profiler integration (4.6.0+, automatic in 4.7).** GH-113279 (4.6.0) — needs a custom build with the tracing flag; not in official export templates. 4.7 build system auto-integrates with `tracy_enable=yes`. For Apple Silicon frame-spike work, Instruments via custom build is worthwhile when editor profiler is too coarse. — phoronix.com/news/Godot-4.7-Beta.

6. **Core container optimizations (4.6.0).** `HashMap` fast-clear without zeroing, `Array::resize` no repeat copy-on-write, `Vector`/`CowData` push_back/insert without extra copy, `NodePath`-to-String caching, scene-tree group lookups, quadratic `String` append fix (GH-90203 closed 2026-02-12). Engine throughput, not GDScript bytecode speed. Prefer `PackedXxxArray`; prefer `_physics_process` over polling.

7. **Jolt Physics elastic-collision energy leak (FIXED in 4.6.2).** Dynamic bodies gradually gained spurious velocity. Kinematic rotation accuracy also improved. Use 4.6.2+ when 3D is added. Irrelevant to current 2D project. — GH-115305.

8. **GDScript closures + await + PackedArray crash (4.7-dev only, not 4.6.x).** Stack cleanup during coroutine unwinding triggered SafeRefCount error. Fixed in 4.7 via revert + GH-117053. Type-inference for inferred returns also stricter in 4.7.dev2 (#117081), breaking mixed-return-type functions. — godotengine/godot#117049, #117081, #117053.

9. **NVIDIA RTX Godot fork (Mar 13, 2026) — informational only.** Not upstream; 3D / DLSS focus; irrelevant for GL Compatibility 2D.

**Web / mobile:** No 4.6.x GL Compatibility web export regressions. WebGL 2.0 shader type-mismatch (#118684 / #118927) is 4.7-dev only. Web threading still requires `SharedArrayBuffer` + COOP/COEP headers. Android Vulkan crash rates dramatically improved in 4.6 via Mali / Adreno workarounds.

---

## 5. Open / Unresolved Issues — Watch List

| Issue | Status | Last seen | Re-scan trigger |
|---|---|---|---|
| #118521 — `is_action_just_pressed_by_event` mouse | Open, no milestone | 2026-05-01 | Any 4.6.x maintenance release; if we add mouse input |
| #116408 — AnimationPlayer events lost on 4.6.0→4.6.1 | Open, milestone 4.7 | 2026-05-01 | Before any upgrade past 4.6.0 |
| #115971 — `.tscn` exports non-deterministic 4.5→4.6 | Open, milestone 4.7 | 2026-05-01 | If we add patch-PCK or CI export pipeline |
| #117486 — TextureButton focus reverts on click | Open, milestone 4.7 | 2026-05-01 | When we add pause/HUD menus |
| #109926 — `move_and_slide` corner-as-floor | Open, no milestone | 2026-05-01 | Any platformer edge-physics regression |
| #118263 — `@tool` physics writes velocity to `.tscn` | Open | 2026-05-01 | Any time a tool script lands on a physics body |
| #94641 / #116141 — Lambda signal connection identity bugs | Open; PR #117336 not in 4.6.x | 2026-05-01 | Quarterly; if we add long-lived autoload signals |
| #118528 — `preload()` pins resources for game lifetime | Open, no milestone | 2026-05-01 | When room load/unload becomes hot |
| #119057 — Hot-reload Dictionary/Array NIL on live instances | Open; PR #119058 adds regression test | 2026-05-01 | Each 4.6.x maintenance |
| #116133 — Multi-line lambda in dict literal parse error | Open | 2026-05-01 | Any 4.6.x maintenance |
| #118425 — `GDScriptFunctionState` not exposed as type | Open | 2026-05-01 | If we use coroutine introspection |
| #118550 / #118552 — `UNTYPED_DECLARATION` warning highlights wrong line | Open; fix PR pending | 2026-05-01 | 4.6.3 / 4.7 release notes |
| #118557 — `abs(float)` flagged unsafe with no message | Open | 2026-05-01 | 4.6.3 / 4.7 release notes |
| #116994 — `AnimationPlayer.clear_queue()` crash in signal handler | Open in 4.6.0/.1; 4.6.2 unconfirmed | 2026-05-01 | Animation work; verify in 4.6.2 |
| #93657 — `AnimationPlayer.queue()` silently skips on loop | Long-standing | 2026-05-01 | Animation work |
| #89961 — ResourceSaver nested subresources nulls | Open in 4.6.x | 2026-05-01 | Before save-system implementation |
| #88067 — `is_on_floor()` erratic in TileMap | Open | 2026-05-01 | Tile art phase |
| #87477 / #109926 — TileMapLayer ceiling/corner stuck | Open | 2026-05-01 | Tile art phase |
| #118110 / #118317 — Sky shader TIME regression (4.6.2) | Cherry-pick to 4.6.3 confirmed | 2026-05-01 | Skip; 2D GL Compat unaffected |
| Proposal #8530 — narrow types after `is` | Open, last activity Apr 2026 | 2026-05-01 | 4.7 release notes |
| Proposal #12567 / PR #107227 — GDScript traits | Active impl | 2026-05-01 | 4.7 release notes |
| 4.7 breaking — one-way collision Vector2 direction | Merged into 4.7 | 2026-04-27 | At 4.7 stable upgrade |
| 4.7 breaking — GPUParticles2D angular velocity semantics | Fixed in 4.7 | 2026-04-27 | At 4.7 stable upgrade — revert any "negate" workaround |

---

## 6. Recurring Scan Recommendation

**Frequency:** monthly, with quarterly deep dives.

- **Monthly (~30 min):**
  - godotengine.org/blog for any maintenance release (4.6.3, 4.6.4) or 4.7 RC/stable announcement.
  - `Signal Emitted` weekly digest catch-up — skim last 4 weeks.
  - godotengine/godot release page and milestone-4.7 closed/open delta.
  - Watch-list issues (§5) — re-check status; bump last-seen; trim resolved entries.
  - GUT and GdUnit4 release pages for new versions.

- **Quarterly (~90 min):**
  - Re-crawl `sourcemap.md` venues to refresh contributor activity (have any of the 15 gone quiet?).
  - GodotCon / GodotFest video drops — GodotCon Amsterdam 2026 talks landing on official YouTube; GodotFest Munich (Nov 2026).
  - godot-rust monthly updates folded in (GDExtension API surface).
  - Re-audit watch list for any item idle >6 months — escalate or drop.

- **Triggered re-scan (immediate):**
  - 4.6.3 or 4.7-stable release announcement (full topic-agent re-run).
  - We adopt mouse input, save system, tile art, or combat — pull the relevant subsection forward and re-verify cited workarounds against current head.
  - Any project-wide upgrade past 4.6.2 — re-verify the AnimationPlayer-events-lost regression (#116408) and `.tscn` non-determinism (#115971).

- **What to watch:** maintenance release notes, milestone-4.7 burndown, `regression` / `confirmed` labels on watch-list issues, GDScript proposal #8530 / #12567 (traits) / #10807 (typed Callable) status changes.

- **Escalation:** ping core-dev contributors only if a watch-list issue blocks shipped work — @vnen / @dalexeev for GDScript, @groud / @KoBeWi for 2D / editor, @clayjohn for rendering, @rburing / @lawnjelly for physics, @akien-mga for release coordination. Do **not** file proposals or PRs we can't follow through on; the core team flagged AI-generated PRs as draining (Feb 2026).

**Self-recommendation:** the user asked for a frequency call — the monthly + triggered model above is the right balance for this project's pace. Quarterly deep dives keep the contributor list and venue rankings honest without becoming a chore.

---

## 7. Surprises

- **Godot 4.7 is NOT yet stable.** Beta 1 dropped 2026-04-24/27. Stable targeted Q2–Q3 2026. Treat 4.6.2 as the production baseline through this scan window.
- **AI-slop load on maintainers (Feb 2026):** core team publicly described AI-generated PRs as "draining and demoralizing." Direct relevance: do not file upstream PRs/proposals we can't shepherd. Our MCP-driven workflow is fine; what matters is that any *upstream* contribution comes with human follow-through.
- **GDScript 3.0 meta-proposal (#12685) is closed/archived.** It was a community wishlist (June 2025), not a planned release. Don't treat it as a roadmap item; track #8530 / #10807 / #9174 / #12567 / #12928 individually instead.
- **Open mouse input regression in 4.6.2 (#118521) filed 2026-04-13, still open.** Not a scope-changer but caught us off-guard during the 2026-05-01 update — would silently break any code using `_by_event` mouse checks.
- **`preload()` pins resources for the game's lifetime** (issue #118528, filed 2026-04-13). Affects Metroidvania room load/unload directly. Use `load()` or `ResourceLoader.load_threaded_request()` for room scenes; reserve `preload()` for small always-needed assets.

No category-one scope-changers. The 4.7 timeline is the biggest operational unknown.

---

## 8. Glossary

- **4.6.2-stable** — current production Godot release (2026-04-01); 122 fixes, 61 contributors. Our baseline.
- **4.7-beta1** — preview engine release (2026-04-24/27). Feature-frozen; bug fixes only from here. Stable target Q2–Q3 2026.
- **ANGLE** — OpenGL-ES emulation layer (Almost Native Graphics Layer Engine); Godot uses it for GL Compatibility on macOS (over Metal) and as a fallback on Windows.
- **GDExtension** — C++ / Rust / etc. native-code plugin API; contrasted with GDScript and the deprecated GDNative.
- **GDType** — proposed unified type system (#12928); blocks structs and generics.
- **GdUnit4** — alternative test framework to GUT; CI-first, heavier, also has C# variant.
- **godot-mcp-pro** — paid MCP plugin we use; live editor access over WebSocket (port 6505).
- **godot-mcp-core / hi-godot/godot-ai / GDAI MCP** — three new 2026 MCP entrants; none replace godot-mcp-pro yet.
- **GodotCon** — official Godot conference; 2026 edition Amsterdam Apr 23–24.
- **GodotEnv** — Chickensoft CLI tool for managing Godot installs and addons; .NET, useful for CI.
- **GodotFest** — separate community-run conference series; Munich Nov 2026.
- **GUT** — Godot Unit Test (bitwes); current 9.6.0 (2026-02-24); GDScript-native.
- **HDR output** — 4.7 feature; Windows / macOS / iOS / visionOS / Linux Wayland.
- **Jolt Physics** — third-party physics engine; Godot 4.6 default for new 3D projects.
- **JIT (4.6 GDScript)** — new just-in-time compiler; benefits typed code most.
- **LibGodot** — embed the engine as a library (4.6 feature).
- **MetSys (KoBeWi/Metroidvania-System)** — addon for object-ID persistence, save-data dictionaries, room-scroll transitions. Targets 4.6+.
- **Phantom Camera** — Camera2D / Camera3D control addon; rectangular limits only.
- **Scene Paint tool** — 4.7 editor addition for multi-scene placement.
- **TileMapLayer** — replacement for legacy TileMap (multi-layer tile rendering); collision properties on TileSet's physics layers.
- **TLC (Technical Lead Committee)** — Godot core contributor designation; appears on contributor profiles.
- **trauma (camera shake)** — strength variable raised to a power (often squared/cubed) for natural falloff.
- **Tracy / Perfetto / Instruments** — system-level profilers; Godot 4.6 supports via custom build, 4.7 auto-integrates.
- **`unique_id` (TSCN, 4.6)** — per-node ID added in 4.6 to support scene-inheritance refactoring; non-deterministic on first 4.5→4.6 open.
- **WC memory (write-combined)** — GPU buffer mapping that's fast to write, catastrophically slow to read. Source of the 4.6.0/4.6.1 canvas regression.

---

*This document supersedes the 2026-04-26 prior crawl. Re-run topic agents on next maintenance release or any of the triggered re-scan conditions in §6.*
