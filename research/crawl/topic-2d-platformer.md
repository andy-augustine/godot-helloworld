# Topic D — 2D Platformer Patterns (Godot 4.6)

**Generated:** 2026-04-26  
**Baseline:** Godot 4.6.2  
**Window:** Q4 2025 – April 2026

---

## TL;DR — Top 3 Findings

1. **ResourceSaver + subresources regressed in 4.6.** Code that worked in 4.5 breaks silently or writes nulls when saving nested custom Resources. Workaround: call `.duplicate(true)` on each sub-resource before save, or switch save data to JSON/ConfigFile.

2. **AnimationTree `travel()` is now the community consensus for complex characters**, but script-driven AnimationPlayer with a guard check on `current_animation` remains valid and low-overhead for simpler rigs. No deprecation; both approaches are supported. Our AnimationPlayer rig is fine — the pressure to migrate is performance-and-polish-only, not correctness.

3. **TileMapLayer corner-edge stuck-player bug is still open.** The safe_margin mismatch at tile junctions causes CharacterBody2D to catch on seams; reducing `safe_margin` to 0 (or matching it to tile-size) and using rectangular colliders per tile is the accepted workaround as of 4.6.2.

---

## Per-Pattern Entries

### 1. Camera2D — Screen Shake

**New approach/refinement (2026):**  
Community-converged on an additive-strength pattern: a single async coroutine owns all shake motion; repeated calls to `add_shake(strength)` increment `current_strength` instead of spawning competing coroutines. Smooth decay via `lerp()` each frame. Guard: only the first call enters the loop.

**Why it matters vs. plain offset-reset:** overlapping heavy-landing shakes (e.g. wall-jump + land in quick succession) stack correctly rather than resetting each other.

**Citation:** forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424  
**Applicability: MED.** Our `GameCamera.add_shake()` already uses a decay pattern. Check whether successive rapid shakes additive-stack or reset — if they reset, apply the guard coroutine pattern.

---

### 2. Camera2D — Room Locking & Limits

**New approach/refinement (2026):**  
Setting `camera.limit_*` per-room via a `Rect2i` remains the canonical pattern. A newer forum thread (forum.godotengine.org/t/how-could-complex-2d-camera-boundaries-be-made/137746, 2026) confirms that Camera2D does not natively support non-rectangular limits; Phantom Camera (last updated 2026-02-28) also only supports rectangles. State-machine camera is emerging for polished metroidvanias: distinct states (follow, freeze, move-to-room, peek) switched on room transition.

**Citation:** forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882; forum.godotengine.org/t/how-could-complex-2d-camera-boundaries-be-made/137746  
**Applicability: MED.** Our architecture (Rect2 bounds on Room + set limits in `World._start_transition`) matches the recommended pattern exactly. If room shapes become non-rectangular, the limit API won't cover it — flag for later.

---

### 3. Camera2D — Limit Snap on Room Transition

**New approach/refinement (2026):**  
The long-standing pitfall of the camera snapping to the raw player position when limits are cleared remains. The working fix — pin camera at `get_screen_center_position()` before disabling follow, then tween camera to target — is confirmed best practice by multiple forum threads. No engine-level fix shipped in 4.6.x.

**Citation:** forum.godotengine.org/t/how-to-update-smoothed-camera2ds-position-immediately (archived); godotengine/godot issue #63330  
**Applicability: HIGH.** We already implement this exact workaround (step 5 in STRUCTURE.md transition choreography). No action needed; just good to confirm it's still the right call.

---

### 4. TileMapLayer — Collision Setup

**New approach/refinement (2026):**  
TileMapLayer collision properties live on the TileSet resource's physics layers, not on the TileMapLayer node inspector. Common beginner trap: adding a physics layer to TileSet but forgetting to paint collision polygons on individual tiles. The node's collision layer/mask is set via the TileSet physics layer, not directly on TileMapLayer.

**New in 4.6:** scene tiles can now be rotated directly in TileMapLayer (previously atlas-only). Minor but useful for room dressing.

