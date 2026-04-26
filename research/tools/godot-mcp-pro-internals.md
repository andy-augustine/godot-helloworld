---
title: "Godot MCP Pro - Internal Architecture & Extensibility Analysis"
researcher: "Claude Opus 4.7"
date: "2026-04-26"
verdict: "NOT MODIFIABLE (proprietary); Extensible only via tool composition"
---

## 1. Architecture Map

### High-level flow
```
Claude (MCP client)
   ↓
Node.js MCP Server (stdio/HTTP) — registerInputTools() et al.
   ↓
GodotConnection (WebSocket:6505)
   ↓
Godot Editor Addon (GDScript) — mcp_input_service.gd autoload
   ↓
Input.parse_input_event() → InputEventKey/Mouse/Action objects
   ↓
Running game receives events via _input() and _unhandled_input()
```

Each tool registered in server/src/tools/* (e.g., input-tools.ts line 11-137) sends a JSON-RPC command via WebSocket to the addon. The addon receives JSON in user://mcp_input_commands, parses it, and dispatches InputEvent objects synchronously within _process().

### Key files
- **Server registration**: `/server/src/index.ts` (lines 74-82) registers tool modules including `registerInputTools()`
- **Tool definitions**: `/server/src/tools/input-tools.ts` (lines 7-137) defines `simulate_key`, `simulate_mouse_click`, `simulate_mouse_move`, `simulate_action`, `simulate_sequence`
- **Addon dispatcher**: `/addons/godot_mcp/mcp_input_service.gd` (lines 1-194) receives commands and converts to InputEvent objects
- **Input command handler**: `/addons/godot_mcp/commands/input_commands.gd` (lines 1-157) serializes events to JSON file

---

## 2. Input Simulation Pipeline (Critical)

### Tool registration (server side)

All input tools follow the same pattern. Example: `simulate_mouse_click` at input-tools.ts:46-64:
- Server registers tool with Zod schema (parameters: x, y, button, pressed, double_click, auto_release)
- Calls `godot.sendCommand("simulate_mouse_click", params)` over WebSocket
- Returns JSON response

### Addon side implementation

#### Serialize (input_commands.gd:40-74)
`_simulate_mouse_click()` builds a press event dict: `{type: "mouse_button", button: 1, pressed: true, position: {x, y}}`. 
If `auto_release=true` (default), appends a release event and writes both with frame_delay=1 to user://mcp_input_commands file.

#### Dispatch (mcp_input_service.gd:22-49)
`_process()` polls for commands file. When found, parses JSON and:
- If dict has `sequence_events` key: queues events with frame_delay, dispatches first immediately
- Else: dispatches single event or array immediately

#### Create event objects (mcp_input_service.gd:96-194)
`_create_event()` factory:
- `_create_mouse_button_event()` (lines 149-157): constructs `InputEventMouseButton`, sets position via `_viewport_to_window()` transform
- `_create_mouse_motion_event()` (lines 160-185): constructs `InputEventMouseMotion`, applies button_mask, scales relative movement by viewport transform
- `_create_key_event()` (lines 123-138): constructs `InputEventKey` from keycode string
- `_create_action_event()` (lines 188-193): constructs `InputEventAction`

#### Inject into game (mcp_input_service.gd:81-93)
`_dispatch_event()` uses TWO injection paths:
1. **GUI-safe path**: `Input.parse_input_event(event)` — standard path, GUI layer may consume
2. **Unhandled path**: `get_viewport().push_input(event, true)` — bypasses GUI, reaches `_unhandled_input()`

Auto-enables unhandled for mouse drag (button_mask > 0) to fix camera pan/drag when UI overlays consume events.

### simulate_sequence (most relevant for drag)

**Server definition** (input-tools.ts:105-137):
```
events: array of {type, keycode?, action?, button?, x?, y?, relative_x?, relative_y?, button_mask?, unhandled?, ...}
frame_delay: frames between events (default: 1)
```

**Addon implementation** (input_commands.gd:116-146):
- Validates events array non-empty
- If frame_delay <= 0: writes all events in one frame as plain JSON array
- If frame_delay > 0: writes `{sequence_events: [...], frame_delay: N}` and queues for multi-frame dispatch
- Queued events dispatch in _process() ticks with frame_delay between each

**Execution model**: Synchronous within Godot, NOT a per-step WebSocket round-trip. All events are queued client-side once the file is written. frame_delay is applied during game _process() calls, so timing is frame-accurate but subject to frame time variance.

### Drag capability analysis

**Can express drag with simulate_sequence?** YES
```
events: [
  {type: "mouse_button", button: 1, pressed: true, x: 100, y: 100},  // press at start
  {type: "mouse_motion", x: 150, y: 100, button_mask: 1},            // move right, hold button
  {type: "mouse_motion", x: 200, y: 100, button_mask: 1},            // move more
  {type: "mouse_button", button: 1, pressed: false, x: 200, y: 100}, // release at end
]
frame_delay: 5
```

**Execution determinism**: MOSTLY DETERMINISTIC
- All events queued in single WebSocket call, no latency between steps
- Frame delays applied in game _process(), frame-accurate
- BUT: actual frame time variance (~16ms at 60fps) means position at event timestamp may shift ±1 frame
- NO sub-frame timing (e.g., you can't say "move at frame 3.5")

**Existing drag reference in codebase**:
- mcp_input_service.gd:78-79: "Mouse drag motions (button_mask > 0) and events with 'unhandled' flag use push_input to bypass GUI"
- input_commands.gd:90-92: auto-enable unhandled when button_mask > 0
- No _get_drag_data or DragData references (those are Godot's native drag-and-drop, not input simulation)

---

## 3. Tool Registration & Extension Points

### Pattern
1. **Server side**: Create TypeScript file in `/server/src/tools/` with export function `registerXxxTools(server: McpServer, godot: GodotConnection)`
2. Call `server.tool(toolName, description, schema, async handler)`
3. Handler calls `godot.sendCommand(commandName, params)`
4. **Addon side**: Add corresponding command to `/addons/godot_mcp/commands/xxx_commands.gd`
5. Implement `_xxx()` method, return `success({...})` or `error_xxx(...)`
6. Write result to file (e.g., user://mcp_input_commands) or return directly
7. **Registration**: Add to `/addons/godot_mcp/command_router.gd` to wire command to handler

### For a hypothetical simulate_drag tool

**Would need**:
- `/server/src/tools/drag-tools.ts`: Define tool signature (start_pos, waypoints, end_pos, frame_interval, button_index, etc.)
- `/addons/godot_mcp/commands/drag_commands.gd`: Compose multiple InputEventMouseButton/MouseMotion events from path, write as sequence
- Wire into command_router.gd

**Is there a clean extension point?** PARTIALLY
- Tool registration is in `index.ts` (lines 74-82); you'd add `registerDragTools(server, godot)` call
- Addon command dispatch in command_router.gd; you'd add `"simulate_drag": _on_simulate_drag` (or delegate to existing input_commands.gd)
- No plugin/extension API; you'd fork or patch the addon code

---

## 4. CLI Surface

**CLI entry**: `/server/src/cli.ts` (lines 1-500+)

**Command groups** (see COMMANDS object starting line 34):
- `project`: info, files, search, grep, get-setting, set-setting
- `scene`: tree, create, open, save, play, stop, content, exports, delete, dependencies
- `node`: add, delete, get, set, find, connect, signal
- `script`: read, create, edit, attach, validate, list
- `editor`: errors, log, screenshot, editor-screenshot, exec, signals, reload
- `input`: key, click, action, actions
- `runtime`: tree, script, properties, screenshot, monitor, etc.

**Input commands** (cli.ts:341-393):
```
input key --key W --duration 0.5   # maps to simulate_key {keycode: "KEY_W", duration: 0.5}
input click --x 100 --y 200         # maps to simulate_mouse_click {x: 100, y: 200}
input action --action ui_accept     # maps to simulate_action {action: "ui_accept"}
```

**CLI implementation**: WebSocket client in cli.ts that connects to port 6510-6514 (if main port 6505 is taken). Sends JSON-RPC 2.0 requests, waits for responses. DOES invoke the same tool implementations as MCP; no separate code path.

**Requires editor running**: YES, for all runtime ops. CLI connects directly to Godot via WebSocket like MCP server does.

**Example flow** (`input key --key W --duration 0.5`):
1. CLI parses --key and --duration
2. Calls `godot.sendCommand("simulate_key", {keycode: "KEY_W", duration: 0.5})`
3. Server-side input-tools.ts handler splits duration: press immediately, setTimeout 500ms, release
4. Each press/release sends command to addon
5. Addon receives, queues events in user://mcp_input_commands
6. Game's _process() dispatches InputEvent objects

---

## 5. Existing Helpers for Multi-Step Sequences

### execute_game_script (runtime-tools.ts:128-156)
**Runs arbitrary GDScript inside the running game**. Could theoretically execute an entire drag sequence as a script:
```gdscript
var start_pos = Vector2(100, 100)
var end_pos = Vector2(200, 100)
var steps = 10
for i in range(steps):
  var t = float(i) / steps
  var pos = start_pos.lerp(end_pos, t)
  Input.parse_input_event(create_mouse_event(pos))
  await get_tree().process_frame
```
BUT: Requires writing GDScript, not leveraging input simulation tools. High complexity.

### run_test_scenario (test-tools.ts:10-54, test_commands.gd:25-100+)
**Orchestrates input, wait, assert, screenshot steps synchronously**.
```json
steps: [
  {type: "input", keycode: "KEY_SPACE", pressed: true},
  {type: "wait", seconds: 0.1},
  {type: "input", keycode: "KEY_SPACE", pressed: false},
  {type: "assert", node_path: "/root/Player", property: "in_air", expected: true}
]
```
Each step is synchronous within the scenario. BUT: steps are individual actions; doesn't provide a drag-specific primitive.

### start_recording / stop_recording / replay_recording
Records real input events from player, replays them. Mentioned in AGENTS.md but not seen in tool files. May not be fully implemented.

### monitor_properties (runtime-tools.ts in AGENTS.md)
Captures property values per frame. Useful for verifying drag movement in position/velocity but doesn't generate drag input.

**Verdict**: `simulate_sequence` + `capture_frames` is the canonical way. `execute_game_script` is a workaround but requires GDScript. `run_test_scenario` doesn't reduce latency.

---

## 6. License & Modification Posture

**License**: Proprietary (LICENSE lines 1-43)
- Granted: personal/commercial use, use on own machines, private projects
- PROHIBITED: redistribute, modify and redistribute, remove copyright notices, share license key
- Modification: Explicitly forbidden to "Modify and redistribute the Software as a competing product"

**Consequence for patching**: You CAN patch the addon locally for your own use. You CANNOT redistribute a patched version.

**No plugin/extension API**: The addon is monolithic GDScript. Extension would require forking.

---

## Key Findings

1. **Input injection uses standard Godot API**: `Input.parse_input_event()` + `InputEventKey/Mouse/Action`. No special undocumented hooks.

2. **Drag support exists but not as a first-class tool**: `simulate_sequence` with button_mask can express drag. Works frame-accurately without MCP round-trip latency.

3. **GUI consumption bypass is explicit**: `push_input(event, true)` auto-enabled for button_mask > 0. Critical for drag over UI.

4. **Sequence execution is game-side only**: Once events are written to file, game's _process() handles timing. No per-event WebSocket latency.

5. **Would NOT require server rebuild to add simulate_drag**: Would be a new command in input_commands.gd that composes a sequence internally. Addon-only change.

6. **License forbids redistribution but allows personal modification**: You can patch locally; cannot share patched version.

---

## Recommendation for Drag Support

**Short term**: Use `simulate_sequence` with waypoint array and button_mask=1. Frame-accurate, no latency. Example:
```json
{
  "events": [
    {type: "mouse_button", button: 1, pressed: true, x: 100, y: 100},
    {type: "mouse_motion", x: 110, y: 100, button_mask: 1, unhandled: false},
    {type: "mouse_motion", x: 120, y: 100, button_mask: 1, unhandled: false},
    ...
    {type: "mouse_button", button: 1, pressed: false, x: 200, y: 100}
  ],
  "frame_delay": 2
}
```

**Long term**: Patch `/addons/godot_mcp/commands/input_commands.gd` to add `_simulate_drag()` that accepts (start, end, num_steps, button, frame_interval) and internally generates the sequence. Would be 20 lines of GDScript. No server rebuild needed.

---

## File References

- Server tool registration: `/server/src/tools/input-tools.ts` (lines 1-138)
- Addon event dispatch: `/addons/godot_mcp/mcp_input_service.gd` (lines 16-93)
- Input event creation: `/addons/godot_mcp/mcp_input_service.gd` (lines 96-194)
- GUI bypass logic: `/addons/godot_mcp/mcp_input_service.gd` (lines 81-93)
- License: `/LICENSE` (lines 1-43)
- AGENTS instructions: `/AGENTS.md` (lines 119-146)
