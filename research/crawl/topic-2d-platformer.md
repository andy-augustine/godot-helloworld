# Topic D — 2D Platformer Patterns (Godot 4.6)

**Generated:** 2026-04-26 | **Updated:** 2026-05-01  
**Baseline:** Godot 4.6.2 (current recommended stable)  
**Window:** January 2026 – May 2026

---

## TL;DR — Top 3 Findings

1. **Godot 4.7 (beta, not yet stable) adds configurable one-way collision direction for CollisionShape2D.** PR #104736 merged 2026-02-10, targeting 4.7. Previously hard-coded to "up" — now a `one_way_collision_direction` Vector2 property. Not actionable today (4.7 is beta), but will affect how we handle pass-through platforms once 4.7 ships.

2. **ResourceSaver + nested subresources is still broken in 4.6.x.** Code that worked in 4.5 silently writes nulls when saving nested custom Resources. Workaround: call `.duplicate(true)` on each sub-resource before `ResourceSaver.save()`. Not hitting us yet (no save system), but HIGH risk when we add one.

3. **TileMapLayer corner/edge stuck-player bug is still open in 4.6.2.** The safe_margin mismatch at tile junctions causes CharacterBody2D to catch on seams; reducing `safe_margin` to 0 and using rectangular colliders per tile is the accepted workaround. No fix merged.

---

## Per-Pattern Entries

### 1. Camera2D — Screen Shake

**New approach/refinement (2026):**  
Community-converged on an additive-strength pattern: a single async coroutine owns all shake motion; repeated calls to `add_shake(strength)` increment `current_strength` instead of spawning competing coroutines. Smooth decay via `lerp()` each frame. Guard: only the first call enters the loop. "Trauma" variable pattern (strength squared or cubed) produces natural-feeling shake falloff.

**Why it matters vs. plain offset-reset:** overlapping heavy-landing shakes (e.g. wall-jump + land in quick succession) stack correctly rather than resetting each other.

**Citation:** https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424 (archived); https://gist.github.com/Alkaliii/3d6d920ec3302c0ce26b5ab89b417a4a  
**Applicability: MED.** Our `GameCamera.add_shake()` already uses a decay pattern. Verify successive rapid shakes additive-stack rather than reset — apply the guard coroutine if they reset.

---

### 2. Camera2D — Room Locking & Limits

**New approach/refinement (2026):**  
Setting `camera.limit_*` per-room via a `Rect2i` remains the canonical pattern. Camera2D does not natively support non-rectangular limits; Phantom Camera (updated 2026-02-28) also only supports rectangles. State-machine camera is emerging as best practice for polished metroidvanias: distinct states (follow, freeze, move-to-room, peek) switched on room transition, rather than a monolithic follow script.

**Citation:** https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882 (Jan 2026); https://forum.godotengine.org/t/how-could-complex-2d-camera-boundaries-be-made/137746 (Apr 2026)  
**Applicability: MED.** Our architecture (Rect2 bounds per Room + set limits in `World._start_transition`) matches the recommended pattern. Flag: if rooms become non-rectangular, the `limit_*` API won't cover it.

---

### 3. Camera2D — Limit Snap on Room Transition

**New approach/refinement (2026):**  
The long-standing pitfall: camera snaps to raw player position when `limit_*` are cleared while `position_smoothing_enabled = true`. Working fix — pin camera at `get_screen_center_position()` before disabling follow, then tween camera to target — is confirmed best practice. No engine-level fix in 4.6.x.

**Citation:** https://github.com/godotengine/godot/issues/63330; forum.godotengine.org/t/how-to-update-smoothed-camera2ds-position-immediately  
**Applicability: HIGH.** We already implement this workaround (step 5 in STRUCTURE.md transition choreography). No action needed; just confirming it's still correct.

---

### 4. TileMapLayer — Collision Setup

**New approach/refinement (2026):**  
TileMapLayer collision properties live on the TileSet resource's physics layers, not on the TileMapLayer node inspector. Common beginner trap: adding a physics layer to TileSet but forgetting to paint collision polygons on individual tiles.

