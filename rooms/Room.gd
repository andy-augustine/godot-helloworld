@tool
class_name Room
extends Node2D

@export var bounds: Rect2 = Rect2(0, 0, 960, 540):
	set(value):
		bounds = value
		queue_redraw()

@export var spawn_points: Dictionary = {}

const _BOUNDS_COLOR := Color(0.4, 0.9, 1.0, 0.55)
const _BOUNDS_WIDTH := 2.0

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_rect(bounds, _BOUNDS_COLOR, false, _BOUNDS_WIDTH)

func get_spawn(spawn_name: String) -> Vector2:
	if spawn_points.has(spawn_name):
		return spawn_points[spawn_name]
	return Vector2.ZERO
