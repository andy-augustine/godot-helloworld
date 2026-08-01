# 2D Platformer Patterns — Godot 4.7/4.8 Intel
*Window: July 2026 onward | Prior crawl covered through ~July 1, 2026*
*Synthesized: 2026-08-01 | Engine baseline: 4.7.1 stable, 4.8-dev2*
*Project context: Metroidvania, CharacterBody2D, custom GameCamera room-lock, TileMapLayer, AnimationPlayer rig, macOS Apple Silicon, GL Compatibility renderer*

---

## TL;DR

1. **Camera2D `position_smoothing` causes a fully gray screen on macOS + Compatibility renderer in 4.7.1** (GH-121843, open) — our exact hardware/renderer combo; disable smoothing in the node, do it in script.
2. **TileSet sources silently empty to zero when using `load_threaded_request` with `use_sub_threads = true` in 4.7** (GH-120482, open regression) — if we ever add threaded room preloading, use synchronous `load()` instead.
3. **Area2D `monitorable` toggle is unreliable while two areas are already overlapping** (GH-121094, confirmed 4.3–4.7) — change `collision_layer/mask` instead of `monitorable` for runtime hitbox toggling in door and hurtbox systems.

---

## Per-Pattern Entries

### 1. Camera — position smoothing (macOS + Compatibility renderer gray screen)

**New issue (July 28, 2026):** Enabling `position_smoothing` on Camera2D with the Compatibility renderer on macOS renders a fully gray screen. Forward+ renderer works. Windows Compatibility renderer works. macOS-only.

**Workaround:** Keep `position_smoothing = false` in the Camera2D node. Implement smoothing manually via `Tween` or `lerp()` in `_process()` applied to `camera.offset` or a separate follow position. Apply smoothing to `offset` (not `global_position`) so it doesn't fight room limits.

**Citation:** https://github.com/godotengine/godot/issues/121843 (2026-07-28, open, needs testing)

**Applicability: HIGH** — Our project uses macOS + Compatibility renderer + GameCamera with room locking. Any attempt to use built-in `position_smoothing` will immediately break rendering. The existing script-driven follow approach avoids this entirely; do not migrate to built-in smoothing while this is open.

---

### 2. Camera — screen shake pattern (confirmed best practice)

**Pattern (stable through 4.7):** Apply shake to `camera.offset`, not `camera.global_position`. Trauma-squared falloff (square the trauma value for a natural decay curve). Use an additive model when overlapping shakes fire in rapid succession. `reset_smoothing()` must be called after teleporting the player across a room boundary — otherwise the camera slides in from the previous room position.

**Citation:** https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424 (2026) | sourcemap §4.4 item 8

**Applicability: MED** — No changes to this pattern since the prior crawl. Relevant when implementing combat hit feedback.

---

### 3. TileMapLayer — threaded room loading regression (4.7)

**New regression (June 20, 2026, still open August 2026):** When a scene containing a TileMapLayer is loaded via `ResourceLoader.load_threaded_request(path, "", true)` (sub-threads enabled), the TileSet ends up with zero atlas sources at runtime. Tiles don't render, collision is absent, and `get_cell_tile_data()` errors. The tileset data is correct on disk — the cache gets poisoned. Does not happen in 4.6.x.

**Workaround:** Use synchronous `ResourceLoader.load()` for room scenes, or use `load_threaded_request(path, "", false)` (sub-threads disabled). If you need async loading to avoid frame hitches, load the PackedScene asynchronously but instantiate synchronously in one frame.

**Citation:** https://github.com/godotengine/godot/issues/120482 (2026-06-20, labeled regression, open)

**Applicability: HIGH** — Directly blocks any future room-streaming implementation that tries to preload rooms in the background. Workaround is safe and low-cost; document it before adding threaded loading.

---

### 4. TileMapLayer — converted to a module in 4.8-dev

**New (July 19, 2026):** PR #121548 merged into 4.8-dev converts TileMap(Layer) to an optional build module (`module_tilemap_enabled=no`). TileMapLayer files are nearly as large as all the rest of the 2D scene code combined; the module flag allows custom stripped builds to exclude it. No API changes, no behavior changes for standard builds. The flag defaults to enabled.

**Applicability: LOW** — No impact for our dev workflow. Relevant only if we ever create a custom engine build (unlikely). Watch for any 4.8 migration notes if the module boundary introduces edge cases.

