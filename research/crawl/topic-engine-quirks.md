# Engine Quirks & Regressions — Godot 4.5/4.6 (Jan 2026+)

**Generated:** 2026-04-26 | **Updated:** 2026-05-01  
**Baseline:** Godot 4.6.2-stable (production)  
**Out of scope:** 4.7-beta findings (noted in watch list only); already-known drag/input issues per TESTING.md Pattern 4

---

## TL;DR — Top 3 Findings

1. **`is_action_just_pressed_by_event` / `is_action_just_released_by_event` always return false for mouse clicks** (issue #118521, open as of 2026-05-01). Mouse event conversion creates a new object ID that no longer matches, so the `_by_event` variants are broken for all mouse button inputs. Use `Input.is_action_just_pressed()` instead.
2. **AnimationPlayer: manually-created events silently wiped on 4.6.0 → 4.6.1 upgrade** (issue #116408, open, milestone 4.7). Method-call tracks and custom signal tracks vanish on first open in 4.6.1+. No workaround; back up `.tscn` files before upgrading.
3. **`.tscn` exports non-deterministic in 4.6 until files are re-saved** (issue #115971, open, milestone 4.7). The `unique_id` added per node in 4.6 is generated non-deterministically on first-open of any 4.5 scene, breaking patch-PCK exports and producing spurious VCS diffs.

---

## Findings

---

### 1. `is_action_just_pressed_by_event` / `is_action_just_released_by_event` broken for mouse buttons

**Severity:** HIGH (breaks any code that distinguishes which device triggered an action)

**Description:** In Godot 4.6.x, `Input.is_action_just_pressed_by_event(event)` and `Input.is_action_just_released_by_event(event)` always return `false` when `event` is an `InputEventMouseButton`. The internal conversion that maps the raw mouse event to an action (via `xformed_by`) creates a new object with a different internal ID; the `_by_event` methods then fail the ID comparison and return false. Keyboard input is unaffected. This was confirmed in 4.6.2-stable and filed April 13, 2026.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/118521 (filed 2026-04-13, confirmed 4.6.2-stable, still open 2026-05-01)

**Workaround:** Do not use `_by_event` variants for mouse button input. Use `Input.is_action_just_pressed("action_name")` or check `event is InputEventMouseButton && event.pressed` directly in `_unhandled_input`.

**Fix status:** Open. No PR or milestone assigned as of 2026-05-01.

**Related issues:** #84466 (mouse release event location mismatch — separate issue)

---

### 2. AnimationPlayer: manually-created events lost on 4.6.0 → 4.6.1 migration

**Severity:** HIGH (blocks in-flight animation work)

**Description:** Opening a Godot 4.6.0 project in 4.6.1 silently drops all manually-authored animation events (method-call tracks, custom signal tracks). Imported skeleton/blend animations from Blender survive; only hand-crafted events are lost. The regression has been confirmed by multiple reporters.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/116408 (filed 2026-02-17, labeled regression)  
- https://forum.godotengine.org/t/animations-disappearing-from-animation-player-node/136527 (forum, 2026)

**Workaround:** Remain on 4.6.0 until a fix lands, or manually re-enter events after migration. Back up `.tscn` files before upgrading.

**Fix status:** Open. Milestone set to 4.7. Not in 4.6.2.

**Related issues:** #116231 (animation path hashing — separate failure mode)

---

### 3. `.tscn` export non-deterministic after 4.5→4.6 migration

**Severity:** HIGH for teams using patch PCKs; MED for version control discipline

**Description:** Godot 4.6 added a `unique_id` field to every scene node (from PR #106837) to support scene-inheritance refactoring. For scenes created in 4.5.x and first-opened in 4.6, the `unique_id` is generated non-deterministically. This means successive exports of the same unmodified scene produce different binary output, breaking patch-PCK workflows and causing VCS diffs to show files as "changed" even after no edits. Workaround is to open-and-save each scene once in 4.6.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/115971 (filed 2026-02, confirmed 4.6-stable and 4.7.dev, open, milestone 4.7)  
- Source PR: https://github.com/godotengine/godot/pull/106837

**Workaround:** Open every affected `.tscn` in the Godot 4.6 editor and save it (Ctrl+S). Commit the resulting diff as a one-time "upgrade" commit. After that, IDs are stable.

**Fix status:** Open. Milestone 4.7.

---

### 4. Animation path hash collision — wrong property animated

**Severity:** HIGH (silent corruption in any scene with many similarly-named nodes)

**Description:** `AnimationPlayer` indexes track paths via a hash of `NodePath:property`. In 4.6.1 a new hashing algorithm was introduced (#115473) but still used direct-key lookup with no collision bucket. Two paths that hash identically (e.g., `Char23288:position` and `Char104673:position`) caused both tracks to drive the same property with values summed rather than overwriting — no error emitted. Fixed in 4.6.2.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/116231 (filed 2026-02-13, confirmed 4.6 and 4.6.1)  
- Fix: PR #117030, shipped in **4.6.2**

**Workaround (pre-4.6.2):** Rename colliding nodes so their hash values differ. Prefer non-numeric distinguishers or type-string prefixes for procedurally generated names.

**Fix status:** FIXED in 4.6.2. Architectural root cause remains open for deeper work.

---

### 5. Control/TextureButton loses focus on any click (4.6 `hide_focus` regression)

**Severity:** HIGH for UI-heavy games; LOW for this 2D platformer (minimal menus)

**Description:** Godot 4.6 added `hide_focus` semantics to `Control.grab_focus()` — focus no longer shows its visual state when acquired via mouse click. This broke `TextureButton`: clicking anywhere on screen clears the focused button's Focus-state texture and reverts it to Normal, even when the button should stay focused. Affects pause menus, item selectors, focus-ring UI.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/117486 (filed 2026-03-16, confirmed 4.6, labeled regression, milestone 4.7)

**Workaround:** Call `grab_focus(false)` explicitly (passing `hide_focus = false`) to restore old behaviour. For TextureButton, subclass and override `_gui_input()` to re-grab focus after click events.

**Fix status:** Open. Milestone 4.7.

---

### 6. `@tool` script `_physics_process()` silently saves corrupted velocity to .tscn

**Severity:** MED (silent data corruption, hard to debug from Inspector)

**Description:** If a `@tool`-decorated script on a physics body (CharacterBody2D, RigidBody2D) runs `_physics_process()` in the editor without an `Engine.is_editor_hint()` guard, gravity accumulates during edit time. The resulting `velocity` is written to the `.tscn` but is invisible in the Inspector. At runtime the character launches or teleports. The value survives `git` merges invisibly.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/118263 (filed 2026-04, confirmed 4.6.stable, open)

**Workaround:** Always guard physics callbacks in tool scripts:
```gdscript
func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return
```
If already corrupted: open `.tscn` in a text editor, find `velocity` sub-key under the node, delete or reset it.

**Fix status:** Open. No PR yet.

---

### 7. `move_and_slide()` treats wall corner as floor (longstanding, unresolved through 4.6)

**Severity:** MED for 2D platformers (causes jitter/sticking at platform edges)

**Description:** When a `CharacterBody2D`'s edge exactly aligns with the corner of a `StaticBody2D` or tile collision shape, `move_and_slide()` classifies the contact as a floor collision. The character stops falling; `is_on_floor()` may return inconsistently. Particularly visible at one-tile platform edges and ceilings.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/109926 (first confirmed 4.0, last confirmed 4.5.beta6, still open in 4.6)  
- https://github.com/godotengine/godot/issues/87477 (stuck on tilemap ceiling, related)

**Workaround:** Use a capsule `CollisionShape2D` instead of rectangle; slightly round or offset collision shapes to avoid 1:1 pixel-aligned tile edges.

**Fix status:** Open. No milestone assigned.

---

### 8. Vulkan `canvas_item_add_texture_rect_region` performance collapse (fixed in 4.6.2)

**Severity:** MED (was critical for Vulkan TileMapLayer; now resolved if on 4.6.2)

**Description:** Starting in 4.6.dev3, the Vulkan Forward+ renderer triggered a massive draw-call explosion when `canvas_item_add_texture_rect_region` was called in loops (e.g., TileMapLayer rendering many tiles). Performance dropped from ~18 to 24,000+ draw calls. GLES3/Compatibility renderer was unaffected.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/115431 (filed 2026-01, confirmed 4.6)  
- Fix: GH-115757, shipped in **4.6.2**

**Workaround (pre-4.6.2):** Use GLES3/Compatibility renderer, or restructure to avoid region draws.

**Fix status:** FIXED in 4.6.2. TileMapLayer on Vulkan is safe in 4.6.2.

---

### 9. Rendering regression: broken sky shaders, VoxelGI, SDFGI in 4.6.0 (fixed)

**Severity:** LOW for our project (2D platformer; 3D GI not used)

**Description:** Godot 4.6.0 introduced a major rendering regression where Forward+ sky shaders, VoxelGI, and SDFGI produced broken or overexposed results compared to 4.5. Multiple projects reported lighting calibration destroyed on upgrade. Fixed via PR #116155.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/115599 (filed 2026-01-29, closed via PR #116155)

**Fix status:** FIXED (in 4.6.1 or 4.6.2; fix merged to 4.7 milestone). Confirmed no impact on 4.6.2.

---

### 10. TSCN format change: `load_steps` removed, `unique_id` added per node (4.6)

**Severity:** LOW operational — affects VCS diffs and external tooling that parses `.tscn`

**Description:** Godot 4.6 stopped writing `load_steps=<int>` in `[gd_scene]` headers (ignored if present). Each node now gets a `unique_id`. Running "Project > Tools > Upgrade Project Files" rewrites all scenes. First open of a 4.5 project generates large VCS diffs.

**Repro/Citation:**  
- https://github.com/godotengine/godot-docs/issues/11707 ("load_steps has been removed in 4.6")  
- Migration guide: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html

**Workaround:** Run the upgrade tool once and commit the diff as a dedicated "upgrade" commit. No runtime impact — format is compatible with 4.5.

---

## Watch List (Open Issues — Re-scan Periodically)

| Issue | Summary | Last checked | Why watch |
|-------|---------|-------------|-----------|
| [#118521](https://github.com/godotengine/godot/issues/118521) | `is_action_just_pressed_by_event` broken for mouse | 2026-05-01 | Open; no milestone; directly impacts any input code using by-event mouse checks |
| [#116408](https://github.com/godotengine/godot/issues/116408) | AnimationPlayer events lost on 4.6.0→4.6.1 | 2026-05-01 | Open, milestone 4.7; blocks upgrade from 4.6.0 |
| [#115971](https://github.com/godotengine/godot/issues/115971) | .tscn exports non-deterministic after 4.5→4.6 upgrade | 2026-05-01 | Open, milestone 4.7; affects patch PCK and CI pipelines |
| [#117486](https://github.com/godotengine/godot/issues/117486) | TextureButton/Control focus reverts on click | 2026-05-01 | Open, milestone 4.7; will affect pause/HUD menus |
| [#109926](https://github.com/godotengine/godot/issues/109926) | `move_and_slide()` wall corner treated as floor | 2026-05-01 | Open, no milestone; directly impacts platformer edge physics |
| [#118263](https://github.com/godotengine/godot/issues/118263) | `@tool` physics saves velocity into .tscn | 2026-05-01 | Open; silent corruption risk if tool scripts added |
| [4.7 breaking](https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/) | One-way collision resolves all directions (not just up) | 2026-04-27 | Will change platform one-way tile behaviour on 4.7 upgrade |
| [4.7 breaking](https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/) | GPUParticles2D angular velocity semantics fixed | 2026-04-27 | Negate workaround must be reverted on 4.7 upgrade |
