# Engine Quirks & Regressions — August 2026 Crawl
**Crawl date:** 2026-09-01  
**Target window:** August 2026 onward (previous crawl: 2026-08-01)  
**Current stable:** Godot 4.7.2 (released August 18, 2026)  
**Next:** 4.8 dev 4 (August 26, 2026) — not yet stable

---

## TL;DR — Top 3 Findings

1. **RigidBody2D sleep regression in 4.7** (HIGH): Bodies freeze after settling to rest — a clean regression from 4.6. No confirmed fix as of 4.7.2. Workaround: set `can_sleep = false` on dynamic bodies or use `sleeping_threshold` tuning. Directly affects any physics object in your platformer (pickups, debris, props).

2. **Shift key simultaneous-release bug fixed in 4.7.2** (MED): If the player held Shift (run/dash) while another key was released at the same frame, the engine could silently drop the Shift modifier state — causing missed input frames. Fixed in 4.7.2; upgrade immediately if still on 4.7.0/4.7.1.

3. **AnimationPlayer editor freeze with many animations** (MED — dev workflow): Any scene tree hierarchy change (move, rename, delete node) stalls the editor for 10–20 seconds when an AnimationPlayer with a large animation library is present. Regression introduced in 4.7; not present in 4.6. No confirmed fix in 4.7.x maintenance releases; fix expected in 4.8.

---

## Per-Finding Entries

---

### 1. RigidBody2D Sleep Freeze Regression
**Severity:** HIGH (2D platformer)  
**Status:** Open — no confirmed fix in 4.7.2

**Description:** After upgrading from 4.6 to 4.7, RigidBody2D bodies freeze in place after coming to rest, rather than entering the normal sleep state and waking on collision. In affected projects, bodies simply stop reacting to physics after a few moments. Worked correctly in 4.6.stable.

**Repro / Citation:**  
- Forum report (June 2026): "After moving to 4.7, the rigidbodies seem to freeze after standing still for a few moments. In 4.6 this all worked with no issue."  
  URL: https://forum.godotengine.org/t/broken-rigidbody2d-behavior-after-4-7-update/140666

**Workaround:** Set `can_sleep = false` on affected bodies, or increase `sleep_threshold` in Project Settings > Physics > 2D to prevent premature sleep. Test if a `sleeping_threshold` overide per-body resolves the symptom.

**Related issues:** RigidBody2D sleep never-wake long-standing issue GH-7996; separate freeze-in-static-mode issue GH-118473 (see below).

---

### 2. Input: Simultaneous Shift Key Release Mishandled
**Severity:** MED (2D platformer)  
**Status:** FIXED in 4.7.2 (August 18, 2026)

**Description:** When the player released Shift at the same frame as another key, the engine could mis-attribute the release event, dropping the modifier state silently. For a platformer this can manifest as a "run button stuck" or "dash cancelled mid-frame" inconsistency. Affects keyboard-driven input; does not affect joypad.

**Repro / Citation:**  
- 4.7.2 release summary (August 18, 2026): "Resolves an issue handling simultaneous Shift key releases."  
  URL: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/  
  Official: https://godotengine.org/article/maintenance-release-godot-4-7-2/

**Workaround:** Upgrade to 4.7.2. No known per-project workaround on earlier builds.

**Related issues:** Part of the broader input hardening pass in 4.7.2.

---

### 3. AnimationPlayer Editor Freeze (Scene Tree Hierarchy Edits)
**Severity:** MED (developer-workflow; does not affect shipped game)  
**Status:** Open — present through 4.7.stable, unclear if fixed in 4.7.1/4.7.2; likely targeting 4.8

**Description:** Any scene tree modification (move, rename, reparent, delete node) triggers a 10–20 second editor freeze when an `AnimationPlayer` with a large animation library is in the scene. The cause is a 4.7 change that forces the AnimationPlayer to enumerate all animations on every tree change. Removing the AnimationPlayer makes the same edits instantaneous.

