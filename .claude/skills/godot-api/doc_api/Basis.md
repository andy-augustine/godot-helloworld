## Basis

The Basis built-in Variant type is a 3×3 used to represent 3D rotation, scale, and shear. It is frequently used within a Transform3D. A Basis is composed by 3 axis vectors, each representing a column of the matrix: `x`, `y`, and `z`. The length of each axis (`Vector3.length`) influences the basis's scale, while the direction of all axes influence the rotation. Usually, these axes are perpendicular to one another. However, when you rotate any axis individually, the basis becomes sheared. Applying a sheared basis to a 3D model will make the model appear distorted. A Basis is: - **Orthogonal** if its axes are perpendicular to each other. - **Normalized** if the length of every axis is `1.0`. - **Uniform** if all axes share the same length (see `get_scale`). - **Orthonormal** if it is both orthogonal and normalized, which allows it to only represent rotations (see `orthonormalized`). - **Conformal** if it is both orthogonal and uniform, which ensures it is not distorted. For a general introduction, see the tutorial. **Note:** Godot uses a , which is a common standard. For directions, the convention for built-in types like Camera3D is for -Z to point forward (+X is right, +Y is up, and +Z is back). Other objects may use different direction conventions. For more information, see the tutorial. **Note:** The basis matrices are exposed as order, which is the same as OpenGL. However, they are stored internally in row-major order, which is the same as DirectX. **Note:** In a boolean context, a basis will evaluate to `false` if it's equal to `IDENTITY`. Otherwise, a basis will always evaluate to `true`.

**Props:**
- x: Vector3 = Vector3(1, 0, 0)
- y: Vector3 = Vector3(0, 1, 0)
- z: Vector3 = Vector3(0, 0, 1)

**Methods:**
- determinant() -> float - Returns the of this basis's matrix.
- from_euler(euler: Vector3, order: int = 2) -> Basis - Constructs a new Basis that only represents rotation from the given Vector3 of , in radians.
- from_scale(scale: Vector3) -> Basis - Constructs a new Basis that only represents scale, with no rotation or shear, from the given `scale` vector.
- get_euler(order: int = 2) -> Vector3 - Returns this basis's rotation as a Vector3 of , in radians.
- get_rotation_quaternion() -> Quaternion - Returns this basis's rotation as a Quaternion.
- get_scale() -> Vector3 - Returns the length of each axis of this basis, as a Vector3.
- inverse() -> Basis - Returns the .
- is_conformal() -> bool - Returns `true` if this basis is conformal.
- is_equal_approx(b: Basis) -> bool - Returns `true` if this basis and `b` are approximately equal, by calling `@GlobalScope.
- is_finite() -> bool - Returns `true` if this basis is finite, by calling `@GlobalScope.
- is_orthonormal() -> bool - Returns `true` if this basis is orthonormal.
- looking_at(target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false) -> Basis - Creates a new Basis with a rotation such that the forward axis (-Z) points towards the `target` position.
- orthonormalized() -> Basis - Returns the orthonormalized version of this basis.
- rotated(axis: Vector3, angle: float) -> Basis - Returns a copy of this basis rotated around the given `axis` by the given `angle` (in radians).
- scaled(scale: Vector3) -> Basis - Returns this basis with each axis's components scaled by the given `scale`'s components.
- scaled_local(scale: Vector3) -> Basis - Returns this basis with each axis scaled by the corresponding component in the given `scale`.
- slerp(to: Basis, weight: float) -> Basis - Performs a spherical-linear interpolation with the `to` basis, given a `weight`.
- tdotx(with: Vector3) -> float - Returns the transposed dot product between `with` and the `x` axis (see `transposed`).
- tdoty(with: Vector3) -> float - Returns the transposed dot product between `with` and the `y` axis (see `transposed`).
- tdotz(with: Vector3) -> float - Returns the transposed dot product between `with` and the `z` axis (see `transposed`).
- transposed() -> Basis - Returns the transposed version of this basis.

**Enums:**
**Constants:** IDENTITY=Basis(1, 0, 0, 0, 1, 0, 0, 0, 1), FLIP_X=Basis(-1, 0, 0, 0, 1, 0, 0, 0, 1), FLIP_Y=Basis(1, 0, 0, 0, -1, 0, 0, 0, 1), FLIP_Z=Basis(1, 0, 0, 0, 1, 0, 0, 0, -1)

