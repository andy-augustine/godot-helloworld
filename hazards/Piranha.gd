extends Area2D

# Coolant-pool piranha — small swimming hazard. Patrols horizontally inside
# the pool's water rectangle, with a soft vertical bob, occasionally flipping
# direction. On overlap with the player it bites once for BITE_DAMAGE and goes
# on a brief cooldown so the player can't be drained from a single contact.
#
# Lives in the pool tank (CoolantPool's water rectangle) and reads its bounds
# from the patrol_rect export — set this on the room scene to match the pool's
# inner area minus a small inset so the fish never overlaps the tank walls.
#
# 24x24 pickup-equivalent footprint, so the player can clear it with a normal
# jump. No vertical pursuit — the fish stays in the water, player escapes by
# jumping out of the pool entirely.

@export var patrol_rect: Rect2 = Rect2(-180, -28, 360, 56)  # local to pool center
@export var swim_speed: float = 50.0    # px/sec, base patrol speed
@export var bob_amplitude: float = 3.0
@export var bob_period: float = 1.2
@export var direction_flip_period: float = 3.5  # roughly how often it changes direction
@export var bite_damage: int = 25
@export var bite_cooldown: float = 1.2  # seconds before the fish can bite again

var _facing: int = 1                    # 1 = right, -1 = left
var _t: float = 0.0
var _bob_t: float = 0.0
var _origin_y: float = 0.0
var _next_flip: float = 0.0
var _bite_clock: float = 0.0            # counts down; can bite when ≤ 0

@onready var _visual: Node2D = $Visual


func _ready() -> void:
	_origin_y = position.y
	_next_flip = direction_flip_period * randf_range(0.6, 1.4)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	_bob_t += delta
	if _bite_clock > 0.0:
		_bite_clock -= delta

	# Horizontal patrol — clamp inside patrol_rect; reverse on edge contact.
	var dx: float = swim_speed * float(_facing) * delta
	position.x = clampf(position.x + dx, patrol_rect.position.x, patrol_rect.position.x + patrol_rect.size.x)
	if position.x <= patrol_rect.position.x or position.x >= patrol_rect.position.x + patrol_rect.size.x:
		_facing = -_facing
		_visual.scale.x = float(_facing)

	# Soft vertical bob inside the patrol band.
	var bob_offset: float = sin(_bob_t * TAU / bob_period) * bob_amplitude
	position.y = clampf(_origin_y + bob_offset, patrol_rect.position.y, patrol_rect.position.y + patrol_rect.size.y)

	# Random direction flip — keeps the fish from feeling deterministic.
	if _t >= _next_flip:
		_t = 0.0
		_next_flip = direction_flip_period * randf_range(0.6, 1.6)
		_facing = -_facing
		_visual.scale.x = float(_facing)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _bite_clock > 0.0:
		return
	if body.has_method("take_environmental_damage"):
		body.take_environmental_damage(bite_damage)
	_bite_clock = bite_cooldown
	# Brief recoil flash so the bite reads visually.
	var tw: Tween = create_tween()
	modulate = Color(2.0, 0.6, 0.6, 1)
	tw.tween_property(self, "modulate", Color.WHITE, 0.3)
