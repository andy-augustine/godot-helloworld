## Vector2

A 2-element structure that can be used to represent 2D coordinates or any other pair of numeric values. It uses floating-point coordinates. By default, these floating-point values use 32-bit precision, unlike [float] which is always 64-bit. If double precision is needed, compile the engine with the option `precision=double`. See Vector2i for its integer counterpart. **Note:** In a boolean context, a Vector2 will evaluate to `false` if it's equal to `Vector2(0, 0)`. Otherwise, a Vector2 will always evaluate to `true`.

**Props:**
- x: float = 0.0
- y: float = 0.0

**Methods:**
- abs() -> Vector2 - Returns a new vector with all components in absolute values (i.
- angle() -> float - Returns this vector's angle with respect to the positive X axis, or `(1, 0)` vector, in radians.
- angle_to(to: Vector2) -> float - Returns the signed angle to the given vector, in radians.
- angle_to_point(to: Vector2) -> float - Returns the signed angle between the X axis and the line from this vector to point `to`, in radians.
- aspect() -> float - Returns this vector's aspect ratio, which is `x` divided by `y`.
- bezier_derivative(control_1: Vector2, control_2: Vector2, end: Vector2, t: float) -> Vector2 - Returns the derivative at the given `t` on the defined by this vector and the given `control_1`, `control_2`, and `end` points.
- bezier_interpolate(control_1: Vector2, control_2: Vector2, end: Vector2, t: float) -> Vector2 - Returns the point at the given `t` on the defined by this vector and the given `control_1`, `control_2`, and `end` points.
- bounce(n: Vector2) -> Vector2 - Returns the vector "bounced off" from a line defined by the given normal `n` perpendicular to the line.
- ceil() -> Vector2 - Returns a new vector with all components rounded up (towards positive infinity).
- clamp(min: Vector2, max: Vector2) -> Vector2 - Returns a new vector with all components clamped between the components of `min` and `max`, by running `@GlobalScope.
- clampf(min: float, max: float) -> Vector2 - Returns a new vector with all components clamped between `min` and `max`, by running `@GlobalScope.
- cross(with: Vector2) -> float - Returns the 2D analog of the cross product for this vector and `with`.
- cubic_interpolate(b: Vector2, pre_a: Vector2, post_b: Vector2, weight: float) -> Vector2 - Performs a cubic interpolation between this vector and `b` using `pre_a` and `post_b` as handles, and returns the result at position `weight`.
- cubic_interpolate_in_time(b: Vector2, pre_a: Vector2, post_b: Vector2, weight: float, b_t: float, pre_a_t: float, post_b_t: float) -> Vector2 - Performs a cubic interpolation between this vector and `b` using `pre_a` and `post_b` as handles, and returns the result at position `weight`.
- direction_to(to: Vector2) -> Vector2 - Returns the normalized vector pointing from this vector to `to`.
- distance_squared_to(to: Vector2) -> float - Returns the squared distance between this vector and `to`.
- distance_to(to: Vector2) -> float - Returns the distance between this vector and `to`.
- dot(with: Vector2) -> float - Returns the dot product of this vector and `with`.
- floor() -> Vector2 - Returns a new vector with all components rounded down (towards negative infinity).
- from_angle(angle: float) -> Vector2 - Creates a Vector2 rotated to the given `angle` in radians.
- is_equal_approx(to: Vector2) -> bool - Returns `true` if this vector and `to` are approximately equal, by running `@GlobalScope.
- is_finite() -> bool - Returns `true` if this vector is finite, by calling `@GlobalScope.
- is_normalized() -> bool - Returns `true` if the vector is normalized, i.
- is_zero_approx() -> bool - Returns `true` if this vector's values are approximately zero, by running `@GlobalScope.
- length() -> float - Returns the length (magnitude) of this vector.
- length_squared() -> float - Returns the squared length (squared magnitude) of this vector.
- lerp(to: Vector2, weight: float) -> Vector2 - Returns the result of the linear interpolation between this vector and `to` by amount `weight`.
- limit_length(length: float = 1.0) -> Vector2 - Returns the vector with a maximum length by limiting its length to `length`.
- max(with: Vector2) -> Vector2 - Returns the component-wise maximum of this and `with`, equivalent to `Vector2(maxf(x, with.
- max_axis_index() -> int - Returns the axis of the vector's highest value.
- maxf(with: float) -> Vector2 - Returns the component-wise maximum of this and `with`, equivalent to `Vector2(maxf(x, with), maxf(y, with))`.
- min(with: Vector2) -> Vector2 - Returns the component-wise minimum of this and `with`, equivalent to `Vector2(minf(x, with.
- min_axis_index() -> int - Returns the axis of the vector's lowest value.
- minf(with: float) -> Vector2 - Returns the component-wise minimum of this and `with`, equivalent to `Vector2(minf(x, with), minf(y, with))`.
- move_toward(to: Vector2, delta: float) -> Vector2 - Returns a new vector moved toward `to` by the fixed `delta` amount.
- normalized() -> Vector2 - Returns the result of scaling the vector to unit length.
- orthogonal() -> Vector2 - Returns a perpendicular vector rotated 90 degrees counter-clockwise compared to the original, with the same length.
- posmod(mod: float) -> Vector2 - Returns a vector composed of the `@GlobalScope.
- posmodv(modv: Vector2) -> Vector2 - Returns a vector composed of the `@GlobalScope.
- project(b: Vector2) -> Vector2 - Returns a new vector resulting from projecting this vector onto the given vector `b`.
- reflect(line: Vector2) -> Vector2 - Returns the result of reflecting the vector from a line defined by the given direction vector `line`.
- rotated(angle: float) -> Vector2 - Returns the result of rotating this vector by `angle` (in radians).
- round() -> Vector2 - Returns a new vector with all components rounded to the nearest integer, with halfway cases rounded away from zero.
- sign() -> Vector2 - Returns a new vector with each component set to `1.
- slerp(to: Vector2, weight: float) -> Vector2 - Returns the result of spherical linear interpolation between this vector and `to`, by amount `weight`.
- slide(n: Vector2) -> Vector2 - Returns a new vector resulting from sliding this vector along a line with normal `n`.
- snapped(step: Vector2) -> Vector2 - Returns a new vector with each component snapped to the nearest multiple of the corresponding component in `step`.
- snappedf(step: float) -> Vector2 - Returns a new vector with each component snapped to the nearest multiple of `step`.

**Enums:**
**Axis:** AXIS_X=0, AXIS_Y=1
**Constants:** ZERO=Vector2(0, 0), ONE=Vector2(1, 1), INF=Vector2(inf, inf), LEFT=Vector2(-1, 0), RIGHT=Vector2(1, 0), UP=Vector2(0, -1), DOWN=Vector2(0, 1)

