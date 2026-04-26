extends Control

# Segmented energy bar. Drawn via _draw() so we have full control over the
# Metroid-style segment dividers, glow, and damage flash — a stock ProgressBar
# would need theme overrides to match, and this is ~30 lines either way.
#
# Driven by the parent HUD calling set_health(current, maximum) when the player
# emits health_changed. The bar lerps toward `_current` so changes feel like a
# drain rather than a snap, and pulses red briefly when damage lands.

const SEG_GAP: float = 2.0       # px gap between segments
const BAR_HEIGHT: float = 14.0
const CORNER_RADIUS: float = 3.0

const COLOR_FILL: Color = Color("00e5ff")       # cyan accent (matches player rig)
const COLOR_BG: Color = Color(0.05, 0.05, 0.1, 0.85)
const COLOR_DAMAGE: Color = Color(1.0, 0.2, 0.2)
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

	# Fill (lerp toward damage color when flashing)
	var fill_color: Color = COLOR_FILL.lerp(COLOR_DAMAGE, _damage_flash)
	draw_rect(Rect2(0, 0, w * fill_ratio, h), fill_color)

	# Segment dividers
	for i in range(1, _segments):
		var x: float = (w / float(_segments)) * float(i)
		draw_line(Vector2(x, 0), Vector2(x, h), COLOR_SEG_LINE, SEG_GAP)

	# Outer border
	draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.15), false, 1.0)
