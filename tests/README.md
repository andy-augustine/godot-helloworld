# tests/

How we test this Godot game through Claude Code + godot-mcp-pro. **Read this before writing any new test or playtest sequence.**

For the working drag-recipe data and the runner script, see [`RESULTS.md`](RESULTS.md). For the reflexive habits that make MCP-driven testing predictable, see the [memory feedback files](../.claude/projects/-Users-claudeprojectlt8-code-personal-godot-helloworld/memory/) — the rules in `feedback_godot_mcp_scene_editing.md` and `feedback_gdscript_practices.md` are the load-bearing ones.

---

## Why this is non-obvious: MCP is async

Every godot-mcp-pro tool call is a round-trip over WebSocket on port 6505. Each call adds ~200-500 ms of latency. The game does **not** pause while we wait for our tool call to return — physics keeps stepping at 60 Hz the whole time.

Practical consequence: a sequence like

```
simulate_action("move_right", pressed=true)   # fires instantly
capture_frames(count=6, frame_interval=4)     # starts 200ms+ later
```

will miss the early/mid-motion frames. At `MOVE_SPEED = 220`, half a second of latency = 100+ pixels of player travel. Anything you wanted to verify mid-motion has already happened.

---

## The four patterns — pick the right one

### Pattern 1: Synchronous harness inside one `execute_game_script` (PREFERRED for state checks)

Run the whole verification deterministically inside the game process. No MCP round-trips mid-sequence. Use for anything involving timing, motion, animation transitions.

```gdscript
var p = get_tree().root.get_node("World/Player")
p.position = Vector2(400, 500)
p.velocity = Vector2.ZERO

var results: Array = []
var step := func() -> void:
    Input.action_press("move_right")
    for i in 10:
        await get_tree().physics_frame
    results.append("t=10f: pos=%s anim=%s" % [p.position, p._current_anim])
    for i in 10:
        await get_tree().physics_frame
    results.append("t=20f: pos=%s anim=%s" % [p.position, p._current_anim])
    Input.action_release("move_right")

await step.call()
for line in results:
    _mcp_print(line)
```

Key rules (also encoded in `feedback_gdscript_practices.md` rule 5):
- Wrap awaiting logic in a `func() -> void:` lambda, then `await` that call. Top-level `await` in `execute_game_script` crashes.
- `await get_tree().physics_frame` advances exactly one physics step.
- Release every pressed input at the end of the test.

### Pattern 2: Pause + pose check

Stop physics, force a pose, screenshot, restore. Good for confirming the rig looks right in a specific animation state. Doesn't validate physics or transitions.

```gdscript
var p = get_tree().root.get_node("World/Player")
p.set_physics_process(false)   # stop _update_animation from overwriting
p.position = Vector2(400, 450)
p._anim.play("run")            # or "jump", "wall_slide", "land", etc.
```

Then call `get_game_screenshot`. Restore `set_physics_process(true)` and the original position before leaving the test.

### Pattern 3: Drag-and-drop via `simulate_sequence`

Synthetic GUI drag works in Godot 4.6.2 — two requirements:

1. Every motion event must have **non-zero `relative_x` / `relative_y`** matching the position delta. Godot's drag-detection threshold accumulates the `relative` field, not absolute deltas. With `relative=(0,0)` every motion, the threshold (~8 px) is never exceeded and `_get_drag_data` never fires.
2. The local godot-mcp-pro addon patches at `addons/godot_mcp/commands/input_commands.gd` and `addons/godot_mcp/mcp_input_service.gd` are required so explicit `unhandled: false` overrides the addon's auto-promotion of motions to `push_input(event, true)`. Without the patches, drag motions skip GUI hit-testing.

Working recipe + runner: [`tests/run_drag_recipe.gd`](run_drag_recipe.gd) with `RESULTS.md` for the JSON sequence and verification data.

For non-GUI mechanics (player movement, dashes, etc.), use Pattern 1 instead — `simulate_sequence` is for cases where GUI hit-testing has to be exercised.

### Pattern 4: Handoff to human playtest

Feel tuning (jump floatiness, run speed, gravity weight) — don't try to QA. Ask the user for symptoms ("turning around feels sluggish", "jump floats too long at apex") and tune the constant in `player/player.gd`. Subjective feel doesn't fit synthetic verification.

---

## Reflexive habits — read the memory rules

The rules below live in the auto-memory's `feedback_godot_mcp_scene_editing.md` and trigger automatically each session. Stating them here for human readers:

- **Always `stop_scene` the moment you have the data.** The play window covers the user's screen and steals focus. Classify the test loop *before* `play_scene` — if it's one-shot (verify-then-stop-regardless), include `stop_scene` in the final tool-call batch. (Rule 7.)
- **`save_scene` is paired with `get_editor_errors`.** Scene parse errors surface immediately on save but never appear in the play-mode log. Reflexively check after every save. (Rule 4.)
- **Cross-scene edits require re-`open_scene` of the parent.** Clashes from instance overrides only show up when the parent is freshly loaded. (Rule 5.)
- **`set_project_setting` is paired with `git diff project.godot`.** The tool can silently strip third-party autoload entries during serialization. Verify the diff. (Rule 6.)
- **Use `set_deferred()` for any `monitoring`/`disabled`/state mutation inside a collision/input callback.** Physics flush is locked during the callback; direct mutations error out. (gdscript-practices rule 8.)

---

## Window / screenshot sizing

Project is set to 960×540 viewport with `allow_hidpi=false` specifically to keep QA screenshots small. Don't change these settings without asking — they exist to conserve session context.

Screenshots at this size cost ~15× less than Retina-scaled full-res captures. If a test really needs more detail, capture just the region of interest rather than bumping up the whole viewport.

---

## Don't QA-sweep without cause

The rig + animation keyframes have been validated in prior sessions. Don't run long synthetic sweeps just to confirm "it still works." Unless a change could plausibly have broken something specific, trust the code and hand off to the user for feel.
