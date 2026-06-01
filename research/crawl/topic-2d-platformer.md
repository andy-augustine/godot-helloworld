# 2D Platformer Patterns — Godot 4.6 (new since Jan 2026)
**Crawl date:** 2026-06-01 | **Window:** post-January 2026

---

## TL;DR — Top 3 Findings

1. **Camera2D limit+smoothing is a live pitfall.** Combining `position_smoothing` with room-based limits produces one-frame overshoots and glitchy snapping on scene load. The established workaround — calling `reset_smoothing()` after repositioning the camera for a transition — is now widely confirmed as the correct pattern. A PR (#115397, Jan 2026) was submitted to improve Camera2D generally; check if it merged before 4.6.3.

2. **GLES3 2D batching had a silent rendering regression in 4.6.0 — fixed in 4.6.3.** The bug (GH-117725) caused GLES3 to skip rendering all items at specific buffer sizes. Any project running 4.6.0–4.6.2 with heavy TileMapLayer + sprite batching may have seen incorrect rendering. Upgrading to 4.6.3 (released May 19 2026) fixes it.

3. **Script-driven AnimationPlayer remains valid for small state counts, but AnimationTree is the community consensus for 5+ states.** The threshold where AnimationTree pays off is lower than many devs expect. Our current AnimationPlayer-only rig is fine for the existing state count but watch for the crossover point.

---

## Per-Pattern Entries

### 1. Camera2D — Room Locking and Screen Shake

**New approach / refinement (2026):**
- Room locking via `Camera2D.limit_*` (left/right/top/bottom) remains the canonical pattern. No new node was shipped for this in 4.6.
- Confirmed pitfall: enabling **both** `position_smoothing_enabled` and `limit_smoothed` causes the camera to be offset on scene start and one frame late when limits change. Community consensus: disable `limit_smoothed`; use `reset_smoothing()` to hard-snap camera position after a room transition completes.
- Screen shake: noise-based trauma pattern (`trauma` → squared to `shake_amount`) is still the standard. Offset-based shake (random offset each frame) is considered inferior because it can push the camera outside its limits unexpectedly.
- Camera2D `offset` is blocked by `limit_*` when limits are tight — screen shake at room edges will be clipped. Workaround: apply shake via a sub-viewport or a separate `RemoteTransform2D` rather than Camera2D offset directly.
- Phantom Camera v0.11.0.2 (released March 6 2025, last update per crawl Feb 28 2026 asset library) adds Lookahead 2D but has no built-in room-lock primitive; complex polygon limits are not supported. Still an add-on worth considering if we expand the camera system.

**Citations:**
- [Handling Camera in Metroidvania games — Godot Forum](https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882)
- [Camera2D limit smoothing issues — GitHub #56336](https://github.com/godotengine/godot/issues/56336)
- [Improve Camera2D PR #115397 — Jan 2026](https://github.com/godotengine/godot/pull/115397)
- [Phantom Camera asset library](https://godotengine.org/asset-library/asset/1822)

**Applicability: HIGH** — we use Camera2D with room limits and position smoothing. The `reset_smoothing()` discipline is directly applicable to our room transition code.

---

### 2. TileMapLayer — Collision and Physics Layers

**New approach / refinement (2026):**
- TileMapLayer (replacing TileMap, deprecated in 4.3) is now mature and the only supported workflow. One `TileMapLayer` node per visual/physics layer, sharing one `TileSet` resource.
- Physics layers are configured on the **TileSet resource**, not on the TileMapLayer node itself. Inspector shows collision layer/mask on TileSet → Physics Layers, not on the node. This trips up many developers upgrading from TileMap.
- Multiple physics layers on a single TileSet are valid and recommended: e.g., layer 1 = solid ground, layer 3 = one-way platforms.
- **Known active bug (not yet fixed as of 4.6.3):** `CharacterBody2D` with a **capsule or circle** collision shape incorrectly triggers `is_on_wall()` when hitting the top corner of one-way platform tiles (GH-102887). Affects 4.3–4.6.x. Workaround: use a rectangular collision shape (e.g. `RectangleShape2D`) for the player's primary collider when one-way platforms are in use.
- **4.6.3 fix:** TileMap layer selector not updating when modifying TileMap in inspector (GH-117256) — editor-only annoyance, now fixed.
- **4.6.3 fix:** GLES3 batching skipping rendering at specific buffer sizes (GH-117725) — affects any project using GLES3 renderer with heavy 2D batching.
- Dynamic tile collision (modifying tile physics at runtime via `set_cell()`) does not update the physics server until the next frame; you cannot rely on it being synchronous within the same `_physics_process` call.

**Citations:**
- [TileMapLayer docs](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)
- [Player getting stuck on TileMapLayer — Godot Forum #125521](https://forum.godotengine.org/t/player-getting-stuck-on-tilemaplayer-collision-shape/125521)
- [is_on_wall() capsule/one-way bug GH-102887](https://github.com/godotengine/godot/issues/102887)
- [4.6.3 release notes](https://godotengine.org/article/maintenance-release-godot-4-6-3/)

**Applicability: HIGH** — our rooms use TileMapLayer. If we add one-way platforms (pass-through floors), the capsule/circle collider bug will bite us. Use rectangular collider as primary shape.

---

### 3. Collision / Hitbox Layering — Area2D vs CharacterBody2D

**New approach / refinement (2026):**
- Consensus is stable: use **dedicated Area2D children** named `HitArea2D` (attack) and `HurtArea2D` (vulnerable) rather than relying on CharacterBody2D physics contacts for damage. This was confirmed in the updated GDQuest Godot 4 demo.
- Recommended layer naming convention: "Player", "Enemy", "PlayerHitbox", "EnemyHitbox" as separate named layers in project settings. `HurtArea2D` monitors for the opposing hitbox layer only.
- Disable `monitoring` on hitboxes when not active (e.g., melee swing not in progress) — Godot still checks for collisions on enabled shapes even if you don't act on the signal, so toggling `monitoring = false` is a real performance win in rooms with many enemies.
- For simple contact damage (enemy walks into player), CharacterBody2D ↔ CharacterBody2D body detection is acceptable; the Area2D pattern adds value when damage timing matters (weapon arcs, projectiles, parry windows).

**Citations:**
- [GDQuest hitbox/hurtbox library](https://www.gdquest.com/library/hitbox_hurtbox_godot4/)
- [Using Area2D — official docs](https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html)

**Applicability: MED** — we have a health system (HUD/health shipped). When we add melee combat the HitArea2D/HurtArea2D pattern is the approach to use.

---

### 4. Animation State Machines — AnimationTree vs Script-Driven

**New approach / refinement (2026):**
- Community threshold in 2026: **5 or more states → AnimationTree pays off**. Below that, a script-driven `match` over an enum with direct `AnimationPlayer.play()` calls is faster to build and easier to debug.
- Our current rig is script-driven (AnimationPlayer-only), consistent with the project's architecture conventions. This is appropriate for the current state count.
- AnimationTree with `AnimationNodeStateMachine` is the recommended upgrade path when we need cross-fade blends (e.g., walk→run), blend spaces (velocity-driven direction), or attack-into-jump chaining. Its visual graph replaces nested `if` chains.
- Key pitfall: **AnimationTree state machine does not run consistently when transitions are spammed** (GH-69382, open since 4.x) — rapid state changes can skip states. Workaround: gate transitions with a minimum duration check or use `travel()` with `advance_mode` set to manual.
- AnimationPlayer `animation_finished` signal is still the right tool for one-shot actions (attack, hurt, death) even when AnimationTree manages locomotion.

**Citations:**
- [AnimationTree State Machines complete guide — godot-mcp.abyo.net](https://godot-mcp.abyo.net/guides/godot4-animationtree)
- [AnimationNodeStateMachine spam bug GH-69382](https://github.com/godotengine/godot/issues/69382)
- [AnimationNodeStateMachinePlayback docs](https://docs.godotengine.org/en/stable/classes/class_animationnodestatemachineplayback.html)

**Applicability: MED** — current script-driven rig is fine. Plan an AnimationTree migration when state count reaches 6+.

---

### 5. Room Transitions (Door / Scene Load)

**New approach / refinement (2026):**
- Standard pattern: Area2D door trigger → `get_tree().change_scene_to_file()` with a fade-in/out ColorRect overlay using a `Tween`. Still the simplest correct approach.
- **MetSys (KoBeWi/Metroidvania-System)** is the most complete open-source framework for Metroidvania room/map management in Godot 4.6+. It handles scene association, `room_changed` signal, player teleport to correct entry point, and map tracking. Worth studying for our own transition implementation even if we don't use it directly.
- Zelda-style scrolling transitions (camera pans to new room before load) require disabling Camera2D smoothing during the pan and calling `reset_smoothing()` at the destination; otherwise the camera slides back through the door seam.
- **4.6 Unique Node IDs** (shipped 4.6.0): nodes now carry stable internal IDs across scene refactoring; connections are preserved when nodes are renamed/moved. Directly reduces the fragility of signal connections in door/room scenes during iteration.

**Citations:**
- [KoBeWi/Metroidvania-System GitHub](https://github.com/KoBeWi/Metroidvania-System)
- [Dungeon Room Transitions Godot 4 — YouTube tutorial](https://www.youtube.com/watch?v=LGNyzw_2_24)
- [Unique Node IDs PR #106837](https://github.com/godotengine/godot/pull/106837)

**Applicability: HIGH** — we have door transitions in flight. The `reset_smoothing()` step after scene load is easy to miss and will cause camera seam artifacts.

---

### 6. Save / Load

**New approach / refinement (2026):**
- Two approaches are both valid and documented in official 4.6 docs: (a) **group + method** pattern (`save_game_node` group, each node implements `save()`/`load()`) and (b) **custom Resource** pattern (`@export` variables, `ResourceSaver.save("user://save.tres")`).
- Resource approach is preferred for structured Metroidvania data (room unlocks, collected items, abilities) because sub-resources serialize automatically and files can be inspected in the editor during development. Use `.tres` (text) in dev, `.res` (binary) for ship.
- **Active bug in 4.6:** `ResourceSaver` fails silently on some platforms when saving resources with nested custom resources if the sub-resource path is not explicitly set. Check the return value of `ResourceSaver.save()` — it returns an error code. Do not assume success.
- `user://` is the only writable path in exported builds; `res://` is read-only post-export. Always use `user://` for save files.

**Citations:**
- [ResourceSaver issues in 4.6 — Godot Forum #136658](https://forum.godotengine.org/t/issues-with-saving-resources-using-resourcesaver-in-4-6/136658)
- [Saving games official docs 4.6](https://docs.godotengine.org/en/4.6/tutorials/io/saving_games.html)
- [GDQuest save game with resources](https://www.gdquest.com/library/save_game_godot4/)

**Applicability: MED** — save/load is not yet built. When we do build it, use the Resource pattern; always check `ResourceSaver.save()` return value.

---

## Pitfalls We May Already Be Hitting

| Pitfall | Status | Risk to Us |
|---|---|---|
| Camera2D `position_smoothing` + `limit_smoothed` = glitchy room entry | Known, unfixed in 4.6.x | **HIGH** — if our GameCamera uses both flags, room transitions may jitter on scene load |
| GLES3 batching rendering regression (GH-117725) | Fixed in 4.6.3 | **MED** — if running 4.6.0–4.6.2 and using GLES3, upgrade to 4.6.3 |
| `is_on_wall()` false positive on capsule/circle colliders + one-way platforms (GH-102887) | Open bug, 4.3–4.6.x | **LOW now / HIGH later** — no one-way platforms yet; will be critical when added |
| GDScript lambda closure captures snapshot of variable, not live reference (GH-117348) | Open in 4.6.x | **MED** — any lambda-based callbacks (e.g., tween `finished` closures in transitions) that expect to read a mutated outer variable will silently use stale data |
| `ResourceSaver` silent failure on nested resources | Active forum report | **LOW now** — no save system yet; note for when we build it |

---

## Godot 4.7 Watch (Beta — not stable until ~late June 2026)

- **One-way collision direction control for CollisionShape2D** — long-requested; landed in 4.7 dev 1. Will fix TileMapLayer one-way platform authoring. Do not adopt until 4.7 stable.
- **2D physics improvements** (unspecified in beta notes) — monitor 4.7 stable release notes for CharacterBody2D/TileMapLayer fixes.
- **Animation track group collapsing** — editor QoL for AnimationPlayer; no runtime behavior change.
