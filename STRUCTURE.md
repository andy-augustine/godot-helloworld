# Structure

How the project is laid out and how the pieces talk to each other. Aimed at someone **directing changes** ("make the deadzone bigger", "add a new room", "change what happens on a hard landing") rather than writing GDScript by hand.

For Godot/GDScript syntax and Unreal/Unity equivalents in depth, see [`GODOT_PRIMER.md`](GODOT_PRIMER.md). Quick analogies appear inline here.

---

## Folder map

```
godot-helloworld/
├── World.tscn                  ← entry scene (set in project.godot as main_scene)
├── World.gd                    ← top-level coordinator: owns Player+Camera+current Room, runs door transitions
├── project.godot               ← Godot project config (input map, autoloads, main_scene)
├── icon.svg                    ← project/window icon
│
├── player/
│   ├── player.tscn             ← CharacterBody2D + Rig (sprite limbs) + AnimationPlayer + particles
│   └── player.gd               ← movement, jump, wall slide, animation state, camera-shake hook
│
├── camera/
│   ├── GameCamera.tscn         ← bare Camera2D wrapper for the script
│   └── GameCamera.gd           ← follow logic, deadzone, lookahead, shake, room-bounds clamp
│
├── rooms/
│   ├── Room.tscn / Room.gd     ← base template — exports `bounds: Rect2`, draws bounds in editor
│   ├── StartingRoom.tscn       ← first room — platforms, doors, environment
│   ├── SecondRoom.tscn         ← second room — gated on dash (PlatformC→PlatformD gap)
│   └── ThirdRoom.tscn          ← stub closing the dash loop (TO BE CONTINUED label)
│
├── doors/
│   ├── Door.tscn               ← Area2D + collision + Spawn marker + visual
│   └── Door.gd                 ← target room path, target door name, direction, signal
│
├── audio/
│   └── AudioManager.gd         ← AudioManager autoload — bus routing, SFX/music helpers
│
├── hazards/                    ← procedural-animated tier hazards (drop into rooms)
│   ├── PlasmaFissure.tscn/.gd  ← tick-damage Area2D, bypasses iframes (Reactor Chamber)
│   ├── CoolantPool.tscn/.gd    ← Area2D slow-zone + StaticBody tank walls (Cryo Reservoir)
│   ├── SwingTendril.tscn/.gd   ← AnimatableBody2D pendulum platform (Cryo Reservoir)
│   ├── Piranha.tscn/.gd        ← swimming bite hazard inside the coolant pool (25 dmg, 1.2s cd)
│   └── Crown.tscn/.gd          ← endgame prize (ThirdRoom right side); pickup → HUD flash+confetti
│
├── shaders/
│   └── gradient_bg.gdshader    ← procedural-background gradient (per-room ShaderMaterial params)
│
├── hud/                        ← in-game UI
│   ├── HUD.tscn / HUD.gd       ← top-level HUD coordinator
│   ├── HealthBar.tscn / .gd    ← segmented bar w/ green→yellow→red gradient + crit pulse
│   ├── SkillCard.tscn / .gd    ← single skill card (drag source)
│   ├── SkillCardSlot.tscn / .gd← inventory + active slot (drop targets)
│   ├── SkillsPanel.tscn / .gd  ← top-right panel composing slots + cards
│   └── AbilityStrip.tscn / .gd ← bottom-center movement-ability strip (JUMPS/RUNS/CLIMBS)
│
├── skills/                     ← active-card state autoload
│   ├── Skill.gd                ← Resource subclass — id, name, description, icon
│   └── Skills.gd               ← Skills autoload — owned cards + currently-active slot
│                                  (future: repurposed for weapon swap)
│
├── inventory/                  ← movement-ability ownership + pickup scene
│   ├── abilities.gd            ← static REGISTRY for all defined movement abilities
│   ├── Inventory.gd            ← Inventory autoload — permanent owned abilities
│   ├── Pickup.gd / .tscn       ← reusable pickup (Area2D + visual + sparkle + audio)
│                                  ability granted via @export var ability_id
│
├── plans/                      ← in-progress multi-phase plans
│   └── done/                   ← completed plans, kept for context
│
├── tests/                      ← test scenes + RESULTS.md + README (how-we-test guide)
├── research/                   ← evaluations of external tools/approaches; intel crawl outputs
├── backlog/                    ← future ideas, not yet plans (gamedev + tooling-pipeline + claude-collab)
├── screenshots/                ← debug/QA screenshots (gitignored)
├── addons/godot_mcp/           ← godot-mcp-pro plugin (vendored — required by Claude)
├── CLAUDE.md                   ← rules Claude Code follows on every session
├── SETUP.md / README.md / GODOT_PRIMER.md / STRUCTURE.md  ← root docs
├── tests/README.md             ← how-we-test guide (lives next to test code)
└── .godot/, *.uid, .DS_Store   ← gitignored; auto-regenerated
```

