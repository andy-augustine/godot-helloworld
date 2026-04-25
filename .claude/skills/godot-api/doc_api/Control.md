## Control <- CanvasItem

Base class for all UI-related nodes. Control features a bounding rectangle that defines its extents, an anchor position relative to its parent control or the current viewport, and offsets relative to the anchor. The offsets update automatically when the node, any of its parents, or the screen size change. For more information on Godot's UI system, anchors, offsets, and containers, see the related tutorials in the manual. To build flexible UIs, you'll need a mix of UI elements that inherit from Control and Container nodes. **Note:** Since both Node2D and Control inherit from CanvasItem, they share several concepts from the class such as the `CanvasItem.z_index` and `CanvasItem.visible` properties. **User Interface nodes and input** Godot propagates input events via viewports. Each Viewport is responsible for propagating InputEvents to their child nodes. As the `SceneTree.root` is a Window, this already happens automatically for all UI elements in your game. Input events are propagated through the SceneTree from the root node to all child nodes by calling `Node._input`. For UI elements specifically, it makes more sense to override the virtual method `_gui_input`, which filters out unrelated input events, such as by checking z-order, `mouse_filter`, focus, or if the event was inside of the control's bounding box. Call `accept_event` so no other node receives the event. Once you accept an input, it becomes handled so `Node._unhandled_input` will not process it. Only one Control node can be in focus. Only the node in focus will receive events. To get the focus, call `grab_focus`. Control nodes lose focus when another node grabs it, or if you hide the node in focus. Focus will not be represented visually if gained via mouse/touch input, only appearing with keyboard/gamepad input (for accessibility), or via `grab_focus`. Set `mouse_filter` to `MOUSE_FILTER_IGNORE` to tell a Control node to ignore mouse or touch events. You'll need it if you place an icon on top of a button. Theme resources change the control's appearance. The `theme` of a Control node affects all of its direct and indirect children (as long as a chain of controls is uninterrupted). To override some of the theme items, call one of the `add_theme_*_override` methods, like `add_theme_font_override`. You can also override theme items in the Inspector. **Note:** Theme items are *not* Object properties. This means you can't access their values using `Object.get` and `Object.set`. Instead, use the `get_theme_*` and `add_theme_*_override` methods provided by this class.

**Props:**
- accessibility_controls_nodes: NodePath[] = []
- accessibility_described_by_nodes: NodePath[] = []
- accessibility_description: String = ""
- accessibility_flow_to_nodes: NodePath[] = []
- accessibility_labeled_by_nodes: NodePath[] = []
- accessibility_live: int (AccessibilityServer.AccessibilityLiveMode) = 0
- accessibility_name: String = ""
- anchor_bottom: float = 0.0
- anchor_left: float = 0.0
- anchor_right: float = 0.0
- anchor_top: float = 0.0
- auto_translate: bool
- clip_contents: bool = false
- custom_maximum_size: Vector2 = Vector2(-1, -1)
- custom_minimum_size: Vector2 = Vector2(0, 0)
- focus_behavior_recursive: int (Control.FocusBehaviorRecursive) = 0
- focus_mode: int (Control.FocusMode) = 0
- focus_neighbor_bottom: NodePath = NodePath("")
- focus_neighbor_left: NodePath = NodePath("")
- focus_neighbor_right: NodePath = NodePath("")
- focus_neighbor_top: NodePath = NodePath("")
- focus_next: NodePath = NodePath("")
- focus_previous: NodePath = NodePath("")
- global_position: Vector2
- grow_horizontal: int (Control.GrowDirection) = 1
- grow_vertical: int (Control.GrowDirection) = 1
- layout_direction: int (Control.LayoutDirection) = 0
- localize_numeral_system: bool = true
- mouse_behavior_recursive: int (Control.MouseBehaviorRecursive) = 0
- mouse_default_cursor_shape: int (Control.CursorShape) = 0
- mouse_filter: int (Control.MouseFilter) = 0
- mouse_force_pass_scroll_events: bool = true
- offset_bottom: float = 0.0
- offset_left: float = 0.0
- offset_right: float = 0.0
- offset_top: float = 0.0
- offset_transform_enabled: bool = false
- offset_transform_pivot: Vector2 = Vector2(0, 0)
- offset_transform_pivot_ratio: Vector2 = Vector2(0.5, 0.5)
- offset_transform_position: Vector2 = Vector2(0, 0)
- offset_transform_position_ratio: Vector2 = Vector2(0, 0)
- offset_transform_rotation: float = 0.0
- offset_transform_scale: Vector2 = Vector2(1, 1)
- offset_transform_visual_only: bool = true
- physics_interpolation_mode: int (Node.PhysicsInterpolationMode) = 2
- pivot_offset: Vector2 = Vector2(0, 0)
- pivot_offset_ratio: Vector2 = Vector2(0, 0)
- position: Vector2 = Vector2(0, 0)
- propagate_maximum_size: bool = false
- rotation: float = 0.0
- rotation_degrees: float
- scale: Vector2 = Vector2(1, 1)
- shortcut_context: Node
- size: Vector2 = Vector2(0, 0)
- size_flags_horizontal: int (Control.SizeFlags) = 1
- size_flags_stretch_ratio: float = 1.0
- size_flags_vertical: int (Control.SizeFlags) = 1
- theme: Theme
- theme_type_variation: StringName = &""
- tooltip_auto_translate_mode: int (Node.AutoTranslateMode) = 0
- tooltip_text: String = ""
- translation_context: StringName = &""

