# 2D Platformer Patterns — Godot 4.7 Intel
*Crawled: 2026-09-01 | Window: August 2026 onward (previous crawl: 2026-08-01)*
*Sources: sourcemap.md v2 | Previous crawl baseline: research/tools/godot-4.6-current-intel.md §4.4*
*Engine target: Godot 4.7.2 (stable, Aug 18 2026). Prior target was 4.7.1.*

> **Delta note.** The August 1 crawl covered 4.7.1-era patterns thoroughly (P1–P11 in the synthesis).
> This file covers only what is new or materially changed since that date.
> Do NOT re-read P1–P11 from the synthesis as new findings; they remain valid unless explicitly
> superseded below.

---

## TL;DR — Top 3 Findings

1. **Upgrade to 4.7.2 now.** The Shift-key simultaneous-release bug (GH-125811, fixed in 4.7.2)
   is a silent platformer input breakage: releasing Shift + a direction key in the same frame
   fired only one `INPUT_KEY` action released event in 4.7.0–4.7.1. Zero breaking changes;
   free update. This is the single highest-priority action from this crawl.

2. **4.7.2 threading hardening likely resolves the threaded TileSet load bug (GH-120482).**
   The "threading hardening" block in the 4.7.2 changelog maps to the same subsystem as the
   `load_threaded_request` + TileSet sources regression. The previous crawl marked this HIGH
   before any room-streaming work. Re-test synchronous vs. threaded load on 4.7.2 before
   starting that work — the workaround (synchronous load) may no longer be required.

3. **Four previous-crawl open issues are NOT fixed in 4.7.2 and still affect our stack.**
   Camera2D built-in smoothing gray screen (GH-121843), AnimationPlayer scene-root path
   writing (GH-120921), TileSet editor physics-layer freeze (GH-120873), Area2D monitorable
   toggle no-op (GH-121094). All four have confirmed workarounds already in the codebase or
   in STRUCTURE.md; no new action needed, but do not remove the workarounds.

---

## Per-Pattern Entries

### P-A. Shift Key Simultaneous Release — platformer input breakage, FIXED in 4.7.2
**Applicability: HIGH**

In 4.7.0 and 4.7.1, releasing two keys in the same physics frame where one was Shift fired only
one `action_released` event. For a CharacterBody2D platformer where sprint is `ui_run`
(Shift + direction) and the player releases the movement key and Shift together, the game
silently continued treating one as held. The fix landed in 4.7.2 (August 18, 2026).

**Action:** Upgrade to 4.7.2 and remove any `Input.is_key_pressed(KEY_SHIFT)` polling workaround
if one was added to compensate. Re-run the jump+run combo in the playtest after upgrading.

**Citation:** Godot 4.7.2 release notes, opensourceforu.com/2026/08/godot-4-7-2-released/
(2026-08-18). Issue confirmed to affect 4.7.0–4.7.1; absent in 4.6.x.

---

### P-B. Threaded TileSet Load Regression (GH-120482) — Status Update for 4.7.2
**Applicability: HIGH (gate on room streaming work)**

Previous finding (Aug 1 crawl): `load_threaded_request(path, "", true)` on a scene containing
TileMapLayer yielded a TileSet with zero atlas sources at runtime. Workaround: synchronous
`load()` or disable sub-threads.

4.7.2 release notes cite "threading hardening" as a targeted fix category. The specific issue
tracker entry (GH-120482) is not listed by name, but the subsystem matches. **Do not remove
the synchronous-load workaround until explicit re-test on 4.7.2 confirms the regression is
resolved.** Check GH-120482 for a "fixed in 4.7.2" label before starting room streaming.

**Citation:** 4.7.2 changelog summary, opensourceforu.com/2026/08/godot-4-7-2-released/.
Original issue: github.com/godotengine/godot/issues/120482 (2026-06-20, labeled regression).

---

### P-C. 4.7.2 Has Zero Breaking Changes — Safe to Upgrade
**Applicability: HIGH (decision gate)**

The sourcemap confirms no breaking changes in 4.7.2 for GL Compatibility 2D projects. The
release addresses only bugs (57 fixes from 39 developers). The upgrade path from 4.7.1 is:
back up project, bump `config/features` in project.godot, test playback. No GDScript API
removals, no TileMapLayer API changes, no CharacterBody2D behavior changes.

**Citation:** opensourceforu.com/2026/08/godot-4-7-2-released/ (2026-08-18).

---

### P-D. 4.8-dev4 Object Property Access 1.6× Faster — Future Direction
**Applicability: MED (not stable)**

4.8-dev4 (August 26, 2026) includes a `_physics_process` optimization: object property
access via GDScript is now 1.6× faster per the dev4 changelog. This matters for
CharacterBody2D movement scripts that access `velocity`, `position`, and collision result
fields on every tick. Not stable and not a reason to migrate (4.8-dev2 still crashes on
projects with RESET AnimationPlayer tracks — GH-121681, unresolved as of crawl date).

