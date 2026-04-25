## Transform2D

The Transform2D built-in Variant type is a 2×3 representing a transformation in 2D space. It contains three Vector2 values: `x`, `y`, and `origin`. Together, they can represent translation, rotation, scale, and skew. The `x` and `y` axes form a 2×2 matrix, known as the transform's **basis**. The length of each axis (`Vector2.length`) influences the transform's scale, while the direction of all axes influence the rotation. Usually, both axes are perpendicular to one another. However, when you rotate one axis individually, the transform becomes skewed. Applying a skewed transform to a 2D sprite will make the sprite appear distorted. For a general introduction, see the tutorial. **Note:** Unlike Transform3D, there is no 2D equivalent to the Basis type. All mentions of "basis" refer to the `x` and `y` components of Transform2D. **Note:** In a boolean context, a Transform2D will evaluate to `false` if it's equal to `IDENTITY`. Otherwise, a Transform2D will always evaluate to `true`.

**Props:**
- origin: Vector2 = Vector2(0, 0)
- x: Vector2 = Vector2(1, 0)
- y: Vector2 = Vector2(0, 1)

**Methods:**
- affine_inverse() -> Transform2D - Returns the inverted version of this transform.
- basis_xform(v: Vector2) -> Vector2 - Returns a copy of the `v` vector, transformed (multiplied) by the transform basis's matrix.
- basis_xform_inv(v: Vector2) -> Vector2 - Returns a copy of the `v` vector, transformed (multiplied) by the inverse transform basis's matrix (see `inverse`).
- determinant() -> float - Returns the of this transform basis's matrix.
- get_origin() -> Vector2 - Returns this transform's translation.
- get_rotation() -> float - Returns this transform's rotation (in radians).
- get_scale() -> Vector2 - Returns the length of both `x` and `y`, as a Vector2.
- get_skew() -> float - Returns this transform's skew (in radians).
- interpolate_with(xform: Transform2D, weight: float) -> Transform2D - Returns the result of the linear interpolation between this transform and `xform` by the given `weight`.
- inverse() -> Transform2D - Returns the .
- is_conformal() -> bool - Returns `true` if this transform's basis is conformal.
- is_equal_approx(xform: Transform2D) -> bool - Returns `true` if this transform and `xform` are approximately equal, by running `@GlobalScope.
- is_finite() -> bool - Returns `true` if this transform is finite, by calling `@GlobalScope.
- looking_at(target: Vector2 = Vector2(0, 0)) -> Transform2D - Returns a copy of the transform rotated such that the rotated X-axis points towards the `target` position, in global space.
- orthonormalized() -> Transform2D - Returns a copy of this transform with its basis orthonormalized.
- rotated(angle: float) -> Transform2D - Returns a copy of this transform rotated by the given `angle` (in radians).
- rotated_local(angle: float) -> Transform2D - Returns a copy of the transform rotated by the given `angle` (in radians).
- scaled(scale: Vector2) -> Transform2D - Returns a copy of the transform scaled by the given `scale` factor.
- scaled_local(scale: Vector2) -> Transform2D - Returns a copy of the transform scaled by the given `scale` factor.
- translated(offset: Vector2) -> Transform2D - Returns a copy of the transform translated by the given `offset`.
- translated_local(offset: Vector2) -> Transform2D - Returns a copy of the transform translated by the given `offset`.

**Enums:**
**Constants:** IDENTITY=Transform2D(1, 0, 0, 1, 0, 0), FLIP_X=Transform2D(-1, 0, 0, 1, 0, 0), FLIP_Y=Transform2D(1, 0, 0, -1, 0, 0)

