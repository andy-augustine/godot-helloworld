## CharacterBody2D <- PhysicsBody2D

CharacterBody2D is a specialized class for physics bodies that are meant to be user-controlled. They are not affected by physics at all, but they affect other physics bodies in their path. They are mainly used to provide high-level API to move objects with wall and slope detection (`move_and_slide` method) in addition to the general collision detection provided by `PhysicsBody2D.move_and_collide`. This makes it useful for highly configurable physics bodies that must move in specific ways and collide with the world, as is often the case with user-controlled characters. For game objects that don't require complex movement or collision detection, such as moving platforms, AnimatableBody2D is simpler to configure.

**Props:**
- floor_block_on_wall: bool = true
- floor_constant_speed: bool = false
- floor_max_angle: float = 0.7853982
- floor_snap_length: float = 1.0
- floor_stop_on_slope: bool = true
- max_slides: int = 4
- motion_mode: int (CharacterBody2D.MotionMode) = 0
- platform_floor_layers: int = 4294967295
- platform_on_leave: int (CharacterBody2D.PlatformOnLeave) = 0
- platform_wall_layers: int = 0
- safe_margin: float = 0.08
- slide_on_ceiling: bool = true
- up_direction: Vector2 = Vector2(0, -1)
- velocity: Vector2 = Vector2(0, 0)
- wall_min_slide_angle: float = 0.2617994

**Methods:**
- apply_floor_snap() - Allows to manually apply a snap to the floor regardless of the body's velocity.
- get_floor_angle(up_direction: Vector2 = Vector2(0, -1)) -> float - Returns the floor's collision angle at the last collision point according to `up_direction`, which is `Vector2.
- get_floor_normal() -> Vector2 - Returns the collision normal of the floor at the last collision point.
- get_last_motion() -> Vector2 - Returns the last motion applied to the CharacterBody2D during the last call to `move_and_slide`.
- get_last_slide_collision() -> KinematicCollision2D - Returns a KinematicCollision2D if a collision occurred.
- get_platform_velocity() -> Vector2 - Returns the linear velocity of the platform at the last collision point.
- get_position_delta() -> Vector2 - Returns the travel (position delta) that occurred during the last call to `move_and_slide`.
- get_real_velocity() -> Vector2 - Returns the current real velocity since the last call to `move_and_slide`.
- get_slide_collision(slide_idx: int) -> KinematicCollision2D - Returns a KinematicCollision2D, which contains information about a collision that occurred during the last call to `move_and_slide`.
- get_slide_collision_count() -> int - Returns the number of times the body collided and changed direction during the last call to `move_and_slide`.
- get_wall_normal() -> Vector2 - Returns the collision normal of the wall at the last collision point.
- is_on_ceiling() -> bool - Returns `true` if the body collided with the ceiling on the last call of `move_and_slide`.
- is_on_ceiling_only() -> bool - Returns `true` if the body collided only with the ceiling on the last call of `move_and_slide`.
- is_on_floor() -> bool - Returns `true` if the body collided with the floor on the last call of `move_and_slide`.
- is_on_floor_only() -> bool - Returns `true` if the body collided only with the floor on the last call of `move_and_slide`.
- is_on_wall() -> bool - Returns `true` if the body collided with a wall on the last call of `move_and_slide`.
- is_on_wall_only() -> bool - Returns `true` if the body collided only with a wall on the last call of `move_and_slide`.
- move_and_slide() -> bool - Moves the body based on `velocity`.

**Enums:**
**MotionMode:** MOTION_MODE_GROUNDED=0, MOTION_MODE_FLOATING=1
**PlatformOnLeave:** PLATFORM_ON_LEAVE_ADD_VELOCITY=0, PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY=1, PLATFORM_ON_LEAVE_DO_NOTHING=2

