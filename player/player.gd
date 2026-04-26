extends CharacterBody2D

# Player controller. Attached to the root of player.tscn (CharacterBody2D).
# Lives as a sibling of GameCamera under World.
#
# Responsibilities:
#   - Read input → drive horizontal motion, jump, wall slide, wall jump
#   - Tune the feel: coyote time, jump buffer, variable jump height, fast-fall gravity
#   - Drive the rig animation (idle / run / jump / fall / wall_slide / land) plus
#     dust + spark particles
#   - On heavy landings, ask the camera for screen shake (via group "camera")
#
# Tunable feel constants are grouped at the top under each section header. None
# of them are `@export`'d — they're shared across all players (only one for now).
# Promote one to `@export` if you ever need per-instance tuning.
#
# In group "player" (set on player.tscn), so GameCamera can find this node.
# See STRUCTURE.md for the room/camera/player relationship; GODOT_NOTES.md
# §Physics for `move_and_slide` and §Animation for the AnimationPlayer pattern.

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

# Health
const MAX_HEALTH: int = 100
const IFRAMES_DURATION: float = 1.2
const IFRAME_FLASH_RATE: float = 10.0  # flashes per second

var _health: int = MAX_HEALTH
var _iframes_timer: float = 0.0

signal health_changed(current: int, maximum: int)
signal player_died
signal player_respawned

# Sizzle tunables (Phase 5)
const HIT_STOP_DURATION: float = 0.06    # global time-scale freeze on damage
const DEATH_FREEZE_DURATION: float = 0.45 # rig collapse + screen fade window
const DEATH_TILT_DEG: float = 22.0        # rig rotation during collapse

# ── Animation ──────────────────────────────────────────────────────────────────
@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _rig: Node2D = $Rig
@onready var _land_dust: CPUParticles2D = $Rig/LandDust
@onready var _run_dust: CPUParticles2D = $Rig/RunDust
@onready var _wall_sparks: CPUParticles2D = $Rig/WallSlideSparks
@onready var _wall_slide_audio: AudioStreamPlayer = $WallSlideAudio
var _facing: int = 1
var _was_grounded: bool = true
var _was_wall_sliding: bool = false
var _current_anim: String = ""
var _pre_move_vel_y: float = 0.0
const WALL_SLIDE_AUDIO_VOLUME: float = -16.0  # baseline; fade-out tweens to -40 then stops

const FACING_LERP: float = 0.3  # per-frame smoothing factor for facing flip
const LAND_DUST_MIN_VEL: float = 200.0  # fall velocity below which landing is silent
const HEAVY_LANDING_MIN_VEL: float = 950.0   # below this, no camera shake (regular jumps stay quiet)
const HEAVY_LANDING_MAX_VEL: float = 1700.0  # shake intensity saturates here


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_tick_timers(delta)
	_handle_jump(delta)
	_handle_horizontal(delta)
	_handle_wall_slide(delta)
	_pre_move_vel_y = velocity.y
	move_and_slide()
	_post_move_update()
	_update_animation()


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

	# I-frames countdown — flashes the rig at IFRAME_FLASH_RATE while active
	if _iframes_timer > 0.0:
		_iframes_timer = max(_iframes_timer - delta, 0.0)
		var flash: bool = fmod(_iframes_timer, 1.0 / IFRAME_FLASH_RATE) < (0.5 / IFRAME_FLASH_RATE)
		_rig.modulate.a = 0.2 if flash else 1.0
	else:
		_rig.modulate.a = 1.0


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
		AudioManager.play_sfx("jump", 0.1, -8)
		return

	# --- Floor / coyote jump ---
	if (can_floor_jump or can_coyote_jump) and buffered_jump:
		_consume_jump_buffer()
		velocity.y = JUMP_VELOCITY
		_is_jumping = true
		_coyote_timer = 0.0
		AudioManager.play_sfx("jump", 0.1, -6)
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


