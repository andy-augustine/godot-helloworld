## Curve3D <- Resource

This class describes a Bézier curve in 3D space. It is mainly used to give a shape to a Path3D, but can be manually sampled for other purposes. It keeps a cache of precalculated points along the curve, to speed up further calculations.

**Props:**
- bake_interval: float = 0.2
- closed: bool = false
- point_count: int = 0
- point_{index}/in: Vector3 = Vector3(0, 0, 0)
- point_{index}/out: Vector3 = Vector3(0, 0, 0)
- point_{index}/position: Vector3 = Vector3(0, 0, 0)
- point_{index}/tilt: float = 0.0
- up_vector_enabled: bool = true

**Methods:**
- add_point(position: Vector3, in: Vector3 = Vector3(0, 0, 0), out: Vector3 = Vector3(0, 0, 0), index: int = -1) - Adds a point with the specified `position` relative to the curve's own position, with control points `in` and `out`.
- clear_points() - Removes all points from the curve.
- get_baked_length() -> float - Returns the total length of the curve, based on the cached points.
- get_baked_points() -> PackedVector3Array - Returns the cache of points as a PackedVector3Array.
- get_baked_tilts() -> PackedFloat32Array - Returns the cache of tilts as a PackedFloat32Array.
- get_baked_up_vectors() -> PackedVector3Array - Returns the cache of up vectors as a PackedVector3Array.
- get_closest_offset(to_point: Vector3) -> float - Returns the closest offset to `to_point`.
- get_closest_point(to_point: Vector3) -> Vector3 - Returns the closest point on baked segments (in curve's local space) to `to_point`.
- get_point_in(idx: int) -> Vector3 - Returns the position of the control point leading to the vertex `idx`.
- get_point_out(idx: int) -> Vector3 - Returns the position of the control point leading out of the vertex `idx`.
- get_point_position(idx: int) -> Vector3 - Returns the position of the vertex `idx`.
- get_point_tilt(idx: int) -> float - Returns the tilt angle in radians for the point `idx`.
- remove_point(idx: int) - Deletes the point `idx` from the curve.
- sample(idx: int, t: float) -> Vector3 - Returns the position between the vertex `idx` and the vertex `idx + 1`, where `t` controls if the point is the first vertex (`t = 0.
- sample_baked(offset: float = 0.0, cubic: bool = false) -> Vector3 - Returns a point within the curve at position `offset`, where `offset` is measured as a distance in 3D units along the curve.
- sample_baked_up_vector(offset: float, apply_tilt: bool = false) -> Vector3 - Returns an up vector within the curve at position `offset`, where `offset` is measured as a distance in 3D units along the curve.
- sample_baked_with_rotation(offset: float = 0.0, cubic: bool = false, apply_tilt: bool = false) -> Transform3D - Returns a Transform3D with `origin` as point position, `basis.
- samplef(fofs: float) -> Vector3 - Returns the position at the vertex `fofs`.
- set_point_in(idx: int, position: Vector3) - Sets the position of the control point leading to the vertex `idx`.
- set_point_out(idx: int, position: Vector3) - Sets the position of the control point leading out of the vertex `idx`.
- set_point_position(idx: int, position: Vector3) - Sets the position for the vertex `idx`.
- set_point_tilt(idx: int, tilt: float) - Sets the tilt angle in radians for the point `idx`.
- tessellate(max_stages: int = 5, tolerance_degrees: float = 4) -> PackedVector3Array - Returns a list of points along the curve, with a curvature controlled point density.
- tessellate_even_length(max_stages: int = 5, tolerance_length: float = 0.2) -> PackedVector3Array - Returns a list of points along the curve, with almost uniform density.

