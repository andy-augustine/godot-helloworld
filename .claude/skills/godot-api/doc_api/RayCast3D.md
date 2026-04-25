## RayCast3D <- Node3D

A raycast represents a ray from its origin to its `target_position` that finds the closest object along its path, if it intersects any. RayCast3D can ignore some objects by adding them to an exception list, by making its detection reporting ignore Area3Ds (`collide_with_areas`) or PhysicsBody3Ds (`collide_with_bodies`), or by configuring physics layers. RayCast3D calculates intersection every physics frame, and it holds the result until the next physics frame. For an immediate raycast, or if you want to configure a RayCast3D multiple times within the same physics frame, use `force_raycast_update`. To sweep over a region of 3D space, you can approximate the region with multiple RayCast3Ds or use ShapeCast3D.

**Props:**
- collide_with_areas: bool = false
- collide_with_bodies: bool = true
- collision_mask: int = 1
- debug_shape_custom_color: Color = Color(0, 0, 0, 1)
- debug_shape_thickness: int = 2
- enabled: bool = true
- exclude_parent: bool = true
- hit_back_faces: bool = true
- hit_from_inside: bool = false
- target_position: Vector3 = Vector3(0, -1, 0)

**Methods:**
- add_exception(node: CollisionObject3D) - Adds a collision exception so the ray does not report collisions with the specified `node`.
- add_exception_rid(rid: RID) - Adds a collision exception so the ray does not report collisions with the specified RID.
- clear_exceptions() - Removes all collision exceptions for this ray.
- force_raycast_update() - Updates the collision information for the ray immediately, without waiting for the next `_physics_process` call.
- get_collider() -> Object - Returns the first object that the ray intersects, or `null` if no object is intersecting the ray (i.
- get_collider_rid() -> RID - Returns the RID of the first object that the ray intersects, or an empty RID if no object is intersecting the ray (i.
- get_collider_shape() -> int - Returns the shape ID of the first object that the ray intersects, or `0` if no object is intersecting the ray (i.
- get_collision_face_index() -> int - Returns the collision object's face index at the collision point, or `-1` if the shape intersecting the ray is not a ConcavePolygonShape3D.
- get_collision_mask_value(layer_number: int) -> bool - Returns whether or not the specified layer of the `collision_mask` is enabled, given a `layer_number` between 1 and 32.
- get_collision_normal() -> Vector3 - Returns the normal of the intersecting object's shape at the collision point, or `Vector3(0, 0, 0)` if the ray starts inside the shape and `hit_from_inside` is `true`.
- get_collision_point() -> Vector3 - Returns the collision point at which the ray intersects the closest object, in the global coordinate system.
- is_colliding() -> bool - Returns whether any object is intersecting with the ray's vector (considering the vector length).
- remove_exception(node: CollisionObject3D) - Removes a collision exception so the ray can report collisions with the specified `node`.
- remove_exception_rid(rid: RID) - Removes a collision exception so the ray can report collisions with the specified RID.
- set_collision_mask_value(layer_number: int, value: bool) - Based on `value`, enables or disables the specified layer in the `collision_mask`, given a `layer_number` between 1 and 32.

