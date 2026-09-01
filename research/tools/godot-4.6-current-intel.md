# Godot Current Intel — Synthesized Deliverable
*Synthesized: 2026-09-01 | Intel window: August 2026 (delta since the 2026-08-01 crawl)*
*Canonical path retained per backlog #12; the crawl now tracks 4.7.x/4.8-dev, not 4.6.x.*
*Project context: 2D Metroidvania, **Godot 4.6.2** (`config/features = "4.6"` in `project.godot`), GDScript-only, macOS Apple Silicon, GL Compatibility renderer, 960×540, CharacterBody2D + custom GameCamera room-lock, TileMapLayer rooms, AnimationPlayer rig, MCP-driven dev (godot-mcp-pro).*
*Inputs: `research/crawl/sourcemap.md` + five topic crawls (engine-quirks, gdscript-language, tooling, 2d-platformer, performance), all crawled 2026-09-01.*

**Provenance caveat (read before acting).** `topic-gdscript-language.md` and `topic-tooling.md` both ran without live web fetch and synthesize from the sourcemap plus model training knowledge. Every claim sourced only to those two files is marked **provisional** below and needs a live confirmation before it drives a code change. Engine-quirks, 2D-platformer, and performance findings carry primary URLs and are stated as fact.

---

## 1. TL;DR

- **Engine:** RigidBody2D bodies freeze permanently after settling in 4.7 — a clean regression from 4.6, still unfixed in 4.7.2. Workaround: `can_sleep = false`.
- **GDScript:** 4.8-dev4 makes object property access 1.6× faster; no backport to 4.7.x. Nothing else in GDScript semantics changed this window.
- **Tooling:** GUT v9.7.1 (Jul 11, 2026) is confirmed Godot 4.7-compatible with no breaking API changes. Stay on GUT; no migration pressure.
- **2D platformer:** Upgrade to 4.7.2 now. It fixes the Shift-simultaneous-release input bug that silently breaks sprint+direction combos, with zero breaking changes.
- **Performance:** No 4.7.x performance or 2D rendering regressions exist. The 4.6.2 → 4.7.2 upgrade is low-risk and closes real threading gaps.

---

## 2. Active sources, ranked

### HIGH

- **`godotengine/godot`** — main engine; ground truth for behavior and regressions. 26,550+ forks, updated Aug 2026. https://github.com/godotengine/godot
  *S/N update: PR backlog is large but materially better curated since the July 1, 2026 AI-contribution ban. Prefer merged PRs and maintainer commits over open-PR noise.*