**Repro / Citation:**  
- GitHub issue #120379 (filed June 17, 2026): Reproducible in 4.7.beta2, 4.7.rc2, 4.7.rc3; not in 4.6.stable. Minimal repro: instantiate a complex scene 74 times (with AnimationPlayers) — rename a node → 7+ second freeze.  
  URL: https://github.com/godotengine/godot/issues/120379

**Workaround:** For large-animation-library characters, keep the AnimationPlayer scene separate and only instantiate it when needed; do hierarchy edits on scenes that exclude the AnimationPlayer. Alternatively, temporarily delete or disable the AnimationPlayer node while doing large scene tree reorganizations, then re-add.

**Related issues:** GH-104483 (progressive freeze when adding animation keys — separate but related editor performance regression).

---

### 4. RigidBody2D Separates from CollisionShape2D When Frozen (Static Mode)
**Severity:** MED (2D platformer — affects any dynamically-frozen physics props)  
**Status:** Open — filed April 2026, no confirmed fix as of 4.7.2

**Description:** When a `RigidBody2D` is programmatically frozen to `Freeze Mode: Static` at runtime and then repositioned, the `CollisionShape2D` child desyncs — the shape stays at the old position while the visual (sprite) moves. The orphaned collision shape is invisible in the editor even with "Visible Collision Shapes" enabled, but still blocks other bodies.

**Repro / Citation:**  
- GitHub issue #118473 (April 12, 2026): Affects Godot 4.6 and up; Godot Physics engine (Jolt unconfirmed).  
  URL: https://github.com/godotengine/godot/issues/118473

**Workaround:** Avoid changing `freeze` state and position in the same frame. Use a `StaticBody2D` from the start for objects that need to be fixed in place, rather than freezing a RigidBody2D. If dynamic freeze is unavoidable, force a full physics step (`await get_tree().physics_frame`) before repositioning.

**Related issues:** GH-34124, GH-30551 (older shape-sync issues, different root cause).

---

### 5. Input: High-Polling-Rate Mouse Lag on Windows
**Severity:** LOW (2D platformer — keyboard-driven; editor UX affected)  
**Status:** FIXED in 4.7.2 (August 18, 2026)

**Description:** On Windows, mice with ≥1000 Hz polling rates (e.g. gaming peripherals at 4000 Hz) caused input queue starvation, introducing visible stutter in both the editor and in games. Did not affect gamepad or keyboard input.

**Repro / Citation:**  
- 4.7.2 RC1 release notes: "Thread hardening and high-polling-rate mouse support."  
  URL: https://www.warp2search.net/story/godot-472-release-threading-hardening-mouse-input-fixes-and-57-stability-patches (August 2026)  
  Also: https://www.linuxcompatible.org/story/godot-engine-472-rc1-released-43-fixes-thread-hardening-and-high-polling-rate-mouse-improvements

**Workaround:** Upgrade to 4.7.2. On older builds: reduce mouse polling rate in device software (e.g. to 500 Hz).

---

### 6. GUI: TextureButton Focus Regression (4.6+)
**Severity:** LOW (2D platformer UI — HUD/menu)  
**Status:** Open as of last known state — filed against 4.6, closed as duplicate of GH-115782; root fix status unclear

**Description:** `TextureButton` nodes lose focus and revert to their Normal texture immediately when the player clicks anywhere, even if the button was focused. The Focused texture never shows during gameplay click sequences. Regression from Godot 4.5.

**Repro / Citation:**  
- GitHub issue #117486 (March 2026): "Texture button that is in currently focus will revert to 'Normal' and display the normal texture instead." Closed as duplicate of #115782.  
  URL: https://github.com/godotengine/godot/issues/117486

**Workaround:** Use a standard `Button` with a StyleBoxTexture theme override for focus states rather than `TextureButton` if you need reliable keyboard/gamepad-driven UI focus.

**Related issues:** GH-115782 (parent issue), GH-68067 (disabled-state variant).

---

