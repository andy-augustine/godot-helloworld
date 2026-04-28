extends Area2D

# Endgame crown — the prize at the far right of ThirdRoom. Floats with a
# slow vertical bob, spins continuously, glows via a layered translucent
# ColorRect, and emits a constant golden sparkle. On player contact:
#  1. Stop animating itself
#  2. Trigger the HUD's screen flash + confetti shower
#  3. Free itself
#
# Designed wider than the player is tall (player capsule height = 48; crown
# visual ≈ 72 wide) so it visually dominates and reads as significant.
#
# Player contact uses Area2D.body_entered so it fires on the first overlap;
# subsequent overlaps are no-ops because the node is freed in the same call.

const SPIN_SPEED: float = 1.6           # radians/sec, full visible rotation
const BOB_AMPLITUDE: float = 6.0        # px peak-to-baseline
const BOB_PERIOD: float = 1.8           # sec per full bob cycle
const FLASH_COLOR: Color = Color(1, 1, 1, 1)

var _t: float = 0.0
var _origin_y: float = 0.0
var _claimed: bool = false

@onready var _visual: Node2D = $Visual


func _ready() -> void:
	_origin_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _claimed:
		return
	_t += delta
	# Bob in y, spin around z. Spin is on the visual node so the Area2D
	# CollisionShape stays axis-aligned (avoids weird rotated-box hit-tests).
	position.y = _origin_y + sin(_t * TAU / BOB_PERIOD) * BOB_AMPLITUDE
	_visual.rotation += SPIN_SPEED * delta


func _on_body_entered(body: Node2D) -> void:
	if _claimed:
		return
	if not body.is_in_group("player"):
		return
	_claimed = true
	# Notify HUD to play the endgame sequence (screen flash + confetti shower).
	# HUD owns the canvas-layer effect so it composites above the world.
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("play_crown_pickup"):
		hud.play_crown_pickup(global_position)
	# Sparkle burst from the crown itself before freeing — so the moment of
	# pickup reads even if the HUD effect is delayed by a frame.
	var burst: CPUParticles2D = $Sparkle
	burst.amount = 64
	burst.initial_velocity_max = 320.0
	burst.lifetime = 1.2
	burst.restart()
	# Pop and free. queue_free with a short delay so the burst can play out.
	set_deferred("monitoring", false)
	visible = false
	await get_tree().create_timer(0.05).timeout
	queue_free()
