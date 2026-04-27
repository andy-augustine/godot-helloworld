# Plan: Pickups system — dash as the first ability

**Status:** in progress (claimed by Andy + Claude, branch `main`, 2026-04-27)

The genre-defining loop: pickups grant permanent movement abilities; rooms are designed so each new ability is required to clear the room it's found in. Dash ships first; future rooms add double-jump, wall-climb, etc.

This plan is multi-phase ("polish mode") because it spans data layer, player mechanics, HUD, level design, and polish. Phase order is risk-first: data + mechanic before UI before level changes before polish.

---

## Steelman of the design (refined from session 2026-04-27)

**Decision A — One ability shipped end-to-end (dash).** Multiple-abilities-per-plan is more game but more risk. Dash alone is a complete loop: pickup → ability granted → level requires it.

**Decision B — Each new room introduces AND requires its own ability.** Rooms 2/3/4 = dash / double-jump / wall-climb, in that order. Means progression is forward (each room is self-contained) rather than canonical Metroidvania backtracking. Backtracking-rewards (e.g. Room 1 ledges that need wall-climb to reach a secret) come later, once the ability set is rich enough to warrant it. This is a deliberate simplification appropriate for a teaching-the-genre project.

**Decision C — Movement abilities are always-on; weapons (future) use the existing skill cards.**

The skill-card drag-and-drop was a playtest mechanic for D&D, given a meaningful skin via "active passive buff." Forcing players to swap cards mid-combat to use dash would break game-feel — movement abilities have to be always-on per genre convention.

The cards repurpose to weapon-swap (drag a weapon card to the active slot to wield it). Stubbed for now — no weapon code in this plan, just documentation of intent in `Skills.gd` so the path is reserved.

