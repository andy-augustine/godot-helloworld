extends Control

# Top-of-screen iconographic strip showing all defined movement abilities,
# grouped by category (Jumps / Runs / Climbs). Locked = greyed silhouette;
# unlocked = full color + glow. Just-acquired plays the swirl-and-smack
# sequence (PickupTornado → dramatic slot pulse → skill_acquired SFX).
#
# The list is driven by Abilities.REGISTRY — adding a new ability there makes
# it appear here automatically. Live state comes from the Inventory autoload.

const ICON_SIZE := Vector2(28, 28)
const ICON_GAP: float = 6.0
const SECTION_GAP: float = 28.0
const LABEL_FONT_SIZE: int = 8
const TITLE_FONT_SIZE: int = 9
const TITLE_COLOR := Color(0.85, 0.9, 0.95, 0.7)
const POP_DURATION: float = 0.35

# Dramatic pulse on landing — 3x scale + color flash + return.
const PULSE_PEAK_SCALE: float = 3.0
const PULSE_UP_DURATION: float = 0.18
const PULSE_DOWN_DURATION: float = 0.45

const _CATEGORY_TITLES := {
	0: "JUMPS",   # Abilities.Category.JUMPS
	1: "RUNS",    # Abilities.Category.RUNS
	2: "CLIMBS",  # Abilities.Category.CLIMBS
}

const _CATEGORY_HUE := {
	0: Color("9b6cff"),  # Jumps — purple
	1: Color("ff8c1a"),  # Runs  — orange
	2: Color("4ad6c2"),  # Climbs— teal
}

# id -> Control (slot container, 28x28). Pulse animation scales this; the
# locked "hole" Panel and the unlocked "raised" stack of ColorRects both live
# inside it and are toggled via visibility on grant.
var _icons: Dictionary = {}
# id -> Node2D (icon holder for ability symbol polygons; lives inside the
# raised stack so it's hidden when the ability is locked)
var _icon_holders: Dictionary = {}
# id -> Panel (the dark recessed "hole" visible while the ability is locked)
var _holes: Dictionary = {}
# id -> Control (the raised pickup-style stack visible once the ability is
# unlocked — outline + body + highlight + inner glow)
var _raised: Dictionary = {}


func _ready() -> void:
	add_to_group("ability_strip")
	_build()
	var inv := get_node_or_null("/root/Inventory")
	if inv:
		# Named-method connection per intel-crawl §4.2 (lambda signal connections
		# silently multiply on scene reload — use named methods for autoload signals).
		inv.ability_granted.connect(_on_ability_granted)
	_refresh_all()


# Used by Pickup.gd to compute the world-space target the pickup should fly to
# at the end of its swirl animation. Returns screen-space (HUD) coordinates;
# Pickup converts via the camera transform.
func get_slot_screen_position(id: StringName) -> Vector2:
	var slot: Control = _icons.get(id, null)
	if slot == null:
		return Vector2.ZERO
	return slot.global_position + slot.size * 0.5


func _build() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(SECTION_GAP))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# IGNORE so this fullscreen-width HBox doesn't intercept drags meant for
	# the SkillsPanel slots underneath it. Without this, pickups can't be
	# dragged from inventory → active because the row consumes the events.
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	for cat_idx in [0, 1, 2]:
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_theme_constant_override("separation", 4)
		row.add_child(col)

		var title := Label.new()
		title.text = _CATEGORY_TITLES[cat_idx]
		title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
		title.add_theme_color_override("font_color", TITLE_COLOR)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(title)

		var icon_row := HBoxContainer.new()
		icon_row.alignment = BoxContainer.ALIGNMENT_CENTER
		icon_row.add_theme_constant_override("separation", int(ICON_GAP))
		icon_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(icon_row)

		var ids: Array[StringName] = Abilities.ids_in_category(cat_idx)
		for id in ids:
			icon_row.add_child(_make_icon(id, cat_idx))


