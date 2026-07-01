# Godot Engine Quirks & Regressions — Jan 2026 → Jul 2026
*Scope: 4.5→4.6→4.6.3→4.7 changes affecting a 2D Metroidvania platformer on macOS (GL Compatibility, Apple Silicon)*
*Generated: 2026-07-01*

---

## TL;DR — Top 3 Findings

**1. Animation hash collisions silently corrupted property targeting (4.6.0–4.6.3 era; fixed in 4.7).**
Animations in projects with procedurally-named nodes (e.g. `Char23288:position` vs `Char104673:position`) could collide in the TrackCache hash map, causing tracks to apply to wrong targets or combine values. A partial fix shipped in 4.6.1 (GH-115473); the root fix (use StringName pointer IDs instead of hashes) landed in 4.7 via GH-117030 (merged Mar 14 2026). Any project on 4.6.x with many animation tracks should treat this as HIGH risk if nodes have auto-generated or numbered names.

**2. `Input.parse_input_event` Button regression in late-4.6 → 4.7 dev cycle; fixed in 4.7 stable.**
An early-return code path blocked button press events from completing when routed through `parse_input_event`. Directly relevant to this project's synthetic input testing harness. Fixed by GH-119329, merged May 26 2026, shipping in 4.7 stable.

**3. Scene UID non-determinism introduced in 4.6, unfixed through 4.7.**
Scenes saved in ≤4.5.1 export non-deterministically in 4.6+ because the new per-node `unique_id` field regenerates on every export cycle. Milestone pushed to 4.8. Workaround: open and re-save every `.tscn` file once in the editor.

---

## Per-Finding Entries

---

### F1 — Animation Track Hash Collisions (AnimationPlayer/Mixer)

**Severity:** HIGH (for projects with numbered/procedural node names; MED for typical hand-authored scenes)

**Description:**
4.6.0 introduced a new `AHashMap` for AnimationPlayer's `TrackCache`. Two node-path strings that happen to produce the same hash would corrupt each other's track data — animations applied to the wrong property, or combined incorrectly. The symptom is animations moving in wrong directions or combining transforms unexpectedly.

**Repro/Citation:**
- Issue: https://github.com/godotengine/godot/issues/116231 (opened Feb 2026, repro in 4.6.1-rc1)
- Partial fix (improved hash algorithm): GH-115473, Feb 13 2026
- Root fix (IDs instead of hashes): GH-117030, merged Mar 14 2026

**Workaround (on 4.6.x):** Rename colliding nodes to break the hash collision. Check if any nodes share the same numeric suffix pattern.

**Fix ships in:** 4.7-stable (June 18 2026)

**Related:** GH-115993 (AnimationPlayer crash from AHashMap realloc, also fixed in 4.7), GH-115931 (AnimationTree use-after-free on AHashMap realloc)

---

### F2 — `Input.parse_input_event` Breaks Button Events

**Severity:** HIGH (this project uses `parse_input_event` for synthetic input in MCP-driven tests)

**Description:**
A change that added multitouch support to `BaseButton` introduced early `return` statements in the `parse_input_event` code path that prevented button-press logic from executing. Any code calling `Input.parse_input_event` with button events (e.g. jump, attack) would silently drop the press.

**Repro/Citation:**
- PR/fix: https://github.com/godotengine/godot/pull/119329
- Merged: May 26 2026; milestone: 4.7
- Also listed in 4.7 GUI changelog: "Fix `Input.parse_input_event` `Button` regression ([GH-119329](https://github.com/godotengine/godot/pull/119329))"

**Workaround (on 4.6.x):** Call `Input.action_press()` / `Input.action_release()` directly for action testing instead of routing through `parse_input_event` with button events.

**Fix ships in:** 4.7-stable

---

### F3 — Scene Export Non-Determinism (UID Regeneration in 4.6)

**Severity:** MED (no gameplay impact; breaks patch PCK / diff-based workflows and makes git diffs noisy)

