# Godot Current Intel — Synthesized Deliverable

**Crawl date:** 2026-11-01 | **Window:** 2026-10-01 forward | **Supersedes:** synthesis of 2026-10-01
**Inputs:** `research/crawl/sourcemap.md` [SM], `topic-engine-quirks.md` [EQ], `topic-gdscript-language.md` [GD], `topic-tooling.md` [TL], `topic-2d-platformer.md` [2D], `topic-performance.md` [PF]
**Project:** Godot 4.6.2, GDScript, GL Compatibility, 960×540, macOS Apple Silicon, godot-mcp-pro.

**Crawl caveats (read first):**
- godotengine.org, docs.godotengine.org and forum.godotengine.org were unreachable from the crawl sessions. Claims sourced there come from search snippets and mirrors (gamedev.net, linuxiac, linuxcompatible). [EQ][GD][PF]
- [2D] issue statuses for GH-121843, GH-121681, GH-123593, GH-120379, GH-121094 carry over from the prior crawl and were not re-read on GitHub. They are **provisional**.
- **4.7.2 stable status is provisional.** [SM] confirms only 4.7.2 RC1 (2026-08-03). [EQ] reports GH-109639 "fixed in 4.7.2 stable" and repros on "4.7.2" (GH-124548, GH-122708), which implies 4.7.2 stable shipped. Confirm at https://github.com/godotengine/godot-builds/releases.
- **Repo verified this synthesis:** `camera/GameCamera.gd:52` and `World.gd:124,151` set `position_smoothing_enabled = true`. No `event.device` checks, no `.connect(func` lambda connections, no `one_way` collision in any `.gd`/`.tscn`/`.tres`. `addons/` contains only `godot_mcp`; **GUT is not installed**, which contradicts [TL]'s "we already use GUT".

---

## 1. TL;DR

- **Engine:** 4.7 moved keyboard/mouse to `InputEvent.DEVICE_ID_KEYBOARD`/`DEVICE_ID_MOUSE`; `device == 0` breaks. Open GH-124614 lets mouse motion suppress joypad menu input. [EQ]
- **GDScript:** Lambdas capturing `self` connected to a RefCounted's own signal still leak in 4.7 (GH-102327). Use named-method connections, which we already do. [GD]
- **Tooling:** GdUnit4 jumped to v6.2.2 (2026-10-07) with full stack traces and CLI/JUnit output. It is now ahead of GUT for CI reporting. [TL]
- **2D platformer:** GH-121843 (Camera2D built-in smoothing gray screen, macOS + Compat) still gates 4.7. Replace `position_smoothing_enabled` with a script lerp first. [2D]
- **Performance:** 4.8 beta 1 makes Object property access ~1.6× faster and saves ~12 MB RAM, with no code changes. 4.8 stable is due Q4 2026. [PF]

---

## 2. Active sources, ranked

S/N updates from this crawl are marked **Δ**.

### HIGH
| Source | URL | Why | Tag |
|---|---|---|---|
| godotengine/godot issues + PRs | https://github.com/godotengine/godot | Authoritative bug/fix state. October filed GH-124548, GH-124614, GH-124966, all relevant | [SM][EQ][GD] |
| Official blog | https://godotengine.org/blog/ | Release notes, dev snapshots, policy (AI ban). Highest trust | [SM] |
| godot-builds releases | https://github.com/godotengine/godot-builds/releases | Only reliable way to confirm 4.7.2 / 4.8 beta 2 tags | [SM] |
| forum.godotengine.org | https://forum.godotengine.org/ | Best Q&A S/N. Hosted the Metroidvania camera consensus thread | [SM][2D] |
| godot-proposals | https://github.com/godotengine/godot-proposals | GDScript type-system and lambda proposals (#13800, #8558) | [SM][GD] |
| MikeSchulze/gdUnit4 | https://github.com/MikeSchulze/gdUnit4 | **Δ** Was "v5.1 RC, stale since April" [SM]. Actually v6.2.2 on 2026-10-07, so active | [TL] |
| bitwes/Gut | https://github.com/bitwes/Gut | v9.7.1 (2026-07-10) tracks 4.7. Changelogs live here, not on the Asset Store | [SM][TL] |
| GDQuest | https://www.youtube.com/@GDQuest | Intermediate/advanced, recommended by the docs | [SM] |
| Contributors Rocket.Chat | https://chat.godotengine.org/ | Core devs, `#gdscript`, `#rendering` | [SM] |

