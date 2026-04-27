extends Node

# Fire-and-forget SFX manager. Autoload (registered via Project Settings → Autoload).
# Loads streams into a Dictionary, plays via a pool of AudioStreamPlayers so
# overlapping calls don't clobber each other (e.g. fast jump → land → jump).
#
# Usage:
#   AudioManager.play_sfx("jump", 0.1)              # ±10% pitch variation
#   AudioManager.play_sfx("heavy_landing", 0.0, -3) # quieter
#
# To register a new SFX: add an entry to SFX below + drop the .ogg file in
# assets/audio/sfx/. No code changes elsewhere.
#
# See plans/audio-foundations.md for the design rationale (pool vs per-call,
# why wall-slide is separate, etc.).

const SFX_BUS := "SFX"
const POOL_SIZE := 8

# Map of name → AudioStream. Add a row here + drop the .ogg file in
# assets/audio/sfx/ to register a new SFX. Wall-slide is NOT here — it
# loops on a dedicated AudioStreamPlayer on the player node, not via the pool.
const SFX: Dictionary = {
	"jump": preload("res://assets/audio/sfx/jump.ogg"),
	"heavy_landing": preload("res://assets/audio/sfx/heavy_landing.ogg"),
	"dash": preload("res://assets/audio/sfx/dash.ogg"),
	"pickup": preload("res://assets/audio/sfx/pickup.ogg"),
	"player_hit": preload("res://assets/audio/sfx/player_hit.ogg"),
	"player_death": preload("res://assets/audio/sfx/player_death.ogg"),
}

var _player_pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = SFX_BUS
		add_child(p)
		_player_pool.append(p)

# Play a registered SFX. Picks a free player from the pool. Drops the call
# silently if no player is free (rare with POOL_SIZE=8 for our SFX volume).
#
#   sfx_name        — key into SFX dictionary
#   pitch_variation — 0.0 = exact pitch, 0.1 = ±10% randomization (anti-monotony)
#   volume_db       — adjustment from the stream's natural volume (negative = quieter)
func play_sfx(sfx_name: String, pitch_variation: float = 0.0, volume_db: float = 0.0) -> void:
	if not SFX.has(sfx_name):
		push_warning("AudioManager: unknown SFX '%s'" % sfx_name)
		return
	var player := _get_free_player()
	if player == null:
		return
	player.stream = SFX[sfx_name]
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.volume_db = volume_db
	player.play()

func _get_free_player() -> AudioStreamPlayer:
	for p in _player_pool:
		if not p.playing:
			return p
	return null
