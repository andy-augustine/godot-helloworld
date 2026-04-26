class_name SkillCard
extends Control

# A single skill card. bind() is safe to call before or after the node enters
# the tree — visuals apply on _ready if bind() ran early.

var skill: Skill

@onready var _panel: Panel = $Panel
@onready var _name_label: Label = $Panel/VBox/NameLabel
@onready var _desc_label: Label = $Panel/VBox/DescLabel


func bind(s: Skill) -> void:
	skill = s
	if is_node_ready():
		_apply_visuals()


func _ready() -> void:
	if skill:
		_apply_visuals()


func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := duplicate() as Control
	preview.modulate = Color(1.0, 1.0, 1.0, 0.7)
	set_drag_preview(preview)
	return { "skill": skill, "source_slot": get_parent() }


# Forward drops to the parent slot. When the active slot is occupied, the card
# is the topmost hit under the cursor — without these forwarders, swap is
# impossible because Godot would only consult SkillCard for _can_drop_data.
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var slot := get_parent() as SkillCardSlot
	return slot._can_drop_data(at_position, data) if slot else false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var slot := get_parent() as SkillCardSlot
	if slot:
		slot._drop_data(at_position, data)


func _apply_visuals() -> void:
	_name_label.text = skill.display_name
	_desc_label.text = skill.description
	# Duplicate the inspector-set StyleBoxFlat so per-card color tints don't
	# mutate the shared scene resource. Static styling (corner_radius,
	# border_width) lives on the Panel in SkillCard.tscn — tweak there.
	var sb := _panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.bg_color = skill.color.darkened(0.6)
	sb.border_color = skill.color
	_panel.add_theme_stylebox_override("panel", sb)
