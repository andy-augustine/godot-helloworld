extends Node2D

# Energy tendril swing — a hanging plasma strand that swings on a pendulum
# arc, with an AnimatableBody2D platform tracking the bottom of the swing.
# Player jumps onto the platform, gets carried by sync_to_physics, jumps off
# when timing is right.
#
# Lives in `hazards/`. Drop the .tscn into a Room scene at the desired pivot
# position. Tune amplitude + period via @export.
#
# IMPORTANT structural note: PlatformBody is a *sibling* of Pivot, not a
# child. Sub-tree:
#   SwingTendril (Node2D, this script)
#   ├── Pivot (Node2D) — rotates; carries the visual rope (TendrilLine etc.)
#   └── PlatformBody (AnimatableBody2D) — sync_to_physics, position written
#       manually each physics tick to track the bottom of the swing arc.
#
# History: earlier versions had PlatformBody as a child of Pivot AND with
# sync_to_physics = true. Two interacting bugs:
#   1) sync_to_physics + parent rotation → body's local position drifts
#      because the physics server keeps "correcting" it each tick. After a
#      minute of swinging it ended up at local (-2363, 516).
#   2) Even after restructuring to make PlatformBody a sibling of Pivot,
#      sync_to_physics = true causes direct script-driven position assignment
#      to be silently overwritten by the physics server's transform sync
#      (sync_to_physics is specifically meant for AnimationPlayer-driven
#      motion, where the animation system writes physics-aware updates).
# Fix: PlatformBody is a sibling of Pivot AND sync_to_physics = false.
# AnimatableBody2D's kinematic-push behavior on collision (carrying the
# player when its position changes) does NOT require sync_to_physics — that
# setting only controls visual interpolation timing, not the push mechanic.

const TENDRIL_LENGTH: float = 180.0  # must match the TendrilLine polygon length

@export var swing_amplitude_deg: float = 55.0
@export var swing_period: float = 3.5  # seconds for a full cycle
@export var phase_offset: float = 0.0

@onready var _pivot: Node2D = $Pivot
@onready var _platform: AnimatableBody2D = $PlatformBody

var _time: float = 0.0


func _ready() -> void:
	_time = phase_offset * swing_period / TAU


func _physics_process(delta: float) -> void:
	_time += delta
	var phase: float = _time * TAU / swing_period
	var rot: float = deg_to_rad(swing_amplitude_deg) * sin(phase)
	# Visual rope rotates around the pivot — children of Pivot inherit
	_pivot.rotation = rot
	# Platform tracks the bottom of the swing arc. The tendril visual is at
	# Pivot-local (0, TENDRIL_LENGTH); rotating that point by `rot` yields
	# (-sin(rot)*L, cos(rot)*L) per Godot's 2D rotation convention. The
	# x-component is negated — got bitten by a sign flip earlier where the
	# platform ended up mirror-imaged across the pivot from the rope.
	_platform.position = Vector2(-sin(rot), cos(rot)) * TENDRIL_LENGTH
	_platform.rotation = 0.0
