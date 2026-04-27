extends Node

# Permanent movement abilities (granted by pickups). Always-on once acquired.
# Surfaced via the HUD ability strip and read by player.gd to gate movement
# features (dash, double_jump, ...).
#
# Distinct from the Skills autoload — Skills holds the active card buff
# (ephemeral, swappable). Inventory holds permanent ability ownership.
# See plans/done/pickups.md for the design rationale.
#
# Persistence: deliberately NONE. Until a real save system exists
# (backlog/gamedev.md #10), Inventory state is per-run only — exit and
# restart wipes it. This is intentional so the pickup-grant loop can be
# play-tested fresh every session. When the save system lands, restore
# the FileAccess persistence pattern (the original implementation lived
# in commit 39dca7c if needed as reference) and gate it on a save slot.

var owned: Dictionary = {}  # StringName -> true

signal ability_granted(id: StringName)


func has(id: StringName) -> bool:
	return owned.get(id, false)


# Permanent jump multiplier from owned movement abilities. Currently only
# &"high_jump" contributes (1.5x). When more jump-affecting abilities land,
# move the per-ability multiplier into abilities.gd's REGISTRY entry.
func get_jump_multiplier() -> float:
	return 1.5 if has(&"high_jump") else 1.0


func grant(id: StringName) -> void:
	if not Abilities.has_ability(id):
		push_warning("Inventory.grant: unknown ability id %s" % id)
		return
	if owned.get(id, false):
		return
	owned[id] = true
	ability_granted.emit(id)


# Debug helper — clears all owned abilities. Used during development to test
# the pickup loop from a fresh state mid-session.
func _debug_clear() -> void:
	owned = {}