**New in 4.6 — scene tiles can now be rotated:** PR #108010 (merged into 4.6). Previously, scene tiles (e.g. animated pickups, torches, chests placed via TileMapLayer) could not be rotated — only atlas tiles could. Now they rotate in 90° increments. Minor but useful for room dressing.

**Citation:** https://github.com/godotengine/godot/pull/108010 (2025, shipped in 4.6); https://www.gdquest.com/library/cheatsheet_tileset_setup/; https://forum.godotengine.org/t/tile-map-layer-collision-setup/106693  
**Applicability: LOW** (now). Our rooms use hand-placed StaticBody2D, not TileMapLayer. When we add tile art, this becomes HIGH — paint collisions per tile, confirm physics layer numbers match character mask.

---

### 5. TileMapLayer — Corner/Edge Stuck Bug

**New approach/refinement (2026):**  
CharacterBody2D catching on tile seams at corners remains an active issue in 4.6.2 (no fix merged). Root cause: safe_margin buffer interacts badly with adjacent tile collision boundaries. Accepted workarounds:

- Set `CharacterBody2D.safe_margin` to 0 (eliminates buffer; test slope behavior afterwards).
- Use rectangular collision per tile (not polygon); rectangles share edges cleanly.
- Alternatively, use hand-built StaticBody2D platforms with single continuous shapes (avoids tile seam entirely — this is our current approach).

**Citation:** https://forum.godotengine.org/t/player-getting-stuck-on-tilemaplayer-collision-shape/125521; https://bugnet.io/blog/fix-godot-tilemaplayer-collision-not-working  
**Applicability: MED** (future tile art phase). Note it early so we don't debug this from scratch.

---

### 6. Collision/Hitbox Layering — Area2D Hitbox/Hurtbox

**New approach/refinement (2026):**  
GDQuest canonical guide (updated for 4.6) specifies:

- **Hitbox (attacker):** Layer 2 "hitboxes", Mask 0, Monitoring OFF. Damage logic lives here only as data.
- **Hurtbox (receiver):** Layer 0, Mask 2, fires `area_entered` → damage applied on receiver.
- Damage-handling logic stays on the receiver, not the attacker. Enables varied enemies without coupling.
- Turn off `monitorable` on hitboxes that are inactive (e.g. sheathed weapon) to cut physics overhead.
- Signal pattern: Hurtbox emits `damaged(amount, knockback_dir)`, receiver decides HP deduction and invincibility frames.

**Citation:** https://www.gdquest.com/library/hitbox_hurtbox_godot4/; https://forum.godotengine.org/t/how-to-use-reusable-hitbox-class/58515  
**Applicability: HIGH** (when we add enemies/combat). Commit the layer numbering in project settings before combat work begins — changing layer assignments mid-project is painful.

---

### 7. 2D Physics — One-Way Collision Direction (Coming in 4.7)

**New feature (4.7, beta only as of 2026-05-01):**  
PR #104736 (merged 2026-02-10, milestone: 4.7) adds `one_way_collision_direction` as a `Vector2` property on `CollisionShape2D`. Previously, one-way collision was hard-coded to "up" — this blocked rotating platforms and side-pass-through walls. The new property works as a normalized vector (similar to `up_direction` on `CharacterBody2D`). Backward-compatible via deprecation bindings.

**Practical impact for platformers:** Pass-through platforms that can be oriented left/right/down (think: grate floors, side-entry tunnels) become natively possible without physics hacks.

**Citation:** https://github.com/godotengine/godot-proposals/issues/12093 (proposal); https://github.com/godotengine/godot/pull/104736 (merged 2026-02-10); https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627  
**Applicability: MED** (future, 4.7 only). Track for when 4.7 stable ships (targeted Q2–Q3 2026). Relevant to pass-through floor tiles and any non-upward one-way surfaces.

---

### 8. Animation — Script-Driven AnimationPlayer (our current approach)

**New approach/refinement (2026):**  
Community consensus: script-driven AnimationPlayer with a guard check (`if anim.current_animation != target: anim.play(target)`) remains correct and low-overhead for character rigs with clear discrete states. No deprecation signaled.

**Pitfall confirmed in 4.6:** `AnimationPlayer.queue()` silently skips if a looping animation is currently playing (long-standing). Use `.play()` with the guard check instead of `.queue()` for looping animations.

