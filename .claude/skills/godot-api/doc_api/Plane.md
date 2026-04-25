## Plane

Represents a normalized plane equation. `normal` is the normal of the plane (a, b, c normalized), and `d` is the distance from the origin to the plane (in the direction of "normal"). "Over" or "Above" the plane is considered the side of the plane towards where the normal is pointing. **Note:** In a boolean context, a plane will evaluate to `false` if all its components equal `0`. Otherwise, a plane will always evaluate to `true`.

**Props:**
- d: float = 0.0
- normal: Vector3 = Vector3(0, 0, 0)
- x: float = 0.0
- y: float = 0.0
- z: float = 0.0

**Methods:**
- distance_to(point: Vector3) -> float - Returns the shortest distance from the plane to the position `point`.
- get_center() -> Vector3 - Returns the center of the plane.
- has_point(point: Vector3, tolerance: float = 1e-05) -> bool - Returns `true` if `point` is inside the plane.
- intersect_3(b: Plane, c: Plane) -> Variant - Returns the intersection point of the three planes `b`, `c` and this plane.
- intersects_ray(from: Vector3, dir: Vector3) -> Variant - Returns the intersection point of a ray consisting of the position `from` and the direction normal `dir` with this plane.
- intersects_segment(from: Vector3, to: Vector3) -> Variant - Returns the intersection point of a segment from position `from` to position `to` with this plane.
- is_equal_approx(to_plane: Plane) -> bool - Returns `true` if this plane and `to_plane` are approximately equal, by running `@GlobalScope.
- is_finite() -> bool - Returns `true` if this plane is finite, by calling `@GlobalScope.
- is_point_over(point: Vector3) -> bool - Returns `true` if `point` is located above the plane.
- normalized() -> Plane - Returns a copy of the plane, with normalized `normal` (so it's a unit vector).
- project(point: Vector3) -> Vector3 - Returns the orthogonal projection of `point` into a point in the plane.

**Enums:**
**Constants:** PLANE_YZ=Plane(1, 0, 0, 0), PLANE_XZ=Plane(0, 1, 0, 0), PLANE_XY=Plane(0, 0, 1, 0)