### MED
| Source | URL | Why | Tag |
|---|---|---|---|
| godot-docs repo | https://github.com/godotengine/godot-docs | Migration guides. Lambda docs PR #123675 pending | [SM][GD] |
| 4.7 migration guide | https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html | Required before the upgrade | [EQ][PF] |
| r/godot | https://www.reddit.com/r/godot/ | Community pulse; weak on deep GDScript | [SM] |
| Official Discord | https://discord.gg/4JBkykG | `#help`; link user-sourced, verify | [SM] |
| Mastodon @godotengine | https://mastodon.gamedev.place/@godotengine | Announcements | [SM] |
| gamedev.net Godot | https://gamedev.net/news/topic/godot/ | **Δ** Promoted in practice. It was the working mirror for blocked godotengine.org posts | [EQ][PF] |
| Godot Digest / Godot Weekly | https://godotdigest.substack.com/, https://godot-weekly.curated.co/ | Curated digests | [SM] |
| GodotCon talks | https://talks.godotengine.org/godotcon-boston-2026/ | Boston 2026 talks: low-spec optimisation, rendering | [SM] |
| KidsCanCode / Brackeys | https://kidscancode.org/godot_recipes/, https://www.youtube.com/@Brackeys | Recipes / beginner; 2026 activity unconfirmed | [SM] |
| linuxiac / linuxcompatible | https://linuxiac.com/, https://www.linuxcompatible.org/ | **Δ** New. Reliable release-note mirrors | [EQ][2D] |

### LOW
| Source | Why | Tag |
|---|---|---|
| chickensoft-games | C#-only | [SM] |
| Bluesky / Lemmy | No high-signal instance found | [SM] |
| X / Twitter | No core-dev presence | [SM] |
| Third-party MCP directories (enterprisedna, sourcepulse, summerengine) | Useful only for discovering tools; stats unverified | [TL] |

### SKIP
ask.godotengine.org (dead). Old Asset Library (replaced by store.godotengine.org in 4.7). StackOverflow GDScript threads. Godot 3.x venues. Undated "Godot 4" YouTube tutorials. AI-generated "docs", which hallucinate 4.5+ APIs. [SM]

---

## 3. Contributors to follow

| # | Handle | Domain | Primary link | Why useful | Example contribution |
|---|---|---|---|---|---|
| 1 | @vnen (George Marques) | GDScript lead: parser, VM, types | https://github.com/vnen | Most authoritative voice on GDScript semantics (lambdas, typed opcodes) | Typed arrays / typed instructions [SM] |
| 2 | @dalexeev (Danil Alexeev) | GDScript static analysis, inference | https://github.com/dalexeev | Triages the type traps we hit | Classified GH-114877 (ternary metatype) as a bug [GD] |
| 3 | @Repiteo (Thaddeus Crews) | Release management | https://github.com/Repiteo | Triages release-blocking regressions; authors patch posts | 4.7.1, 4.7.2 RC1, 4.8 dev 3 posts [SM] |
| 4 | @akien-mga (Rémi Verschelde) | Releases, contribution policy | https://github.com/akien-mga | PR gatekeeper; policy changes | June/July 2026 AI-contribution policy [SM] |
| 5 | @bitwes (Tom Wright) | GUT | https://github.com/bitwes/Gut | Responsive maintainer; GUT minor tracks Godot minor | v9.7.1 double-generation fixes (GH-841, GH-842) [TL] |
| 6 | @MikeSchulze (Mike Schulze) | GdUnit4 | https://github.com/MikeSchulze/gdUnit4 | Fastest-moving test framework | v6.2.0 reworked Inspector, full stack traces [TL] |
| 7 | @KoBeWi | 2D editor, TileMap, Metroidvania-System | https://github.com/KoBeWi | Owns upstream 2D; plugin is our best save/room fit | Metroidvania-System plugin [2D] |
| 8 | @lawnjelly | 2D rendering, batching | https://github.com/lawnjelly | 2D rendering edge cases; prolific reviewer | 2D batching work [SM] |
| 9 | @adamscott (Adam Scott) | GDScript async / runtime | https://github.com/adamscott | Coroutine and `await` behaviour | GDScript async work [SM] |
| 10 | @AThousandShips | Triage, core | https://github.com/AThousandShips | Triage voice on leak/cycle reports | Assessed GH-102327 as a circular-reference edge case [GD] |
| 11 | @clayjohn (Clay John) | Rendering: GL/Vulkan, shaders | https://github.com/clayjohn | Matters if renderer regressions reach Compat | Rendering sub-team lead [SM] |
| 12 | @reduz (Juan Linietsky) | Architecture | https://github.com/reduz | Approves major architectural decisions | Co-creator [SM] |
| 13 | @beremaran | godot-agent-loop MCP | https://github.com/beremaran/godot-agent-loop | Best-positioned alternative/complement to godot-mcp-pro | v3.0.0 restructure, 16+40 tools (2026-08-04) [TL] |

