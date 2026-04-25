## Color

A color represented in RGBA format by a red (`r`), green (`g`), blue (`b`), and alpha (`a`) component. Each component is a 32-bit floating-point value, usually ranging from `0.0` to `1.0`. Some properties (such as `CanvasItem.modulate`) may support values greater than `1.0`, for overbright or HDR (High Dynamic Range) colors. Colors can be created in a number of ways: By the various Color constructors, by static methods such as `from_hsv`, and by using a name from the set of standardized colors based on with the addition of `TRANSPARENT`. Although Color may be used to store values of any encoding, the red (`r`), green (`g`), and blue (`b`) properties of Color are expected by Godot to be encoded using the unless otherwise stated. This color encoding is used by many traditional art and web tools, making it easy to match colors between Godot and these tools. Godot uses color primaries, which are used by the sRGB standard. All physical simulation, such as lighting calculations, and colorimetry transformations, such as `get_luminance`, must be performed on linearly encoded values to produce correct results. When performing these calculations, convert Color to and from linear encoding using `srgb_to_linear` and `linear_to_srgb`. **Note:** In a boolean context, a Color will evaluate to `false` if it is equal to `Color(0, 0, 0, 1)` (opaque black). Otherwise, a Color will always evaluate to `true`.

**Props:**
- a: float = 1.0
- a8: int = 255
- b: float = 0.0
- b8: int = 0
- g: float = 0.0
- g8: int = 0
- h: float = 0.0
- ok_hsl_h: float = 0.0
- ok_hsl_l: float = 0.0
- ok_hsl_s: float = 0.0
- r: float = 0.0
- r8: int = 0
- s: float = 0.0
- v: float = 0.0

**Methods:**
- blend(over: Color) -> Color - Returns a new color resulting from overlaying this color over the given color.
- clamp(min: Color = Color(0, 0, 0, 0), max: Color = Color(1, 1, 1, 1)) -> Color - Returns a new color with all components clamped between the components of `min` and `max`, by running `@GlobalScope.
- darkened(amount: float) -> Color - Returns a new color resulting from making this color darker by the specified `amount` (ratio from 0.
- from_hsv(h: float, s: float, v: float, alpha: float = 1.0) -> Color - Constructs a color from an .
- from_ok_hsl(h: float, s: float, l: float, alpha: float = 1.0) -> Color - Constructs a color from an .
- from_rgba8(r8: int, g8: int, b8: int, a8: int = 255) -> Color - Returns a Color constructed from red (`r8`), green (`g8`), blue (`b8`), and optionally alpha (`a8`) integer channels, each divided by `255.
- from_rgbe9995(rgbe: int) -> Color - Decodes a Color from an RGBE9995 format integer.
- from_string(str: String, default: Color) -> Color - Creates a Color from the given string, which can be either an HTML color code or a named color (case-insensitive).
- get_luminance() -> float - Returns the light intensity of the color, as a value between 0.
- hex(hex: int) -> Color - Returns the Color associated with the provided `hex` integer in 32-bit RGBA format (8 bits per channel).
- hex64(hex: int) -> Color - Returns the Color associated with the provided `hex` integer in 64-bit RGBA format (16 bits per channel).
- html(rgba: String) -> Color - Returns a new color from `rgba`, an HTML hexadecimal color string.
- html_is_valid(color: String) -> bool - Returns `true` if `color` is a valid HTML hexadecimal color string.
- inverted() -> Color - Returns the color with its `r`, `g`, and `b` components inverted (`(1 - r, 1 - g, 1 - b, a)`).
- is_equal_approx(to: Color) -> bool - Returns `true` if this color and `to` are approximately equal, by running `@GlobalScope.
- lerp(to: Color, weight: float) -> Color - Returns the linear interpolation between this color's components and `to`'s components.
- lightened(amount: float) -> Color - Returns a new color resulting from making this color lighter by the specified `amount`, which should be a ratio from 0.
- linear_to_srgb() -> Color - Returns a copy of the color that is encoded using the .
- srgb_to_linear() -> Color - Returns a copy of the color that uses linear encoding.
- to_abgr32() -> int - Returns the color converted to a 32-bit integer in ABGR format (each component is 8 bits).
- to_abgr64() -> int - Returns the color converted to a 64-bit integer in ABGR format (each component is 16 bits).
- to_argb32() -> int - Returns the color converted to a 32-bit integer in ARGB format (each component is 8 bits).
- to_argb64() -> int - Returns the color converted to a 64-bit integer in ARGB format (each component is 16 bits).
- to_html(with_alpha: bool = true) -> String - Returns the color converted to an HTML hexadecimal color String in RGBA format, without the hash (`#`) prefix.
- to_rgba32() -> int - Returns the color converted to a 32-bit integer in RGBA format (each component is 8 bits).
- to_rgba64() -> int - Returns the color converted to a 64-bit integer in RGBA format (each component is 16 bits).

**Enums:**
**Constants:** ALICE_BLUE=Color(0.9411765, 0.972549, 1, 1), ANTIQUE_WHITE=Color(0.98039216, 0.92156863, 0.84313726, 1), AQUA=Color(0, 1, 1, 1), AQUAMARINE=Color(0.49803922, 1, 0.83137256, 1), AZURE=Color(0.9411765, 1, 1, 1), BEIGE=Color(0.9607843, 0.9607843, 0.8627451, 1), BISQUE=Color(1, 0.89411765, 0.76862746, 1), BLACK=Color(0, 0, 0, 1), BLANCHED_ALMOND=Color(1, 0.92156863, 0.8039216, 1), BLUE=Color(0, 0, 1, 1), ...