**Citation:** https://github.com/godotengine/godot/pull/121548 (2026-07-19, merged to 4.8-dev)

---

### 5. TileMapLayer — physics layer painting spike

**New issue (July 2, 2026):** Setting up or painting physics layers onto tiles in the TileSet editor causes the 3D GPU workload to spike and freeze the editor. Reported with TileMapLayer in 4.7. No fix yet.

**Workaround:** Set physics layers in the TileSet editor before drawing tiles and exit the physics-paint mode before switching back to tile-placement.

**Citation:** https://github.com/godotengine/godot/issues/120873 (2026-07-02, open)

**Applicability: MED** — Editor-only; no runtime impact. Relevant during level-building sessions when editing physics layers.

---

### 6. Area2D — `monitorable` toggle unreliable while overlapping

**New report / broader detail (July 8, 2026):** Confirmed across 4.3–4.7: changing `monitorable` on an Area2D while it is already overlapping another Area2D has no effect on existing overlaps. The overlap is not re-evaluated. By contrast, changing `collision_layer` or `collision_mask` forces a re-evaluation and fires proper enter/exit signals. Also: toggling target `monitoring` while overlapping fires a spurious `area_exited` + `area_entered` pair.

**Pattern:** For runtime hitbox toggling (hurtboxes, door sensors, pickup zones), use `collision_layer = 0` to disable and restore it to re-enable. Do not toggle `monitorable` at runtime unless areas are guaranteed to not be overlapping.

**Citation:** https://github.com/godotengine/godot/issues/121094 (2026-07-08, open, needs testing)

**Applicability: MED** — Affects door trigger zones and any hurtbox that can be disabled mid-overlap (invincibility frames, phase transitions). The `collision_layer` workaround is safe and already the recommended pattern in GDQuest guides.

---

### 7. AnimationPlayer — unique node path bug when parented to scene root

**New issue (July 4, 2026, confirmed 4.7 stable + 4.7.1 RC1):** When an AnimationPlayer node is a direct child of the scene root, adding a new animation track to a node marked `%unique` uses a local path (`MyNode`) instead of the unique path (`%MyNode`). This causes tracks for the same node with different path styles to be grouped separately, breaking cross-animation synchronization.

**Workaround:** Nest the AnimationPlayer inside one intermediate node (not the scene root). A common structure is `Root → AnimationRoot (Node2D) → AnimationPlayer`.

**Citation:** https://github.com/godotengine/godot/issues/120921 (2026-07-04, open, confirmed 4.7 + 4.7.1 RC1)

**Applicability: MED** — Our player AnimationPlayer rig may be a direct child of the CharacterBody2D root. If we add new tracks and the rig uses `%unique` node names, track paths may be inconsistent. Apply the workaround preemptively at next rig revision.

---

### 8. AnimationPlayer + AnimationTree — inconsistent stop behavior

**New issue (July 29, 2026):** When using AnimationPlayer and AnimationTree together on the same node, the animation stopping condition in the editor is inconsistent with runtime behavior. Observed in 4.7.

**Relevance to us:** We use AnimationPlayer only (no AnimationTree). No impact unless we add blending later.

**Citation:** https://github.com/godotengine/godot/issues/121885 (2026-07-29, open)

**Applicability: LOW** — Confirms that staying AnimationPlayer-only is the lower-risk path for now.

---

### 9. Scene Paint Mode (4.7) — now with in-editor instructions (4.8-dev)

**New in 4.7, refined in 4.8-dev (July 11, 2026):** Scene Paint Mode (press `B` in the 2D editor) scatters real, editable scene instances across the 2D viewport — ideal for placing enemies, pickups, and props off the TileMapLayer grid. PR #121227 added proper in-editor instructions in 4.8-dev1. Also fixed: snap offset and scaled-node behavior (PR #120620, June 2026).

**Pattern:** Use Scene Paint Mode for enemy and pickup placement instead of hand-placing instances. The resulting nodes are real scene instances, not baked tiles, so they carry their own scripts and signals.

**Citation:** https://github.com/godotengine/godot/pull/121227 (2026-07-11, merged to 4.8-dev1) | https://github.com/godotengine/godot/pull/120620 (2026-06-24)

**Applicability: MED** — Useful for level design once enemies and pickups exist. No code impact; editor-only workflow improvement.