**Methods:**
- accept_event() - Marks an input event as handled.
- accessibility_drag() - Starts drag-and-drop operation without using a mouse.
- accessibility_drop() - Ends drag-and-drop operation without using a mouse.
- add_theme_color_override(name: StringName, color: Color) - Creates a local override for a theme Color with the specified `name`.
- add_theme_constant_override(name: StringName, constant: int) - Creates a local override for a theme constant with the specified `name`.
- add_theme_font_override(name: StringName, font: Font) - Creates a local override for a theme Font with the specified `name`.
- add_theme_font_size_override(name: StringName, font_size: int) - Creates a local override for a theme font size with the specified `name`.
- add_theme_icon_override(name: StringName, texture: Texture2D) - Creates a local override for a theme icon with the specified `name`.
- add_theme_stylebox_override(name: StringName, stylebox: StyleBox) - Creates a local override for a theme StyleBox with the specified `name`.
- begin_bulk_theme_override() - Prevents `*_theme_*_override` methods from emitting `NOTIFICATION_THEME_CHANGED` until `end_bulk_theme_override` is called.
- end_bulk_theme_override() - Ends a bulk theme override update.
- find_next_valid_focus() -> Control - Finds the next (below in the tree) Control that can receive the focus.
- find_prev_valid_focus() -> Control - Finds the previous (above in the tree) Control that can receive the focus.
- find_valid_focus_neighbor(side: int) -> Control - Finds the next Control that can receive the focus on the specified `Side`.
- force_drag(data: Variant, preview: Control) - Forces drag and bypasses `_get_drag_data` and `set_drag_preview` by passing `data` and `preview`.
- get_anchor(side: int) -> float - Returns the anchor for the specified `Side`.
- get_begin() -> Vector2 - Returns `offset_left` and `offset_top`.
- get_bound_minimum_size() -> Vector2 - Returns the bound value of `get_combined_minimum_size` by `get_combined_maximum_size`.
- get_combined_maximum_size() -> Vector2 - Returns the combined maximum size from `custom_maximum_size` and `get_maximum_size`, as well as the `custom_maximum_size` of this node's parent if it is a Control node with `propagate_maximum_size` set to `true`.
- get_combined_minimum_size() -> Vector2 - Returns the combined minimum size from `custom_minimum_size` and `get_minimum_size`.
- get_combined_pivot_offset() -> Vector2 - Returns the combined value of `pivot_offset` and `pivot_offset_ratio`, in pixels.
- get_cursor_shape(at_position: Vector2 = Vector2(0, 0)) -> int - Returns the mouse cursor shape for this control when hovered over `at_position` in local coordinates.
- get_end() -> Vector2 - Returns `offset_right` and `offset_bottom`.
- get_focus_mode_with_override() -> int - Returns the `focus_mode`, but takes the `focus_behavior_recursive` into account.
- get_focus_neighbor(side: int) -> NodePath - Returns the focus neighbor for the specified `Side`.
- get_global_rect() -> Rect2 - Returns the position and size of the control relative to the containing canvas.
- get_maximum_size() -> Vector2 - Returns the maximum size for this control.
- get_minimum_size() -> Vector2 - Returns the minimum size for this control.
- get_mouse_filter_with_override() -> int - Returns the `mouse_filter`, but takes the `mouse_behavior_recursive` into account.
- get_offset(offset: int) -> float - Returns the offset for the specified `Side`.
- get_parent_area_size() -> Vector2 - Returns the width/height occupied in the parent control.
- get_parent_control() -> Control - Returns the parent control node.
- get_rect() -> Rect2 - Returns the position and size of the control in the coordinate system of the containing node.
- get_screen_position() -> Vector2 - Returns the position of this Control in global screen coordinates (i.
- get_theme_color(name: StringName, theme_type: StringName = &"") -> Color - Returns a Color from the first matching Theme in the tree if that Theme has a color item with the specified `name` and `theme_type`.
- get_theme_constant(name: StringName, theme_type: StringName = &"") -> int - Returns a constant from the first matching Theme in the tree if that Theme has a constant item with the specified `name` and `theme_type`.
- get_theme_default_base_scale() -> float - Returns the default base scale value from the first matching Theme in the tree if that Theme has a valid `Theme.
- get_theme_default_font() -> Font - Returns the default font from the first matching Theme in the tree if that Theme has a valid `Theme.
- get_theme_default_font_size() -> int - Returns the default font size value from the first matching Theme in the tree if that Theme has a valid `Theme.
- get_theme_font(name: StringName, theme_type: StringName = &"") -> Font - Returns a Font from the first matching Theme in the tree if that Theme has a font item with the specified `name` and `theme_type`.
- get_theme_font_size(name: StringName, theme_type: StringName = &"") -> int - Returns a font size from the first matching Theme in the tree if that Theme has a font size item with the specified `name` and `theme_type`.
- get_theme_icon(name: StringName, theme_type: StringName = &"") -> Texture2D - Returns an icon from the first matching Theme in the tree if that Theme has an icon item with the specified `name` and `theme_type`.
- get_theme_stylebox(name: StringName, theme_type: StringName = &"") -> StyleBox - Returns a StyleBox from the first matching Theme in the tree if that Theme has a stylebox item with the specified `name` and `theme_type`.
- get_tooltip(at_position: Vector2 = Vector2(0, 0)) -> String - Returns the tooltip text for the position `at_position` in the control's local coordinates, which will typically appear when the cursor is resting over this control.
- grab_click_focus() - Creates an InputEventMouseButton that attempts to click the control.
- grab_focus(hide_focus: bool = false) - Steal the focus from another control and become the focused control (see `focus_mode`).
- has_focus(ignore_hidden_focus: bool = false) -> bool - Returns `true` if this is the current focused control.
- has_theme_color(name: StringName, theme_type: StringName = &"") -> bool - Returns `true` if there is a matching Theme in the tree that has a color item with the specified `name` and `theme_type`.
- has_theme_color_override(name: StringName) -> bool - Returns `true` if there is a local override for a theme Color with the specified `name` in this Control node.
- has_theme_constant(name: StringName, theme_type: StringName = &"") -> bool - Returns `true` if there is a matching Theme in the tree that has a constant item with the specified `name` and `theme_type`.
- has_theme_constant_override(name: StringName) -> bool - Returns `true` if there is a local override for a theme constant with the specified `name` in this Control node.
- has_theme_font(name: StringName, theme_type: StringName = &"") -> bool - Returns `true` if there is a matching Theme in the tree that has a font item with the specified `name` and `theme_type`.
- has_theme_font_override(name: StringName) -> bool - Returns `true` if there is a local override for a theme Font with the specified `name` in this Control node.
- has_theme_font_size(name: StringName, theme_type: StringName = &"") -> bool - Returns `true` if there is a matching Theme in the tree that has a font size item with the specified `name` and `theme_type`.
- has_theme_font_size_override(name: StringName) -> bool - Returns `true` if there is a local override for a theme font size with the specified `name` in this Control node.
- has_theme_icon(name: StringName, theme_type: StringName = &"") -> bool - Returns `true` if there is a matching Theme in the tree that has an icon item with the specified `name` and `theme_type`.
- has_theme_icon_override(name: StringName) -> bool - Returns `true` if there is a local override for a theme icon with the specified `name` in this Control node.
- has_theme_stylebox(name: StringName, theme_type: StringName = &"") -> bool - Returns `true` if there is a matching Theme in the tree that has a stylebox item with the specified `name` and `theme_type`.
- has_theme_stylebox_override(name: StringName) -> bool - Returns `true` if there is a local override for a theme StyleBox with the specified `name` in this Control node.
- is_drag_successful() -> bool - Returns `true` if a drag operation is successful.
- is_layout_rtl() -> bool - Returns `true` if the layout is right-to-left.
- release_focus() - Give up the focus.
- remove_theme_color_override(name: StringName) - Removes a local override for a theme Color with the specified `name` previously added by `add_theme_color_override` or via the Inspector dock.
- remove_theme_constant_override(name: StringName) - Removes a local override for a theme constant with the specified `name` previously added by `add_theme_constant_override` or via the Inspector dock.
- remove_theme_font_override(name: StringName) - Removes a local override for a theme Font with the specified `name` previously added by `add_theme_font_override` or via the Inspector dock.
- remove_theme_font_size_override(name: StringName) - Removes a local override for a theme font size with the specified `name` previously added by `add_theme_font_size_override` or via the Inspector dock.
- remove_theme_icon_override(name: StringName) - Removes a local override for a theme icon with the specified `name` previously added by `add_theme_icon_override` or via the Inspector dock.
- remove_theme_stylebox_override(name: StringName) - Removes a local override for a theme StyleBox with the specified `name` previously added by `add_theme_stylebox_override` or via the Inspector dock.
- reset_size() - Resets the size to `get_combined_minimum_size`.
- set_anchor(side: int, anchor: float, keep_offset: bool = false, push_opposite_anchor: bool = true) - Sets the anchor for the specified `Side` to `anchor`.
- set_anchor_and_offset(side: int, anchor: float, offset: float, push_opposite_anchor: bool = false) - Works the same as `set_anchor`, but instead of `keep_offset` argument and automatic update of offset, it allows to set the offset yourself (see `set_offset`).
- set_anchors_and_offsets_preset(preset: int, resize_mode: int = 0, margin: int = 0) - Sets both anchor preset and offset preset.
- set_anchors_preset(preset: int, keep_offsets: bool = false) - Sets the anchors to a `preset` from `Control.
- set_begin(position: Vector2) - Sets `offset_left` and `offset_top` at the same time.
- set_drag_forwarding(drag_func: Callable, can_drop_func: Callable, drop_func: Callable) - Sets the given callables to be used instead of the control's own drag-and-drop virtual methods.
- set_drag_preview(control: Control) - Shows the given control at the mouse pointer.
- set_end(position: Vector2) - Sets `offset_right` and `offset_bottom` at the same time.
- set_focus_neighbor(side: int, neighbor: NodePath) - Sets the focus neighbor for the specified `Side` to the Control at `neighbor` node path.
- set_global_position(position: Vector2, keep_offsets: bool = false) - Sets the `global_position` to given `position`.
- set_offset(side: int, offset: float) - Sets the offset for the specified `Side` to `offset`.
- set_offsets_preset(preset: int, resize_mode: int = 0, margin: int = 0) - Sets the offsets to a `preset` from `Control.
- set_position(position: Vector2, keep_offsets: bool = false) - Sets the `position` to given `position`.
- set_size(size: Vector2, keep_offsets: bool = false) - Sets the size (see `size`).
- update_maximum_size() - Invalidates the maximum size cache in this node and in parent nodes up to top level.
- update_minimum_size() - Invalidates the minimum size cache in this node and in parent nodes up to top level.
- warp_mouse(position: Vector2) - Moves the mouse cursor to `position`, relative to `position` of this Control.

**Signals:**
- focus_entered
- focus_exited
- gui_input(event: InputEvent)
- maximum_size_changed
- minimum_size_changed
- mouse_entered
- mouse_exited
- resized
- size_flags_changed
- theme_changed

**Enums:**
**FocusMode:** FOCUS_NONE=0, FOCUS_CLICK=1, FOCUS_ALL=2, FOCUS_ACCESSIBILITY=3
**FocusBehaviorRecursive:** FOCUS_BEHAVIOR_INHERITED=0, FOCUS_BEHAVIOR_DISABLED=1, FOCUS_BEHAVIOR_ENABLED=2
**MouseBehaviorRecursive:** MOUSE_BEHAVIOR_INHERITED=0, MOUSE_BEHAVIOR_DISABLED=1, MOUSE_BEHAVIOR_ENABLED=2
**Constants:** NOTIFICATION_RESIZED=40, NOTIFICATION_MOUSE_ENTER=41, NOTIFICATION_MOUSE_EXIT=42, NOTIFICATION_MOUSE_ENTER_SELF=60, NOTIFICATION_MOUSE_EXIT_SELF=61, NOTIFICATION_FOCUS_ENTER=43, NOTIFICATION_FOCUS_EXIT=44, NOTIFICATION_THEME_CHANGED=45, NOTIFICATION_SCROLL_BEGIN=47, NOTIFICATION_SCROLL_END=48, ...
**CursorShape:** CURSOR_ARROW=0, CURSOR_IBEAM=1, CURSOR_POINTING_HAND=2, CURSOR_CROSS=3, CURSOR_WAIT=4, CURSOR_BUSY=5, CURSOR_DRAG=6, CURSOR_CAN_DROP=7, CURSOR_FORBIDDEN=8, CURSOR_VSIZE=9, ...
**LayoutPreset:** PRESET_TOP_LEFT=0, PRESET_TOP_RIGHT=1, PRESET_BOTTOM_LEFT=2, PRESET_BOTTOM_RIGHT=3, PRESET_CENTER_LEFT=4, PRESET_CENTER_TOP=5, PRESET_CENTER_RIGHT=6, PRESET_CENTER_BOTTOM=7, PRESET_CENTER=8, PRESET_LEFT_WIDE=9, ...
**LayoutPresetMode:** PRESET_MODE_MINSIZE=0, PRESET_MODE_KEEP_WIDTH=1, PRESET_MODE_KEEP_HEIGHT=2, PRESET_MODE_KEEP_SIZE=3
**SizeFlags:** SIZE_SHRINK_BEGIN=0, SIZE_FILL=1, SIZE_EXPAND=2, SIZE_EXPAND_FILL=3, SIZE_SHRINK_CENTER=4, SIZE_SHRINK_END=8
**MouseFilter:** MOUSE_FILTER_STOP=0, MOUSE_FILTER_PASS=1, MOUSE_FILTER_IGNORE=2
**GrowDirection:** GROW_DIRECTION_BEGIN=0, GROW_DIRECTION_END=1, GROW_DIRECTION_BOTH=2
**Anchor:** ANCHOR_BEGIN=0, ANCHOR_END=1
**LayoutDirection:** LAYOUT_DIRECTION_INHERITED=0, LAYOUT_DIRECTION_APPLICATION_LOCALE=1, LAYOUT_DIRECTION_LTR=2, LAYOUT_DIRECTION_RTL=3, LAYOUT_DIRECTION_SYSTEM_LOCALE=4, LAYOUT_DIRECTION_MAX=5, LAYOUT_DIRECTION_LOCALE=1
**TextDirection:** TEXT_DIRECTION_INHERITED=3, TEXT_DIRECTION_AUTO=0, TEXT_DIRECTION_LTR=1, TEXT_DIRECTION_RTL=2

