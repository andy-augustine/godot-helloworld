## Texture2D <- Texture

A texture works by registering an image in the video hardware, which then can be used in 3D models or 2D Sprite2D or GUI Control. Textures are often created by loading them from a file. See `@GDScript.load`. Texture2D is a base for other resources. It cannot be used directly. **Note:** The maximum texture size is 16384×16384 pixels due to graphics hardware limitations. Larger textures may fail to import.

**Methods:**
- create_placeholder() -> Resource - Creates a placeholder version of this resource (PlaceholderTexture2D).
- draw(canvas_item: RID, position: Vector2, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false) - Draws the texture using a CanvasItem with the RenderingServer API at the specified `position`.
- draw_rect(canvas_item: RID, rect: Rect2, tile: bool, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false) - Draws the texture using a CanvasItem with the RenderingServer API.
- draw_rect_region(canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false, clip_uv: bool = true) - Draws a part of the texture using a CanvasItem with the RenderingServer API.
- get_format() -> int - Returns the image format of the texture.
- get_height() -> int - Returns the texture height in pixels.
- get_image() -> Image - Returns an Image that is a copy of data from this Texture2D (a new Image is created each time).
- get_mipmap_count() -> int - Returns the number of mipmaps of the texture.
- get_size() -> Vector2 - Returns the texture size in pixels.
- get_width() -> int - Returns the texture width in pixels.
- has_alpha() -> bool - Returns `true` if this Texture2D has an alpha channel.
- has_mipmaps() -> bool - Returns `true` if the texture has mipmaps.