**Citation:** gdquest.com/library/cheatsheet_tileset_setup/; godotengine.org docs; forum.godotengine.org/t/tile-map-layer-collision-setup/106693  
**Applicability: LOW** (now). Our rooms use hand-placed StaticBody2D, not TileMapLayer. When we add tile art, this becomes HIGH — paint collisions per tile, confirm physics layer numbers match character mask.

---

### 5. TileMapLayer — Corner/Edge Stuck Bug

**New approach/refinement (2026):**  
CharacterBody2D catching on tile seams at corners remains an active issue in 4.6.2 (no fix merged). Root cause: safe_margin buffer interacts badly with adjacent tile collision boundaries. Accepted workarounds:

- Set `CharacterBody2D.safe_margin` to 0 (eliminates the buffer; test slope behavior afterwards).
- Use rectangular collision per tile (not polygon); rectangles share edges cleanly.
- Alternatively, place hand-built StaticBody2D platforms with single continuous shapes (avoids tile seam entirely).

**Citation:** forum.godotengine.org/t/player-getting-stuck-on-tilemaplayer-collision-shape/125521; bugnet.io/blog/fix-godot-tilemaplayer-collision-not-working  
**Applicability: MED** (future tile art phase). Note it early so we don't debug this from scratch.

---

### 6. Collision/Hitbox Layering — Area2D Hitbox/Hurtbox

**New approach/refinement (2026):**  
GDQuest's canonical guide (updated for 4.6) specifies:

