extends Node

# Permanent movement abilities (granted by pickups). Always-on once acquired.
# Persisted to user://inventory.json. Surfaced via the HUD ability strip and
# read by player.gd to gate movement features (dash, double_jump, ...).
#
# Distinct from the Skills autoload — Skills holds the active card buff
# (ephemeral, swappable). Inventory holds permanent ability ownership.
# See plans/done/pickups.md for the design rationale.

const SAVE_PATH := "user://inventory.json"

var owned: Dictionary = {}  # StringName -> true

signal ability_granted(id: StringName)


func _ready() -> void:
	_load()


func has(id: StringName) -> bool:
	return owned.get(id, false)


func grant(id: StringName) -> void:
	if not Abilities.has_ability(id):
		push_warning("Inventory.grant: unknown ability id %s" % id)
		return
	if owned.get(id, false):
		return
	owned[id] = true
	ability_granted.emit(id)
	_save()


# Debug helper — clears all owned abilities. Used during development to test
# the pickup loop from a fresh state without manually editing the save file.
func _debug_clear() -> void:
	owned = {}
	_save()


func _save() -> void:
	var ids: Array[String] = []
	for k in owned.keys():
		ids.append(String(k))
	var data := { "owned": ids }
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if not (data is Dictionary):
		return
	var raw: Variant = (data as Dictionary).get("owned", [])
	if not (raw is Array):
		return
	for entry in (raw as Array):
		if entry is String and Abilities.has_ability(StringName(entry)):
			owned[StringName(entry)] = true
