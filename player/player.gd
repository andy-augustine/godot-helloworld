extends CharacterBody2D

# ── Constants ──────────────────────────────────────────────────────────────────
const GRAVITY: float = 1800.0

# Horizontal movement
const MOVE_SPEED: float = 220.0
const ACCELERATION: float = 1400.0
const DECELERATION: float = 1600.0
const AIR_ACCELERATION: float = 900.0
const AIR_DECELERATION: float = 700.0

# Jumping
const JUMP_VELOCITY: float = -540.0
const JUMP_CUT_MULTIPLIER: float = 0.4   # velocity multiplier on early release
const FALL_GRAVITY_MULTIPLIER: float = 1.6  # faster fall when descending

# Wall mechanics
const WALL_SLIDE_GRAVITY: float = 200.0  # slow fall speed while wall-sliding
const WALL_JUMP_VELOCITY: Vector2 = Vector2(240.0, -480.0)  # x away from wall, y upward

# Coyote time & jump buffer
const COYOTE_TIME: float = 0.15
const JUMP_BUFFER_TIME: float = 0.10

# ── State ──────────────────────────────────────────────────────────────────────
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _is_jumping: bool = false  # true while holding jump after leaving ground
var _wall_jump_direction: int = 0  # -1 left, 0 none, +1 right (set on wall-jump)
var _wall_jump_lock_timer: float = 0.0  # brief lock so player can't immediately re-grab
const WALL_JUMP_LOCK: float = 0.15


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_tick_timers(delta)
	_handle_jump(delta)
	_handle_horizontal(delta)
	_handle_wall_slide(delta)
	move_and_slide()
	_post_move_update()


# ── Gravity ────────────────────────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	var grav_mult: float = FALL_GRAVITY_MULTIPLIER if velocity.y > 0.0 else 1.0
	# Reduce gravity during wall-slide
	if _is_wall_sliding():
		velocity.y = move_toward(velocity.y, WALL_SLIDE_GRAVITY, GRAVITY * delta)
	else:
		velocity.y += GRAVITY * grav_mult * delta


# ── Timers ─────────────────────────────────────────────────────────────────────
func _tick_timers(delta: float) -> void:
	# Coyote: count down after leaving floor
	if is_on_floor():
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

	# Jump buffer: keep track of recent jump press
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)

	# Wall-jump direction lock
	_wall_jump_lock_timer = max(_wall_jump_lock_timer - delta, 0.0)


# ── Jump logic ─────────────────────────────────────────────────────────────────
func _handle_jump(_delta: float) -> void:
	var can_coyote_jump: bool = _coyote_timer > 0.0 and not is_on_floor()
	var can_floor_jump: bool = is_on_floor()
	var buffered_jump: bool = _jump_buffer_timer > 0.0

	# --- Wall jump (takes priority over floor/coyote jump when on wall) ---
	if _is_wall_sliding() and buffered_jump:
		_consume_jump_buffer()
		var wall_dir: int = _get_wall_direction()
		velocity.x = -float(wall_dir) * WALL_JUMP_VELOCITY.x
		velocity.y = WALL_JUMP_VELOCITY.y
		_is_jumping = true
		_coyote_timer = 0.0
		_wall_jump_direction = -wall_dir
		_wall_jump_lock_timer = WALL_JUMP_LOCK
		return

	# --- Floor / coyote jump ---
	if (can_floor_jump or can_coyote_jump) and buffered_jump:
		_consume_jump_buffer()
		velocity.y = JUMP_VELOCITY
		_is_jumping = true
		_coyote_timer = 0.0
		return

	# --- Variable jump height: cut velocity on early release ---
	if _is_jumping and Input.is_action_just_released("jump"):
		if velocity.y < 0.0:
			velocity.y *= JUMP_CUT_MULTIPLIER
		_is_jumping = false

	# --- Land: reset jump flag ---
	if is_on_floor():
		_is_jumping = false


func _consume_jump_buffer() -> void:
	_jump_buffer_timer = 0.0


# ── Horizontal movement ────────────────────────────────────────────────────────
func _handle_horizontal(delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")

	# During wall-jump lock, restrict horizontal control briefly
	if _wall_jump_lock_timer > 0.0:
		# Allow some influence but not full override
		dir *= 0.3

	var is_grounded: bool = is_on_floor()
	var accel: float = ACCELERATION if is_grounded else AIR_ACCELERATION
	var decel: float = DECELERATION if is_grounded else AIR_DECELERATION

	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * MOVE_SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)


# ── Wall slide ─────────────────────────────────────────────────────────────────
func _handle_wall_slide(_delta: float) -> void:
	# Wall slide is handled via _apply_gravity; nothing extra needed here
	pass


func _is_wall_sliding() -> bool:
	if is_on_floor():
		return false
	if not is_on_wall():
		return false
	if _wall_jump_lock_timer > 0.0:
		return false
	# Must be pressing toward the wall
	var dir: float = Input.get_axis("move_left", "move_right")
	var wall_dir: int = _get_wall_direction()
	return int(sign(dir)) == wall_dir


func _get_wall_direction() -> int:
	# Returns +1 if wall is to the right, -1 if to the left
	for i in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var normal: Vector2 = col.get_normal()
		if abs(normal.x) > 0.5:
			return -int(sign(normal.x))
	return 0


# ── Post-move cleanup ──────────────────────────────────────────────────────────
func _post_move_update() -> void:
	# If we hit a ceiling, kill upward velocity
	if is_on_ceiling() and velocity.y < 0.0:
		velocity.y = 0.0
		_is_jumping = false
