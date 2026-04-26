class_name Skill
extends Resource

# A passive skill card. Built once per skill in Skills._ready and held in the
# Skills autoload. Speed/jump multipliers are 1.0 by default; the player reads
# them via Skills.get_speed_multiplier() / get_jump_multiplier() each physics
# frame.

@export var id: StringName
@export var display_name: String
@export var description: String
@export var color: Color = Color.WHITE
@export var speed_multiplier: float = 1.0
@export var jump_multiplier: float = 1.0
