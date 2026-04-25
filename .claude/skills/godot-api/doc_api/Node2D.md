## Node2D <- CanvasItem

A 2D game object, with a transform (position, rotation, and scale). All 2D nodes, including physics objects and sprites, inherit from Node2D. Use Node2D as a parent node to move, scale and rotate children in a 2D project. Also gives control of the node's render order. **Note:** Since both Node2D and Control inherit from CanvasItem, they share several concepts from the class such as the `CanvasItem.z_index` and `CanvasItem.visible` properties.

**Props:**
- global_position: Vector2
- global_rotation: float
- global_rotation_degrees: float
- global_scale: Vector2
- global_skew: float
- global_transform: Transform2D
- position: Vector2 = Vector2(0, 0)
- rotation: float = 0.0
- rotation_degrees: float
- scale: Vector2 = Vector2(1, 1)
- skew: float = 0.0
- transform: Transform2D

**Methods:**
- apply_scale(ratio: Vector2) - Multiplies the current scale by the `ratio` vector.
- get_angle_to(point: Vector2) -> float - Returns the angle between the node and the `point` in radians.
- get_relative_transform_to_parent(parent: Node) -> Transform2D - Returns the Transform2D relative to this node's parent.
- global_translate(offset: Vector2) - Adds the `offset` vector to the node's global position.
- look_at(point: Vector2) - Rotates the node so that its local +X axis points towards the `point`, which is expected to use global coordinates.
- move_local_x(delta: float, scaled: bool = false) - Applies a local translation on the node's X axis with the amount specified in `delta`.
- move_local_y(delta: float, scaled: bool = false) - Applies a local translation on the node's Y axis with the amount specified in `delta`.
- rotate(radians: float) - Applies a rotation to the node, in radians, starting from its current rotation.
- to_global(local_point: Vector2) -> Vector2 - Transforms the provided local position into a position in global coordinate space.
- to_local(global_point: Vector2) -> Vector2 - Transforms the provided global position into a position in local coordinate space.
- translate(offset: Vector2) - Translates the node by the given `offset` in local coordinates.