**Convention**: each game entity is its own scene file (`.tscn`) with a script of the same name attached to its root node. `Player.gd` is attached to the root of `Player.tscn`, etc.

> **Unreal**: a `.tscn` is roughly a Blueprint asset / Level. The script attached to the root is its class. **Unity**: a `.tscn` is roughly a Prefab; the script is the MonoBehaviour on the root.

---

## Runtime scene tree

When the game runs, this is what's in memory:

```
World (Node2D)                      ← World.gd
├── StartingRoom (Node2D)           ← Room.gd — initial room, hot-swapped on door transition
│   ├── (platforms, walls — StaticBody2D)
│   ├── (doors — Area2D children, see below)
│   └── ...
├── Player (CharacterBody2D)        ← player.gd, in group "player"
│   ├── Rig (Node2D)                ← visual limbs + particle emitters
│   ├── AnimationPlayer
│   └── CollisionShape2D
└── GameCamera (Camera2D)           ← GameCamera.gd, in group "camera"
```

When a door fires, `World` instantiates the target room as a sibling of `Player`, tweens, then frees the old room.

> **Unreal**: Think of `World` as a `GameMode` + level streaming controller; rooms are sub-levels swapped in/out. **Unity**: `World` is the SceneManager; rooms are additive scenes.

---

## How the pieces talk

```
                    ┌────────────────────────────────────┐
                    │  World.gd  (top-level coordinator) │
                    └────────────────────────────────────┘
                       ▲                ▲             │
       player_entered  │                │ enter_room  │ instantiates,
       signal (door,   │                │ (sets cam   │ frees, tweens
       player)         │                │  limits)    ▼
                    ┌─────┐          ┌────────────┐   ┌──────────────┐
                    │Door │          │ GameCamera │   │  Room (cur)  │
                    │(in  │          │            │◄──│  (children:  │
                    │room)│          │            │   │   doors,     │
                    └─────┘          └────────────┘   │   platforms) │
                       ▲                  ▲           └──────────────┘
                       │                  │
                  body_entered        finds via
                  (Player Area2D)     group "player"
                       │                  │
                       └─── ┌────────┐ ───┘
                            │ Player │
                            └────────┘
                                 │
                       add_shake │  finds GameCamera
                       (heavy    │  via group "camera"
                       landing)  ▼
                            (back to GameCamera)
```

### The two groups

Godot **groups** are tag strings nodes can register themselves under. Any code can find members by tag:

| Group | Member | Used by | Why |
|---|---|---|---|
| `"player"` | the Player node | `GameCamera._ready()` finds the player to follow | Avoids hard parent/child coupling — camera doesn't need to be a child of the player |
| `"camera"` | the GameCamera node | `Player._shake_camera_on_land()` finds the camera | Player triggers screen shake on heavy landings without holding a direct reference |

> **Unreal**: groups ≈ Actor Tags + `GetAllActorsWithTag`. **Unity**: groups ≈ tags + `FindGameObjectsWithTag`. The Godot version is faster (groups are a hash set, not a tag string scan).

### The signal

Doors emit `player_entered(door, player)` when the player's body overlaps their Area2D. `World` connects to each door's signal whenever a room becomes the current room (on startup and after a transition completes), and disconnects from the old room's doors before freeing it.

> **Unreal**: signal ≈ Blueprint Event Dispatcher. **Unity**: signal ≈ `UnityEvent` or C# event. Wired up in code, not in the inspector here.

### Room transitions (the actual choreography)

Triggered when a Door fires `player_entered`:

1. `World._on_door_entered` — guard against re-entry, freeze player physics, zero velocity.
2. Load the target room's `PackedScene` from the door's `target_room_path`.
3. Instantiate the new room as a sibling of `Player`, positioned so its named target door (`door.target_door_name`) lines up `DOOR_GAP` (80 px) past the entry door, in the entry door's `direction`.
4. Compute the new camera position by clamping the spawn point to the new room's bounds rect.
5. **Pin the camera at its visible position** (using `get_screen_center_position()`) before clearing limits — otherwise the camera snaps to the player's raw position the instant limits release.
6. Disable smoothing + follow on the camera.
7. Run a parallel `Tween` (sine ease in-out, 0.5s): player position → spawn marker, camera position → clamped target.
8. After tween: disconnect old-room door signals, free the old room, connect new-room doors, re-enable camera follow + smoothing, set new room limits, unfreeze player.

> **Unreal**: `Tween` ≈ Timeline node. **Unity**: `Tween` ≈ DOTween / coroutine + lerp.

---

## Per-file responsibilities

### `World.gd`
**Purpose**: top-level coordinator. Owns the player, camera, and one current room at a time. Runs door transitions.

**You'd touch this file to**:
- Change transition speed → `TRANSITION_DURATION` (currently 0.5s)
- Change how far apart doors align across rooms → `DOOR_GAP` (80 px)
- Change transition easing → `tween.set_trans(...)` / `set_ease(...)` in `_start_transition`
- Add a fade/flash overlay during transitions