# ── Animation ──────────────────────────────────────────────────────────────────
# Maps physics state → animation clip + drives the visual rig (facing flip,
# particle emitters). One `AnimationPlayer` plays one clip at a time; the
# state→clip table is the `if/else if` block below. Add a new state by
# extending that block and adding a corresponding clip in player.tscn's
# AnimationPlayer.
func _update_animation() -> void:
	var grounded: bool = is_on_floor()
	var wall_sliding: bool = _is_wall_sliding()
	var dir: float = Input.get_axis("move_left", "move_right")

	# Wall-slide audio edges: start the loop on entry, fade out on exit.
	# The 100ms fade prevents an audible click when the player leaves the wall.
	if wall_sliding and not _was_wall_sliding:
		_wall_slide_audio.volume_db = WALL_SLIDE_AUDIO_VOLUME
		_wall_slide_audio.play()
	elif _was_wall_sliding and not wall_sliding:
		_fade_out_wall_slide()
	_was_wall_sliding = wall_sliding

	# Facing flip — only when actively moving, so idle keeps last facing
	if dir > 0.0:
		_facing = 1
	elif dir < 0.0:
		_facing = -1
	# When wall-sliding, face toward the wall so the bracing arm points correctly
	if wall_sliding:
		var wall_dir: int = _get_wall_direction()
		if wall_dir != 0:
			_facing = wall_dir
	# Smoothly interpolate the flip so direction changes have weight
	_rig.scale.x = lerpf(_rig.scale.x, float(_facing), FACING_LERP)

	# Landing transition: play land only if we hit the ground with real speed
	if grounded and not _was_grounded:
		if _pre_move_vel_y > LAND_DUST_MIN_VEL:
			_play("land")
			_emit_land_dust(_pre_move_vel_y)
			_shake_camera_on_land(_pre_move_vel_y)
			_was_grounded = grounded
			_update_particles(grounded, wall_sliding)
			return
	_was_grounded = grounded

	# Don't preempt the one-shot land animation
	if _current_anim == "land" and _anim.is_playing():
		_update_particles(grounded, wall_sliding)
		return

	# State → animation
	var next: String
	if wall_sliding:
		next = "wall_slide"
	elif not grounded:
		next = "jump" if velocity.y < 0.0 else "fall"
	elif absf(velocity.x) > 10.0:
		next = "run"
	else:
		next = "idle"

	_play(next)

	# Scale run cycle by actual horizontal velocity so legs don't skate
	if next == "run":
		_anim.speed_scale = clampf(absf(velocity.x) / MOVE_SPEED, 0.5, 1.5)
	else:
		_anim.speed_scale = 1.0

	_update_particles(grounded, wall_sliding)


func _update_particles(grounded: bool, wall_sliding: bool) -> void:
	# Run dust: kick up while grounded and moving
	var running: bool = grounded and absf(velocity.x) > 40.0
	_run_dust.emitting = running
	if running:
		# Trail behind direction of motion (particles fly backward)
		_run_dust.direction = Vector2(-signf(velocity.x), -0.4)

	# Wall-slide sparks: emit from side of body against the wall
	_wall_sparks.emitting = wall_sliding
	if wall_sliding:
		var wdir: int = _get_wall_direction()
		_wall_sparks.position.x = 14.0 * float(wdir)


func _emit_land_dust(fall_speed: float) -> void:
	# Scale burst intensity with fall velocity
	var t: float = clampf((fall_speed - LAND_DUST_MIN_VEL) / 600.0, 0.0, 1.0)
	_land_dust.amount = int(lerpf(6.0, 18.0, t))
	_land_dust.initial_velocity_max = lerpf(60.0, 140.0, t)
	_land_dust.restart()