### 7. Threading: Multiple Main Thread Race Condition Risk
**Severity:** MED (stability — any threaded scene loading or async ResourceLoader usage)  
**Status:** HARDENED in 4.7.2 — strict single-main-thread invariant now enforced

**Description:** Prior to 4.7.2, it was possible for game code to accidentally spin up a second main thread in certain GDExtension or background-loading scenarios, producing intermittent crashes that were hard to reproduce. 4.7.2 now hard-asserts a single main thread, converting silent corruption into a predictable error. Existing projects using `Thread.new()` correctly are unaffected; projects using `ResourceLoader.load_threaded_request` or background scene loading should test against 4.7.2 to surface any latent threading mistakes.

**Repro / Citation:**  
- 4.7.2 release summary: "enforces a strict single main thread invariant, so you simply cannot have more than one main thread."  
  URL: https://www.warp2search.net/story/godot-472-release-threading-hardening-mouse-input-fixes-and-57-stability-patches (August 2026)

**Workaround:** N/A — the fix is the workaround. Projects hitting the new assert had a latent bug; fix the threading pattern.

---

### 8. Linux/KDE Wayland: IME Popup Position Under Fractional Scaling
**Severity:** LOW (2D platformer — Linux dev environment only)  
**Status:** FIXED in 4.7.2 (August 18, 2026)

**Description:** On Linux with KDE Plasma and Wayland, fractional display scaling caused the IME (Input Method Editor) popup for text entry fields to appear in the wrong position. Affects editor text entry and any in-game text input fields on Linux/KDE.

**Repro / Citation:**  
- 4.7.2 release summary: "resolves an input method editor (IME) popup positioning bug under KDE Plasma when using fractional display scaling."  
  URL: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/ (August 2026)

**Workaround:** Upgrade to 4.7.2. On older builds: disable fractional scaling or switch to X11.

---

### 9. BaseButton Long-Press-as-Right-Click Misbehavior
**Severity:** LOW (2D platformer — only if using `enable_long_press_as_right_click`)  
**Status:** FIXED in 4.7.2 (August 18, 2026)

**Description:** When `BaseButton.enable_long_press_as_right_click = true`, input events were dispatched incorrectly, causing spurious `button_up` signals or consuming the event before the long press threshold was reached.

**Repro / Citation:**  
- 4.7.2 release notes: "fixes BaseButton input when enable_long_press_as_right_click is true."  
  URL: https://www.opensourceforu.com/2026/08/godot-4-7-2-released/

**Workaround:** Upgrade to 4.7.2.

---

## Watch List — Open Issues Worth Re-scanning

| Issue | Title | Why Watch |
|-------|-------|-----------|
| GH-120379 | AnimationPlayer editor freeze on scene tree edits | 4.7 regression, no fix in 4.7.2; expected in 4.8 |
| GH-118473 | RigidBody2D separates from CollisionShape2D (Frozen Static) | Open since April 2026; no confirmed fix |
| Forum thread (no GH#) | RigidBody2D freeze/sleep after 4.7 update | Related to sleep system rewrite; no fix confirmed |
| GH-115782 | TextureButton focus root issue (parent of #117486) | Status unclear; check against 4.7.2 |
| GH-88067 | CharacterBody2D `is_on_floor()` erratic inside tilemaps | Long-standing; resurfaces across minor versions — verify in 4.7.2 |

---

## Notes on Scope

- All 4.7.2 fixes listed as "FIXED" above require upgrading to 4.7.2-stable (released August 18, 2026). Running 4.7.0 or 4.7.1 leaves the Shift key, high-polling mouse, IME, and BaseButton regressions active.
- 4.8 dev 4 (August 26, 2026) contains 224 fixes but is not yet stable. Do not ship against it.
- The sprite neighboring-frame flickering issue (GH-117978, first reported in 4.6.1) was **closed as not planned** due to inability to reproduce — watch for reports in 4.7.x context.
- The `godot-mcp-pro` drag-event and synthetic input patterns documented in `tests/README.md` Pattern 4 are **unaffected** by any of the above; no new regressions found in that area for 4.7.x.
