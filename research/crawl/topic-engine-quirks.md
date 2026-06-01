# Engine Quirks & Regressions — Godot 4.5/4.6
**Scope:** New since January 2026 · 2D Metroidvania context
**Crawl date:** 2026-06-01
**Sources:** github.com/godotengine/godot issues/PRs, CHANGELOG.md, godotengine.org release notes, interactive changelog

---

## TL;DR — Top 3 Findings

1. **GLES3 / Compatibility renderer silently drops entire TileMapLayer render passes** at specific tile counts. If you use the Compatibility renderer (GLES3) and your tile counts hit multiples of `max_instances_per_buffer`, entire layers vanish or flash. Fixed in **4.6.3** (GH-117725), but upgrading is mandatory.

2. **CharacterBody2D slope jitter worsens with distance from origin.** Floating-point precision loss causes choppy slope traversal starting around 16 000 px from (0,0) and growing unplayable at 30 000+ px. **No engine fix yet** (open as of 2026-06-01, GH-118130). Affects long horizontal Metroidvania maps; workaround is to keep world geometry near origin or use streaming/chunked levels.

3. **UID assignment regression in 4.6.0–4.6.2 corrupts resource references on reimport.** Newly imported files were not having their existing UIDs assigned, causing `ResourceSaver` to fail silently and scene references to drift. Fixed in **4.6.3** (GH-118037). Upgrade to 4.6.3 before expanding the asset pipeline.

---

## Findings

---

### F1 — GLES3 Batching Drops Entire TileMapLayer Render Passes
**Severity:** HIGH (2D platformer running Compatibility/GLES3 renderer)
**Status:** Fixed in 4.6.3

**Description:** The GLES3 batching system had a logic error where, when the final instance in a batch brought the total to an exact multiple of `max_instances_per_buffer`, the index counter reset to zero and an `if (index == 0)` guard skipped rendering all accumulated instances. Three symptoms were reported: TileMapLayer tiles missing at specific tile counts; TileMap crashes under SubViewport in Compatibility mode; TileMapLayer disappearing at certain camera positions and zoom levels.

**Repro/Citation:** GH-117725 (merged April 2026, cherry-picked to 4.6.3).
https://github.com/godotengine/godot/pull/117725

**Workaround (pre-4.6.3):** Pad tile counts so they don't hit a multiple of the buffer size, or switch to the Forward+ renderer temporarily.

**Related:** GH-115588 (black screen on project load, 4.6.0 regression, also fixed in maintenance releases).

---

### F2 — CharacterBody2D Slope Jitter at Large Distances from Origin
**Severity:** HIGH (affects core platformer movement on large maps)
**Status:** OPEN as of 2026-06-01 (GH-118130, filed April 2, 2026)

**Description:** Floating-point precision loss in the 2D physics solver causes choppy, jittery slope traversal as the CharacterBody2D moves far from world origin. Noticeable around x=16 000 px; severe at x=30 000–100 000+ px. Specific slope angles (≈11–13°) are most affected. Higher movement speeds amplify the effect. Standard mitigations (`max_angle`, `snap_length`) do not help.

**Repro/Citation:** GH-118130.
https://github.com/godotengine/godot/issues/118130

**Workaround:** Keep all playable geometry within ~10 000 px of (0,0). For large maps, use a world-streaming approach where the camera/level origin stays near zero. This is already good practice for 2D; if your Metroidvania rooms exceed this radius you will hit this bug.

**Related:** GH-117288 (`on_floor` false positive with AnimatableBody2D moving platform + StaticBody2D edge — open, filed March 2026).

---

### F3 — UID Assignment Silent Failure in 4.6.0–4.6.2 (Resource References Drift)
**Severity:** HIGH (breaks save/load and scene references after asset reimport)
**Status:** Fixed in 4.6.3

**Description:** Three linked bugs in `EditorFileSystem::_update_scan_actions`: (1) spurious "Unrecognized UID" errors on reimport; (2) UIDs present on disk but not in cache were never assigned to the file object, causing `ResourceSaver::get_resource_id_for_path` to resolve stale data; (3) those UIDs were never registered in `ResourceUID`. Net effect: after reimporting an asset, scene nodes referencing it could silently drift to wrong resources or lose their link entirely.

