## Object

An advanced Variant type. All classes in the engine inherit from Object. Each class may define new properties, methods or signals, which are available to all inheriting classes. For example, a Sprite2D instance is able to call `Node.add_child` because it inherits from Node. You can create new instances, using `Object.new()` in GDScript, or `new GodotObject` in C#. To delete an Object instance, call `free`. This is necessary for most classes inheriting Object, because they do not manage memory on their own, and will otherwise cause memory leaks when no longer in use. There are a few classes that perform memory management. For example, RefCounted (and by extension Resource) deletes itself when no longer referenced, and Node deletes its children when freed. Objects can have a Script attached to them. Once the Script is instantiated, it effectively acts as an extension to the base class, allowing it to define and inherit new properties, methods and signals. Inside a Script, `_get_property_list` may be overridden to customize properties in several ways. This allows them to be available to the editor, display as lists of options, sub-divide into groups, save on disk, etc. Scripting languages offer easier ways to customize properties, such as with the [annotation @GDScript.@export] annotation. Godot is very dynamic. An object's script, and therefore its properties, methods and signals, can be changed at run-time. Because of this, there can be occasions where, for example, a property required by a method may not exist. To prevent run-time errors, see methods such as `set`, `get`, `call`, `has_method`, `has_signal`, etc. Note that these methods are **much** slower than direct references. In GDScript, you can also check if a given property, method, or signal name exists in an object with the `in` operator: Notifications are [int] constants commonly sent and received by objects. For example, on every rendered frame, the SceneTree notifies nodes inside the tree with a `Node.NOTIFICATION_PROCESS`. The nodes receive it and may call `Node._process` to update. To make use of notifications, see `notification` and `_notification`. Lastly, every object can also contain metadata (data about data). `set_meta` can be useful to store information that the object itself does not depend on. To keep your code clean, making excessive use of metadata is discouraged. **Note:** Unlike references to a RefCounted, references to an object stored in a variable can become invalid without being set to `null`. To check if an object has been deleted, do *not* compare it against `null`. Instead, use `@GlobalScope.is_instance_valid`. It's also recommended to inherit from RefCounted for classes storing data instead of Object. **Note:** The `script` is not exposed like most properties. To set or get an object's Script in code, use `set_script` and `get_script`, respectively. **Note:** In a boolean context, an Object will evaluate to `false` if it is equal to `null` or it has been freed. Otherwise, an Object will always evaluate to `true`. See also `@GlobalScope.is_instance_valid`.

