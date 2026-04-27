# Godot 4.6 synthetic drag test — current intel (narrow re-test crawl)

| | |
|---|---|
| Scope | Targeted check of Godot 4.6 synthetic drag-test viability before re-testing the skill-card UI |
| Researched | 2026-04-26 |
| Pairs with | [`godot-drag-drop-api.md`](godot-drag-drop-api.md) — section-by-section confirms/updates below |
| Followup | Broader 4.6 community crawl is queued separately — only narrow points covered here |

## 1. TL;DR

- **No evidence of a Godot 4.6 regression that breaks `Input.parse_input_event` → `_gui_input`.** Searches of the Godot tracker, godotforums.org, the 4.6 / 4.6.1 / 4.6.2 release notes, and r/godot turn up no issue matching the symptom we recorded. The one forum thread that *sounded* like a match ("Mouse input events broken after going from 4.5.1 → 4.6", Jan 2026) was self-resolved by the OP — invisible Control above the scene was eating the press. Strong signal our prior session was polluted, not a regression. ([forum thread, 2026-01-27](https://forum.godotengine.org/t/mouse-input-events-broken-after-going-from-4-5-1-4-6/131730))
- **The canonical recipe (`Input.parse_input_event` + button_mask on every motion + `use_accumulated_input=false`) is still what people use in 2025-2026.** GUT 9.4.0 (June 2025) shipped the `mouse_relative_motion` button_mask fix from issue #608 / #612. GUT 9.6.0 (Feb 2026) added explicit Godot 4.6 compat changes. The `InputFactory.mouse_motion(pos)` + manual `event.button_mask = MOUSE_BUTTON_MASK_LEFT` workaround from #608's TGRCdev comment is still cited as the reliable form. ([Gut #608](https://github.com/bitwes/Gut/issues/608), [Gut 9.6.0 release](https://github.com/bitwes/Gut/releases/tag/v9.6.0) 2026-02-24)
- **Most surprising finding:** Sauermann (Godot maintainer, GUI domain) explicitly states `Input.parse_input_event` requires a working DisplayServer to dispatch events to a Window, and that **`Viewport.push_input(event)` bypasses that path** and works for in-viewport testing. This is the opposite of what a comment in our `godot-mcp-pro-internals.md` claimed (it said `push_input(event, true)` "bypasses GUI"). The truth: `push_input` *is* the path to GUI; the optional `in_local_coords` arg only changes coordinate-space transformation. ([godot#73557 Sauermann reply, 2023, still authoritative](https://github.com/godotengine/godot/issues/73557))

## 2. Question-by-question findings

### Q1. Is `Input.parse_input_event` known to skip `_gui_input` in Godot 4.6 (or any 4.x)?

**Answer: No known issue.** No matching tracker entry, no 4.6.0/.1/.2 changelog item, no widely-cited forum thread. The closest signals are:

- `Input.parse_input_event` requires a real DisplayServer — fails silently under `--headless`. Not our case (we run from the editor with a window), but worth knowing for CI. ([godot#73557, Sauermann, 2023](https://github.com/godotengine/godot/issues/73557))
- `Input.parse_input_event(InputEventMouseButton)` re-emitted from inside an `_input()` callback when `use_accumulated_input=false` is dropped silently. Workaround: defer the re-send to `_process()`. **Our flow does not re-emit from `_input()`** — we synthesize from `execute_game_script` — so this gotcha doesn't directly apply, but it's adjacent and worth keeping in the gotcha list. ([godotforums thread, 2025-07-15](https://forum.godotengine.org/t/parse-input-event-of-inputeventmousebutton-gets-ignored-when-use-accumulated-input-is-false/116294))
- The "broken in 4.6" forum thread (Jan 2026) was a user-side invisible-Control problem, not an engine regression. ([forum thread](https://forum.godotengine.org/t/mouse-input-events-broken-after-going-from-4-5-1-4-6/131730))

**Conclusion: our prior failure was almost certainly caused by (a) real OS mouse events fighting synthetic events, (b) an invisible Control eating the press, or (c) GDScript parse errors in our probe scripts that we didn't notice. Re-test under hands-off conditions before declaring a regression.**

### Q2. Current (2025-2026) recipe for testing Control drag from automated tests?

**Answer: Same recipe as before. No improvements landed; the GUT InputSender now sets `button_mask` automatically so the manual `InputFactory` workaround is no longer required if you use GUT.**

The TGRCdev comment in [Gut issue #608](https://github.com/bitwes/Gut/issues/608) — published May 2024, still the most-cited working example — used `InputFactory.mouse_motion(pos)` then `event.button_mask = MOUSE_BUTTON_MASK_LEFT`, sandwiched between `sender.mouse_left_button_down()` and `sender.mouse_left_button_up()`, with `Input.use_accumulated_input = false`. That's identical to our Recipe A.

The GUT-internal fix (PRs #612 / #613, "Send down mouse buttons to mouse motion events") was implemented in `main` in mid-2024 and shipped in **GUT 9.4.0 on 2025-06-11**. GUT 9.6.0 (2026-02-24) added explicit "Compatibility changes for Godot 4.6". After 9.4.0, plain `InputSender.mouse_relative_motion()` should set `button_mask` automatically. ([Gut 9.4.0 release notes](https://github.com/bitwes/Gut/releases/tag/v9.4.0), [Gut 9.6.0 release notes](https://github.com/bitwes/Gut/releases/tag/v9.6.0))

GodotTestDriver (chickensoft-games) is C# only and uses the same `parse_input_event` pattern internally. No GDScript-equivalent project surfaced in this crawl.

No 2026-Q1 sources found that contradict the Recipe A pattern.

### Q3. `Viewport.push_input` signature in Godot 4.6 — `(event)` or `(event, in_local_coords)`?

**Answer: `void push_input(event: InputEvent, in_local_coords: bool = false)`.** Same signature for `push_unhandled_input`. The second arg defaults to `false`, in which case the event's `position` is transformed by the viewport's final transform (canvas + container scaling) on the way in. With `true`, the event position is taken as-is, in the viewport's local coordinate space — Godot skips the transform.

The `godot-mcp-pro-internals.md` claim that `push_input(event, true)` "bypasses GUI" is **wrong**. `push_input` *is* the GUI delivery path for the viewport — that's its whole purpose. `in_local_coords=true` only means "I already pre-transformed this event's coordinates, don't re-transform them." It does not skip Control-node hit testing. (Sources: [Godot 4.6 Viewport docs](https://docs.godotengine.org/en/4.6/classes/class_viewport.html); [godot#72657 Sauermann clarification, 2023](https://github.com/godotengine/godot/issues/72657))

The 2023 issue #72657 (about the in_local_coords arg "doing nothing") was archived/closed: confirmed working as designed; user was missing a separate 3D-to-2D coordinate conversion step before pushing into a SubViewport. Not our case.

### Q4. `Control.force_drag` + synthetic release — should it complete a drag?

**Answer: No, not directly. `force_drag` puts the engine into "drag in progress" state but the GUI dispatcher's release-vs-drop logic is event-driven; it watches for an `InputEventMouseButton` release event delivered through the normal pipeline. A bare `Input.parse_input_event` with a release should still complete it, but only if the press-side preconditions match what the dispatcher is now expecting. Several forum threads agree the simplest reliable pattern is to call `target._can_drop_data(pos, data)` then `target._drop_data(pos, data)` directly when you want unit-test-level coverage of the drop logic.**

- The Oct 2025 forum thread "[HELP] how to manually trigger `_can_drop_data` on a control node?" gets the explicit answer: just call it directly, you have to "implement it too". The thread does not propose any "complete force_drag" API. ([forum thread, 2025-10-07](https://forum.godotengine.org/t/help-how-to-manually-trigger-can-drop-data-on-a-control-node/124470))
- The dev.to article and Godot Control class reference document `force_drag` as initiation only. There is no `complete_drag` / `end_drag` API. ([Drag and Drop in Godot 4.x — pdeveloper, dev.to](https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13))
- Note also: when using `force_drag` from within a `_drop_data` handler, you must `call_deferred` because the current drag is still finishing — confirms drag-end is post-frame state-machine work, not synchronous. ([forum / dev.to references above](https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13))

**This means our prior observation ("force_drag engages, synthetic release leaves `gui_is_drag_successful=false`") is consistent with how the dispatcher works and is NOT a regression.** The path forward for force_drag-based tests: either feed the entire press → motion → release synthetic sequence (no force_drag), or skip force_drag entirely and unit-test the slot via direct method calls.

### Q5. GUT InputSender current state (post-#608 / #612 / #613)

**Answer: Fixed. Released in GUT 9.4.0 (2025-06-11). GUT 9.6.0 (2026-02-24) adds explicit Godot 4.6 compat.**

- Issue #612 ("Send down mouse buttons to mouse motion events") closed with comment "Implemented in `main`." in mid-2024. ([Gut #612](https://github.com/bitwes/Gut/issues/612))
- The 9.4.0 release notes reference PR #712 "add hold_frams [sic] and hold_seconds to input sender" — additional drag-friendly conveniences. The button_mask fix itself was rolled in via the issue #612 line, not separately called out in the changelog. ([Gut 9.4.0 release notes](https://github.com/bitwes/Gut/releases/tag/v9.4.0))
- 9.6.0 highlights "Compatibility changes for Godot 4.6" and PR #808 "Godot 4 6". No subsequent regressions specifically about drag testing surfaced in this crawl. ([Gut 9.6.0 release notes](https://github.com/bitwes/Gut/releases/tag/v9.6.0))

We are not using GUT for our MCP-driven flow, but the takeaway is reassuring: the upstream framework people use for drag testing in 2026 still works. If the recipe is broken, it's broken for them too — and there's no chatter saying it is.

### Q6. Anything unexpected — Godot 4.6 input/GUI weirdness affecting our flow

Two genuine 4.6 things to watch:

- **PR #110250 (merged 4.6) "Hide Control focus when given via mouse input"**, by YeldhamDev. Behaviour change: Control focus visuals don't appear from mouse clicks anymore — adds optional `hide_focus` arg to `Control.grab_focus()` and `ignored_hidden_focus` to `Control.has_focus()`. Marked `breaks compat`. **Doesn't affect drag dispatch directly, but if any of our tests assert on focus state after a synthetic click, those assertions may now read differently.** ([godot#110250](https://github.com/godotengine/godot/pull/110250))
- **Issue #117486 — TextureButton focus regression 4.5 → 4.6.** Specific to TextureButton, not generic Controls; not blocking us, but bookmark in case we wire one. ([godot#117486](https://github.com/godotengine/godot/issues/117486))

Nothing surfaced about `_cmd_execute_script` / `execute_game_script` interacting weirdly with the GUI dispatcher — that's a godot-mcp-pro layer concern, not a Godot one.

## 3. Recommended re-test changes

**Re-test plan (hands-off, no real mouse touching the window):**

1. **Verify clean baseline first.** Before any synthetic input: open the project, `get_editor_errors`, confirm zero parse errors. Confirm no invisible Control over the card area — use `find_ui_elements` or walk the scene tree at the press position. The "broken in 4.6" forum thread is a textbook reminder that this is the most likely cause of "events go nowhere".
2. **Run Recipe A literally as written** in `godot-drag-drop-api.md` section 3, all in one `execute_game_script` call. Don't touch the mouse during the run. Log `gui_is_dragging` after step 2 and `gui_is_drag_successful` after release.
3. **If Recipe A still shows zero `_gui_input` fires** — diagnose, don't conclude regression:
   - Print `Input.use_accumulated_input` value at start (confirm it actually got set to `false`).
   - Print the event chain via a temp `_input` hook on the source's parent — does `InputEventMouseButton.pressed=true` arrive? At what position?
   - Walk Controls under `FROM_POS` with their `mouse_filter` values. Anything `STOP` above the card = press absorbed.
   - Try `get_viewport().push_input(press)` instead of `Input.parse_input_event(press)` — both should land in `_gui_input`, but `push_input` is one layer closer to GUI dispatch and skips DisplayServer routing. If `push_input` works and `parse_input_event` doesn't, the issue is DisplayServer routing in this MCP context.
4. **Skip these dead-end tests** (don't waste a re-test cycle on them):
   - **`Control.force_drag(...)` followed by synthetic release** — confirmed not a designed-to-work flow. Either run the full synthetic sequence, or unit-test the slot via direct `_can_drop_data` / `_drop_data` calls. Don't expect force_drag + release to drive the dispatcher to drop.
   - **`Input.warp_mouse(...)` for movement** — already documented as not generating motion events. Don't try.
   - **`Input.action_press(...)` for mouse buttons** — already documented as not firing `_input`. Don't try.
5. **Add this test we hadn't tried**: a control-only smoke test that doesn't involve drag at all — `Input.parse_input_event(InputEventMouseButton press)` then `await process_frame` then check `card._gui_input` was called with anything. If even a plain click doesn't reach `_gui_input`, the diagnosis isn't drag-specific; it's something about our injection point. That's a useful narrowing step before re-running the full drag recipe.
6. **Use GUT-style `InputFactory.mouse_motion(pos)` for the motion events** — not strictly necessary (we can build `InputEventMouseMotion` directly), but it's the form used in the most-cited working test in the wild. If we're going to deviate from the canonical recipe, deviating *toward* the most-tested form costs us nothing.

## 4. Open questions for the broader overnight crawl

- Does the godot-mcp-pro server's `_cmd_execute_script` wrapper run the user's script in a context that has the same DisplayServer access as a normal frame callback? (i.e., does the `Input.parse_input_event` path see a real DisplayServer, or a degraded one?) Worth a careful read of the plugin's runtime-side dispatcher.
- Are there 2026-Q1 reports of `_gui_input` being skipped specifically when the source Control has a parent with `mouse_filter = MOUSE_FILTER_PASS` and an ancestor with `MOUSE_FILTER_STOP`? Subtle propagation rules, hard to search for, easy to mis-debug.
- Is there a GdUnit4 (the other major Godot test framework) drag-testing pattern that diverges from GUT's? Quick check; might surface a different idiom.
- Any 4.6.x-specific changes to the drag-threshold (the ~8 px the engine waits before commiting)? Didn't surface in this crawl.

## 5. What's UNCHANGED vs. our prior `godot-drag-drop-api.md` note

**Still solid:**

- All of section 1 (drag-drop lifecycle, source/target callbacks, observer hooks).
- All of section 2 (input injection primitives, including `warp_mouse` not firing motion, `action_press` not firing `_input`, `use_accumulated_input` merging behaviour).
- The `button_mask` field requirements table — fully confirmed by both #608 and Sauermann's commentary.
- All of section 3 (Recipe A, Recipe B). The recipes are the right shape. **Our prior session's failure to observe them working is not evidence the recipes are wrong.**
- Section 5 (detection / observation APIs).
- Section 6 gotchas 1-12, all still accurate.

**Update / soften:**

- Section "⚠️ Update 2026-04-26 — provisional finding". Should be downgraded further: not just "needs re-test" but "**actively likely user error**, given the mouse-was-in-the-window confounder and the absence of any matching tracker issue." Recipe A is still the right path; tighten the test conditions and try again.
- Section 4 GUT note: "PRs #612 / #613 are listed as 'in next release' — verify against the current GUT version". Now resolvable: shipped in GUT 9.4.0 (2025-06-11). 9.6.0 (2026-02-24) added 4.6 compat.
- Section 6 gotcha 8 (force_drag + 4.3 preview bug): still relevant. Add: also do **not** rely on a synthetic release to complete a `force_drag`-initiated drag. That's a design boundary, not a bug, and we can stop bisecting it.

**Add (new):**

- DisplayServer requirement for `Input.parse_input_event`. If we ever want headless CI for these tests, it has to use `DisplayServerMock`, not `DisplayServerHeadless`. Source: Sauermann in [godot#73557](https://github.com/godotengine/godot/issues/73557).
- `Viewport.push_input(event, in_local_coords=false)` — second arg is a coordinate-system hint, not a "skip GUI" toggle. Correct the claim in `godot-mcp-pro-internals.md`.
- 4.6 PR #110250 changes Control focus-on-click visuals — keep in mind for any test that asserts focus state.

## Sources (chronological where it matters)

- [Gut issue #608 — drag simulation thread, TGRCdev's working recipe](https://github.com/bitwes/Gut/issues/608) — opened 2024-05-18, last working-recipe comment 2024 mid-year
- [Gut issue #612 — InputSender button_mask on motion events](https://github.com/bitwes/Gut/issues/612) — fix landed in main mid-2024
- [Gut 9.4.0 release notes](https://github.com/bitwes/Gut/releases/tag/v9.4.0) — 2025-06-11
- [Gut 9.6.0 release notes](https://github.com/bitwes/Gut/releases/tag/v9.6.0) — 2026-02-24, "Compatibility changes for Godot 4.6"
- [godot#72657 — Viewport.push_input in_local_coords semantics](https://github.com/godotengine/godot/issues/72657) — closed/archived 2023, Sauermann clarification still authoritative
- [godot#73557 — parse_input_event in headless mode, Sauermann reply on DisplayServer requirement](https://github.com/godotengine/godot/issues/73557)
- [godot#110250 — Hide Control focus when given via mouse input](https://github.com/godotengine/godot/pull/110250) — merged into 4.6
- [godot#117486 — TextureButton focus regression 4.5→4.6](https://github.com/godotengine/godot/issues/117486)
- [godotforums.org — parse_input_event of InputEventMouseButton ignored when use_accumulated_input=false](https://forum.godotengine.org/t/parse-input-event-of-inputeventmousebutton-gets-ignored-when-use-accumulated-input-is-false/116294) — 2025-07-15, narrow case (re-emit from `_input`)
- [godotforums.org — how to manually trigger _can_drop_data](https://forum.godotengine.org/t/help-how-to-manually-trigger-can-drop-data-on-a-control-node/124470) — 2025-10-07
- [godotforums.org — Mouse input events broken after going from 4.5.1 → 4.6](https://forum.godotengine.org/t/mouse-input-events-broken-after-going-from-4-5-1-4-6/131730) — 2026-01-27, **NOT a regression**, OP's invisible Control was eating events
- [Godot 4.6 Viewport class reference](https://docs.godotengine.org/en/4.6/classes/class_viewport.html)
- [Godot 4.6.2 maintenance release notes](https://godotengine.org/article/maintenance-release-godot-4-6-2/) — 2026-04-01
