## Resource <- RefCounted

Resource is the base class for all Godot-specific resource types, serving primarily as data containers. Since they inherit from RefCounted, resources are reference-counted and freed when no longer in use. They can also be nested within other resources, and saved on disk. PackedScene, one of the most common Objects in a Godot project, is also a resource, uniquely capable of storing and instantiating the Nodes it contains as many times as desired. In GDScript, resources can loaded from disk by their `resource_path` using `@GDScript.load` or `@GDScript.preload`. The engine keeps a global cache of all loaded resources, referenced by paths (see `ResourceLoader.has_cached`). A resource will be cached when loaded for the first time and removed from cache once all references are released. When a resource is cached, subsequent loads using its path will return the cached reference. **Note:** In C#, resources will not be freed instantly after they are no longer in use. Instead, garbage collection will run periodically and will free resources that are no longer in use. This means that unused resources will remain in memory for a while before being removed.

**Props:**
- resource_local_to_scene: bool = false
- resource_name: String = ""
- resource_path: String = ""
- resource_scene_unique_id: String

**Methods:**
- copy_from_resource(resource: Resource) -> int - Copies the data from `resource` into this resource.
- duplicate(deep: bool = false) -> Resource - Duplicates this resource, returning a new resource with its `export`ed or `PROPERTY_USAGE_STORAGE` properties copied from the original.
- duplicate_deep(deep_subresources_mode: int = 1) -> Resource - Duplicates this resource, deeply, like `duplicate` when passing `true`, with extra control over how subresources are handled.
- emit_changed() - Emits the `changed` signal.
- generate_scene_unique_id() -> String - Generates a unique identifier for a resource to be contained inside a PackedScene, based on the current date, time, and a random value.
- get_id_for_path(path: String) -> String - From the internal cache for scene-unique IDs, returns the ID of this resource for the scene at `path`.
- get_local_scene() -> Node - If `resource_local_to_scene` is set to `true` and the resource has been loaded from a PackedScene instantiation, returns the root Node of the scene where this resource is used.
- get_rid() -> RID - Returns the RID of this resource (or an empty RID).
- is_built_in() -> bool - Returns `true` if the resource is saved on disk as a part of another resource's file.
- reset_state() - Makes the resource clear its non-exported properties.
- set_id_for_path(path: String, id: String) - In the internal cache for scene-unique IDs, sets the ID of this resource to `id` for the scene at `path`.
- set_path_cache(path: String) - Sets the resource's path to `path` without involving the resource cache.
- setup_local_to_scene() - Calls `_setup_local_to_scene`.
- take_over_path(path: String) - Sets the `resource_path` to `path`, potentially overriding an existing cache entry for this path.

**Signals:**
- changed
- setup_local_to_scene_requested

**Enums:**
**DeepDuplicateMode:** DEEP_DUPLICATE_NONE=0, DEEP_DUPLICATE_INTERNAL=1, DEEP_DUPLICATE_ALL=2

