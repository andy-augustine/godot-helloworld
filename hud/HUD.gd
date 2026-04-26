extends CanvasLayer

# HUD root. Finds the player by group on _ready and connects health signals.
# Sits on its own CanvasLayer so it draws above the game world at fixed
# screen-space coords regardless of camera movement. Stable across room
# transitions — the player node persists; only rooms swap.

@onready var _health_bar: Control = $Margin/VBox/HealthBar

func _ready() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("HUD: no node in group 'player'")
		return
	player.health_changed.connect(_on_health_changed)
	player.player_died.connect(_on_player_died)
	# Sync initial state so the bar reflects health on scene load
	_health_bar.set_health(player._health, player.MAX_HEALTH)

func _on_health_changed(current: int, maximum: int) -> void:
	_health_bar.set_health(current, maximum)

func _on_player_died() -> void:
	# Hook for a future death overlay — empty for now.
	pass
