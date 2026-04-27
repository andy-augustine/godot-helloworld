class_name AbilityIcons
extends RefCounted

# Per-ability icon shapes. Each ability returns an Array of PackedVector2Array
# (multiple disjoint polygons let us draw shapes like "two stacked chevrons"
# without resorting to a multi-polygon hack).
#
# Coordinates are in 24x24 icon-local space, centered at (0, 0). The consumer
# (Pickup, AbilityStrip slot) creates a Polygon2D child per array, all sharing
# the same color (category hue lightened/darkened for readability).
#
# Implementation note: GDScript const can't hold a PackedVector2Array literal
# (it's not a constant expression), so the per-ability shapes live inside
# static functions. Cheap; called once when the icon is built into a parent.

static func _double_jump_polys() -> Array:
	# Two chevrons pointing up — "twice up"
	return [
		PackedVector2Array([Vector2(-7, -3), Vector2(0, -10), Vector2(7, -3), Vector2(5, -1), Vector2(0, -6), Vector2(-5, -1)]),
		PackedVector2Array([Vector2(-7, 6), Vector2(0, -1), Vector2(7, 6), Vector2(5, 8), Vector2(0, 3), Vector2(-5, 8)]),
	]


static func _high_jump_polys() -> Array:
	# Tall upward arrow — single triangle on a stem
	return [
		PackedVector2Array([Vector2(0, -10), Vector2(8, 0), Vector2(3, 0), Vector2(3, 9), Vector2(-3, 9), Vector2(-3, 0), Vector2(-8, 0)]),
	]


static func _dash_polys() -> Array:
	# Rightward arrow with small motion bands at left
	return [
		PackedVector2Array([Vector2(-7, -3), Vector2(3, -3), Vector2(3, -7), Vector2(10, 0), Vector2(3, 7), Vector2(3, 3), Vector2(-7, 3)]),
		PackedVector2Array([Vector2(-10, -2), Vector2(-9, -2), Vector2(-9, 2), Vector2(-10, 2)]),
		PackedVector2Array([Vector2(-12, -5), Vector2(-11, -5), Vector2(-11, -3), Vector2(-12, -3)]),
		PackedVector2Array([Vector2(-12, 3), Vector2(-11, 3), Vector2(-11, 5), Vector2(-12, 5)]),
	]


static func _turbo_polys() -> Array:
	# Lightning bolt — fast/turbo signature
	return [
		PackedVector2Array([Vector2(-2, -10), Vector2(5, -3), Vector2(0, -3), Vector2(4, 10), Vector2(-5, 2), Vector2(0, 2), Vector2(-3, -8)]),
	]


static func _wall_climb_polys() -> Array:
	# Vertical bar (the wall) + stair-step path suggesting climbing
	return [
		PackedVector2Array([Vector2(-10, -10), Vector2(-7, -10), Vector2(-7, 10), Vector2(-10, 10)]),
		PackedVector2Array([Vector2(-5, 6), Vector2(-2, 6), Vector2(-2, 2), Vector2(1, 2), Vector2(1, -2), Vector2(4, -2), Vector2(4, -6), Vector2(7, -6), Vector2(7, -3), Vector2(5, -3), Vector2(5, 1), Vector2(2, 1), Vector2(2, 5), Vector2(-1, 5), Vector2(-1, 9), Vector2(-5, 9)]),
	]


static func get_polygon_set(id: StringName) -> Array:
	match id:
		&"double_jump": return _double_jump_polys()
		&"high_jump":   return _high_jump_polys()
		&"dash":        return _dash_polys()
		&"turbo":       return _turbo_polys()
		&"wall_climb":  return _wall_climb_polys()
		_: return []


# Build the icon as Polygon2D children of a parent node. Color is the icon
# body color (typically the ability category hue lightened for visibility on
# dark slot backgrounds).
static func build_into(parent: Node2D, id: StringName, color: Color, scale_factor: float = 1.0) -> void:
	var polys: Array = get_polygon_set(id)
	for poly in polys:
		var p: Polygon2D = Polygon2D.new()
		var scaled: PackedVector2Array = PackedVector2Array()
		for v in poly:
			scaled.append(v * scale_factor)
		p.polygon = scaled
		p.color = color
		parent.add_child(p)
