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

# Critical-health pulse: when fill_ratio drops below CRITICAL_THRESHOLD, the
# fill brightens and dims at PULSE_FREQUENCY Hz, drawing the eye to the danger.
const CRITICAL_THRESHOLD: float = 0.25
const PULSE_FREQUENCY: float = 4.0       # Hz
const PULSE_BRIGHTEN_AMOUNT: float = 0.45 # 0..1 toward white at peak

var _current: float = 100.0
var _maximum: float = 100.0
var _display: float = 100.0       # lerped value for smooth drain animation
var _damage_flash: float = 0.0    # 0..1, decays after hit
var _segments: int = 4
var _pulse_phase: float = 0.0     # accumulated radians for critical-pulse sin
var _critical_pulse: float = 0.0  # 0..1 brightness add when in critical zone

func set_health(current: int, maximum: int) -> void:
	if float(current) < _current:
		_damage_flash = 1.0
	_current = float(current)
	_maximum = float(maximum)

func _process(delta: float) -> void:
	_display = lerpf(_display, _current, 12.0 * delta)
	_damage_flash = max(_damage_flash - delta * 3.0, 0.0)

	var fill_ratio: float = _display / _maximum if _maximum > 0.0 else 0.0
	if fill_ratio < CRITICAL_THRESHOLD and fill_ratio > 0.0:
		_pulse_phase += delta * PULSE_FREQUENCY * TAU
		_critical_pulse = (0.5 + 0.5 * sin(_pulse_phase)) * PULSE_BRIGHTEN_AMOUNT
	else:
		_pulse_phase = 0.0
		_critical_pulse = 0.0

	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = BAR_HEIGHT
	var fill_ratio: float = _display / _maximum if _maximum > 0.0 else 0.0

	# Drop shadow — sits behind the bar, suggests depth against backdrop
	draw_rect(Rect2(1, 2, w, h), Color(0, 0, 0, 0.45))

	# Outer outline (procedural-animated tier border)
	draw_rect(Rect2(-1, -1, w + 2, h + 2), Color(0.05, 0.05, 0.08, 0.85))

	# Background well
	draw_rect(Rect2(0, 0, w, h), COLOR_BG)

	# Health-based color: green (full) → yellow (half) → red (low).
	# Then white-pulse on top during the brief damage flash.
	var base_color: Color
	if fill_ratio >= 0.5:
		base_color = COLOR_HEALTH_MID.lerp(COLOR_HEALTH_HIGH, (fill_ratio - 0.5) * 2.0)
	else:
		base_color = COLOR_HEALTH_LOW.lerp(COLOR_HEALTH_MID, fill_ratio * 2.0)
	var fill_color: Color = base_color.lerp(COLOR_DAMAGE_FLASH, _damage_flash)
	# Critical pulse stacks on top: brightens toward white at the sin peaks
	if _critical_pulse > 0.0:
		fill_color = fill_color.lerp(Color(1, 1, 1), _critical_pulse)

	var fill_w: float = w * fill_ratio
	# Body fill
	draw_rect(Rect2(0, 0, fill_w, h), fill_color)
	# Top gloss highlight — top 35% of the fill, lightened toward white
	var gloss_h: float = h * 0.35
	draw_rect(Rect2(0, 0, fill_w, gloss_h), fill_color.lerp(Color(1, 1, 1), 0.25))
	# Bottom shade — bottom 30%, darkened slightly for grounded depth
	var shade_h: float = h * 0.3
	draw_rect(Rect2(0, h - shade_h, fill_w, shade_h), fill_color.darkened(0.2))

	# Segment dividers — subtle, on top of the fill
	for i in range(1, _segments):
		var x: float = (w / float(_segments)) * float(i)
		draw_line(Vector2(x, 0), Vector2(x, h), COLOR_SEG_LINE, SEG_GAP)

	# Outer top-edge highlight
	draw_line(Vector2(0, 0), Vector2(w, 0), Color(1, 1, 1, 0.25), 1.0)
	# Outer rim
	draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.18), false, 1.0)
