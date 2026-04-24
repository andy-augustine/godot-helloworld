# Game Spec v1 — Animated Platformer

**Date:** 2026-04-24
**Commit:** `3fcc600`
**Captures:** the project after the animated-player-rig phase, before the room/camera system.

This is what you'd hand to an AI if you wanted to recreate the current project in a single prompt. It's organized for both humans (top-to-bottom readable) and AI (section-labeled, numbers explicit, scope stated).

---

## 1. Concept

A Metroid-style 2D platformer built in Godot 4 / GDScript. Focus is tight, forgiving platformer feel with animation and particle polish. No combat, no enemies, and no multi-room levels yet — just a single playground with walls and platforms to exercise movement and rig animations.

## 2. Tech stack

- **Engine:** Godot 4.6+
- **Language:** GDScript (not C#)
- **Renderer:** `gl_compatibility` (broad hardware support)
- **Art:** 100% procedural — everything drawn from `Polygon2D` primitives and `ColorRect`. No textures, no sprite sheets.
- **Target resolution:** 960×540, aspect preserved, HiDPI disabled

## 3. Project settings

In `project.godot`:

```ini
[application]
run/main_scene="res://main.tscn"

[display]
window/size/viewport_width=960
window/size/viewport_height=540
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
window/dpi/allow_hidpi=false

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
```

**Input actions** (in `[input]` block):

| Action | Bindings |
|---|---|
| `move_left` | A, Left arrow |
| `move_right` | D, Right arrow |
| `jump` | Space, W, Up arrow |

## 4. Player

Scene: `player/player.tscn`. Root is a `CharacterBody2D`.

### 4.1 Scene hierarchy

```
Player (CharacterBody2D)
├── CollisionShape2D (RectangleShape2D, ~16×40)
├── Rig (Node2D)                    — handles facing flip via scale.x = ±1
│   └── Squash (Node2D)              — handles squash/stretch animations (scale)
│       ├── LegBack (Polygon2D)
│       ├── LegFront (Polygon2D)
│       ├── ArmBack (Polygon2D)
│       ├── Torso (Polygon2D)
│       ├── ChestLight (Polygon2D)   — cyan diamond
│       ├── ArmFront (Polygon2D)
│       ├── Head (Polygon2D)         — octagonal dome
│       ├── Visor (Polygon2D)        — cyan strip, asymmetric, points forward
│       ├── LandDust (CPUParticles2D)
│       ├── RunDust (CPUParticles2D)
│       └── WallSlideSparks (CPUParticles2D)
├── AnimationPlayer
└── Camera2D
```

**Why Rig and Squash are separate nodes:** `Rig.scale.x` drives the facing flip (±1). `Squash.scale` drives squash/stretch animations. Keeping them on separate nodes means the animation player can't fight the facing code, and vice versa.

### 4.2 Rig parts — exact geometry

All positions are local to `Squash`. All polygons are in the part's local coordinates.

| Part | Polygon points | Position | Color |
|---|---|---|---|
| LegBack | `[(-3,0),(3,0),(3,20),(-3,20)]` | `(4, 12)` | `#2b2f3d` |
| LegFront | `[(-3,0),(3,0),(3,20),(-3,20)]` | `(-4, 12)` | `#2b2f3d` |
| ArmBack | `[(-3,0),(3,0),(3,18),(-3,18)]` | `(8, -12)` | `#2b2f3d` |
| ArmFront | `[(-3,0),(3,0),(3,18),(-3,18)]` | `(-8, -12)` | `#2b2f3d` |
| Torso | `[(-11,-14),(11,-14),(10,14),(-10,14)]` | `(0, -2)` | `#2b2f3d` |
| ChestLight | `[(-3,0),(0,-3),(3,0),(0,3)]` | `(0, 0)` | cyan (e.g. `#4fe8ff`) |
| Head | `[(-7,8),(-8,2),(-6,-6),(-2,-8),(2,-8),(6,-6),(8,2),(7,8)]` | `(0, -24)` | `#2b2f3d` |
| Visor | `[(1,-2),(7,-3),(7,3),(1,4)]` | `(0, -24)` | cyan |

The visor's asymmetric shape (sticking out to the right of head center) is what visually signals facing direction. Flipping `Rig.scale.x` to -1 mirrors it to point left.

**Note on arm/leg placement:** "Front" parts are placed on the *left* side of the body (negative X) and "Back" parts on the right. In a side-view profile of a character facing right, this reads as the near-camera arm/leg visible in front of the torso and the far arm/leg behind it.

### 4.3 Movement constants

In `player/player.gd` (attached to the CharacterBody2D):

```gdscript
const GRAVITY = 1800.0
const MOVE_SPEED = 220.0
const ACCELERATION = 1400.0
const DECELERATION = 1600.0
const AIR_ACCELERATION = 900.0
const AIR_DECELERATION = 700.0

const JUMP_VELOCITY = -540.0
const JUMP_CUT_MULTIPLIER = 0.4       # velocity multiplier on early release
const FALL_GRAVITY_MULTIPLIER = 1.6   # stronger gravity when descending

const WALL_SLIDE_GRAVITY = 200.0      # capped fall speed during wall slide
const WALL_JUMP_VELOCITY = Vector2(240, -480)

const COYOTE_TIME = 0.15              # can jump this long after leaving ground
const JUMP_BUFFER_TIME = 0.10         # jump input held this long before landing
const WALL_JUMP_LOCK = 0.15           # horizontal input reduced post-walljump

const FACING_LERP = 0.3               # per-frame smoothing on facing flip
const LAND_DUST_MIN_VEL = 200.0       # below this fall speed, landing is silent
```

### 4.4 Movement behaviors

- **Horizontal:** `Input.get_axis("move_left", "move_right")` → accelerate toward `dir * MOVE_SPEED` with separate ground/air accel+decel. During `WALL_JUMP_LOCK`, input is reduced to 30% so the kick-off isn't instantly cancelled.
- **Jumping:**
  - Triggered by a buffered press within `JUMP_BUFFER_TIME`, and requires either `is_on_floor()` or coyote time (left ground less than `COYOTE_TIME` ago).
  - Variable height: if the player releases jump while `velocity.y < 0`, multiply `velocity.y` by `JUMP_CUT_MULTIPLIER`.
  - Falling: apply `FALL_GRAVITY_MULTIPLIER` to gravity when `velocity.y > 0`.
- **Wall slide:** if airborne + pressing toward a wall + `_wall_jump_lock_timer == 0`, cap fall speed at `WALL_SLIDE_GRAVITY` by moving toward it at rate `GRAVITY * delta`.
- **Wall jump:** when wall-sliding + buffered jump, set `velocity = Vector2(-wall_dir * WALL_JUMP_VELOCITY.x, WALL_JUMP_VELOCITY.y)`, arm the lock timer, clear coyote.
- **Ceiling:** on `is_on_ceiling()` with `velocity.y < 0`, zero upward velocity and clear `_is_jumping`.

Physics note: `move_and_slide()` zeros velocity on collision, so `_pre_move_vel_y = velocity.y` must be captured before `move_and_slide()` is called — used by the landing animation to measure impact speed.

### 4.5 Facing logic

```gdscript
if dir > 0.0: _facing = 1
elif dir < 0.0: _facing = -1

# When wall-sliding, face toward the wall regardless of input
if wall_sliding:
    _facing = _get_wall_direction()

_rig.scale.x = lerpf(_rig.scale.x, float(_facing), FACING_LERP)
```

## 5. Animations

One `AnimationPlayer` with a default (unnamed) `AnimationLibrary`. All animations below live in that library.

### 5.1 RESET
Baseline pose for every tracked property — required so Godot can interpolate cleanly into any animation. Keyframes rest positions of `Squash`, `Torso`, `Head` plus base rotations/scales of all limbs.

### 5.2 idle — 1.6s, `LOOP_LINEAR`
- `Torso:position.y` — subtle bob (-2 → 0 → -2)
- `Head:position.y` — same bob
- `Visor:modulate` — pulses to `Color(1.5, 1.5, 1.5, 1)` at midpoint (bright glow)
- `ChestLight:modulate` — same pulse

### 5.3 run — 0.5s, `LOOP_LINEAR`
- `LegFront:rotation` — `0.6 → -0.6 → 0.6` (kick forward, swing back)
- `LegBack:rotation` — counter-phase (`-0.6 → 0.6 → -0.6`)
- `ArmFront:rotation` — `±0.5` counter-swinging LegFront
- `ArmBack:rotation` — opposite
- `Squash:position` — `(0,0) → (0,-2) → (0,0) → (0,-2) → (0,0)` (two up-bounces per stride)
- `Torso:rotation` — `0.08` (slight forward lean)

**Runtime tempo:** `_anim.speed_scale = clamp(|velocity.x| / MOVE_SPEED, 0.5, 1.5)` so the cycle matches actual movement — no foot-skating when the player is slowed, no wild flailing when fast.

### 5.4 jump — 0.2s, no loop
Takeoff pose — plays once, holds final frame while airborne and rising.
- `Squash:scale` — `(1,1) → (0.88, 1.15) → (0.95, 1.08)` (stretch up)
- `LegFront:rotation` — `-0.7` (tucked)
- `LegBack:rotation` — `-0.4`
- `ArmFront:rotation` — `-1.2` (arms up)
- `ArmBack:rotation` — `-0.8`

### 5.5 fall — 0.8s, `LOOP_LINEAR`
Plays when airborne and `velocity.y > 0`.
- `Squash:scale` — subtle wobble
- `LegFront/LegBack:rotation` — split to ±0.25
- `ArmFront:rotation` — `-0.9`, `ArmBack:rotation` — `-0.55` (arms trail upward)

### 5.6 wall_slide — 0.5s, `LOOP_LINEAR`
- `ArmFront:rotation` — `-2.6` (reaching up, bracing against wall)
- `ArmBack:rotation` — `0.2`
- `Torso:rotation` — `0.12` (lean into wall)
- `Visor:modulate` — pulses to 1.8× brightness

### 5.7 land — 0.25s, no loop
One-shot on airborne→grounded transition when fall speed exceeded `LAND_DUST_MIN_VEL`.
- `Squash:scale` — `(1.25, 0.7) → (0.95, 1.05) → (1, 1)` (squash, overshoot, settle)
- Cannot be preempted by other animations until it finishes.

### 5.8 Animation selection logic

Called each frame after movement updates:

```gdscript
# Landing override on first grounded frame, if impact was fast enough
if grounded and not _was_grounded and _pre_move_vel_y > LAND_DUST_MIN_VEL:
    _play("land")
    _emit_land_dust(_pre_move_vel_y)

# Don't preempt the one-shot land animation
if _current_anim == "land" and _anim.is_playing():
    return

# State → animation
if wall_sliding:
    _play("wall_slide")
elif not grounded:
    _play("jump" if velocity.y < 0 else "fall")
elif absf(velocity.x) > 10.0:
    _play("run")
else:
    _play("idle")
```

## 6. Particles

All three use `CPUParticles2D` (not GPUParticles2D — simpler, plenty fast for this).

### 6.1 LandDust
- Parent: `Rig/Squash`, position `(0, 32)` (at player's feet)
- Mode: one-shot, `explosiveness = 0.85` (burst)
- Lifetime: 0.6s; direction `(0, -1)`; spread 90°
- Emission shape: `RECTANGLE`, extents `(10, 1)` (wide strip)
- **Dynamic** (scaled by fall speed): `t = clamp((fall_speed - 200) / 600, 0, 1)`
  - `amount = lerp(6, 18, t)`
  - `initial_velocity_max = lerp(60, 140, t)`
- Scale: 3.5 – 6.0
- Gravity: `(0, 260)` (dust falls back down)
- Color ramp: dust-gray `#8c94ae` → transparent
- Trigger: `_emit_land_dust(fall_speed)` sets `amount` and `initial_velocity_max`, then calls `.restart()`

### 6.2 RunDust
- Parent: `Rig/Squash`, position `(0, 32)`
- Mode: continuous, emitting when `grounded and |velocity.x| > 40`
- Amount: 12; lifetime 0.35s
- Direction: `Vector2(-sign(velocity.x), -0.4)` (trails behind motion)
- Spread: 25°; velocity 20 – 50
- Scale: 2.5 – 4.5
- Gravity: `(0, 200)`
- Color ramp: same dust-gray, fading

### 6.3 WallSlideSparks
- Parent: `Rig/Squash`, position `(±14, 0)` — flipped to match wall side: `position.x = 14 * wall_direction`
- Mode: continuous, emitting while wall-sliding
- Amount: 18; lifetime 0.35s
- Emission shape: `RECTANGLE`, extents `(1, 10)` (thin vertical strip along body)
- Direction: `(0, -1)` (up); spread 35°; velocity 40 – 90
- Scale: 1.5 – 3.0
- Gravity: `(0, 240)`
- Color ramp: yellow → orange → transparent

## 7. Level

`main.tscn` is a single-screen playground. Hand-placed `StaticBody2D` nodes (no TileMap yet).

| Node | Position | Collision size | Visual color |
|---|---|---|---|
| Ground | `(576, 648)` | `1400 × 40` | `#595c8c` |
| Platform1 | `(300, 528)` | `200 × 20` | `#595c8c` |
| Platform2 | `(576, 448)` | `200 × 20` | `#595c8c` |
| Platform3 | `(876, 368)` | `200 × 20` | `#595c8c` |
| SmallPlatform1 | `(176, 368)` | `80 × 20` | `#595c8c` |
| SmallPlatform2 | `(976, 288)` | `80 × 20` | `#595c8c` |
| WallLeft | `(136, 518)` | `40 × 260` | `#4d527a` |
| WallRight | `(1016, 518)` | `40 × 260` | `#4d527a` |

Each node contains a `CollisionShape2D` (RectangleShape2D) and a matching `ColorRect` visual with the same bounds. Walls are tall vertical rectangles for wall-slide / wall-jump practice.

Player spawn: `(576, 500)`.

## 8. Camera

Currently a `Camera2D` as a child of Player. No limits, no smoothing tuning — it just follows. This is placeholder; a room-bounded external camera is the next phase.

## 9. Intentional scope limits

What this v1 does **NOT** include, and should **NOT** be added during rebuild:

- Room-based camera or multi-room transitions
- TileMapLayer-based levels (hand-placed StaticBody2D only)
- Enemies, combat, damage, HP
- Pickups, upgrades, collectibles
- UI / HUD
- Sound effects, music
- Save/load, checkpoints
- Multiple scenes/levels beyond `main.tscn`
- Sprite-sheet art (everything is Polygon2D)

---

## Appendix: What makes this a good spec

Patterns worth noticing if you're writing one of these yourself:

1. **Numbers, not adjectives.** `MOVE_SPEED = 220` is executable. "Feels snappy" is not.
2. **Exact geometry.** Polygon points and positions stated so the rebuild looks like the original, not approximately like it.
3. **Scope stated explicitly** (Section 9). Without a scope fence, an AI will "help" by adding features you didn't ask for.
4. **Rationale for non-obvious decisions** (e.g. *why* Rig and Squash are separate, or the arm/leg "front is on the left" note). Prevents the AI from "fixing" intentional structure during rebuild.
5. **State logic as pseudocode**, not prose. Ambiguity gets resolved by you once, not guessed by the model over and over.
6. **Project settings explicit.** Resolution, stretch mode, HiDPI, and input actions are easy to forget but affect game feel and portability.
7. **Tables for repetitive structured data** (body parts, level geometry, input actions). Less reading, easier to scan, harder to miss a row.

Rule of thumb: if you couldn't hand the spec to a new human and get a recognizable rebuild back, the spec is too vague.
