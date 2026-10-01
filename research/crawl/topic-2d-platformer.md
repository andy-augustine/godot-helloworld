# 2D Platformer Patterns — Godot 4.7 Intel
*Crawled: 2026-10-01 | Window: September 2026 onward (previous crawl: 2026-09-01)*
*Sources: sourcemap.md v3 | Engine target: Godot 4.7.2 (stable). 4.8-dev5 shipped Sept 2026.*

> **Delta note.** The September 1 crawl covered 4.7.2-era patterns (P-A through P-I).
> This file covers only what is new or materially changed since that date.
> P-A through P-I remain valid unless explicitly superseded below.

---

## TL;DR — Top 3 Findings

1. **4.8 feature freeze is imminent (October 2026); GH-121681 watch trigger has fired.**
   Dev5 shipped in September 2026 with 183 fixes. The watch list trigger for GH-121681
   (AnimationPlayer RESET-track crash in 4.8-dev2) was "4.8-dev5 or 4.8 stable RC."
   That trigger is now live. Confirm fix status before any 4.8 migration attempt.

2. **SaveKit is a new lightweight save plugin on the new Godot Asset Store.**
   SaveKit (fernforestgames, v0.1, MIT, Apr 2026) targets Godot 4.5+ and offers
   group-based node saving with JSON/binary serializers and a clean extension point.
   First credible GDScript-native alternative to KoBeWi Metroidvania-System for save/load
   since the last crawl. Worth evaluating before implementing our own room-state save system.

3. **Area2D monitorable toggle (GH-121094) is confirmed still open in 4.7.2 and 4.8-dev5.**
   Community threads in September 2026 continue reporting the no-op on re-enable.
   The `collision_layer = 0` / restore workaround is confirmed as the canonical fix.
   Audit Door.gd before any refactor that touches door enable/disable logic.

---

## Per-Pattern Entries

### P-J. 4.8-dev5 Shipped — Feature Freeze Pending, No 2D Runtime Breakage
**Applicability: MED (future planning)**

Godot 4.8 dev5 (September 2026) delivered: mip-level texture streaming (VRAM reduction via
TextureStreaming singleton, must be enabled in project settings — 3D-only benefit), alpha test
coverage fix for foliage, and a 2D editor toolbar redesign (GH-121080, by Jayden Sipe) that
increases parity with the game view toolbar. 183 fixes from 78 contributors.

No 2D runtime API changes in dev5 that affect CharacterBody2D, TileMapLayer, Camera2D, Area2D,
or AnimationPlayer behavior. The 2D toolbar change is editor-UI only — it does not affect .tscn
files, scripts, or runtime.

Feature freeze is scheduled for late October 2026. Beta RC phase expected shortly after.
Current recommendation: stay on 4.7.2 until 4.8 RC is proven stable.

**Citation:** warp2search.net summary of dev-snapshot-godot-4-8-dev-5 (Sept 2026);
sourcemap.md §3 milestones (4.8 dev5 confirmed).

---

### P-K. GH-121681 Watch Trigger Now Live — Recheck Before Any 4.8 Migration
**Applicability: HIGH (gate on 4.8 migration)**

The previous crawl noted: "Recheck GH-121681 closure before attempting 4.8 migration. Trigger:
4.8-dev5 or 4.8 stable RC." Dev5 has now shipped; the trigger has fired.

