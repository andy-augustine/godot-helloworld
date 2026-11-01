# GDScript Language Traps & Proposals
**Crawl date:** 2026-11-01  
**New-since window:** 2026-10-01 forward (confirmed 4.7.x / 4.8 beta 1 context)  
**Not re-discovered:** explicit types over `:=` for Variant returns, `String()` wrap before mixed-type ternaries, 1-element Array for lambda accumulators, no top-level `await` in MCP-injected scripts.

---

## TL;DR — Top 3 Findings

1. **Lambda + RefCounted self-connection = open memory leak in 4.7** (GH-102327). A `RefCounted` connecting a lambda that captures `self` to its own signal is still a live bug as of July 2026 comment. Workaround: use method references or capture `weakref(self)`.

2. **Lambda capture is by value; outer mutations are invisible inside** (GH-117348). GDScript capture-by-value is *intended*, but the error message when a captured object is later freed ("Lambda capture at index N was freed") is opaque — it gives an index, not a variable name, and fires before you can guard against it (GH-117840, 4.6.1, open).

3. **Ternary with metatypes picks the first branch type, not a common supertype** (GH-114877). `(SubA if cond else SubB).new()` infers `SubA`, not `Object`. Swapping branches changes the inferred type. This is unreliable; avoid class-value ternaries. Bug open, "Up for grabs".

---

## Traps & Gotchas

### T1 — Lambda + RefCounted self-signal = reference cycle leak
**Title:** Connecting a lambda that captures `self` keeps a `RefCounted` alive forever

**What compiles:** `my_signal.connect(func(): use(self))` — no error, no warning.  
**Runtime:** The `RefCounted` never reaches ref-count 0 because the lambda callable holds a strong reference back to `self`, forming a cycle. The leak-checker reports `RefCounted:<id>` entries, making the source hard to identify. Confirmed present in v4.3 → v4.7 (July 2026 comment).

**Fix/workaround:**
```gdscript
# Option A: named method (preferred, zero overhead)
my_signal.connect(_on_my_signal)

# Option B: weakref capture (keeps lambda syntax)
var weak_self := weakref(self)
my_signal.connect(func():
    var s = weak_self.get_ref()
    if s:
        s.use()
)
```
A connected method reference does NOT form a cycle. `weakref()` avoids the cycle but the callback must guard with `get_ref()` before use.

**Status:** Open. GH-102327, labeled `bug`, "Needs proposal." No PR linked. Engine maintainer AThousandShips considers it a "circular reference edge case"; a fix requires bookkeeping for `GDScriptLambdaCallable` lifetimes that does not exist yet.

**Citation:** https://github.com/godotengine/godot/issues/102327

---

### T2 — Lambda capture-by-value: outer reassignment invisible; freed capture = opaque error
**Title:** Outer variable reassignments after lambda creation are not seen inside; freed captures error with an index number

**What compiles:** Any lambda using an outer local variable — no error.  
**What surprises devs:** Reassigning the outer variable after the lambda is created does not change what the lambda sees. The lambda holds a snapshot of the value at creation time.

**Runtime:**  
- Reassigning the captured var inside the lambda does NOT update the outer var.  
- If the captured object is freed before the lambda is called, the engine raises:  
  `Lambda capture at index 1 was freed. Passed "null" instead.`  
  There is no way to check inside the lambda before this fires (GH-117840).

**Fix/workaround:**
```gdscript
# Use a reference type as a mutable container (already known pattern)
var acc := [initial_value]
some_signal.connect(func(): acc[0] += 1)

# For freed-capture: keep the lambda's object alive (or use a method ref)
# There is no guard syntax yet — file a PR for GH-117840 if this blocks you.
```
`CONFUSABLE_CAPTURE_REASSIGNMENT` warning fires when you reassign a captured var inside a lambda; no symmetric warning exists for the reverse direction.

**Status (docs):** PR #123675 adding clarification to lambda docs is open, "Fix pending review."  
**Status (error UX):** GH-117840 is open, labeled `enhancement`, "For team assessment." No fix or milestone.

**Citations:**  
- Capture by value / docs PR: https://github.com/godotengine/godot/issues/117348  
- Freed-capture UX: https://github.com/godotengine/godot/issues/117840

---

### T3 — Lambda connected to signal cannot be disconnected without a stored reference
**Title:** Anonymous lambda connections are not disconnectable after the fact

**What compiles:** `some_signal.connect(func(): ...)` — no warning.  
**Runtime:** The connection persists. There is no way to disconnect it later because you have no handle to the `Callable`. The lambda is not equal to a freshly created matching lambda.

