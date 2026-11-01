# 2D Platformer Patterns — Intel Delta (October 2026)

**Crawl window:** 2026-10-01 forward  
**Based on:** `research/crawl/sourcemap.md` (crawled 2026-11-01) plus `research/tools/godot-4.6-current-intel.md` (last synthesis 2026-10-01)  
**Target engine:** Godot 4.7.x (current stable); 4.8 beta 1 dropped 2026-10-15  
**Project state:** still on 4.6.2; planned upgrade to 4.7 gated on GH-121843

---

## TL;DR — Top 3 Findings

1. **4.7 adds one-way collision direction on CollisionShape2D** — the most significant new platformer-specific API since TileMapLayer. Pass-through floor tiles can now use a native direction flag instead of script hacks. Relevant to our TileMapLayer terrain setup, MED-priority.
2. **4.8 beta 1 (Oct 15, 2026) fired three watch triggers**: GH-121681 (RESET track crash), GH-123593 (AnimationPlayer capture track segfault on freed nodes), GH-120379 (AnimationPlayer editor freeze). All need manual verification on GitHub before any 4.8 trial. Beta feature freeze means the 4.8 API surface is now locked.
3. **GH-121843 (Camera2D built-in smoothing → gray screen, macOS + Compatibility) is the outstanding 4.7 upgrade blocker.** Status is still provisional (last confirmed via changelog absence Sep 2026). No fix was listed in 4.7.1 or 4.7.2 RC1 changelogs. Manually verify on GitHub before upgrading. Community consensus since September: replace built-in smoothing with a script `lerp` in `_physics_process` regardless of fix status.

---

## Per-Pattern Entries

### Camera Systems — Camera2D, Room Locking, Screen Shake

**What's new (4.7):** No Camera2D API changes in 4.7.x or 4.8-dev5 beyond the bug context. The `position_smoothing` gray-screen regression (GH-121843) is a 4.7 regression, not a 4.7 feature.

**What's new (4.8 beta 1, Oct 15):** 4.8 feature freeze locks the camera API. No Camera2D changes reported in 4.8 beta 1 notes. The `position_smoothing` bug may or may not be fixed — the watch trigger has fired; verify manually.

**Refined best practice (Sep–Oct 2026 community):** Script-driven position smoothing:
```gdscript
position = position.lerp(target, delta * smoothing_speed)
```
Applied in `_physics_process`, this avoids GH-121843 entirely and gives full control over ease-out when entering a room. The Sep 2026 Metroidvania camera forum thread reached consensus on this approach.  
Source: https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882

**Screen shake:** No new API. Signal-driven offset accumulation + exponential decay in `_process` remains the pattern. No known regressions in 4.7.x.

**Applicability:** HIGH — GH-121843 directly blocks the 4.7 upgrade. Our `GameCamera.gd:52` enables `position_smoothing_enabled`; `World.gd:124,151` re-enables it post-transition. Replace before any 4.7 test.

**Pitfall we may be hitting:** None on 4.6. The pitfall activates only after upgrading to 4.7.

---

### TileMapLayer (replaced TileMap in 4.3)

**What's new:** TileMapLayer API is stable. No changes in 4.7.0, 4.7.1, 4.7.2 RC1, or 4.8-dev5. The migration from deprecated `TileMap` to `TileMapLayer` is complete as a platform story; no follow-up churn.

**4.7 addition relevant to TileMapLayer:** The `CollisionShape2D` one-way direction flag (see Collision section below) applies to TileSet collision shapes. This is the only 4.7 change that affects TileMapLayer-based rooms.

**Best practice (unchanged):** `set_cells_terrain_connect()` for bulk writes; never `set_cell()` in a hot loop; `local_to_map()` before any cell query.  
Source: https://forum.godotengine.org/t/best-architectual-practices-for-using-the-tilemaplayer-node-programmatically/116440

**Watch item still open:** GH-120482 (TileSet sources empty under threaded load). The 4.7.2 fix is unverified — test manually before any room-streaming work.

**Applicability:** LOW (no new action needed now; MED if room streaming is added).

---

### Collision / Hitbox Layering — Area2D vs CharacterBody2D

**What's new — 4.7 (HIGH relevance):** `CollisionShape2D` gains a **one-way collision direction** property. Before 4.7, one-way platforms required either TileSet per-tile physics or a workaround that checked `move_and_slide` collision normals. In 4.7, set the direction flag directly on the `CollisionShape2D` in the TileSet. This is the native solution for pass-through floors (jump-down platforms, semi-solid ceilings).  
Source: https://godotengine.org/article/maintenance-release-godot-4-7-1/ (changelog); https://linuxiac.com/godot-4-7-open-source-game-engine-released-with-linux-wayland-hdr-support/

**Migration note for 4.7 upgrade:** Read the 4.7 migration guide before upgrading — the one-way collision change is listed as a breaking change relative to 4.6. Existing one-way workarounds in `player.gd` may conflict with the new native behavior.

**Area2D monitorable no-op (GH-121094, provisional):** Toggle `collision_layer`/`collision_mask` instead of `monitorable`. Our `Door.gd` does not touch `monitorable` — no exposure. Carries forward from Sep 2026.

