extends Control

# Segmented health bar. Drawn via _draw() so we have full control over the
# Metroid-style segment dividers, color gradient, damage flash, critical pulse,
# animated shimmer sweep, ambient halo, and cap glint — a stock ProgressBar
# would need a half-dozen theme overrides to come close.
#
# Driven by the parent HUD calling set_health(current, maximum) when the player
# emits health_changed. The bar lerps toward `_current` so changes feel like a
# drain rather than a snap, shifts color from green → yellow → red as health
# drops, pulses when damage lands, and shimmers continuously so it reads as
# "alive" instead of static UI.

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

# Sizzle layer — always on, gives the bar life without competing with damage cues.
const SHIMMER_PERIOD: float = 2.4         # seconds for one left-to-right shimmer pass
const SHIMMER_WIDTH_RATIO: float = 0.18   # band width as fraction of bar width
const SHIMMER_PEAK_ALPHA: float = 0.55    # 0..1 brightness add at peak of band
const HALO_PERIOD: float = 3.2            # seconds for one halo pulse cycle
const HALO_BASE_ALPHA: float = 0.06       # halo glow at trough
const HALO_PEAK_ALPHA: float = 0.18       # halo glow at peak
const HALO_PADDING: float = 4.0           # px outside bar each direction

var _current: float = 100.0
var _maximum: float = 100.0
var _display: float = 100.0       # lerped value for smooth drain animation
var _damage_flash: float = 0.0    # 0..1, decays after hit
var _segments: int = 4
var _pulse_phase: float = 0.0     # accumulated radians for critical-pulse sin
var _critical_pulse: float = 0.0  # 0..1 brightness add when in critical zone
var _shimmer_t: float = 0.0       # 0..1 looped position of shimmer band
var _halo_t: float = 0.0          # accumulated radians for halo pulse

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

	# Sizzle: shimmer sweeps left-to-right continuously, halo pulses on its own beat
	_shimmer_t = fmod(_shimmer_t + delta / SHIMMER_PERIOD, 1.0)
	_halo_t += delta * TAU / HALO_PERIOD

	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = BAR_HEIGHT
	var fill_ratio: float = _display / _maximum if _maximum > 0.0 else 0.0

	# Layer 0 — outer halo glow. Pulses subtly so the bar feels "alive" even
	# when nothing's happening. Two stacked rects with falling alpha give a
	# cheap pseudo-radial-glow without a shader.
	var halo_pulse: float = 0.5 + 0.5 * sin(_halo_t)
	var halo_alpha: float = lerpf(HALO_BASE_ALPHA, HALO_PEAK_ALPHA, halo_pulse)
	var fill_color_for_halo: Color = _compute_fill_color(fill_ratio)
	# Outer ring — wider, dimmer
	draw_rect(
		Rect2(-HALO_PADDING - 2, -HALO_PADDING - 2, w + 2 * (HALO_PADDING + 2), h + 2 * (HALO_PADDING + 2)),
		Color(fill_color_for_halo.r, fill_color_for_halo.g, fill_color_for_halo.b, halo_alpha * 0.35)
	)
	# Inner ring — tighter, brighter
	draw_rect(
		Rect2(-HALO_PADDING, -HALO_PADDING, w + 2 * HALO_PADDING, h + 2 * HALO_PADDING),
		Color(fill_color_for_halo.r, fill_color_for_halo.g, fill_color_for_halo.b, halo_alpha)
	)

	# Layer 1 — drop shadow behind the bar body
	draw_rect(Rect2(1, 2, w, h), Color(0, 0, 0, 0.55))

	# Layer 2 — outer outline
	draw_rect(Rect2(-1, -1, w + 2, h + 2), Color(0.05, 0.05, 0.08, 0.92))

	# Layer 3 — well/background
	draw_rect(Rect2(0, 0, w, h), COLOR_BG)

	# Layer 4 — the fill itself, with health-color gradient, damage flash, critical pulse
	var fill_color: Color = _compute_fill_color(fill_ratio)
	var fill_w: float = w * fill_ratio

	# Body fill
	draw_rect(Rect2(0, 0, fill_w, h), fill_color)
	# Top gloss highlight — top 35% of the fill, lightened toward white
	var gloss_h: float = h * 0.35
	draw_rect(Rect2(0, 0, fill_w, gloss_h), fill_color.lerp(Color(1, 1, 1), 0.32))
	# Bottom shade — bottom 30%, darkened
	var shade_h: float = h * 0.3
	draw_rect(Rect2(0, h - shade_h, fill_w, shade_h), fill_color.darkened(0.25))

	# Layer 5 — animated shimmer sweep. Bright vertical band that travels
	# across the fill so the bar feels alive. Position is the band's center.
	if fill_w > 4.0:
		var band_w: float = w * SHIMMER_WIDTH_RATIO
		var band_center_x: float = -band_w + (w + band_w * 2.0) * _shimmer_t
		# Build the band as 5 narrow rects with falling alpha for a soft falloff.
		# Cheap fake of a gradient — looks great at this scale.
		for i in range(5):
			var rel: float = (float(i) - 2.0) / 2.0  # -1..+1 across the band
			var x_offset: float = rel * (band_w * 0.5)
			var slice_w: float = band_w / 5.0
			var slice_alpha: float = (1.0 - abs(rel)) * SHIMMER_PEAK_ALPHA
			var slice_x: float = band_center_x + x_offset - slice_w * 0.5
			# Clip to fill area
			if slice_x + slice_w < 0.0 or slice_x > fill_w:
				continue
			var clipped_x: float = maxf(slice_x, 0.0)
			var clipped_w: float = minf(slice_x + slice_w, fill_w) - clipped_x
			if clipped_w <= 0.0:
				continue
			draw_rect(
				Rect2(clipped_x, 0, clipped_w, h),
				Color(1.0, 1.0, 1.0, slice_alpha)
			)

	# Layer 6 — golden cap on the right edge of the fill. Reads as a "tip" or
	# "leading edge" — gives the fill a sense of momentum/direction.
	if fill_ratio > 0.0 and fill_ratio < 1.0:
		var cap_w: float = 3.0
		var cap_x: float = maxf(fill_w - cap_w, 0.0)
		draw_rect(Rect2(cap_x, 0, cap_w, h), fill_color.lerp(Color(1, 1, 1), 0.6))
		draw_rect(Rect2(cap_x + cap_w - 1, 0, 1, h), Color(1, 1, 1, 0.95))

	# Layer 7 — segment dividers + pip caps. Pips are small bright dots at the
	# top of each segment line, reading as polished cap markers.
	for i in range(1, _segments):
		var x: float = (w / float(_segments)) * float(i)
		draw_line(Vector2(x, 0), Vector2(x, h), COLOR_SEG_LINE, SEG_GAP)
		# Pip cap — small bright dot at the top of the divider
		draw_rect(Rect2(x - 1.5, -1, 3, 3), Color(0.9, 0.95, 1.0, 0.8))

	# Layer 8 — outer top-edge highlight (catches "light")
	draw_line(Vector2(0, 0), Vector2(w, 0), Color(1, 1, 1, 0.32), 1.0)
	# Layer 9 — outer rim
	draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.22), false, 1.0)


# Composite the fill color from health ratio + damage flash + critical pulse.
# Extracted because both _draw layers (halo + body) need it for color matching.
func _compute_fill_color(fill_ratio: float) -> Color:
	var base_color: Color
	if fill_ratio >= 0.5:
		base_color = COLOR_HEALTH_MID.lerp(COLOR_HEALTH_HIGH, (fill_ratio - 0.5) * 2.0)
	else:
		base_color = COLOR_HEALTH_LOW.lerp(COLOR_HEALTH_MID, fill_ratio * 2.0)
	var fill_color: Color = base_color.lerp(COLOR_DAMAGE_FLASH, _damage_flash)
	if _critical_pulse > 0.0:
		fill_color = fill_color.lerp(Color(1, 1, 1), _critical_pulse)
	return fill_color
