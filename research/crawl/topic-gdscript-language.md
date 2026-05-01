# GDScript Language Traps & Proposals
**Generated:** 2026-04-26 | **Updated:** 2026-05-01 | **Baseline:** Godot 4.6.2 stable | **Lead:** @vnen + @dalexeev

---

## TL;DR — Top 3 Findings

1. **`:=` type inference blind spots are real and unsolved.** Type narrowing after `is` checks still does not propagate in 4.6-stable (issue #60499 / duplicate #115492). The engine's own autocomplete uses the narrowed type; the type-checker does not. Manual `as` casts or temp typed vars are the only workarounds — this is an active pain point with an open proposal (#8530) dated April 2026.

2. **Lambda-signal connections can silently multiply on scene reload.** Connecting a signal with an anonymous lambda (not a named method) bypasses Godot's duplicate-connection guard; each `_ready()` call adds another copy. In 4.6 a companion bug (#116141) makes identity vs. equality confusion cause *spurious* "already connected" errors when two different objects with equal content are connected to the same signal. Both remain open.

3. **`await` on a freed-node coroutine is a permanent memory leak.** If a node calls `queue_free()` and then `await`s a signal that never fires (or fires after the node is freed), the `GDScriptFunctionState` never cleans up — issue #72629 was closed as "not planned." The workaround is to only `await` signals with lifetimes shorter than `self`, or cancel via a boolean guard before freeing.

---

## Per-Trap Entries

### 1. Type Narrowing (`is` checks don't narrow for the type-checker)

**What compiles:** `if node is MyClass:` — the block compiles cleanly, autocomplete shows `MyClass` members.

**Runtime / lint failure:** Setting `unsafe_property_access` to Error causes spurious errors inside the block because the static analyzer still sees the pre-check type (e.g., `Node`), not the narrowed `MyClass`. Confirmed present in 4.6-stable on Windows 11.

**Fix / workaround:**
```gdscript
if node is MyClass:
    var typed_node: MyClass = node  # explicit downcast silences the analyzer
    typed_node.my_property = value
# or: (node as MyClass).my_property = value
```

**Citations:** [#115492](https://github.com/godotengine/godot/issues/115492) (closed as dupe of #60499); proposal [#8530](https://github.com/godotengine/godot-proposals/issues/8530) (open, last activity Apr 2026).

---

### 2. Lambda Captures — Local vs. Script-Scope Evaluation Timing

**What compiles:** A lambda that references both local variables and `self`-scope variables compiles without complaint.

**Runtime surprise:** Local variables are captured *by value at lambda creation time*; script-scope (member) variables are evaluated *at call time*. This asymmetry means a captured local `var count` is frozen at capture point and mutations inside the lambda do not propagate back to the outer scope. Issue #69014 was closed as "not planned" — this is intentional design, not a bug.

**Freed-object variant (confirmed 4.6.1):** If a captured object is freed before the lambda executes, the engine passes `null` and emits: `"Lambda capture at index N was freed. Passed 'null' instead."` The index is positional — you must count captures manually. Issue [#117840](https://github.com/godotengine/godot/issues/117840) (filed March 25, 2026, Godot v4.6.1) proposes better wording / downgrade to warning; open as of May 2026.

**Fix / workaround:** Guard inside the lambda: `if captured_obj == null: return`. Use `weakref(obj)` when long-lived lambdas reference scene-tree nodes that may be freed; call `.get_ref()` and null-check inside the lambda body.

**Citations:** [#117840](https://github.com/godotengine/godot/issues/117840) (Mar 25, 2026); [#69014](https://github.com/godotengine/godot/issues/69014) (closed not-planned).

---

### 3. Lambda Signal Connection Accumulation on Scene Reload

**What compiles / appears to work:** `some_signal.connect(func(): do_thing())` — connects fine.

**Runtime failure:** On every scene reload (e.g., player dies and scene is re-instantiated while the signal source persists in an autoload) `_ready` adds another connection. Godot's duplicate-connection guard uses callable *identity*; each `func()` literal creates a fresh Callable object, so the guard never fires. Signal fires N times after N reloads.

**Additional 4.6 bug:** A companion identity-vs-equality bug (#116141, Feb 2026) can cause false "already connected" errors when two *different* object instances with equal content are connected to the same signal.

**Fix / workaround:** Use named methods — `some_signal.connect(_on_thing)` — so the Callable is stable and the guard works. For lambdas that are truly needed, store the Callable in a member var and call `disconnect` in `_exit_tree`.

**Citations:** [#94641](https://github.com/godotengine/godot/issues/94641) (open, filed 2024); [#116141](https://github.com/godotengine/godot/issues/116141) (filed Feb 2026, PR #117336 open, not in 4.6.x).

---

### 4. `await` — Coroutine Lifetime Hazards

**Hanging await / memory leak:** Freeing a node that is mid-`await` on a signal with a longer lifetime leaks the `GDScriptFunctionState`. Issue [#72629](https://github.com/godotengine/godot/issues/72629) (Feb 2023) was closed as "not planned." The leak is silent in release builds; debug builds print "resume after free."

**queue_free + timer race:** Calling `queue_free()` on a node while it awaits `get_tree().create_timer(...)` can let the coroutine execute one more frame after the node is freed. Reproducible in 4.2–4.3 RC2; [#93608](https://github.com/godotengine/godot/issues/93608) still open. Workaround: use a boolean `_is_alive` guard checked at the top of the coroutine.

**GDScriptFunctionState not accessible as type:** Calling an async function via `callv()` returns a `GDScriptFunctionState`, but `if state is GDScriptFunctionState:` fails — the type is not exposed to GDScript. Workaround: `state.get_class() == "GDScriptFunctionState"`. Reported in 4.5.2 and 4.6.2; [#118425](https://github.com/godotengine/godot/issues/118425) (Apr 11, 2026).

**Untyped coroutine → Variant result:** `var result := await my_func()` where `my_func()` has no return type annotation infers `result` as `Variant`, losing all static analysis downstream. Fix: annotate all coroutine return types explicitly.

**Spurious "await not needed" warning:** A `-> void` function without `async` emits this warning even when synchronization is intended. [#74679](https://github.com/godotengine/godot/issues/74679).

**Citations:** [#72629](https://github.com/godotengine/godot/issues/72629); [#93608](https://github.com/godotengine/godot/issues/93608); [#118425](https://github.com/godotengine/godot/issues/118425) (Apr 2026); [PR #72677](https://github.com/godotengine/godot/pull/72677) (@dalexeev await type-inference fix).

---

### 5. `WeakRef` Has No Type Parameter — `.get_ref()` Returns Variant

**What compiles:** `var ref := weakref(my_node)` — inferred as `WeakRef`.

**Runtime / maintenance trap:** `ref.get_ref()` always returns `Variant`. Assigning the result to a typed variable requires an explicit cast; omitting it silently produces a Variant-typed local, losing all static-analysis benefits.

**Fix / workaround:**
```gdscript
var _ref: WeakRef = weakref(my_node)

func get_node_safe() -> MyNode:
    return _ref.get_ref() as MyNode  # null if freed
```

Proposal [#9174](https://github.com/godotengine/godot-proposals/issues/9174) requests `WeakRef[T]` syntax with a linked PR [#109268](https://github.com/godotengine/godot/pull/109268) — open, no merge date.

**Citations:** [#9174](https://github.com/godotengine/godot-proposals/issues/9174); official WeakRef docs (stable).

---

### 6. `preload()` Pins Resources in Memory for Game Lifetime

**What compiles / appears to work:** `const SCENE = preload("res://player.tscn")` — loads fine.

**Runtime trap:** Compiled scripts hold an extra reference to all preloaded resources; the resource cache cannot release them. They remain in memory until exit, even after all instances are freed. Affects both 4.0.4 and 4.6.2. Issue [#118528](https://github.com/godotengine/godot/issues/118528) (Apr 13, 2026) — no fix, no milestone.

**Fix / workaround:** Use `preload()` only for lightweight, always-needed assets (small textures, audio buses). Use `load()` or `ResourceLoader.load_threaded_request()` for heavy scenes or assets you need to free. This is especially relevant for Metroidvania rooms that must load and unload.

**Citations:** [#118528](https://github.com/godotengine/godot/issues/118528) (Apr 13, 2026).

---

### 7. Hot-Reload: New Dictionary/Array Members Are NIL on Live Instances

**What compiles / appears to work:** Adding `var injected_dict: Dictionary = {}` to a script, then hot-reloading.

**Runtime trap:** Existing live instances see the new property in `get_property_list()` but its value is `Variant::NIL` instead of an empty Dictionary/Array. Calling `.has()` or `.size()` on NIL crashes. Only fresh instances created after reload initialize correctly.

**Fix / workaround:** Defensive init at top of `_ready()` / `_process()`:
```gdscript
if not injected_dict is Dictionary:
    injected_dict = {}
```
Or restart the game instead of hot-reloading when adding container members.

**Affected version:** 4.6.2-stable. PR #119058 adds regression test; fix status unclear.

**Citations:** [#119057](https://github.com/godotengine/godot/issues/119057) (Apr 28, 2026).

---

### 8. Multi-Line Lambda Inside Dictionary Literal — Parser Error

**What compiles:** Single-line lambda inside dict: `{"items": items.map(func(e): return e.name)}`.

**Compile failure:** Multi-line lambda body inside a dict declaration triggers `"Unindent doesn't match the previous indentation level"` even with correct indentation. Reproducible in v4.6-stable.

**Fix / workaround:** Extract the lambda to a local variable before the dict, or collapse to a single-line lambda.

```gdscript
# Fails in 4.6:
var wrapped := {"items": items.map(func(e: Item):
    return {"name": e.name}  # parse error
)}

# Works:
var mapper := func(e: Item): return {"name": e.name}
var wrapped := {"items": items.map(mapper)}
```

**Citations:** [#116133](https://github.com/godotengine/godot/issues/116133) (Godot v4.6-stable).

---

### 9. Typed vs. Untyped Performance Gap (4.6 JIT)

**Not a bug — a new pressure point:** Godot 4.6 ships a JIT compiler. Typed GDScript benefits far more than untyped code. Practical order of performance: `PackedXxxArray` > `Array[T]` > bare `Array`. The typed/untyped gap is now 2–3× at minimum; on hot inner loops the gap is larger.

**Trap:** Using `Array` where `Array[T]` would work forfeits both JIT gains and static analysis. The `UNTYPED_DECLARATION` warning (Project Settings → Debug → GDScript) now flags functions without explicit return type; in 4.7-dev the warning incorrectly highlights the entire function body instead of just the declaration line ([#118550](https://github.com/godotengine/godot/issues/118550), Apr 13, 2026, fix PR #118552 pending).

**Untyped @GlobalScope functions marked unsafe silently:** Calling `abs(float_var)` instead of `absf(float_var)` is flagged as "unsafe code" with no warning message in 4.6 and 4.7-dev ([#118557](https://github.com/godotengine/godot/issues/118557), Apr 14, 2026). Use typed variants: `absf()`, `absi()`, `snappedf()`, etc.

**Citations:** [StraySpark benchmark article (2026)](https://www.strayspark.studio/blog/gdscript-vs-csharp-godot-2026-choosing-scripting-language); [#118550](https://github.com/godotengine/godot/issues/118550); [#118557](https://github.com/godotengine/godot/issues/118557).

---

### 10. Underscored Signals Now Hidden (4.6 — Intentional)

Signals named with a leading underscore (e.g., `signal _internal_event`) no longer appear in editor autocomplete, documentation, or `get_signal_list()` results in Godot 4.6. This matches the convention for private methods. If you have autoloaded signals prefixed with `_` that you inspect dynamically, update the prefix or your introspection code.

**PR:** [#112770](https://github.com/godotengine/godot/pull/112770) merged November 2025, ships in 4.6.

---

## Active / Tracked GDScript Proposals (2026)

| # | Title | Status | Priority for this project |
|---|---|---|---|
| [#8530](https://github.com/godotengine/godot-proposals/issues/8530) | Suppress unsafe-access warnings inside `is` blocks | Open — last activity Apr 2026 | High — daily friction |
| [#10807](https://github.com/godotengine/godot-proposals/issues/10807) | Typed `Callable[Params, Return]` | Open — no impl yet | High — signal typing |
| [#9174](https://github.com/godotengine/godot-proposals/issues/9174) | `WeakRef[T]` typed weak references (PR #109268 open) | Open — PR exists | Med |
| [#12567](https://github.com/godotengine/godot-proposals/discussions/12567) | Trait system design (PR #107227 in progress) | Active implementation | Med — watch for 4.7 |
| [#12928](https://github.com/godotengine/godot-proposals/issues/12928) | GDType unified type system (Aug 2025) | Open — no impl PR yet | Med — unblocks structs/generics |
| [#13800](https://github.com/godotengine/godot-proposals/issues/13800) | Generics for GDScript classes/functions (Dec 2025) | Open — no core response | Low / watch |
| [#14106](https://github.com/godotengine/godot-proposals/issues/14106) | `defer` keyword (Jan 30, 2026) | Open — no core response | Low / nice-to-have |
| [#7329](https://github.com/godotengine/godot-proposals/issues/7329) | Structs in GDScript | **Blocked** — awaits GDType system | Low until GDType lands |
| [#12685](https://github.com/godotengine/godot-proposals/issues/12685) | GDScript 3.0 meta-proposal | **Closed / archived** | Closed |

### Notes on proposal landscape (May 2026)

- **Type narrowing (#8530)** is the most directly actionable — still seeing active comments. If it lands in 4.7 it would eliminate most explicit-downcast boilerplate in this codebase.
- **Typed Callable (#10807)** would let signal connections be fully type-checked; no implementation PR yet.
- **`WeakRef[T]` (#9174)** has a linked engine PR — worth monitoring for 4.7.
- **Trait system (#12567)** has an active implementation PR (#107227) and is the most likely "big language feature" to land in 4.7. Uses keyword still debated (`uses`, `implements`, `applies`).
- **Structs PR (#117410)** was opened and closed March 2026 — author voluntarily withdrew because the GDType unified type system (#12928) must land first to avoid future incompatibilities.
- **`defer` keyword (#14106)** was filed January 30, 2026; no core team engagement yet.
- **Abstract methods** (`@abstract` keyword, PR #106409 by @dalexeev) shipped in Godot 4.5 — already available in 4.6.2.
- The "GDScript 3.0" meta-proposal was closed in early 2026; maintainers are tracking improvements as individual proposals instead.

*Sources: github.com/godotengine/godot issues (esp. #117840, #118425, #118528, #118550, #118557, #119057, #116133, #94641, #116141, #72629, #93608); github.com/godotengine/godot-proposals (#8530, #9174, #10807, #12567, #12928, #13800, #14106); godotengine.org releases; StraySpark GDScript vs C# 2026 benchmark.*
