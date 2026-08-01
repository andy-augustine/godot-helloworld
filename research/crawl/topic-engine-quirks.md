# Engine Quirks & Regressions — July 2026 Crawl

**Crawled:** 2026-08-01 | **Target window:** July 2026+ (4.7 stable June 18, 4.7.1 July 14, 4.8-dev2 July 21)  
**Baseline:** Godot 4.7.1 stable; 4.8-dev2 in active development  
**Sources:** godotengine/godot issues (GitHub search), linuxcompatible.org, godotengine.org/article (4.7.1 changelog), direct GitHub issue fetches

---

## TL;DR — Top 3

1. **AnimationNodeStateMachineTransition with `switch_mode = sync` floods the debugger** with
   "index p_frame is out of bounds" on 4.7 and 4.7.1; workaround is to avoid sync mode (GH-120480,
   milestone 4.8, unpatched).
2. **GDScript `await` in a parent method breaks child overrides** — any child class that overrides a
   `-> ReturnType` method containing `await` without declaring its own return type triggers a false
   "Compiler bug: Unresolved return" error in 4.7.0/4.7.1 (GH-121584, workaround: add explicit
   return type to override).
3. **Stale `.godot/uid_cache.bin` silently crashes the running game** when the debugger inspects
   resources in 4.7.x; delete the file when hitting mysterious in-editor crashes (GH-120306, open).

---

## Findings

### F1 — AnimationNodeStateMachineTransition sync mode: error flood (4.7 regression)

