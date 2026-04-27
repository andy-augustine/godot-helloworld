# Engine Quirks & Regressions — Godot 4.5/4.6 (Jan 2026+)

**Generated:** 2026-04-26  
**Baseline:** Godot 4.6.2-stable (production)  
**Out of scope:** 4.7-beta findings (noted in watch list only); already-known drag/input issues per TESTING.md Pattern 4

---

## TL;DR — Top 3 Findings

1. **AnimationPlayer: manually-created events silently wiped on 4.6.0 → 4.6.1 upgrade** (issue #116408, open, milestone 4.7). No workaround; revert to 4.6.0 or re-enter events by hand.
2. **Animation path hash collisions corrupt multi-object scenes** (issue #116231, fixed in 4.6.2 via PR #117030). Track paths with identical hashes apply to the wrong node — affects procedurally generated node names especially.
3. **TextureButton (and Control subclasses) loses focus on any click in 4.6** (issue #117486, open, milestone 4.7). The new `hide_focus` API introduced in 4.6 broke the case where the focus texture should persist.

---

## Findings

---

### 1. AnimationPlayer: manually-created events lost on 4.6.0 → 4.6.1 migration

**Severity:** HIGH (blocks in-flight animation work)

**Description:** Opening a Godot 4.6.0 project in 4.6.1 silently drops all manually-authored animation events (method-call tracks, custom signal tracks). Imported skeleton/blend animations from Blender survive; only hand-crafted events are lost. The regression has been confirmed by multiple reporters.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/116408 (filed 2026-02-17, labeled regression)  
- https://forum.godotengine.org/t/animations-disappearing-from-animation-player-node/136527 (forum, 2026)

**Workaround:** Remain on 4.6.0 until a fix lands, or manually re-enter events after migration. Back up `.tscn` files before upgrading.

**Fix status:** Open. Milestone set to 4.7. Not in 4.6.2.

**Related issues:** #116231 (animation path hashing — separate failure mode)

---

### 2. Animation path hash collision — wrong property animated

**Severity:** HIGH (silent corruption in any scene with many similarly-named nodes)

**Description:** `AnimationPlayer` indexes track paths via a hash of `NodePath:property`. In 4.6.1 a new hashing algorithm was introduced (#115473) but still uses direct-key lookup with no collision bucket. Two paths that hash identically (e.g., `Char23288:position` and `Char104673:position`) cause both tracks to drive the same property; the other node never animates. Effect is visually obvious (diagonal movement, summed offsets) but only detectable through inspection — no error is emitted.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/116231 (filed 2026-02-06, confirmed 4.6 and 4.6.1)  
- Fix: PR #117030, shipped in **4.6.2**

**Workaround (pre-4.6.2):** Rename colliding nodes so their hash values differ. If using procedurally generated names (e.g., `Entity0` … `Entity99999`) prefer non-numeric distinguishers or prefix with a type string.

**Fix status:** FIXED in 4.6.2. Architectural root cause (hash-as-key with no collision handling) remains open for deeper work.

---

### 3. Control/TextureButton loses focus on click (4.6 `hide_focus` regression)

**Severity:** HIGH for UI-heavy games; LOW for this 2D platformer (minimal menus)

**Description:** Godot 4.6 added `hide_focus` semantics to `Control.grab_focus()` and `Control.has_focus()` (PR #110250) — focus no longer shows its visual state when acquired by mouse click. This broke TextureButton: clicking anywhere on screen now clears the focused button's Focus-state texture and reverts it to Normal, even when the button should stay focused. Affects any game with pause menus, item selectors, or focus-ring UI.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/117486 (filed 2026-03-XX, confirmed 4.6, labeled regression, milestone 4.7)  
- Migration docs confirm API change: `Control.grab_focus()` now accepts optional `hide_focus` param

**Workaround:** Call `grab_focus(false)` explicitly (passing `hide_focus = false`) to restore the old behaviour. For TextureButton, you may need to subclass and override `_gui_input()` to re-grab focus after click events.

**Fix status:** Open. Milestone 4.7.

---

### 4. `@tool` script `_physics_process()` silently saves corrupted velocity to .tscn

**Severity:** MED (silent data corruption, hard to debug)

**Description:** If a `@tool`-decorated script on a physics body (CharacterBody2D, RigidBody2D) runs `_physics_process()` in the editor without an `Engine.is_editor_hint()` guard, gravity and other physics forces accumulate during edit time. The resulting `velocity` value is written into the `.tscn` file but never shown in the Inspector. At runtime the character launches or teleports unexpectedly. The value survives `git` merges invisibly.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/118263 (filed 2026-04-XX, confirmed 4.6.stable, open)

**Workaround:** Always guard physics callbacks in tool scripts:
```gdscript
func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return
    # ... rest of logic
```
If already corrupted: open the `.tscn` in a text editor, find the `velocity` sub-key under the node, and delete or reset it.

**Fix status:** Open. Engine could warn or block physics writes in editor mode, but no PR yet.

---

### 5. `move_and_slide()` treats wall corner as floor (longstanding, unresolved through 4.6)

**Severity:** MED for 2D platformers (causes jitter at platform edges)

**Description:** When a `CharacterBody2D`'s edge exactly aligns with the corner of a `StaticBody2D` or tile collision shape, `move_and_slide()` classifies the contact as a floor collision. The character stops falling; `is_on_floor()` returns false, yet physics treats it as grounded. Particularly visible at one-tile platform edges.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/109926 (first confirmed 4.0, last confirmed 4.5.beta6, still open in 4.6)  
- YouTube "Godot 4.6 Collision Bug? CharacterBody2D 'Sticking' Explained & Fixed": https://www.youtube.com/watch?v=7M47Hu9EzYM (Feb 2026)

**Workaround:** Slightly round or offset collision shapes; avoid 1:1 pixel-aligned tile edges. Using a capsule CollisionShape2D instead of a rectangle reduces incidence significantly.

**Fix status:** Open. No milestone assigned. @lawnjelly has looked at related issues but no PR.

---

### 6. Jolt Physics 3D energy leak on elastic collision (fixed in 4.6.2)

**Severity:** LOW for this project (we use 2D; Jolt is 3D default only)

**Description:** With Jolt Physics as the default 3D engine (new in 4.6), a ball bouncing with `restitution = 1.0` (perfectly elastic) gains energy each frame, eventually escaping the scene. Root cause: gravity was applied twice per step in Jolt's integration path.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/115169 (filed 2026-01-XX, confirmed 4.6)  
- Fix: GH-115305, shipped in **4.6.2** ("Rework gravity application to prevent energy increase on elastic collisions")

**Workaround (pre-4.6.2):** Use Godot Physics for 3D temporarily, or add damping.  

**Fix status:** FIXED in 4.6.2.

---

### 7. Vulkan `canvas_item_add_texture_rect_region` performance collapse (fixed in 4.6.2)

**Severity:** MED for 2D games using sprite atlases or region-draw (our TileMapLayer uses this)

**Description:** Starting in 4.6.dev3, the Vulkan renderer caused a massive draw-call explosion when `canvas_item_add_texture_rect_region` was invoked in a loop (e.g., TileMapLayer rendering many tiles). Performance dropped from ~18 draw calls to 24,000+ for the same scene. OpenGL/GLES3 backend was unaffected.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/115431 (filed 2026-01-XX, confirmed 4.6)  
- Fix: GH-115757 ("Fix accidental write-combined memory reads in canvas renderer"), shipped in **4.6.2**

**Workaround (pre-4.6.2):** Use GLES3/Compatibility renderer, or restructure to avoid region draws.

**Fix status:** FIXED in 4.6.2. (Confirming our Vulkan TileMapLayer performance is safe on 4.6.2.)

---

### 8. GPUParticles2D angular velocity inverted (unfixed through 4.6.2)

**Severity:** LOW for platformer (particle polish, not gameplay)

**Description:** Setting a positive `angular_velocity` in a `ParticleProcessMaterial` causes particles to rotate counterclockwise (should be clockwise). Applying a deceleration curve causes a brief opposite-direction spike before stopping. Reproducible in 4.5.1 and 4.6.stable.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/115547 (filed 2026-01-XX, open)  
- Fix merged: PR #117861, targeting **4.7**

**Workaround:** Negate the angular velocity value (use negative values for clockwise rotation) and invert curve values accordingly.

**Fix status:** Fix merged to 4.7 only. Not backported to 4.6.x.

---

### 9. TSCN format change: `load_steps` removed, `unique_id` added per node (4.6)

**Severity:** LOW operational — affects version control diffs and any external tooling that parses `.tscn`

**Description:** Godot 4.6 changed the `.tscn` file format: the `load_steps=<int>` attribute in `[gd_scene]` headers is no longer written (ignored if present). Each node now gets a `unique_id` field to track identity through renames and moves. Running "Project > Tools > Upgrade Project Files" rewrites all scenes to the new format. First open of a 4.5 project generates large diffs in version control.

**Repro/Citation:**  
- https://github.com/godotengine/godot-docs/issues/11707 ("load_steps has been removed in 4.6")  
- Migration guide: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html  

**Workaround:** Run the upgrade tool once and commit the resulting diff as a dedicated "upgrade" commit to keep history clean. No runtime impact — format is forwards/backwards compatible with 4.5.

---

### 10. UID cache stale after overwrite-move in editor file dock (fixed in 4.6)

**Severity:** LOW — only triggers on specific editor workflow

**Description:** Moving file A onto file B (overwrite) in the editor file system dock left stale UID mappings in the filesystem cache. Dependent resources would fail to load until the `.godot/` folder was deleted and rescanned.

**Repro/Citation:**  
- https://github.com/godotengine/godot/issues/114493 (filed 2026-01-XX)  
- Fix: PR #114499, shipped before 4.6 stable

**Workaround (if hit):** Delete `.godot/` folder; editor will rescan on next open.

**Fix status:** FIXED in 4.6.0.

---

## Watch List (Open Issues — Re-scan Periodically)

| Issue | Summary | Last checked | Why watch |
|-------|---------|-------------|-----------|
| [#116408](https://github.com/godotengine/godot/issues/116408) | AnimationPlayer events lost on 4.6.0→4.6.1 | 2026-04-26 | Open, milestone 4.7; blocks any upgrade from 4.6.0 |
| [#117486](https://github.com/godotengine/godot/issues/117486) | TextureButton/Control focus reverts on click | 2026-04-26 | Open, milestone 4.7; will affect pause/HUD menus |
| [#109926](https://github.com/godotengine/godot/issues/109926) | `move_and_slide()` wall corner treated as floor | 2026-04-26 | Open, no milestone; directly impacts platformer edge behavior |
| [#118263](https://github.com/godotengine/godot/issues/118263) | `@tool` physics saves velocity into .tscn | 2026-04-26 | Open; silent corruption if we ever add tool scripts |
| [#115547](https://github.com/godotengine/godot/issues/115547) | GPUParticles2D angular velocity inverted | 2026-04-26 | Fix in 4.7 only; backport to 4.6.x would close this |
| [4.7 breaking: GH-117861](https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/) | 2D `angular_velocity` semantics fixed (RigidBody2D) | 2026-04-26 | Breaking if we adopt 4.7; recheck physics tuning |
| [4.7 breaking: GH-104736](https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/) | One-way collision resolves all directions (not just up) | 2026-04-26 | Will change platform one-way tile behaviour on 4.7 upgrade |
