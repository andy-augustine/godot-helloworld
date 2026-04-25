@tool
class_name Door
extends Area2D

# Trigger that fires when the player overlaps it. Carries metadata about
# where this door leads. Lives as a child of a Room scene.
#
# Inspector fields (set per door instance, no code change needed):
#   target_room_path  — file picker; the .tscn of the destination room
#   target_door_name  — node name of the matching door in that room (must exist)
#   direction         — Vector2 the player exits through ((1,0) east, (-1,0) west, etc.)
#   spawn_inset       — fallback distance from door if no `Spawn` Marker2D child is set
#
# `World.gd` connects to `player_entered` whenever a room becomes current, and
# runs the cross-room transition. See STRUCTURE.md "Room transitions" for the flow.
#
# `@tool` lets the editor draw a direction arrow. See GODOT_NOTES.md §Editor vs runtime.

@export_file("*.tscn") var target_room_path: String = ""
@export var target_door_name: String = ""
@export var direction: Vector2 = Vector2(1, 0):
	set(value):
		direction = value
		queue_redraw()
@export var spawn_inset: float = 60.0

signal player_entered(door: Door, player: Node2D)

func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered.emit(self, body)

func get_target_room_scene() -> PackedScene:
	if target_room_path == "":
		return null
	return load(target_room_path) as PackedScene

# Where the player should appear when arriving *through* this door from elsewhere.
# Prefer an explicit `Spawn` Marker2D child; fall back to inset behind the door.
func get_spawn_position() -> Vector2:
	var marker: Marker2D = get_node_or_null("Spawn") as Marker2D
	if marker:
		return marker.global_position
	var dir_norm: Vector2 = direction.normalized() if direction.length() > 0.0 else Vector2.RIGHT
	return global_position - dir_norm * spawn_inset

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var dir_norm: Vector2 = direction.normalized() if direction.length() > 0.0 else Vector2.RIGHT
	draw_line(Vector2.ZERO, dir_norm * 40.0, Color(1, 0.8, 0.3, 0.8), 3.0)
