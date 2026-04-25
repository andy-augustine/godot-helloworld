## Quaternion

The Quaternion built-in Variant type is a 4D data structure that represents rotation in the form of a . Compared to the Basis type which can store both rotation and scale, quaternions can *only* store rotation. A Quaternion is composed by 4 floating-point components: `w`, `x`, `y`, and `z`. These components are very compact in memory, and because of this some operations are more efficient and less likely to cause floating-point errors. Methods such as `get_angle`, `get_axis`, and `slerp` are faster than their Basis counterparts. For a great introduction to quaternions, see . You do not need to know the math behind quaternions, as Godot provides several helper methods that handle it for you. These include `slerp` and `spherical_cubic_interpolate`, as well as the `*` operator. **Note:** Quaternions must be normalized before being used for rotation (see `normalized`). **Note:** Similarly to Vector2 and Vector3, the components of a quaternion use 32-bit precision by default, unlike [float] which is always 64-bit. If double precision is needed, compile the engine with the option `precision=double`. **Note:** In a boolean context, a quaternion will evaluate to `false` if it's equal to `IDENTITY`. Otherwise, a quaternion will always evaluate to `true`.

**Props:**
- w: float = 1.0
- x: float = 0.0
- y: float = 0.0
- z: float = 0.0

**Methods:**
- angle_to(to: Quaternion) -> float - Returns the angle between this quaternion and `to`.
- dot(with: Quaternion) -> float - Returns the dot product between this quaternion and `with`.
- exp() -> Quaternion - Returns the exponential of this quaternion.
- from_euler(euler: Vector3) -> Quaternion - Constructs a new Quaternion from the given Vector3 of , in radians.
- get_angle() -> float - Returns the angle of the rotation represented by this quaternion.
- get_axis() -> Vector3 - Returns the rotation axis of the rotation represented by this quaternion.
- get_euler(order: int = 2) -> Vector3 - Returns this quaternion's rotation as a Vector3 of , in radians.
- inverse() -> Quaternion - Returns the inverse version of this quaternion, inverting the sign of every component except `w`.
- is_equal_approx(to: Quaternion) -> bool - Returns `true` if this quaternion and `to` are approximately equal, by calling `@GlobalScope.
- is_finite() -> bool - Returns `true` if this quaternion is finite, by calling `@GlobalScope.
- is_normalized() -> bool - Returns `true` if this quaternion is normalized.
- length() -> float - Returns this quaternion's length, also called magnitude.
- length_squared() -> float - Returns this quaternion's length, squared.
- log() -> Quaternion - Returns the logarithm of this quaternion.
- normalized() -> Quaternion - Returns a copy of this quaternion, normalized so that its length is `1.
- slerp(to: Quaternion, weight: float) -> Quaternion - Performs a spherical-linear interpolation with the `to` quaternion, given a `weight` and returns the result.
- slerpni(to: Quaternion, weight: float) -> Quaternion - Performs a spherical-linear interpolation with the `to` quaternion, given a `weight` and returns the result.
- spherical_cubic_interpolate(b: Quaternion, pre_a: Quaternion, post_b: Quaternion, weight: float) -> Quaternion - Performs a spherical cubic interpolation between quaternions `pre_a`, this vector, `b`, and `post_b`, by the given amount `weight`.
- spherical_cubic_interpolate_in_time(b: Quaternion, pre_a: Quaternion, post_b: Quaternion, weight: float, b_t: float, pre_a_t: float, post_b_t: float) -> Quaternion - Performs a spherical cubic interpolation between quaternions `pre_a`, this vector, `b`, and `post_b`, by the given amount `weight`.

**Enums:**
**Constants:** IDENTITY=Quaternion(0, 0, 0, 1)