**Methods:**
- add_user_signal(signal: String, arguments: Array = []) - Adds a user-defined signal named `signal`.
- call(method: StringName) -> Variant - Calls the `method` on the object and returns the result.
- call_deferred(method: StringName) -> Variant - Calls the `method` on the object during idle time.
- callv(method: StringName, arg_array: Array) -> Variant - Calls the `method` on the object and returns the result.
- can_translate_messages() -> bool - Returns `true` if the object is allowed to translate messages with `tr` and `tr_n`.
- cancel_free() - If this method is called during `NOTIFICATION_PREDELETE`, this object will reject being freed and will remain allocated.
- connect(signal: StringName, callable: Callable, flags: int = 0) -> int - Connects a `signal` by name to a `callable`.
- disconnect(signal: StringName, callable: Callable) - Disconnects a `signal` by name from a given `callable`.
- emit_signal(signal: StringName) -> int - Emits the given `signal` by name.
- free() - Deletes the object from memory.
- get(property: StringName) -> Variant - Returns the Variant value of the given `property`.
- get_class() -> String - Returns the object's built-in class name, as a String.
- get_incoming_connections() -> Dictionary[] - Returns an Array of signal connections received by this object.
- get_indexed(property_path: NodePath) -> Variant - Gets the object's property indexed by the given `property_path`.
- get_instance_id() -> int - Returns the object's unique instance ID.
- get_meta(name: StringName, default: Variant = null) -> Variant - Returns the object's metadata value for the given entry `name`.
- get_meta_list() -> StringName[] - Returns the object's metadata entry names as an Array of StringNames.
- get_method_argument_count(method: StringName) -> int - Returns the number of arguments of the given `method` by name.
- get_method_list() -> Dictionary[] - Returns this object's methods and their signatures as an Array of dictionaries.
- get_property_list() -> Dictionary[] - Returns the object's property list as an Array of dictionaries.
- get_script() -> Variant - Returns the object's Script instance, or `null` if no script is attached.
- get_signal_connection_list(signal: StringName) -> Dictionary[] - Returns an Array of connections for the given `signal` name.
- get_signal_list() -> Dictionary[] - Returns the list of existing signals as an Array of dictionaries.
- get_translation_domain() -> StringName - Returns the name of the translation domain used by `tr` and `tr_n`.
- has_connections(signal: StringName) -> bool - Returns `true` if any connection exists on the given `signal` name.
- has_meta(name: StringName) -> bool - Returns `true` if a metadata entry is found with the given `name`.
- has_method(method: StringName) -> bool - Returns `true` if the given `method` name exists in the object.
- has_signal(signal: StringName) -> bool - Returns `true` if the given `signal` name exists in the object.
- has_user_signal(signal: StringName) -> bool - Returns `true` if the given user-defined `signal` name exists.
- is_blocking_signals() -> bool - Returns `true` if the object is blocking its signals from being emitted.
- is_class(class: StringName) -> bool - Returns `true` if the object inherits from the given `class`.
- is_connected(signal: StringName, callable: Callable) -> bool - Returns `true` if a connection exists between the given `signal` name and `callable`.
- is_queued_for_deletion() -> bool - Returns `true` if the `Node.
- notification(what: int, reversed: bool = false) - Sends the given `what` notification to all classes inherited by the object, triggering calls to `_notification`, starting from the highest ancestor (the Object class) and going down to the object's script.
- notify_property_list_changed() - Emits the `property_list_changed` signal.
- property_can_revert(property: StringName) -> bool - Returns `true` if the given `property` has a custom default value.
- property_get_revert(property: StringName) -> Variant - Returns the custom default value of the given `property`.
- remove_meta(name: StringName) - Removes the given entry `name` from the object's metadata.
- remove_user_signal(signal: StringName) - Removes the given user signal `signal` from the object.
- set(property: StringName, value: Variant) - Assigns `value` to the given `property`.
- set_block_signals(enable: bool) - If set to `true`, the object becomes unable to emit signals.
- set_deferred(property: StringName, value: Variant) - Assigns `value` to the given `property`, at the end of the current frame.
- set_indexed(property_path: NodePath, value: Variant) - Assigns a new `value` to the property identified by the `property_path`.
- set_message_translation(enable: bool) - If set to `true`, allows the object to translate messages with `tr` and `tr_n`.
- set_meta(name: StringName, value: Variant) - Adds or changes the entry `name` inside the object's metadata.
- set_script(script: Variant) - Attaches `script` to the object, and instantiates it.
- set_translation_domain(domain: StringName) - Sets the name of the translation domain used by `tr` and `tr_n`.
- to_string() -> String - Returns a String representing the object.
- tr(message: StringName, context: StringName = &"") -> String - Translates a `message`, using the translation catalogs configured in the Project Settings.
- tr_n(message: StringName, plural_message: StringName, n: int, context: StringName = &"") -> String - Translates a `message` or `plural_message`, using the translation catalogs configured in the Project Settings.

**Signals:**
- property_list_changed
- script_changed

**Enums:**
**Constants:** NOTIFICATION_POSTINITIALIZE=0, NOTIFICATION_PREDELETE=1, NOTIFICATION_EXTENSION_RELOADED=2
**ConnectFlags:** CONNECT_DEFERRED=1, CONNECT_PERSIST=2, CONNECT_ONE_SHOT=4, CONNECT_REFERENCE_COUNTED=8, CONNECT_APPEND_SOURCE_OBJECT=16

