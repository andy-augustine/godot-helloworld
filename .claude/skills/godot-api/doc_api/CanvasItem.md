## CanvasItem <- Node

Abstract base class for everything in 2D space. Canvas items are laid out in a tree; children inherit and extend their parent's transform. CanvasItem is extended by Control for GUI-related nodes, and by Node2D for 2D game objects. Any CanvasItem can draw. For this, `queue_redraw` is called by the engine, then `NOTIFICATION_DRAW` will be received on idle time to request a redraw. Because of this, canvas items don't need to be redrawn on every frame, improving the performance significantly. Several functions for drawing on the CanvasItem are provided (see `draw_*` functions). However, they can only be used inside `_draw`, its corresponding `Object._notification` or methods connected to the `draw` signal. Canvas items are drawn in tree order on their canvas layer. By default, children are on top of their parents, so a root CanvasItem will be drawn behind everything. This behavior can be changed on a per-item basis. A CanvasItem can be hidden, which will also hide its children. By adjusting various other properties of a CanvasItem, you can also modulate its color (via `modulate` or `self_modulate`), change its Z-index, blend mode, and more. Note that properties like transform, modulation, and visibility are only propagated to *direct* CanvasItem child nodes. If there is a non-CanvasItem node in between, like Node or AnimationPlayer, the CanvasItem nodes below will have an independent position and `modulate` chain. See also `top_level`.

**Props:**
- clip_children: int (CanvasItem.ClipChildrenMode) = 0
- light_mask: int = 1
- material: Material
- modulate: Color = Color(1, 1, 1, 1)
- self_modulate: Color = Color(1, 1, 1, 1)
- show_behind_parent: bool = false
- texture_filter: int (CanvasItem.TextureFilter) = 0
- texture_repeat: int (CanvasItem.TextureRepeat) = 0
- top_level: bool = false
- use_parent_material: bool = false
- visibility_layer: int = 1
- visible: bool = true
- y_sort_enabled: bool = false
- z_as_relative: bool = true
- z_index: int = 0

