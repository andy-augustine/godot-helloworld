# Plan: HUD + Player Health System

**Status:** approved, not yet started.

**Estimated time:** ~4 hours total.

**Recommended model for execution:** Sonnet 4.6 — well-specified mechanical work. Polish tuning in Phase 4 may benefit from a more capable model on demand.

**Merge note:** The concurrent audio session modifies `player/player.gd` (adds wall-slide audio, jump SFX call sites). This plan also modifies `player.gd` (health vars, `take_damage`, signals, i-frames). Both sets of changes are additive and in different sections of the file — they'll merge cleanly but whoever lands second should check for conflicts.

---

## Decisions locked in

1. **Health model: integer energy points, 100 max, configurable.** No energy tanks for now — those are a Pickups (#7) concern. One continuous pool keeps the system simple while pickups aren't in.
2. **HUD placement: CanvasLayer as a World child.** Not an autoload — the HUD is a display layer for the current session, not a cross-scene service. World.gd adds it as a child, finds the player via group "player" and connects signals.
3. **Health signals flow outward from player.gd:** `health_changed(current, maximum)` and `player_died`. HUD listens; nothing else needs to. This keeps the player script as the single source of truth for health state and avoids a separate autoload.
4. **Invincibility frames (i-frames): 1.2s after any hit.** Standard Metroid/platformer pattern. During i-frames the player rig flashes (alternating opacity 0.2 ↔ 1.0 at 10Hz) — visible feedback that you're temporarily safe.
5. **Death handling this round: freeze + brief pause, then respawn at the current room's first spawn point.** No game-over screen, no title screen regression, no save/load. Keep it simple until the save system exists. The respawn resets health to full.
6. **Damage source this round: none yet.** The `take_damage(amount)` method exists and works but nothing calls it automatically — enemies aren't in yet. We expose a debug key (Tab) to trigger a hit during testing so the full pipeline can be verified.
7. **Visual style: cyan/teal energy bar, top-left HUD corner, matching player rig palette.** Segmented look (dividers every 25pts = 4 segments) fits Metroid genre without requiring the full energy-tank system. The bar itself uses a `StyleBoxFlat` with the cyan accent color plus a subtle glow tint. Damage flash: bar briefly pulses red, then returns to cyan.

---

## Architecture

```
World.tscn
├── StartingRoom / current room
├── Player (CharacterBody2D)   ← player.gd — owns health state, emits signals
├── GameCamera (Camera2D)
└── HUD (CanvasLayer)          ← hud/HUD.gd — listens to player signals, draws health bar
    └── MarginContainer
        └── VBoxContainer
            └── HealthBar (Control)   ← hud/HealthBar.gd — draws segmented bar via _draw()
```

**Why CanvasLayer:** UI drawn on a CanvasLayer sits above the game world at a fixed screen position regardless of camera movement. Control nodes with CanvasLayer are the standard Godot pattern for HUD elements.

**Why custom `_draw()` for HealthBar rather than a ProgressBar:** The Metroid segmented aesthetic needs custom rendering — a `ProgressBar` node would require theme overriding to look right. A small `_draw()` node is ~20 lines and gives full control over glow, segments, and damage flash.

---

## Phase 1 — Health system in player.gd (~45 min)

### 1a. Constants and state

Add to `player.gd` under the existing `# ── State` section:

```gdscript
# Health
const MAX_HEALTH: int = 100
const IFRAMES_DURATION: float = 1.2
const IFRAME_FLASH_RATE: float = 10.0  # flashes per second

var _health: int = MAX_HEALTH
var _iframes_timer: float = 0.0

signal health_changed(current: int, maximum: int)
signal player_died
```

### 1b. `take_damage(amount)` method

```gdscript
func take_damage(amount: int) -> void:
    if _iframes_timer > 0.0:
        return
    _health = max(_health - amount, 0)
    _iframes_timer = IFRAMES_DURATION
    health_changed.emit(_health, MAX_HEALTH)
    var cam: Node = get_tree().get_first_node_in_group("camera")
    if cam and cam.has_method("add_shake"):
        cam.add_shake(4.0)
    if _health == 0:
        player_died.emit()
        _handle_death()
```

### 1c. Death and respawn

```gdscript
func _handle_death() -> void:
    set_physics_process(false)
    velocity = Vector2.ZERO
    await get_tree().create_timer(0.4).timeout
    _respawn()

func _respawn() -> void:
    var room: Node = get_tree().get_first_node_in_group("current_room")
    if room and room.has_method("get_spawn_position"):
        global_position = room.get_spawn_position("default")
    _health = MAX_HEALTH
    _iframes_timer = 0.0
    health_changed.emit(_health, MAX_HEALTH)
    set_physics_process(true)
```

This requires the current room to be tagged in group `"current_room"` (see Phase 1d). If no spawn is found, the player respawns in place — graceful fallback.

### 1d. Tick i-frames in `_tick_timers`

```gdscript
# I-frames countdown
if _iframes_timer > 0.0:
    _iframes_timer = max(_iframes_timer - delta, 0.0)
    # Flash the rig
    var flash: bool = fmod(_iframes_timer, 1.0 / IFRAME_FLASH_RATE) < (0.5 / IFRAME_FLASH_RATE)
    _rig.modulate.a = 0.2 if flash else 1.0
else:
    _rig.modulate.a = 1.0
```

### 1e. Debug damage key

```gdscript
func _input(event: InputEvent) -> void:
    if OS.is_debug_build() and event.is_action_pressed("ui_focus_next"):  # Tab key
        take_damage(20)
```

Remove this before shipping enemies — it's test scaffolding only.

### 1f. Tag current room — World.gd change

In `World.gd`, after each room becomes current, add it to group `"current_room"` and remove the old one:

```gdscript
# In _ready, after: _current_room = $StartingRoom
_current_room.add_to_group("current_room")

# In _start_transition, after: _current_room = new_room
_current_room.add_to_group("current_room")
# (the old room is queue_freed so it auto-leaves all groups)
```

---

## Phase 2 — HealthBar control (~1 hr)

Create `hud/HealthBar.gd`:

```gdscript
extends Control

# Segmented energy bar. Draws via _draw() for full style control.
# Call set_health(current, maximum) to update; the bar tweens on change.

const SEG_GAP: float = 2.0       # px gap between segments
const BAR_HEIGHT: float = 14.0
const CORNER_RADIUS: float = 3.0

const COLOR_FILL: Color = Color("00e5ff")       # cyan accent (matches player rig)
const COLOR_BG: Color = Color(0.05, 0.05, 0.1, 0.85)
const COLOR_DAMAGE: Color = Color(1.0, 0.2, 0.2)
const COLOR_SEG_LINE: Color = Color(0.0, 0.0, 0.0, 0.5)

var _current: float = 100.0
var _maximum: float = 100.0
var _display: float = 100.0       # lerped value for smooth drain animation
var _damage_flash: float = 0.0    # 0..1, decays after hit
var _segments: int = 4

func set_health(current: int, maximum: int) -> void:
    if current < _current:
        _damage_flash = 1.0
    _current = float(current)
    _maximum = float(maximum)

func _process(delta: float) -> void:
    _display = lerpf(_display, _current, 12.0 * delta)
    _damage_flash = max(_damage_flash - delta * 3.0, 0.0)
    queue_redraw()

func _draw() -> void:
    var w: float = size.x
    var h: float = BAR_HEIGHT
    var fill_ratio: float = _display / _maximum if _maximum > 0.0 else 0.0

    # Background
    draw_rect(Rect2(0, 0, w, h), COLOR_BG)

    # Fill (lerp toward damage color when flashing)
    var fill_color: Color = COLOR_FILL.lerp(COLOR_DAMAGE, _damage_flash)
    draw_rect(Rect2(0, 0, w * fill_ratio, h), fill_color)

    # Segment dividers
    for i in range(1, _segments):
        var x: float = (w / float(_segments)) * float(i)
        draw_line(Vector2(x, 0), Vector2(x, h), COLOR_SEG_LINE, SEG_GAP)

    # Outer border
    draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.15), false, 1.0)
```

---

## Phase 3 — HUD scene + wiring (~1 hr)

### 3a. Create `hud/HUD.gd`

```gdscript
extends CanvasLayer

# HUD root. Finds the player by group on _ready and connects health signals.
# Survives room transitions — the player node is stable; only the room swaps.

@onready var _health_bar: Control = $Margin/VBox/HealthBar

func _ready() -> void:
    var player: Node = get_tree().get_first_node_in_group("player")
    if player == null:
        push_warning("HUD: no node in group 'player'")
        return
    player.health_changed.connect(_on_health_changed)
    player.player_died.connect(_on_player_died)
    # Sync initial state
    _health_bar.set_health(player._health, player.MAX_HEALTH)

func _on_health_changed(current: int, maximum: int) -> void:
    _health_bar.set_health(current, maximum)

func _on_player_died() -> void:
    # Could show a death overlay here in a future phase
    pass
```

### 3b. Create `hud/HUD.tscn`

Scene tree:
```
HUD (CanvasLayer, layer=10)
└── MarginContainer (anchors: full rect; margin: 12px all sides)
    └── VBoxContainer (alignment: top-left; h_size_flags: shrink begin)
        ├── EnergyLabel (Label, text: "ENERGY", font_size: 9, color: cyan dim)
        └── HealthBar (Control, custom_minimum_size: (120, 14)) ← HealthBar.gd attached
```

Use MCP: `create_scene`, `add_node`, `update_property`, `attach_script`.

### 3c. Add HUD to World.tscn

Add `HUD` as the last child of `World`:
```
World
├── StartingRoom
├── Player
├── GameCamera
└── HUD   ← new
```

Use MCP: `add_scene_instance` (with path `res://hud/HUD.tscn`).

No changes to `World.gd` needed — HUD self-connects in `_ready`.

---

## Phase 4 — Tune and polish (~45 min)

Play-test with `play_scene`. Iterate on:

- **Bar width**: default 120px. If it feels too wide/narrow relative to the viewport, adjust `custom_minimum_size.x` on HealthBar.
- **Drain speed**: `lerpf(..., 12.0 * delta)` in `_process`. At 12.0, a full drain takes ~0.25s. If it feels laggy, raise to 20.0; if too instant, lower to 8.0.
- **Damage flash duration**: `_damage_flash - delta * 3.0` gives ~0.33s. Tune the `3.0` multiplier.
- **Label**: The "ENERGY" label above the bar is optional — may look cleaner without it. Remove if it clutters the corner.
- **I-frames flash rate**: `IFRAME_FLASH_RATE = 10.0` is standard. Drop to 6.0 if it feels seizure-y; raise to 14.0 for snappier feel.
- **Respawn delay**: currently 0.4s freeze before respawn. Extend to 0.8s with a red vignette flash if we want it to feel more dramatic (future).

After tuning, capture final values in constants/comments.

---

## Files created

- `hud/HUD.tscn`
- `hud/HUD.gd`, `hud/HUD.gd.uid`
- `hud/HealthBar.gd`, `hud/HealthBar.gd.uid`

## Files modified

- `player/player.gd` — health constants, state vars, signals, `take_damage`, `_handle_death`, `_respawn`, i-frame flash in `_tick_timers`, debug key in `_input`
- `World.gd` — tag current room with `"current_room"` group; add HUD instance to World.tscn
- `World.tscn` — `HUD` child added

## Files NOT modified

- `camera/GameCamera.gd` — already has `add_shake`, no changes needed
- `rooms/Room.gd` — `get_spawn_position` already exists (returns `spawn_points["default"]` or a fallback)
- `doors/Door.gd`, `rooms/*.tscn` — not touched

## Explicitly out of scope

- Energy tanks / expandable health capacity (that's Pickups #7)
- Ability indicator slots (no abilities yet)
- "Item acquired" notification (no pickups yet)
- Game-over screen / save slot selection (that's Save System #10 + Pause Menu #12)
- Music / SFX on damage (that's the concurrent audio session, or a follow-up)
- Enemy damage sources (that's Enemies #9 — enemies will call `player.take_damage(n)`)

---

## How execution should run

1. **Phase 1 first** — health state on the player. After Phase 1, verify in the editor that `player.gd` compiles clean (no errors in Output), and that pressing Tab deals 20 damage (printed via `print` is fine for quick confirm).
2. **Phase 2** — the HealthBar control. Validate the `_draw()` logic is correct by attaching it to a bare test scene if needed, or just proceed to Phase 3 and verify visually in the game.
3. **Phase 3** — wire HUD into World. Run the game and confirm: bar appears top-left, Tab key drains the bar, i-frames flash the player, respawn resets the bar to full.
4. **Phase 4** — playtest-driven tuning. No "done" state here — it's feel work.

After all phases pass playtest, commit. Plan moves to `plans/done/hud-health.md` per CLAUDE.md archive rule.

## Open questions for the user mid-flight

- If the corner HUD looks too cluttered (the game is fairly small-scale), we could try a bottom-center placement instead. Surface during Phase 4.
- The "ENERGY" label prefix is Metroid-authentic but may feel heavy for the current minimal aesthetic. Flag it for the user to decide in Phase 4.
