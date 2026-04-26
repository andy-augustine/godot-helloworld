extends Control

# Top-right HUD panel: 1 active slot + 2 inventory slots. Subscribes to
# Skills.active_changed and rebuilds card placement on every change.
# Source of truth is Skills (autoload) — this view is stateless.

const SkillCardScene := preload("res://hud/SkillCard.tscn")

@onready var _active_slot: SkillCardSlot = $VBox/ActiveSlot
@onready var _inv_slots: Array[SkillCardSlot] = [
	$VBox/InventoryRow/InvSlot1,
	$VBox/InventoryRow/InvSlot2,
]


func _ready() -> void:
	Skills.active_changed.connect(_on_active_changed)
	_rebuild()


func _on_active_changed(_new: Skill, _prev: Skill) -> void:
	_rebuild()


func _rebuild() -> void:
	for slot in _inv_slots:
		slot.set_card(null)
	_active_slot.set_card(null)

	var inv_idx := 0
	for s in Skills.inventory:
		if s == Skills.active:
			continue
		if inv_idx >= _inv_slots.size():
			break
		var card := SkillCardScene.instantiate() as SkillCard
		card.bind(s)
		_inv_slots[inv_idx].set_card(card)
		inv_idx += 1

	if Skills.active:
		var card := SkillCardScene.instantiate() as SkillCard
		card.bind(Skills.active)
		_active_slot.set_card(card)
