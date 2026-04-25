## Engine <- Object

The Engine singleton allows you to query and modify the project's run-time parameters, such as frames per second, time scale, and others. It also stores information about the current build of Godot, such as the current version.

**Props:**
- max_fps: int = 0
- max_physics_steps_per_frame: int = 8
- physics_jitter_fix: float = 0.5
- physics_ticks_per_second: int = 60
- print_error_messages: bool = true
- print_to_stdout: bool = true
- time_scale: float = 1.0

**Methods:**
- capture_script_backtraces(include_variables: bool = false) -> ScriptBacktrace[] - Captures and returns backtraces from all registered script languages.
- get_architecture_name() -> String - Returns the name of the CPU architecture the Godot binary was built for.
- get_author_info() -> Dictionary - Returns the engine author information as a Dictionary, where each entry is an Array of strings with the names of notable contributors to the Godot Engine: `lead_developers`, `founders`, `project_managers`, and `developers`.
- get_copyright_info() -> Dictionary[] - Returns an Array of dictionaries with copyright information for every component of Godot's source code.
- get_donor_info() -> Dictionary - Returns a Dictionary of categorized donor names.
- get_frames_drawn() -> int - Returns the total number of frames drawn since the engine started.
- get_frames_per_second() -> float - Returns the average frames rendered every second (FPS), also known as the framerate.
- get_license_info() -> Dictionary - Returns a Dictionary of licenses used by Godot and included third party components.
- get_license_text() -> String - Returns the full Godot license text.
- get_main_loop() -> MainLoop - Returns the instance of the MainLoop.
- get_physics_frames() -> int - Returns the total number of frames passed since the engine started.
- get_physics_interpolation_fraction() -> float - Returns the fraction through the current physics tick we are at the time of rendering the frame.
- get_process_frames() -> int - Returns the total number of frames passed since the engine started.
- get_script_language(index: int) -> ScriptLanguage - Returns an instance of a ScriptLanguage with the given `index`.
- get_script_language_count() -> int - Returns the number of available script languages.
- get_singleton(name: StringName) -> Object - Returns the global singleton with the given `name`, or `null` if it does not exist.
- get_singleton_list() -> PackedStringArray - Returns a list of names of all available global singletons.
- get_version_info() -> Dictionary - Returns the current engine version information as a Dictionary containing the following entries: - `major` - Major version number as an int; - `minor` - Minor version number as an int; - `patch` - Patch version number as an int; - `hex` - Full version encoded as a hexadecimal int with one byte (2 hex digits) per number (see example below); - `status` - Status (such as "beta", "rc1", "rc2", "stable", etc.
- get_write_movie_path() -> String - Returns the path to the MovieWriter's output file, or an empty string if the engine wasn't started in Movie Maker mode.
- has_singleton(name: StringName) -> bool - Returns `true` if a singleton with the given `name` exists in the global scope.
- is_editor_hint() -> bool - Returns `true` if the script is currently running inside the editor, otherwise returns `false`.
- is_embedded_in_editor() -> bool - Returns `true` if the engine is running embedded in the editor.
- is_in_physics_frame() -> bool - Returns `true` if the engine is inside the fixed physics process step of the main loop.
- register_script_language(language: ScriptLanguage) -> int - Registers a ScriptLanguage instance to be available with `ScriptServer`.
- register_singleton(name: StringName, instance: Object) - Registers the given Object `instance` as a singleton, available globally under `name`.
- unregister_script_language(language: ScriptLanguage) -> int - Unregisters the ScriptLanguage instance from `ScriptServer`.
- unregister_singleton(name: StringName) - Removes the singleton registered under `name`.

