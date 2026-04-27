extends Node

# Skill state, autoloaded so player.gd and the HUD both read from one place.
# Inventory is fixed for now (player starts with both Turbo and High Jump);
# active slot is the only mutable state. Persists active selection to
# user://skills.json so it survives quit/relaunch. Death-system impact on the
# active slot is deferred — depends on the eventual game style.
#
# See plans/done/skill-cards.md for design rationale.
#
# ── Future direction (queued, not yet implemented) ─────────────────────────────
# This autoload is being repurposed for WEAPON SWAP. The drag-and-drop card UI
# in hud/SkillsPanel etc. is the right substrate for "swap which weapon is
# wielded" — an active choice the player makes mid-combat — but it is wrong
# for permanent movement abilities (dash, double-jump, wall-climb), which the
# genre demands be always-on. Movement abilities now live in the Inventory
# autoload (inventory/Inventory.gd), surfaced via the HUD AbilityStrip.
#
# The existing turbo / high_jump cards remain functional as a bridge artifact —
# they are passive multipliers (speed / jump height), close enough to "weapon-
# like" that they aren't doing harm. When a real weapon system lands, they get
# migrated to Inventory (always-on once acquired) and Skill becomes Weapon.
# Tracked at backlog/gamedev.md "Migrate turbo/high_jump from Skills to
# Inventory".

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
