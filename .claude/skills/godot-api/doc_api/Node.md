## Node <- Object

Nodes are Godot's building blocks. They can be assigned as the child of another node, resulting in a tree arrangement. A given node can contain any number of nodes as children with the requirement that all siblings (direct children of a node) should have unique names. A tree of nodes is called a *scene*. Scenes can be saved to the disk and then instantiated into other scenes. This allows for very high flexibility in the architecture and data model of Godot projects. **Scene tree:** The SceneTree contains the active tree of nodes. When a node is added to the scene tree, it receives the `NOTIFICATION_ENTER_TREE` notification and its `_enter_tree` callback is triggered. Child nodes are always added *after* their parent node, i.e. the `_enter_tree` callback of a parent node will be triggered before its child's. Once all nodes have been added in the scene tree, they receive the `NOTIFICATION_READY` notification and their respective `_ready` callbacks are triggered. For groups of nodes, the `_ready` callback is called in reverse order, starting with the children and moving up to the parent nodes. This means that when adding a node to the scene tree, the following order will be used for the callbacks: `_enter_tree` of the parent, `_enter_tree` of the children, `_ready` of the children and finally `_ready` of the parent (recursively for the entire scene tree). **Processing:** Nodes can override the "process" state, so that they receive a callback on each frame requesting them to process (do something). Normal processing (callback `_process`, toggled with `set_process`) happens as fast as possible and is dependent on the frame rate, so the processing time *delta* (in seconds) is passed as an argument. Physics processing (callback `_physics_process`, toggled with `set_physics_process`) happens a fixed number of times per second (60 by default) and is useful for code related to the physics engine. Nodes can also process input events. When present, the `_input` function will be called for each input that the program receives. In many cases, this can be overkill (unless used for simple projects), and the `_unhandled_input` function might be preferred; it is called when the input event was not handled by anyone else (typically, GUI Control nodes), ensuring that the node only receives the events that were meant for it. To keep track of the scene hierarchy (especially when instantiating scenes into other scenes), an "owner" can be set for the node with the `owner` property. This keeps track of who instantiated what. This is mostly useful when writing editors and tools, though. Finally, when a node is freed with `Object.free` or `queue_free`, it will also free all its children. **Groups:** Nodes can be added to as many groups as you want to be easy to manage, you could create groups like "enemies" or "collectables" for example, depending on your game. See `add_to_group`, `is_in_group` and `remove_from_group`. You can then retrieve all nodes in these groups, iterate them and even call methods on groups via the methods on SceneTree. **Networking with nodes:** After connecting to a server (or making one, see ENetMultiplayerPeer), it is possible to use the built-in RPC (remote procedure call) system to communicate over the network. By calling `rpc` with a method name, it will be called locally and in all connected peers (peers = clients and the server that accepts connections). To identify which node receives the RPC call, Godot will use its NodePath (make sure node names are the same on all peers). Also, take a look at the high-level networking tutorial and corresponding demos. **Note:** The `script` property is part of the Object class, not Node. It isn't exposed like most properties but does have a setter and getter (see `Object.set_script` and `Object.get_script`).

**Props:**
- auto_translate_mode: int (Node.AutoTranslateMode) = 0
- editor_description: String = ""
- multiplayer: MultiplayerAPI
- name: StringName
- owner: Node
- physics_interpolation_mode: int (Node.PhysicsInterpolationMode) = 0
- process_mode: int (Node.ProcessMode) = 0
- process_physics_priority: int = 0
- process_priority: int = 0
- process_thread_group: int (Node.ProcessThreadGroup) = 0
- process_thread_group_order: int
- process_thread_messages: int (Node.ProcessThreadMessages)
- scene_file_path: String
- unique_name_in_owner: bool = false