The existing `turbo` and `high_jump` cards stay functional in P1 (they're passive multipliers, technically compatible with "weapon-like"). Migration to the inventory system is a deferred cleanup pass — one big change at a time.

**Decision D — HUD ability strip + future skill tree.**

Always-on abilities still need a UI. Two surfaces, staged:
- **Phase 1 (this ship):** small iconographic strip at the bottom-center of the HUD. Three categories: **Jumps** | **Runs** | **Climbs**. Each category is a short row of icons (24×24-ish). Locked = greyed silhouette at 25% alpha. Unlocked = full color + faint glow. Just-acquired = scale-pop + flash for ~1s.
- **Future:** pause-screen ability tree (Hollow Knight charm-grid style) — out of scope here, but the strip's data model should be tree-ready (each ability already lives in a category).

Bottom-center is chosen over top-center because top-left is the HealthBar and top-right is the SkillsPanel (cards). Bottom-center keeps the HUD balanced and reads as "your toolkit."

---

## Architecture

### Inventory autoload (new)

`inventory/Inventory.gd` — autoloaded singleton. Separate from `Skills` because the concept is fundamentally different:
- `Skills` = which active card buff is equipped (ephemeral, swappable).
- `Inventory` = which permanent abilities you own (additive, never lost).

```gdscript
# Inventory.gd
extends Node

# Permanent movement abilities (grants from pickups). Always-on once acquired.
# Persisted to user://inventory.json. Surfaced via the HUD ability strip and
# read by player.gd to gate movement features (dash, double_jump, ...).

const SAVE_PATH := "user://inventory.json"

var owned: Dictionary = {}  # ability_id (StringName) -> true

signal ability_granted(id: StringName)

func has(id: StringName) -> bool:
    return owned.get(id, false)

func grant(id: StringName) -> void:
    if owned.get(id, false):
        return
    owned[id] = true
    ability_granted.emit(id)
    _save()

func _save() -> void:
    var data := { "owned": owned.keys().map(func(k): return String(k)) }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(data))

func _load() -> void:
    # Symmetric load — restore owned dict from JSON
    ...
```

Note from intel crawl §4.4: `ResourceSaver.save()` writes nulls for nested sub-resources after the 4.5→4.6 upgrade. We're using `FileAccess` + JSON here (already the pattern used in `Skills.gd`), so the landmine doesn't apply. When an actual save system lands, this is the pattern to extend.

### Ability registry

A central list of all defined abilities (id, display name, category, icon). Lives at `inventory/abilities.gd` as a static dictionary. Used by both `Inventory` (for validation) and `HUD AbilityStrip` (for rendering).

```gdscript
# abilities.gd — static registry, no state
class_name Abilities

enum Category { JUMPS, RUNS, CLIMBS }

const REGISTRY: Dictionary = {
    &"dash": {
        "display_name": "DASH",
        "category": Category.RUNS,
        "icon_path": "res://inventory/icons/dash.svg",  # filled in P4
    },
    # double_jump, wall_climb, turbo, high_jump — stubs for future rooms
    &"double_jump": { "display_name": "DOUBLE JUMP", "category": Category.JUMPS, "icon_path": "" },
    &"wall_climb":  { "display_name": "WALL CLIMB",  "category": Category.CLIMBS, "icon_path": "" },
    &"turbo":       { "display_name": "TURBO",       "category": Category.RUNS,   "icon_path": "" },
    &"high_jump":   { "display_name": "HIGH JUMP",   "category": Category.JUMPS,  "icon_path": "" },
}
```

The strip renders all five from day one, with only `dash` unlockable in this ship — the others are visible-but-locked, which previews the progression visually.

### Pickup scene

`inventory/Pickup.tscn` — base scene for any pickup.
- Root: `Area2D` (in group `pickup`)
- `CollisionShape2D` — small rectangle (~24×24)
- `Visual` — `ColorRect` placeholder for V1; can promote to `Sprite2D` once an icon exists
- `IdleAnim` — `AnimationPlayer` with a gentle bob loop (vertical sine ~6px @ 1Hz)
- `Sparkle` — `CPUParticles2D` always-on, low-rate
- `PickupAudio` — `AudioStreamPlayer` for the on-grab sound
- Script: `Pickup.gd` with `@export var ability_id: StringName` and `body_entered → Inventory.grant(ability_id) → burst particles + audio + queue_free`

Per memory rule (`feedback_godot_mcp_scene_editing.md` rule 1), build `Pickup.tscn` end-to-end before instancing it in `SecondRoom.tscn`. Don't pierce instance boundaries.

### Player dash mechanic

Adds to `player.gd`:

```gdscript
const DASH_SPEED: float = 600.0
const DASH_DURATION: float = 0.18
const DASH_COOLDOWN: float = 0.4

var _dash_timer: float = 0.0       # >0 = currently dashing
var _dash_cooldown_timer: float = 0.0
var _air_dash_used: bool = false   # 1 air dash per air-time
var _dash_dir: int = 0             # frozen at dash-start
```

Behavior:
- Trigger: `Input.is_action_just_pressed("dash")` AND `Inventory.has(&"dash")` AND `_dash_cooldown_timer <= 0` AND (grounded OR not `_air_dash_used`).
- During dash: gravity disabled, `velocity.y = 0`, `velocity.x = DASH_SPEED * _dash_dir`. Horizontal input ignored.
- Direction: input axis if non-zero at dash-start, else `_facing`.
- On land: `_air_dash_used = false`.
- Cancellable into jump after dash ends (just doesn't extend the dash).
- New animation state `dash` — added to AnimationPlayer (or just a tinted `run` for V1; full state in P4).
- New CPUParticles2D `DashTrail` on the rig — emits backward during dash.
- Audio: `dash_whoosh` via `AudioManager.play_sfx`.
- Camera: small shake on dash activation (`add_shake(2.0)` — lighter than landing).

### HUD ability strip

`hud/AbilityStrip.tscn` + `hud/AbilityStrip.gd`. Anchored bottom-center of `HUD.tscn`.

Layout:
```
        [JUMPS]            [RUNS]           [CLIMBS]
       □ □ (locked)    ■ □ (dash lit)     □ (locked)
```

Implementation:
- Root: `Control` with bottom-center anchor preset (per `feedback_godot_mcp_scene_editing.md` rule 3 — static layout in inspector, not code).
- Three `VBoxContainer` columns, each with a category label + horizontal `HBoxContainer` of `AbilityIcon` instances.
- `AbilityIcon.tscn` — `TextureRect` + locked/unlocked state. Connects to `Inventory.ability_granted` to swap state and run the pop animation.

For V1 with no icons: each AbilityIcon is a 24×24 `ColorRect` (category-colored when unlocked, dim grey when locked), with the abbreviated ability name below. Icons proper come in P4.

### SecondRoom changes

Current state: 1600×720, ground at y=700, three platforms at heights 560/400/240, exit door (DoorL, leads back to StartingRoom) on the LEFT side. No exit on the right — the room is currently a dead-end.

Modifications:
- **Add a fourth platform (PlatformD)** at the far right (~x=1500, y=320) — out of jump-reach from PlatformC (at x=1200) without dashing. The dash-distance gap between PlatformC and PlatformD is the gating mechanism.
- **Add a dash pickup** on PlatformB (the middle one, y=400) — the player has to climb through normal jumping to reach the pickup, then dash to clear PlatformC→PlatformD.
- **Add DoorR** on the right wall, positioned above PlatformD, leading to a stub `ThirdRoom.tscn`.
- **Adjust WallRight position** to expose DoorR.

### ThirdRoom stub

`rooms/ThirdRoom.tscn` — minimal one-screen room with:
- Ground + walls + ceiling
- Spawn point matching the entry direction
- A back-door (`DoorL`) returning to SecondRoom
- A "future double-jump pickup will live here" sign — could be a `Label` placeholder that says "TO BE CONTINUED"

Keeps the loop visually closed (player dashes across, walks into a real room, can return). Future ship: double-jump pickup + tall-gap layout in ThirdRoom.

---

## Phases

### P0 — Inventory foundation (~1.5h)
- Create `inventory/` directory
- Create `inventory/abilities.gd` (Abilities class with REGISTRY)
- Create `inventory/Inventory.gd` autoload + register in `project.godot`
- Add `dash` input action to `project.godot` (default key: `Shift`)
- Acceptance: `Inventory.grant(&"dash")` succeeds in `execute_game_script`; `Inventory.has(&"dash")` returns true; persists across editor restart.

**Commit:** `P0: Inventory autoload + abilities registry`

### P1 — Dash mechanic (~2h)
- Add dash constants + state to `player.gd`
- Add `_handle_dash()` method, hook into `_physics_process`
- Wire `Inventory.has(&"dash")` gate
- Add `dash` animation clip (V1: tinted run) to `player.tscn` AnimationPlayer
- Test sequence: grant via `execute_game_script` → press Shift → verify dash happens
- Acceptance: dashing covers ~150px in 0.18s, ground + air dash work, air-dash refreshes on land, gated by Inventory.

**Commit:** `P1: Dash mechanic — gated by Inventory`

### P2 — HUD ability strip (~1.5h)
- Create `hud/AbilityIcon.tscn` (V1: ColorRect + Label)
- Create `hud/AbilityStrip.tscn` — three VBox columns
- Wire to `Inventory.ability_granted` for live updates
- Add to `HUD.tscn` as instance, anchored bottom-center
- Acceptance: strip shows 5 icons (1 lit if dash already granted, 4 locked); on `Inventory.grant(&"dash")` from a fresh state, the dash icon pops + lights up.

**Commit:** `P2: HUD ability strip — bottom-center, three categories`

### P3 — Level changes (~1.5h)
- Build `inventory/Pickup.tscn` end-to-end (root, collision, visual, sparkle, audio, script)
- Build `rooms/ThirdRoom.tscn` (stub)
- Edit `rooms/SecondRoom.tscn`: add PlatformD, instance Pickup on PlatformB with `ability_id = &"dash"`, add DoorR pointing to ThirdRoom, adjust WallRight
- Acceptance: player enters SecondRoom, can climb to PlatformB, picks up dash, can dash from PlatformC to PlatformD, walks through DoorR to ThirdRoom, returns via DoorL.

**Commit:** `P3: SecondRoom dash-gating + ThirdRoom stub + DashPickup`

### P4 — Polish (~2h)
- `DashTrail` particles on the player rig (CPUParticles2D, ghost trail)
- Dedicated `dash_whoosh` SFX hook (silent until audio lands, per backlog #16 pattern)
- Camera shake on dash (small, 2.0)
- On-pickup particle burst + audio
- Pickup idle bob (AnimationPlayer)
- Distinct `dash` animation clip on the player rig (subtle stretch + lean)
- Bottom-strip pop animation on grant (scale 1.0 → 1.3 → 1.0 over 0.4s, glow flash)
- Acceptance: dash *feels* like dashing — visual, audio, screen-shake all hit on the same frame.

**Commit:** `P4: Dash polish — trail, audio, shake, pickup VFX, strip pop`

### P5 — Stub the weapon-card future direction (~15min)
- Add a comment block at the top of `Skills.gd` documenting:
  - The active-card system is being repurposed for weapon swap
  - Movement abilities have moved to Inventory autoload
  - Existing turbo/high_jump cards remain as a bridge artifact, to be migrated to Inventory in a future cleanup pass when the weapon system is built
- Update `backlog/gamedev.md` with a new entry: "Migrate turbo/high_jump from Skills (cards) to Inventory (always-on) — pending weapon system"
- Mark `backlog/gamedev.md` #7 (Pickups system) as `**Status:** complete (2026-04-27)` per the post-ship docs sweep rule

**Commit:** `P5: Document weapon-card pivot + backlog updates`

### Post-ship docs sweep (per CLAUDE.md)
- Move `plans/pickups.md` → `plans/done/pickups.md` with status line + commit hashes
- Update `ROADMAP.md`: Updated date, Most recent ship, Where things live tree (add `inventory/`), Backlog top picks
- Update `STRUCTURE.md`: add `inventory/` to folder map
- Update `feedback_gdscript_practices.md` if any new traps surface during dev
- Commit: `Pickups: post-ship docs sweep + plan archive`

---

## Explicitly NOT in scope this round

- Double-jump, wall-climb (future room ships).
- Pause-screen skill tree (deferred until ability set is richer).
- Migrating turbo/high_jump out of the card system (deferred — separate cleanup pass).
- Locked doors (the gating in this ship is platforming-based, not door-based).
- Ability-revoke / pickup-respawn / save-system polish (single-grant-per-run is fine for a hello-world).
- Combat-tied abilities (dash invincibility, attack cancels, etc.).
- Sounds/icons that need real assets — V1 uses placeholders, sound hooks, and color blocks, all replaceable later without code changes.

---

## Risk register

| Risk | Mitigation |
|---|---|
| Dash collides with wall-jump lock — can dash while pressed against wall? | First implementation: dash always wins (overrides wall slide). Re-evaluate during P1 if it feels exploit-y. |
| Air-dash refresh on `is_on_floor()` may double-fire across coyote-time edge | Refresh only on `was_grounded == false → is_on_floor() == true` transition, not every frame |
| HUD strip clips into existing HealthBar or SkillsPanel at small viewport | 960×540 is the only target; manual-verify in editor after P2; add margin if needed |
| `Inventory` autoload load-order vs `Skills` autoload | Both are independent — neither calls the other. Order in project.godot is alphabetical safety. |
| AnimationPlayer events lost on 4.6.0→4.6.1 upgrade ([#116408](https://github.com/godotengine/godot/issues/116408), per intel crawl) | We're on 4.6.2; new tracks added in 4.6.2 are unaffected. Document in P1 commit if any added. |
| Lambda signal connections multiply on scene reload (per intel crawl §4.2) | Use named methods for `Inventory.ability_granted` connections, not lambdas |

---

## Estimated total

P0 1.5h + P1 2h + P2 1.5h + P3 1.5h + P4 2h + P5 0.25h + sweep 0.5h ≈ **9 hours**, plus the usual MCP iteration overhead. Realistically a one-or-two-session ship.