---

## 4. Findings

Ranked within each subsection by relevance to this project. Cross-topic duplicates live in one place only.

### 4.1 Engine: quirks and regressions

1. **Keyboard/mouse device IDs changed in 4.7 (GH-116274, intentional).** Keyboard/mouse events no longer report `device == 0`. Use `InputEvent.DEVICE_ID_KEYBOARD` / `DEVICE_ID_MOUSE`, or `event is InputEventKey`/`InputEventMouse`. Our scripts have no `event.device` checks today, so we have zero exposure. Keep it that way when adding gamepad support. https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html, https://godotengine.org/article/dev-snapshot-godot-4-7-dev-2/ [EQ]
2. **Mouse motion suppresses joypad input in menus (GH-124614, OPEN, 4.7+ regression).** `InputEventJoypadButton` stops reaching `_input()` on menu `Control`s while the mouse moves. Bisected to GH-109639, the polling-rate fix, so no build has both fixes. Mitigation: poll `Input.is_joy_button_pressed()` in `_physics_process` for menu navigation. Affects any future pause/inventory menu with dual input. Windows confirmed; macOS unverified. https://github.com/godotengine/godot/issues/124614 [EQ]
3. **High-polling-rate mouse collapses FPS on Windows in 4.7.0/4.7.1 (GH-109639).** ≥1 kHz mice drop to <1 FPS; one rig went from <1 FPS on 4.7.1 to ~477 FPS on 4.8 dev 3. Fixed in 4.7.2 (stable status provisional, see caveats) and 4.8 dev 3+. Windows only, so it doesn't affect macOS dev. Never ship a Windows build on 4.7.0/4.7.1. https://godotengine.org/article/fixing-high-polling-rate-mice-on-windows/, https://godotengine.org/article/release-candidate-godot-4-7-2-rc-1/ [EQ][SM][PF]
4. **AnimationPlayer `current_animation_length` stale after editing length in a named AnimationLibrary (GH-124548, OPEN, filed 2026-10-18, 4.7.2).** Our rig is AnimationPlayer-based, so any code reading `current_animation_length` after an MCP edit gets stale values. Workaround: set `current_animation = ""`, then restore it. https://github.com/godotengine/godot/issues/124548 [EQ]
5. **CapsuleShape2D gets stuck between colliders (GH-122708, OPEN, 4.6–4.7.x, reproduced 4.7.2 macOS).** Relevant to any capsule-shaped CharacterBody2D squeezing between tiles. Our exact platform. https://github.com/godotengine/godot/issues/122708 [EQ]
6. **Script editor input bleeds into the running game outside Windowed+Embedded mode (GH-124079, 4.8 dev 7+, 4.8 milestone).** Not in 4.7.2. If we trial 4.8 betas, playtest in Windowed+Embedded. https://github.com/godotengine/godot/issues/124079 [EQ]
7. **4.8 new projects ignore joypad input when the window is unfocused (GH-120399, intentional).** Upgraded projects keep their setting. Matters only if `project.godot` is regenerated. Setting: `Input/Devices/Joypad/ignore_input_on_unfocus`. https://gamedev.net/news/6488-dev-snapshot-godot-48-beta-1/ [EQ]
8. **One-way collision API gained a `direction` parameter (GH-104736, 4.7 breaking).** This breaks only custom `PhysicsServer2DExtension` overrides of `body_set_shape_as_one_way_collision`. Add `direction: Vector2 = Vector2.ZERO`. We have none. The user-facing side is in §4.4 #3. https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html [EQ][PF]
9. **Other 4.7 migration items** [PF]: LinearToSRGB shader clamping changed; CanvasItem line antialiasing feather removed (antialiased `draw_line` needs wider lines); audio `area_mask` default changed. Audit any custom `_draw()` lines (HUD, debug overlays) after the upgrade. Source: 4.7 migration guide (above).
10. **Forward+ ~60% FPS drop vs 4.6.3 (GH-119963, 4.7 betas, status unclear).** Forward+ only. We use GL Compatibility, so we have no exposure. https://github.com/godotengine/godot/issues/119963 [EQ]
11. **VisualShader graphs broken in 4.8 dev 4 → beta 1 (GH-124966).** Possibly fixed in beta 2 (2026-10-29); provisional, since the fix isn't confirmed. We use no VisualShaders. https://github.com/godotengine/godot/issues/124966 [EQ]