**Repro/Citation:** GH-118037 (merged April 7, 2026); GH-109636.
https://github.com/godotengine/godot/pull/118037

**Workaround (pre-4.6.3):** Force a full project reimport (`Project → Reimport All`) after any asset replacement; validate UID consistency manually.

**Related:** GH-118522 — scene unique IDs on nodes change after every GLB reimport (fixed 4.6.3).

---

### F4 — Scene Unique IDs Regenerate on Every GLB Reimport
**Severity:** MED (breaks node path references and signal connections in inherited 3D scenes)
**Status:** Fixed in 4.6.3

**Description:** When a scene inherits a GLB and the imported instance is replaced on reimport, node Unique IDs were not preserved — they were regenerated each time. Any code or signal using `%UniqueNodeName` syntax referencing those nodes would break silently after each reimport cycle.

**Repro/Citation:** GH-118522 (merged ~April 2026, cherry-picked 4.6.3); GH-117605.
https://github.com/godotengine/godot/pull/118522

**Workaround (pre-4.6.3):** Avoid inheriting GLB scenes directly; instead, instantiate them as sub-scenes without Unique IDs on the imported nodes.

---

### F5 — CharacterBody2D Miss-Reporting Collisions with Falling RigidBody2D
**Severity:** MED (affects hazard/enemy collision detection in platformers)
**Status:** OPEN as of 2026-06-01 (GH-119824, filed May 27, 2026; reproduces 4.5.2–4.7-beta3)

**Description:** When a CharacterBody2D is already in contact with the floor and a RigidBody2D falls onto it from above, `get_slide_collision()` on the character body returns no collision for the incoming rigid body, even though the RigidBody2D correctly detects the impact. Root cause is collision resolution ordering: when the character is already grounded, the solver repositions it before processing the new contact.

**Repro/Citation:** GH-119824.
https://github.com/godotengine/godot/issues/119824

**Workaround:** Detect the collision from the RigidBody2D side (`_integrate_forces` or `body_entered` signal on the rigid body) rather than from the character side. For falling objects/enemies that need to interact with the player, use Area2D on the RigidBody2D to detect overlap with the player's shape.

---

### F6 — TileMapLayer Collision Phantom Cuts (Tile-Seam Snag)
**Severity:** MED (causes invisible walls/slides mid-tilemap for platformers)
**Status:** OPEN as of 2026-06-01 (GH-119163, filed May 2, 2026; confirmed 4.6-stable and 4.7.dev3)

**Description:** Characters using `move_and_slide()` with square collision shapes snag on invisible seams between tiles in a TileMapLayer, causing micro-stops or unexpected slides even on flat ground. This is the classic "ghost collision" problem that was partially fixed in 4.6 (GH-106084 fixed `segment_intersects_convex`) but persists in tile-edge scenarios.

**Repro/Citation:** GH-119163.
https://github.com/godotengine/godot/issues/119163

**Workaround:** Use a slightly-smaller-than-tile capsule or circle collision shape for the player instead of a rectangle. Alternatively, use GodotPhysics instead of Jolt if Jolt is the active physics engine (though Jolt is the 4.6+ default for new 3D projects; 2D uses GodotPhysics by default).

---

### F7 — AnimationTree StateMachine Inspector Fails to Update Without Deselect
**Severity:** LOW (editor workflow friction; no runtime impact)
**Status:** OPEN as of 2026-06-01 (GH-119249; affects 4.6.2 and 4.7-beta1)

**Description:** When the AnimationTree node is selected in the scene and you then click a StateMachine node inside the AnimationTree panel, the inspector continues showing AnimationTree properties instead of switching to StateMachine properties.

**Repro/Citation:** GH-119249.
https://github.com/godotengine/godot/issues/119249

**Workaround:** Click outside the StateMachine node to deselect, then reselect it to force inspector refresh.

---

