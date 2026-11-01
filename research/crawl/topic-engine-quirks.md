# Engine Quirks & Regressions — Godot 4.6→4.7/4.8
**Crawl date:** 2026-11-01  
**Window:** October 2026 forward (covers 4.7.x regressions relevant to upgrade planning; 4.8 beta findings)  
**Project version:** 4.6.2 — upgrade target is 4.7.2+ or 4.8 stable (Q4 2026)

> **Network note:** godotengine.org and forum.godotengine.org were unreachable from this session's network.
> Claims sourced from godotengine.org come from cached search snippets, gamedev.net mirrors, and
> community re-posts. Verify directly when network access is restored.

---

## TL;DR — Top 3

1. **Don't land on 4.7.0 or 4.7.1.** High-polling-rate mice (≥ ~1 kHz) collapse frame rate to
   under 1 FPS on Windows. Fixed in 4.7.2 stable. This is a catastrophic regression for
   playtesting on any modern gaming peripheral. Skip straight to 4.7.2+ when upgrading.

2. **Keyboard/mouse device IDs broke in 4.7.** `event.device == 0` no longer identifies
   keyboard or mouse; they moved to `InputEvent.DEVICE_ID_KEYBOARD` /
   `InputEvent.DEVICE_ID_MOUSE` (GH-116274). Code with hardcoded `device == 0` silently
   misbehaves — gamepads that also report ID 0 now share that slot.

3. **Mouse motion overrides joypad input in menus (4.7+, still open).** Moving the mouse in
   a menu while a controller is connected can suppress gamepad `InputEventJoypadButton` delivery
   to `_input`. Confirmed and tagged; only workaround so far is to revert GH-109639 (the same
   PR that fixed the polling-rate crash — you can't have both fixes at once without a custom
   build).

---

## Findings

### 1. High-polling-rate mouse causes near-zero FPS on Windows  
**Severity:** HIGH  
**Versions affected:** 4.7.0, 4.7.1  
**Fixed in:** 4.7.2 stable, 4.8 dev 3+  

**Description:** Windows sends both `WM_MOUSEMOVE` (legacy) and `WM_INPUT` (raw) events
simultaneously for captured/visible mouse modes. At ≥ 1 kHz polling rates, this overwhelmed
`DisplayServerWindows::process_events()`. On an 8 kHz / 480 Hz test rig, frame rate dropped
below 1 FPS in 4.7.1. The fix (GH-109639) buffers raw input, limits legacy motion to once per
frame, and leaves buttons/keys/gamepads untouched.

**Benchmark (single rig, treat as indicative):** 8 kHz mouse, 480 Hz monitor — 4.7.1: <1 FPS;
4.8 dev 3: ~477 FPS; 1% lows improved 45.8×.

**Repro/citation:**  
- <https://godotengine.org/article/release-candidate-godot-4-7-2-rc-1/> (August 3, 2026)  
- <https://godotengine.org/article/fixing-high-polling-rate-mice-on-windows/> (2026)  
- <https://gamedev.net/news/4973-dev-snapshot-godot-48-dev-3/> (2026)  

**Workaround:** Upgrade to 4.7.2+. No in-project workaround exists.  
**Related issues:** GH-109639

---

### 2. Keyboard/mouse input device IDs changed — `device == 0` breaks  
**Severity:** HIGH  
**Versions affected:** 4.7.0+ (breaking change)  
**Fixed in:** N/A — intentional change; project code must migrate  

**Description:** In Godot 4.6 and earlier, keyboard and mouse `InputEvent` objects reported
`device == 0`. Godot 4.7 moved them to `InputEvent.DEVICE_ID_KEYBOARD` and
`InputEvent.DEVICE_ID_MOUSE` (GH-116274). Rationale: some joypads also enumerate as device 0,
causing false matches. Any code pattern like `if event.device == 0: # it's keyboard/mouse`
silently misroutes input after upgrade.

**Repro/citation:**  
- <https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html> (2026)  
- <https://godotengine.org/article/dev-snapshot-godot-4-7-dev-2/> (2026)  

**Workaround:** Replace `event.device == 0` with `event is InputEventKey` /
`event is InputEventMouse` checks, or compare against the new constants.  
**Related issues:** GH-116274

---

### 3. Mouse motion overrides joypad input in menus (open regression, 4.7+)  
**Severity:** HIGH  
**Versions affected:** 4.7+ (not in 4.5, 4.6)  
**Fixed in:** Open as of October 2026  

**Description:** On Windows (and possibly other platforms), moving the mouse while a controller
is connected causes `InputEventJoypadButton` events to be suppressed or consumed before reaching
`_input()` on menu `Control` nodes. Projects that support both mouse and gamepad navigation in
menus are directly affected. The regression is bisected to GH-109639 (the same high-polling-rate
fix); reverting it restores gamepad menu navigation but re-introduces the FPS crash. The issue
was confirmed and tagged as a regression on the Godot tracker.

**Repro/citation:**  
- <https://github.com/godotengine/godot/issues/124614> (Godot issue tracker, 2026)  
- <https://www.linuxcompatible.org/story/godot-engine-471-release-candidate-addresses-47-regressions-in-rendering-and-input/> (2026)  

**Workaround:** None confirmed. Potential mitigation: poll `Input.is_joy_button_pressed()` in
`_physics_process` rather than relying on `_input()` events for joypad menu navigation.  
**Related issues:** GH-124614, GH-109639

---