### `player/player.gd`
**Purpose**: input → motion → animation. CharacterBody2D-based platformer controller with coyote time, jump buffering, variable jump height, wall slide, and wall jump.

**You'd touch this file to**:
- Tune feel — every movement constant is at the top: `GRAVITY`, `MOVE_SPEED`, `ACCELERATION/DECELERATION` (ground + air), `JUMP_VELOCITY`, `JUMP_CUT_MULTIPLIER`, `WALL_JUMP_VELOCITY`, `COYOTE_TIME`, `JUMP_BUFFER_TIME`
- Add a new state (e.g. dash) — extend the state→animation block in `_update_animation` and the corresponding physics handler
- Change when heavy-landing shake fires → `HEAVY_LANDING_MIN_VEL` / `HEAVY_LANDING_MAX_VEL`
- Add new particle effects → drop a `CPUParticles2D` under `Rig`, wire it in `_update_particles`

### `camera/GameCamera.gd`
**Purpose**: follow the player, clamp to current room bounds, lookahead, deadzone, screen shake.

**You'd touch this file to**:
- Change deadzone size (camera doesn't react to small movements) → `deadzone_size`
- Change horizontal lookahead → `lookahead_x_amount`, `lookahead_x_speed`
- Change fall lookahead (camera pulls down on fast falls) → `fall_lookahead_amount`, `fall_velocity_threshold`
- Change vertical bias (more sky vs. more ground) → `y_offset` (default −40, negative = camera looks up)
- Change shake decay → `_SHAKE_DECAY`
- Change follow smoothing → `smoothing_speed`

> All of these are `@export` (Godot's "show in inspector" annotation; Unreal `UPROPERTY(EditAnywhere)` / Unity `[SerializeField]`), so they can also be tweaked directly in the editor on the GameCamera node without editing the script.

### `rooms/Room.gd`
**Purpose**: base class for room scenes. Exports a `bounds: Rect2` (camera-clamp region in local coords) and `spawn_points: Dictionary` (named entry/spawn positions). Draws the bounds rect in the editor (debug-only — invisible at runtime).

**You'd touch this file to**:
- Change the editor bounds visualization color or thickness → `_BOUNDS_COLOR`, `_BOUNDS_WIDTH`
- Add a per-room property (background music, ambient color, gravity scale)

**To add a new room**: duplicate `StartingRoom.tscn`, edit its `bounds`, add Door children pointing at neighbors, edit door arrangement. No code change needed.

### `doors/Door.gd`
**Purpose**: trigger that fires when the player overlaps it. Carries metadata about which room and which door to land at.

**Per-door inspector fields**:
- `target_room_path` — file picker; `.tscn` of the destination room
- `target_door_name` — string; the **node name** of the door in that room to line up with
- `direction` — `Vector2`; which way the player exits this door (e.g. `(1,0)` east, `(-1,0)` west, `(0,1)` south)
- `spawn_inset` — fallback distance from door if there's no `Spawn` marker child

The `Spawn` Marker2D (child of the door) is the exact arrival point for the player when they come through this door from elsewhere.

> **Unreal**: a Door is roughly a `TriggerVolume` Actor with exposed properties. **Unity**: a trigger Collider + a small MonoBehaviour with `[SerializeField]` references.

### `camera/GameCamera.tscn` / `doors/Door.tscn` / `rooms/Room.tscn`
Just wrappers — the script holds the logic; the scene exists so the script can be instanced as a `PackedScene`. Standard Godot pattern.

---

## Where to change common things

| You want to... | File / property |
|---|---|
| Change overall game feel (jump height, run speed) | `player/player.gd` constants block |
| Make landing shake stronger / weaker | `player/player.gd` `_shake_camera_on_land` (calls `cam.add_shake(...)`) |
| Make the camera less twitchy | `camera/GameCamera.gd` `deadzone_size`, `smoothing_speed` |
| Make transitions faster / slower / linear | `World.gd` `TRANSITION_DURATION`, `tween.set_ease/set_trans` |
| Add a new room | duplicate `rooms/StartingRoom.tscn`; set `bounds`; add Door children pointing at neighbors |
| Connect two rooms | put a Door on each side; set `target_room_path` and `target_door_name` cross-referencing each other |
| Change the input bindings | `project.godot` → "Input Map" tab in the Godot editor |
| Change the entry scene | `project.godot` → `run/main_scene` (currently `World.tscn`) |

---

## What's deliberately *not* here

- **No external state-machine plugin** — the player uses an `enum`-and-`match` pattern in `_physics_process`. Simple and visible.
- **No TileMapLayer** — rooms use hand-placed `StaticBody2D` platforms. Tile art is a future phase.
- **No save/load**, **no enemies** — scoped out. Add them as new top-level subsystems following the same pattern (own scene + script + group tag if other systems need to find them). HUD (`hud/`) and pickups (`inventory/`) have shipped; see those folders.