**Description:**
PR GH-106837 added a `unique_id` to every scene node in 4.6. The ID generation is non-deterministic, so scenes saved in ≤4.5.1 produce different exports on every run until the scene is re-saved. This breaks delta-PCK patch exports and makes `.tscn` files appear modified on every export without actual content changes.

**Repro/Citation:**
- Issue: https://github.com/godotengine/godot/issues/115971 (Feb 6 2026; confirmed 4.6-stable and 4.7-dev)
- Milestone: 4.8 ("Up for grabs")

**Workaround:** Open every `.tscn` file once and save it in the editor on 4.6+. This stabilizes UIDs for subsequent exports.

**Fix ships in:** 4.8 (not yet, as of July 2026)

---

### F4 — Godot Physics Area Overlap Missed After `area_set_space`

**Severity:** MED (affects Area2D-based hazard/pickup detection in 2D platformers using GodotPhysics)

**Description:**
When a physics area is reparented or its space is changed at runtime (e.g. toggling a hazard area on/off), overlapping bodies could be silently dropped — the engine misses the re-entry event. Manifests as enemies or pickups failing to detect the player after being re-enabled.

**Repro/Citation:**
- Fix: GH-118420 ("Fix Godot Physics missing area overlaps after `area_set_space`")
- Ships in 4.7 changelog (Physics section)
- Source: https://github.com/godotengine/godot/pull/118420

**Workaround (on 4.6.x):** Avoid toggling `monitoring` or reparenting Area2D nodes at runtime; instead hide and disable collision shapes individually. Or call `area_set_space` and then force a re-check with a brief timer.

**Fix ships in:** 4.7-stable

---

### F5 — Sky Shader / VoxelGI / SDFGI Rendering Regression in 4.6

**Severity:** LOW for this project (GL Compatibility renderer; VoxelGI/SDFGI are not used in 2D platformers)

**Description:**
Godot 4.6-stable broke built-in sky shaders, VoxelGI light propagation, and SDFGI quality versus 4.5. Carefully tuned lighting scenes came out overexposed and with severe artifacts. Only affects the Forward+ and Mobile renderers; GL Compatibility is unaffected.

**Repro/Citation:**
- Issue: https://github.com/godotengine/godot/issues/115599
- Fix: GH-116155 ("Add compatibility fallback to `textureLod` when reading from `RADIANCE`"); milestone 4.7

**Fix ships in:** 4.7-stable

---

### F6 — CharacterBody2D Slope Jitter Far from Scene Origin

**Severity:** MED (relevant for large side-scrolling rooms; distance threshold ~30,000+ pixels on X-axis)

**Description:**
CharacterBody2D movement on slopes becomes choppy or jittery when the character is positioned far from `(0,0)` on the X-axis. Severity grows with distance. Certain slope angles (11–13°) trigger it more consistently. Y-axis position has no effect. Not confirmed as a 4.6 regression (may be older), but actively reported against 4.6.1.rc1 in April 2026.

**Repro/Citation:**
- Issue: https://github.com/godotengine/godot/issues/118130 (April 2026, Godot 4.6.1.rc1)
- Status: Open, awaiting triage. No fix yet.

**Workaround:** Keep rooms centered near world origin; use `RemoteTransform2D` or level-chunk loading to avoid large absolute coordinates. This is the standard Metroidvania room-streaming mitigation.

**Fix ships in:** Unknown; not yet targeted.

---

### F7 — AnimatedSprite2D Position Offset Regression (4.4 → 4.6)

**Severity:** MED (affects projects upgrading from 4.4.x to 4.6; animation transforms differ)

**Description:**
Projects using `AnimatedSprite2D` (or `SpriteAnimation2D`) that were working in 4.4.1 show incorrect position offsets in 4.6-stable. The animation transform handling changed between versions. Projects that were started on 4.6 are unaffected; only migrations from 4.4.x are impacted.

**Repro/Citation:**
- Issue: https://github.com/godotengine/godot/issues/116132 (Feb 10 2026, 4.6-stable confirmed; 4.4.1 not reproducible)
- Milestone: 4.7

