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
@onready var _flash_overlay: ColorRect = $FlashOverlay
@onready var _confetti: CPUParticles2D = $Confetti


func _ready() -> void:
	add_to_group("hud")
	# CPUParticles2D doesn't render without a texture in Godot 4. Build a tiny
	# 4x6 white rectangle in code so each particle reads as a confetti strip;
	# avoids checking in a binary asset for a six-byte image.
	var img: Image = Image.create(4, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	_confetti.texture = ImageTexture.create_from_image(img)
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("HUD: no node in group 'player'")
		return
	player.health_changed.connect(_on_health_changed)
	player.player_died.connect(_on_player_died)
	player.player_respawned.connect(_on_player_respawned)
	# Sync initial state so the bar reflects health on scene load
	_health_bar.set_health(player._health, player.MAX_HEALTH)


# Endgame celebration triggered when the player grabs the Crown. Two beats:
# (1) a quick white screen flash that fades over ~0.5s, (2) a confetti burst
# from the bottom-right of the screen aimed up-and-left, with gravity pulling
# the pieces back down before they hit the ceiling or the left wall. World
# position is unused for now (the effect is screen-anchored) but accepted so
# Crown.gd can pass it for future variations (e.g. emit from contact point).
func play_crown_pickup(_world_pos: Vector2) -> void:
	# Flash: 0 → 0.85 → 0 over ~0.55s. Sharp on, slow off so it reads as a
	# "snap" rather than a wash.
	_flash_overlay.modulate.a = 0.0
	var flash_tw: Tween = create_tween()
	flash_tw.tween_property(_flash_overlay, "modulate:a", 0.85, 0.06)
	flash_tw.tween_property(_flash_overlay, "modulate:a", 0.0, 0.5)
	# Confetti: one-shot burst. Restart triggers the pre-configured emission
	# with all particles released at once (explosiveness=1.0 in scene).
	_confetti.restart()
	_confetti.emitting = true

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