**Fix:**
```gdscript
# Store the callable before connecting
var _cb := func(): _handle_event()
some_signal.connect(_cb)
# Later:
some_signal.disconnect(_cb)
```
This is a design pattern issue, not a bug. The pitfall hits when lambdas are wired inside `_ready()` on nodes that get re-used or re-added.

**Citation:** Forum thread "Do signal connections prevent RefCounted garbage collection?" — https://forum.godotengine.org/t/do-signal-connections-prevent-refcounted-garbage-collection/111346 (godotengine.org DNS blocked in this session; confirmed via search snippet)

---

### T4 — Ternary metatype inference picks first branch, not common supertype
**Title:** `(TypeA if cond else TypeB).new()` infers `TypeA`, not a shared parent type

**What compiles:** No error. GDScript accepts class-value ternaries.  
**Runtime:** The inferred type is whichever class appears first. Swapping branches silently changes the inferred type. When branches are unrelated (e.g. `Node2D`/`Node3D`), inference picks `Node`; for `Resource`/`Node`, it picks `Object`. dalexeev classifies this as a bug in the metatype compatibility check.

**Fix/workaround:**
```gdscript
# Avoid — picks SubA type even though SubB is also possible:
# var obj := (SubA if cond else SubB).new()

# Safe — explicit type:
var obj: ParentClass = (SubA if cond else SubB).new()
```
Ordinary instance ternaries (`SubA.new() if cond else SubB.new()`) do correctly produce an incompatibility warning.

**Status:** Open. GH-114877, labeled `bug`, "Up for grabs." No assignee or linked PR.

**Citation:** https://github.com/godotengine/godot/issues/114877

---

### T5 — `await` inside a lambda passed directly as a Callable argument (historical; fixed 4.1)
**Versions:** 4.0 betas; resolved in 4.1 by PR #74949.  
Storing the lambda in a variable before awaiting was the workaround. The pre-scan rule "no top-level `await` in MCP-injected scripts" addresses the surviving edge cases. No new activity found.

---

### T6 — Untyped arrays silently lose typed-instruction speedups
**Title:** Forgetting `Array[T]` (or `PackedXArray`) reverts iteration to Variant dispatch

Static typing gives GDScript specialized opcodes. An `Array` (untyped) iterates via Variant boxing on every element read/write; `Array[float]` avoids it; `PackedFloat32Array` is faster still. No new bugs here — but the 2026 community advice repeats this as the #1 performance gotcha missed after porting from 4.0 → 4.7.

**Fix:** Audit hot loops. Replace `var pts: Array` with `var pts: Array[Vector2]` or a packed array.

**Citation:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html

---

## GDScript Proposals — 2026 Status

godotengine.org was DNS-blocked in this session; direct proposal listing via MCP was also blocked (repo not in allow-list). The following status is from GitHub issue page fetches and web search.

| Proposal | Issue | Topic | 2026 status |
|---|---|---|---|
| Return-type inference (`->:` operator) | #8371 | `:=` symmetry for functions | Open; ~3 years old; no maintainer acceptance found |
| Cross-language async `Future` class | #8911 | `await` / coroutines across GDScript + GDExtension | Open; last substantive activity July 2024; no 2026 movement |
| GDScript generics for classes/functions | #13800 | Type system | Open; active 2026 community discussion; community fork exists; not accepted |
| Enforced static typing per-file | #7908 | Type checking | Open; no acceptance found |
| Lambda capture-by-reference (linked from T2) | #8558 | Lambda semantics | Open; language design question; no decision |

**Summary:** No GDScript language proposals were confirmed as accepted or implemented in the 2026 window searched. The type system, async/await, and lambda semantic improvements are all still in "discussed but not accepted" territory. The most actionable near-term 4.8 beta change to watch is symbol renaming (editor, not language); no GDScript VM or syntax changes noted in 4.8 beta 1 release metadata.

---

## 4.8 Beta 1 (Oct 15, 2026) — GDScript-Specific Notes

godotengine.org DNS was blocked. From sourcemap.md context only: 4.8 beta 1 features are symbol renaming (editor-level), multi-bounce AO, Trail3D, docked game view, AccessKit iOS/Android. **No GDScript language or VM changes were noted in the sourcemap summary.** Verify directly at https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/ when network access is available.

---

*Sources consulted: GH-102327, GH-117348, GH-117840, GH-114877, GH-68201, GH-93990, godot-proposals #8911 #8371 #13800 #7908, web search (github.com/godotengine, docs.godotengine.org). godotengine.org and forum.godotengine.org were DNS-blocked in this session.*
