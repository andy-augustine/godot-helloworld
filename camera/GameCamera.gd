class_name GameCamera
extends Camera2D

# Game camera. Lives as a sibling of Player under World (NOT a child of Player —
# that lets transitions move the camera independently and clamp to room bounds).
#
# Responsibilities:
#   - Follow the player with a deadzone (small movements don't shake the framing)
#   - Look ahead horizontally when the player is moving fast, and downward when
#     falling fast (so the player can see where they'll land)
#   - Clamp to the current room's `bounds` Rect2 (set via `enter_room(room)`)
#   - Provide screen-shake for impact moments — `add_shake(intensity)` is called
#     by the player on heavy landings
#
# Finds the player at startup via group "player". Adds itself to group "camera"
# so the player can find it for shake events. See STRUCTURE.md and GODOT_NOTES.md
# §Groups for the rationale.
#
# Most tuning values are `@export`'d, so they can be edited on the GameCamera node
# in the inspector at runtime without touching the script.

@export var y_offset: float = -40.0
@export var smoothing_speed: float = 8.0

# Deadzone — player can move within this rect around the anchor with no camera response.
@export var deadzone_size: Vector2 = Vector2(40, 50)

# Horizontal lookahead — camera leads in the direction of horizontal motion.
@export var lookahead_x_amount: float = 30.0
@export var lookahead_x_speed: float = 4.0
@export var lookahead_x_velocity_threshold: float = 30.0

# Vertical lookahead during fast falls — pulls camera down so landing is visible.
@export var fall_lookahead_amount: float = 60.0
@export var fall_velocity_threshold: float = 350.0
@export var fall_lookahead_speed: float = 5.0

const _SHAKE_DECAY: float = 14.0

var _player: Node2D
var _room: Node2D
var follow_player: bool = true

var _anchor: Vector2 = Vector2.ZERO
var _lookahead_x: float = 0.0
var _lookahead_y: float = 0.0

var _shake_offset: Vector2 = Vector2.ZERO
var _shake_intensity: float = 0.0

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed
	offset = Vector2(0, y_offset)
	add_to_group("camera")
	make_current()
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		_anchor = _player.global_position

func _physics_process(delta: float) -> void:
	_update_shake(delta)
	if not follow_player or _player == null:
		offset = Vector2(_shake_offset.x, y_offset + _shake_offset.y)
		return
	_update_anchor()
	_update_lookahead(delta)
	global_position = _anchor + Vector2(_lookahead_x, _lookahead_y)
	offset = Vector2(_shake_offset.x, y_offset + _shake_offset.y)

# The "anchor" is what the camera frames; it only moves when the player leaves
# the deadzone rect around it. Inside the deadzone the camera doesn't react —
# this is what stops idle micro-movements from jittering the view.
func _update_anchor() -> void:
	var p: Vector2 = _player.global_position
	var hd: Vector2 = deadzone_size * 0.5
	var dx: float = p.x - _anchor.x
	var dy: float = p.y - _anchor.y
	if dx > hd.x:
		_anchor.x = p.x - hd.x
	elif dx < -hd.x:
		_anchor.x = p.x + hd.x
	if dy > hd.y:
		_anchor.y = p.y - hd.y
	elif dy < -hd.y:
		_anchor.y = p.y + hd.y

func _update_lookahead(delta: float) -> void:
	var pvx: float = _get_player_vx()
	var target_x: float = 0.0
	if absf(pvx) > lookahead_x_velocity_threshold:
		target_x = signf(pvx) * lookahead_x_amount
	_lookahead_x = move_toward(_lookahead_x, target_x, lookahead_x_speed * 60.0 * delta)
	var pvy: float = _get_player_vy()
	var target_y: float = fall_lookahead_amount if pvy > fall_velocity_threshold else 0.0
	_lookahead_y = move_toward(_lookahead_y, target_y, fall_lookahead_speed * 60.0 * delta)

func _update_shake(delta: float) -> void:
	if _shake_intensity > 0.0:
		_shake_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_intensity
		_shake_intensity = max(_shake_intensity - _SHAKE_DECAY * delta, 0.0)
	else:
		_shake_offset = Vector2.ZERO

func add_shake(intensity: float) -> void:
	_shake_intensity = max(_shake_intensity, intensity)

func _get_player_vx() -> float:
	if _player is CharacterBody2D:
		return (_player as CharacterBody2D).velocity.x
	return 0.0

func _get_player_vy() -> float:
	if _player is CharacterBody2D:
		return (_player as CharacterBody2D).velocity.y
	return 0.0

# Called by World whenever a room becomes current (startup + after a transition).
# Translates the room's local `bounds` Rect2 into the camera's `limit_*` fields,
# which Camera2D uses to clamp itself. Also resets smoothing so the camera doesn't
# slide visibly the moment a new room becomes active.
func enter_room(room: Node2D) -> void:
	_room = room
	if room == null:
		clear_limits()
		return
	var b: Rect2 = room.bounds
	var origin: Vector2 = room.global_position
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	# Compensate for the static y_offset (not the dynamic offset that includes
	# shake), and only along axes where the room is at least viewport-sized.
	var oy: float = y_offset if b.size.y >= view_size.y else 0.0
	limit_left = int(origin.x + b.position.x)
	limit_top = int(origin.y + b.position.y - oy)
	limit_right = int(origin.x + b.position.x + b.size.x)
	limit_bottom = int(origin.y + b.position.y + b.size.y - oy)
	if _player:
		_anchor = _player.global_position
	_lookahead_x = 0.0
	_lookahead_y = 0.0
	reset_smoothing()

func clear_limits() -> void:
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000
