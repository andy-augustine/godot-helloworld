class_name Abilities
extends RefCounted

# Static registry of all defined movement abilities.
# Used by Inventory (validation) and the HUD AbilityStrip (rendering).
# Add a new ability here, then either pickup-grant it via Inventory.grant
# or wire its mechanic in player.gd. The HUD strip auto-renders new entries
# in their declared category.

enum Category { JUMPS, RUNS, CLIMBS }

const REGISTRY: Dictionary = {
	&"dash": {
		"display_name": "DASH",
		"category": Category.RUNS,
		"icon_path": "",
	},
	&"double_jump": {
		"display_name": "DOUBLE JUMP",
		"category": Category.JUMPS,
		"icon_path": "",
	},
	&"wall_climb": {
		"display_name": "WALL CLIMB",
		"category": Category.CLIMBS,
		"icon_path": "",
	},
	&"turbo": {
		"display_name": "TURBO",
		"category": Category.RUNS,
		"icon_path": "",
	},
	&"high_jump": {
		"display_name": "HIGH JUMP",
		"category": Category.JUMPS,
		"icon_path": "",
	},
}


static func has_ability(id: StringName) -> bool:
	return REGISTRY.has(id)


static func display_name(id: StringName) -> String:
	if not REGISTRY.has(id):
		return String(id)
	return REGISTRY[id].get("display_name", String(id))


static func category(id: StringName) -> int:
	if not REGISTRY.has(id):
		return -1
	return REGISTRY[id].get("category", -1)


static func ids_in_category(cat: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in REGISTRY.keys():
		if REGISTRY[id].get("category", -1) == cat:
			out.append(id)
	return out
