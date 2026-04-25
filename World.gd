extends Node2D

# Top-level coordinator. World.tscn is the entry scene (set in project.godot).
# Owns Player + GameCamera + the current Room (one room loaded at a time).
#
# Responsibilities:
#   - On _ready: connect door signals on the starting room, hand the camera its bounds
#   - On a door firing `player_entered`: load the target room, position it so the
#     entry door and target door align, tween player + camera, swap rooms, free old
#
# See STRUCTURE.md "Room transitions" for the full step-by-step.
#
# Tunables:
#   TRANSITION_DURATION — how long the slide takes (0.5s feels Hollow Knight-ish)
#   DOOR_GAP            — how far past the entry door the new room sits when aligned

const TRANSITION_DURATION: float = 0.5
const DOOR_GAP: float = 80.0

@onready var _camera: GameCamera = $GameCamera
@onready var _player: CharacterBody2D = $Player

var _current_room: Node2D
var _transitioning: bool = false

func _ready() -> void:
	_current_room = $StartingRoom
	_connect_room_doors(_current_room)
	_camera.enter_room(_current_room)

# Doors are children of the current room. Connect/disconnect their signals when
# rooms swap so we don't accumulate dangling listeners across transitions.
func _connect_room_doors(room: Node2D) -> void:
	if not is_instance_valid(room):
		return
	for child in room.get_children():
		if child is Door:
			if not child.player_entered.is_connected(_on_door_entered):
				child.player_entered.connect(_on_door_entered)

func _disconnect_room_doors(room: Node2D) -> void:
	if not is_instance_valid(room):
		return
	for child in room.get_children():
		if child is Door:
			if child.player_entered.is_connected(_on_door_entered):
				child.player_entered.disconnect(_on_door_entered)

func _on_door_entered(door: Door, player: Node2D) -> void:
	if _transitioning:
		return
	_start_transition(door, player)

# Choreography for crossing a door. See STRUCTURE.md "Room transitions" for an
# overview; the inline steps below are the implementation specifics.
func _start_transition(door: Door, player: Node2D) -> void:
	_transitioning = true
	# Freeze player so input/gravity don't fight the position tween.
	player.set_physics_process(false)
	if player is CharacterBody2D:
		(player as CharacterBody2D).velocity = Vector2.ZERO

	var packed: PackedScene = door.get_target_room_scene()
	if packed == null:
		push_error("Door has no target_room_path")
		_abort_transition(player)
		return

	# Instantiate the new room as a sibling of Player. Move it before Player in
	# the child order so the player draws on top of room geometry.
	var new_room: Node2D = packed.instantiate()
	add_child(new_room)
	move_child(new_room, _player.get_index())

	var target_door: Door = new_room.get_node_or_null(door.target_door_name) as Door
	if target_door == null:
		push_error("Target door '%s' not found in %s" % [door.target_door_name, packed.resource_path])
		new_room.queue_free()
		_abort_transition(player)
		return

	# Align the new room so its target door lands DOOR_GAP past the entry door
	# in the entry door's `direction`. The math: world position of the target
	# door must equal (entry door world position + direction * gap), so we
	# offset the room itself to make that true given the target door's local pos.
	var entry_door_world: Vector2 = door.global_position
	var target_door_local: Vector2 = target_door.position
	new_room.global_position = entry_door_world + door.direction.normalized() * DOOR_GAP - target_door_local

	var spawn_pos: Vector2 = target_door.get_spawn_position()
	var camera_target: Vector2 = _compute_clamped_camera_pos(new_room, spawn_pos)

	# Pin camera to its currently displayed position before clearing limits.
	# Otherwise inverted-limit midpoint clamping is dropped and the view jumps
	# to the player's raw position the instant limits are cleared.
	_camera.global_position = _camera.get_screen_center_position() - _camera.offset
	_camera.follow_player = false
	_camera.position_smoothing_enabled = false
	_camera.clear_limits()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "global_position", spawn_pos, TRANSITION_DURATION)
	tween.tween_property(_camera, "global_position", camera_target, TRANSITION_DURATION)

	await tween.finished

	_disconnect_room_doors(_current_room)
	_current_room.queue_free()
	_current_room = new_room
	_connect_room_doors(_current_room)

	_camera.follow_player = true
	_camera.position_smoothing_enabled = true
	_camera.enter_room(_current_room)

	player.set_physics_process(true)
	_transitioning = false

func _compute_clamped_camera_pos(room: Node2D, target: Vector2) -> Vector2:
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var half: Vector2 = view_size * 0.5
	var origin: Vector2 = room.global_position
	var b: Rect2 = room.bounds
	var ox: float = 0.0
	var oy: float = _camera.y_offset if b.size.y >= view_size.y else 0.0
	var lim_left: float = origin.x + b.position.x - ox
	var lim_top: float = origin.y + b.position.y - oy
	var lim_right: float = origin.x + b.position.x + b.size.x - ox
	var lim_bottom: float = origin.y + b.position.y + b.size.y - oy
	var min_x: float = lim_left + half.x
	var max_x: float = lim_right - half.x
	var min_y: float = lim_top + half.y
	var max_y: float = lim_bottom - half.y
	var x: float = clampf(target.x, min_x, max_x) if max_x >= min_x else (min_x + max_x) * 0.5
	var y: float = clampf(target.y, min_y, max_y) if max_y >= min_y else (min_y + max_y) * 0.5
	return Vector2(x, y)

func _abort_transition(player: Node2D) -> void:
	_camera.follow_player = true
	_camera.position_smoothing_enabled = true
	_camera.enter_room(_current_room)
	player.set_physics_process(true)
	_transitioning = false
