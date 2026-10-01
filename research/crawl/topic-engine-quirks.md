# Engine Quirks & Regressions — October 2026 Crawl
**Crawl date:** 2026-10-01  
**Target window:** September 2026 onward (previous crawl: 2026-09-01)  
**Current stable:** Godot 4.7.2 (released August 18, 2026)  
**4.8 status:** dev7 as of October 1, 2026 — feature freeze imminent, beta expected late October

> **Calendar correction vs. sourcemap:** The sourcemap listed 4.8 dev5 as the latest snapshot.
> GitHub issue #124029 (filed Sep 30) references "4.8.dev7", confirming two additional dev
> snapshots shipped in September. Feature freeze is very close; watch the milestones page.

---

## TL;DR — Top 3 Findings (new this crawl)

1. **Modifier key `is_action_pressed()` inverted Heisenbug (4.7.2 — still open)** (HIGH): In projects
   with multiple scenes and scripts, `Input.is_action_pressed()` for Shift/Ctrl/Alt returns an *inverted*
   boolean — `true` when not pressed, `false` when pressed. Directly hits any run/dash mechanic.
   Workaround exists. GH-120528.

2. **`.tscn` save silently converts external subresources to internal (4.8 dev)** (HIGH): Scene saves
   can rewrite resource paths, converting externally-referenced subresources into embedded-internal ones,
   dirtying version control and breaking resource sharing. GH-123846.

3. **Binary resource relative-path resolution broken (4.8 dev)** (HIGH for binary-format workflows):
   Relative paths inside binary `.res` / `.scn` files resolve to wrong locations; affects projects
   using packed binary resources. Does not affect text `.tres` / `.tscn`. GH-123189.

---

## Per-Finding Entries (new since September 2026)

---

### A. Input: `is_action_pressed()` Inverted for Modifier Keys — Heisenbug
**Severity:** HIGH (2D platformer — any dash/run mechanic using Shift)  
**Status:** Open — filed June 21, 2026; last updated September 14, 2026; no fix in 4.7.2

**Description:** In projects with sufficient complexity (multiple scenes, scripts, singletons), modifier
keys (Shift, Ctrl, Alt, Meta) report inverted state from `Input.is_action_pressed()`: starts `true` at
project launch without key held, then inverts on first actual press. `is_action_just_pressed()` works
correctly; only the persistent-state query is corrupted. Bug is timing-dependent — adding `print()`
calls during _ready() can cause it to disappear (classic Heisenbug). Root cause: during initialization
`Input` may register a modifier press event without the corresponding release, leaving state corrupted.

**Repro / Citation:**  
- GH-120528 (June 21, 2026 — open as of Sep 14, 2026): https://github.com/godotengine/godot/issues/120528  
- GH-122728 (Aug 22, 2026, separate user repro in 4.7.2): https://github.com/godotengine/godot/issues/122728

**Workaround:** Track modifier state manually using transition events only:
```gdscript
var _shift_held := false
func _process(_delta):
    if Input.is_action_just_pressed("dash"): _shift_held = true
    elif Input.is_action_just_released("dash"): _shift_held = false
```
Do NOT rely on `is_action_pressed()` for modifier-key-bound actions in complex projects.

**Related issues:** GH-122554 (confirmed Shift stuck on Windows in 4.7.2 — separate race condition).

---

### B. `.tscn` Save Corrupts External Subresource Paths
**Severity:** HIGH (scene file hygiene; save/load correctness)  
**Status:** Open — filed September 26, 2026; needs testing label

**Description:** When a scene property references an external subresource (e.g., a Material or Resource
stored in its own `.tres`), saving the parent `.tscn` may rewrite the path reference and embed the
resource inline as an internal subresource instead. The change is silent, corrupts VCS diffs, and can
break other scenes that reference the same external resource. Affects 4.7.x and 4.8 dev builds.

**Repro / Citation:**  
- GH-123846 (September 26, 2026):  
  "Scene properties that reference external subresources modify their paths and make the internal
  subresources on save."  
  URL: https://github.com/godotengine/godot/issues/123846

**Workaround:** After any save, run `git diff` to check whether `.tscn` files have gained inline
`[sub_resource ...]` blocks that should remain as `[ext_resource ...]` references. If so, manually
revert the embedding and use `ResourceSaver.FLAG_RELATIVE_PATHS` explicitly. Prefer text format
(`.tscn`/`.tres`) over binary (`.scn`/`.res`) until this is resolved.

**Related issues:** GH-123189 (binary resource relative-path resolution broken, below).

---

### C. Binary Resource Relative-Path Resolution Broken
**Severity:** HIGH (only if using binary `.res`/`.scn` format)  
**Status:** Open — filed September 4, 2026

**Description:** Relative path references inside binary-format resources (`ResourceFormatLoaderBinary`)
resolve to incorrect locations. Projects using binary resources (e.g., AtlasTexture, compressed meshes,
or any `.scn` binary scene file) may see missing-resource errors at runtime that do not occur in the
text-format equivalent. Does **not** affect `.tres` / `.tscn` text resources.

**Repro / Citation:**  
- GH-123189 (September 4, 2026):  
  URL: https://github.com/godotengine/godot/issues/123189

**Workaround:** Keep all resources in text format (`.tres`/`.tscn`). Use `ResourceSaver.FLAG_CHANGE_PATH`
to force absolute paths in binary resources as a stop-gap.

---