### 4.2 GDScript: language traps and proposals

1. **Lambda capturing `self`, connected to a RefCounted's own signal, leaks (GH-102327, OPEN, v4.3 → v4.7).** The cycle never hits refcount 0, and the leak report shows only `RefCounted:<id>`. Fix: named-method connection (preferred) or `weakref(self)` + `get_ref()` guard. `hud/AbilityStrip.gd:55` already follows this. Keep it as a review rule. https://github.com/godotengine/godot/issues/102327 [GD][PF]
2. **Anonymous lambda connections can't be disconnected.** An identical new lambda isn't equal to the original. Store the `Callable` in a member if you'll need `disconnect`. This bites nodes re-added to the tree (rooms re-entered). https://forum.godotengine.org/t/do-signal-connections-prevent-refcounted-garbage-collection/111346 [GD]
3. **Lambda capture is by value; a freed capture gives an opaque error (GH-117348 intended; GH-117840 open).** Outer reassignment after creation is invisible inside the lambda. A freed captured object raises `Lambda capture at index N was freed` with no guard possible. Use a 1-element Array container (existing rule) or method refs. Docs PR #123675 pending. https://github.com/godotengine/godot/issues/117348, https://github.com/godotengine/godot/issues/117840 [GD]
4. **Ternary over class values infers the first branch's type (GH-114877, OPEN, "Up for grabs").** `(SubA if c else SubB).new()` types as `SubA`. Always annotate explicitly: `var o: Parent = (...).new()`. Relevant once enemy factories exist. https://github.com/godotengine/godot/issues/114877 [GD]
5. **Untyped `Array` drops typed-opcode speedups.** Use `Array[Vector2]` or `Packed*Array` in hot loops. Typed GDScript is consistently faster. Pending PR #70838 claims 40%+ typed dispatch gains (5.76→3.31 ms); merge status in 4.8 is provisional because it wasn't confirmed. The usual 2D bottleneck is draw calls and node count, not script. https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html, https://github.com/godotengine/godot-benchmarks [GD][PF]
6. **No GDScript language changes accepted or shipped in the 2026 window.** Generics (#13800, active discussion, community fork), return-type inference `->:` (#8371), enforced static typing (#7908), lambda capture-by-reference (#8558), async `Future` (#8911) are all open and unaccepted. 4.8 beta 1 adds editor **symbol renaming**, but no language/VM changes. https://github.com/godotengine/godot-proposals [GD][SM]
7. **`await` inside a lambda passed directly as a Callable** was fixed in 4.1 (PR #74949), and nothing new has surfaced since. The existing rule (no top-level `await` in MCP-injected scripts) still stands. [GD]

### 4.3 Tooling

1. **GUT is not installed in this repo.** [TL] assumed we use it; `addons/` holds only `godot_mcp`. Choose a framework before writing unit tests rather than defaulting to GUT. (Repo check, this synthesis.)
2. **GdUnit4 v6.2.2 (2026-10-07) is current, not v5.1 RC as [SM] reported.** v6.1.0 (Jan) brought 4.6 support, variadic `assert_signal`, and orphan detection. v6.2.0 (Jul 28) reworked the Inspector and added full stack traces, orphan details, and `GdUnitObjectAssert.is_valid()`. v6.2.2 fixed orphan reporting for queued-free children and large-string diff OOM, and its CI runs on 4.8 dev 7. CLI runner + JUnit XML make it the better pick if we want headless CI reports. Its 4.6.2 compatibility on v6.2.x is provisional: v6.1 added 4.6 support, but v6.2's minimum wasn't stated. https://github.com/MikeSchulze/gdUnit4/releases [TL]
3. **GUT v9.7.x targets 4.7; v9.7.0 changed doubles.** Doubles/`stub().to_do_nothing()` now return the declared type's default instead of `null`. v9.7.1 (2026-07-10) fixed double parsing (GH-841) and "Unresolved return" (GH-842). If we adopt GUT, pin 9.6.x on 4.6 and 9.7.x on 4.7; versions track the Godot minor. https://github.com/bitwes/Gut/releases [TL][SM]
4. **godot-agent-loop (beremaran, MIT, Godot 4.7+) is the strongest new MCP server.** v3.0.0 (2026-08-04) exposes 16 default + 40 hidden tools, including `game_performance` (live/static profiler audit) and `analyze_project_integrity`. It requires 4.7, so we can't use it on 4.6.2. It's a candidate complement to godot-mcp-pro for profiling after the upgrade. The documented install pins `@1.0.0`; pin v3.x deliberately. https://github.com/beremaran/godot-agent-loop/releases/tag/v1.0.0, https://cdn.jsdelivr.net/gh/beremaran/godot-agent-loop@main/README.md [TL]
5. **gdt (monkeymonk, Go CLI, v0.2.2, 2026-07-21).** Manages engine versions and export templates, runs `gdt export`, generates GitHub Actions configs, and proxies LSP/DAP. Revisit when we build export CI or reach v1.0. https://pkg.go.dev/github.com/monkeymonk/gdt [TL]
6. **In-editor AI plugins (GodotAI, Godot AI, Gamedev AI; Mar–Apr 2026)** run as docked chat panels with less agentic reach than Claude Code + MCP. No action needed. https://www.summerengine.com/blog/best-ai-tools-for-godot [TL]
7. **Other community MCP servers** (better-godot-mcp, tugcantopaloglu/godot-mcp, tomyud1/godot-mcp, hi-godot/godot-ai) have nothing that beats godot-mcp-pro for this project. Previously evaluated in `research/tools/mcp-alternatives.md`. [TL]

### 4.4 2D platformer patterns

1. **GH-121843: Camera2D built-in smoothing shows a gray screen on macOS + Compatibility (4.7 regression). Status provisional:** it is absent from the 4.7.1 / 4.7.2 RC1 fix lists and was not re-read on GitHub. That's our exact platform, renderer and code path (`camera/GameCamera.gd:52`, `World.gd:124,151`). Before any 4.7 trial, replace built-in smoothing with `position = position.lerp(target, delta * smoothing_speed)` in `_physics_process`. The Sep 2026 forum consensus favours this anyway, since it gives full control over room-entry easing. https://github.com/godotengine/godot/issues/121843, https://forum.godotengine.org/t/handling-the-camera-in-metroidvania-games/130882 [2D]
2. **GH-123846: saving a `.tscn` embeds external subresources (OPEN since 2026-09-26, no fix in 4.7.2 RC1).** This is the highest-risk issue for our MCP-driven loop. After every MCP scene save, check `git diff` for `[sub_resource]` replacing `[ext_resource]`. Whether 4.6 is affected is provisional (untested on 4.6). https://github.com/godotengine/godot/issues/123846 [2D]
3. **4.7 adds a one-way collision direction on CollisionShape2D.** It's the native way to build drop-through platforms and semi-solid ceilings, including in TileSet physics shapes. We have no one-way collision today, so there's nothing to conflict with ([2D]'s "workarounds in `player.gd`" don't exist). Use the native flag when drop-through floors are designed post-4.7. https://linuxiac.com/godot-4-7-open-source-game-engine-released-with-linux-wayland-hdr-support/ [2D][SM]
4. **AnimationPlayer issues (status provisional, carried from the prior crawl, re-verify):**
   - GH-123593: a capture track segfaults when the target node is freed. Guard with `is_instance_valid(target)` before `play()` in enemy-death and door animations. Applies on 4.6. https://github.com/godotengine/godot/issues/123593
   - GH-121681: crashes when a RESET track references a missing node path (4.8 dev 2+). Keep RESET tracks complete and paths valid before any 4.8 trial. https://github.com/godotengine/godot/issues/121681
   - GH-120379: the AnimationPlayer editor freezes on tree edits (4.7 regression). Don't restructure the tree with the AnimationPlayer panel open. https://github.com/godotengine/godot/issues/120379
   - GH-120921: an AnimationPlayer at the scene root writes wrong relative paths. Our rig is nested, so we're not exposed; re-check on the next rig revision. [2D]
5. **Hot-reload leaves newly added typed members `nil` (#119057; fix PR #123040 in progress).** After adding a typed member declaration, stop and restart the scene. Don't trust hot-reload for this. [2D]
6. **Area2D `monitorable` re-enable is a no-op (GH-121094, 4.7+, provisional).** Toggle `collision_layer`/`collision_mask` instead. `Door.gd` doesn't touch `monitorable`. [2D]
7. **TileMapLayer API is unchanged through 4.8 beta 1.** Use `set_cells_terrain_connect()` for bulk writes, avoid `set_cell()` in loops, and call `local_to_map()` before queries. Open GH-120482 (TileSet sources empty under threaded load; 4.7.2 fix unverified) matters only if we add room streaming. https://forum.godotengine.org/t/best-architectual-practices-for-using-the-tilemaplayer-node-programmatically/116440 [2D]
8. **Hitbox/hurtbox convention unchanged.** Separate `Area2D` children per role. Layers: 1 world, 2 player, 3 enemy, 4 hitbox, 5 pickup. Keep CharacterBody2D on 1+2. [2D]
9. **Save/load: no core API changes.** KoBeWi Metroidvania-System is still the best fit for room/ability persistence. SaveKit (fernforestgames, v0.1, MIT, 4.5+) is the fallback. GH-123189 (4.8 binary-resource relative paths) doesn't affect us while we stay on text `.tscn`/`.tres`. https://store.godotengine.org/asset/fernforestgames/savekit/ [2D]
10. **Room transitions: no new API.** Door overlap → fade → load → fade with `change_scene_to_*` is still the standard. [2D]

### 4.5 Performance and deployment

1. **Use GL Compatibility on macOS; don't switch renderers.** GH-123481 (CanvasShaderRD deadlock on M4/M5 + macOS 26 under Metal/Vulkan, 4.8 milestone) is still open per [2D]'s upgrade checklist. [PF] found no GL Compatibility 2D regressions on Apple Silicon in 4.7; the 4.2 ANGLE/Metal issue was fixed in 4.2.1. https://github.com/godotengine/godot/issues/123481 [2D][PF]
2. **4.8 beta 1 engine wins:** Object property access ~1.6× faster (GH-122596), ~12 MB less runtime RAM (GH-122751), faster bulk child removal (GH-120942). Faster bulk removal helps room unload. You get all three automatically on upgrade. Source: 4.8 beta 1 post via snippet, https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/ [PF]
3. **macOS export:** official templates build Universal 2 `.app`. Notarization needs a Developer ID, `rcodesign` configured in Editor Settings, the Debugging entitlement **disabled**, then `rcodesign staple`. Exporting from Windows/Linux strips the exec bit, so always export on the Mac. Gatekeeper blocks ad-hoc/unsigned downloads. https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html [PF]
4. **Non-allocating physics queries (4.8 dev 7, in beta 1).** These reuse typed result objects instead of allocating a Dictionary per query. Low value now; adopt when enemies or projectiles raycast every frame. https://godotengine.org/article/dev-snapshot-godot-4-8-dev-7/ [PF]
5. **Profiling:** use `Performance.TIME_PROCESS` for script frame time. GPU frame time reads null in some 4.7 profiler environments. Profile before optimising script, because rendering is usually the bottleneck. [PF]
6. **Web export (future):** threaded builds need `COOP: same-origin` + `COEP: require-corp`. Without them the build falls back to single-thread, which is much slower. WebGL 2 only; 4.7 adds wasm64. Check Safari status at ship time. [PF][SM]
7. **Leak hygiene:** disconnect signals in `_exit_tree` for nodes holding RefCounted refs, use `WeakRef` to break cycles, and check the Memory debugger periodically. [PF] found no new native GDScript refcount bugs; the only 2026 leak was in godot-rust (PR #1302). [PF]

---

## 5. Open / unresolved issues we may hit

| Issue | Status | Last seen | Re-scan trigger |
|---|---|---|---|
| GH-121843 Camera2D smoothing gray screen, macOS + Compat | Open (provisional) | 2026-11-01 (carried from 2026-10-01) | Before the 4.7 upgrade; every 4.7.x patch and 4.8 RC. Moot once the script lerp lands |
| GH-123846 `.tscn` save embeds subresources | Open | 2026-11-01 | Any 4.7.x/4.8 changelog mentioning resource saving; any unexpected `[sub_resource]` in our diffs |
| GH-124614 Mouse motion suppresses joypad menu input | Open, regression | 2026-11-01 | Before building any pause/inventory menu with gamepad; 4.7.3/4.8 RC |
| GH-124548 `current_animation_length` stale (named library) | Open, filed 2026-10-18 | 2026-11-01 | Upgrade to 4.7.2+; code reading animation length |
| GH-122708 CapsuleShape2D stuck between colliders | Open, repro 4.7.2 macOS | 2026-11-01 | Player/enemy collider shape change; 4.7.x patch |
| GH-123481 CanvasShaderRD deadlock M4/M5 + macOS 26 | Open, 4.8 milestone | 2026-10-01 | Any renderer switch; 4.8 stable |
| GH-123593 AnimationPlayer capture track segfault on freed node | Open (provisional) | 2026-10-01 | Enemy-death / door animation work; 4.8 RC |
| GH-121681 RESET track missing-path crash | Open (provisional) | 2026-10-01 | Before any 4.8 beta trial |
| GH-120379 AnimationPlayer editor freeze on tree edits | Open (provisional) | 2026-10-01 | 4.7 upgrade; rig restructuring |
| GH-120921 AnimationPlayer at scene root wrong paths | Open | 2026-10-01 | Next rig revision |
| #119057 Hot-reload typed members `nil` (PR #123040) | Fix in progress | 2026-10-01 | PR #123040 merges |
| GH-121094 Area2D `monitorable` re-enable no-op | Open (provisional) | 2026-10-01 | Door re-entry refactor |
| GH-120482 TileSet sources empty under threaded load | Open; 4.7.2 fix unverified | 2026-10-01 | Room-streaming work |
| GH-102327 Lambda/RefCounted self-signal leak | Open, "Needs proposal" | 2026-07 (last comment) | A linked PR appears; any lambda connection in review |
| GH-114877 Class-value ternary inference | Open, "Up for grabs" | 2026-11-01 | Enemy factory code; linked PR |
| GH-117840 Freed lambda capture opaque error | Open, enhancement | 2026-11-01 | Docs PR #123675 merges |
| GH-119963 Forward+ FPS drop vs 4.6.3 | Unclear | 2026-11-01 | Only if leaving GL Compatibility |
| GH-124079 Editor steals game input (non-embedded) | 4.8 milestone | 2026-11-01 | Before a 4.8 beta trial |
| GH-124966 VisualShader breakage 4.8 dev 4–beta 1 | Possibly fixed beta 2 (provisional) | 2026-10-29 | Only if adopting VisualShader |
| GH-120399 Joypad ignored on unfocus (4.8 default) | Intentional | 2026-10-15 | 4.8 upgrade; regenerating `project.godot` |
| 4.7.2 stable release status | Provisional | 2026-08-03 (RC1) | Next scan: confirm tag on godot-builds |
| GdUnit4 v6.2.x minimum Godot version | Unverified | 2026-10-07 | Before choosing a test framework |

---

## 6. Recurring scan recommendation

**Self-recommendation: monthly**, plus event-driven triggers, plus a **one-off targeted scan right after 4.8 stable ships**. Monthly is enough because our stack (2D, GL Compat, GDScript) took no direct hits from October's fixes. October only added two new open issues on our paths (GH-124548, GH-124614), and most watch items move on release boundaries. Weekly would burn crawl budget with blocked domains for little delta. Quarterly is too slow while 4.8 stable and our 4.7 upgrade decision are both imminent. Run via `/refresh-godot-intel` (runbook `research/crawl/PLAN.md`).

**Event triggers (scan immediately):**
- 4.8 RC or stable post on the blog. Re-verify every §5 row, plus GdUnit4/GUT compatibility tags.
- A 4.7.3 patch. Check whether GH-121843, GH-123846, GH-124614 or GH-122708 are in the fix list.
- Before executing the 4.7 upgrade itself. Do a direct GitHub read of every "provisional" row.
- godot-mcp-pro release, or any MCP-loop breakage.

**Sources per scan (in order):** godot-builds releases → official blog (or gamedev.net/linuxiac mirrors if blocked) → godotengine/godot issues filtered by `topic:2d`, `topic:animation`, `topic:input`, `platform:macos`, `regression` → godot-proposals (GDScript label) → Gut and gdUnit4 releases → forum (Metroidvania/camera/TileMapLayer threads) → beremaran/godot-agent-loop releases.

**Watch for:** fixes to §5 rows; new macOS + Compatibility regressions; `.tscn`/resource serialization changes; AnimationPlayer/AnimationLibrary changes; Camera2D changes; CharacterBody2D/`move_and_slide` changes; any accepted GDScript proposal; 4.9 dev roadmap posts.

**Process fix:** the crawl must have network access to github.com issue pages and godotengine.org. Two crawls in a row have produced provisional statuses because of blocked domains. Allow-list `godotengine.org`, `docs.godotengine.org`, `forum.godotengine.org` and the GitHub API before the next run.

**Who to ping if blocked:**
- GDScript semantics: @vnen, @dalexeev (Rocket.Chat `#gdscript`).
- Release/regression status: @Repiteo, @akien-mga.
- 2D / TileMap / Camera2D: @KoBeWi. 2D rendering: @lawnjelly. Renderer: @clayjohn.
- Test frameworks: @bitwes (GUT), @MikeSchulze (GdUnit4), via GitHub issues.
- Given the July 2026 AI-contribution policy, comment on upstream issues as a human with concrete repros. Don't paste AI-generated analyses. [SM]

---

## 7. Surprises

1. **Godot 4.8 beta 1 shipped 2026-10-15 (feature freeze), and 4.8 stable is due Q4 2026.** Beta 2 reportedly followed on 2026-10-29 [EQ]. This reframes the upgrade: skipping 4.7 and going 4.6.2 → 4.8 stable is now a credible option. It would bring the §4.5 perf wins and the GH-109639 fix, at the cost of the 4.8-specific GH-124079 / GH-121681 / GH-120399 items. Decide at 4.8 RC. https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/ [SM]
2. **Godot banned fully AI-authored code contributions (July 2026).** Maintainers reject AI-generated PRs; limited assistance (completion, regex, translation) is tolerated. This project is AI-driven, so any upstream bug report or PR from us needs human-verified repros. https://www.gamingonlinux.com/2026/07/godot-engine-to-get-stricter-on-ai-contributed-code/ [SM]
3. **GdUnit4 is two majors past what the pre-scan expected** (v6.2.2, not v5.1 RC). Combined with GUT not actually being installed here, the test-framework choice is open. [TL]
4. **The GH-109639 fix caused GH-124614.** The patch that makes 4.7.2 usable on Windows is also what breaks gamepad menu input. No released build has both behaviours right. [EQ]

---

## 8. Glossary

- **AccessKit**: cross-platform accessibility toolkit; 4.8 extends it to iOS/Android.
- **AnimationLibrary**: named container of Animations attached to an AnimationPlayer. GH-124548 concerns named (non-default) libraries.
- **CanvasShaderRD**: RenderingDevice (Metal/Vulkan) 2D canvas shader; where GH-123481 deadlocks.
- **COOP/COEP**: Cross-Origin-Opener/Embedder-Policy HTTP headers; required to enable SharedArrayBuffer for threaded web exports.
- **`DEVICE_ID_KEYBOARD` / `DEVICE_ID_MOUSE`**: 4.7 `InputEvent` constants replacing `device == 0` for keyboard/mouse.
- **Docked game view**: 4.8 editor feature that embeds the running game in an editor dock.
- **gdt**: Go CLI "Godot Developer Toolchain": engine version manager, export automation, CI config generator.
- **GdUnit4**: GDScript/C# unit-test framework by MikeSchulze; v6.x current.
- **godot-agent-loop**: MIT MCP server for Godot 4.7+ with profiler and integrity-audit tools.
- **godot-builds**: GitHub repo hosting official Godot release binaries and tags.
- **GodotFest**: independent, business-focused Godot event (Munich, 2026-11-03/04); not an official GodotCon.
- **`GDScriptLambdaCallable`**: internal Callable type backing GDScript lambdas; its lifetime bookkeeping is the missing piece for GH-102327.
- **GUT**: Godot Unit Test by bitwes; version 9.x.y tracks Godot 4.x.
- **Metroidvania-System**: KoBeWi's plugin for room maps, room-state persistence and ability flags.
- **Non-allocating physics queries**: 4.8 space-state methods that fill reusable typed result objects instead of returning new Dictionaries.
- **`rcodesign`**: cross-platform Apple code-signing/notarization tool that Godot's macOS exporter integrates.
- **SaveKit**: fernforestgames group-based save plugin (JSON/binary).
- **Symbol renaming**: 4.8 editor refactor feature for renaming identifiers across scripts.
- **Trail3D**: 4.8 3D trail node; not relevant to us.
- **Universal 2**: macOS binary containing both arm64 and x86_64 slices.
- **wasm64**: 64-bit WebAssembly export target added in 4.7.
- **Windowed+Embedded**: editor run mode where the game window is embedded in the editor; the safe mode for GH-124079.
