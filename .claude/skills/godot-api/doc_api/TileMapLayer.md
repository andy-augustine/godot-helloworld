## TileMapLayer <- Node2D

Node for 2D tile-based maps. A TileMapLayer uses a TileSet which contain a list of tiles which are used to create grid-based maps. Unlike the TileMap node, which is deprecated, TileMapLayer has only one layer of tiles. You can use several TileMapLayer to achieve the same result as a TileMap node. For performance reasons, all TileMap updates are batched at the end of a frame. Notably, this means that scene tiles from a TileSetScenesCollectionSource are initialized after their parent. This is only queued when inside the scene tree. To force an update earlier on, call `update_internals`. **Note:** For performance and compatibility reasons, the coordinates serialized by TileMapLayer are limited to 16-bit signed integers, i.e. the range for X and Y coordinates is from `-32768` to `32767`. When saving tile data, tiles outside this range are wrapped.

**Props:**
- collision_enabled: bool = true
- collision_visibility_mode: int (TileMapLayer.DebugVisibilityMode) = 0
- enabled: bool = true
- navigation_enabled: bool = true
- navigation_visibility_mode: int (TileMapLayer.DebugVisibilityMode) = 0
- occlusion_enabled: bool = true
- physics_quadrant_size: int = 16
- rendering_quadrant_size: int = 16
- tile_map_data: PackedByteArray = PackedByteArray()
- tile_set: TileSet
- use_kinematic_bodies: bool = false
- x_draw_order_reversed: bool = false
- y_sort_origin: int = 0

**Methods:**
- clear() - Clears all cells.
- erase_cell(coords: Vector2i) - Erases the cell at coordinates `coords`.
- fix_invalid_tiles() - Clears cells containing tiles that do not exist in the `tile_set`.
- get_cell_alternative_tile(coords: Vector2i) -> int - Returns the tile alternative ID of the cell at coordinates `coords`.
- get_cell_atlas_coords(coords: Vector2i) -> Vector2i - Returns the tile atlas coordinates ID of the cell at coordinates `coords`.
- get_cell_source_id(coords: Vector2i) -> int - Returns the tile source ID of the cell at coordinates `coords`.
- get_cell_tile_data(coords: Vector2i) -> TileData - Returns the TileData object associated with the given cell, or `null` if the cell does not exist or is not a TileSetAtlasSource.
- get_coords_for_body_rid(body: RID) -> Vector2i - Returns the coordinates of the physics quadrant (see `physics_quadrant_size`) for given physics body RID.
- get_navigation_map() -> RID - Returns the RID of the NavigationServer2D navigation used by this TileMapLayer.
- get_neighbor_cell(coords: Vector2i, neighbor: int) -> Vector2i - Returns the neighboring cell to the one at coordinates `coords`, identified by the `neighbor` direction.
- get_pattern(coords_array: Vector2i[]) -> TileMapPattern - Creates and returns a new TileMapPattern from the given array of cells.
- get_surrounding_cells(coords: Vector2i) -> Vector2i[] - Returns the list of all neighboring cells to the one at `coords`.
- get_used_cells() -> Vector2i[] - Returns a Vector2i array with the positions of all cells containing a tile.
- get_used_cells_by_id(source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = -1) -> Vector2i[] - Returns a Vector2i array with the positions of all cells containing a tile.
- get_used_rect() -> Rect2i - Returns a rectangle enclosing the used (non-empty) tiles of the map.
- has_body_rid(body: RID) -> bool - Returns whether the provided `body` RID belongs to one of this TileMapLayer's cells.
- is_cell_flipped_h(coords: Vector2i) -> bool - Returns `true` if the cell at coordinates `coords` is flipped horizontally.
- is_cell_flipped_v(coords: Vector2i) -> bool - Returns `true` if the cell at coordinates `coords` is flipped vertically.
- is_cell_transposed(coords: Vector2i) -> bool - Returns `true` if the cell at coordinates `coords` is transposed.
- local_to_map(local_position: Vector2) -> Vector2i - Returns the map coordinates of the cell containing the given `local_position`.
- map_pattern(position_in_tilemap: Vector2i, coords_in_pattern: Vector2i, pattern: TileMapPattern) -> Vector2i - Returns for the given coordinates `coords_in_pattern` in a TileMapPattern the corresponding cell coordinates if the pattern was pasted at the `position_in_tilemap` coordinates (see `set_pattern`).
- map_to_local(map_position: Vector2i) -> Vector2 - Returns the centered position of a cell in the TileMapLayer's local coordinate space.
- notify_runtime_tile_data_update() - Notifies the TileMapLayer node that calls to `_use_tile_data_runtime_update` or `_tile_data_runtime_update` will lead to different results.
- set_cell(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0) - Sets the tile identifiers for the cell at coordinates `coords`.
- set_cells_terrain_connect(cells: Vector2i[], terrain_set: int, terrain: int, ignore_empty_terrains: bool = true) - Update all the cells in the `cells` coordinates array so that they use the given `terrain` for the given `terrain_set`.
- set_cells_terrain_path(path: Vector2i[], terrain_set: int, terrain: int, ignore_empty_terrains: bool = true) - Update all the cells in the `path` coordinates array so that they use the given `terrain` for the given `terrain_set`.
- set_navigation_map(map: RID) - Sets a custom `map` as a NavigationServer2D navigation map.
- set_pattern(position: Vector2i, pattern: TileMapPattern) - Pastes the TileMapPattern at the given `position` in the tile map.
- update_internals() - Triggers a direct update of the TileMapLayer.

**Signals:**
- changed

**Enums:**
**DebugVisibilityMode:** DEBUG_VISIBILITY_MODE_DEFAULT=0, DEBUG_VISIBILITY_MODE_FORCE_HIDE=2, DEBUG_VISIBILITY_MODE_FORCE_SHOW=1

