## RayCast2D <- Node2D

A raycast represents a ray from its origin to its `target_position` that finds the closest object along its path, if it intersects any. RayCast2D can ignore some objects by adding them to an exception list, by making its detection reporting ignore Area2Ds (`collide_with_areas`) or PhysicsBody2Ds (`collide_with_bodies`), or by configuring physics layers. RayCast2D calculates intersection every physics frame, and it holds the result until the next physics frame. For an immediate raycast, or if you want to configure a RayCast2D multiple times within the same physics frame, use `force_raycast_update`. To sweep over a region of 2D space, you can approximate the region with multiple RayCast2Ds or use ShapeCast2D.

**Props:**
- collide_with_areas: bool = false
- collide_with_bodies: bool = true
- collision_mask: int = 1
- enabled: bool = true
- exclude_parent: bool = true
- hit_from_inside: bool = false
- target_position: Vector2 = Vector2(0, 50)

**Methods:**
- add_exception(node: CollisionObject2D) - Adds a collision exception so the ray does not report collisions with the specified `node`.
- add_exception_rid(rid: RID) - Adds a collision exception so the ray does not report collisions with the specified RID.
- clear_exceptions() - Removes all collision exceptions for this ray.
- force_raycast_update() - Updates the collision information for the ray immediately, without waiting for the next `_physics_process` call.
- get_collider() -> Object - Returns the first object that the ray intersects, or `null` if no object is intersecting the ray (i.
- get_collider_rid() -> RID - Returns the RID of the first object that the ray intersects, or an empty RID if no object is intersecting the ray (i.
- get_collider_shape() -> int - Returns the shape ID of the first object that the ray intersects, or `0` if no object is intersecting the ray (i.
- get_collision_mask_value(layer_number: int) -> bool - Returns whether or not the specified layer of the `collision_mask` is enabled, given a `layer_number` between 1 and 32.
- get_collision_normal() -> Vector2 - Returns the normal of the intersecting object's shape at the collision point, or `Vector2(0, 0)` if the ray starts inside the shape and `hit_from_inside` is `true`.
- get_collision_point() -> Vector2 - Returns the collision point at which the ray intersects the closest object, in the global coordinate system.
- is_colliding() -> bool - Returns whether any object is intersecting with the ray's vector (considering the vector length).
- remove_exception(node: CollisionObject2D) - Removes a collision exception so the ray can report collisions with the specified `node`.
- remove_exception_rid(rid: RID) - Removes a collision exception so the ray can report collisions with the specified RID.
- set_collision_mask_value(layer_number: int, value: bool) - Based on `value`, enables or disables the specified layer in the `collision_mask`, given a `layer_number` between 1 and 32.

