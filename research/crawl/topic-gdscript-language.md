# GDScript Language — Traps, Gotchas, and Proposals
**Window:** July 2026 onward (engine baseline: 4.7.1 stable; 4.8-dev2 live)
**Crawled:** 2026-08-01 | Sources: godotengine/godot issues, godotengine/godot-proposals discussions

---

## TL;DR — Top 3 Findings

1. **`await` across freed objects hangs permanently in 4.7 (GH-120998).** In 4.6 the caller was released when the awaited object was freed; in 4.7 the coroutine is cancelled but the caller blocks forever. Any pattern that awaits a method on a node that may be `queue_free`'d is now a silent deadlock.

2. **`await` + inheritance causes "Compiler bug: Unresolved return" spam in 4.7.0 and 4.7.1 (GH-121584).** Overriding a typed-return parent method with an untyped override that does `return await untyped_call()` triggers an error print on every script load; non-fatal but breaks GUT mock generation.

3. **GH-102327 (lambda-captures-self signal leak on RefCounted) is still OPEN.** Last updated July 5, 2026; no fix landed in 4.7. The prior workaround (disconnect before free, or use weakref) remains the only defence.

---

## Per-Trap Entries

### TRAP-1: `await` caller hangs when awaited object is freed (4.7 regression)

**What compiles vs runtime:**
Compiles without error. At runtime, if Object A awaits a coroutine owned by Object B, and B is `queue_free`'d while the coroutine is mid-flight, the coroutine is cancelled (correct) but A's `await` expression never resumes. A hangs indefinitely — no error, no timeout.

**Was not broken in 4.6.** The change in 4.7 altered how cancelled coroutines propagate cancellation to their awaiting callers.

```gdscript
# event.gd — hangs forever in 4.7 if character is freed while running go_to()
func do_event() -> void:
    await character.go_to(target)   # <-- never resumes if character.queue_free() fires
    next.do_event()
```

**Fix / workaround:**
- Add a validity guard after every cross-object `await`:
  ```gdscript
  await character.go_to(target)
  if not is_instance_valid(character):
      return
  ```
- Prefer signal-based notification over coroutine return values across object boundaries.
- If you own the coroutine target, emit a "cancelled" signal before freeing so callers can
  `await` that signal and bail cleanly.

**Citation:** https://github.com/godotengine/godot/issues/120998 (opened 2026-07-06, open/unfixed as of 2026-08-01, confirmed 4.7 regression)

---

### TRAP-2: `await` + untyped return override silently errors on script load (4.7.0/4.7.1)

**What compiles vs runtime:**
Compiles and runs correctly, but every script load prints `ERROR: Compiler bug: Unresolved return.` to the console. The code path that triggers it is:

1. Parent class declares a method with an explicit `-> SomeType` return hint.
2. Child class overrides that method with *no* return type annotation.
3. The override's body is `return await some_untyped_call()`.

```gdscript
# parent.gd
func fetch() -> bool:
    await get_tree().process_frame
    return true

# child.gd — triggers "Compiler bug: Unresolved return" on load in 4.7
func fetch():
    return await this_returns_whatever()   # untyped return
```

The compiler enters a fallback branch that should be unreachable (`gdscript_byte_codegen.cpp:1846`). Affects GUT/GdUnit4 when generating doubles of classes that have `await`-containing typed methods.

**Fix / workaround:**
- Always annotate the return type on overrides: `func fetch() -> bool:`.
- In tests: if GUT generates a double that triggers this, add an explicit return-type hint to the method under test, or suppress the console error in CI.

**Citation:** https://github.com/godotengine/godot/issues/121584 (opened 2026-07-20, confirmed regression, open as of 2026-08-01)

---

### TRAP-3: Lambda captures `self`, connected to signal on RefCounted — permanent leak (GH-102327)

**What compiles vs runtime:**
No error, no warning. The RefCounted instance is kept alive indefinitely because the connected lambda holds a strong reference to `self`, which holds the signal, which holds the lambda — a reference cycle that the engine's RefCounted free-tracking cannot break.

```gdscript
# Inside a RefCounted subclass — leaks
my_signal.connect(func(): do_something())   # lambda implicitly captures self
```

**Status update:** Still OPEN as of July 5, 2026 (last activity). No fix in 4.7.

**Fix / workaround (unchanged from prior crawl):**
- Use `Callable(self, &"method_name")` for signal connections that should not prolong lifetime.
- Disconnect in `_notification(NOTIFICATION_PREDELETE)` before the object would normally free.
- For fire-and-forget one-shots: `.connect(func(): …, CONNECT_ONE_SHOT)` reduces but does not eliminate the window.

**Citation:** https://github.com/godotengine/godot/issues/102327 (opened 2025-02-02, confirmed open 2026-07-05)

---

### TRAP-4: `class_name` script silently rejected as autoload (usability trap)

