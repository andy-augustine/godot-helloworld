# GDScript Language Traps, Gotchas & Proposals
**Crawl date:** 2026-10-01
**Target window:** September 2026 onward (previous crawl: 2026-09-01)
**Godot stable:** 4.7.2 — 4.8 dev5 (September 2026, feature freeze imminent)
**Sources:** godotengine/godot issues, godotengine/godot-proposals, @vnen / @Ivorforce / @reduz

---

## TL;DR — Top 3 New Findings (September 2026)

1. **Untyped GDScript called from multiple threads can crash** — `OPCODE_OPERATOR` first-run cache has a race when a function is first called simultaneously from several threads; fix: declare typed operands or pre-warm on main thread (#124010, open crash, Sept 30 2026).

2. **Lambda closure capture is by-value for local variables** — `#117348` (labeled `documentation`, still open) confirms that outer *local* variables are snapshotted at lambda-creation time; the long-standing "all print 2" loop-variable trap is distinct and by-reference, making closure semantics context-dependent and confusing. The 1-element-Array workaround remains correct for mutable accumulators.

3. **`Dictionary[SpecificType, V]` does NOT satisfy `Dictionary[Variant, V]` in 4.8.dev5** — a regression tightened covariance rules; closed "not planned" suggesting it may become permanent. Never use `Dictionary[Variant, ...]` as a generic receive type for typed dictionaries.

---

## Per-Trap Entries

### Trap 1 — `:=` inference collapses to `Variant` on untyped return *(confirmed)*
| Compiles | Runtime |
|----------|---------|
| Yes (silently) | Loses type safety; downstream calls fail at runtime |

```gdscript
var cam := get_helper_result()   # helper returns Variant → cam is Variant
cam.some_method()                # runtime error
```
**Fix:** Annotate explicitly when RHS is untyped: `var cam: GameCamera = get_helper_result()`
**Status 4.7.2:** Unchanged. Intentional; fix requires annotation.

---

### Trap 2 — Lambda capture semantics are context-dependent *(updated Sept 2026)*
| Compiles | Runtime |
|----------|---------|
| Yes | Loop var: all lambdas see LAST value (by-ref). Local var reassigned after lambda: lambda keeps OLD value (by-value snapshot). |

```gdscript
# CASE A — loop variable: by-reference (classic trap)
for i in range(3):
    funcs.append(func(): print(i))   # prints 2, 2, 2

# CASE B — #117348: local var reassigned after lambda creation
var x = 1
var fn = func(): print(x); x += 1
fn.call()   # prints 1 (snapshot), then x inside lambda is 2
x = 10
fn.call()   # still prints 2 (NOT 10) — lambda has its own copy
```
**Fix:** Use 1-element Array for mutable accumulator closures:
```gdscript
var cell := [initial_value]
var fn = func(): cell[0] += 1
```
**Status 4.7.2:** #117348 open since March 2026, labeled `documentation` — no VM behavior change expected; the inconsistency is a known spec gap.

---

### Trap 3 — `await` is illegal / broken inside lambda bodies *(unchanged)*
| Compiles | Runtime |
|----------|---------|
| Some forms parse-error; some silently compile wrong | Coroutine never suspends the caller |

```gdscript
some_signal.connect(func(): await other_signal)  # does NOT work
```
**Fix:** Extract to a named function. Note: no top-level `await` in MCP-injected scripts either (same root cause).
**Status 4.7.2:** Unchanged. Closed as resolved in 4.1 (PR #74949) but async-in-lambda edge cases persist; verify against 4.7 if needed.

---

### Trap 4 — Untyped GDScript + multi-threading = crash *(NEW — #124010, Sept 2026)*
| Compiles | Runtime |
|----------|---------|
| Yes | Crash (heap access violation) when a function with untyped operands is first called simultaneously from multiple threads |

**Root cause:** `OPCODE_OPERATOR` first-run cache writes signature → then return type → then function pointer (no lock on read path). A second thread can read the new signature and dereference an uninitialized pointer.

```gdscript
# Danger: untyped operands + WorkerThreadPool
func compute(a, b):       # no type hints
    return a + b          # cached on first call; race if called from 8 threads simultaneously
```
**Fix (either):**
1. Declare typed parameters: `func compute(a: int, b: int) -> int:` — uses `OPCODE_OPERATOR_VALIDATED` which has no first-run cache
2. Pre-warm on main thread before handing to workers

**Status:** Open crash bug as of Sept 30 2026. Not in 4.7.2; may land in 4.8.
**Citation:** godotengine/godot #124010

---

### Trap 5 — Native `RefCounted` objects freed mid-method-call *(NEW — #122367, Aug 2026)*
| Compiles | Runtime |
|----------|---------|
| Yes | Crash (use-after-free) when a native GDExtension RefCounted removes its own last reference during a method call |

**Root cause:** GDScript VM keeps GDScript-originated temporaries alive until statement completion, but does NOT protect native `RefCounted` objects the same way. If the native object calls `set("self_ref", null)` internally, the object is freed while GDScript is still in the call.

**Workaround:** Store a strong reference in a local variable before the call chain:
```gdscript
var held_ref = potentially_self_deleting_obj   # keeps refcount +1 for duration
held_ref.method_that_might_delete_self()
```
**Status:** Open, Aug 13 2026. No fix in 4.7.2; complex — may require VM-level change.
**Citation:** godotengine/godot #122367

---

### Trap 6 — `Dictionary[T, V]` covariance tightened in 4.8.dev5 *(NEW — #123383)*
| Compiles | Runtime |
|----------|---------|
| Error in 4.8.dev5 (was OK in dev4) | N/A |

```gdscript
func get_map() -> Dictionary[MyEnum, String]: ...
func caller() -> Dictionary[Variant, String]:
    return get_map()   # ERROR in 4.8.dev5: cannot convert Dictionary[MyEnum, String]
```
**Fix:** Match key types exactly. Do not use `Dictionary[Variant, ...]` as a "generic" receive type for typed dictionaries. Use `Dictionary[MyEnum, String]` throughout or an untyped `Dictionary`.
**Status:** Closed "not planned" — behavior change is likely intentional as 4.8 feature freeze approaches.
**Citation:** godotengine/godot #123383

---

### Trap 7 — Self-referential typed `@export` Array causes shutdown resource leak *(NEW — #122601)*
| Compiles | Runtime |
|----------|---------|
| Yes | "1 resource still in use at exit" warning; may prevent clean shutdown in CI/headless runs |

```gdscript
# NavNode.gd — self-referential typed array
@export var connections: Array[NavNode] = []   # triggers leak
# Workaround:
@export var connections: Array[Node] = []      # use parent type
```
**Status:** Closed "not planned" in Aug 2026. Exact reproduction condition unknown; workaround: use a parent-class type.
**Citation:** godotengine/godot #122601

---

### Trap 8 — `Callable.bind()` reference lost for `disconnect()` *(confirmed unchanged)*
**Fix:** Store the bound Callable at connect time; reuse for disconnect. `my_func.bind(42)` creates a new Callable each call — equality fails.

---

### Trap 9 — Hot-reload leaves new typed members as `nil` on live instances *(known, fix in progress)*
New `var members: Dictionary = {}` added to a script during hot-reload appear as `nil` on already-live instances. PR #123040 adds a regression test and fix. **Workaround:** Stop and restart the scene after adding new typed builtin member declarations.
**Citation:** godotengine/godot #119057

---

### Trap 10 — String literals as multiline comments deprecated in 4.8 *(NEW behavior)*
PR #121833 (merged for 4.8) emits a `DEPRECATED` warning for standalone string literals used as comments (`""" ... """`). These will be **errors in Godot 5.x**. Use `##` doc comments instead.
**Action now:** Audit scripts for `"""..."""` blocks and replace with `## comment` lines.
**Citation:** godotengine/godot-proposals #15279 → godotengine/godot PR #121833

---

## GDScript Proposals — Active & Worth Tracking (Oct 2026)

| Proposal | Status | Impact |
|----------|--------|--------|
| **Nullable types** (`Vec2?` syntax) — proposals #162 | Open, "on hold", requires core feedback. PR #76843 exists. | HIGH — would eliminate `is_instance_valid()` boilerplate |
| **Structs / value types** — proposals #7329 | Open, active Sept 2026. No milestone. | MED — eliminates dict-as-compound-return pattern |
| **Callable type hints** (`Callable[[int], void]`) | Active design; @vnen owns. No milestone. | MED — catches signal handler mismatches at parse time |
| **GDScript annotation plugins** — proposals #14940 | Active; @Ivorforce. No milestone. | LOW immediate / HIGH tooling future |
| **Nonvirtual GDScript functions** — proposals #15491 | Open Sept 2026; performance gating behind project setting. | MED perf — enables inlining; relevance grows post-4.8 |
| **Typed Array `as`-cast** — godot #54311 | Open since 2021; still open Sept 2026. Use `Array[T](source)` constructor as workaround. | MED — typed array interop still rough |
| **Unified type system** — proposals #11489 | Closed "not planned" Sept 2026. | Archived |

---

## Watch List (re-scan monthly)

| Item | Where | Why |
|------|--------|-----|
| #124010 OPCODE_OPERATOR threading crash | godot issues | Fix expected before 4.8 stable; affects any project using WorkerThreadPool |
| 4.8 feature freeze / beta | godotengine.org/blog | GDScript property 1.6× speedup (dev4) + covariance rule changes (dev5) |
| Nullable types PR #76843 | godotengine/godot | If merged, changes `weakref` + optional-return patterns project-wide |
| `@static_unload` documentation | godot-docs | Underused; causes scene-reload state bugs |
