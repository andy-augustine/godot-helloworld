## Node3D <- Node

The Node3D node is the base representation of a node in 3D space. All other 3D nodes inherit from this class. Affine operations (translation, rotation, scale) are calculated in the coordinate system relative to the parent, unless the Node3D's `top_level` is `true`. In this coordinate system, affine operations correspond to direct affine operations on the Node3D's `transform`. The term *parent space* refers to this coordinate system. The coordinate system that is attached to the Node3D itself is referred to as object-local coordinate system, or *local space*. **Note:** Unless otherwise specified, all methods that need angle parameters must receive angles in *radians*. To convert degrees to radians, use `@GlobalScope.deg_to_rad`. **Note:** In Godot 3 and older, Node3D was named *Spatial*.

**Props:**
- basis: Basis
- global_basis: Basis
- global_position: Vector3
- global_rotation: Vector3
- global_rotation_degrees: Vector3
- global_transform: Transform3D
- position: Vector3 = Vector3(0, 0, 0)
- quaternion: Quaternion
- rotation: Vector3 = Vector3(0, 0, 0)
- rotation_degrees: Vector3
- rotation_edit_mode: int (Node3D.RotationEditMode) = 0
- rotation_order: int (EulerOrder) = 2
- scale: Vector3 = Vector3(1, 1, 1)
- top_level: bool = false
- transform: Transform3D = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
- visibility_parent: NodePath = NodePath("")
- visible: bool = true

**Methods:**
- add_gizmo(gizmo: Node3DGizmo) - Attaches the given `gizmo` to this node.
- clear_gizmos() - Clears all EditorNode3DGizmo objects attached to this node.
- clear_subgizmo_selection() - Deselects all subgizmos for this node.
- force_update_transform() - Forces the node's `global_transform` to update, by sending `NOTIFICATION_TRANSFORM_CHANGED`.
- get_gizmos() -> Node3DGizmo[] - Returns all the EditorNode3DGizmo objects attached to this node.
- get_global_transform_interpolated() -> Transform3D - When using physics interpolation, there will be circumstances in which you want to know the interpolated (displayed) transform of a node rather than the standard transform (which may only be accurate to the most recent physics tick).
- get_parent_node_3d() -> Node3D - Returns the parent Node3D that directly affects this node's `global_transform`.
- get_world_3d() -> World3D - Returns the World3D this node is registered to.
- global_rotate(axis: Vector3, angle: float) - Rotates this node's `global_basis` around the global `axis` by the given `angle`, in radians.
- global_scale(scale: Vector3) - Scales this node's `global_basis` by the given `scale` factor.
- global_translate(offset: Vector3) - Adds the given translation `offset` to the node's `global_position` in global space (relative to the world).
- hide() - Prevents this node from being rendered.
- is_local_transform_notification_enabled() -> bool - Returns `true` if the node receives `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` whenever `transform` changes.
- is_scale_disabled() -> bool - Returns `true` if this node's `global_transform` is automatically orthonormalized.
- is_transform_notification_enabled() -> bool - Returns `true` if the node receives `NOTIFICATION_TRANSFORM_CHANGED` whenever `global_transform` changes.
- is_visible_in_tree() -> bool - Returns `true` if this node is inside the scene tree and the `visible` property is `true` for this node and all of its Node3D ancestors *in sequence*.
- look_at(target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false) - Rotates the node so that the local forward axis (-Z, `Vector3.
- look_at_from_position(position: Vector3, target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false) - Moves the node to the specified `position`, then rotates the node to point toward the `target` position, similar to `look_at`.
- orthonormalize() - Orthonormalizes this node's `basis`.
- rotate(axis: Vector3, angle: float) - Rotates this node's `basis` around the `axis` by the given `angle`, in radians.
- rotate_object_local(axis: Vector3, angle: float) - Rotates this node's `basis` around the `axis` by the given `angle`, in radians.
- rotate_x(angle: float) - Rotates this node's `basis` around the X axis by the given `angle`, in radians.
- rotate_y(angle: float) - Rotates this node's `basis` around the Y axis by the given `angle`, in radians.
- rotate_z(angle: float) - Rotates this node's `basis` around the Z axis by the given `angle`, in radians.
- scale_object_local(scale: Vector3) - Scales this node's `basis` by the given `scale` factor.
- set_disable_scale(disable: bool) - If `true`, this node's `global_transform` is automatically orthonormalized.
- set_identity() - Sets this node's `transform` to `Transform3D.
- set_ignore_transform_notification(enabled: bool) - If `true`, the node will not receive `NOTIFICATION_TRANSFORM_CHANGED` or `NOTIFICATION_LOCAL_TRANSFORM_CHANGED`.
- set_notify_local_transform(enable: bool) - If `true`, the node will receive `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` whenever `transform` changes.
- set_notify_transform(enable: bool) - If `true`, the node will receive `NOTIFICATION_TRANSFORM_CHANGED` whenever `global_transform` changes.
- set_subgizmo_selection(gizmo: Node3DGizmo, id: int, transform: Transform3D) - Selects the `gizmo`'s subgizmo with the given `id` and sets its transform.
- show() - Allows this node to be rendered.
- to_global(local_point: Vector3) -> Vector3 - Returns the `local_point` converted from this node's local space to global space.
- to_local(global_point: Vector3) -> Vector3 - Returns the `global_point` converted from global space to this node's local space.
- translate(offset: Vector3) - Adds the given translation `offset` to the node's position, in local space (relative to this node).
- translate_object_local(offset: Vector3) - Adds the given translation `offset` to the node's position, in local space (relative to this node).
- update_gizmos() - Updates all the EditorNode3DGizmo objects attached to this node.

**Signals:**
- visibility_changed

**Enums:**
**Constants:** NOTIFICATION_TRANSFORM_CHANGED=2000, NOTIFICATION_ENTER_WORLD=41, NOTIFICATION_EXIT_WORLD=42, NOTIFICATION_VISIBILITY_CHANGED=43, NOTIFICATION_LOCAL_TRANSFORM_CHANGED=44
**RotationEditMode:** ROTATION_EDIT_MODE_EULER=0, ROTATION_EDIT_MODE_QUATERNION=1, ROTATION_EDIT_MODE_BASIS=2

