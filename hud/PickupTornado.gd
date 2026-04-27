extends Control

# Spawned by AbilityStrip when a new ability is granted. Plays a 3-ring
# expanding swirl above the target slot, then "smacks down" into the slot
# and emits the `smacked` signal so the strip can pulse the slot + play the
# acquired-sound. Self-frees after the animation.
#
# Lives in the same CanvasLayer as the AbilityStrip (HUD layer). Position is
# in HUD/screen-space.
#
# Tunables exposed for per-spawn overrides; defaults match the user spec
# (3 expanding circles, smack-down landing, 3x slot scale on landing).

const RING_COUNT: int = 3
const RING_RADIUS: float = 14.0
const RING_EXPAND_TO: float = 3.6        # final scale relative to base
const RING_EXPAND_DURATION: float = 0.42
const RING_STAGGER: float = 0.08         # delay between rings starting

const TRAVEL_DROP: float = 90.0          # pixels above slot where the swirl starts
const TRAVEL_DELAY: float = 0.18         # how long after rings start before drop
const TRAVEL_DURATION: float = 0.22      # how fast the smack happens
const TRAVEL_OVERSHOOT: float = 8.0      # extra pixels past target for the smack feel

signal smacked

@export var hue: Color = Color(0.85, 0.95, 1, 1)

var _target: Vector2 = Vector2.ZERO
var _rings: Array = []


func setup(target_screen_pos: Vector2, color: Color) -> void:
	_target = target_screen_pos
	hue = color
	# Start above the slot so the smack-down has somewhere to fall from. Using
	# global_position because Control.position is parent-local — the tornado is
	# parented to AbilityStrip (which has its own offset), so screen-space
	# positioning has to go through global_position.
	global_position = target_screen_pos - Vector2(0, TRAVEL_DROP)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	for i in range(RING_COUNT):
		var ring: Node2D = _make_ring()
		add_child(ring)
		_rings.append(ring)
	_animate()


func _make_ring() -> Node2D:
	# Filled circle Polygon2D. Reads as a "pulse wave" when scaled+faded.
	var node: Polygon2D = Polygon2D.new()
	var verts: PackedVector2Array = PackedVector2Array()
	var seg: int = 28
	for i in range(seg):
		var a: float = float(i) * TAU / float(seg)
		verts.append(Vector2(cos(a), sin(a)) * RING_RADIUS)
	node.polygon = verts
	node.color = Color(hue.r, hue.g, hue.b, 0.85)
	node.scale = Vector2(0.2, 0.2)
	return node


func _animate() -> void:
	# Each ring expands + fades on a stagger; after the last ring starts
	# expanding, the whole tornado drops onto the slot. On land, emit smacked.
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)

	for i in range(_rings.size()):
		var ring: Node2D = _rings[i]
		var delay: float = float(i) * RING_STAGGER
		tween.tween_property(ring, "scale", Vector2(RING_EXPAND_TO, RING_EXPAND_TO), RING_EXPAND_DURATION).set_delay(delay)
		tween.tween_property(ring, "modulate:a", 0.0, RING_EXPAND_DURATION).set_delay(delay)

	# Drop onto target — tween global_position (parent-local "position" would
	# be wrong because the tornado's parent has its own offset).
	var drop_tween: Tween = create_tween()
	drop_tween.tween_interval(TRAVEL_DELAY)
	drop_tween.set_trans(Tween.TRANS_QUAD)
	drop_tween.set_ease(Tween.EASE_IN)
	drop_tween.tween_property(self, "global_position", _target + Vector2(0, TRAVEL_OVERSHOOT), TRAVEL_DURATION)
	drop_tween.set_trans(Tween.TRANS_BACK)
	drop_tween.set_ease(Tween.EASE_OUT)
	drop_tween.tween_property(self, "global_position", _target, 0.08)
	drop_tween.tween_callback(func() -> void:
		smacked.emit()
		# Linger a moment so the rings finish fading, then free
		var t: SceneTreeTimer = get_tree().create_timer(0.25)
		t.timeout.connect(queue_free))
