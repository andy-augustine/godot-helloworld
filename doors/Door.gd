@tool
class_name Door
extends Area2D

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
