# Camera / Room System — Plan

**Status:** approved, not started. Next session should start from this file.

## Decisions locked in

1. **Doors**: both horizontal and vertical (Metroid convention — east/west and north/south transitions)
2. **Transition feel**: Hollow Knight ~0.5s pan glide with ease-in-out (not Super Metroid snap)
3. **Second demo room**: clone of first room to prove plumbing — visual distinctness is a later phase

## Architecture

- Camera lives in its own scene, finds the player via group tag `"player"` — not parent/child. This lets the camera transition between rooms without reparenting the player.
- Rooms are scenes with: `bounds: Rect2`, `spawn_points: Dictionary` (name → Vector2), `doors: Array[Door]`.
- World scene holds: current room (hot-swapped on transition), camera, player.
- Camera has two modes:
  - `locked` — clamped to current room's bounds, soft-follows player
  - `transitioning` — tweens from old room's camera frame to new room's frame over 0.5s

## Phase 1 — Room template + first room

- Create `rooms/Room.gd` base class with:
  - `@export var bounds: Rect2`
  - `@export var spawn_points: Dictionary` (populated in editor or from child nodes)
  - `doors: Array[Door]` (auto-collected from Area2D children in `_ready`)
- Create `rooms/StartingRoom.tscn` built on the template. Move everything currently under `main.tscn`'s `Level` node into it.
- Make the entry scene a new `World.tscn` that holds: current room slot + GameCamera + Player.
- Debug-draw the room bounds in-editor (visible in editor, invisible at runtime — use `_draw()` gated on `Engine.is_editor_hint()`).
- Add `"player"` group tag to the player scene.

## Phase 2 — Camera scene

- Create `camera/GameCamera.tscn` (Camera2D + `GameCamera.gd`).
- On `_ready`: find player via `get_tree().get_first_node_in_group("player")`.
- Soft-follow using Camera2D's built-in `position_smoothing_enabled` + `position_smoothing_speed`.
- Clamped to current room's bounds via `enter_room(room: Room)` — this sets `limit_left/top/right/bottom` from `room.bounds`.
- Slight Y offset (~-40) so more screen is above the player (fixes the wasted-space-below issue).
- If no room has been entered yet, acts as a plain follow cam (fallback so nothing breaks during setup).

## Phase 3 — Door triggers + transitions

- `doors/Door.tscn` — Area2D with:
  - `@export var target_room: PackedScene`
  - `@export var target_door_name: String` (node name of the matching door on the target room)
  - `@export var direction: Vector2` — horizontal: `(1,0)`/`(−1,0)`, vertical: `(0,1)`/`(0,−1)`
  - A CollisionShape2D sized as the trigger region (e.g. the doorway)
  - A child `Spawn` Marker2D for where the player re-appears when arriving through this door
- On `body_entered` (player):
  1. Freeze player input (simplest: set `set_physics_process(false)` on the player, or route via a World-held input lock)
  2. World asks the target room's packed scene to instantiate
  3. Find matching door on the new room by name; compute destination camera frame and player spawn position
  4. Tween the camera from current frame → new frame over 0.5s with ease-in-out
  5. Simultaneously tween player position from current door to destination spawn (so the player "walks through")
  6. After tween: free the old room, hand control back to player
- Horizontal and vertical doors use the same code path; `direction` handles orientation.

## Phase 4 — Polish

- Deadzone around player so micro-steps don't jitter the camera.
- Horizontal lookahead: offset camera ~20px in the direction the player is moving (blends into Y offset).
- Vertical lookahead when falling: extra downward offset briefly, so the player can see landing.
- Screen-shake helper on the camera (unused initially — just plumbed for later: landing impact, damage, etc.).
- Optional: subtle vignette dip or flash during room transition — tune for feel.

## Phase 5 — Playtest & tune

- Walk through each door direction (N/S/E/W). Report what's off:
  - Transition too slow / too fast
  - Camera snap / overshoot at room boundaries
  - Lookahead feels wrong
  - Deadzone too big or too small
- Tune the constants, not the architecture.

## Explicitly NOT in scope this round

- TileMapLayer conversion (hand-placed StaticBody2D platforms stay; tile art is its own later phase)
- Save/load of current room
- Multiple camera sub-zones within a single big room
- Cinematic door sequences (pauses, dialogue, unlock animations)
- Music or sound on transitions
- Unique art / palettes per room — the demo second room is a plumbing-only clone

## Files — created

- `rooms/Room.gd`, `rooms/Room.tscn` (base template)
- `rooms/StartingRoom.tscn`, `rooms/SecondRoom.tscn`
- `camera/GameCamera.gd`, `camera/GameCamera.tscn`
- `doors/Door.gd`, `doors/Door.tscn`
- `World.gd`, `World.tscn` (new entry scene)

## Files — modified

- `player/player.tscn` — add `"player"` group tag; remove the child `Camera2D` since camera is now external
- `project.godot` — point `run/main_scene` at `res://World.tscn`
- `player/player.gd` — expected no changes; if anything, wiring for the input-freeze hook during transitions

## How the next session should start

1. Read `CLAUDE.md` and `TESTING.md` (auto-loaded).
2. Read this file to confirm plan is still the intent.
3. Confirm with the user that they want to proceed (they may have changed their mind in the intervening time).
4. Execute Phase 1 first, checkpoint with the user visually, then proceed to Phase 2, etc.
5. Remember TESTING.md's QA patterns for any playtesting — no `simulate_action` + separate `capture_frames` sequences.
