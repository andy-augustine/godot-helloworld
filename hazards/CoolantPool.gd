extends Area2D

# Coolant pool slow-zone — when the player overlaps, they're slowed.
# Implementation: notify player via enter_slow_zone() / exit_slow_zone() so
# multiple overlapping zones stack correctly via a counter. No damage —
# the punishment is opportunity cost (you can't traverse the room normally).
#
# Lives in `hazards/`. Drop the .tscn into a Room scene; resize the
# CollisionShape2D's RectangleShape2D and adjust visual offsets to match.


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("enter_slow_zone"):
		body.enter_slow_zone()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("exit_slow_zone"):
		body.exit_slow_zone()
