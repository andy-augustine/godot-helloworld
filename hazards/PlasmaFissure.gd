extends Area2D

# Plasma fissure hazard — damages bodies in the "player" group that overlap,
# on a tick, bypassing iframes. The player's iframe system is sized for
# discrete enemy hits; a continuous environmental hazard needs to keep
# damaging the player as long as they linger, otherwise standing in lava
# is the same as a single graze. See player.gd:take_environmental_damage.
#
# Tuning is exported per-instance, so future variants (smaller/bigger pits,
# different damage rates) reuse this scene without subclassing.
#
# Lives in `hazards/`. Drop the .tscn instance into a Room and resize via
# its CollisionShape2D's RectangleShape2D. Visual children are independent
# of collision, so adjust the visual offsets too if the collision changes.

@export var damage_per_tick: int = 25
@export var tick_interval: float = 0.4

@onready var _timer: Timer = $DamageTimer
var _bodies_inside: Array[Node2D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_timer.wait_time = tick_interval
	_timer.timeout.connect(_on_tick)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body not in _bodies_inside:
		_bodies_inside.append(body)
	# Apply one immediate tick on entry — feels worse if you've fallen in
	# than if there were a 0.4s grace before the first hit registers.
	_apply_damage()
	if _timer.is_stopped():
		_timer.start()


func _on_body_exited(body: Node2D) -> void:
	_bodies_inside.erase(body)
	if _bodies_inside.is_empty():
		_timer.stop()


func _on_tick() -> void:
	_apply_damage()


func _apply_damage() -> void:
	for body in _bodies_inside:
		if body.has_method("take_environmental_damage"):
			body.take_environmental_damage(damage_per_tick)
