extends Control

# Bottom-of-screen iconographic strip showing all defined movement abilities,
# grouped by category (Jumps / Runs / Climbs). Locked = greyed silhouette;
# unlocked = full color + faint glow. Just-acquired = scale-pop animation.
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

# id -> ColorRect, used to update visual state on grant
var _icons: Dictionary = {}


func _ready() -> void:
	_build()
	var inv := get_node_or_null("/root/Inventory")
	if inv:
		# Named-method connection per intel-crawl §4.2 (lambda signal connections
		# silently multiply on scene reload — use named methods for autoload signals).
		inv.ability_granted.connect(_on_ability_granted)
	_refresh_all()


func _build() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(SECTION_GAP))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(row)

	for cat_idx in [0, 1, 2]:
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 4)
		row.add_child(col)

		var title := Label.new()
		title.text = _CATEGORY_TITLES[cat_idx]
		title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
		title.add_theme_color_override("font_color", TITLE_COLOR)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(title)

		var icon_row := HBoxContainer.new()
		icon_row.alignment = BoxContainer.ALIGNMENT_CENTER
		icon_row.add_theme_constant_override("separation", int(ICON_GAP))
		col.add_child(icon_row)

		var ids: Array[StringName] = Abilities.ids_in_category(cat_idx)
		for id in ids:
			icon_row.add_child(_make_icon(id, cat_idx))


func _make_icon(id: StringName, cat_idx: int) -> Control:
	var cell := VBoxContainer.new()
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.add_theme_constant_override("separation", 2)

	var box := ColorRect.new()
	box.custom_minimum_size = ICON_SIZE
	box.color = LOCKED_COLOR
	box.set_meta("category_color", _CATEGORY_HUE[cat_idx])
	box.set_meta("ability_id", id)
	box.pivot_offset = ICON_SIZE * 0.5
	cell.add_child(box)

	var caption := Label.new()
	caption.text = _short_label(Abilities.display_name(id))
	caption.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	caption.add_theme_color_override("font_color", TITLE_COLOR)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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


func _apply_state(id: StringName, owned: bool, animate: bool) -> void:
	var box: ColorRect = _icons.get(id, null)
	if box == null:
		return
	if owned:
		box.color = box.get_meta("category_color", Color.WHITE)
	else:
		box.color = LOCKED_COLOR
	if animate and owned:
		_play_pop(box)


func _play_pop(box: ColorRect) -> void:
	box.scale = Vector2.ONE
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(box, "scale", Vector2(1.4, 1.4), POP_DURATION * 0.4)
	tween.tween_property(box, "scale", Vector2(1.0, 1.0), POP_DURATION * 0.6)


func _on_ability_granted(id: StringName) -> void:
	_apply_state(id, true, true)
