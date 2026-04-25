## AnimationPlayer <- AnimationMixer

An animation player is used for general-purpose playback of animations. It contains a dictionary of AnimationLibrary resources and custom blend times between animation transitions. Some methods and properties use a single key to reference an animation directly. These keys are formatted as the key for the library, followed by a forward slash, then the key for the animation within the library, for example `"movement/run"`. If the library's key is an empty string (known as the default library), the forward slash is omitted, being the same key used by the library. AnimationPlayer is better-suited than Tween for more complex animations, for example ones with non-trivial timings. It can also be used over Tween if the animation track editor is more convenient than doing it in code. Updating the target properties of animations occurs at the process frame.

**Props:**
- assigned_animation: StringName
- autoplay: StringName = &""
- current_animation: StringName = &""
- current_animation_length: float
- current_animation_position: float
- movie_quit_on_finish: bool = false
- playback_auto_capture: bool = true
- playback_auto_capture_duration: float = -1.0
- playback_auto_capture_ease_type: int (Tween.EaseType) = 0
- playback_auto_capture_transition_type: int (Tween.TransitionType) = 0
- playback_default_blend_time: float = 0.0
- speed_scale: float = 1.0

**Methods:**
- animation_get_next(animation_from: StringName) -> StringName - Returns the key of the animation which is queued to play after the `animation_from` animation.
- animation_set_next(animation_from: StringName, animation_to: StringName) - Triggers the `animation_to` animation when the `animation_from` animation completes.
- clear_queue() - Clears all queued, unplayed animations.
- get_blend_time(animation_from: StringName, animation_to: StringName) -> float - Returns the blend time (in seconds) between two animations, referenced by their keys.
- get_method_call_mode() -> int - Returns the call mode used for "Call Method" tracks.
- get_playing_speed() -> float - Returns the actual playing speed of current animation or `0` if not playing.
- get_process_callback() -> int - Returns the process notification in which to update animations.
- get_queue() -> StringName[] - Returns a list of the animation keys that are currently queued to play.
- get_root() -> NodePath - Returns the node which node path references will travel from.
- get_section_end_time() -> float - Returns the end time of the section currently being played.
- get_section_start_time() -> float - Returns the start time of the section currently being played.
- has_section() -> bool - Returns `true` if an animation is currently playing with a section.
- is_animation_active() -> bool - Returns `true` if the an animation is currently active.
- is_playing() -> bool - Returns `true` if an animation is currently playing (even if `speed_scale` and/or `custom_speed` are `0`).
- pause() - Pauses the currently playing animation.
- play(name: StringName = &"", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) - Plays the animation with key `name`.
- play_backwards(name: StringName = &"", custom_blend: float = -1) - Plays the animation with key `name` in reverse.
- play_section(name: StringName = &"", start_time: float = -1, end_time: float = -1, custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) - Plays the animation with key `name` and the section starting from `start_time` and ending on `end_time`.
- play_section_backwards(name: StringName = &"", start_time: float = -1, end_time: float = -1, custom_blend: float = -1) - Plays the animation with key `name` and the section starting from `start_time` and ending on `end_time` in reverse.
- play_section_with_markers(name: StringName = &"", start_marker: StringName = &"", end_marker: StringName = &"", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) - Plays the animation with key `name` and the section starting from `start_marker` and ending on `end_marker`.
- play_section_with_markers_backwards(name: StringName = &"", start_marker: StringName = &"", end_marker: StringName = &"", custom_blend: float = -1) - Plays the animation with key `name` and the section starting from `start_marker` and ending on `end_marker` in reverse.
- play_with_capture(name: StringName = &"", duration: float = -1.0, custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false, trans_type: int = 0, ease_type: int = 0) - See also `AnimationMixer.
- queue(name: StringName) - Queues an animation for playback once the current animation and all previously queued animations are done.
- reset_section() - Resets the current section.
- seek(seconds: float, update: bool = false, update_only: bool = false) - Seeks the animation to the `seconds` point in time (in seconds).
- set_blend_time(animation_from: StringName, animation_to: StringName, sec: float) - Specifies a blend time (in seconds) between two animations, referenced by their keys.
- set_method_call_mode(mode: int) - Sets the call mode used for "Call Method" tracks.
- set_process_callback(mode: int) - Sets the process notification in which to update animations.
- set_root(path: NodePath) - Sets the node which node path references will travel from.
- set_section(start_time: float = -1, end_time: float = -1) - Changes the start and end times of the section being played.
- set_section_with_markers(start_marker: StringName = &"", end_marker: StringName = &"") - Changes the start and end markers of the section being played.
- stop(keep_state: bool = false) - Stops the currently playing animation.

**Signals:**
- animation_changed(old_name: StringName, new_name: StringName)
- current_animation_changed(name: StringName)

**Enums:**
**AnimationProcessCallback:** ANIMATION_PROCESS_PHYSICS=0, ANIMATION_PROCESS_IDLE=1, ANIMATION_PROCESS_MANUAL=2
**AnimationMethodCallMode:** ANIMATION_METHOD_CALL_DEFERRED=0, ANIMATION_METHOD_CALL_IMMEDIATE=1

