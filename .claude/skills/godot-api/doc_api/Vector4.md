## Vector4

A 4-element structure that can be used to represent 4D coordinates or any other quadruplet of numeric values. It uses floating-point coordinates. By default, these floating-point values use 32-bit precision, unlike [float] which is always 64-bit. If double precision is needed, compile the engine with the option `precision=double`. See Vector4i for its integer counterpart. **Note:** In a boolean context, a Vector4 will evaluate to `false` if it's equal to `Vector4(0, 0, 0, 0)`. Otherwise, a Vector4 will always evaluate to `true`.

**Props:**
- w: float = 0.0
- x: float = 0.0
- y: float = 0.0
- z: float = 0.0

**Methods:**
- abs() -> Vector4 - Returns a new vector with all components in absolute values (i.
- ceil() -> Vector4 - Returns a new vector with all components rounded up (towards positive infinity).
- clamp(min: Vector4, max: Vector4) -> Vector4 - Returns a new vector with all components clamped between the components of `min` and `max`, by running `@GlobalScope.
- clampf(min: float, max: float) -> Vector4 - Returns a new vector with all components clamped between `min` and `max`, by running `@GlobalScope.
- cubic_interpolate(b: Vector4, pre_a: Vector4, post_b: Vector4, weight: float) -> Vector4 - Performs a cubic interpolation between this vector and `b` using `pre_a` and `post_b` as handles, and returns the result at position `weight`.
- cubic_interpolate_in_time(b: Vector4, pre_a: Vector4, post_b: Vector4, weight: float, b_t: float, pre_a_t: float, post_b_t: float) -> Vector4 - Performs a cubic interpolation between this vector and `b` using `pre_a` and `post_b` as handles, and returns the result at position `weight`.
- direction_to(to: Vector4) -> Vector4 - Returns the normalized vector pointing from this vector to `to`.
- distance_squared_to(to: Vector4) -> float - Returns the squared distance between this vector and `to`.
- distance_to(to: Vector4) -> float - Returns the distance between this vector and `to`.
- dot(with: Vector4) -> float - Returns the dot product of this vector and `with`.
- floor() -> Vector4 - Returns a new vector with all components rounded down (towards negative infinity).
- inverse() -> Vector4 - Returns the inverse of the vector.
- is_equal_approx(to: Vector4) -> bool - Returns `true` if this vector and `to` are approximately equal, by running `@GlobalScope.
- is_finite() -> bool - Returns `true` if this vector is finite, by calling `@GlobalScope.
- is_normalized() -> bool - Returns `true` if the vector is normalized, i.
- is_zero_approx() -> bool - Returns `true` if this vector's values are approximately zero, by running `@GlobalScope.
- length() -> float - Returns the length (magnitude) of this vector.
- length_squared() -> float - Returns the squared length (squared magnitude) of this vector.
- lerp(to: Vector4, weight: float) -> Vector4 - Returns the result of the linear interpolation between this vector and `to` by amount `weight`.
- max(with: Vector4) -> Vector4 - Returns the component-wise maximum of this and `with`, equivalent to `Vector4(maxf(x, with.
- max_axis_index() -> int - Returns the axis of the vector's highest value.
- maxf(with: float) -> Vector4 - Returns the component-wise maximum of this and `with`, equivalent to `Vector4(maxf(x, with), maxf(y, with), maxf(z, with), maxf(w, with))`.
- min(with: Vector4) -> Vector4 - Returns the component-wise minimum of this and `with`, equivalent to `Vector4(minf(x, with.
- min_axis_index() -> int - Returns the axis of the vector's lowest value.
- minf(with: float) -> Vector4 - Returns the component-wise minimum of this and `with`, equivalent to `Vector4(minf(x, with), minf(y, with), minf(z, with), minf(w, with))`.
- normalized() -> Vector4 - Returns the result of scaling the vector to unit length.
- posmod(mod: float) -> Vector4 - Returns a vector composed of the `@GlobalScope.
- posmodv(modv: Vector4) -> Vector4 - Returns a vector composed of the `@GlobalScope.
- round() -> Vector4 - Returns a new vector with all components rounded to the nearest integer, with halfway cases rounded away from zero.
- sign() -> Vector4 - Returns a new vector with each component set to `1.
- snapped(step: Vector4) -> Vector4 - Returns a new vector with each component snapped to the nearest multiple of the corresponding component in `step`.
- snappedf(step: float) -> Vector4 - Returns a new vector with each component snapped to the nearest multiple of `step`.

**Enums:**
**Axis:** AXIS_X=0, AXIS_Y=1, AXIS_Z=2, AXIS_W=3
**Constants:** ZERO=Vector4(0, 0, 0, 0), ONE=Vector4(1, 1, 1, 1), INF=Vector4(inf, inf, inf, inf)