- **Hitbox (attacker):** Layer 2 "hitboxes", Mask 0, Monitoring OFF (can't detect anything itself). Damage logic lives here only as data.
- **Hurtbox (receiver):** Layer 0, Mask 2, fires `area_entered` → damage applied on receiver.
- Damage-handling logic stays on the receiver, not the attacker. Enables varied enemies without coupling.
- Turn off `monitorable` on hitboxes that are inactive (e.g. sheathed weapon) to cut physics overhead.

**Citation:** gdquest.com/library/hitbox_hurtbox_godot4/  
**Applicability: HIGH** (when we add enemies/combat). Worth committing the layer numbering now in project settings before combat work begins.

---

### 7. Animation — Script-Driven AnimationPlayer (our current approach)

**New approach/refinement (2026):**  
Community consensus: script-driven AnimationPlayer with a guard check (`if anim.current_animation != target: anim.play(target)`) remains correct and low-overhead for character rigs with clear discrete states. No deprecation signaled.

The pressure to migrate to AnimationTree is real for rigs needing blend spaces (walk→run speed-based) or crossfade blending between states. For our Metroid-style discrete states (idle/run/jump/fall/wall-slide), AnimationPlayer is not a liability.

**AnimationTree note:** If we add a combo attack or blended run cycle, the pattern is: code state machine drives a `StateMachinePlayback.travel("state_name")` call; AnimationTree owns blending.

**Citation:** forum.godotengine.org/t/player-animation-best-practice/63616; godot-mcp.abyo.net/guides/godot4-animationtree  
**Applicability: LOW** (now), **HIGH** (if blend spaces or crossfades added). No migration needed for current rig.

---

### 8. Room Transitions — Scene-Per-Room

**New approach/refinement (2026):**  
Scene-per-room with door Area2D nodes remains the recommended pattern for metroidvanias. Alternatives discussed (all rooms loaded, additive loading) are dismissed for memory reasons unless rooms are small. The KoBeWi/Metroidvania-System plugin (Godot 4.x, updated 2026) adds object-ID persistence for collectibles and save state — worth tracking if we need persistent room state (breakable walls, collected items).

**Citation:** forum.godotengine.org/t/room-system-for-metroidvanias/112752; github.com/KoBeWi/Metroidvania-System  
**Applicability: LOW** (our pattern matches). Plugin worth evaluating when persistent room state becomes a requirement.

---

### 9. Save/Load — Resource vs JSON vs FileAccess

**New approach/refinement (2026):**  
GDQuest updated guide (2026) confirms:

- **Resources** — preferred when save data maps cleanly to existing Resource classes. Godot 4 fixed array-of-resources (no longer needs workarounds from 4.0 era).
- **FileAccess.store_var/get_var** — binary, no code-execution risk, best for untrusted-source concern.
- **JSON** — only for external integrations; poor fit for native Godot types.

**Known 4.6 regression:** `ResourceSaver.save()` with nested subresources can silently write nulls or fail to update files. Triggered by upgrading from 4.5; root cause unclear. Workaround: call `.duplicate(true)` on each sub-resource before saving. Also: save to `user://`, not `res://`, in exported builds.

**Citation:** forum.godotengine.org/t/issues-with-saving-resources-using-resourcesaver-in-4-6/136658; gdquest.com/library/save_game_godot4/; gdquest.com/library/cheatsheet_save_systems/  
**Applicability: HIGH** (when we implement save/load). Use Resources; call `.duplicate(true)` defensively on any sub-resource before `ResourceSaver.save()`; write to `user://`.

---

## Pitfalls Reported in 2026 We Might Already Be Hitting

| Pitfall | Trigger | Status | Risk to Us |
|---|---|---|---|
| Camera snaps to player when limits cleared | Changing `limit_*` while `position_smoothing_enabled` is true | No engine fix; workaround: pin via `get_screen_center_position()` before clearing | Already mitigated in our transition code |
| TileMapLayer corner seams catch CharacterBody2D | Adjacent tile collision edges at corners/walls | Open bug, no 4.6.2 fix | LOW now (no TileMapLayer in rooms yet) |
| ResourceSaver drops sub-resource nulls on upgrade from 4.5 | Nested Resource objects in arrays/dicts | Open regression in 4.6; workaround: `.duplicate(true)` | LOW now (no save system yet); HIGH when we add one |
| AnimationPlayer `queue()` silently skips if looped anim is current | Calling `.queue()` on a looping animation | Long-standing; use `.play()` with guard check instead | MED — check `_update_animation` guard logic |
| TileSet physics layer ≠ CharacterBody2D mask | Mismatch between TileSet physics layer number and char mask | Configuration error, not engine bug | LOW now; HIGH at tile art phase |

---

## Sources

- [Additive 2D Camera Shake — Godot Forum](https://forum.godotengine.org/t/additive-2d-camera-shake-for-overlapping-shakes-in-rapid-succession/108424)
- [Handling Camera in Metroidvania Games — Godot Forum](https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882)
- [Complex Camera Boundaries — Godot Forum](https://forum.godotengine.org/t/how-could-complex-2d-camera-boundaries-be-made/137746)
- [Player Stuck on TileMapLayer — Godot Forum](https://forum.godotengine.org/t/player-getting-stuck-on-tilemaplayer-collision-shape/125521)
- [ResourceSaver Issues in 4.6 — Godot Forum](https://forum.godotengine.org/t/issues-with-saving-resources-using-resourcesaver-in-4-6/136658)
- [ResourceSaver null sub-resources — godotengine/godot #89961](https://github.com/godotengine/godot/issues/89961)
- [Hitbox/Hurtbox Godot 4 — GDQuest Library](https://www.gdquest.com/library/hitbox_hurtbox_godot4/)
- [Save Game with Resources — GDQuest Library](https://www.gdquest.com/library/save_game_godot4/)
- [Godot 4.6 Workflow Changes — GDQuest Library](https://www.gdquest.com/library/godot_4_6_workflow_changes/)
- [AnimationTree State Machines — godot-mcp-pro guide](https://godot-mcp.abyo.net/guides/godot4-animationtree)
- [Player Animation Best Practice — Godot Forum](https://forum.godotengine.org/t/player-animation-best-practice/63616)
- [Room System for Metroidvanias — Godot Forum](https://forum.godotengine.org/t/room-system-for-metroidvanias/112752)
- [Metroidvania System plugin — KoBeWi/Metroidvania-System](https://github.com/KoBeWi/Metroidvania-System)
- [Phantom Camera addon — ramokz/phantom-camera](https://github.com/ramokz/phantom-camera)
- [TileMapLayer Collision Setup — Godot Forum](https://forum.godotengine.org/t/tile-map-layer-collision-setup/106693)
- [TileSet Setup Cheat Sheet — GDQuest Library](https://www.gdquest.com/library/cheatsheet_tileset_setup/)