**Methods:**
- add_child(node: Node, force_readable_name: bool = false, internal: int = 0) - Adds a child `node`.
- add_sibling(sibling: Node, force_readable_name: bool = false) - Adds a `sibling` node to this node's parent, and moves the added sibling right below this node.
- add_to_group(group: StringName, persistent: bool = false) - Adds the node to the `group`.
- atr(message: String, context: StringName = "") -> String - Translates a `message`, using the translation catalogs configured in the Project Settings.
- atr_n(message: String, plural_message: StringName, n: int, context: StringName = "") -> String - Translates a `message` or `plural_message`, using the translation catalogs configured in the Project Settings.
- call_deferred_thread_group(method: StringName) -> Variant - This function is similar to `Object.
- call_thread_safe(method: StringName) -> Variant - This function ensures that the calling of this function will succeed, no matter whether it's being done from a thread or not.
- can_auto_translate() -> bool - Returns `true` if this node can automatically translate messages depending on the current locale.
- can_process() -> bool - Returns `true` if the node can receive processing notifications and input callbacks (`NOTIFICATION_PROCESS`, `_input`, etc.
- create_tween() -> Tween - Creates a new Tween and binds it to this node.
- duplicate(flags: int = 15) -> Node - Duplicates the node, returning a new node with all of its properties, signals, groups, and children copied from the original, recursively.
- find_child(pattern: String, recursive: bool = true, owned: bool = true) -> Node - Finds the first descendant of this node whose `name` matches `pattern`, returning `null` if no match is found.
- find_children(pattern: String, type: String = "", recursive: bool = true, owned: bool = true) -> Node[] - Finds all descendants of this node whose names match `pattern`, returning an empty Array if no match is found.
- find_parent(pattern: String) -> Node - Finds the first ancestor of this node whose `name` matches `pattern`, returning `null` if no match is found.
- get_accessibility_element() -> RID - Returns main accessibility element RID.
- get_child(idx: int, include_internal: bool = false) -> Node - Fetches a child node by its index.
- get_child_count(include_internal: bool = false) -> int - Returns the number of children of this node.
- get_children(include_internal: bool = false) -> Node[] - Returns all children of this node inside an Array.
- get_groups() -> StringName[] - Returns an Array of group names that the node has been added to.
- get_index(include_internal: bool = false) -> int - Returns this node's order among its siblings.
- get_last_exclusive_window() -> Window - Returns the Window that contains this node, or the last exclusive child in a chain of windows starting with the one that contains this node.
- get_multiplayer_authority() -> int - Returns the peer ID of the multiplayer authority for this node.
- get_node(path: NodePath) -> Node - Fetches a node.
- get_node_and_resource(path: NodePath) -> Array - Fetches a node and its most nested resource as specified by the NodePath's subname.
- get_node_or_null(path: NodePath) -> Node - Fetches a node by NodePath.
- get_node_rpc_config() -> Variant - Returns a Dictionary mapping method names to their RPC configuration defined for this node using `rpc_config`.
- get_orphan_node_ids() -> int[] - Returns object IDs of all orphan nodes (nodes outside the SceneTree).
- get_parent() -> Node - Returns this node's parent node, or `null` if the node doesn't have a parent.
- get_path() -> NodePath - Returns the node's absolute path, relative to the `SceneTree.
- get_path_to(node: Node, use_unique_path: bool = false) -> NodePath - Returns the relative NodePath from this node to the specified `node`.
- get_physics_process_delta_time() -> float - Returns the time elapsed (in seconds) since the last physics callback.
- get_process_delta_time() -> float - Returns the time elapsed (in seconds) since the last process callback.
- get_scene_instance_load_placeholder() -> bool - Returns `true` if this node is an instance load placeholder.
- get_tree() -> SceneTree - Returns the SceneTree that contains this node.
- get_tree_string() -> String - Returns the tree as a String.
- get_tree_string_pretty() -> String - Similar to `get_tree_string`, this returns the tree as a String.
- get_viewport() -> Viewport - Returns the node's closest Viewport ancestor, if the node is inside the tree.
- get_window() -> Window - Returns the Window that contains this node.
- has_node(path: NodePath) -> bool - Returns `true` if the `path` points to a valid node.
- has_node_and_resource(path: NodePath) -> bool - Returns `true` if `path` points to a valid node and its subnames point to a valid Resource, e.
- is_ancestor_of(node: Node) -> bool - Returns `true` if the given `node` is a direct or indirect child of this node.
- is_displayed_folded() -> bool - Returns `true` if the node is folded (collapsed) in the Scene dock.
- is_editable_instance(node: Node) -> bool - Returns `true` if `node` has editable children enabled relative to this node.
- is_greater_than(node: Node) -> bool - Returns `true` if the given `node` occurs later in the scene hierarchy than this node.
- is_in_group(group: StringName) -> bool - Returns `true` if this node has been added to the given `group`.
- is_inside_tree() -> bool - Returns `true` if this node is currently inside a SceneTree.
- is_multiplayer_authority() -> bool - Returns `true` if the local system is the multiplayer authority of this node.
- is_node_ready() -> bool - Returns `true` if the node is ready, i.
- is_part_of_edited_scene() -> bool - Returns `true` if the node is part of the scene currently opened in the editor.
- is_physics_interpolated() -> bool - Returns `true` if physics interpolation is enabled for this node (see `physics_interpolation_mode`).
- is_physics_interpolated_and_enabled() -> bool - Returns `true` if physics interpolation is enabled (see `physics_interpolation_mode`) **and** enabled in the SceneTree.
- is_physics_processing() -> bool - Returns `true` if physics processing is enabled (see `set_physics_process`).
- is_physics_processing_internal() -> bool - Returns `true` if internal physics processing is enabled (see `set_physics_process_internal`).
- is_processing() -> bool - Returns `true` if processing is enabled (see `set_process`).
- is_processing_input() -> bool - Returns `true` if the node is processing input (see `set_process_input`).
- is_processing_internal() -> bool - Returns `true` if internal processing is enabled (see `set_process_internal`).
- is_processing_shortcut_input() -> bool - Returns `true` if the node is processing shortcuts (see `set_process_shortcut_input`).
- is_processing_unhandled_input() -> bool - Returns `true` if the node is processing unhandled input (see `set_process_unhandled_input`).
- is_processing_unhandled_key_input() -> bool - Returns `true` if the node is processing unhandled key input (see `set_process_unhandled_key_input`).
- move_child(child_node: Node, to_index: int) - Moves `child_node` to the given index.
- notify_deferred_thread_group(what: int) - Similar to `call_deferred_thread_group`, but for notifications.
- notify_thread_safe(what: int) - Similar to `call_thread_safe`, but for notifications.
- print_orphan_nodes() - Prints all orphan nodes (nodes outside the SceneTree).
- print_tree() - Prints the node and its children to the console, recursively.
- print_tree_pretty() - Prints the node and its children to the console, recursively.
- propagate_call(method: StringName, args: Array = [], parent_first: bool = false) - Calls the given `method` name, passing `args` as arguments, on this node and all of its children, recursively.
- propagate_notification(what: int) - Calls `Object.
- queue_accessibility_update() - Queues an accessibility information update for this node.
- queue_free() - Queues this node to be deleted at the end of the current frame.
- remove_child(node: Node) - Removes a child `node`.
- remove_from_group(group: StringName) - Removes the node from the given `group`.
- reparent(new_parent: Node, keep_global_transform: bool = true) - Changes the parent of this Node to the `new_parent`.
- replace_by(node: Node, keep_groups: bool = false) - Replaces this node by the given `node`.
- request_ready() - Requests `_ready` to be called again the next time the node enters the tree.
- reset_physics_interpolation() - When physics interpolation is active, moving a node to a radically different transform (such as placement within a level) can result in a visible glitch as the object is rendered moving from the old to new position over the physics tick.
- rpc(method: StringName) -> int - Sends a remote procedure call request for the given `method` to peers on the network (and locally), sending additional arguments to the method called by the RPC.
- rpc_config(method: StringName, config: Variant) - Changes the RPC configuration for the given `method`.
- rpc_id(peer_id: int, method: StringName) -> int - Sends a `rpc` to a specific peer identified by `peer_id` (see `MultiplayerPeer.
- set_deferred_thread_group(property: StringName, value: Variant) - Similar to `call_deferred_thread_group`, but for setting properties.
- set_display_folded(fold: bool) - If set to `true`, the node appears folded in the Scene dock.
- set_editable_instance(node: Node, is_editable: bool) - Set to `true` to allow all nodes owned by `node` to be available, and editable, in the Scene dock, even if their `owner` is not the scene root.
- set_multiplayer_authority(id: int, recursive: bool = true) - Sets the node's multiplayer authority to the peer with the given peer `id`.
- set_physics_process(enable: bool) - If set to `true`, enables physics (fixed framerate) processing.
- set_physics_process_internal(enable: bool) - If set to `true`, enables internal physics for this node.
- set_process(enable: bool) - If set to `true`, enables processing.
- set_process_input(enable: bool) - If set to `true`, enables input processing.
- set_process_internal(enable: bool) - If set to `true`, enables internal processing for this node.
- set_process_shortcut_input(enable: bool) - If set to `true`, enables shortcut processing for this node.
- set_process_unhandled_input(enable: bool) - If set to `true`, enables unhandled input processing.
- set_process_unhandled_key_input(enable: bool) - If set to `true`, enables unhandled key input processing.
- set_scene_instance_load_placeholder(load_placeholder: bool) - If set to `true`, the node becomes an InstancePlaceholder when packed and instantiated from a PackedScene.
- set_thread_safe(property: StringName, value: Variant) - Similar to `call_thread_safe`, but for setting properties.
- set_translation_domain_inherited() - Makes this node inherit the translation domain from its parent node.
- update_configuration_warnings() - Refreshes the warnings displayed for this node in the Scene dock.

