# 2D Platformer Patterns — Godot 4.6 / 4.7
*Intel window: Jan 2026 – Jul 2026 | Written: 2026-07-01*

---

## TL;DR — Top 3 Findings

1. **Godot 4.7 fixes the TileMapLayer-disappears-at-certain-Camera2D-zoom bug** (issue #105645, PR #117725) — this affected 4.3 through 4.4.1 in Compatibility mode; upgrade to 4.7 if you see tilemap flickering.
2. **CollisionShape2D gains one-way direction control in 4.7** — new property lets you set the allowed collision direction as relative or global on any shape, eliminating rotation-hack workarounds for rotating platforms.
3. **`notify_runtime_tile_data_update()` is mandatory after runtime `set_cell` calls** — a persistent pitfall: physics shapes silently stay stale until you call this; follow with `update_internals()` only if you need immediate same-frame raycast results.

---

## Per-Pattern Entries

### 1. Camera2D — Room Locking

**New approach / refinement (2026):**
The standard pattern is to set `Camera2D.limit_left/right/top/bottom` per room. In Godot 4.7, `position_smoothing_enabled` combined with room transitions requires explicit reset — call `reset_smoothing()` (or temporarily disable smoothing) after teleporting the player to a new room origin, otherwise the camera slides in from the old room position creating a jarring pan.

For Metroidvania room-lock specifically: store each room's pixel bounds as a `Rect2` and assign them to the camera's four limit properties on room enter. This is unaffected by 4.6/4.7 changes — the API is stable.

**Known bug fixed in 4.7:** TileMapLayer vanishes at certain Camera2D positions in Compatibility rendering mode (affected 4.3–4.4.1). Fix merged as PR #117725, ships in 4.7.
- Source: [Issue #105645](https://github.com/godotengine/godot/issues/105645)
- **Applicability: HIGH** (project uses Camera2D with room locking and TileMapLayer rooms; upgrade to 4.7 eliminates risk)

---

### 2. TileMapLayer — Current Best Practice

**New approach / refinement (2026):**
TileMapLayer (replacing TileMap since 4.3) is now the only supported path in 4.7 — the old TileMap node is fully deprecated. Use one TileMapLayer node per logical layer (ground, background, foreground) — they are independent scene nodes now, easier to show/hide and script separately.

**Godot 4.6 addition:** Scene tiles in TileMapLayer can now be rotated in 90-degree increments natively — no more duplicating scene variants for each rotation. (PR #108010)
- Source: [Proposal #12570](https://github.com/godotengine/godot-proposals/issues/12570), [PR #108010](https://github.com/godotengine/godot/pull/108010)

**Runtime tile editing (set_cell):** After any batch of `set_cell()` calls, call `tile_layer.notify_runtime_tile_data_update()` once. Physics collision shapes rebuild on the next physics frame. Do NOT call it per-cell. If you need shapes available in the same frame (e.g. for an immediate raycast), follow with `update_internals()`.
- Source: [Forum thread #99417](https://forum.godotengine.org/t/tilemaplayer-notify-runtime-tile-data-update-doesnt-work-as-i-expect/99417)

**Ghost collision at tile seams:** CharacterBody2D can catch on tile corners in otherwise flat TileMapLayer surfaces (issue #89458). Fixed by merging adjacent tile polygons — PR #102662. Verify this fix is in your build; if still hitting it, a temporary workaround is a single StaticBody2D with merged collision geometry for that floor section.
- Source: [Issue #89458](https://github.com/godotengine/godot/issues/89458)
- **Applicability: MED** (project uses TileMapLayer rooms; scene-tile rotation is a nice gain; runtime editing not currently used but good to know for destructible tiles)

---

### 3. CollisionShape2D — One-Way Collision Direction (NEW in 4.7)

**New approach / refinement (2026):**
Godot 4.7 adds a one-way collision direction property to `CollisionShape2D`, allowing you to specify the allowed pass-through direction as either relative to the shape's local transform or in global space. Previously, one-way platforms on rotating or non-axis-aligned objects required rotation hacks or duplicated shapes; now it is a single inspector property.

This also improves `CharacterBody2D` on moving/rotating platforms — the engine resolves across all directions correctly.
- Source: [Proposal #12093](https://github.com/godotengine/godot-proposals/issues/12093), confirmed in 4.7 beta 1 notes
- **Applicability: MED** (no rotating platforms currently; relevant when adding conveyor or rotating hazard rooms)

---

### 4. Collision / Hitbox Layering — Area2D vs CharacterBody2D

**New approach / refinement (2026):**
The consensus layer scheme for a Metroidvania in 2026:

| Layer | Bit | Used for |
|-------|-----|----------|
| World | 1 | TileMapLayer physics, static walls/floors |
| Player | 2 | CharacterBody2D body |
| Enemy | 3 | Enemy bodies |
| Pickup/Trigger | 4 | Items, door triggers, room transitions |
| Projectile | 5 | Bullets, thrown objects |
| Hitbox | 6 | Attack hitboxes (mask = enemy hurtbox layer only) |
| Hurtbox | 7 | Damage-receive zones on all characters |

Hitboxes: use `Area2D` with `monitoring = true`, `monitorable = false`, `collision_mask = 0` unless actively attacking. Disable monitoring during idle frames for physics performance — the engine still runs overlap checks even on idle hitboxes if monitoring stays on.
- Source: [GDQuest hitbox/hurtbox library](https://www.gdquest.com/library/hitbox_hurtbox_godot4/), [Godot MCP Pro guide](https://godot-mcp.abyo.net/guides/godot4-collision-layers)

**Known pitfall:** Area2D fires phantom `body_entered` signals for CharacterBody2D nodes that start with disabled CollisionShape2D and enable via `set_deferred()` — all nearby Area2Ds trigger body_entered then body_exited spuriously on scene load (issue #88592, open as of mid-2026). Workaround: initialize CharacterBody2D with the shape already enabled (or add a one-frame check in the handler using `is_inside_tree()` + distance test).
- Source: [Issue #88592](https://github.com/godotengine/godot/issues/88592)
- **Applicability: HIGH** (project uses Area2D for door/room triggers and likely for item pickups; phantom signals could mis-fire room transitions on scene load)

---

### 5. Animation — AnimationPlayer vs AnimationTree

**New approach / refinement (2026):**
Script-driven `AnimationPlayer.play()` (what this project uses) remains valid for simple character rigs with ≤8 distinct non-blended states. The community consensus in 2026 is:

- **AnimationPlayer only** (current approach): fine for idle/run/jump/fall/attack if transitions are instantaneous. Scattering `play()` calls through state-machine code is the accepted trade-off.
- **AnimationTree + StateMachine**: necessary when you need blended transitions (e.g., run-to-walk blend, aim offsets). Adds visual graph editor complexity but removes scattered play() calls.

**Godot 4.7 note:** AnimationTree internals were optimized; `BlendSpace` point handling has a compat break — projects using BlendSpace2D that wrote against internal point ordering should retest in 4.7. Not relevant unless migrating to AnimationTree.
- Source: [Godot MCP Pro AnimationTree guide](https://godot-mcp.abyo.net/guides/godot4-animationtree), [Issue #92730](https://github.com/godotengine/godot/issues/92730)
- **Applicability: LOW** (current AnimationPlayer approach is fine; upgrade to AnimationTree only when blending becomes a felt need)

---

### 6. Room Transitions — Scene Management

**New approach / refinement (2026):**
Two dominant patterns in the Metroidvania community:

**Pattern A — change_scene_to_file() with autoload player:**
Player and camera live in an autoload (or are re-instantiated and repositioned). `get_tree().change_scene_to_file("res://rooms/room_b.tscn")` unloads the old room, loads the new one. Simple; loses old room state unless serialized.

**Pattern B — additive loading (SubScene / add_child):**
Keep player persistent; load new room as child of root alongside old room; fade transition; free old room after crossfade. More Metroid-authentic (adjacent rooms stay loaded). Heavier but enables seamless scrolling between adjacent rooms.

For door-based transitions (current project model), Pattern A with a fade overlay is the simpler and more common choice. Use `CanvasLayer` at layer 100 with a `ColorRect` animated via `AnimationPlayer` or `Tween`.

**`change_scene_to_file` caveat:** In Godot 4, camera `position_smoothing` does not auto-reset between scenes — must call `reset_smoothing()` or disable/re-enable smoothing in the new room's `_ready()`.
- Source: [GDQuest scene transition tutorial](https://www.gdquest.com/tutorial/godot/2d/scene-transition-rect/), [Metroidvania System wiki](https://github.com/KoBeWi/Metroidvania-System/wiki/Specific-Rooms)
- **Applicability: MED** (project already has door transitions; this confirms current approach is correct and flags the smoothing reset pitfall)

---

### 7. Save / Load

**New approach / refinement (2026):**
GDQuest and KidsCanCode both recommend **custom Resources** (`.tres`/`.res`) as the primary save format for singleplayer games in 2026:

- Create a class extending `Resource` with `@export` fields for all save data
- `ResourceSaver.save(save_data, "user://save.res")` — use `.res` (binary) for release, `.tres` (text) during development
- `ResourceLoader.load("user://save.res")` to restore
- Arrays of resources serialize without extra code in Godot 4

**When NOT to use custom resources:** Online/shared saves, or when players might edit files — use `FileAccess` + JSON instead (resource files can embed scripts and execute on load — security risk for untrusted input).

**Metroidvania-specific — room state persistence:** Track discovered rooms and collected items as Dictionary in a global autoload. On scene change, write the current room's diff to the autoload dict. Save the full dict on door transition or checkpoint. The Metroidvania System plugin (@KoBeWi, supports 4.6+) provides an automated storable-object ID system for this pattern if a plugin approach is acceptable.
- Source: [GDQuest save formats](https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/), [Metroidvania System storable objects wiki](https://github.com/KoBeWi/Metroidvania-System/wiki/Storable-Objects)
- **Applicability: HIGH** (save/load not yet implemented in this project; custom Resource + binary `.res` is the right foundation to build toward)

---

### 8. Screen Shake — Camera2D

**New approach / refinement (2026):**
The trauma-based system (popularized by Game Feel book) remains the 2026 standard:

```gdscript
var trauma: float = 0.0
var decay: float = 0.8

func add_trauma(amount: float) -> void:
    trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
    trauma = max(trauma - decay * delta, 0.0)
    var shake = trauma * trauma  # square for more dramatic falloff
    offset = Vector2(
        randf_range(-max_offset.x, max_offset.x) * shake,
        randf_range(-max_offset.y, max_offset.y) * shake
    )
```

For overlapping shakes (e.g., multiple explosions in rapid succession), use an **additive** model: each new shake adds to existing trauma rather than resetting it, so rapid events compound correctly. OpenSimplexNoise can replace `randf_range` for smoother directional shake.

**Pitfall:** Apply shake to `camera.offset`, NOT to the camera node's position or the viewport. Shaking position fights with the room-limit system; shaking offset stays within limits.
- Source: [KidsCanCode screen shake recipe](https://kidscancode.org/godot_recipes/4.x/2d/screen_shake/index.html), [Forum additive shake thread #108424](https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424)
- **Applicability: MED** (no screen shake implemented yet; this is the right pattern when adding combat feedback)

---

### 9. Godot 4.7 — Scene Paint Tool (2D Level Design)

**New approach / refinement (2026):**
Godot 4.7 adds a **Scene Paint Mode** (press `B` in the 2D editor) for quickly scattering scene instances (enemies, collectibles, decorations) without being restricted to a TileMap grid. Each painted instance is a real node, fully editable. Not tied to TileMapLayer — complements it for organic level dressing.

Useful for placing: enemy spawners, item drops, decorative props, trigger zones.
- Source: [Gaming on Linux coverage](https://www.gamingonlinux.com/2026/06/godot-engine-4-7-is-out-bringing-a-new-asset-store-hdr-support-steam-frame-support/), [Coding Quests 4.7 overview](https://codingquests.io/blog/godot-4-7-everything-new)
- **Applicability: MED** (useful for future rooms with enemies and pickups; no code impact)

---

## Pitfalls Reported in 2026

| Pitfall | Versions | Status | Action |
|---------|----------|--------|--------|
| **TileMapLayer vanishes with Camera2D zoom in Compatibility mode** | 4.3–4.4.1 | Fixed in 4.7 (PR #117725) | Upgrade to 4.7 |
| **`set_cell()` leaves physics collision stale** | All 4.x | By design; needs `notify_runtime_tile_data_update()` | Call after any batch of set_cell |
| **Ghost tile-seam collision** on flat TileMapLayer floors | 4.3–4.4 | Fixed by PR #102662 | Verify in your build; StaticBody2D merge as fallback |
| **Area2D phantom body_entered on scene load** when CharacterBody2D starts with disabled CollisionShape2D + set_deferred enable | 4.0–4.3.dev3 | Open as of mid-2026 | Initialize shapes enabled, or validate hit in handler |
| **Camera position_smoothing not reset between scene changes** | All 4.x | By design | Call `reset_smoothing()` in new room's `_ready()` |
| **CollisionShape2D enabled in editor slows scene load** for large counts | 4.5.1 | Open (issue #113867) | Disable shapes in editor, enable in `_ready()` — but test against phantom-body_entered pitfall above |
| **AnimationTree BlendSpace internal change** | 4.7 | Shipped | Retest any BlendSpace2D projects after upgrading |

---

*Sources: [Godot issue #99953](https://github.com/godotengine/godot/issues/99953) · [Issue #105645](https://github.com/godotengine/godot/issues/105645) · [Issue #89458](https://github.com/godotengine/godot/issues/89458) · [Issue #88592](https://github.com/godotengine/godot/issues/88592) · [Proposal #12093](https://github.com/godotengine/godot-proposals/issues/12093) · [PR #108010](https://github.com/godotengine/godot/pull/108010) · [Metroidvania System](https://github.com/KoBeWi/Metroidvania-System) · [GDQuest save formats](https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/) · [Godot 4.7 beta 1 notes](https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/) · [Forum shake thread #108424](https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424)*