func _make_icon(id: StringName, cat_idx: int) -> Control:
	var cell := VBoxContainer.new()
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.add_theme_constant_override("separation", 2)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Slot container — the pulse animation scales this whole node so both the
	# hole and the raised stack scale together. Pivot at center for clean pulse.
	var slot := Control.new()
	slot.custom_minimum_size = ICON_SIZE
	slot.set_meta("category_color", _CATEGORY_HUE[cat_idx])
	slot.set_meta("ability_id", id)
	slot.pivot_offset = ICON_SIZE * 0.5
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(slot)

	# LOCKED visual: a dark recessed "hole". Black bg with a slightly-darker
	# top+left rim simulates light blocked from above (inset depth cue).
	var hole := Panel.new()
	hole.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hole.add_theme_stylebox_override("panel", _make_hole_stylebox())
	hole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(hole)
	_holes[id] = hole

	# UNLOCKED visual: layered ColorRects mirroring Pickup.tscn's structure
	# (outline / body / highlight / inner-glow) so the slot reads as the same
	# pickup the player just collected, now seated "above ground" in its slot.
	var raised := Control.new()
	raised.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raised.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raised.visible = false
	slot.add_child(raised)
	_raised[id] = raised

	var hue: Color = _CATEGORY_HUE[cat_idx]
	# Outline (full footprint)
	var outline := ColorRect.new()
	outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outline.color = hue.darkened(0.5)
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raised.add_child(outline)
	# Body (24x24 inset by 2px on every edge)
	var body := ColorRect.new()
	body.position = Vector2(2, 2)
	body.size = Vector2(24, 24)
	body.color = hue
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raised.add_child(body)
	# Highlight (small accent top-left to read as 3D)
	var highlight := ColorRect.new()
	highlight.position = Vector2(4, 4)
	highlight.size = Vector2(8, 4)
	highlight.color = Color(hue.lightened(0.45).r, hue.lightened(0.45).g, hue.lightened(0.45).b, 0.95)
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raised.add_child(highlight)
	# Inner glow (faint warm wash inside the body)
	var inner_glow := ColorRect.new()
	inner_glow.position = Vector2(6, 12)
	inner_glow.size = Vector2(16, 8)
	inner_glow.color = Color(hue.lightened(0.25).r, hue.lightened(0.25).g, hue.lightened(0.25).b, 0.5)
	inner_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raised.add_child(inner_glow)

	# Symbolic icon polygons centered on the raised body.
	var icon_holder: Node2D = Node2D.new()
	icon_holder.position = ICON_SIZE * 0.5
	raised.add_child(icon_holder)
	AbilityIcons.build_into(icon_holder, id, hue.lightened(0.55), 0.7)
	_icon_holders[id] = icon_holder

	var caption := Label.new()
	caption.text = _short_label(Abilities.display_name(id))
	caption.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	caption.add_theme_color_override("font_color", TITLE_COLOR)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(caption)

	_icons[id] = slot
	return cell


func _make_hole_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.03, 0.05, 0.95)
	sb.border_width_top = 1
	sb.border_width_left = 1
	sb.border_color = Color(0, 0, 0, 0.85)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_bottom_left = 4
	return sb


# DASH stays DASH; DOUBLE JUMP -> 2X JMP; HIGH JUMP -> HI JMP; WALL CLIMB -> WLL CLM.
# Avoids long captions overflowing the 28px icon width.
func _short_label(full_name: String) -> String:
	match full_name:
		"DOUBLE JUMP": return "2X JMP"
		"HIGH JUMP": return "HI JMP"
		"WALL CLIMB": return "WLL CLM"
		_: return full_name


func _refresh_all() -> void:
	var inv := get_node_or_null("/root/Inventory")
	if inv == null:
		return
	for id in _icons.keys():
		_apply_state(id, inv.has(id), false)


func _apply_state(id: StringName, owned: bool, _animate: bool) -> void:
	var hole: Panel = _holes.get(id, null)
	var raised: Control = _raised.get(id, null)
	if hole:
		hole.visible = not owned
	if raised:
		raised.visible = owned


func _on_ability_granted(id: StringName) -> void:
	# By the time this fires, the Pickup has finished its swirl-and-fly
	# animation (Pickup grants only on landing). Light up the slot, play
	# the reward SFX, run the dramatic pulse.
	var slot: Control = _icons.get(id, null)
	if slot == null:
		return
	_apply_state(id, true, false)
	AudioManager.play_sfx("skill_acquired", 0.04, -2.0)
	_play_dramatic_pulse(slot)


func _play_dramatic_pulse(box: Control) -> void:
	box.scale = Vector2.ONE
	box.modulate = Color.WHITE
	# Up: scale to 3.0, modulate white-bright
	var up_tween: Tween = create_tween()
	up_tween.set_parallel(true)
	up_tween.set_trans(Tween.TRANS_BACK)
	up_tween.set_ease(Tween.EASE_OUT)
	up_tween.tween_property(box, "scale", Vector2(PULSE_PEAK_SCALE, PULSE_PEAK_SCALE), PULSE_UP_DURATION)
	up_tween.tween_property(box, "modulate", Color(1.8, 1.8, 1.8, 1), PULSE_UP_DURATION * 0.6)
	# Down: scale + color back to normal
	up_tween.chain()
	up_tween.set_parallel(true)
	up_tween.set_trans(Tween.TRANS_QUAD)
	up_tween.set_ease(Tween.EASE_IN_OUT)
	up_tween.tween_property(box, "scale", Vector2.ONE, PULSE_DOWN_DURATION)
	up_tween.tween_property(box, "modulate", Color.WHITE, PULSE_DOWN_DURATION)
