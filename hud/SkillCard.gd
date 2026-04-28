class_name SkillCard
extends Control

# A single skill card. bind() is safe to call before or after the node enters
# the tree — visuals apply on _ready if bind() ran early.

const PULSE_PERIOD: float = 1.4   # seconds for one pulse cycle on equipped cards
const PULSE_MIN_ALPHA: float = 0.82
const HOVER_LIFT: float = 2.0
const HOVER_TWEEN_TIME: float = 0.08

var skill: Skill
var _equipped: bool = false       # true if our parent slot is the ACTIVE one
var _hover_tween: Tween = null

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
	# Detect whether we're parked in the active slot — drives the equipped pulse.
	var parent_slot := get_parent() as SkillCardSlot
	_equipped = parent_slot != null and parent_slot.kind == SkillCardSlot.SlotKind.ACTIVE
	set_process(_equipped)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	# Equipped pulse: modulate.a oscillates over PULSE_PERIOD so the card reads
	# as "powered on". Only runs when _equipped is true (set in _ready).
	var t: float = Time.get_ticks_msec() / 1000.0
	var phase: float = sin(t * 2.0 * PI / PULSE_PERIOD) * 0.5 + 0.5  # 0..1
	modulate.a = lerp(PULSE_MIN_ALPHA, 1.0, phase)


func _on_mouse_entered() -> void:
	if _hover_tween: _hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "position:y", -HOVER_LIFT, HOVER_TWEEN_TIME)


func _on_mouse_exited() -> void:
	if _hover_tween: _hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "position:y", 0.0, HOVER_TWEEN_TIME)


func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := duplicate() as Control
	preview.modulate = Color(1.0, 1.0, 1.0, 0.85)
	preview.scale = Vector2(1.05, 1.05)
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
	# Cards shrunk to 44x32; long descriptions don't fit. Skill resources now
	# carry a tight short_desc (e.g. "+50%"); fall back to the verbose one if
	# unset so legacy cards still render.
	_desc_label.text = skill.short_desc if skill.short_desc != "" else skill.description
	# Duplicate the inspector-set StyleBoxFlat so per-card color tints don't
	# mutate the shared scene resource. Static styling (corner_radius,
	# border_width) lives on the Panel in SkillCard.tscn — tweak there.
	var sb := _panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.bg_color = skill.color.darkened(0.6)
	sb.border_color = skill.color
	_panel.add_theme_stylebox_override("panel", sb)
