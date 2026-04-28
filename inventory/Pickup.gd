extends Area2D

# Pickup that grants a movement ability via the Inventory autoload, then
# disappears in a quick burst. The ability is determined by `ability_id`,
# which must be a key in Abilities.REGISTRY. Subclasses (or just instances
# with the export set) re-skin via the inspector, no code change needed.
#
# Lives in group "pickup". Sits as a child of a Room scene at world-space
# position. Picked up on body_entered with the player.

@export var ability_id: StringName = &""
@export var float_amplitude: float = 4.0   # vertical bob amplitude
@export var float_period: float = 1.4      # full bob cycle in seconds

# Swirl-and-fly grant animation (the visual flourish on grab):
# Pickup spins in expanding revolutions then flies to its AbilityStrip slot.
# Tunable on the constants below; ability is granted only at landing so the
# slot's pulse + skill_acquired SFX align with the visual smack.
const SWIRL_DURATION: float = 1.6           # 3 revs in <= 2s, this is the rev portion
const SWIRL_REVOLUTIONS: float = 3.0
const SWIRL_START_RADIUS: float = 24.0      # ~2x the pickup-box width (24px)
const SWIRL_END_RADIUS: float = 96.0        # ~2x the player visible height (~48px)
const FLY_DURATION: float = 0.55            # time from end-of-swirl to slot landing

@onready var _body: ColorRect = $Visual/Body
@onready var _outline: ColorRect = $Visual/Outline
@onready var _highlight: ColorRect = $Visual/Highlight
@onready var _inner_glow: ColorRect = $Visual/InnerGlow
@onready var _icon_holder: Node2D = $Visual/IconHolder
@onready var _sparkle: CPUParticles2D = $Sparkle

var _t: float = 0.0
var _origin_y: float = 0.0
var _animating: bool = false      # true once player touched and swirl began
var _swirl_origin: Vector2 = Vector2.ZERO  # captured at animation start


func _ready() -> void:
	add_to_group("pickup")
	_origin_y = position.y

	# If the player already owns this ability (e.g. they re-entered the room),
	# don't render at all — there's no proper room-state autoload yet, so the
	# pickup is responsible for its own "already collected" check. When room-
	# state persistence lands (backlog/gamedev.md, eventually), this becomes
	# the room state's job and pickups can simplify.
	var inv := get_node_or_null("/root/Inventory")
	if inv and ability_id != &"" and inv.has(ability_id):
		queue_free()
		return

	body_entered.connect(_on_body_entered)
	# Color the procedural-animated stack + sparkle to the ability's category.
	# Outline = body darkened 50%, highlight = body lightened 35%, glow = body
	# lightened 25% with reduced alpha. Computed here so per-instance ability_id
	# drives palette without scene-level color authoring per pickup.
	if Abilities.has_ability(ability_id):
		var cat: int = Abilities.category(ability_id)
		var hue := _hue_for(cat)
		_body.color = hue
		_outline.color = hue.darkened(0.5)
		_highlight.color = hue.lightened(0.45)
		_inner_glow.color = Color(hue.lightened(0.25), 0.5)
		_sparkle.color = hue
		# Symbolic icon for this ability — drawn on top of the body so the
		# player can recognize what's in the box at a glance.
		AbilityIcons.build_into(_icon_holder, ability_id, hue.lightened(0.55), 0.85)


func _process(delta: float) -> void:
	# Suspend the idle bob during the grant animation — the swirl tween writes
	# directly to global_position; bob would fight it.
	if _animating:
		return
	_t += delta
	# Vertical bob — gentle sine, doesn't accumulate drift
	position.y = _origin_y + sin(_t * TAU / float_period) * float_amplitude


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if ability_id == &"":
		push_warning("Pickup: empty ability_id, skipping grant")
		return
	if _animating:
		return
	var inv := get_node_or_null("/root/Inventory")
	if inv == null:
		push_warning("Pickup: Inventory autoload missing, skipping grant")
		return
	if inv.has(ability_id):
		queue_free()  # already owned, just clean up
		return

	# Acknowledgment burst at the touch moment. The bigger reward (slot pulse
	# + skill_acquired SFX) plays at landing — handled by AbilityStrip's
	# ability_granted handler, which fires when we call inv.grant() at the
	# end of the fly animation.
	_sparkle.amount = 32
	_sparkle.initial_velocity_max = 220.0
	_sparkle.lifetime = 0.7
	_sparkle.restart()
	AudioManager.play_sfx("pickup", 0.05, -4.0)
	# Disable further triggers — the pickup is committed now, prevent
	# re-triggering by another player frame. set_deferred required because
	# we're inside a body_entered callback (mid physics flush).
	set_deferred("monitoring", false)
	_animating = true
	_swirl_origin = global_position
	_start_swirl_animation()


func _start_swirl_animation() -> void:
	# Phase 1: 3 expanding revolutions around the pickup's origin.
	# Phase 2: fly to the AbilityStrip slot's world position.
	# Phase 3: grant + free.
	var target_world: Vector2 = _get_slot_world_position()
	var tween: Tween = create_tween()
	tween.tween_method(_apply_swirl, 0.0, 1.0, SWIRL_DURATION).set_trans(Tween.TRANS_LINEAR)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", target_world, FLY_DURATION)
	tween.tween_callback(_on_landing)


func _apply_swirl(t: float) -> void:
	# t goes 0..1 over SWIRL_DURATION. radius lerps small→large; phase covers
	# SWIRL_REVOLUTIONS full circles. The pickup's initial position is the
	# orbit center.
	var phase: float = t * SWIRL_REVOLUTIONS * TAU
	var radius: float = lerpf(SWIRL_START_RADIUS, SWIRL_END_RADIUS, t)
	global_position = _swirl_origin + Vector2(cos(phase), sin(phase)) * radius


func _on_landing() -> void:
	var inv: Node = get_node_or_null("/root/Inventory")
	if inv:
		inv.grant(ability_id)
	queue_free()


# Computes the world-space position the pickup should land at — the slot's
# screen center, projected back through the camera transform. Falls back to
# the pickup's current position if anything in the lookup chain is missing.
func _get_slot_world_position() -> Vector2:
	var strip: Node = get_tree().get_first_node_in_group("ability_strip")
	if strip == null or not strip.has_method("get_slot_screen_position"):
		return global_position
	var screen_pos: Vector2 = strip.get_slot_screen_position(ability_id)
	if screen_pos == Vector2.ZERO:
		return global_position
	var camera: Node = get_tree().get_first_node_in_group("camera")
	if camera == null:
		return global_position
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	# camera.global_position is the world-space center of the viewport (zoom 1).
	# Top-left of viewport in world = camera_pos - viewport_size * 0.5.
	# Pixel (sx, sy) in screen-space → world-space.
	return (camera as Node2D).global_position - viewport_size * 0.5 + screen_pos


func _hue_for(cat: int) -> Color:
	match cat:
		0: return Color("9b6cff")  # Jumps
		1: return Color("ff8c1a")  # Runs
		2: return Color("4ad6c2")  # Climbs
		_: return Color.WHITE