The issue (4.8-dev2 crash when AnimationPlayer plays any animation whose RESET track references
a node path that isn't present) cannot be confirmed resolved or open through accessible sources
this crawl — the GitHub API for godotengine/godot is not available in this session. **Do not
assume it is fixed.** Before migrating to 4.8 beta, manually verify:
1. Open the issue at github.com/godotengine/godot/issues/121681 in a browser.
2. If closed with a "fixed in 4.8-devN" label, note the dev version and proceed.
3. If still open, keep the workaround: ensure every AnimationPlayer RESET track covers all
   property paths that appear in any other animation on the same player.

**Citation:** Previous crawl P-D + watch list entry; 4.8-dev5 confirmed via warp2search.net.

---

### P-L. SaveKit — New GDScript Save Plugin on Godot Asset Store
**Applicability: MED (pre-save-system work)**

SaveKit (fernforestgames, MIT license, v0.1, submitted 2026-04-10) is the first notable
GDScript-native save plugin released on the new Godot Asset Store (launched with 4.7).
Architecture: nodes added to a `saveable` group; `SaveManager.save_game()` /
`SaveManager.load_game()` serializes them. Built-in JSON and binary formats; extensible via
`SaveKitSerializer` / `SaveKitDeserializer`. Does NOT require a C# runtime.

Contrast with KoBeWi Metroidvania-System (storable-object IDs + room-state serialization):
SaveKit is more general-purpose and simpler; KoBeWi bakes in Metroidvania-specific patterns
(door flags, ability unlocks, room persistence). For our project, KoBeWi remains the better
fit if we adopt a pre-built plugin; SaveKit is worth a look only if we find KoBeWi too opinionated.

Compatibility: Godot 4.5+; should work on 4.7.2 without modification.

**Action:** No action now. Revisit during save-system planning phase.

**Citation:** store.godotengine.org/asset/fernforestgames/savekit/ (confirmed active Oct 2026).

---

### P-M. Area2D Monitorable Toggle (GH-121094) — Confirmed Open, Workaround Canonical
**Applicability: HIGH (Door.gd risk)**

Forum threads dated September 2026 confirm GH-121094 (setting `monitorable = true` on an
Area2D that was previously `false` does not re-trigger `body_entered` for bodies already
overlapping) is still open in 4.7.2 and unaddressed in 4.8-dev5. Community consensus as
of this crawl:

- **Wrong:** `area.monitorable = false` then `area.monitorable = true`
- **Correct:** `area.collision_layer = 0` then restore; or `area.collision_mask = 0` then
  restore. Layer/mask toggle correctly triggers new enter events on the next physics frame.

**Action:** Audit Door.gd. If any enable/disable path touches `monitorable`, replace with
`collision_layer` toggling. This is high-priority before implementing door re-entry logic.

**Citation:** forum.godotengine.org/t/whats-the-latest-status-on-area2d-not-detecting-
staticbody2d-if-not-set-to-monitorable/140997 (Sept 2026 activity confirmed).

---

### P-N. TileMapLayer API Stable — No Changes in 4.7.2 or 4.8-dev5
**Applicability: LOW (no action)**

No TileMapLayer API additions, removals, or behavior changes in 4.7.2 or 4.8-dev5.
The module-opt-out flag (`module_tilemap_enabled=no`) for custom engine builds remains
only relevant for non-standard builds (previously flagged in P-I / P11).

Best practice as of September 2026 (community-confirmed): use `set_cells_terrain_connect()`
for bulk tile writes; never `set_cell()` in a per-frame loop without batching; always convert
world coordinates via `local_to_map(global_pos)` before passing to TileMapLayer methods.
No new patterns emerged; previously-documented recipe is current.

**Citation:** forum.godotengine.org/t/best-architectual-practices-for-using-the-tilemaplayer-
node-programmatically/116440 (active thread, no new engine changes noted).

---

### P-O. Camera2D for Metroidvania — PhantomCamera Plugin Gaining Traction
**Applicability: LOW (our approach is already better)**

An active September 2026 forum thread ("Handling the Camera in Metroidvania games",
forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882) shows the
PhantomCamera plugin (3D/2D, tween-based, active on the new Asset Store) is the most
frequently recommended third-party camera solution for room-based games. However, the
thread authors who tried it for Metroidvania-style room locking report that scripted
Camera2D with `lerp()` in `_physics_process` + explicit `limit_*` updates produces the
same result with less setup overhead.

Our GameCamera (script-driven lerp + explicit limit locking per room) already matches this
pattern. No reason to adopt PhantomCamera. Note: Camera2D built-in smoothing gray screen
(GH-121843) remains unresolved — do not enable built-in smoothing.

**Citation:** forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882
(Sept 2026); GH-121843 still absent from 4.8-dev5 fix list.

---

## Pitfalls We Might Already Be Hitting

| Pitfall | Likelihood | Status |
|---|---|---|
| **Area2D monitorable toggle no-op** — Door.gd enable/disable path | HIGH | GH-121094 still open; use collision_layer toggle instead |
| **AnimationPlayer RESET crash on 4.8** — triggered when migrating | MED on migration | GH-121681 trigger fired; manually verify before any 4.8 attempt |
| **Camera built-in smoothing gray screen** — any "simplify camera" refactor | MED if refactored | GH-121843 still open; our script-driven lerp is correct, don't change it |
| **AnimationPlayer at scene root path bug** — player.tscn rig | MED | GH-120921 still open; nest AnimationPlayer one level down at next rig revision |
| **TileSet threaded load** — not used yet; risk on room streaming | LOW now | GH-120482 4.7.2 fix unverified; re-test synchronous vs threaded on 4.7.2 before starting |

---

## Watch List

| Issue | Priority | Re-scan trigger |
|---|---|---|
| GH-121843 Camera2D smoothing gray screen (macOS + Compat) | HIGH | 4.8 RC or stable |
| GH-121681 4.8-dev2 crash on RESET tracks | HIGH | **TRIGGERED** — manually verify at github.com/godotengine/godot/issues/121681 before 4.8 migration |
| GH-120482 TileSet sources empty under threaded load | HIGH | Before room-streaming work; confirm 4.7.2 fix via manual test |
| GH-121094 Area2D monitorable toggle no-op | HIGH | Before any door re-entry refactor; use collision_layer workaround now |
| GH-120921 AnimationPlayer scene-root path writing | MED | Next player-rig revision |
| GH-121113 DrawableTexture2D @tool blank image | MED | Before minimap editor-preview work |
| 4.8-dev4/dev5 property access 1.6× speedup | MED | 4.8 stable; recheck _physics_process budget |