**Hitbox layering convention (unchanged):** Hurtbox as `Area2D` child of the entity, hitbox as a separate `Area2D` child. Layer/mask convention: 1=world, 2=player, 3=enemy, 4=hitbox, 5=pickup. `CharacterBody2D` collision stays on layer 1+2 only. No changes to this pattern in 4.7.

**Applicability:** HIGH for 4.7 upgrade (one-way collision direction is a breaking change to read). MED for current 4.6 work (no action).

---

### Animation State Machines — AnimationTree vs Script-Driven

**What's new:** AnimationTree with StateMachine nodes had no API changes in 4.7.x. Script-driven `AnimationPlayer` with enum + `match` (our current approach) has no new limitations.

**4.8 beta watch triggers fired (Oct 15, 2026):**
- **GH-121681** — crash when RESET track references a missing node path (4.8-dev2+). Verify current status manually on GitHub. Our AnimationPlayer rig must have RESET tracks covering every property used by any other animation. This is now urgent before any 4.8 beta trial.  
  Source: https://github.com/godotengine/godot/issues/121681
- **GH-123593** — AnimationPlayer capture track segfaults when the target node has been freed. Call `is_instance_valid(target)` before `play()`. Relevant to enemy death and door open/close animations.  
  Source: https://github.com/godotengine/godot/issues/123593
- **GH-120379** — AnimationPlayer editor freezes on tree edits (4.7 regression). No workaround. Avoid tree-restructuring while AnimationPlayer is open in the editor.  
  Source: https://github.com/godotengine/godot/issues/120379

**GH-120921 (still open):** AnimationPlayer at the scene root writes wrong relative paths. Our player rig is nested (not at root), so no exposure today. At the next rig revision, confirm nesting depth.

**Applicability:** HIGH (three watch triggers just fired on 4.8 beta; GH-123593 and GH-120921 apply in 4.6 too).

---

### Room Transitions

**What's new:** No new API for scene transitions in 4.7. The `SceneTree.change_scene_to_file()` / `change_scene_to_packed()` path is unchanged. Signal-based door overlap → fade → load → fade pattern is still the community standard.

**GH-123846 (tscn save embeds external subresources, Sep 26):** Still open, no fix in 4.7.2 RC1. Our MCP-driven workflow saves `.tscn` files frequently. After any MCP scene edit, `git diff` for unexpected `[sub_resource]` blocks replacing `[ext_resource]` references. This is the highest-risk open issue for our dev loop.  
Source: https://github.com/godotengine/godot/issues/123846

**Applicability:** HIGH (GH-123846 active risk in our MCP workflow).

---

### Save / Load

**What's new:** No Godot core save/load API changes in 4.7.x. `ConfigFile`, `FileAccess`, and `ResourceSaver` APIs are stable.

**SaveKit** (fernforestgames, v0.1, MIT, Godot 4.5+): Group-based save plugin with JSON/binary serializers. Still available; still low priority vs KoBeWi Metroidvania-System for our room/ability persistence needs.  
Source: https://store.godotengine.org/asset/fernforestgames/savekit/

**KoBeWi Metroidvania-System:** No new version confirmed in the Oct 2026 window. Still the recommended fit for our room persistence and ability flags.

**4.8 note:** GH-123189 (binary resource relative path bug) is open. We use text `.tscn`/`.tres` — no exposure. Keep it that way.

**Applicability:** LOW (no action needed; revisit at the save system implementation phase).

---

## Pitfalls We May Already Be Hitting

| Pitfall | Affects 4.6? | Status | Action |
|---|---|---|---|
| GH-123846: MCP scene save embeds subresources | Yes (version scope provisional; 4.6 untested) | Open, Sep 26 | Run `git diff` after every MCP scene save; look for `[sub_resource]` replacing `[ext_resource]` |
| GH-120921: AnimationPlayer at scene root wrong paths | Yes | Open | Verify player rig is NOT at scene root before next animation edit |
| GH-121094: Area2D monitorable re-enable no-op | Yes (4.7+, provisional) | Open | Not currently triggered; keep for door re-entry refactor |
| Hot-reload leaves new typed members `nil` (#119057) | Yes | Fix in PR #123040 (in progress) | Stop+restart scene after adding any new typed member declaration |

---

## 4.7 Migration — Checklist for 2D Platformer Upgrade

Before upgrading from 4.6.2 to 4.7.x:

1. **Read the official 4.7 migration guide** — breaking changes include the one-way collision direction semantics.
2. **Verify GH-121843 is fixed** (Camera2D smoothing gray screen, macOS + Compatibility). If not fixed, replace `position_smoothing_enabled` with a script lerp before upgrading.
3. **Audit one-way platform tiles** — the new `CollisionShape2D` direction flag may conflict with existing workarounds in `player.gd`.
4. **Test on GL Compatibility renderer only** — GH-123481 (Metal/Vulkan deadlock, M4/M5 + macOS 26) is open and 4.8-milestoned; GL Compat avoids it.
5. **Verify GUT 9.7.x** runs correctly on 4.7.x before running any playtests.

---

*Sources: godotengine.org release posts; research/crawl/sourcemap.md (2026-11-01); research/tools/godot-4.6-current-intel.md (2026-10-01). GH issue statuses from previous crawl unless noted as "verified" — confirm manually on github.com/godotengine/godot.*
