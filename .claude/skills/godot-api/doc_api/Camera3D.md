## Camera3D <- Node3D

Camera3D is a special node that displays what is visible from its current location. Cameras register themselves in the nearest Viewport node (when ascending the tree). Only one camera can be active per viewport. If no viewport is available ascending the tree, the camera will register in the global viewport. In other words, a camera just provides 3D display capabilities to a Viewport, and, without one, a scene registered in that Viewport (or higher viewports) can't be displayed.

**Props:**
- attributes: CameraAttributes
- compositor: Compositor
- cull_mask: int = 1048575
- current: bool = false
- doppler_tracking: int (Camera3D.DopplerTracking) = 0
- environment: Environment
- far: float = 4000.0
- fov: float = 75.0
- frustum_offset: Vector2 = Vector2(0, 0)
- h_offset: float = 0.0
- keep_aspect: int (Camera3D.KeepAspect) = 1
- near: float = 0.05
- projection: int (Camera3D.ProjectionType) = 0
- size: float = 1.0
- v_offset: float = 0.0

**Methods:**
- clear_current(enable_next: bool = true) - If this is the current camera, remove it from being current.
- get_camera_projection() -> Projection - Returns the projection matrix that this camera uses to render to its associated viewport.
- get_camera_rid() -> RID - Returns the camera's RID from the RenderingServer.
- get_camera_transform() -> Transform3D - Returns the transform of the camera plus the vertical (`v_offset`) and horizontal (`h_offset`) offsets; and any other adjustments made to the position and orientation of the camera by subclassed cameras such as XRCamera3D.
- get_cull_mask_value(layer_number: int) -> bool - Returns whether or not the specified layer of the `cull_mask` is enabled, given a `layer_number` between 1 and 20.
- get_frustum() -> Plane[] - Returns the camera's frustum planes in world space units as an array of Planes in the following order: near, far, left, top, right, bottom.
- get_pyramid_shape_rid() -> RID - Returns the RID of a pyramid shape encompassing the camera's view frustum, ignoring the camera's near plane.
- is_position_behind(world_point: Vector3) -> bool - Returns `true` if the given position is behind the camera (the blue part of the linked diagram).
- is_position_in_frustum(world_point: Vector3) -> bool - Returns `true` if the given position is inside the camera's frustum (the green part of the linked diagram).
- make_current() - Makes this camera the current camera for the Viewport (see class description).
- project_local_ray_normal(screen_point: Vector2) -> Vector3 - Returns a normal vector from the screen point location directed along the camera.
- project_position(screen_point: Vector2, z_depth: float) -> Vector3 - Returns the 3D point in world space that maps to the given 2D coordinate in the Viewport rectangle on a plane that is the given `z_depth` distance into the scene away from the camera.
- project_ray_normal(screen_point: Vector2) -> Vector3 - Returns a normal vector in world space, that is the result of projecting a point on the Viewport rectangle by the inverse camera projection.
- project_ray_origin(screen_point: Vector2) -> Vector3 - Returns a 3D position in world space, that is the result of projecting a point on the Viewport rectangle by the inverse camera projection.
- set_cull_mask_value(layer_number: int, value: bool) - Based on `value`, enables or disables the specified layer in the `cull_mask`, given a `layer_number` between 1 and 20.
- set_frustum(size: float, offset: Vector2, z_near: float, z_far: float) - Sets the camera projection to frustum mode (see `PROJECTION_FRUSTUM`), by specifying a `size`, an `offset`, and the `z_near` and `z_far` clip planes in world space units.
- set_orthogonal(size: float, z_near: float, z_far: float) - Sets the camera projection to orthogonal mode (see `PROJECTION_ORTHOGONAL`), by specifying a `size`, and the `z_near` and `z_far` clip planes in world space units.
- set_perspective(fov: float, z_near: float, z_far: float) - Sets the camera projection to perspective mode (see `PROJECTION_PERSPECTIVE`), by specifying a `fov` (field of view) angle in degrees, and the `z_near` and `z_far` clip planes in world space units.
- unproject_position(world_point: Vector3) -> Vector2 - Returns the 2D coordinate in the Viewport rectangle that maps to the given 3D point in world space.

**Enums:**
**ProjectionType:** PROJECTION_PERSPECTIVE=0, PROJECTION_ORTHOGONAL=1, PROJECTION_FRUSTUM=2
**KeepAspect:** KEEP_WIDTH=0, KEEP_HEIGHT=1
**DopplerTracking:** DOPPLER_TRACKING_DISABLED=0, DOPPLER_TRACKING_IDLE_STEP=1, DOPPLER_TRACKING_PHYSICS_STEP=2

