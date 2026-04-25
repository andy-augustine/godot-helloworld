# Plan: Audio foundations + first three SFX (jump / heavy landing / wall slide)

**Status:** approved, not yet started.

**Estimated time:** ~3 hours total, mostly mechanical after Phase 1.

**Recommended model for execution:** Sonnet 4.6 (`claude-sonnet-4-6`) is sufficient — most of this is well-specified file authoring + script edits. Polish-mode tuning at the end may benefit from a more capable model on demand.

## Decisions locked in

1. **Sound source: Kenney CC0 packs.** [Interface Sounds](https://kenney.nl/assets/interface-sounds), [Impact Sounds](https://kenney.nl/assets/impact-sounds), [Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds). Auditioned and picked per-event in Phase 2.
2. **Audio bus structure: Master / Music / SFX.** Music bus exists for future content; nothing routes through it yet.
3. **Player model: pooled `AudioStreamPlayer` nodes** owned by an `AudioManager` autoload, plus one dedicated `AudioStreamPlayer` for the wall-slide loop on the player node itself.
4. **Pitch variation on jumps** (~±10%) so repeated jumps don't sound identical — standard polish trick. Heavy landings get **volume scaling** based on impact velocity, not pitch.
5. **Wall slide is a state, not an event** → looped audio, fade out smoothly on exit (~100 ms) so it doesn't click off.
6. **Out of scope this round:** music, transition stingers, footsteps, run-dust SFX. Those are easy follow-ups once the system is in.

## Architecture

```
Project Settings → Audio Buses
├── Master
├── Music   (created, no streams routed yet — placeholder for future)
└── SFX

AudioManager  (autoload — `audio/AudioManager.gd`)
├── _player_pool: 8 × AudioStreamPlayer (round-robin reuse for fire-and-forget SFX)
├── SFX: Dictionary[name → AudioStream]
├── play_sfx(name, pitch_variation=0.0, volume_db=0.0) → void

Player.tscn
└── WallSlideAudio (AudioStreamPlayer, dedicated, loop=true)  — managed directly by player.gd
```

**Why a pool, not one player per call:** fire-and-forget SFX can overlap (player jumps, lands, jumps again within 200ms). Spawning + freeing nodes for each call thrashes the scene tree. A pool of 8 is plenty for our SFX volume; oldest free wins, drops if all busy (rare).

**Why wall_slide is separate, not via AudioManager:** it's a sustained loop tied to player state, not a fire-and-forget event. Owning it on the player makes start/stop/fade trivial.

## Phase 1 — Audio infrastructure (~1 hr)

### 1a. Audio buses
- Open `Project Settings → Audio → Audio Buses`
- Add `Music` (route to Master)
- Add `SFX` (route to Master)
- Save. Confirm in `default_bus_layout.tres`.

Use MCP: `add_audio_bus` (Music), `add_audio_bus` (SFX). Verify with `get_audio_bus_layout`.

### 1b. AudioManager autoload
Create `audio/AudioManager.gd`:

```gdscript
extends Node

# Fire-and-forget SFX manager. Loads streams into a Dictionary, plays via a pool
# of AudioStreamPlayers so overlapping plays don't clobber each other.
#
# Usage:
#   AudioManager.play_sfx("jump", 0.1)              # ±10% pitch variation
#   AudioManager.play_sfx("heavy_landing", 0.0, -3) # quieter
#
# To register a new SFX: add an entry to SFX below + drop the .ogg file in
# assets/audio/sfx/. No code changes needed elsewhere.

const SFX_BUS := "SFX"
const POOL_SIZE := 8

const SFX: Dictionary = {
    "jump": preload("res://assets/audio/sfx/jump.ogg"),
    "heavy_landing": preload("res://assets/audio/sfx/heavy_landing.ogg"),
}

var _player_pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
    for i in POOL_SIZE:
        var p := AudioStreamPlayer.new()
        p.bus = SFX_BUS
        add_child(p)
        _player_pool.append(p)

func play_sfx(sfx_name: String, pitch_variation: float = 0.0, volume_db: float = 0.0) -> void:
    if not SFX.has(sfx_name):
        push_warning("AudioManager: unknown SFX '%s'" % sfx_name)
        return
    var player := _get_free_player()
    if player == null:
        return  # all busy, drop the sound
    player.stream = SFX[sfx_name]
    player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
    player.volume_db = volume_db
    player.play()

func _get_free_player() -> AudioStreamPlayer:
    for p in _player_pool:
        if not p.playing:
            return p
    return null
```

Register as autoload in `Project Settings → Autoload`: name `AudioManager`, path `res://audio/AudioManager.gd`, enable.

Use MCP: `add_autoload`. Verify with `get_autoload`.

## Phase 2 — Source + place SFX files (~30 min)

Download Kenney packs to a temp location and audition. Pick **one** file per event:

| Event | Suggested pack | Candidate files | Final filename |
|---|---|---|---|
| Jump | Interface Sounds | `pluck_001.ogg`, `pluck_002.ogg`, `switch_002.ogg` | `assets/audio/sfx/jump.ogg` |
| Heavy landing | Impact Sounds | `impactPlate_heavy_001.ogg`, `impactGeneric_heavy_001-005.ogg` | `assets/audio/sfx/heavy_landing.ogg` |
| Wall slide | Sci-Fi Sounds | `forceField_000-004.ogg` (loopable hum) | `assets/audio/sfx/wall_slide.ogg` |

**Process:**
1. Use a Bash command to download the pack(s) — Kenney exposes direct download links.
2. Unzip to a temp dir under the project root that's gitignored, e.g. `_audio_workshop/`.
3. Audition by playing on the command line (`afplay <file>` on macOS).
4. Copy the chosen file into `assets/audio/sfx/<name>.ogg`. **Only the chosen files** are committed.
5. Add `_audio_workshop/` to `.gitignore`.

**Wall slide must loop.** After importing into Godot, set the OGG resource's `loop` property to `true` in the inspector (or via MCP `edit_resource`). Without this, the player will hear the sound once and silence on a sustained slide.

**License attribution.** Kenney is CC0 (no attribution required), but it's polite. Add a one-line note in `assets/audio/sfx/CREDITS.md` listing pack names and Kenney's URL.

## Phase 3 — Wire jump SFX (~15 min)

In `player/player.gd`, in `_handle_jump`:

- After every successful jump (wall jump, floor jump, coyote jump), call `AudioManager.play_sfx("jump", 0.1)`.
- Three call sites: inside the wall-jump branch, inside the floor/coyote-jump branch. Don't fire on jump-cut (releasing jump key for variable height) — that's not a "jump" event in the audio sense.

Place the calls right after `_is_jumping = true` in each successful-jump path so they only fire on actual ignition.

## Phase 4 — Wire heavy-landing audio (alongside shake) (~15 min)

In `player/player.gd._shake_camera_on_land`, add audio at the same trigger as the shake:

```gdscript
func _shake_camera_on_land(fall_speed: float) -> void:
    if fall_speed < HEAVY_LANDING_MIN_VEL:
        return
    var span: float = HEAVY_LANDING_MAX_VEL - HEAVY_LANDING_MIN_VEL
    var t: float = clampf((fall_speed - HEAVY_LANDING_MIN_VEL) / span, 0.0, 1.0)
    
    # Existing camera shake
    var cam: Node = get_tree().get_first_node_in_group("camera")
    if cam and cam.has_method("add_shake"):
        cam.add_shake(lerpf(3.0, 9.0, t))
    
    # New: scaled audio, -6dB at light end, 0dB at saturation
    AudioManager.play_sfx("heavy_landing", 0.0, lerpf(-6.0, 0.0, t))
```

Reuses the `t` calculation so shake intensity and audio volume scale together — perfect coupling.

## Phase 5 — Wire wall-slide loop (~30 min)

### 5a. Scene change to `player.tscn`
Add a child of `Player`:
- Name: `WallSlideAudio`
- Type: `AudioStreamPlayer`
- `stream`: `res://assets/audio/sfx/wall_slide.ogg` (with `loop=true` set on the resource per Phase 2)
- `bus`: `SFX`
- `volume_db`: `-6.0` (start quieter than other SFX since it's sustained — tune in Phase 6)

Use MCP: `add_node`, `update_property`.

### 5b. Script wiring in `player.gd`

```gdscript
@onready var _wall_slide_audio: AudioStreamPlayer = $WallSlideAudio

# Track previous wall-slide state for entry/exit edges
var _was_wall_sliding: bool = false

# In _update_animation, after computing `wall_sliding`:
if wall_sliding and not _was_wall_sliding:
    _wall_slide_audio.volume_db = -6.0  # restore (in case mid-fade)
    _wall_slide_audio.play()
elif _was_wall_sliding and not wall_sliding:
    _fade_out_wall_slide()
_was_wall_sliding = wall_sliding

# New helper
func _fade_out_wall_slide() -> void:
    if not _wall_slide_audio.playing:
        return
    var tween := create_tween()
    tween.tween_property(_wall_slide_audio, "volume_db", -40.0, 0.1)
    tween.tween_callback(_wall_slide_audio.stop)
```

The 100ms fade prevents a click on exit. After `stop()`, the next entry resets `volume_db` so we don't accumulate fade state.

## Phase 6 — Tune (~30 min)

Playtest with `play_scene` and listen. Iterate on:

- **Master/SFX bus volumes** — open Audio Buses, adjust dB until SFX sit nicely behind the visuals.
- **Per-SFX `volume_db` arguments** — if jump is too loud relative to landing, drop its `volume_db` parameter at the call site.
- **Pitch variation on jumps** — 0.1 is a starting point. If repeated jumps still feel mechanical, try 0.15. If they feel too random/cartoony, drop to 0.05.
- **Wall slide volume curve** — does it cut in too suddenly? Try a 50ms fade-IN matching the fade-OUT.
- **Heavy-landing dB curve** — currently -6 → 0. May want quieter (-9 → -3) if it's overpowering.

After tuning, capture the final values in the script comments + the AudioManager defaults so they're durable.

## Files created

- `audio/AudioManager.gd`, `audio/AudioManager.gd.uid` (auto)
- `assets/audio/sfx/jump.ogg`, `heavy_landing.ogg`, `wall_slide.ogg` (+ `.import` files auto-generated by Godot)
- `assets/audio/sfx/CREDITS.md`
- `default_bus_layout.tres` (Godot regenerates when buses change)

## Files modified

- `project.godot` — adds `Music` and `SFX` buses (`audio_bus_layout`), adds `AudioManager` autoload
- `player/player.tscn` — adds `WallSlideAudio` child node
- `player/player.gd` — three new call sites + the wall-slide entry/exit + `_fade_out_wall_slide` helper
- `.gitignore` — add `_audio_workshop/`

## Files NOT modified

- `World.gd`, `camera/GameCamera.gd`, `doors/Door.gd`, `rooms/*` — no audio yet. Door-transition SFX is a follow-up backlog item.

## How execution should run

1. **Phase 1 first** and verify (open the Godot editor, check the bus layout panel, confirm autoload appears in the autoload list). Don't proceed if Phase 1 isn't visibly correct.
2. **Phase 2 next** — get the files in. This is the most likely place to stall (Kenney packs are zip downloads, requires picking + copying files). Audition via `afplay` so we don't ship sounds we haven't heard.
3. **Phases 3–5** are mechanical script + scene edits. Run the game between each phase to confirm the new audio fires.
4. **Phase 6** is the most subjective. Take screenshots/recordings via MCP if useful, but trust ears over screenshots for audio.

After all phases pass playtest, commit. Plan file moves to `plans/done/audio-foundations.md` per CLAUDE.md archive rule, with a completion-status header.

## Open question for the user mid-flight

If the Kenney files we audition don't fit the game's mood (the player rig is sleek/cyan/sci-fi, so chunky cartoon thuds may clash), I'll surface that during Phase 2 and we can swap packs before locking in.