**New 4.6 regression:** `AnimationPlayer.clear_queue()` called during the `animation_started` signal callback causes a crash in 4.6.0 and 4.6.1 (issue #116994). Workaround: defer the `clear_queue()` call. Status in 4.6.2: not confirmed fixed — avoid `clear_queue()` in signal handlers.

**AnimationTree note (when to migrate):** If we add a combo attack or blended run cycle, the pattern is: code state machine drives `StateMachinePlayback.travel("state_name")`; AnimationTree owns blending. For our current discrete states (idle/run/jump/fall/wall-slide), AnimationPlayer is not a liability.

**Citation:** https://forum.godotengine.org/t/player-animation-best-practice/63616; https://github.com/godotengine/godot/issues/116994 (clear_queue crash); https://github.com/godotengine/godot/issues/93657 (queue doesn't emit finished signal)  
**Applicability: MED.** Avoid `clear_queue()` in signal handlers. Guard `is playing` checks on looped animations.

---

### 9. Room Transitions — Scene-Per-Room

**New approach/refinement (2026):**  
Scene-per-room with door Area2D nodes remains the recommended pattern for metroidvanias. The KoBeWi/Metroidvania-System plugin now explicitly targets "Godot 4.6 or newer" (stable 1.6 branch for older versions). Key features for future consideration: object-ID persistence for collectibles, automated save data as Dictionary (discovered rooms, stored object IDs), and room-scroll transitions (Zelda-style).

**Citation:** https://forum.godotengine.org/t/room-system-for-metroidvanias/112752; https://github.com/KoBeWi/Metroidvania-System  
**Applicability: LOW** (our pattern matches). MetSys plugin worth evaluating when persistent room state (breakable walls, collected items) becomes a requirement.

---

### 10. Save/Load — Resource vs JSON vs FileAccess

**New approach/refinement (2026):**  
- **Resources** — preferred when save data maps cleanly to existing Resource classes.
- **FileAccess.store_var/get_var** — binary, no code-execution risk, best for untrusted-source concern.
- **JSON** — only for external integrations; poor fit for native Godot types (Vector2, Color, etc.).

**Known 4.6 regression (still open):** `ResourceSaver.save()` with nested subresources silently writes nulls or fails to update. Root cause: sub-resources referring to each other cause the serializer to write null references. Workaround: call `.duplicate(true)` on each sub-resource before saving. Also: always save to `user://`, never `res://`, in exported builds.

**Citation:** https://forum.godotengine.org/t/issues-with-saving-resources-using-resourcesaver-in-4-6/136658; https://github.com/godotengine/godot/issues/89961; https://www.gdquest.com/library/save_game_godot4/  
**Applicability: HIGH** (when we implement save/load). Use Resources; call `.duplicate(true)` defensively on any sub-resource before `ResourceSaver.save()`; write to `user://`.

---

## Pitfalls Reported in 2026 We Might Already Be Hitting

| Pitfall | Trigger | Status | Risk to Us |
|---|---|---|---|
| Camera snaps to player when limits cleared | Changing `limit_*` while `position_smoothing_enabled = true` | No engine fix; workaround: pin via `get_screen_center_position()` before clearing | Already mitigated in our transition code |
| `AnimationPlayer.clear_queue()` crash | Called during `animation_started` signal callback | Open regression (4.6.0, 4.6.1); workaround: defer call | LOW unless we use clear_queue in signal handlers — audit |
| `AnimationPlayer.queue()` silently skips | Calling `.queue()` while a looping anim is current | Long-standing; use `.play()` with guard check | MED — check `_update_animation` guard logic in player script |
| TileMapLayer corner seams catch CharacterBody2D | Adjacent tile collision edges at corners/walls | Open bug, no 4.6.2 fix | LOW now (no TileMapLayer rooms yet) |
| ResourceSaver drops sub-resource nulls | Nested Resource objects in arrays/dicts | Open regression in 4.6; workaround: `.duplicate(true)` | LOW now (no save system yet); HIGH when we add one |
| `is_on_floor()` returns false inside TileMapLayer | Character spawned inside tile collision geometry | Open; workaround: spawn above geometry | LOW now; relevant when we add TileMapLayer rooms |
| `is_action_just_pressed_by_event` / `is_action_just_released_by_event` return false for mouse clicks | Mouse button events cause internal ID mismatch on conversion | Open regression in 4.6.2 (issue #118521, filed 2026-04-13) | LOW (keyboard-driven game); HIGH if we add mouse click input |
| TileSet physics layer ≠ CharacterBody2D mask | Mismatch between TileSet physics layer number and character mask | Configuration error, not engine bug | LOW now; HIGH at tile art phase |

---

## Sources

- [Additive 2D Camera Shake — Godot Forum](https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424)
- [Camera Shake Gist (GDScript 4) — GitHub](https://gist.github.com/Alkaliii/3d6d920ec3302c0ce26b5ab89b417a4a)
- [Handling Camera in Metroidvania Games — Godot Forum](https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882)
- [Complex Camera Boundaries — Godot Forum](https://forum.godotengine.org/t/how-could-complex-2d-camera-boundaries-be-made/137746)
- [Camera Limit Snap Issue — godotengine/godot #63330](https://github.com/godotengine/godot/issues/63330)
- [Scene Tile Rotation PR — godotengine/godot #108010](https://github.com/godotengine/godot/pull/108010)
- [Player Stuck on TileMapLayer — Godot Forum](https://forum.godotengine.org/t/player-getting-stuck-on-tilemaplayer-collision-shape/125521)
- [Fix TileMapLayer Collision Not Working — Bugnet Blog](https://bugnet.io/blog/fix-godot-tilemaplayer-collision-not-working)
- [One-Way Collision Direction Proposal — godot-proposals #12093](https://github.com/godotengine/godot-proposals/issues/12093)
- [One-Way Collision Direction PR — godotengine/godot #104736](https://github.com/godotengine/godot/pull/104736) (merged 2026-02-10, milestone: 4.7)
- [Godot 4.7 Beta 1 Forum Thread](https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627)
- [Hitbox/Hurtbox Godot 4 — GDQuest Library](https://www.gdquest.com/library/hitbox_hurtbox_godot4/)
- [Reusable Hitbox Class — Godot Forum](https://forum.godotengine.org/t/how-to-use-reusable-hitbox-class/58515)
- [AnimationPlayer queue() doesn't emit finished — godotengine/godot #93657](https://github.com/godotengine/godot/issues/93657)
- [AnimationPlayer clear_queue() crash in 4.6 — godotengine/godot #116994](https://github.com/godotengine/godot/issues/116994)
- [Player Animation Best Practice — Godot Forum](https://forum.godotengine.org/t/player-animation-best-practice/63616)
- [AnimationTree State Machines — godot-mcp-pro guide](https://godot-mcp.abyo.net/guides/godot4-animationtree)
- [Room System for Metroidvanias — Godot Forum](https://forum.godotengine.org/t/room-system-for-metroidvanias/112752)
- [Metroidvania System plugin — KoBeWi/Metroidvania-System](https://github.com/KoBeWi/Metroidvania-System)
- [ResourceSaver Issues in 4.6 — Godot Forum](https://forum.godotengine.org/t/issues-with-saving-resources-using-resourcesaver-in-4-6/136658)
- [ResourceSaver null sub-resources — godotengine/godot #89961](https://github.com/godotengine/godot/issues/89961)
- [Save Game with Resources — GDQuest Library](https://www.gdquest.com/library/save_game_godot4/)
- [Godot 4.6 Workflow Changes — GDQuest Library](https://www.gdquest.com/library/godot_4_6_workflow_changes/)
- [TileSet Setup Cheat Sheet — GDQuest Library](https://www.gdquest.com/library/cheatsheet_tileset_setup/)
- [is_on_floor() erratic in TileMap — godotengine/godot #88067](https://github.com/godotengine/godot/issues/88067)
- [is_action_just_pressed_by_event mouse regression — godotengine/godot #118521](https://github.com/godotengine/godot/issues/118521) (filed 2026-04-13, open as of 2026-05-01)
- [Phantom Camera addon — ramokz/phantom-camera](https://github.com/ramokz/phantom-camera)
- [TileMapLayer Collision Setup — Godot Forum](https://forum.godotengine.org/t/tile-map-layer-collision-setup/106693)