### F8 — NodePath Properties Throw Errors When Referenced Node Is Deleted
**Severity:** LOW (editor error spam; no crash, no data loss in most cases)
**Status:** Fixed in 4.6.3

**Description:** If a node with a NodePath property (e.g., a path target, a remote transform target) has its referenced node deleted in the editor, the property inspector logged errors. In some edge cases this could cascade into editor instability.

**Repro/Citation:** GH-115274 (merged April 13, 2026, cherry-picked 4.6.3).
https://github.com/godotengine/godot/pull/115274

**Workaround (pre-4.6.3):** Ensure NodePath targets are cleared before deleting referenced nodes.

---

### F9 — Volumetric Fog Visual Break on Projects Upgrading from 4.5 to 4.6
**Severity:** LOW (rendering aesthetics; 3D only — note for future 3D use)
**Status:** Escape hatch added in 4.6.3

**Description:** PRs #111998 and #112494 rewrote the volumetric fog blending equation in 4.6, which is technically more correct but breaks the visual appearance of any project that had tuned fog in 4.5. No way to restore old look by adjusting settings alone.

**Repro/Citation:** GH-119414 (project setting to restore legacy fog behavior, shipped 4.6.3).
https://github.com/godotengine/godot/pull/119414

**Workaround:** After upgrading to 4.6.3, enable `Rendering > Environment > Volumetric Fog > Use Legacy Blending` project setting to restore pre-4.6 appearance at no runtime cost (uses a specialization constant). Requires engine restart.

---

### F10 — Label `add_child` 150–400× Slower for Certain Unicode Characters
**Severity:** LOW (affects UI initialization with multilingual or symbol-heavy labels)
**Status:** OPEN as of 2026-06-01 (GH-116216, filed February 2026)

**Description:** Adding a Label node containing certain Unicode code points (e.g., ☠, ☥, 𝜎) to the scene tree is 150–400× slower than ASCII equivalents — 35 000–106 000 µs versus ~240 µs. Affects runtime `add_child` calls, not just editor. No workaround documented.

**Repro/Citation:** GH-116216.
https://github.com/godotengine/godot/issues/116216

**Workaround:** Avoid those code points in runtime-added Labels if you see frame spikes; use images/sprites for decorative symbols.

---

## Watch List — Open Issues Worth Re-Scanning

| # | Title | Why it matters | URL |
|---|---|---|---|
| 118130 | CharacterBody2D slope jitter at distance | Core platformer movement; no fix yet | https://github.com/godotengine/godot/issues/118130 |
| 119824 | CharacterBody2D misses RigidBody2D collision from above | Hazard/enemy hit detection | https://github.com/godotengine/godot/issues/119824 |
| 119163 | TileMapLayer collision cut (ghost seams) | Invisible walls in tile rooms | https://github.com/godotengine/godot/issues/119163 |
| 117288 | `on_floor` false positive with moving platform | Platform-riding edge case | https://github.com/godotengine/godot/issues/117288 |
| 116216 | Label `add_child` slow for Unicode symbols | HUD / UI with non-ASCII glyphs | https://github.com/godotengine/godot/issues/116216 |
| 119249 | AnimationTree inspector not updating | Workflow friction during dev | https://github.com/godotengine/godot/issues/119249 |
| 114044 | Wayland `MOUSE_MODE_CAPTURED` escape from window | Linux players with Wayland compositors | https://github.com/godotengine/godot/issues/114044 |
| 116663 | Large TileSet atlas lag in editor | Asset pipeline / tileset editing | https://github.com/godotengine/godot/issues/116663 |

**Re-scan cadence:** check at 4.6.4 release or 4.7-stable (expected late June 2026); issues 118130 and 119824 are highest priority.

---

## Already-Known / Do Not Re-Discover

- Synthetic drag via `Input.parse_input_event` with `relative_x/y` populated works in 4.6.2 — documented in TESTING.md Pattern 4.
- godot-mcp-pro auto-promotion of `unhandled` on motion events — local patch at github.com/youichi-uda/godot-mcp-pro/pull/25.
- `force_drag` + synthetic release dead end — by design, documented in TESTING.md Pattern 4.
