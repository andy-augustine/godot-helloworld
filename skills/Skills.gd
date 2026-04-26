extends Node

# Skill state, autoloaded so player.gd and the HUD both read from one place.
# Inventory is fixed for now (player starts with both Turbo and High Jump);
# active slot is the only mutable state. Persists active selection to
# user://skills.json so it survives quit/relaunch. Death-system impact on the
# active slot is deferred — depends on the eventual game style.
#
# See plans/skill-cards.md for design rationale.

const SAVE_PATH := "user://skills.json"

var inventory: Array[Skill] = []
var active: Skill = null

signal active_changed(new_active: Skill, prev_active: Skill)

func _ready() -> void:
	var turbo := Skill.new()
	turbo.id = &"turbo"
	turbo.display_name = "TURBO"
	turbo.description = "+50% top speed"
	turbo.color = Color("ff8c1a")
	turbo.speed_multiplier = 1.5
	turbo.jump_multiplier = 1.0

	var high_jump := Skill.new()
	high_jump.id = &"high_jump"
	high_jump.display_name = "HIGH JUMP"
	high_jump.description = "+50% jump height"
	high_jump.color = Color("9b6cff")
	high_jump.speed_multiplier = 1.0
	high_jump.jump_multiplier = 1.5

	inventory = [turbo, high_jump]
	_load()


func set_active(skill: Skill) -> void:
	if skill == active:
		return
	var prev := active
	active = skill
	active_changed.emit(active, prev)
	_save()


func get_speed_multiplier() -> float:
	return active.speed_multiplier if active else 1.0


func get_jump_multiplier() -> float:
	return active.jump_multiplier if active else 1.0


func _save() -> void:
	var data := { "active_id": String(active.id) if active else "" }
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
	var id: String = data.get("active_id", "")
	if id == "":
		return
	for s in inventory:
		if String(s.id) == id:
			active = s
			return