**Action:** Recheck GH-121681 closure before attempting 4.8 migration.

**Citation:** godotengine.org/article/dev-snapshot-godot-4-8-dev-4/ (2026-08-26).

---

### P-E. Camera2D Built-in Smoothing Gray Screen (GH-121843) — Still Open in 4.7.2
**Applicability: HIGH (confirmed still affects our stack)**

No mention of GH-121843 in the 4.7.2 changelog. The macOS + GL Compatibility gray screen when
`position_smoothing_enabled = true` is still present. **The GameCamera's script-driven follow
(`lerp` in `_physics_process`) remains the correct approach and must not be changed to use
built-in smoothing.**

**Citation:** github.com/godotengine/godot/issues/121843 (opened 2026-07-28, not in 4.7.2
notes). Confirmed by absence from 4.7.2 fix list at opensourceforu.com/2026/08/.

---

### P-F. AnimationPlayer at Scene Root Path Bug (GH-120921) — Still Open
**Applicability: MED**

Not addressed in 4.7.2. AnimationPlayer as a direct child of the scene root still writes
local paths instead of `%unique` paths in 4.7.2. The workaround (nest AnimationPlayer one
level down under an intermediate Node2D) applies at next rig revision. No action needed now
since the player rig has not been restructured.

**Citation:** github.com/godotengine/godot/issues/120921 (2026-07-04), confirmed absent
from 4.7.2 changelog.

---

### P-G. DrawableTexture2D (Minimap Primitive) — @tool Bug Still Open
**Applicability: MED**

GH-121113 (`DrawableTexture2D.get_image()` returns blank in @tool scripts) is not in the
4.7.2 fix list. Runtime use (player-explored-room minimap drawn at play time) remains fully
functional. **Editor-time minimap preview is still off the table.** Use a separate editor
plugin approach or defer minimap work to runtime-only.

**Citation:** github.com/godotengine/godot/issues/121113 (2026-07-08).

---

### P-H. Save/Load — No Change, KoBeWi Plugin Still Active
**Applicability: HIGH (unchanged)**

The Metroidvania-System plugin (KoBeWi, storable-object IDs + room-state serialization) shows
no breaking changes in 4.7.2. The `Resource` + JSON pattern for save files remains best
practice. Nothing new to act on; see prior crawl P3 for the full recipe.

**Citation:** github.com/KoBeWi/Metroidvania-System — active as of Aug 2026 per sourcemap
contributor entry.

---

### P-I. TileMapLayer as Optional Build Module in 4.8 — No Runtime Impact
**Applicability: LOW**

Already flagged in prior crawl P11. 4.8-dev4 does not change this further. Standard Godot
builds (which is what we use) keep TileMapLayer. Only relevant if a custom engine build with
`module_tilemap_enabled=no` is ever produced.

---

## Pitfalls We Might Already Be Hitting

| Pitfall | Likelihood | Status |
|---|---|---|
| **Shift key combos silently dropping in 4.7.0–4.7.1** | HIGH if on 4.7.x pre-4.7.2 | FIXED in 4.7.2; upgrade |
| **Camera built-in smoothing** — our GameCamera avoids this, but any "simplify the camera" refactor might re-enable it | MED if refactored | Workaround in place; don't change it |
| **AnimationPlayer at scene root** — player.tscn root is CharacterBody2D with AnimationPlayer as direct child per STRUCTURE.md | HIGH | Apply nest-one-level workaround at next rig revision |
| **Area2D monitorable toggle** — Door.gd uses Area2D; if any code sets `monitorable = false` during transitions instead of `collision_layer = 0`, signals may not fire on re-enable | MED | Audit Door.gd's enable/disable path; use collision_layer |
| **Threaded TileSet load** — not currently used; risk materializes when room streaming is added | LOW now, HIGH then | Re-test on 4.7.2 before starting streaming |

---

## Watch List

| Issue | Priority | Re-scan trigger |
|---|---|---|
| GH-121843 Camera2D smoothing gray screen (macOS + Compat) | HIGH | Every 4.7.x patch; 4.8 stable |
| GH-120482 TileSet sources empty under threaded load | HIGH | Before room-streaming work; confirm 4.7.2 fix |
| GH-120921 AnimationPlayer scene-root path writing | MED | Next player-rig revision |
| GH-121113 DrawableTexture2D @tool blank image | MED | Before minimap work |
| GH-121681 4.8-dev2 crash on RESET tracks | HIGH | 4.8-dev5 or 4.8 stable RC |
| 4.8-dev4 property access speedup | MED | 4.8 stable; recheck _physics_process budget |
