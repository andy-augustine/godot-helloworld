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

const SPIN_SPEED: float = 1.6           # radians/sec around the imagined head Y-axis
const BOB_AMPLITUDE: float = 6.0        # px peak-to-baseline
const BOB_PERIOD: float = 1.8           # sec per full bob cycle

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
	position.y = _origin_y + sin(_t * TAU / BOB_PERIOD) * BOB_AMPLITUDE
	# Head-spin illusion: simulate the crown rotating around an imagined
	# vertical axis through the wearer's head. In 2D we fake this with a
	# horizontal scale that follows cos(angle): full width at 0° and 180°
	# (front + back of crown), zero width at 90° + 270° (edge-on). Negative
	# scale.x mirrors the design — fine because the crown is symmetric.
	# Rotation stays at 0, so the band stays horizontal — distinct from the
	# pinwheel-spin we replaced.
	_visual.scale.x = cos(_t * SPIN_SPEED)


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
	set_deferred("monitoring", false)
	queue_free()
