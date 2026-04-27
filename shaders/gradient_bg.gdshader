// Vertical gradient with subtle noise dither for procedural-background tier.
// Used as the backdrop layer in each room, behind all gameplay geometry.
// See ART_CONVENTIONS.md "Procedural-background" sub-tier.
//
// Per-room instances configure color_top + color_bottom in their .tscn.
// noise_amount adds a tiny per-pixel dither so big flat fills don't band.

shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.05, 0.06, 0.10, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.10, 0.12, 0.18, 1.0);
uniform float noise_amount : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec4 grad = mix(color_top, color_bottom, UV.y);
	float n = fract(sin(dot(UV * 100.0, vec2(12.9898, 78.233))) * 43758.5453);
	grad.rgb += (n - 0.5) * noise_amount;
	COLOR = grad;
}
