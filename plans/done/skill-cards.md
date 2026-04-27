# Plan: Skill Cards — drag-and-drop inventory + active slot

**Status:** complete (2026-04-26). All five phases shipped. P4 was originally deferred but later validated via the synthetic-drag pattern unlocked in P5 (the `relative`-on-motions discovery + addon patches made mid-drag visual verification reliable).

**Commits:**
- `506f576` P1 — Skill class + Skills autoload + player coupling
- `dafbd82` P2 — HUD scaffolding (SkillCard / SkillCardSlot / SkillsPanel)
- `3108d2f` P3 — drag-drop methods (equip / swap / deactivate)
- `b14b9c0` P3 fix — mouse_filter on inner Controls
- `66a3ea4` P3 fix — DescLabel custom_minimum_size for autowrap
- `d6da1a6` P3 hygiene — static visuals to inspector StyleBoxFlat
- `0d925ff` P3 — SkillCard forwards _can_drop_data/_drop_data (swap-on-occupied)
- `fe5645e` P5 (initial, retracted) — direct-invocation harness; synthetic drag thought broken
- `4e75a95` P5 follow-up — research crawl retracts the "broken" finding
- `4587965` P5 hands-off re-run — addon patch #1, mystery still open
- `8ba9fe3` P5 final — synthetic drag fully working end-to-end (relative-on-motions was the key, plus addon patch #2)
- `338a1b0` P4 polish — equipped pulse, hover lift, drag preview, drop flash, empty-slot style

**Outcome:**
- Phases 1–3 went per plan after several `.tscn` serialization issues (duplicate `EmptyPanel` captures in SkillsPanel.tscn → HUD.tscn) which were fixed and which produced six new working-style rules now encoded in `feedback_godot_mcp_scene_editing.md` memory.
- Phase 5 produced a meaningful **negative result**: synthetic drag-and-drop via `Input.parse_input_event` and `Viewport.push_input` does not work in Godot 4.6.2 (verified `_gui_input` doesn't fire). The recipe from `research/tools/godot-drag-drop-api.md §3` is invalidated for this Godot version. Documented in `tests/RESULTS.md` and the research doc; replaced with a direct-invocation runner at `tests/run_drag_recipe.gd`.
- Phase 4 (polish) was skipped — empty-slot dashed border, drag preview scale-up, equipped pulse, drop flash, hover lift. The feature works without these. Future opportunistic touch-up via a small follow-up.

**Carryover:**
- P4 polish items (deferred — see above).
- The synthetic-drag bisect (when did it break in 4.x?) is not done. Out of scope. If it turns out to be a 4.6 regression worth filing upstream, that's a separate task.
- "Synthetic drag-and-drop" Claude skill — **not graduated**. The recipe doesn't work. Captured the empirical finding instead. No skill to extract.

**Estimated time vs actual:** estimated ~5–6 hours; actual closer to 8 hours including the .tscn cleanup detours and the P5 dead-end investigation. Most of the overrun was on the .tscn serialization issues — now prevented going forward by the encoded rules.

**Why this plan exists:** We need to validate the synthetic-drag recipe in [`research/tools/godot-drag-drop-api.md §3`](../research/tools/godot-drag-drop-api.md) against a real UI before crystallizing it into a Claude skill. Rather than build throwaway test scaffolding under `tests/`, this plan delivers a real game system — a 2-card skill inventory + 1 active slot HUD in the top-right corner — and uses it as the validation harness in Phase 5. Forward-compatible with the future pickup system (the only change later is "find the cards" instead of "start with both").

**Estimated time:** ~5–6 hours total. P1 ~1h, P2 ~1.5h, P3 ~1h, P4 ~45m, P5 ~1.5h.

**Recommended model for execution:** Sonnet 4.6 for P1–P3 (mechanical), Opus on call for P4 visual tuning and P5 recipe-debugging if the negative control or recipe doesn't behave as predicted.

---

## Decisions locked in (from user)

1. **Persistence: yes for now.** Active-slot selection survives quit/relaunch via `user://skills.json`. Death-system impact (lose on death? keep until N deaths? lose-everything-on-death?) is **deferred** — depends on what kind of game this becomes. For now, deaths do not affect the active slot.
2. **Drop into occupied active slot: swap.** The card already in the active slot returns to the inventory slot the incoming card came from. (Future: confirmation popups, swap animations.)
3. **Deactivate via drag-back.** Drag the active card back into either inventory slot to clear active. (Future: double-click, right-click, dedicated "unequip" button.)
4. **Visual style: distinct treatment, playing-card aesthetic.** Rounded corners, bordered, distinct per-skill color. Text-only labels in this plan; richer graphics deferred. Do **not** match the existing HUD/HEALTH bar look — these are deliberately their own thing.
5. **Skills shipped:** **Turbo** (+50% top speed) and **High Jump** (+50% jump height). Both start in inventory at game start; active slot starts empty.
6. **Layout: top-right HUD corner.** Two inventory slots stacked or side-by-side, plus one active slot below/beside. Final arrangement decided in P2 by visual feel.

---

## Architecture

```
res://skills/
  Skill.gd                    — Resource base class (id, display_name, description, color, multipliers)
  turbo.tres                  — Skill instance: id="turbo", speed_mult=1.5, jump_mult=1.0
  high_jump.tres              — Skill instance: id="high_jump", speed_mult=1.0, jump_mult=1.5
  Skills.gd                   — autoload singleton: inventory + active_slot, persistence, signals

res://hud/
  SkillCard.tscn / .gd        — Control: draws a card (rounded panel, label, color tint).
                                Implements _get_drag_data + set_drag_preview.
  SkillCardSlot.tscn / .gd    — Control: a card-shaped drop zone.
                                Implements _can_drop_data + _drop_data.
                                Holds a reference to the SkillCard inside it (or null).
  SkillsPanel.tscn / .gd      — Container: lays out 2 inventory slots + 1 active slot top-right.
                                Subscribes to Skills.active_changed and rebuilds card placement.

res://hud/HUD.tscn            — modified: adds SkillsPanel anchored top-right.

res://player/player.gd        — modified: reads multipliers from Skills singleton, applies to
                                MOVE_SPEED and JUMP_VELOCITY each physics frame.

res://tests/                  — new dir
  run_drag_recipe.gd          — test runner (Recipe A + Recipe B + negative control)
  RESULTS.md                  — captured baselines per Godot version
```

**Why a Resource base for Skill:** keeps the door open to disk-loaded skill libraries (e.g., a future `skills/library/*.tres` folder) without rewriting the data model. For now we just have two `.tres` files. Same shape as the existing audio bus / particle preset Resources used elsewhere in Godot conventions.

**Why an autoload (`Skills`) instead of a HUD-local state object:** the player needs to read multipliers; making the player walk a node path to find the HUD is fragile (HUD might not exist yet on `_ready`, room transitions, etc.). An autoload is the standard Godot pattern when "the active skill" is logically game-global. Mirrors `AudioManager`.

**Why drag/drop on `Control` nodes (Flavor A) and not 2D physics drag (Flavor B):** the cards are HUD elements, so Godot's Control drag-and-drop system is the right fit. The recipe doc covers both flavors; P5 also exercises Flavor B against a sprite for completeness, but the production code is Flavor A only.

---

## Phase 1 — Data model + player coupling (~1 hr)

### 1a. `skills/Skill.gd`

```gdscript
class_name Skill
extends Resource

@export var id: StringName              # unique key, e.g. "turbo"
@export var display_name: String        # shown on card
@export var description: String         # shown under name (one short line)
@export var color: Color                # card tint
@export var speed_multiplier: float = 1.0
@export var jump_multiplier: float = 1.0
```

### 1b. `skills/turbo.tres` and `skills/high_jump.tres`

Create via MCP `create_resource` with type `Skill`:

| Resource | id | display_name | description | color | speed | jump |
|---|---|---|---|---|---|---|
| `turbo.tres` | `turbo` | "TURBO" | "+50% top speed" | `Color("ff8c1a")` (orange) | 1.5 | 1.0 |
| `high_jump.tres` | `high_jump` | "HIGH JUMP" | "+50% jump height" | `Color("9b6cff")` (purple) | 1.0 | 1.5 |

### 1c. `skills/Skills.gd` (autoload)

```gdscript
extends Node

# Skill state, autoloaded so player and HUD can both read it.
# Inventory is fixed for now (player starts with both); active slot
# is the only mutable state. Persists to user://skills.json.

const SAVE_PATH := "user://skills.json"

var inventory: Array[Skill] = []
var active: Skill = null

signal active_changed(new_active: Skill, prev_active: Skill)

func _ready() -> void:
    var turbo := preload("res://skills/turbo.tres") as Skill
    var high_jump := preload("res://skills/high_jump.tres") as Skill
    inventory = [turbo, high_jump]
    _load()

func set_active(skill: Skill) -> void:
    if skill == active:
        return
    var prev := active
    active = skill
    active_changed.emit(active, prev)
    _save()

func get_speed_multiplier() -> float:
    return active.speed_multiplier if active else 1.0

func get_jump_multiplier() -> float:
    return active.jump_multiplier if active else 1.0

func _save() -> void:
    var data := { "active_id": active.id if active else "" }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))

func _load() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var data: Variant = JSON.parse_string(f.get_as_text())
    if not (data is Dictionary):
        return
    var id: String = data.get("active_id", "")
    if id == "":
        return
    for s in inventory:
        if String(s.id) == id:
            active = s
            return
```

Register as autoload via `set_project_setting`:
```
autoload/Skills = "*res://skills/Skills.gd"
```

### 1d. Player coupling — `player/player.gd`

In the horizontal-motion section, replace direct `MOVE_SPEED` use with `_get_move_speed()`:

```gdscript
func _get_move_speed() -> float:
    return MOVE_SPEED * Skills.get_speed_multiplier()

func _get_jump_velocity() -> float:
    return JUMP_VELOCITY * Skills.get_jump_multiplier()
```

Replace every reference to `MOVE_SPEED` in `_physics_process` (and wall-slide / wall-jump where appropriate) with `_get_move_speed()`. Replace `JUMP_VELOCITY` use in jump initiation with `_get_jump_velocity()`. Wall-jump's `WALL_JUMP_VELOCITY.y` should also scale with `Skills.get_jump_multiplier()` so high-jump applies symmetrically:

```gdscript
velocity = Vector2(WALL_JUMP_VELOCITY.x * dir, WALL_JUMP_VELOCITY.y * Skills.get_jump_multiplier())
```

`MOVE_SPEED` and `JUMP_VELOCITY` constants stay — they're the base. Only call sites change.

### 1e. Dev verification (no UI yet)

Quick console check via MCP `execute_game_script`:

```gdscript
Skills.set_active(preload("res://skills/turbo.tres"))
_mcp_print("speed_mult=%s" % Skills.get_speed_multiplier())   # expect 1.5
Skills.set_active(null)
_mcp_print("speed_mult=%s" % Skills.get_speed_multiplier())   # expect 1.0
```

Also play_scene briefly with each active skill to feel-check that turbo really moves faster and high-jump really jumps higher.

**Phase 1 done when:** Skills autoload exists, both `.tres` resources load, player.gd uses `_get_move_speed()` / `_get_jump_velocity()`, the dev-toggle test prints the right multipliers, and a 30-second play-test confirms each skill has the expected effect.

---

## Phase 2 — HUD scaffolding (no drag yet) (~1.5 hr)

### 2a. `hud/SkillCard.tscn` and `hud/SkillCard.gd`

Card shape: rounded panel with name + effect. Aspect ratio leans tall (playing-card-ish). Approximate size: **64w × 88h** (smallish to fit two inventory + one active in the top-right corner without crowding).

Scene tree:
```
SkillCard (Control, custom_minimum_size 64×88)
└── Panel (StyleBoxFlat — corner_radius_all=8, border_width=2, bg_color=skill.color * 0.4)
    └── VBoxContainer (full rect, margin 6px)
        ├── NameLabel (Label, font_size=10, text="TURBO", h_align center)
        └── DescLabel (Label, font_size=8, text="+50% speed", autowrap, h_align center)
```

`SkillCard.gd`:

```gdscript
class_name SkillCard
extends Control

var skill: Skill

@onready var _panel: Panel = $Panel
@onready var _name: Label = $Panel/VBox/NameLabel
@onready var _desc: Label = $Panel/VBox/DescLabel

func bind(s: Skill) -> void:
    skill = s
    _name.text = s.display_name
    _desc.text = s.description
    var sb := _panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
    sb.bg_color = s.color * 0.4
    sb.border_color = s.color
    _panel.add_theme_stylebox_override("panel", sb)
```

### 2b. `hud/SkillCardSlot.tscn` and `hud/SkillCardSlot.gd`

Same outer shape as a SkillCard, but empty by default — a "card-shaped hole". Acts as the drop target.

Scene tree:
```
SkillCardSlot (Control, custom_minimum_size 64×88)
└── EmptyPanel (Panel, StyleBoxFlat — same corner_radius, dashed/dimmed border)
└── (card child appended dynamically when occupied)
```

`SkillCardSlot.gd`:

```gdscript
class_name SkillCardSlot
extends Control

enum SlotKind { INVENTORY, ACTIVE }

@export var kind: SlotKind = SlotKind.INVENTORY

var card: SkillCard = null    # null when empty

func set_card(c: SkillCard) -> void:
    if card and card.get_parent() == self:
        remove_child(card)
    card = c
    if c:
        if c.get_parent():
            c.get_parent().remove_child(c)
        add_child(c)
        c.position = Vector2.ZERO
```

Drag/drop methods come in P3.

### 2c. `hud/SkillsPanel.tscn` and `hud/SkillsPanel.gd`

Top-right anchored. Layout:
```
SkillsPanel (Control, anchors=top-right, margin 12px)
└── VBoxContainer (separation 8)
    ├── ActiveLabel (Label, "ACTIVE", font_size=9, color dim)
    ├── ActiveSlot (SkillCardSlot, kind=ACTIVE)
    ├── Spacer (Control, custom_minimum_size 0×8)
    ├── InventoryLabel (Label, "INVENTORY", font_size=9, color dim)
    └── InventoryRow (HBoxContainer, separation 6)
        ├── InvSlot1 (SkillCardSlot, kind=INVENTORY)
        └── InvSlot2 (SkillCardSlot, kind=INVENTORY)
```

`SkillsPanel.gd`:

```gdscript
extends Control

const SkillCardScene := preload("res://hud/SkillCard.tscn")

@onready var _active_slot: SkillCardSlot = $VBox/ActiveSlot
@onready var _inv_slots: Array[SkillCardSlot] = [
    $VBox/InventoryRow/InvSlot1,
    $VBox/InventoryRow/InvSlot2,
]

func _ready() -> void:
    Skills.active_changed.connect(_rebuild)
    _rebuild()

func _rebuild(_new = null, _prev = null) -> void:
    # Place each inventory skill in an inventory slot; place active skill in active slot.
    # Skills currently in the active slot do not duplicate into inventory.
    for slot in _inv_slots:
        slot.set_card(null)
    _active_slot.set_card(null)

    var inv_idx := 0
    for s in Skills.inventory:
        if s == Skills.active:
            continue
        var card := SkillCardScene.instantiate() as SkillCard
        card.bind(s)
        if inv_idx < _inv_slots.size():
            _inv_slots[inv_idx].set_card(card)
            inv_idx += 1

    if Skills.active:
        var card := SkillCardScene.instantiate() as SkillCard
        card.bind(Skills.active)
        _active_slot.set_card(card)
```

### 2d. Wire SkillsPanel into HUD.tscn

Add SkillsPanel as a sibling of the existing HealthBar margin container, anchored top-right (the HealthBar is top-left). Use MCP `add_scene_instance` with path `res://hud/SkillsPanel.tscn`.

### 2e. Visual sanity check

`play_scene`. Expect:
- Top-right corner shows: ACTIVE label, empty card-shaped slot with dashed border, INVENTORY label, two filled cards (Turbo orange, High Jump purple).
- Cards have rounded corners, distinct color tints, readable text.
- HealthBar still works in the top-left, unaffected.

**Phase 2 done when:** the panel renders correctly, cards show the right names/colors, the active slot looks empty, and the layout doesn't collide with the HealthBar.

---

## Phase 3 — Drag-and-drop logic (~1 hr)

### 3a. `SkillCard._get_drag_data` (source side)

```gdscript
func _get_drag_data(_at_position: Vector2) -> Variant:
    var preview := SkillCardScene.instantiate() as SkillCard
    preview.bind(skill)
    preview.modulate = Color(1, 1, 1, 0.7)
    set_drag_preview(preview)
    return { "card": self, "skill": skill, "source_slot": get_parent() }
```

### 3b. `SkillCardSlot._can_drop_data` and `_drop_data` (target side)

```gdscript
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    return data is Dictionary and data.has("skill")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
    var dropped: Skill = data.skill
    var src: SkillCardSlot = data.source_slot

    if src == self:
        return

    if kind == SlotKind.ACTIVE:
        # Swap: current active (if any) returns to source slot
        var prev_active := Skills.active
        Skills.set_active(dropped)
        # set_active triggers SkillsPanel._rebuild via active_changed signal,
        # which re-places everything cleanly. No manual card moves needed here.
    else:
        # Dropping onto an inventory slot — only meaningful if source is the active slot
        # (i.e., user is deactivating). Otherwise no-op.
        if src.kind == SlotKind.ACTIVE:
            Skills.set_active(null)
```

The whole movement is driven by `Skills.set_active(...)` → `active_changed` signal → `SkillsPanel._rebuild()`. The DOM-style "move this card here" logic stays in one place.

### 3c. Drag threshold safety

`Control._get_drag_data` is only called after Godot's built-in drag threshold (~8 px). For real users this is fine. For the synthetic Recipe A in P5, we already step `STEPS=12` from from→to, so the second motion event easily exceeds 8 px.

### 3d. Manual playtest

1. Drag Turbo from inventory → active. Expect: Turbo card now in active slot, inventory shows only High Jump, player runs faster on next play.
2. Drag High Jump from inventory → active. Expect: swap. Turbo returns to inventory, High Jump is active, player jumps higher.
3. Drag the active card back to an inventory slot. Expect: active slot empty, both cards in inventory, multipliers reset to 1.0.
4. Quit and relaunch. Expect: last active selection persists (e.g., Turbo still active).

**Phase 3 done when:** all four scenarios work in manual playtest.

---

## Phase 4 — Polish (~45 min)

Tunable, taste-driven; surface visual choices to the user during this phase.

- **Drag preview opacity / scale**: currently 70% opacity. Try 80% + slight 1.05× scale on the preview for "lifted" feel.
- **Equipped pulse**: subtle slow pulse on the active-slot card (modulate.a oscillates 0.85 ↔ 1.0 over 1.2s) so it reads as "powered on".
- **Drop flash**: when `_drop_data` succeeds on the active slot, briefly flash the slot border the color of the dropped skill, then fade back.
- **Empty-slot border style**: P2 used a dimmed border. Try a **dashed** border (custom `_draw()` on the empty panel) to read more clearly as "drop here".
- **Card hover lift**: on mouse-over, raise card 2px (`offset.y -= 2`). Reverts on exit.
- **Text legibility**: at 64×88 the description label may be tight. Tune font size or shorten copy.

Open question for the user mid-phase: should the active slot have a glow / particle ring when occupied? Cheap to add, may or may not fit the aesthetic.

**Phase 4 done when:** the user signs off on the visual feel during a brief playtest review.

---

## Phase 5 — QA harness + recipe validation (~1.5 hr)

This phase is the original goal: verify the synthetic-drag recipe from [`research/tools/godot-drag-drop-api.md §3`](../research/tools/godot-drag-drop-api.md) actually works in our project.

### 5a. `tests/run_drag_recipe.gd` — test runner

A GDScript test runner that, when `play_scene` is active, can be invoked via `execute_game_script` with three modes:
- `mode = "recipe_a_turbo"` — drag Turbo from its inventory slot to the active slot
- `mode = "recipe_a_swap"` — drag High Jump on top of active Turbo (tests swap)
- `mode = "recipe_a_deactivate"` — drag active card back to inventory
- `mode = "negative_control"` — same as `recipe_a_turbo` but with `button_mask=0` on motions; expect drag to NOT engage

For each mode, the runner:
1. Resets `Skills.active = null` and waits one frame
2. Resolves source and target slot positions in viewport coordinates via `Control.get_global_rect().get_center()`
3. Runs the canonical Recipe A from the doc, using `Input.parse_input_event` + `Input.use_accumulated_input = false` + `await get_tree().physics_frame`
4. Records assertions: `gui_is_dragging` mid-drag, `gui_is_drag_successful` post-drop, `Skills.active.id` post-drop, observed `_get_move_speed()` value
5. Prints a structured result line: `MODE | dragging_mid=X | drop_ok=Y | active_id=Z | speed_mult=W`

### 5b. Pass criteria

| Mode | Mid-drag `gui_is_dragging` | Post `gui_is_drag_successful` | `Skills.active.id` | `speed_mult` |
|---|---|---|---|---|
| recipe_a_turbo | true | true | "turbo" | 1.5 |
| recipe_a_swap | true | true | "high_jump" | 1.0 |
| recipe_a_deactivate | true | true | "" (empty) | 1.0 |
| negative_control | **false** | false | "" | 1.0 |

The negative-control row is the proof that `button_mask` is load-bearing in the current Godot version.

### 5c. `tests/RESULTS.md` — captured baselines

After all four modes pass, write a short doc:
```markdown
# Drag recipe validation results

| | |
|---|---|
| Validated | 2026-04-26 |
| Godot version | 4.4.x (run `godot --version` to confirm) |
| Recipe source | research/tools/godot-drag-drop-api.md §3 (Recipe A) |
| Project SHA | <commit hash at validation time> |

## Observed output

```
recipe_a_turbo       | dragging_mid=true  | drop_ok=true  | active_id=turbo     | speed_mult=1.5
recipe_a_swap        | dragging_mid=true  | drop_ok=true  | active_id=high_jump | speed_mult=1.0
recipe_a_deactivate  | dragging_mid=true  | drop_ok=true  | active_id=          | speed_mult=1.0
negative_control     | dragging_mid=false | drop_ok=false | active_id=          | speed_mult=1.0
```

## Conclusion

Recipe A works in this project against real Control drag-and-drop UI. `button_mask` is required (negative control fails as predicted). Recipe is safe to lift into a Claude skill.
```

### 5d. Update TESTING.md

Add **Pattern 4 — synthetic drag-and-drop** as a new section, with the recipe verbatim (UI flavor) plus a one-paragraph summary of why each gotcha (`button_mask`, `use_accumulated_input`, single-call discipline) matters. Cross-reference the validated results in `tests/RESULTS.md` and the source recipe doc.

### 5e. (Out of this plan, follow-up) Write the Claude skill

After this plan is complete and TESTING.md is updated, write `~/.claude/skills/godot-drag-test/SKILL.md` lifting Recipe A as a parameterised template. Track as a backlog item, not part of this plan.

**Phase 5 done when:** all four runner modes pass, RESULTS.md is committed, TESTING.md has Pattern 4 added.

---

## Files created

- `skills/Skill.gd` (+ `.uid`)
- `skills/turbo.tres`
- `skills/high_jump.tres`
- `skills/Skills.gd` (+ `.uid`) — autoload
- `hud/SkillCard.tscn`, `hud/SkillCard.gd` (+ `.uid`)
- `hud/SkillCardSlot.tscn`, `hud/SkillCardSlot.gd` (+ `.uid`)
- `hud/SkillsPanel.tscn`, `hud/SkillsPanel.gd` (+ `.uid`)
- `tests/run_drag_recipe.gd` (+ `.uid`)
- `tests/RESULTS.md`

## Files modified

- `player/player.gd` — switch `MOVE_SPEED` and `JUMP_VELOCITY` reads to `_get_move_speed()` / `_get_jump_velocity()`; add the two helpers.
- `hud/HUD.tscn` — add SkillsPanel anchored top-right.
- `project.godot` — register `Skills` autoload (via `set_project_setting`, never edit the file directly).
- `TESTING.md` — add Pattern 4 in P5d.

## Files NOT modified

- `World.gd`, `World.tscn` — no change; HUD already lives there.
- `camera/`, `doors/`, `rooms/` — unrelated.
- `audio/AudioManager.gd` — no SFX wired this round (deferred to backlog).
- The existing `hud/HealthBar.gd` and HEALTH stack — unaffected.

## Explicitly out of scope

- **Pickup system** — skills are pre-loaded, not found in world. Forward-compatible: change is "remove preload from `Skills._ready` and let pickups insert into `inventory` on collect".
- **Cooldowns / limited uses** — skills are persistent passives.
- **Multiple active skills** — single active slot only.
- **Sound effects** — equip/swap/deactivate SFX deferred to audio backlog.
- **Drag animations between slots** — cards snap on `_rebuild()`. Tween animations could come later.
- **Death-system impact** — skills persist across deaths for now. Final rule depends on game-style decision (rogue-like / Metroid / etc).
- **Skill icons / artwork** — text-only cards in this plan; richer graphics later.
- **Inventory > 2 cards** — UI assumes exactly 2 inventory slots. Future expansion needs a layout change.
- **Touch / mobile drag** — desktop-mouse-only. `InputEventScreenTouch` would be a separate pass.

---

## How execution should run

1. **P1 first.** Validate data + multipliers via dev-toggle before any UI exists. This is the load-bearing layer; if it's wrong, P2-P5 are wasted.
2. **P2.** Get the panel rendering correctly with no drag interaction. Confirm visually.
3. **P3.** Add drag/drop methods. Manual-test all four scenarios (active, swap, deactivate, persist).
4. **P4.** Polish pass — surface visual choices to the user.
5. **P5.** Build the test runner, verify all four modes including the negative control. **Do not skip the negative control** — it's the proof point that justifies the skill.

Commit after each phase. Plan archives to `plans/done/skill-cards.md` per CLAUDE.md rules when P5 completes (recipe validated, RESULTS.md committed, TESTING.md updated).

## Open questions for the user mid-flight

- **Card size** — 64×88 is a guess. May feel cramped or oversized once visible. Tune in P2 / P4.
- **Color choices** — orange Turbo / purple High Jump are placeholders. User may want different palettes (e.g., Turbo red, High Jump green).
- **Active-slot pulse / glow** — yes/no aesthetic call in P4.
- **Should "ACTIVE" / "INVENTORY" labels stay**, or is the layout self-explanatory? Decide in P4.
- **If P5's negative control unexpectedly PASSES** (i.e. drag works without `button_mask`), that means our Godot version's GUI dispatcher has changed since GUT issue #608 was filed. Investigate before lifting to a skill — the recipe may be over-cautious.
