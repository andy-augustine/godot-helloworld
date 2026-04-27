extends Node2D

# Energy tendril swing — a hanging plasma strand that swings on a pendulum
# arc, with an AnimatableBody2D platform at its end. Player jumps onto the
# platform, gets carried by the swing's motion (sync_to_physics handles the
# kinematic push), jumps off when timing is right.
#
# Lives in `hazards/`. Drop the .tscn into a Room scene at the desired pivot
# position. Tune amplitude + period via @export.

@export var swing_amplitude_deg: float = 55.0
@export var swing_period: float = 3.5  # seconds for full cycle (one extreme-to-extreme-and-back)
@export var phase_offset: float = 0.0   # 0..TAU; advances the starting angle for cycling levels

@onready var _pivot: Node2D = $Pivot

var _time: float = 0.0


func _ready() -> void:
	_time = phase_offset * swing_period / TAU


func _physics_process(delta: float) -> void:
	_time += delta
	var phase: float = _time * TAU / swing_period
	_pivot.rotation = deg_to_rad(swing_amplitude_deg) * sin(phase)