**Methods:**
- draw_animation_slice(animation_length: float, slice_begin: float, slice_end: float, offset: float = 0.0) - Subsequent drawing commands will be ignored unless they fall within the specified animation slice.
- draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = -1.0, antialiased: bool = false) - Draws an unfilled arc between the given angles with a uniform `color` and `width` and optional antialiasing (supported only for positive `width`).
- draw_char(font: Font, pos: Vector2, char: String, font_size: int = 16, modulate: Color = Color(1, 1, 1, 1), oversampling: float = 0.0) - Draws a string first character using a custom font.
- draw_char_outline(font: Font, pos: Vector2, char: String, font_size: int = 16, size: int = -1, modulate: Color = Color(1, 1, 1, 1), oversampling: float = 0.0) - Draws a string first character outline using a custom font.
- draw_circle(position: Vector2, radius: float, color: Color, filled: bool = true, width: float = -1.0, antialiased: bool = false) - Draws a circle, with `position` defined in local space.
- draw_colored_polygon(points: PackedVector2Array, color: Color, uvs: PackedVector2Array = PackedVector2Array(), texture: Texture2D = null) - Draws a colored polygon of any number of points, convex or concave.
- draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float = -1.0, dash: float = 2.0, aligned: bool = true, antialiased: bool = false) - Draws a dashed line from a 2D point to another, with a given color and width.
- draw_ellipse(position: Vector2, major: float, minor: float, color: Color, filled: bool = true, width: float = -1.0, antialiased: bool = false) - Draws an ellipse with semi-major axis `major` and semi-minor axis `minor`.
- draw_ellipse_arc(center: Vector2, major: float, minor: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = -1.0, antialiased: bool = false) - Draws an unfilled elliptical arc between the given angles with a uniform `color` and `width` and optional antialiasing (supported only for positive `width`).
- draw_end_animation() - After submitting all animations slices via `draw_animation_slice`, this function can be used to revert drawing to its default state (all subsequent drawing commands will be visible).
- draw_lcd_texture_rect_region(texture: Texture2D, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1)) - Draws a textured rectangle region of the font texture with LCD subpixel anti-aliasing at a given position, optionally modulated by a color.
- draw_line(from: Vector2, to: Vector2, color: Color, width: float = -1.0, antialiased: bool = false) - Draws a line from a 2D point to another, with a given color and width.
- draw_mesh(mesh: Mesh, texture: Texture2D, transform: Transform2D = Transform2D(1, 0, 0, 1, 0, 0), modulate: Color = Color(1, 1, 1, 1)) - Draws a Mesh in 2D, using the provided texture.
- draw_msdf_texture_rect_region(texture: Texture2D, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1), outline: float = 0.0, pixel_range: float = 4.0, scale: float = 1.0) - Draws a textured rectangle region of the multichannel signed distance field texture at a given position, optionally modulated by a color.
- draw_multiline(points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) - Draws multiple disconnected lines with a uniform `width` and `color`.
- draw_multiline_colors(points: PackedVector2Array, colors: PackedColorArray, width: float = -1.0, antialiased: bool = false) - Draws multiple disconnected lines with a uniform `width` and segment-by-segment coloring.
- draw_multiline_string(font: Font, pos: Vector2, text: String, alignment: int = 0, width: float = -1, font_size: int = 16, max_lines: int = -1, modulate: Color = Color(1, 1, 1, 1), brk_flags: int = 3, justification_flags: int = 3, direction: int = 0, orientation: int = 0, oversampling: float = 0.0) - Breaks `text` into lines and draws it using the specified `font` at the `pos` in local space (top-left corner).
- draw_multiline_string_outline(font: Font, pos: Vector2, text: String, alignment: int = 0, width: float = -1, font_size: int = 16, max_lines: int = -1, size: int = 1, modulate: Color = Color(1, 1, 1, 1), brk_flags: int = 3, justification_flags: int = 3, direction: int = 0, orientation: int = 0, oversampling: float = 0.0) - Breaks `text` to the lines and draws text outline using the specified `font` at the `pos` in local space (top-left corner).
- draw_multimesh(multimesh: MultiMesh, texture: Texture2D) - Draws a MultiMesh in 2D with the provided texture.
- draw_polygon(points: PackedVector2Array, colors: PackedColorArray, uvs: PackedVector2Array = PackedVector2Array(), texture: Texture2D = null) - Draws a solid polygon of any number of points, convex or concave.
- draw_polyline(points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) - Draws interconnected line segments with a uniform `color` and `width` and optional antialiasing (supported only for positive `width`).
- draw_polyline_colors(points: PackedVector2Array, colors: PackedColorArray, width: float = -1.0, antialiased: bool = false) - Draws interconnected line segments with a uniform `width`, point-by-point coloring, and optional antialiasing (supported only for positive `width`).
- draw_primitive(points: PackedVector2Array, colors: PackedColorArray, uvs: PackedVector2Array, texture: Texture2D = null) - Draws a custom primitive.
- draw_rect(rect: Rect2, color: Color, filled: bool = true, width: float = -1.0, antialiased: bool = false) - Draws a rectangle.
- draw_set_transform(position: Vector2, rotation: float = 0.0, scale: Vector2 = Vector2(1, 1)) - Sets a custom local transform for drawing via components.
- draw_set_transform_matrix(xform: Transform2D) - Sets a custom local transform for drawing via matrix.
- draw_string(font: Font, pos: Vector2, text: String, alignment: int = 0, width: float = -1, font_size: int = 16, modulate: Color = Color(1, 1, 1, 1), justification_flags: int = 3, direction: int = 0, orientation: int = 0, oversampling: float = 0.0) - Draws `text` using the specified `font` at the `pos` in local space (bottom-left corner using the baseline of the font).
- draw_string_outline(font: Font, pos: Vector2, text: String, alignment: int = 0, width: float = -1, font_size: int = 16, size: int = 1, modulate: Color = Color(1, 1, 1, 1), justification_flags: int = 3, direction: int = 0, orientation: int = 0, oversampling: float = 0.0) - Draws `text` outline using the specified `font` at the `pos` in local space (bottom-left corner using the baseline of the font).
- draw_style_box(style_box: StyleBox, rect: Rect2) - Draws a styled rectangle.
- draw_texture(texture: Texture2D, position: Vector2, modulate: Color = Color(1, 1, 1, 1)) - Draws a texture at a given position.
- draw_texture_rect(texture: Texture2D, rect: Rect2, tile: bool, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false) - Draws a textured rectangle at a given position, optionally modulated by a color.
- draw_texture_rect_region(texture: Texture2D, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false, clip_uv: bool = true) - Draws a textured rectangle from a texture's region (specified by `src_rect`) at a given position in local space, optionally modulated by a color.
- force_update_transform() - Forces the node's transform to update.
- get_canvas() -> RID - Returns the RID of the World2D canvas where this node is registered to, used by the RenderingServer.
- get_canvas_item() -> RID - Returns the internal canvas item RID used by the RenderingServer for this node.
- get_canvas_layer_node() -> CanvasLayer - Returns the CanvasLayer that contains this node, or `null` if the node is not in any CanvasLayer.
- get_canvas_transform() -> Transform2D - Returns the transform of this node, converted from its registered canvas's coordinate system to its viewport's coordinate system.
- get_global_mouse_position() -> Vector2 - Returns mouse cursor's global position relative to the CanvasLayer that contains this node.
- get_global_transform() -> Transform2D - Returns the global transform matrix of this item, i.
- get_global_transform_with_canvas() -> Transform2D - Returns the transform from the local coordinate system of this CanvasItem to the Viewports coordinate system.
- get_instance_shader_parameter(name: StringName) -> Variant - Get the value of a shader parameter as set on this instance.
- get_local_mouse_position() -> Vector2 - Returns the mouse's position in this CanvasItem using the local coordinate system of this CanvasItem.
- get_screen_transform() -> Transform2D - Returns the transform of this CanvasItem in global screen coordinates (i.
- get_transform() -> Transform2D - Returns the transform matrix of this CanvasItem.
- get_viewport_rect() -> Rect2 - Returns this node's viewport boundaries as a Rect2.
- get_viewport_transform() -> Transform2D - Returns the transform of this node, converted from its registered canvas's coordinate system to its viewport embedder's coordinate system.
- get_visibility_layer_bit(layer: int) -> bool - Returns `true` if the layer at the given index is set in `visibility_layer`.
- get_world_2d() -> World2D - Returns the World2D this node is registered to.
- hide() - Hide the CanvasItem if it's currently visible.
- is_local_transform_notification_enabled() -> bool - Returns `true` if the node receives `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` whenever its local transform changes.
- is_transform_notification_enabled() -> bool - Returns `true` if the node receives `NOTIFICATION_TRANSFORM_CHANGED` whenever its global transform changes.
- is_visible_in_tree() -> bool - Returns `true` if the node is present in the SceneTree, its `visible` property is `true` and all its ancestors are also visible.
- make_canvas_position_local(viewport_point: Vector2) -> Vector2 - Transforms `viewport_point` from the viewport's coordinates to this node's local coordinates.
- make_input_local(event: InputEvent) -> InputEvent - Returns a copy of the given `event` with its coordinates converted from global space to this CanvasItem's local space.
- move_to_front() - Moves this node below its siblings, usually causing the node to draw on top of its siblings.
- queue_redraw() - Queues the CanvasItem to redraw.
- set_instance_shader_parameter(name: StringName, value: Variant) - Set the value of a shader uniform for this instance only ().
- set_notify_local_transform(enable: bool) - If `true`, the node will receive `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` whenever its local transform changes.
- set_notify_transform(enable: bool) - If `true`, the node will receive `NOTIFICATION_TRANSFORM_CHANGED` whenever its global transform changes.
- set_visibility_layer_bit(layer: int, enabled: bool) - Set/clear individual bits on the rendering visibility layer.
- show() - Show the CanvasItem if it's currently hidden.

**Signals:**
- draw
- hidden
- item_rect_changed
- visibility_changed

**Enums:**
**Constants:** NOTIFICATION_TRANSFORM_CHANGED=2000, NOTIFICATION_LOCAL_TRANSFORM_CHANGED=35, NOTIFICATION_DRAW=30, NOTIFICATION_VISIBILITY_CHANGED=31, NOTIFICATION_ENTER_CANVAS=32, NOTIFICATION_EXIT_CANVAS=33, NOTIFICATION_WORLD_2D_CHANGED=36
**TextureFilter:** TEXTURE_FILTER_PARENT_NODE=0, TEXTURE_FILTER_NEAREST=1, TEXTURE_FILTER_LINEAR=2, TEXTURE_FILTER_NEAREST_WITH_MIPMAPS=3, TEXTURE_FILTER_LINEAR_WITH_MIPMAPS=4, TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC=5, TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC=6, TEXTURE_FILTER_MAX=7
**TextureRepeat:** TEXTURE_REPEAT_PARENT_NODE=0, TEXTURE_REPEAT_DISABLED=1, TEXTURE_REPEAT_ENABLED=2, TEXTURE_REPEAT_MIRROR=3, TEXTURE_REPEAT_MAX=4
**ClipChildrenMode:** CLIP_CHILDREN_DISABLED=0, CLIP_CHILDREN_ONLY=1, CLIP_CHILDREN_AND_DRAW=2, CLIP_CHILDREN_MAX=3

