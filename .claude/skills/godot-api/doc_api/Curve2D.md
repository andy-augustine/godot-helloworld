## Curve2D <- Resource

This class describes a Bézier curve in 2D space. It is mainly used to give a shape to a Path2D, but can be manually sampled for other purposes. It keeps a cache of precalculated points along the curve, to speed up further calculations.

**Props:**
- bake_interval: float = 5.0
- point_count: int = 0
- point_{index}/in: Vector2 = Vector2(0, 0)
- point_{index}/out: Vector2 = Vector2(0, 0)
- point_{index}/position: Vector2 = Vector2(0, 0)

**Methods:**
- add_point(position: Vector2, in: Vector2 = Vector2(0, 0), out: Vector2 = Vector2(0, 0), index: int = -1) - Adds a point with the specified `position` relative to the curve's own position, with control points `in` and `out`.
- clear_points() - Removes all points from the curve.
- get_baked_length() -> float - Returns the total length of the curve, based on the cached points.
- get_baked_points() -> PackedVector2Array - Returns the cache of points as a PackedVector2Array.
- get_closest_offset(to_point: Vector2) -> float - Returns the closest offset to `to_point`.
- get_closest_point(to_point: Vector2) -> Vector2 - Returns the closest point on baked segments (in curve's local space) to `to_point`.
- get_point_in(idx: int) -> Vector2 - Returns the position of the control point leading to the vertex `idx`.
- get_point_out(idx: int) -> Vector2 - Returns the position of the control point leading out of the vertex `idx`.
- get_point_position(idx: int) -> Vector2 - Returns the position of the vertex `idx`.
- remove_point(idx: int) - Deletes the point `idx` from the curve.
- sample(idx: int, t: float) -> Vector2 - Returns the position between the vertex `idx` and the vertex `idx + 1`, where `t` controls if the point is the first vertex (`t = 0.
- sample_baked(offset: float = 0.0, cubic: bool = false) -> Vector2 - Returns a point within the curve at position `offset`, where `offset` is measured as a pixel distance along the curve.
- sample_baked_with_rotation(offset: float = 0.0, cubic: bool = false) -> Transform2D - Similar to `sample_baked`, but returns Transform2D that includes a rotation along the curve, with `Transform2D.
- samplef(fofs: float) -> Vector2 - Returns the position at the vertex `fofs`.
- set_point_in(idx: int, position: Vector2) - Sets the position of the control point leading to the vertex `idx`.
- set_point_out(idx: int, position: Vector2) - Sets the position of the control point leading out of the vertex `idx`.
- set_point_position(idx: int, position: Vector2) - Sets the position for the vertex `idx`.
- tessellate(max_stages: int = 5, tolerance_degrees: float = 4) -> PackedVector2Array - Returns a list of points along the curve, with a curvature controlled point density.
- tessellate_even_length(max_stages: int = 5, tolerance_length: float = 20.0) -> PackedVector2Array - Returns a list of points along the curve, with almost uniform density.

