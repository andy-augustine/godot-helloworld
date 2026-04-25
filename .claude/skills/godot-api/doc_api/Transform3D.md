## Transform3D

The Transform3D built-in Variant type is a 3×4 matrix representing a transformation in 3D space. It contains a Basis, which on its own can represent rotation, scale, and shear. Additionally, combined with its own `origin`, the transform can also represent a translation. For a general introduction, see the tutorial. **Note:** Godot uses a , which is a common standard. For directions, the convention for built-in types like Camera3D is for -Z to point forward (+X is right, +Y is up, and +Z is back). Other objects may use different direction conventions. For more information, see the tutorial. **Note:** In a boolean context, a Transform3D will evaluate to `false` if it's equal to `IDENTITY`. Otherwise, a Transform3D will always evaluate to `true`.

**Props:**
- basis: Basis = Basis(1, 0, 0, 0, 1, 0, 0, 0, 1)
- origin: Vector3 = Vector3(0, 0, 0)

**Methods:**
- affine_inverse() -> Transform3D - Returns the inverted version of this transform.
- interpolate_with(xform: Transform3D, weight: float) -> Transform3D - Returns the result of the linear interpolation between this transform and `xform` by the given `weight`.
- inverse() -> Transform3D - Returns the .
- is_equal_approx(xform: Transform3D) -> bool - Returns `true` if this transform and `xform` are approximately equal, by running `@GlobalScope.
- is_finite() -> bool - Returns `true` if this transform is finite, by calling `@GlobalScope.
- looking_at(target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false) -> Transform3D - Returns a copy of this transform rotated so that the forward axis (-Z) points towards the `target` position.
- orthonormalized() -> Transform3D - Returns a copy of this transform with its `basis` orthonormalized.
- rotated(axis: Vector3, angle: float) -> Transform3D - Returns a copy of this transform rotated around the given `axis` by the given `angle` (in radians).
- rotated_local(axis: Vector3, angle: float) -> Transform3D - Returns a copy of this transform rotated around the given `axis` by the given `angle` (in radians).
- scaled(scale: Vector3) -> Transform3D - Returns a copy of this transform scaled by the given `scale` factor.
- scaled_local(scale: Vector3) -> Transform3D - Returns a copy of this transform scaled by the given `scale` factor.
- translated(offset: Vector3) -> Transform3D - Returns a copy of this transform translated by the given `offset`.
- translated_local(offset: Vector3) -> Transform3D - Returns a copy of this transform translated by the given `offset`.

**Enums:**
**Constants:** IDENTITY=Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0), FLIP_X=Transform3D(-1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0), FLIP_Y=Transform3D(1, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0), FLIP_Z=Transform3D(1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0)

