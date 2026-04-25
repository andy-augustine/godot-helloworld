## Rect2

The Rect2 built-in Variant type represents an axis-aligned rectangle in a 2D space. It is defined by its `position` and `size`, which are Vector2. It is frequently used for fast overlap tests (see `intersects`). Although Rect2 itself is axis-aligned, it can be combined with Transform2D to represent a rotated or skewed rectangle. For integer coordinates, use Rect2i. The 3D equivalent to Rect2 is AABB. **Note:** Negative values for `size` are not supported. With negative size, most Rect2 methods do not work correctly. Use `abs` to get an equivalent Rect2 with a non-negative size. **Note:** In a boolean context, a Rect2 evaluates to `false` if both `position` and `size` are zero (equal to `Vector2.ZERO`). Otherwise, it always evaluates to `true`.

**Props:**
- end: Vector2 = Vector2(0, 0)
- position: Vector2 = Vector2(0, 0)
- size: Vector2 = Vector2(0, 0)

**Methods:**
- abs() -> Rect2 - Returns a Rect2 equivalent to this rectangle, with its width and height modified to be non-negative values, and with its `position` being the top-left corner of the rectangle.
- encloses(b: Rect2) -> bool - Returns `true` if this rectangle *completely* encloses the `b` rectangle.
- expand(to: Vector2) -> Rect2 - Returns a copy of this rectangle expanded to align the edges with the given `to` point, if necessary.
- get_area() -> float - Returns the rectangle's area.
- get_center() -> Vector2 - Returns the center point of the rectangle.
- get_support(direction: Vector2) -> Vector2 - Returns the vertex's position of this rect that's the farthest in the given direction.
- grow(amount: float) -> Rect2 - Returns a copy of this rectangle extended on all sides by the given `amount`.
- grow_individual(left: float, top: float, right: float, bottom: float) -> Rect2 - Returns a copy of this rectangle with its `left`, `top`, `right`, and `bottom` sides extended by the given amounts.
- grow_side(side: int, amount: float) -> Rect2 - Returns a copy of this rectangle with its `side` extended by the given `amount` (see `Side` constants).
- has_area() -> bool - Returns `true` if this rectangle has positive width and height.
- has_point(point: Vector2) -> bool - Returns `true` if the rectangle contains the given `point`.
- intersection(b: Rect2) -> Rect2 - Returns the intersection between this rectangle and `b`.
- intersects(b: Rect2, include_borders: bool = false) -> bool - Returns `true` if this rectangle overlaps with the `b` rectangle.
- is_equal_approx(rect: Rect2) -> bool - Returns `true` if this rectangle and `rect` are approximately equal, by calling `Vector2.
- is_finite() -> bool - Returns `true` if this rectangle's values are finite, by calling `Vector2.
- merge(b: Rect2) -> Rect2 - Returns a Rect2 that encloses both this rectangle and `b` around the edges.