**Signals:**
- child_entered_tree(node: Node)
- child_exiting_tree(node: Node)
- child_order_changed
- editor_description_changed(node: Node)
- editor_state_changed
- ready
- renamed
- replacing_by(node: Node)
- tree_entered
- tree_exited
- tree_exiting

**Enums:**
**Constants:** NOTIFICATION_ENTER_TREE=10, NOTIFICATION_EXIT_TREE=11, NOTIFICATION_MOVED_IN_PARENT=12, NOTIFICATION_READY=13, NOTIFICATION_PAUSED=14, NOTIFICATION_UNPAUSED=15, NOTIFICATION_PHYSICS_PROCESS=16, NOTIFICATION_PROCESS=17, NOTIFICATION_PARENTED=18, NOTIFICATION_UNPARENTED=19, ...
**ProcessMode:** PROCESS_MODE_INHERIT=0, PROCESS_MODE_PAUSABLE=1, PROCESS_MODE_WHEN_PAUSED=2, PROCESS_MODE_ALWAYS=3, PROCESS_MODE_DISABLED=4
**ProcessThreadGroup:** PROCESS_THREAD_GROUP_INHERIT=0, PROCESS_THREAD_GROUP_MAIN_THREAD=1, PROCESS_THREAD_GROUP_SUB_THREAD=2
**ProcessThreadMessages:** FLAG_PROCESS_THREAD_MESSAGES=1, FLAG_PROCESS_THREAD_MESSAGES_PHYSICS=2, FLAG_PROCESS_THREAD_MESSAGES_ALL=3
**PhysicsInterpolationMode:** PHYSICS_INTERPOLATION_MODE_INHERIT=0, PHYSICS_INTERPOLATION_MODE_ON=1, PHYSICS_INTERPOLATION_MODE_OFF=2
**DuplicateFlags:** DUPLICATE_SIGNALS=1, DUPLICATE_GROUPS=2, DUPLICATE_SCRIPTS=4, DUPLICATE_USE_INSTANTIATION=8, DUPLICATE_INTERNAL_STATE=16, DUPLICATE_DEFAULT=15
**InternalMode:** INTERNAL_MODE_DISABLED=0, INTERNAL_MODE_FRONT=1, INTERNAL_MODE_BACK=2
**AutoTranslateMode:** AUTO_TRANSLATE_MODE_INHERIT=0, AUTO_TRANSLATE_MODE_ALWAYS=1, AUTO_TRANSLATE_MODE_DISABLED=2

