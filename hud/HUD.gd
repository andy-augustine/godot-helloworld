extends CanvasLayer

# HUD root. Finds the player by group on _ready and connects health signals.
# Sits on its own CanvasLayer so it draws above the game world at fixed
# screen-space coords regardless of camera movement. Stable across room
# transitions — the player node persists; only rooms swap.

# Death fade pacing. Player.gd takes ~0.65s from death-blow to respawn:
# DEATH_TWEEN_DURATION (0.4s rig collapse) + DEATH_HOLD_DURATION (0.25s held
# pose). We wait DEATH_FADE_DELAY so the rig collapse plays in clear view,
# then fade to black during the hold so the teleport-to-spawn happens behind
# the curtain. Fade-back fires on player_respawned.
const DEATH_FADE_DELAY: float = 0.4
const DEATH_FADE_IN: float = 0.25
const DEATH_FADE_OUT: float = 0.35

@onready var _health_bar: Control = $Margin/VBox/HealthBar
@onready var _death_overlay: ColorRect = $DeathOverlay

func _ready() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("HUD: no node in group 'player'")
		return
	player.health_changed.connect(_on_health_changed)
	player.player_died.connect(_on_player_died)
	player.player_respawned.connect(_on_player_respawned)
	# Sync initial state so the bar reflects health on scene load
	_health_bar.set_health(player._health, player.MAX_HEALTH)

func _on_health_changed(current: int, maximum: int) -> void:
	_health_bar.set_health(current, maximum)

func _on_player_died() -> void:
	# Let the rig collapse animation breathe before pulling the curtain.
	await get_tree().create_timer(DEATH_FADE_DELAY).timeout
	var tween := create_tween()
	tween.tween_property(_death_overlay, "modulate:a", 1.0, DEATH_FADE_IN)

func _on_player_respawned() -> void:
	var tween := create_tween()
	tween.tween_property(_death_overlay, "modulate:a", 0.0, DEATH_FADE_OUT)
