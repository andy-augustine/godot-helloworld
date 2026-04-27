extends Area2D

# Pickup that grants a movement ability via the Inventory autoload, then
# disappears in a quick burst. The ability is determined by `ability_id`,
# which must be a key in Abilities.REGISTRY. Subclasses (or just instances
# with the export set) re-skin via the inspector, no code change needed.
#
# Lives in group "pickup". Sits as a child of a Room scene at world-space
# position. Picked up on body_entered with the player.

@export var ability_id: StringName = &""
@export var float_amplitude: float = 4.0   # vertical bob amplitude
@export var float_period: float = 1.4      # full bob cycle in seconds

@onready var _visual: ColorRect = $Visual
@onready var _sparkle: CPUParticles2D = $Sparkle
@onready var _audio: AudioStreamPlayer = $PickupAudio

var _t: float = 0.0
var _origin_y: float = 0.0


func _ready() -> void:
	add_to_group("pickup")
	_origin_y = position.y

	# If the player already owns this ability (e.g. they re-entered the room),
	# don't render at all — there's no proper room-state autoload yet, so the
	# pickup is responsible for its own "already collected" check. When room-
	# state persistence lands (backlog/gamedev.md, eventually), this becomes
	# the room state's job and pickups can simplify.
	var inv := get_node_or_null("/root/Inventory")
	if inv and ability_id != &"" and inv.has(ability_id):
		queue_free()
		return

	body_entered.connect(_on_body_entered)
	# Color the visual + sparkle to the ability's category if registered
	if Abilities.has_ability(ability_id):
		var cat: int = Abilities.category(ability_id)
		var hue := _hue_for(cat)
		_visual.color = hue
		_sparkle.color = hue


func _process(delta: float) -> void:
	_t += delta
	# Vertical bob — gentle sine, doesn't accumulate drift
	position.y = _origin_y + sin(_t * TAU / float_period) * float_amplitude


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if ability_id == &"":
		push_warning("Pickup: empty ability_id, skipping grant")
		return
	var inv := get_node_or_null("/root/Inventory")
	if inv == null:
		push_warning("Pickup: Inventory autoload missing, skipping grant")
		return
	if inv.has(ability_id):
		queue_free()  # already owned, just clean up
		return

	inv.grant(ability_id)
	# Burst on grab — restart particles for a satisfying poof
	_sparkle.amount = 28
	_sparkle.initial_velocity_max = 180.0
	_sparkle.lifetime = 0.6
	_sparkle.restart()
	_audio.play()
	# Disable further triggers while the burst plays out, then free.
	# set_deferred is required because we're inside a body_entered callback
	# (mid physics flush). See feedback_gdscript_practices.md rule 8.
	set_deferred("monitoring", false)
	_visual.visible = false
	# Brief delay so particles + audio finish
	get_tree().create_timer(0.7).timeout.connect(queue_free)


func _hue_for(cat: int) -> Color:
	match cat:
		0: return Color("9b6cff")  # Jumps
		1: return Color("ff8c1a")  # Runs
		2: return Color("4ad6c2")  # Climbs
		_: return Color.WHITE
