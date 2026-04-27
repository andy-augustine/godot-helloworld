class_name SkillCardSlot
extends Control

# A card-shaped drop zone. Holds at most one SkillCard at a time. The empty
# panel is shown when no card is parked here. Drag-and-drop wiring comes in P3.

enum SlotKind { INVENTORY, ACTIVE }

@export var kind: SlotKind = SlotKind.INVENTORY

var card: SkillCard = null

@onready var _empty_panel: Panel = $EmptyPanel


func _ready() -> void:
	_refresh_empty_visibility()


func set_card(c: SkillCard) -> void:
	if card and card.get_parent() == self:
		remove_child(card)
		card.queue_free()
	card = c
	if c:
		if c.get_parent():
			c.get_parent().remove_child(c)
		add_child(c)
		c.position = Vector2.ZERO
	_refresh_empty_visibility()


func _refresh_empty_visibility() -> void:
	if is_node_ready():
		_empty_panel.visible = card == null


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.has("skill") and data.has("source_slot")):
		return false
	var src: SkillCardSlot = data.source_slot
	if src == self:
		return false
	# Inventory-to-inventory drags are a no-op; reject so the cursor reads "no drop"
	if kind == SlotKind.INVENTORY and src.kind == SlotKind.INVENTORY:
		return false
	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var dropped: Skill = data.skill
	var src: SkillCardSlot = data.source_slot

	if kind == SlotKind.ACTIVE:
		# Equip (or swap, if active slot was occupied — Skills.set_active +
		# active_changed → SkillsPanel._rebuild handles the card movement)
		Skills.set_active(dropped)
		_flash(dropped.color)
	elif src.kind == SlotKind.ACTIVE:
		# Drag-back from active to inventory — deactivate
		Skills.set_active(null)
		_flash(Color(0.7, 0.7, 0.75))


# Brief modulate flash on drop in the dropped skill's color, fading back to
# white over ~0.4s. Tints the slot + card together (modulate composes).
func _flash(color: Color) -> void:
	modulate = color
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.4)
