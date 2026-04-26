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


func _apply_visuals() -> void:
	_name_label.text = skill.display_name
	_desc_label.text = skill.description
	var sb := StyleBoxFlat.new()
	sb.bg_color = skill.color.darkened(0.6)
	sb.border_color = skill.color
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	_panel.add_theme_stylebox_override("panel", sb)
