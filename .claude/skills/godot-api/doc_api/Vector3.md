## Vector3

A 3-element structure that can be used to represent 3D coordinates or any other triplet of numeric values. It uses floating-point coordinates. By default, these floating-point values use 32-bit precision, unlike [float] which is always 64-bit. If double precision is needed, compile the engine with the option `precision=double`. See Vector3i for its integer counterpart. **Note:** In a boolean context, a Vector3 will evaluate to `false` if it's equal to `Vector3(0, 0, 0)`. Otherwise, a Vector3 will always evaluate to `true`.

**Props:**
- x: float = 0.0
- y: float = 0.0
- z: float = 0.0

**Methods:**
- abs() -> Vector3 - Returns a new vector with all components in absolute values (i.
- angle_to(to: Vector3) -> float - Returns the unsigned minimum angle to the given vector, in radians.
- bezier_derivative(control_1: Vector3, control_2: Vector3, end: Vector3, t: float) -> Vector3 - Returns the derivative at the given `t` on the defined by this vector and the given `control_1`, `control_2`, and `end` points.
- bezier_interpolate(control_1: Vector3, control_2: Vector3, end: Vector3, t: float) -> Vector3 - Returns the point at the given `t` on the defined by this vector and the given `control_1`, `control_2`, and `end` points.
- bounce(n: Vector3) -> Vector3 - Returns the vector "bounced off" from a plane defined by the given normal `n`.
- ceil() -> Vector3 - Returns a new vector with all components rounded up (towards positive infinity).
- clamp(min: Vector3, max: Vector3) -> Vector3 - Returns a new vector with all components clamped between the components of `min` and `max`, by running `@GlobalScope.
- clampf(min: float, max: float) -> Vector3 - Returns a new vector with all components clamped between `min` and `max`, by running `@GlobalScope.
- cross(with: Vector3) -> Vector3 - Returns the cross product of this vector and `with`.
- cubic_interpolate(b: Vector3, pre_a: Vector3, post_b: Vector3, weight: float) -> Vector3 - Performs a cubic interpolation between this vector and `b` using `pre_a` and `post_b` as handles, and returns the result at position `weight`.
- cubic_interpolate_in_time(b: Vector3, pre_a: Vector3, post_b: Vector3, weight: float, b_t: float, pre_a_t: float, post_b_t: float) -> Vector3 - Performs a cubic interpolation between this vector and `b` using `pre_a` and `post_b` as handles, and returns the result at position `weight`.
- direction_to(to: Vector3) -> Vector3 - Returns the normalized vector pointing from this vector to `to`.
- distance_squared_to(to: Vector3) -> float - Returns the squared distance between this vector and `to`.
- distance_to(to: Vector3) -> float - Returns the distance between this vector and `to`.
- dot(with: Vector3) -> float - Returns the dot product of this vector and `with`.
- floor() -> Vector3 - Returns a new vector with all components rounded down (towards negative infinity).
- inverse() -> Vector3 - Returns the inverse of the vector.
- is_equal_approx(to: Vector3) -> bool - Returns `true` if this vector and `to` are approximately equal, by running `@GlobalScope.
- is_finite() -> bool - Returns `true` if this vector is finite, by calling `@GlobalScope.
- is_normalized() -> bool - Returns `true` if the vector is normalized, i.
- is_zero_approx() -> bool - Returns `true` if this vector's values are approximately zero, by running `@GlobalScope.
- length() -> float - Returns the length (magnitude) of this vector.
- length_squared() -> float - Returns the squared length (squared magnitude) of this vector.
- lerp(to: Vector3, weight: float) -> Vector3 - Returns the result of the linear interpolation between this vector and `to` by amount `weight`.
- limit_length(length: float = 1.0) -> Vector3 - Returns the vector with a maximum length by limiting its length to `length`.
- max(with: Vector3) -> Vector3 - Returns the component-wise maximum of this and `with`, equivalent to `Vector3(maxf(x, with.
- max_axis_index() -> int - Returns the axis of the vector's highest value.
- maxf(with: float) -> Vector3 - Returns the component-wise maximum of this and `with`, equivalent to `Vector3(maxf(x, with), maxf(y, with), maxf(z, with))`.
- min(with: Vector3) -> Vector3 - Returns the component-wise minimum of this and `with`, equivalent to `Vector3(minf(x, with.
- min_axis_index() -> int - Returns the axis of the vector's lowest value.
- minf(with: float) -> Vector3 - Returns the component-wise minimum of this and `with`, equivalent to `Vector3(minf(x, with), minf(y, with), minf(z, with))`.
- move_toward(to: Vector3, delta: float) -> Vector3 - Returns a new vector moved toward `to` by the fixed `delta` amount.
- normalized() -> Vector3 - Returns the result of scaling the vector to unit length.
- octahedron_decode(uv: Vector2) -> Vector3 - Returns the Vector3 from an octahedral-compressed form created using `octahedron_encode` (stored as a Vector2).
- octahedron_encode() -> Vector2 - Returns the octahedral-encoded (oct32) form of this Vector3 as a Vector2.
- outer(with: Vector3) -> Basis - Returns the outer product with `with`.
- posmod(mod: float) -> Vector3 - Returns a vector composed of the `@GlobalScope.
- posmodv(modv: Vector3) -> Vector3 - Returns a vector composed of the `@GlobalScope.
- project(b: Vector3) -> Vector3 - Returns a new vector resulting from projecting this vector onto the given vector `b`.
- reflect(n: Vector3) -> Vector3 - Returns the result of reflecting the vector through a plane defined by the given normal vector `n`.
- rotated(axis: Vector3, angle: float) -> Vector3 - Returns the result of rotating this vector around a given axis by `angle` (in radians).
- round() -> Vector3 - Returns a new vector with all components rounded to the nearest integer, with halfway cases rounded away from zero.
- sign() -> Vector3 - Returns a new vector with each component set to `1.
- signed_angle_to(to: Vector3, axis: Vector3) -> float - Returns the signed angle to the given vector, in radians.
- slerp(to: Vector3, weight: float) -> Vector3 - Returns the result of spherical linear interpolation between this vector and `to`, by amount `weight`.
- slide(n: Vector3) -> Vector3 - Returns a new vector resulting from sliding this vector along a plane with normal `n`.
- snapped(step: Vector3) -> Vector3 - Returns a new vector with each component snapped to the nearest multiple of the corresponding component in `step`.
- snappedf(step: float) -> Vector3 - Returns a new vector with each component snapped to the nearest multiple of `step`.

**Enums:**
**Axis:** AXIS_X=0, AXIS_Y=1, AXIS_Z=2
**Constants:** ZERO=Vector3(0, 0, 0), ONE=Vector3(1, 1, 1), INF=Vector3(inf, inf, inf), LEFT=Vector3(-1, 0, 0), RIGHT=Vector3(1, 0, 0), UP=Vector3(0, 1, 0), DOWN=Vector3(0, -1, 0), FORWARD=Vector3(0, 0, -1), BACK=Vector3(0, 0, 1), MODEL_LEFT=Vector3(1, 0, 0), ...

