## AABB

The AABB built-in Variant type represents an axis-aligned bounding box in a 3D space. It is defined by its `position` and `size`, which are Vector3. It is frequently used for fast overlap tests (see `intersects`). Although AABB itself is axis-aligned, it can be combined with Transform3D to represent a rotated or skewed bounding box. It uses floating-point coordinates. The 2D counterpart to AABB is Rect2. There is no version of AABB that uses integer coordinates. **Note:** Negative values for `size` are not supported. With negative size, most AABB methods do not work correctly. Use `abs` to get an equivalent AABB with a non-negative size. **Note:** In a boolean context, an AABB evaluates to `false` if both `position` and `size` are zero (equal to `Vector3.ZERO`). Otherwise, it always evaluates to `true`.

**Props:**
- end: Vector3 = Vector3(0, 0, 0)
- position: Vector3 = Vector3(0, 0, 0)
- size: Vector3 = Vector3(0, 0, 0)

**Methods:**
- abs() -> AABB - Returns an AABB equivalent to this bounding box, with its width, height, and depth modified to be non-negative values.
- encloses(with: AABB) -> bool - Returns `true` if this bounding box *completely* encloses the `with` box.
- expand(to_point: Vector3) -> AABB - Returns a copy of this bounding box expanded to align the edges with the given `to_point`, if necessary.
- get_center() -> Vector3 - Returns the center point of the bounding box.
- get_endpoint(idx: int) -> Vector3 - Returns the position of one of the 8 vertices that compose this bounding box.
- get_longest_axis() -> Vector3 - Returns the longest normalized axis of this bounding box's `size`, as a Vector3 (`Vector3.
- get_longest_axis_index() -> int - Returns the index to the longest axis of this bounding box's `size` (see `Vector3.
- get_longest_axis_size() -> float - Returns the longest dimension of this bounding box's `size`.
- get_shortest_axis() -> Vector3 - Returns the shortest normalized axis of this bounding box's `size`, as a Vector3 (`Vector3.
- get_shortest_axis_index() -> int - Returns the index to the shortest axis of this bounding box's `size` (see `Vector3.
- get_shortest_axis_size() -> float - Returns the shortest dimension of this bounding box's `size`.
- get_support(direction: Vector3) -> Vector3 - Returns the vertex's position of this bounding box that's the farthest in the given direction.
- get_volume() -> float - Returns the bounding box's volume.
- grow(by: float) -> AABB - Returns a copy of this bounding box extended on all sides by the given amount `by`.
- has_point(point: Vector3) -> bool - Returns `true` if the bounding box contains the given `point`.
- has_surface() -> bool - Returns `true` if this bounding box has a surface or a length, that is, at least one component of `size` is greater than `0`.
- has_volume() -> bool - Returns `true` if this bounding box's width, height, and depth are all positive.
- intersection(with: AABB) -> AABB - Returns the intersection between this bounding box and `with`.
- intersects(with: AABB) -> bool - Returns `true` if this bounding box overlaps with the box `with`.
- intersects_plane(plane: Plane) -> bool - Returns `true` if this bounding box is on both sides of the given `plane`.
- intersects_ray(from: Vector3, dir: Vector3) -> Variant - Returns the first point where this bounding box and the given ray intersect, as a Vector3.
- intersects_segment(from: Vector3, to: Vector3) -> Variant - Returns the first point where this bounding box and the given segment intersect, as a Vector3.
- is_equal_approx(aabb: AABB) -> bool - Returns `true` if this bounding box and `aabb` are approximately equal, by calling `Vector3.
- is_finite() -> bool - Returns `true` if this bounding box's values are finite, by calling `Vector3.
- merge(with: AABB) -> AABB - Returns an AABB that encloses both this bounding box and `with` around the edges.

