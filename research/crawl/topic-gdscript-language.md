# GDScript Language Traps & Proposals — New Since Jan 2026
**Crawl date:** 2026-06-01 | **Window:** post-January 2026 | **Engine target:** Godot 4.6.x (4.7 beta noted separately)

---

## TL;DR — Top 3 Findings

1. **Lambda closures capture by value, not by reference** (confirmed open bug #117348, March 2026). Mutations to outer variables inside a lambda are invisible to the outer scope, and subsequent lambda calls continue using the snapshot captured at creation time. The 1-element Array accumulator workaround (already in memory) is the confirmed fix; do not rely on plain outer-variable mutation.

2. **Connecting a lambda that captures `self` leaks RefCounted objects** (open bug #102327). The reference cycle prevents garbage collection. Fix: connect a named method instead of an anonymous lambda, or capture `weakref(self)` and guard with `is_instance_valid()`.

3. **Typed `Dictionary[K,V]` and `Array[T]` silently crash or error in two newly-confirmed scenarios**: nested `for`-loop iteration over a typed dictionary causes a silent crash with no editor output (bug #116947, confirmed 4.6.1+); and typed collections cannot be initialised with a ternary expression (bug #110628, open "up for grabs"). Both require falling back to untyped containers as a workaround.

---

## Per-Trap Entries

### 1. Lambda outer-variable capture is a value snapshot, not a live reference

**What compiles vs runtime:**
Compiles and runs without error. The lambda silently operates on a stale copy.

```gdscript
var x := 1
var f := func(): x += 1; return x
f.call()   # returns 2
print(x)   # prints 1 — outer x unchanged
x = 10
f.call()   # still returns 2, not 11
```

**Impact:** Any pattern relying on a lambda updating a shared counter, flag, or reference (e.g., dynamic signal teardown, accumulating results, tracking invocation count) will silently produce wrong results.

**Fix/Workaround:** Use the 1-element Array accumulator pattern (already in `feedback_gdscript_practices.md`): `var acc := [0]` and access `acc[0]` inside the lambda. Arrays are reference types and their contents *are* shared.

**Status:** Open, discussion-tagged, no assignee. Confirmed in 4.6.1 stable.

**Citation:** https://github.com/godotengine/godot/issues/117348 (opened Mar 12 2026)

---

### 2. Lambda capturing `self` leaks RefCounted (reference cycle)

**What compiles vs runtime:**
Compiles. No runtime error. Memory inspector shows accumulating orphaned objects and "Orphan StringName" warnings.

```gdscript
# LEAKS — lambda implicitly captures self
some_signal.connect(func(): print(self.name))
```

**Impact:** Every node that uses this pattern and is reloaded/freed leaks its own RefCounted wrapper. Accumulates across scene reloads.

**Fix/Workaround (three options, best to worst):**
1. Connect a named method: `some_signal.connect(_on_signal)` — no capture, no leak.
2. Capture a weakref: `var wr := weakref(self)` then `func(): if wr.get_ref(): ...` inside the lambda.
3. Store the lambda in a member var, call `disconnect()` in `_exit_tree()` — prevents orphan accumulation but requires discipline.

**Status:** Open, no assignee, no milestone. Overlaps with anonymous-lambda scene-reload duplication bug #94641 (connecting the same lambda twice on reload because each lambda expression creates a new non-equal Callable).

**Citations:**
- https://github.com/godotengine/godot/issues/102327 (RefCounted leak with self capture)
- https://github.com/godotengine/godot/issues/94641 (lambda connections multiply on scene reload)

---

### 3. Typed Dictionary nested `for` loop causes silent crash

**What compiles vs runtime:**
Type-checks pass, scene runs. Game window freezes and exits with no error in Output dock.

```gdscript
const DATA: Dictionary[StringName, Array] = { &"a": [1, 2], &"b": [3, 4] }
func _ready() -> void:
    for key in DATA:        # outer loop
        for val in DATA[key]:  # crashes silently here
            print(val)
```

**Impact:** Complete silent crash; no stack trace. Extremely hard to diagnose without knowing the cause.

**Fix/Workaround:** Remove the type annotation from the dictionary declaration (`var DATA := {...}` or `const DATA: Dictionary = {...}`). Untyped dictionaries iterate correctly.

**Status:** Closed as duplicate of #88753. Not fixed in 4.6.1 or 4.6.2. No milestone assigned. Confirmed affect 4.5.2 and 4.6.1.

**Citation:** https://github.com/godotengine/godot/issues/116947 (reported Mar 2 2026)

---

### 4. Typed Array/Dictionary cannot be initialised with a ternary expression

**What compiles vs runtime:**
Passes static analysis. Runtime error: `"Trying to assign a dictionary of type 'Dictionary' to a variable of type 'Dictionary[String, int]'."`.

```gdscript
var condition := true
var data: Dictionary[String, int] = {a: 1} if condition else {a: 2}  # runtime error
```

**Fix/Workaround:**
```gdscript
var data: Dictionary[String, int]
if condition:
    data = {a: 1}
else:
    data = {a: 2}
```

**Status:** Open, tagged "Up for grabs", affects 4.5+ including 4.6.

**Citation:** https://github.com/godotengine/godot/issues/110628 (opened Sep 2025, confirmed 4.6)

---

### 5. `weakref()` holds resources alive in tool scripts (4.6 regression)

**What compiles vs runtime:**
No error. Resource inspector shows the resource persisting and re-rendering even after it is set to `null` in the inspector.

**Impact:** Affects `@tool` scripts that use `weakref()` to track exported textures. Scene reloads fail to release the previous resource, and it continues to render.

**Status:** Open, tagged as regression vs 4.5.1, assigned to **milestone 4.7**. No backport to 4.6.x listed.

**Workaround:** Avoid `weakref()` in `@tool` exported-property trackers. Use a plain property with an explicit `_notification(NOTIFICATION_PREDELETE)` guard, or upgrade to 4.7 when stable.

**Citation:** https://github.com/godotengine/godot/issues/115448 (opened Jan 27 2026)

---

### 6. `await` on a signal whose emitter is `queue_free()`d causes hung coroutine + leak

**What compiles vs runtime:**
No compile error. At runtime, if the node emitting the awaited signal is freed before the signal fires, the coroutine suspends permanently. `GDScriptFunctionState` objects accumulate as orphans.

```gdscript
await some_node.animation_finished  # if some_node is freed first: hangs forever
```

**Impact:** Memory leak that grows with scene reloads; coroutine never resumes; no error emitted.

**Fix/Workaround:**
- Always check `is_instance_valid(node)` before awaiting a signal on it.
- Prefer `await get_tree().process_frame` as a single-frame yield rather than long-lived signal waits on externally-owned nodes.
- Use `CONNECT_ONE_SHOT` where possible — Godot auto-disconnects and the coroutine resumes correctly.

**Status:** Ongoing known issue; multiple related reports open (e.g., #99383, #72629, #74449). No comprehensive fix in 4.6.x.

**Citations:**
- https://github.com/godotengine/godot/issues/99383 (freed node + Tween/coroutine leak, affects 4.4+)
- https://github.com/godotengine/godot/issues/72629 (hanging await after free)

---

### 7. Freed-object lambda error message uses opaque index, not variable name

**What compiles vs runtime:**
Runtime error (not crash): `"Lambda capture at index 1 was freed. Passed 'null' instead."` — the index makes it hard to identify which variable was freed.

**Impact:** Debugging becomes trial-and-error when a lambda captures several objects. The error is also flagged as a hard error even when the programmer explicitly intends to handle null via `is_instance_valid()`.

**Status:** Open, tagged for team assessment. PR discussion proposes either (a) emit variable name in the message or (b) demote to warning. Fix PR #118552 is pending review as of Apr 2026.

**Workaround:** Guard lambdas that capture possibly-freed objects:
```gdscript
var captured_node := $Enemy
some_signal.connect(func():
    if not is_instance_valid(captured_node): return
    captured_node.take_damage(10)
)
```

**Citation:** https://github.com/godotengine/godot/issues/117840 (opened Mar 25 2026)

---

### 8. 4.6.3: Race condition in `RefCounted` and threaded signal emission (engine fix)

Concurrent signal emissions from `Thread` objects could corrupt reference counts and cause sporadic crashes. Fixed in 4.6.3 (May 19 2026). No GDScript API change required — just upgrade. Code using `ResourceLoader.load_threaded_*` or emitting signals from threads benefits automatically.

**Citation:** https://godotengine.org/article/maintenance-release-godot-4-6-3/

---

## GDScript-Language Proposals Worth Tracking (2026)

### Active / Open

| Proposal | ID | What it addresses | Status | Signal |
|---|---|---|---|---|
| **Await multiple signals** (`all()`/`any()` built-ins) | #13597 | Waiting for N signals simultaneously without custom helpers | Open, no assignee | High — common async pattern in game logic |
| **Unused signal warning inheritance** | #13951 | Warn when a child class inherits an abstract signal it never emits | Open, no assignee | Medium — useful for strategy/observer patterns |
| **Instantiable/disposable Signal type** | #8999 | Create one-off signal objects from code (not `@signal` declarations) | Open, long-running | Low — proposal stalled; no core dev engagement in 2026 |
| **Typed WeakRef** (`WeakRef[T]`) | #9174 | Syntactic sugar for typed weak references | Open, community discussion | Medium — relevant given #115448 weakref regression |
| **Show full warnings in script editor footer** | #13506 | Surface truncated warning text in editor footer bar | Open | Low — QoL, not a language change |

### Closed / Archived (Not Accepted)

**GDScript 3.0** (#12685) — namespaces, generics, class-based scripts. Closed "archived" June 2025; no core dev approval.

### 4.7-Beta Language Changes (not stable until late June 2026)

- **`UNTYPED_DECLARATION` warning** (opt-in): warns on functions missing `->` return type. Bug in 4.7.dev: warning highlights entire function body instead of declaration line (issue #118550, fix PR pending). Do not enable until fix ships.
- Static analyzer (unused vars, unreachable code) expanded in 4.6; default-on in strict projects.

---

## Key Takeaways for This Project

1. **Never mutate outer variables from inside a lambda** — use the `[value]` Array wrapper (already in memory file).
2. **Never connect a lambda that captures `self`** — use named methods or explicit `weakref()` guard.
3. **Avoid typed `Dictionary[K,V]` for nested loop iteration** — untype until #88753 is resolved.
4. **Await safety**: `is_instance_valid(node)` before awaiting signals on externally-owned nodes.
5. **4.6.3 upgrade is safe** — thread-safety fixes, no API changes, no known incompatibilities.
6. **Watch #13597** (await-multiple-signals) — if accepted, replaces custom timeout/any() helpers.

---

## Sources

- https://github.com/godotengine/godot/issues/117348
- https://github.com/godotengine/godot/issues/102327
- https://github.com/godotengine/godot/issues/94641
- https://github.com/godotengine/godot/issues/116947
- https://github.com/godotengine/godot/issues/110628
- https://github.com/godotengine/godot/issues/115448
- https://github.com/godotengine/godot/issues/117840
- https://github.com/godotengine/godot/issues/99383
- https://github.com/godotengine/godot/issues/72629
- https://github.com/godotengine/godot/issues/118550
- https://github.com/godotengine/godot-proposals/issues/13597
- https://github.com/godotengine/godot-proposals/issues/13951
- https://github.com/godotengine/godot-proposals/issues/8999
- https://github.com/godotengine/godot-proposals/issues/9174
- https://github.com/godotengine/godot-proposals/issues/12685
- https://godotengine.org/article/maintenance-release-godot-4-6-3/