### 4. Joypad input ignored on unfocused windows — new default in 4.8 (breaking)  
**Severity:** MED  
**Versions affected:** 4.8 new projects (existing project setting defaults unchanged on upgrade)  
**Fixed in:** N/A — intentional change  

**Description:** Godot 4.8 (GH-120399) introduces a project setting that ignores joypad events
when the app window is not focused. It is on by default for **new** projects created in 4.8.
Projects upgrading from 4.7.x should be unaffected unless they explicitly reset settings during
conversion. However, any project creating a fresh `project.godot` in 4.8 and expecting joypad
input while the window loses focus will be surprised.

**Repro/citation:**  
- 4.8 beta 1 release notes snippet (godotengine.org, October 15, 2026)  
- <https://gamedev.net/news/6488-dev-snapshot-godot-48-beta-1/> (October 2026)  

**Workaround:** In 4.8, set `Input/Devices/Joypad/ignore_input_on_unfocus` to `false` in
Project Settings.  
**Related issues:** GH-120399

---

### 5. Forward+ rendering ~60%+ FPS drop in 4.7 vs 4.6.3  
**Severity:** HIGH  
**Versions affected:** 4.7 betas (bisected to beta 4); final stable status unconfirmed  
**Fixed in:** Status unclear — may have been addressed in 4.7 stable or 4.7.1  

**Description:** GH-119963 reports a major frame-rate regression in Forward+ rendering mode when
comparing 4.7 beta 4 to 4.6.3 on the same scene. The commit causing the regression was
identified via bisect. The 4.7.1 release notes highlight rendering fixes (flickering lighting on
scaled mesh instances, "previous transforms remembered for two frames after movement stops") but
it is unclear whether these are the same root cause.

**Repro/citation:**  
- <https://github.com/godotengine/godot/issues/119963> (2026)  
- <https://godotengine.org/article/maintenance-release-godot-4-7-1/> (July 14, 2026)  

**Workaround:** Test a representative scene in 4.7.2 before upgrading. If regression persists,
switch renderer to Compatibility or Mobile mode as a temporary measure.  
**Related issues:** GH-119963; also 4.7.1 rendering fixes in the release notes

---

### 6. AnimationPlayer `current_animation_length` stale after named-library edit (GH-124548)
**Severity:** MED | **Versions affected:** 4.7.2 | **Fixed in:** Open, filed October 18, 2026  

Changing an animation's length inside a named `AnimationLibrary` does not update
`current_animation_length`. Workaround: bounce `current_animation` to `""` then back to force
a refresh. Citation: <https://github.com/godotengine/godot/issues/124548> (October 18, 2026)

---

### 7. Script editor captures game input in non-Windowed+Embedded mode (4.8 dev, GH-124079)
**Severity:** MED | **Versions affected:** 4.8 dev 7+; NOT in 4.7.2 stable  
**Fixed in:** Targeted 4.8 stable (in 4.8 milestone)  

Editor keyboard input bleeds into the running game when using anything other than
Windowed+Embedded mode. Workaround: use Windowed+Embedded during 4.8 dev/beta playtesting.
Citation: <https://github.com/godotengine/godot/issues/124079> (2026)

---

### 8. PhysicsServer2DExtension one-way collision `direction` parameter (4.7 breaking change)
**Severity:** MED (only custom `PhysicsServer2DExtension` subclasses affected)  
GH-104736: the `PhysicsServer2DExtension` override for `body_set_shape_as_one_way_collision`
now requires a `direction: Vector2` parameter. Add `direction: Vector2 = Vector2.ZERO` to any
override. Citation: <https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html> (2026)

---

### 9. Visual shader breakage — 4.8 dev 4 through beta 1 (GH-124966)
**Severity:** MED (VisualShader users only; not in 4.7)  
Removal of parameter-name validation in `VisualShader::add_node()` broke existing VisualShader
graphs in 4.8 dev 4–beta 1. Possibly fixed in beta 2 (October 29, 2026) — unconfirmed. Stay on
4.7.x if using VisualShader until 4.8 stable. Citation:
<https://github.com/godotengine/godot/issues/124966> (2026)

---

## Watch List — Open Issues Worth Re-scanning

| Issue | Description | Versions | Priority |
|---|---|---|---|
| GH-124614 | Mouse motion overrides joypad input in menus | 4.7+ | HIGH — no fix yet; blocks dual input menus |
| GH-124548 | `current_animation_length` stale after named-library edit | 4.7.2 | MED — open Oct 18, 2026 |
| GH-124079 | Script editor steals input from game (non-embedded mode) | 4.8 dev | MED — in 4.8 milestone |
| GH-124966 | VisualShader breakage from dev 4 | 4.8 beta | MED — check if 4.8 beta 2 resolves |
| GH-119963 | Forward+ FPS drop 60%+ vs 4.6.3 | 4.7 betas | HIGH — verify status in 4.7.2 stable |
| GH-122708 | CapsuleShape2D stuck between colliders | 4.6–4.7.x | MED — reproduced 4.7.2 macOS |
| GH-120399 | Joypad ignored on unfocused window (new 4.8 default) | 4.8 new projects | LOW for now; check after 4.8 stable |

**Re-scan cadence:** Check GH-124614 and GH-119963 first — both are high impact and have no
confirmed fix as of the crawl date. Re-scan after 4.8 stable ships (expected late Q4 2026).

---

*Sources cited above. Godot blog posts sourced via search-result snippets; verify at
<https://godotengine.org/blog/> when network access is available.*