**Workaround:** Adjust sprite offsets manually post-migration, or keep on 4.6.x and wait for the 4.7 fix.

**Fix ships in:** 4.7-stable (milestone assigned; verify fix is present before upgrading)

---

### F8 — BlendSpace Negative Time Scale Regression (4.7 dev cycle)

**Severity:** LOW for this project (simple 2D platformer; BlendSpace is rarely needed at negative time scales)

**Description:**
An optimization change to BlendSpace1D/2D processing during the 4.7 beta cycle introduced a regression where negative time scales were handled incorrectly. Fixed before 4.7 stable shipped.

**Repro/Citation:**
- Fix: GH-119089 ("Fix negative time scale regression in BlendSpace1D and BlendSpace2D")
- Merged before 4.7-stable (June 18 2026)
- Source: CHANGELOG.md Animation section

**Fix ships in:** 4.7-stable (no action needed; already fixed)

---

### F9 — `ResourceLoader.load_threaded_get` Resources Never Unloaded (4.7 Core)

**Severity:** MED (slow memory leak if threaded resource loading is used for room streaming)

**Description:**
Resources loaded via `ResourceLoader.load_threaded_get()` were never evicted from an internal cache, causing a memory leak proportional to the number of unique resources loaded asynchronously. Critical for any game that uses background room/asset loading.

**Repro/Citation:**
- Fix: GH-119394 ("Fix Resources loaded using `ResourceLoader.load_threaded_get` are never unloaded")
- Also: GH-119757 ("Fix `ResourceLoader::load_threaded_get()` deadlocks"); GH-120077 ("Fix ResourceLoader deadlocks")
- Ships in 4.7 changelog (Core section)

**Workaround (on 4.6.x):** Avoid `load_threaded_get` for room streaming; use synchronous `load()` or manually track and free resources with `ResourceLoader.load_interactive`.

**Fix ships in:** 4.7-stable

---

### F10 — Tree Node Mouse Drag Regression (4.7 stable → 4.7.1)

**Severity:** LOW for gameplay; MED for editor workflow (scene dock drag-drop broken in 4.7.0)

**Description:**
In Godot 4.7-stable, dragging nodes in the Scene tree dock was incorrectly interpreted as touchscreen scroll on macOS and Linux. `drag_touching` conflicted with TreeItem drag-and-drop, making scene-tree reorganization unreliable via mouse drag.

**Repro/Citation:**
- Fix: GH-120728 ("Fix Tree node mouse dragging regression on touchscreens")
- Merged to master: June 30 2026; cherry-picked to 4.7.1 branch same day
- Issue: GH-120669

**Fix ships in:** 4.7.1 (not yet released as of July 1 2026; cherry-pick confirmed)

---

## Watch List — Open Issues Worth Re-Scanning

| Issue | Area | Status | Why Watch |
|-------|------|--------|-----------|
| [GH-118130](https://github.com/godotengine/godot/issues/118130) | Physics/CharacterBody2D | Open, untriaged | Slope jitter at large X coords; affects room-scale layouts |
| [GH-115971](https://github.com/godotengine/godot/issues/115971) | Core/.tscn | Milestone 4.8 | UID non-determinism; re-check if 4.8 ships a fix |
| [GH-118908](https://github.com/godotengine/godot/issues/118908) | Input/Web | Open | MouseMotion fires on button press (web only; not macOS) |
| [GH-110567](https://github.com/godotengine/godot/issues/110567) | Navigation/TileMapLayer | Open since 4.5 | NavigationAgent2D target never reached on TileMapLayer; affects 2D nav if used |
| [GH-116551](https://github.com/godotengine/godot/issues/116551) | Core/Resources | Open | Cyclic resource inclusion false positive on exported `Curve`; affects .tres files |

---

*Sources: GitHub godotengine/godot CHANGELOG.md (raw, master branch, accessed 2026-07-01); individual GitHub issues/PRs as cited above; gamedev.net Godot 4.6.3 release note (May 21 2026); sourcemap.md project intel file.*