func _shake_camera_on_land(fall_speed: float) -> void:
	if fall_speed < HEAVY_LANDING_MIN_VEL:
		return
	var span: float = HEAVY_LANDING_MAX_VEL - HEAVY_LANDING_MIN_VEL
	var t: float = clampf((fall_speed - HEAVY_LANDING_MIN_VEL) / span, 0.0, 1.0)
	# Audio + shake share the same trigger and intensity curve so visual and
	# auditory hit feel coupled. Volume scales -6 dB (light heavy) → 0 dB (max).
	AudioManager.play_sfx("heavy_landing", 0.0, lerpf(-6.0, 0.0, t))
	var cam: Node = get_tree().get_first_node_in_group("camera")
	if cam == null or not cam.has_method("add_shake"):
		return
	cam.add_shake(lerpf(3.0, 9.0, t))


func _play(anim_name: String) -> void:
	if _current_anim == anim_name and _anim.is_playing():
		return
	_anim.play(anim_name)
	_current_anim = anim_name


# Fade the wall-slide loop to silence over 100ms then stop. Avoids a click that
# would happen if we just called stop() at the end of a wave cycle.
func _fade_out_wall_slide() -> void:
	if not _wall_slide_audio.playing:
		return
	var tween := create_tween()
	tween.tween_property(_wall_slide_audio, "volume_db", -40.0, 0.1)
	tween.tween_callback(_wall_slide_audio.stop)


# ── Health ─────────────────────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if _iframes_timer > 0.0:
		return
	_health = max(_health - amount, 0)
	_iframes_timer = IFRAMES_DURATION
	health_changed.emit(_health, MAX_HEALTH)
	# Hit feedback: SFX + camera shake + brief global hit-stop. AudioManager
	# silently warns if "player_hit" isn't registered yet — wiring is in place
	# for whenever the .ogg lands. See backlog/gamedev.md item #16.
	AudioManager.play_sfx("player_hit", 0.08, -2.0)
	var cam: Node = get_tree().get_first_node_in_group("camera")
	if cam and cam.has_method("add_shake"):
		cam.add_shake(4.0)
	# Hit-stop: freeze the world for ~60ms. ignore_time_scale=true on the timer
	# so it ticks even though Engine.time_scale is 0.
	Engine.time_scale = 0.0
	await get_tree().create_timer(HIT_STOP_DURATION, true, false, true).timeout
	Engine.time_scale = 1.0
	if _health == 0:
		player_died.emit()
		_handle_death()


func _handle_death() -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO
	# Death SFX (silent until player_death.ogg is registered — see backlog #16).
	AudioManager.play_sfx("player_death", 0.0, 0.0)
	# Rig collapse: tint deep red, fade alpha out, tilt over. Reset on respawn.
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_rig, "modulate", Color(0.6, 0.15, 0.15, 0.0), DEATH_FREEZE_DURATION * 0.8)
	tween.tween_property(_rig, "rotation", deg_to_rad(DEATH_TILT_DEG * float(_facing)), DEATH_FREEZE_DURATION)
	await get_tree().create_timer(DEATH_FREEZE_DURATION).timeout
	_respawn()


func _respawn() -> void:
	# Per Room.gd: get_spawn returns a local-space Vector2 (or Vector2.ZERO if
	# the named spawn isn't defined). Convert to world via room.to_global.
	# Fall back to in-place if no current room or no default spawn.
	var room: Node = get_tree().get_first_node_in_group("current_room")
	if room and room.has_method("get_spawn"):
		var local_pos: Vector2 = room.get_spawn("default")
		if local_pos != Vector2.ZERO and room is Node2D:
			global_position = (room as Node2D).to_global(local_pos)
	_health = MAX_HEALTH
	_iframes_timer = 0.0
	_rig.modulate = Color(1, 1, 1, 1)
	_rig.rotation = 0.0
	health_changed.emit(_health, MAX_HEALTH)
	player_respawned.emit()
	set_physics_process(true)


# Debug: Tab deals 20 damage so we can verify the health pipeline before
# enemies exist. Remove this when enemies start calling take_damage().
func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("ui_focus_next"):
		take_damage(20)
