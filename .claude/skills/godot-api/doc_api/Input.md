## Input <- Object

The Input singleton handles key presses, mouse buttons and movement, gamepads, and input actions. Actions and their events can be set in the **Input Map** tab in **Project > Project Settings**, or with the InputMap class. **Note:** Input's methods reflect the global input state and are not affected by `Control.accept_event` or `Viewport.set_input_as_handled`, as those methods only deal with the way input is propagated in the SceneTree.

**Props:**
- emulate_mouse_from_touch: bool
- emulate_touch_from_mouse: bool
- ignore_joypad_on_unfocused_application: bool
- mouse_mode: int (Input.MouseMode)
- use_accumulated_input: bool

**Methods:**
- action_press(action: StringName, strength: float = 1.0) - This will simulate pressing the specified action.
- action_release(action: StringName) - If the specified action is already pressed, this will release it.
- add_joy_mapping(mapping: String, update_existing: bool = false) - Adds a new mapping entry (in SDL2 format) to the mapping database.
- clear_joy_motion_sensors_calibration(device: int) - Clears the calibration information for the specified joypad's motion sensors, if it has any and if they were calibrated.
- flush_buffered_events() - Sends all input events which are in the current buffer to the game loop.
- get_accelerometer() -> Vector3 - Returns the acceleration in m/s² of the device's accelerometer sensor, if the device has one.
- get_action_raw_strength(action: StringName, exact_match: bool = false) -> float - Returns a value between 0 and 1 representing the raw intensity of the given action, ignoring the action's deadzone.
- get_action_strength(action: StringName, exact_match: bool = false) -> float - Returns a value between 0 and 1 representing the intensity of the given action.
- get_axis(negative_action: StringName, positive_action: StringName) -> float - Get axis input by specifying two actions, one negative and one positive.
- get_connected_joypads() -> int[] - Returns an Array containing the device IDs of all currently connected joypads.
- get_current_cursor_shape() -> int - Returns the currently assigned cursor shape.
- get_gravity() -> Vector3 - Returns the gravity in m/s² of the device's accelerometer sensor, if the device has one.
- get_gyroscope() -> Vector3 - Returns the rotation rate in rad/s around a device's X, Y, and Z axes of the gyroscope sensor, if the device has one.
- get_joy_accelerometer(device: int) -> Vector3 - Returns the acceleration, including the force of gravity, in m/s² of the joypad's accelerometer sensor, if the joypad has one and it's currently enabled.
- get_joy_axis(device: int, axis: int) -> float - Returns the current value of the joypad axis at index `axis`.
- get_joy_gravity(device: int) -> Vector3 - Returns the gravity in m/s² of the joypad's accelerometer sensor, if the joypad has one and it's currently enabled.
- get_joy_guid(device: int) -> String - Returns an SDL-compatible device GUID on platforms that use gamepad remapping, e.
- get_joy_gyroscope(device: int) -> Vector3 - Returns the rotation rate in rad/s around a joypad's X, Y, and Z axes of the gyroscope sensor, if the joypad has one and it's currently enabled.
- get_joy_info(device: int) -> Dictionary - Returns a dictionary with extra platform-specific information about the device, e.
- get_joy_motion_sensors_calibration(device: int) -> Dictionary - Returns the calibration information about the specified joypad's motion sensors in the form of a Dictionary, if it has any and if they have been calibrated, otherwise returns an empty Dictionary.
- get_joy_motion_sensors_rate(device: int) -> float - Returns the joypad's motion sensor rate in Hz, if the joypad has motion sensors and they're currently enabled.
- get_joy_name(device: int) -> String - Returns the name of the joypad at the specified device index, e.
- get_joy_vibration_duration(device: int) -> float - Returns the duration of the current vibration effect in seconds.
- get_joy_vibration_remaining_duration(device: int) -> float - Returns the remaining duration of the current vibration effect in seconds.
- get_joy_vibration_strength(device: int) -> Vector2 - Returns the strength of the joypad vibration: x is the strength of the weak motor, and y is the strength of the strong motor.
- get_last_mouse_screen_velocity() -> Vector2 - Returns the last mouse velocity in screen coordinates.
- get_last_mouse_velocity() -> Vector2 - Returns the last mouse velocity.
- get_magnetometer() -> Vector3 - Returns the magnetic field strength in micro-Tesla for all axes of the device's magnetometer sensor, if the device has one.
- get_mouse_button_mask() -> int - Returns mouse buttons as a bitmask.
- get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2 - Gets an input vector by specifying four actions for the positive and negative X and Y axes.
- has_joy_light(device: int) -> bool - Returns `true` if the joypad has an LED light that can change colors and/or brightness.
- has_joy_motion_sensors(device: int) -> bool - Returns `true` if the joypad has motion sensors (accelerometer and gyroscope).
- has_joy_vibration(device: int) -> bool - Returns `true` if the joypad supports vibration.
- is_action_just_pressed(action: StringName, exact_match: bool = false) -> bool - Returns `true` when the user has *started* pressing the action event in the current frame or physics tick.
- is_action_just_pressed_by_event(action: StringName, event: InputEvent, exact_match: bool = false) -> bool - Returns `true` when the user has *started* pressing the action event in the current frame or physics tick, and the first event that triggered action press in the current frame/physics tick was `event`.
- is_action_just_released(action: StringName, exact_match: bool = false) -> bool - Returns `true` when the user *stops* pressing the action event in the current frame or physics tick.
- is_action_just_released_by_event(action: StringName, event: InputEvent, exact_match: bool = false) -> bool - Returns `true` when the user *stops* pressing the action event in the current frame or physics tick, and the first event that triggered action release in the current frame/physics tick was `event`.
- is_action_pressed(action: StringName, exact_match: bool = false) -> bool - Returns `true` if you are pressing the action event.
- is_anything_pressed() -> bool - Returns `true` if any action, key, joypad button, or mouse button is being pressed.
- is_joy_button_pressed(device: int, button: int) -> bool - Returns `true` if you are pressing the joypad button at index `button`.
- is_joy_known(device: int) -> bool - Returns `true` if the system knows the specified device.
- is_joy_motion_sensors_calibrated(device: int) -> bool - Returns `true` if the joypad's motion sensors have been calibrated.
- is_joy_motion_sensors_calibrating(device: int) -> bool - Returns `true` if the joypad's motion sensors are currently being calibrated.
- is_joy_motion_sensors_enabled(device: int) -> bool - Returns `true` if the requested joypad has motion sensors (accelerometer and gyroscope) and they are currently enabled.
- is_joy_vibrating(device: int) -> bool - Returns `true` if the joypad is still vibrating after a call to `start_joy_vibration`.
- is_key_label_pressed(keycode: int) -> bool - Returns `true` if you are pressing the key with the `keycode` printed on it.
- is_key_pressed(keycode: int) -> bool - Returns `true` if you are pressing the Latin key in the current keyboard layout.
- is_mouse_button_pressed(button: int) -> bool - Returns `true` if you are pressing the mouse button specified with `MouseButton`.
- is_physical_key_pressed(keycode: int) -> bool - Returns `true` if you are pressing the key in the physical location on the 101/102-key US QWERTY keyboard.
- parse_input_event(event: InputEvent) - Feeds an InputEvent to the game.
- remove_joy_mapping(guid: String) - Removes all mappings from the internal database that match the given GUID.
- set_accelerometer(value: Vector3) - Sets the acceleration value of the accelerometer sensor.
- set_custom_mouse_cursor(image: Resource, shape: int = 0, hotspot: Vector2 = Vector2(0, 0)) - Sets a custom mouse cursor image, which is only visible inside the game window, for the given mouse `shape`.
- set_default_cursor_shape(shape: int = 0) - Sets the default cursor shape to be used in the viewport instead of `CURSOR_ARROW`.
- set_gravity(value: Vector3) - Sets the gravity value of the accelerometer sensor.
- set_gyroscope(value: Vector3) - Sets the value of the rotation rate of the gyroscope sensor.
- set_joy_light(device: int, color: Color) - Sets the joypad's LED light, if available, to the specified color.
- set_joy_motion_sensors_calibration(device: int, calibration_info: Dictionary) - Sets the specified joypad's calibration information.
- set_joy_motion_sensors_enabled(device: int, enable: bool) - Enables or disables the motion sensors (accelerometer and gyroscope), if available, on the specified joypad.
- set_magnetometer(value: Vector3) - Sets the value of the magnetic field of the magnetometer sensor.
- should_ignore_device(vendor_id: int, product_id: int) -> bool - Queries whether an input device should be ignored or not.
- start_joy_motion_sensors_calibration(device: int) - Starts the process of calibrating the specified joypad's gyroscope, if it has one.
- start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0) - Starts to vibrate the joypad.
- stop_joy_motion_sensors_calibration(device: int) - Stops the calibration process of the specified joypad's motion sensors.
- stop_joy_vibration(device: int) - Stops the vibration of the joypad started with `start_joy_vibration`.
- vibrate_handheld(duration_ms: int = 500, amplitude: float = -1.0) - Vibrate the handheld device for the specified duration in milliseconds.
- warp_mouse(position: Vector2) - Sets the mouse position to the specified vector, provided in pixels and relative to an origin at the upper left corner of the currently focused Window Manager game window.

**Signals:**
- joy_connection_changed(device: int, connected: bool)

**Enums:**
**MouseMode:** MOUSE_MODE_VISIBLE=0, MOUSE_MODE_HIDDEN=1, MOUSE_MODE_CAPTURED=2, MOUSE_MODE_CONFINED=3, MOUSE_MODE_CONFINED_HIDDEN=4, MOUSE_MODE_MAX=5
**CursorShape:** CURSOR_ARROW=0, CURSOR_IBEAM=1, CURSOR_POINTING_HAND=2, CURSOR_CROSS=3, CURSOR_WAIT=4, CURSOR_BUSY=5, CURSOR_DRAG=6, CURSOR_CAN_DROP=7, CURSOR_FORBIDDEN=8, CURSOR_VSIZE=9, ...