**What compiles vs runtime:**
Attempting to add a GDScript file that contains a `class_name` declaration as a Project > AutoLoad entry fails with a generic, unhelpful error rather than a message explaining the conflict. The script appears valid and compiles fine standalone.

**Fix / workaround:**
Remove `class_name` from scripts intended to be used as autoloads, or use a wrapper script without `class_name` that instantiates the class.

**Citation:** https://github.com/godotengine/godot/issues/121744 (opened 2026-07-25, open/needs-testing as of 2026-08-01)

---

### TRAP-5: `UNTYPED_DECLARATION` fires twice for rest parameters (4.8-dev, fixed)

**What compiles vs runtime:**
In 4.8-dev builds, a variadic function using the `...args` rest-parameter syntax produces the `UNTYPED_DECLARATION` warning twice for the same parameter. Not a runtime trap — a warning-noise issue. Already fixed (issue closed).

```gdscript
func my_func(..._args) -> void:  # two identical UNTYPED_DECLARATION warnings in 4.8-dev
    pass
```

**Status:** Fixed, closed 2026-07-27.

**Note:** The `...args` variadic syntax itself is a new GDScript feature; if you use it, annotate the type to silence the warning.

**Citation:** https://github.com/godotengine/godot/issues/121838 (opened and closed 2026-07-27)

---

### TRAP-6: String literals used as block comments — deprecation coming

**What compiles vs runtime:**
Currently silent — no warning. GDScript has long tolerated bare string literals as a pseudo-block-comment idiom (borrowed from Python):

```gdscript
"""
This is treated as a comment-like expression.
No warning currently.
"""
```

Proposal #15279 (July 28, 2026) proposes adding a `STANDALONE_EXPRESSION` warning for string literals in 4.x and forbidding them entirely in 5.x. No label indicating acceptance yet, but maintainer sentiment has been cited as supportive.

**Fix / workaround:** Switch to `#`-prefixed line comments now. Do not rely on string literals as block comments in production scripts.

**Citation:** https://github.com/godotengine/godot-proposals/issues/15279 (opened 2026-07-28, open)

---

## Summary of Accepted / In-Progress GDScript Proposals

| # | Title | State (Aug 2026) | Notes |
|---|-------|-----------------|-------|
| [#15279](https://github.com/godotengine/godot-proposals/issues/15279) | Phase out string literals as multiline comments | Open | Warn in 4.x, forbid in 5.x; maintainer support evident |
| [#14652](https://github.com/godotengine/godot-proposals/issues/14652) | Migrate GDScript to GDExtension ("GDScript 3.0") | Open (breaks-compat) | Godot 5.0 target; author is @dalexeev; eliminates scripts-as-resources, `preload()`, runtime script attachment; `static` var initializers may be forbidden |
| [#12639](https://github.com/godotengine/godot-proposals/issues/12639) | Add `@static` annotation to GDScript | Open | Preferred style over keyword `static`, aligning with `@abstract` direction |
| [#1207](https://github.com/godotengine/godot-proposals/issues/1207) | Generic parameters / typed collections (`Array[T[U]]`) | Open | Still unimplemented; active discussion July 2026 |
| [#4872](https://github.com/godotengine/godot-proposals/issues/4872) | Allow explicitly defining interfaces in GDScript | Open | Duck-typing alternative; no PR yet |
| [#14487](https://github.com/godotengine/godot-proposals/issues/14487) | Don't suggest abstract classes in autocompletion | Open | Labelled "implementer wanted"; low-effort UX fix |
| [#15144](https://github.com/godotengine/godot-proposals/issues/15144) | Forbid scripts inheriting their own inner classes | Closed (archived) | Rejected July 24; pattern is legal but acknowledged as confusing |
| [#15139](https://github.com/godotengine/godot-proposals/issues/15139) | Allow narrowing type overrides in child classes | Closed (archived) | Rejected July 7; workaround: shadow property with getter |

**Unconfirmed status (sourcemap-listed, not found active in July 2026 window):**
- Trait system (#12567), typed Callables (#9286), unified type system (#11489), strict mode (#6677) — all remain open but saw no substantial activity in July 2026. Check @vnen (George Marques) commit feed for any movement.

---

## 4.7 GDScript Surface Changes to Know

- **Variadic / rest-parameter syntax** (`func f(...args)`) is now supported. Annotate the type to avoid the `UNTYPED_DECLARATION` warning.
- **`abstract` keyword** (4.5+) is considered stable in 4.7; GUT 9.7.0 added stricter return-type-aware doubling to accommodate.
- **Coroutine cancellation changed** (see TRAP-1): freed-object handling of in-flight coroutines is different from 4.6.

---

*Crawled by research agent. Engine baseline: 4.7.1 stable. Primary sources: GitHub issues and proposals.*