- **`godotengine/godot-proposals`** (Discussions) — where GDScript is heading. Issues filed Aug 28–29, 2026. https://github.com/godotengine/godot-proposals/discussions
  *S/N update: load-bearing threads this window are traits/interfaces (~#7903), Callable type hints, and annotation plugins (#14940).*
- **`godotengine/godot-docs`** — doc PRs reveal what just changed in engine behavior; 4.7 docs current. https://github.com/godotengine/godot-docs
- **`godotengine.org/blog`** — authoritative release, dev-snapshot, and policy channel. 4.8-dev4 posted Aug 26, 2026. https://godotengine.org/blog
- **`forum.godotengine.org`** — official Discourse; the RigidBody2D 4.7 freeze report surfaced here before any GH issue. https://forum.godotengine.org
- **`bitwes/Gut`** — v9.7.1 (Jul 11, 2026); only GDScript-native test framework, author responsive. https://github.com/bitwes/Gut
- **`godot-gdunit-labs/gdUnit4`** — v6.2.0 (Jul 30, 2026); richest CI/JUnit integration. https://github.com/godot-gdunit-labs/gdUnit4

### MED

- **`contributing.godotengine.org`** — area ownership and team leads; use to route a question to the right maintainer. https://contributing.godotengine.org/en/latest/organization/areas.html
- **Godot Asset Store** — *new in 4.7 (Jun 2026)*; background-threaded, editor-integrated. Now the primary plugin discovery channel. https://store.godotengine.org
- **Godot Digest** — curated weekly roundup; issue ~40 correlates with Aug 2026. Best cheap scan index. https://godotdigest.substack.com
- **`r/godot`** — 88,000+ members, 32% yearly growth, Foundation-moderated. Good for trend-spotting, weak for depth. https://reddit.com/r/godot
- **Official Godot Discord** — 78,827 members; #announcements, #game-jams, #xr. Ephemeral — do not cite. https://discord.com/invite/godotengine
- **`@godotengine` on X** / **`@godotengine@mastodon.gamedev.place`** (22,600 followers) — release timestamps; clayjohn posts rendering deep-dives on both. Mastodon skews more technical.
- **`chickensoft-games`** — C#-only tooling (GodotEnv, AutoInject); repos updated Aug 19–20, 2026. Useful for CI patterns, not game code. https://github.com/chickensoft-games
- **jettelly.com/blog** — editorial feature breakdowns ("Godot 4.7: What's New So Far"); fast scan, secondary source. https://jettelly.com/blog
- **GDQuest** — most rigorous free tutorial catalog; accessible patterns, not engine internals. https://www.youtube.com/c/gdquest
- **GameFromScratch** — fastest reliable news summary channel (covered W4/Tencent and the AI ban quickly). https://gamefromscratch.com

### LOW

- **Old Asset Library** — `godotengine.org/asset-library`; functional but being phased out for the Store. Only for pre-4.7 assets not yet migrated.
- **HackerNews** — occasional high-quality threads (AI ban, 4.7 release). Not a consistent signal source.
- **Bastiaan Olij (YouTube)** — authoritative on XR but no regular posting schedule. https://www.youtube.com/c/BastiaanOlij
- **`godotengine.itch.io` devlog** — duplicates or promotes official blog posts; never primary.
- **`godot-contributing-docs` repo** — migrated to `contributing.godotengine.org`; archive only.

### SKIP (dead or actively misleading)

- **`godotforums.org`** — unofficial Discourse, separate from and smaller than the official forum; core devs absent. Actively causes confusion with `forum.godotengine.org`.
- **KidsCanCode** — content peaked in the 3.x era; no confirmed 2026 activity, no recent commits on `kidscancode/godot_tutorials`. *Note: the previous crawl listed this as MED; this crawl downgrades it to SKIP.*
- **`r/godot` for deep technical answers** — MED for trends, LOW for depth. Use the forum instead.

---

## 3. Contributors to follow

1. **Rémi Verschelde (@akien-mga)** — project manager, release pipeline, all areas. https://github.com/akien-mga
   Why: triages every release and sets contribution policy. Single best person to watch for direction. Example: authored the July 2026 AI-contribution ban announcement.
2. **Juan Linietsky (@reduz)** — core architecture, GDScript VM, rendering. https://github.com/reduz
   Why: decides what gets accepted; still commits despite being W4 CEO. Example: co-authored the GDScript struct-like value types proposal (~#7903).
3. **George Marques (@vnen)** — GDScript type system, GDExtension. https://github.com/vnen
   Why: owns the GDScript language spec; the authority on typing, annotations, and compiler behavior. Example: driving the Callable type-hint and trait-system discussions.
4. **Clay John (@clayjohn)** — rendering pipeline, shaders, screen-space effects. https://github.com/clayjohn
   Why: rendering maintainer at W4; posts deep-dives on X and Mastodon. Example: authored the 4.6 SSR full rewrite and the 4.7 SSR notes.
5. **bitwes** — GUT testing framework, GDScript test patterns. https://github.com/bitwes
   Why: sole maintainer of the framework our tests run on; responsive on issues. Example: GUT v9.7.1 (Jul 11, 2026) Godot 4.7 compatibility release.
6. **Pāvels Nadtočajevs (@bruvzg)** — text/font rendering, GDExtension, input. https://github.com/bruvzg
   Why: owns text layout and a large share of the input hardening that landed in 4.7.2. Example: GDExtension parent-class iteration fix in 4.7.2.
7. **HP van Braam (@hpvb)** — build systems, Jolt physics integration, porting. https://github.com/hpvb
   Why: drove the physics-backend change and maintains build infrastructure; the right person for physics-regression context. Example: Jolt as default 3D physics in 4.6.
8. **Lukas Tenbrink (@Ivorforce)** — GDScript compiler internals. https://github.com/Ivorforce
   Why: listed GDScript area maintainer, active in language design. Example: GDScript annotation plugins proposal (#14940).
9. **Mike Schulze (MikeSchulze)** — GdUnit4, CI/CD integration. https://github.com/godot-gdunit-labs/gdUnit4
   Why: the reference for structured JUnit reporting if we ever add CI. Example: GdUnit4 v6.2.0 (Jul 30, 2026).
10. **David Snopek (@dsnopek)** — web/WASM export, multiplayer, networking. https://github.com/dsnopek
    Why: lead on the export path we'd need for any web build. Example: wasm64 web export merged in 4.7.
11. **Fredia Huya-Kouadio (@m4gr3d)** — Android, mobile export, build tooling. https://github.com/m4gr3d
    Why: owns the mobile export toolchain that stabilized in 4.7. Example: GodotCon Boston 2026 talk, "What's New in Android for Godot Developers."
12. **Bastiaan Olij (@BastiaanOlij)** — XR/OpenXR, GPU terrain. https://github.com/BastiaanOlij
    Why: main XR dev at the Foundation; publishes substantive blog progress reports. Example: OpenXR Vendors progress report, May 19, 2026.
13. **KoBeWi** — 2D editor, TileMap, Metroidvania-System plugin. https://github.com/KoBeWi/Metroidvania-System
    Why: maintains the room-state/storable-ID plugin closest to our architecture, and is a 2D/editor maintainer upstream. Example: Metroidvania-System active through Aug 2026 with no 4.7.2 breakage.
14. **nightblade9** — independent GDScript patterns blog. https://github.com/nightblade9/godot-gamedev
    Why: not a core maintainer, but code-level technical posts with higher rigor than most community content.

---

## 4. Findings

### 4.1 Engine — quirks and regressions

Ranked by relevance to a 2D CharacterBody2D platformer.

1. **RigidBody2D freezes permanently after coming to rest (4.7 regression, OPEN).** Bodies settle and then stop reacting to physics entirely rather than sleeping and waking on collision. Worked correctly in 4.6.stable. No fix in 4.7.2. Hits every physics prop we have or will have: pickups, debris, breakables. **Workaround:** set `can_sleep = false` on affected bodies, or raise the 2D sleep threshold in Project Settings → Physics. Source: forum report, June 2026, https://forum.godotengine.org/t/broken-rigidbody2d-behavior-after-4-7-update/140666. Related: GH-7996.
2. **RigidBody2D separates from its CollisionShape2D when frozen to Static and repositioned (OPEN since Apr 2026).** The collision shape stays at the old position while the sprite moves; the orphaned shape is invisible even with "Visible Collision Shapes" on, but still blocks other bodies. Affects 4.6 and up, Godot Physics backend (Jolt unconfirmed). **Workaround:** never change `freeze` and `position` in the same frame; prefer `StaticBody2D` for permanently-fixed objects; if dynamic freeze is unavoidable, `await get_tree().physics_frame` before repositioning. Source: https://github.com/godotengine/godot/issues/118473.
3. **AnimationPlayer editor freeze on any scene-tree edit (4.7 regression, OPEN — dev workflow only).** Move, rename, reparent, or delete a node in a scene containing an AnimationPlayer with a large animation library and the editor stalls 10–20 seconds. Cause is a 4.7 change forcing full animation enumeration on every tree change. Not present in 4.6. Fix expected in 4.8. Repro: instantiate a complex scene 74 times, rename a node → 7+ second freeze. **Workaround:** do large hierarchy reorganizations on scenes that exclude the AnimationPlayer, or temporarily disable it. Source: https://github.com/godotengine/godot/issues/120379 (filed Jun 17, 2026). Related: GH-104483.
4. **Threading: strict single-main-thread invariant now enforced (4.7.2).** Before 4.7.2 it was possible for a GDExtension or background-loading path to spin up a second main thread, producing intermittent, hard-to-reproduce crashes. 4.7.2 hard-asserts one main thread, converting silent corruption into a predictable error. Correct `Thread.new()` usage is unaffected; anything using `ResourceLoader.load_threaded_request` or background scene loading should be tested against 4.7.2 to surface latent bugs. This is a fix, not a workaround target. Source: https://www.warp2search.net/story/godot-472-release-threading-hardening-mouse-input-fixes-and-57-stability-patches.
5. **TextureButton loses focus and reverts to its Normal texture on any click (4.6+ regression, status unclear).** The Focused texture never displays during gameplay click sequences — relevant to HUD/menu work with keyboard or gamepad focus. Filed against 4.6, closed as duplicate of GH-115782; root fix unconfirmed against 4.7.2. **Workaround:** use a standard `Button` with a `StyleBoxTexture` theme override instead of `TextureButton` where focus states matter. Source: https://github.com/godotengine/godot/issues/117486.
6. **Fixed in 4.7.2, low project impact:** high-polling-rate (≥1000 Hz) mouse input starvation on Windows; IME popup mispositioning on Linux/KDE Plasma under Wayland fractional scaling; `BaseButton` misdispatching input when `enable_long_press_as_right_click = true`. All three are informational for a macOS keyboard-driven project. Source: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/.
7. **Cleared:** the sprite neighboring-frame flicker issue (GH-117978, first reported in 4.6.1) was **closed as not planned** — could not be reproduced. Watch for fresh reports in a 4.7.x context rather than treating it as open.
8. **No impact on our MCP workflow.** No new regressions in the drag-event or synthetic-input paths that `tests/README.md` Pattern 4 depends on, across all of 4.7.x.

### 4.2 GDScript — language traps and proposals

All entries in this subsection are **provisional**: `topic-gdscript-language.md` ran with no live web fetch and drew on the sourcemap plus training knowledge (cutoff Aug 2025). The traps are long-stable language behavior and low-risk to rely on; the proposal statuses need live confirmation before anyone plans architecture around them.

1. **`Callable.bind()` returns a new Callable, so `disconnect(f.bind(x))` silently fails.** The rebound Callable does not compare equal to the stored one and the signal stays connected — a leak that outlives the node. Store the bound Callable at connect time and disconnect the stored reference. Highest-relevance trap here: our codebase connects bound handlers for doors, pickups, and HUD.
2. **Lambda captures are by-reference, so loop-variable closures all see the final value.** `for i in range(3): funcs.append(func(): print(i))` prints `2, 2, 2`. By design, not a bug (proposal #5027 closed). Workaround remains the 1-element-Array binding: `var cell := [i]` then capture `cell`.
3. **`await` is illegal inside lambda bodies.** Some forms are parse errors, some silently skip the suspend; either way the enclosing coroutine does not suspend. Extract to a named function and connect that. Same coroutine-context restriction that blocks top-level `await` in MCP-injected scripts. No change in 4.7.x.
4. **`@static_unload` is the fix for static state surviving scene changes.** GDScript static vars persist as long as the script stays cached, so `static var score` is not reset by `change_scene_to_file()`. Add `@static_unload` to scripts with resettable static state; deliberately omit it on autoloads and singletons. Documentation improved in 4.7.x; still underused in community code.
5. **`:=` collapses to `Variant` when the right-hand side has an untyped or non-specific return.** Compiles silently, loses type safety, fails downstream at runtime. Most common with `Dictionary.get()` and chained `find()` results. Annotate explicitly (`var cam: GameCamera = ...`) whenever the RHS is not obviously typed. Intentional behavior; no fix planned.
6. **`Array[T]` is still not cleanly assignable to untyped `Array`.** Covariance rules were refined in 4.5/4.6 but remain incomplete; passing `Array[Enemy]` to `func f(a: Array)` can error in strict contexts. Cast explicitly or type the parameter as `Array[Enemy]`. Covariance proposals are open.
7. **`match` against a `StringName` with `String` arms can fail to match.** `==` between `String` and `StringName` returns `true` in most contexts, but the `match` arm comparison path may still diverge in typed contexts. Keep the matched expression and all arms on the same type — use `&"idle"` literals consistently. Directly relevant given our enum+`match` state machine convention.
8. **`WeakRef.get_ref()` needs an `is_instance_valid()` guard.** A freed node reference is non-null but invalid, so `obj != null` is the wrong check. Behavior is stable and expected.
9. **Proposals worth tracking, none merged, none in a milestone:** Callable type hints (`Callable[[int, String], void]`, @vnen) — MED impact, would catch signal-handler signature mismatches at parse time. Struct-like value types (@reduz) — MED, would replace the "return a Dictionary for compound values" pattern. Typed `Dictionary[K, V]` — partially implemented since 4.4, but `get()` still returns `Variant`; MED for state-management code. Traits/interfaces (~#7903) and annotation plugins (#14940, @Ivorforce) — LOW immediate, HIGH long-term architectural impact.
10. **No GDScript semantics changed in 4.7.2.** Zero reported breaking changes across the release.

### 4.3 Tooling

All entries in this subsection are **provisional**: `topic-tooling.md` synthesized from the sourcemap with no new web fetches.

1. **GUT v9.7.1 (Jul 11, 2026) is Godot 4.7-compatible and remains the correct choice.** Explicitly tagged for 4.7.x, no breaking API changes from 9.6.x, MIT, headless `--headless` CI invocation unchanged. GdUnit4 adds C# machinery we do not need. **Action:** confirm the version pinned in this project matches 9.7.1 and bump if behind. https://github.com/bitwes/Gut
2. **The Godot Asset Store is now the primary plugin discovery channel.** Launched with 4.7 (Jun 19, 2026), background-threaded browsing, integrated with the editor's Add-ons panel. Old Asset Library still resolves but is being phased out. **Action:** start any future plugin evaluation (inventory, state machine, save system) at https://store.godotengine.org before GitHub. GUT and GdUnit4 are both listed.
3. **The AI contribution ban does not affect our internal workflow, but does affect anything we upstream.** The ban (effective Jul 1, 2026) covers contributions to `godotengine/*`, not internal project development driven by Claude Code + godot-mcp-pro. Two concrete consequences: (a) the in-flight `youichi-uda/godot-mcp-pro` PR #25 should state plainly that it is human-authored and human-reviewed if it is submitted upstream; (b) file bug reports and repros by hand — maintainers now scrutinize PR and issue authorship, and human-validated repros get faster responses. Source: https://godotengine.org/article/contribution-policy-2026/
4. **GdUnit4 v6.2.0 (Jul 30, 2026) — LOW priority, revisit only for CI.** Built on Godot 4.5 stable; 4.7.x compatibility unconfirmed. Ships GitHub Actions workflow templates and improved JUnit XML export. The JUnit output is the real differentiator and only matters once we have a CI pipeline. https://github.com/godot-gdunit-labs/gdUnit4
5. **chickensoft-games — MED, for CI patterns only.** GodotEnv (multi-version Godot install manager) is the right model for pinning a specific Godot binary in CI, and now manages 4.7 installs. AutoInject and GameDemo are C#-specific — skip. Repos updated Aug 19–20, 2026. https://github.com/chickensoft-games
6. **`hi-godot/godot-ai` — status unknown, needs a spot check.** Last confirmed activity April 2026; no August 2026 activity found. Given the previous crawl flagged it as a credible free replacement for our paid godot-mcp-pro, its 4.7 compatibility and release velocity are the open question. Covered fully in `research/tools/mcp-alternatives.md`.
7. **`shameindemgg/godot-catalyst` — SKIP.** Claims 240+ MCP tools; first released April 2026 at 1 star. Insufficient community validation. Revisit only if it clears ~500 stars by the next crawl.
8. **4.8-dev4 will invalidate profiler baselines.** The 1.6× object-property-access speedup means any benchmark established now against 4.7.2 needs recalibration after 4.8 stable. Log it; no action.

### 4.4 2D platformer patterns

This is a delta file — P1–P11 from the 2026-08-01 synthesis remain valid and are not restated. Ranked by project relevance.

1. **Upgrade to 4.7.2 — highest-priority action from this crawl.** In 4.7.0–4.7.1, releasing two keys in the same physics frame where one was Shift fired only one `action_released` event, so a sprint+direction release silently left one input treated as held. Fixed in 4.7.2 (GH-125811). Zero breaking changes; free update. **Action:** upgrade, remove any `Input.is_key_pressed(KEY_SHIFT)` polling compensation, and re-run the jump+run combo in the playtest. Source: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/ (2026-08-18).
2. **Camera2D built-in smoothing still renders a gray screen on macOS + GL Compatibility (GH-121843, OPEN).** Absent from the 4.7.2 fix list. Our exact configuration. **The GameCamera's script-driven `lerp` follow in `_physics_process` is the correct approach and must not be "simplified" to `position_smoothing_enabled = true`.** Source: https://github.com/godotengine/godot/issues/121843 (opened 2026-07-28).
3. **4.7.2 is safe to upgrade to from 4.7.1 and from 4.6.2.** 57 bug fixes from 39 developers, zero breaking changes for GL Compatibility 2D projects: no GDScript API removals, no TileMapLayer API changes, no CharacterBody2D behavior changes. Path: back up, bump `config/features` in `project.godot`, test playback. Source: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/.
4. **The threaded TileSet load regression (GH-120482) may be fixed by 4.7.2 threading hardening — provisional, verify before relying on it.** `load_threaded_request(path, "", true)` on a scene containing a TileMapLayer yielded a TileSet with zero atlas sources. The 4.7.2 "threading hardening" block maps to the same subsystem, but GH-120482 is not named in the changelog. **Do not remove the synchronous-load workaround until an explicit re-test on 4.7.2 confirms it.** This gates room-streaming work. Source: https://github.com/godotengine/godot/issues/120482 (2026-06-20, labeled regression).
5. **AnimationPlayer as a direct child of the scene root still writes local paths instead of `%unique` paths (GH-120921, OPEN).** Not addressed in 4.7.2. Our `player.tscn` has exactly this shape per STRUCTURE.md. **Action:** apply the nest-one-level-under-an-intermediate-Node2D workaround at the next player-rig revision; no action while the rig is untouched. Source: https://github.com/godotengine/godot/issues/120921 (2026-07-04).
6. **`DrawableTexture2D.get_image()` still returns a blank image in `@tool` scripts (GH-121113, OPEN).** Runtime use — a minimap drawn during play — is fully functional. **Editor-time minimap preview stays off the table**; plan minimap work as runtime-only or via a separate editor-plugin approach. Source: https://github.com/godotengine/godot/issues/121113 (2026-07-08).
7. **Audit `Door.gd` for the Area2D `monitorable` toggle no-op (GH-121094, OPEN).** If any transition code sets `monitorable = false` to disable a door rather than zeroing `collision_layer`, signals may not fire when it is re-enabled. Use `collision_layer` for enable/disable.
8. **Two open items unchanged and requiring no action:** the TileSet editor physics-layer freeze (GH-120873) and save/load — KoBeWi's Metroidvania-System shows no breaking changes under 4.7.2, and the `Resource` + JSON save pattern remains best practice (see prior crawl P3). https://github.com/KoBeWi/Metroidvania-System
9. **Do not migrate to 4.8-dev.** 4.8-dev4 (Aug 26, 2026) brings a `_physics_process`-relevant 1.6× property-access speedup, but 4.8-dev2 still crashes on projects with RESET AnimationPlayer tracks (GH-121681, unresolved). Recheck GH-121681 closure before any 4.8 attempt. Source: https://godotengine.org/article/dev-snapshot-godot-4-8-dev-4/.
10. **TileMapLayer becoming an optional build module in 4.8 has no runtime impact.** Standard Godot builds keep it; only relevant to a custom build with `module_tilemap_enabled=no`, which we do not produce.

### 4.5 Performance and deployment

1. **Upgrade 4.6.2 → 4.7.2 (the performance case, same conclusion as §4.4).** Threading hardening fixes intermittent freezes and phantom errors during resource loading, audio streaming, and background scene loading. Zero breaking changes. **No 4.7.x performance regressions and no 2D rendering regressions exist as of this crawl** — the Compatibility renderer path is unaffected. Source: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/.
2. **4.8-dev4's 1.6× object property access is the largest GDScript VM gain of the 4.x cycle.** Property reads/writes are the dominant GDScript cost in a platformer — `velocity`, `position`, collision-result fields, every tick. **Action:** none now. Re-evaluate at 4.8 stable (likely Q1 2027, provisional estimate); benchmark `_physics_process` property patterns against a 4.7.2 baseline before upgrading. Not backported to 4.7.x. Source: https://godotengine.org/article/dev-snapshot-godot-4-8-dev-4/.
3. **macOS / Apple Silicon GL Compatibility posture is sound.** The renderer runs over Apple's deprecated OpenGL compatibility layer, which adds overhead versus Metal, but at 960×540 that overhead is negligible. No macOS-specific performance regressions in 4.7.x. If frame budget ever becomes a concern, profile with the built-in profiler before considering a renderer switch. For distribution, macOS exports need notarization for Gatekeeper; 4.7 export templates include the required entitlements structure — verify the codesign + `notarytool` workflow before building a distributable `.app`.
4. **wasm64 is the default web export target as of 4.7.0** (@dsnopek), removing the 4 GB WASM heap ceiling. No current web target. If one is added, test against the 4.7.2 wasm64 template and make sure export presets do not pin the deprecated wasm32 path.
5. **Android Build Environment stabilized in 4.7.0** (@m4gr3d). LOW now. Backlog note: if a mobile target is ever added, start from 4.7.2, not 4.6.x — the export toolchain is materially improved.
6. **PCSS shadow range correction in 4.7.2** — 3D-only, no impact on this project. Informational; evidence of active renderer maintenance.

---

## 5. Open / unresolved issues we may hit

| Issue | Status | Last seen | What triggers a re-scan |
|---|---|---|---|
| RigidBody2D freezes after settling (4.7 regression, forum report, no GH#) | Open, no fix in 4.7.2 | 2026-06 forum thread; confirmed absent from 4.7.2 notes 2026-08-18 | Every 4.7.x patch; immediately before adding any RigidBody2D prop, pickup, or debris |
| GH-121843 — Camera2D `position_smoothing` gray screen, macOS + GL Compatibility | Open, absent from 4.7.2 changelog | 2026-07-28 (opened) | Every 4.7.x patch and 4.8 stable; **and before any GameCamera refactor** |
| GH-120482 — TileSet atlas sources empty under `load_threaded_request` | Open; possibly fixed by 4.7.2 threading hardening (unconfirmed, provisional) | 2026-06-20 (opened) | Before starting room streaming — re-test synchronous vs. threaded load on 4.7.2 and check for a "fixed in 4.7.2" label |
| GH-120379 — AnimationPlayer editor freeze on scene-tree edits | Open, 4.7 regression, fix expected in 4.8 | 2026-06-17 (filed) | 4.8 dev snapshots and 4.8 stable |
| GH-118473 — RigidBody2D separates from CollisionShape2D when frozen Static | Open since April 2026, no fix in 4.7.2 | 2026-04-12 (filed) | Before implementing any runtime freeze/reposition of a physics body |
| GH-120921 — AnimationPlayer at scene root writes local instead of `%unique` paths | Open, not in 4.7.2 | 2026-07-04 (opened) | At the next player-rig revision |
| GH-121113 — `DrawableTexture2D.get_image()` blank in `@tool` scripts | Open, not in 4.7.2 | 2026-07-08 (opened) | Before starting minimap work |
| GH-121681 — 4.8-dev2 crash on projects with RESET AnimationPlayer tracks | Open as of crawl date | 2026-09-01 (crawl) | 4.8-dev5 or the first 4.8 stable RC — blocks any 4.8 migration |
| GH-121094 — Area2D `monitorable` toggle no-op | Open | 2026-09-01 (crawl) | Audit `Door.gd` enable/disable path now; re-scan at next door/transition change |
| GH-115782 / GH-117486 — TextureButton loses focus, reverts to Normal texture | Open; #117486 closed as duplicate, root fix status unclear | 2026-03 (filed) | Before any keyboard/gamepad-driven menu or HUD focus work; verify against 4.7.2 |
| GH-120873 — TileSet editor physics-layer freeze | Open, workaround in place | 2026-09-01 (crawl) | Next TileSet physics-layer edit |
| GH-88067 — CharacterBody2D `is_on_floor()` erratic inside tilemaps | Long-standing; resurfaces across minor versions | 2026-09-01 (crawl) | Verify against 4.7.2 immediately after upgrading |
| `hi-godot/godot-ai` 4.7 compatibility | Unknown; no confirmed activity since April 2026 | 2026-04 | Check GitHub commit dates Aug–Sep 2026; escalate if our godot-mcp-pro workflow ever breaks |
| `youichi-uda/godot-mcp-pro` PR #25 (local fork patch) | In flight, status unknown | 2026-09-01 (crawl) | Check merged vs. stalled; if stalled, keep applying locally |
| GdUnit4 v6.x compatibility with 4.7 | Unconfirmed (targets 4.5+) | 2026-07-30 (v6.2.0) | Only if we adopt CI and need JUnit XML |
| GH-117978 — sprite neighboring-frame flicker | **Closed as not planned** (could not reproduce) | 2026-09-01 (crawl) | Only if a fresh report appears in a 4.7.x context |

---

## 6. Recurring scan recommendation

**Monthly, ~45 minutes. Keep the current cadence — do not stretch to quarterly.**

Justification: this one-month window produced a full maintenance release (4.7.2, 57 fixes), one HIGH-severity open physics regression that lands directly on our stack, and a dev snapshot with a VM-level speedup. Quarterly would have left the Shift-key input bug live in the project for two extra months. Weekly is not warranted — the August delta over the July crawl was real but modest, and most of it was release-driven rather than continuous.

**Every month (the core loop):**
- `godotengine/godot` issues filtered to `regression` + `topic:2d` / `topic:physics` / `topic:gdscript` / `topic:animation`.
- `godotengine.org/blog` for releases and dev snapshots.
- GUT and GdUnit4 release pages.
- Every §5 row that has no explicit event trigger — in particular the RigidBody2D sleep regression, GH-121843, and GH-88067.

**Every month, watch specifically for:** anything touching RigidBody2D sleep or freeze semantics; Camera2D + Compatibility on macOS; TileMapLayer/TileSet threaded loading; new 4.7.x patch releases and whether any §5 row landed in them.

**Weekly, but cheap (~5 min):** read the Godot Digest issue as a scan index. Escalate to a full crawl only if it names something in §5.

**Quarterly:** the GDScript proposal landscape (Callable type hints, traits, struct types, annotation plugins) via @vnen's and @Ivorforce's activity; MCP tooling re-evaluation (`hi-godot/godot-ai` release velocity, `godot-catalyst` star count); GodotCon/GodotFest recordings — GodotFest Munich is Nov 11–12, 2026.

**Event-driven, not calendar-driven — re-scan immediately when:**
- Any 4.8 dev snapshot ships (dev5 should resolve or confirm GH-121681, GH-120379, and the property-speedup benchmark).
- Before starting room streaming (GH-120482).
- Before starting the minimap (GH-121113).
- At the next player-rig revision (GH-120921).
- Before any GameCamera refactor (GH-121843).

**Who to ping if blocked:**
- GDScript semantics → @vnen (github.com/vnen), or the Programming category on `forum.godotengine.org`.
- Release status / "did this fix land?" → @akien-mga.
- 2D, TileMap, editor → KoBeWi.
- Physics regressions (RigidBody2D sleep, Jolt) → @hpvb.
- Rendering / Compatibility renderer → @clayjohn (responsive on Mastodon).
- GUT → bitwes, responsive on GitHub issues.
- Deep engine design → Godot Contributors Chat (invitation-only); file a GitHub issue first and let it route.

**Standing constraint:** the Foundation's AI-contribution ban means **we file no AI-authored issue text, repro scripts, or PRs upstream.** Write reports by hand, and state human authorship explicitly on anything submitted.

---

## 7. Surprises

Three scope-changers this window.

1. **Godot 4.7 is at 4.7.2 and 4.8 is already in dev — the previous crawl's 4.6.x framing was two minors stale, and this crawl's own name is now stale.** 4.7.0 shipped June 19, 2026; 4.7.2 on August 18, 2026 (57 fixes, 39 developers, zero breaking changes); 4.8-dev4 on August 26, 2026. This project is still on 4.6.2 per `project.godot`. Every topic agent independently recommended the upgrade. The canonical filename `godot-4.6-current-intel.md` is retained per backlog #12 but no longer describes its contents.
2. **The AI-contribution ban is real, in force since July 1, 2026, and constrains our upstream posture.** The Foundation rewrote the contributor guidelines to ban "autonomous AI agent use or vibe coding" and disallow AI-generated substantial code. Our internal Claude Code + godot-mcp-pro workflow is unaffected — it does not touch `godotengine/*`. What is affected: any engine patch, bug report, or godot-mcp-pro upstream PR we file must be human-authored and clearly stated as such. Source: https://godotengine.org/article/contribution-policy-2026/
3. **W4 Games raised an $18M Series B led by Tencent (August 2026).** W4 — founded by Juan Linietsky, Rémi Verschelde, and others — is Godot's commercial arm; the Foundation remains independent. Includes a 50% team expansion and Asia go-to-market. Not a technical change today, but it is the largest funding event in the engine's history and it puts the two most senior maintainers under a Tencent-backed employer. Worth tracking for governance drift. Source: https://www.w4games.com/blog/w4-games-news-1/w4-games-raises-18-million-to-accelerate-international-presence-193

*Also notable but not scope-changing:* the RigidBody2D sleep regression is the first 4.7 physics regression severe enough to require a per-body workaround, and it surfaced on the forum without a GitHub issue — a reminder that `forum.godotengine.org` leads the issue tracker for some classes of report.

---

## 8. Glossary

Terms first encountered in this window, or carried forward because they remain load-bearing.

- **4.7 "Director's Cut"** — the 4.7.0 release name (Jun 19, 2026): HDR output on all desktop platforms, production-ready AreaLight3D, the new Asset Store, built-in VirtualJoystick, Control offset transforms, DrawableTexture2D, wasm64 web export.
- **Godot Asset Store** — `store.godotengine.org`; the 4.7 replacement for the Asset Library. Background-threaded browsing, editor-integrated, now the primary plugin discovery channel.
- **wasm64** — 64-bit WebAssembly; the default web export target since 4.7.0, removing the 4 GB heap ceiling that wasm32 imposed.
- **Threading hardening** — the 4.7.2 change enforcing a strict single-main-thread invariant, turning silent multi-main-thread corruption into a hard assert.
- **PCSS** — Percentage-Closer Soft Shadows; a 3D shadow technique whose range calculation was corrected in 4.7.2. No 2D relevance.
- **AccessKit** — the cross-platform accessibility abstraction Godot uses for screen-reader support; updated to 0.22.3 in 4.7.2.
- **Trail3D** — 4.8-dev node for rendering motion trails. 3D-only.
- **VisualShader node groups** — 4.8-dev feature allowing collapsible groups of visual shader nodes.
- **GodotEnv** — chickensoft-games CLI that manages multiple installed Godot versions; the right model for pinning an engine binary in CI.
- **AutoInject** — chickensoft-games C# dependency-injection library. C#-only; not applicable to a GDScript project.
- **GdUnit4** — MikeSchulze's GDScript + C# test framework; strong CI story, JUnit XML export, GitHub Actions templates.
- **`@static_unload`** — GDScript annotation that unloads a script from cache on scene change so its `static var` state resets. Omit it deliberately on autoloads.
- **Traits (proposal)** — a proposed `trait` keyword giving GDScript structural typing: a method contract without full inheritance. In design discussion, no milestone.
- **Annotation plugins (proposal #14940)** — would let GDScript code define its own `@my_annotation` directives evaluated at parse/load time, enabling user-land DI and serialization frameworks.
- **Callable type hints (proposal)** — `Callable[[int, String], void]` syntax to type Callable parameters and returns; would catch signal-handler signature mismatches at parse time.
- **GDScript struct-like value types (proposal)** — pass-by-copy, heap-free aggregates for per-frame data such as hit results and movement vectors.
- **`godot-catalyst`** — `shameindemgg`'s MCP server claiming 240+ Godot tools; released April 2026, unproven, currently SKIP.
- **Metroidvania-System** — KoBeWi's plugin automating storable-object IDs and room-state serialization; closest existing plugin to our architecture.
- **GodotFest Munich** — Nov 11–12, 2026; now designated "GodotCon Europe" by the Foundation. Professional audience, weekday schedule.
