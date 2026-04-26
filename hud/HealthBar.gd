extends Control

# Segmented health bar. Drawn via _draw() so we have full control over the
# Metroid-style segment dividers, color gradient, and damage flash — a stock
# ProgressBar would need theme overrides to match, and this is ~40 lines either way.
#
# Driven by the parent HUD calling set_health(current, maximum) when the player
# emits health_changed. The bar lerps toward `_current` so changes feel like a
# drain rather than a snap, shifts color from green → yellow → red as health
# drops, and pulses white briefly when damage lands.

const SEG_GAP: float = 2.0       # px gap between segments
const BAR_HEIGHT: float = 14.0
const CORNER_RADIUS: float = 3.0

# Bar color shifts with remaining health: green at full, yellow around half,
# red as it approaches empty. Two-segment lerp keyed at ratio 0.5 so the
# midpoint reads cleanly as yellow rather than a muddy green-red blend.
const COLOR_HEALTH_HIGH: Color = Color(0.25, 0.9, 0.35)   # green
const COLOR_HEALTH_MID: Color = Color(1.0, 0.85, 0.2)     # yellow
const COLOR_HEALTH_LOW: Color = Color(1.0, 0.25, 0.25)    # red
const COLOR_BG: Color = Color(0.05, 0.05, 0.1, 0.85)
const COLOR_DAMAGE_FLASH: Color = Color(1.0, 1.0, 1.0)    # white pulse — reads as a hit even when the bar is already red
const COLOR_SEG_LINE: Color = Color(0.0, 0.0, 0.0, 0.5)

var _current: float = 100.0
var _maximum: float = 100.0
var _display: float = 100.0       # lerped value for smooth drain animation
var _damage_flash: float = 0.0    # 0..1, decays after hit
var _segments: int = 4

func set_health(current: int, maximum: int) -> void:
	if float(current) < _current:
		_damage_flash = 1.0
	_current = float(current)
	_maximum = float(maximum)

func _process(delta: float) -> void:
	_display = lerpf(_display, _current, 12.0 * delta)
	_damage_flash = max(_damage_flash - delta * 3.0, 0.0)
	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = BAR_HEIGHT
	var fill_ratio: float = _display / _maximum if _maximum > 0.0 else 0.0

	# Background
	draw_rect(Rect2(0, 0, w, h), COLOR_BG)

	# Health-based color: green (full) → yellow (half) → red (low).
	# Then white-pulse on top during the brief damage flash.
	var base_color: Color
	if fill_ratio >= 0.5:
		base_color = COLOR_HEALTH_MID.lerp(COLOR_HEALTH_HIGH, (fill_ratio - 0.5) * 2.0)
	else:
		base_color = COLOR_HEALTH_LOW.lerp(COLOR_HEALTH_MID, fill_ratio * 2.0)
	var fill_color: Color = base_color.lerp(COLOR_DAMAGE_FLASH, _damage_flash)
	draw_rect(Rect2(0, 0, w * fill_ratio, h), fill_color)

	# Segment dividers
	for i in range(1, _segments):
		var x: float = (w / float(_segments)) * float(i)
		draw_line(Vector2(x, 0), Vector2(x, h), COLOR_SEG_LINE, SEG_GAP)

	# Outer border
	draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.15), false, 1.0)
