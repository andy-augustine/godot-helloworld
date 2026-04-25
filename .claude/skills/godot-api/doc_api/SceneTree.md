## SceneTree <- MainLoop

As one of the most important classes, the SceneTree manages the hierarchy of nodes in a scene, as well as scenes themselves. Nodes can be added, fetched and removed. The whole scene tree (and thus the current scene) can be paused. Scenes can be loaded, switched and reloaded. You can also use the SceneTree to organize your nodes into **groups**: every node can be added to as many groups as you want to create, e.g. an "enemy" group. You can then iterate these groups or even call methods and set properties on all the nodes belonging to any given group. SceneTree is the default MainLoop implementation used by the engine, and is thus in charge of the game loop.

**Props:**
- auto_accept_quit: bool = true
- current_scene: Node
- debug_collisions_hint: bool = false
- debug_navigation_hint: bool = false
- debug_paths_hint: bool = false
- edited_scene_root: Node
- multiplayer_poll: bool = true
- paused: bool = false
- physics_interpolation: bool = false
- quit_on_go_back: bool = true
- root: Window

**Methods:**
- call_group(group: StringName, method: StringName) - Calls `method` on each node inside this tree added to the given `group`.
- call_group_flags(flags: int, group: StringName, method: StringName) - Calls the given `method` on each node inside this tree added to the given `group`.
- change_scene_to_file(path: String) -> int - Changes the running scene to the one at the given `path`, after loading it into a PackedScene and creating a new instance.
- change_scene_to_node(node: Node) -> int - Changes the running scene to the provided Node.
- change_scene_to_packed(packed_scene: PackedScene) -> int - Changes the running scene to a new instance of the given PackedScene (which must be valid).
- create_timer(time_sec: float, process_always: bool = true, process_in_physics: bool = false, ignore_time_scale: bool = false) -> SceneTreeTimer - Returns a new SceneTreeTimer.
- create_tween() -> Tween - Creates and returns a new Tween processed in this tree.
- get_first_node_in_group(group: StringName) -> Node - Returns the first Node found inside the tree, that has been added to the given `group`, in scene hierarchy order.
- get_frame() -> int - Returns how many physics process steps have been processed, since the application started.
- get_multiplayer(for_path: NodePath = NodePath("")) -> MultiplayerAPI - Searches for the MultiplayerAPI configured for the given path, if one does not exist it searches the parent paths until one is found.
- get_node_count() -> int - Returns the number of nodes inside this tree.
- get_node_count_in_group(group: StringName) -> int - Returns the number of nodes assigned to the given group.
- get_nodes_in_group(group: StringName) -> Node[] - Returns an Array containing all nodes inside this tree, that have been added to the given `group`, in scene hierarchy order.
- get_processed_tweens() -> Tween[] - Returns an Array of currently existing Tweens in the tree, including paused tweens.
- has_group(name: StringName) -> bool - Returns `true` if a node added to the given group `name` exists in the tree.
- is_accessibility_enabled() -> bool - Returns `true` if accessibility features are enabled, and accessibility information updates are actively processed.
- is_accessibility_supported() -> bool - Returns `true` if accessibility features are supported by the OS and enabled in project settings.
- notify_group(group: StringName, notification: int) - Calls `Object.
- notify_group_flags(call_flags: int, group: StringName, notification: int) - Calls `Object.
- queue_delete(obj: Object) - Queues the given `obj` to be deleted, calling its `Object.
- quit(exit_code: int = 0) - Quits the application at the end of the current iteration, with the given `exit_code`.
- reload_current_scene() -> int - Reloads the currently active scene, replacing `current_scene` with a new instance of its original PackedScene.
- set_group(group: StringName, property: String, value: Variant) - Sets the given `property` to `value` on all nodes inside this tree added to the given `group`.
- set_group_flags(call_flags: int, group: StringName, property: String, value: Variant) - Sets the given `property` to `value` on all nodes inside this tree added to the given `group`.
- set_multiplayer(multiplayer: MultiplayerAPI, root_path: NodePath = NodePath("")) - Sets a custom MultiplayerAPI with the given `root_path` (controlling also the relative subpaths), or override the default one if `root_path` is empty.
- unload_current_scene() - If a current scene is loaded, calling this method will unload it.

**Signals:**
- node_added(node: Node)
- node_configuration_warning_changed(node: Node)
- node_removed(node: Node)
- node_renamed(node: Node)
- physics_frame
- process_frame
- scene_changed
- tree_changed
- tree_process_mode_changed

**Enums:**
**GroupCallFlags:** GROUP_CALL_DEFAULT=0, GROUP_CALL_REVERSE=1, GROUP_CALL_DEFERRED=2, GROUP_CALL_UNIQUE=4

