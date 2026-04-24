extends Camera2D

# Smoothing is handled by Godot's built-in position_smoothing.
# This script just ensures sensible defaults and exposes them as exports.

@export var smooth_speed: float = 5.0  # position_smoothing_speed

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smooth_speed
	enabled = true