### D. RichTextLabel / Container Freeze + Crash (4.7 regression)
**Severity:** MED (2D platformer — dialog boxes, cutscene text, HUD item descriptions)  
**Status:** Open — filed August 6, 2026; confirmed; last updated September 22, 2026

**Description:** A regression introduced in 4.7 causes RichTextLabel inside Container nodes to freeze
and subsequently crash the engine under certain layout conditions. Exact trigger involves dynamic resizing
of the parent container while the RichTextLabel is visible. Not present in 4.6.

**Repro / Citation:**  
- GH-122176 (August 6, 2026):  
  URL: https://github.com/godotengine/godot/issues/122176

**Workaround:** Avoid dynamically resizing Containers holding active RichTextLabels. Use a fixed
`min_size`, or replace with plain Label for HUD text that resizes frequently.

---

### E. AnimationPlayer Capture Track Segfault on Freed Target
**Severity:** MED (developer stability — any scene with capture-mode AnimationPlayer tracks)  
**Status:** Open — filed September 18, 2026; confirmed crash

**Description:** If an `AnimationPlayer` uses a capture track (`Animation.TYPE_VALUE` with capture mode)
and the target node has been freed (e.g., after `queue_free()` from an async callback), playing the
animation causes a segfault rather than a safe error. Affects 4.8 dev builds; 4.7.x status unconfirmed.

**Repro / Citation:**  
- GH-123593 (September 18, 2026):  
  URL: https://github.com/godotengine/godot/issues/123593

**Workaround:** Before calling `play()`, verify targets are live (`is_instance_valid(node)`). Stop the
AnimationPlayer in `_notification(NOTIFICATION_PREDELETE)` on the scene root.

---

### F. Input Action Fires Twice When Mouse Is Moving (mouse-button actions)
**Severity:** LOW (2D platformer — keyboard-primary; relevant only if using mouse actions)  
**Status:** Open — filed August 12, 2026; needs testing

**Description:** An `InputAction` bound to a mouse button fires its `pressed` signal twice per click
when the mouse is in motion at the time of the click. Keyboard-bound actions are unaffected. Only
relevant to menus or point-and-click systems.

**Repro / Citation:**  
- GH-122320 (August 12, 2026):  
  URL: https://github.com/godotengine/godot/issues/122320

**Workaround:** Use `_unhandled_input()` with `event is InputEventMouseButton` directly instead of
action mapping for mouse-bound actions until fixed.

---

### G. Tab Focus Escapes SubViewportContainer
**Severity:** LOW (2D platformer — only if pause menu uses SubViewportContainer for in-world UI)  
**Status:** Open — filed September 23, 2026

**Description:** Pressing Tab to cycle keyboard/gamepad focus inside a `SubViewportContainer` causes
focus to jump outside the SubViewport entirely rather than cycling within it. Affects any in-game UI
embedded in a SubViewport (e.g., menus rendered in-world).

**Repro / Citation:**  
- GH-123744 (September 23, 2026):  
  URL: https://github.com/godotengine/godot/issues/123744

**Workaround:** Override `_gui_input()` on the SubViewportContainer to consume Tab and call
`SubViewport.get_child(0).gui_focus_next()` manually.

---

## Previous Findings — Status Updates

| Finding | Previous Status | October 2026 Update |
|---------|----------------|---------------------|
| RigidBody2D sleep freeze (GH-forum) | Open, no fix in 4.7.2 | Still open — no fix reported |
| AnimationPlayer editor freeze (GH-120379) | Open, expected in 4.8 | Still open — not in any 4.8 dev release confirmed |
| RigidBody2D Frozen-Static shape desync (GH-118473) | Open since April 2026 | Still open |
| TextureButton focus regression (GH-115782) | Status unclear | No update found |
| Shift simultaneous-release (GH fix in 4.7.2) | FIXED in 4.7.2 | Still fixed; new distinct Shift Heisenbug (GH-120528) is unrelated |

---

## Watch List — Open Issues Worth Re-scanning

| Issue | Title | Why Watch |
|-------|-------|-----------|
| GH-120528 | `is_action_pressed()` inverted for modifier keys | Directly hits run/dash on Shift; no fix ETA |
| GH-123846 | `.tscn` save converts external to internal subresources | Can silently corrupt project file structure |
| GH-123189 | Relative paths broken in binary resources | Affects any binary resource workflow |
| GH-122176 | RichTextLabel/Container freeze+crash (4.7) | Still open after 7 weeks; no fix in sight |
| GH-123593 | AnimationPlayer capture track segfault | Confirmed crash; fix expected in 4.8 |
| GH-120379 | AnimationPlayer editor freeze on tree edits | 4.7 regression; expected 4.8 fix unconfirmed |
| GH-118473 | RigidBody2D Frozen-Static collision shape desync | Open since April 2026, affects physics props |
| 4.8 feature freeze | Milestone: godotengine/godot | Beta expected late October; watch for breaking API changes |

---

## Notes on Scope

- All findings marked (4.8 dev) occur in pre-release snapshots — do NOT ship against 4.8.
- 4.8 reached **dev7** by October 1, 2026 (two snapshots beyond what the sourcemap recorded).
  Feature freeze is imminent; beta likely by late October 2026.
- The `godot-mcp-pro` synthetic drag / `Input.parse_input_event` patterns remain unaffected
  by all findings in this crawl. No new regressions found in that area.
- GH-122554 (Left Shift stuck on Windows) was closed in 4.7.2; the Heisenbug GH-120528 is a
  **different mechanism** (initialization-time state inversion) and remains open.
