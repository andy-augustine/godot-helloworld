extends Node

# Drag-recipe validation runner.
#
# Two modes:
#
# 1. run_all() — direct mode: invokes target_slot._can_drop_data / _drop_data
#    directly. Fast, deterministic, doesn't exercise GUI hit-test or state
#    machine. Validates slot routing rules (ACTIVE vs INVENTORY, swap,
#    deactivate, inv→inv reject, same-slot reject).
#
# 2. The synthetic-drag mode is invoked from outside this runner via the
#    godot-mcp-pro simulate_sequence MCP tool. See tests/RESULTS.md for the
#    working JSON recipe; the key gotchas are:
#      - relative_x / relative_y MUST be populated on every motion event
#        (Godot's drag-detection threshold accumulates relative deltas)
#      - unhandled: false MUST be set explicitly on every motion event
#        (otherwise the addon auto-promotes to push_input(event, true)
#        which interferes with normal GUI hit-testing)
#      - frame_delay >= 1 so events spread across frames
#    Two local addon patches are also required — see TESTING.md Pattern 4.
#
# Invoke direct mode via execute_game_script:
#   var R = load("res://tests/run_drag_recipe.gd").new()
#   get_tree().root.add_child(R)
#   for line in R.run_all(): _mcp_print(line)
#   R.queue_free()

func run_all() -> Array:
	var panel: Node = get_tree().root.get_node("World/HUD/SkillsPanel")
	var inv1: Node = panel.get_node("VBox/InventoryRow/InvSlot1")
	var inv2: Node = panel.get_node("VBox/InventoryRow/InvSlot2")
	var active: Node = panel.get_node("VBox/ActiveSlot")
	var results: Array = []

	# Reset
	Skills.set_active(null)
	results.append(_snapshot("baseline", inv1, inv2, active))

	# Mode 1: equip turbo (drop inv1=turbo into empty active)
	var d1: Dictionary = { "skill": inv1.card.skill, "source_slot": inv1 }
	results.append("mode1 (equip turbo): can_drop=%s" % active._can_drop_data(Vector2.ZERO, d1))
	active._drop_data(Vector2.ZERO, d1)
	results.append(_snapshot("after mode1", inv1, inv2, active))

	# Mode 2: swap (drop inv1=high_jump onto active=turbo)
	var d2: Dictionary = { "skill": inv1.card.skill, "source_slot": inv1 }
	results.append("mode2 (swap to high_jump): can_drop=%s" % active._can_drop_data(Vector2.ZERO, d2))
	active._drop_data(Vector2.ZERO, d2)
	results.append(_snapshot("after mode2", inv1, inv2, active))

	# Mode 3: deactivate (drop active card back into inv1)
	var d3: Dictionary = { "skill": active.card.skill, "source_slot": active }
	results.append("mode3 (deactivate): can_drop=%s" % inv1._can_drop_data(Vector2.ZERO, d3))
	inv1._drop_data(Vector2.ZERO, d3)
	results.append(_snapshot("after mode3", inv1, inv2, active))

	# Mode 4 (negative): inv → inv must be rejected
	var d4: Dictionary = { "skill": inv1.card.skill, "source_slot": inv1 }
	results.append("mode4 (inv1→inv2 reject): can_drop=%s (expect false)" % inv2._can_drop_data(Vector2.ZERO, d4))

	# Mode 4b (negative): same-slot must be rejected
	results.append("mode4b (inv1→inv1 reject): can_drop=%s (expect false)" % inv1._can_drop_data(Vector2.ZERO, d4))

	Skills.set_active(null)
	return results


func _snapshot(label: String, inv1: Node, inv2: Node, active: Node) -> String:
	return "%s: active=%s | inv1=%s | inv2=%s | speed=%.1f | jump=%.1f" % [
		label,
		"-" if Skills.active == null else String(Skills.active.id),
		"-" if inv1.card == null else String(inv1.card.skill.id),
		"-" if inv2.card == null else String(inv2.card.skill.id),
		Skills.get_speed_multiplier(),
		Skills.get_jump_multiplier(),
	]