---

### 10. Control offset transforms (4.7 new) — HUD animation

**New in 4.7:** Control nodes gained offset transform animation support, allowing UI elements to be animated positionally via AnimationPlayer without touching anchors. This is the recommended pattern for animating health bars sliding in, damage number popups, and screen-edge HUD elements.

**Pattern:** Animate `offset_left`, `offset_top`, etc. in AnimationPlayer tracks on Control children (e.g., health bar, status icons). No longer requires workarounds via `position` which could break anchor-based layout.

**Citation:** https://godotengine.org/releases/4.7/ (2026-06-18) | sourcemap §3 milestone entry

**Applicability: HIGH** — Directly upgrades our HUD animation approach. Any damage flash, health-drain animation, or status icon entrance should use Control offset tracks in AnimationPlayer rather than position-based hacks.

---

### 11. DrawableTexture2D (4.7 new) — minimap use case, editor bug

**New in 4.7:** `DrawableTexture2D` provides a texture you can draw onto at runtime using the same `draw_*` API as `_draw()`. Suitable for a runtime Metroidvania minimap that reveals rooms as the player explores them.

**Known issue (July 8, 2026):** `DrawableTexture2D.get_image()` returns an incorrect (blank) Image in `@tool` editor scripts. Works correctly at runtime. Do not use it with `@tool` scripts for editor-time map generation.

**Citation:** https://github.com/godotengine/godot/issues/121113 (2026-07-08, open) | release notes 4.7

**Applicability: MED** — Useful when implementing a minimap subsystem. Plan for runtime-only use; editor preview will not work until GH-121113 is fixed.

---

### 12. HDR 2D (4.7 new) — Subtract blend mode broken

**New in 4.7, new bug (July 20, 2026):** Enabling HDR 2D (`Project Settings > Viewport > HDR 2D`) breaks the `Subtract` blend mode on CanvasItemMaterial — sprites render as opaque over transparent/empty space instead of subtracting. Still open as of August 2026.

**Applicability: LOW** — We are not using HDR 2D. Do not enable it until GH-121587 is resolved.

**Citation:** https://github.com/godotengine/godot/issues/121587 (2026-07-20, open)

---

### 13. Save/load — custom Resource + JSON best practice (confirmed, no change)

**Pattern (unchanged through 4.7):** Use a `Resource` subclass with `@export` fields and `.tres` format during development. For release builds, switch to `.res` (binary). For room/item state in Metroidvania games, store a `Dictionary` of discovered rooms and collected item IDs in an autoload singleton. Write to disk via `FileAccess` + JSON for portability and to avoid the security risk of `ResourceLoader.load()` on untrusted data (Resources can embed executable scripts).

**Note:** KoBeWi's Metroidvania-System plugin automates the storable-object ID assignment and room-state serialization for 4.6+ and is maintained as of mid-2026.

**Citation:** https://gdquest.com/tutorial/godot/best-practices/save-game-formats/ (2026) | sourcemap §4.4 item 3

**Applicability: HIGH** — Foundation for save/load when that subsystem is planned. No new changes, but confirmed as best practice.

---

## Pitfalls We May Already Be Hitting

| Pitfall | Risk | Check |
|---------|------|-------|
| Camera2D `position_smoothing` gray screen on macOS + Compatibility (GH-121843) | HIGH | Verify `position_smoothing = false` in GameCamera; if using built-in smoothing anywhere, disable immediately |
| AnimationPlayer direct child of scene root uses local paths, not `%unique` (GH-120921) | MED | Inspect player rig: is AnimationPlayer a direct child of CharacterBody2D root? Add one intermediate Node2D parent if so |
| Area2D `monitorable` toggle silently no-ops while overlapping (GH-121094) | MED | Audit all hitbox/hurtbox enable/disable code; replace `monitorable = false` with `collision_layer = 0` |
| Lambda captures `self` leaks RefCounted (GH-102327, unfixed 4.7.1) | MED | Scan for `signal.connect(func(): self.X)` patterns; use named method refs |
| TileSet threaded load silently empties sources (GH-120482) | LOW now | Will become HIGH if threaded room preloading is added; use synchronous load |

---

*Sources: github.com/godotengine/godot issues/PRs (searched August 1, 2026), sourcemap.md §3–4, godot-4.6-current-intel.md §4.4*
