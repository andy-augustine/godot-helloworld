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
const LOCKED_COLOR := Color(0.35, 0.38, 0.45, 0.6)
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

# id -> ColorRect (slot background); used to update visual state on grant
var _icons: Dictionary = {}
# id -> Node2D (icon holder for ability symbol polygons)
var _icon_holders: Dictionary = {}


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
	var box: ColorRect = _icons.get(id, null)
	if box == null:
		return Vector2.ZERO
	return box.global_position + box.size * 0.5


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

	var box := ColorRect.new()
	box.custom_minimum_size = ICON_SIZE
	box.color = LOCKED_COLOR
	box.set_meta("category_color", _CATEGORY_HUE[cat_idx])
	box.set_meta("ability_id", id)
	box.pivot_offset = ICON_SIZE * 0.5
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(box)

	# Symbolic icon polygons centered in the box. Locked state hides them
	# (modulate alpha 0); unlocked shows them in the category hue lightened.
	var icon_holder: Node2D = Node2D.new()
	icon_holder.position = ICON_SIZE * 0.5
	icon_holder.modulate = Color(1, 1, 1, 0)  # hidden until unlocked
	box.add_child(icon_holder)
	AbilityIcons.build_into(icon_holder, id, _CATEGORY_HUE[cat_idx].lightened(0.55), 0.7)
	_icon_holders[id] = icon_holder

	var caption := Label.new()
	caption.text = _short_label(Abilities.display_name(id))
	caption.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	caption.add_theme_color_override("font_color", TITLE_COLOR)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(caption)

	_icons[id] = box
	return cell


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
	var box: ColorRect = _icons.get(id, null)
	if box == null:
		return
	var holder: Node2D = _icon_holders.get(id, null)
	if owned:
		box.color = box.get_meta("category_color", Color.WHITE)
		if holder:
			holder.modulate = Color(1, 1, 1, 1)
	else:
		box.color = LOCKED_COLOR
		if holder:
			holder.modulate = Color(1, 1, 1, 0)


func _on_ability_granted(id: StringName) -> void:
	# By the time this fires, the Pickup has finished its swirl-and-fly
	# animation (Pickup grants only on landing). Light up the slot, play
	# the reward SFX, run the dramatic pulse.
	var box: ColorRect = _icons.get(id, null)
	if box == null:
		return
	_apply_state(id, true, false)
	AudioManager.play_sfx("skill_acquired", 0.04, -2.0)
	_play_dramatic_pulse(box)


func _play_dramatic_pulse(box: ColorRect) -> void:
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