| | |
|---|---|
| Severity | HIGH |
| Status | OPEN — milestone 4.8; not in 4.7.1 |
| GH | [#120480](https://github.com/godotengine/godot/issues/120480) |
| Introduced | 4.7 (not present in 4.6) |

When an `AnimationNodeStateMachineTransition` node has `switch_mode` set to **Sync** and the
animation drives a Sprite2D frame property, the state machine computes an interpolated frame value
roughly double the valid range. Every physics tick the debugger receives:
`ERROR: index p_frame is out of bounds (N)`. The animation visually plays correctly, but the error
flood makes the debugger unusable during playtesting.

**Workaround:** Change `switch_mode` from Sync to **Immediate** or **At End**. If Sync is
required, drive the blend manually from an AnimationPlayer instead of AnimationTree.

**Relevance:** This project is AnimationPlayer-only; any upgrade to AnimationTree for enemy AIs would hit this immediately.

---

### F2 — GDScript: `await` + inheritance causes false "Compiler bug" error (4.7 regression)

| | |
|---|---|
| Severity | MED |
| Status | OPEN — no milestone set; confirmed in 4.7.0 and 4.7.1 |
| GH | [#121584](https://github.com/godotengine/godot/issues/121584) |
| Introduced | 4.7 (not present in 4.6) |

Pattern that triggers the error:
```gdscript
# Parent
func transition() -> bool:
    await get_tree().process_frame
    return true

# Child — no return-type annotation on the override
func transition():         # <- missing -> bool
    return some_other_call()   # <- no declared return type
```
The compiler reaches a supposedly-unreachable branch and prints
`Compiler bug: Unresolved return`. The script compiles and runs correctly despite the message, but
the error spams Output and confuses GUT/GdUnit4 test runners (doubles trigger the same path).

**Workaround:** Annotate every override with an explicit return type matching the parent. In test
doubles produced by GUT, this means ensuring the doubled class's method signatures include types.

---

### F3 — Android: Control touch fires inside letterbox border (4.7 regression)

| | |
|---|---|
| Severity | HIGH (Android builds only), LOW (desktop) |
| Status | OPEN — marked 4.8 release blocker |
| GH | [#121492](https://github.com/godotengine/godot/issues/121492) |
| Introduced | 4.7 (confirmed absent in 4.6.3) |

Under `stretch/mode = canvas_items`, Control nodes positioned outside the logical viewport receive
touch events that land in the black letterbox area on Android touchscreens. A button at coordinate
(600, 100) in a 960×540 viewport on a 16:10 device fires from the top black strip. This does not
occur on Windows/macOS; desktop mouse clicks correctly ignore the letterbox. 

**Workaround:** Clamp UI Control positions to the viewport rect; switch stretch mode to `viewport`;
or conditionally disable Controls near viewport edges on mobile.

---

### F4 — AnimationNodeOneShot "Abort on Reset" silently broken in 4.7 (FIXED in 4.7.1)

| | |
|---|---|
| Severity | MED (was HIGH before patch) |
| Status | FIXED in 4.7.1 (July 14, 2026) |
| Source | 4.7.1 changelog |

`AnimationNodeOneShot`'s "Abort on Reset" flag did nothing in 4.7.0 — the one-shot clip continued
playing through `RESET` triggers. Fixed in 4.7.1 with no API change.

**Action:** Upgrade to 4.7.1. Test one-shot animations (hit effects, pickups, death) that rely on RESET to cancel them.

---

### F5 — Stale uid_cache.bin crashes game during debugger inspection (4.7 regression)

| | |
|---|---|
| Severity | MED |
| Status | OPEN — no fix in 4.7.1 |
| GH | [#120306](https://github.com/godotengine/godot/issues/120306) |
| Introduced | 4.7 RC2 (not present in 4.6.3) |

After a stale `.godot/uid_cache.bin` accumulates from project restructuring, opening the Remote
Tree or clicking the Video RAM tab in the running-game debugger causes an immediate silent crash
(game closes as if Alt+F4). No error is printed to Output. The crash disappears after deleting
`uid_cache.bin` and restarting the editor.

**Workaround:** Delete `.godot/uid_cache.bin` and restart the editor. Especially likely after renaming scenes or moving resources in bulk.

---

### F6 — "Local to Scene" resource converts to sub-resource under Editable Children (4.6/4.7)

| | |
|---|---|
| Severity | MED |
| Status | OPEN — behavior change from 4.5; no fix targeted |
| GH | [#121428](https://github.com/godotengine/godot/issues/121428) |
| Introduced | 4.6 (persists in 4.7) |

In 4.5.x, a resource marked "Local to Scene" on a GLB-imported mesh with Editable Children stays
as an external file reference — every instance shares it, and edits in the inspector propagate
globally. In 4.6+, Godot converts it to an embedded sub-resource unique to that scene; the
inspector tooltip still shows the original path, misleadingly. Global edits no longer propagate.

**Workaround:** Do not combine "Local to Scene" materials with Editable Children. Use instanced subscenes for per-instance variation.

---

### F7 — "Upgrade Project Files" crashes on AnimationPlayer + RESET animation (4.8-dev2 only)

| | |
|---|---|
| Severity | LOW (4.8-dev2 only; 4.7.1 stable unaffected) |
| Status | OPEN — 4.8-dev2 specific; commit bf898d1 identified via bisect |
| GH | [#121681](https://github.com/godotengine/godot/issues/121681) |
| Introduced | 4.8-dev2 |

Running **Project → Tools → Upgrade Project Files** on any scene containing an `AnimationPlayer`
with a `RESET` track crashes the editor (EXC_BAD_ACCESS on macOS, memory violation on other
platforms) at 27–39% progress. Introduced by commit `bf898d1` in 4.8-dev2; reverting the commit
eliminates the crash.

**Workaround:** Do not run UPF from 4.8-dev2; stay on 4.7.1 for project migration until 4.8 stable.

---

### F8 — Forward+ renderer hangs on close on some GPUs (4.7+ regression)

| | |
|---|---|
| Severity | LOW (GPU-specific) |
| Status | OPEN — milestone 4.8; confirmed NVIDIA RTX 5050 + Vulkan 1.4 |
| GH | [#121503](https://github.com/godotengine/godot/issues/121503) |
| Introduced | 4.7-dev1 (not present in 4.6.3) |

Closing a running Forward+ project causes Godot to hang indefinitely; requires system kill. Tied
to specific NVIDIA GPU + Vulkan 1.4 driver combinations; not universal. This project uses
GL Compatibility, so it is not currently exposed.

**Workaround:** Use Compatibility or Mobile renderer on affected hardware. Not relevant for macOS/Apple Silicon (Metal driver path).

---

## Already Known — No Action Needed

| Issue | Status |
|---|---|
| Animation TrackCache hash collisions (GH-117030) | Fixed in 4.7 (root fix landed) |
| `Input.parse_input_event` dropped button events (GH-119329) | Fixed in 4.7 stable |
| GH-102327 lambda capture leak (GDScript, not engine) | Documented; no engine fix expected |

---

## Watch List

| GH | Title | Why | Next check |
|---|---|---|---|
| #120480 | AnimStateMachine sync error flood | Unpatched; 4.8 milestone — fix expected in 4.8-dev3+ | 4.8-dev3 release |
| #121584 | GDScript await+inheritance false error | No milestone; may slip to 4.8.1 | 4.8 release |
| #121492 | Android touch in letterbox | 4.8 release blocker — should land before 4.8 stable | 4.8-dev3 release |
| #120306 | uid_cache.bin silent crash | Open in 4.7.x; watch for 4.7.2 or 4.8 | Monthly |
| #121681 | UPF crash with RESET animation | 4.8-dev2 specific — should be caught before 4.8 stable | 4.8-dev3 release |
| #121428 | Local to Scene sub-resource conversion | No fix targeted; behavior change since 4.6 | Quarterly |
