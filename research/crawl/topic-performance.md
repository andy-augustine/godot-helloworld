# Godot Performance & Deployment — Research Notes
**Period:** Oct 2026 forward (4.7.x → 4.8 beta 1)  
**Project context:** macOS/Apple Silicon, GL Compatibility, 960×540, GDScript, no mobile target yet  
**Crawl date:** 2026-11-01  
**Note:** godotengine.org, docs.godotengine.org, and most third-party domains are blocked in this session's network policy. Facts below are sourced from search-result snippets and the few domains that resolved. Verify specifics directly when network access is available.

---

## TL;DR — Top 3 Findings

1. **Godot 4.8 beta 1 (Oct 15) cuts Object property access ~1.6× and saves ~12 MB runtime RAM.** Both are engine-side wins that land for free on any project upgrading from 4.7. Relevant to GDScript scripts that read/write node properties every frame (most 2D games).

2. **macOS export from a non-Mac host silently breaks the executable bit.** `.app` bundles exported from Windows (or Linux) lose the execute permission and will not run on macOS until the flag is restored. Universal 2 binaries, notarization via `rcodesign`, and Gatekeeper blocking are all active 4.7 concerns for this project when it eventually ships.

3. **Web export threading requires COOP/COEP headers; single-threaded fallback is significantly slower.** 4.7 added wasm64 as a new 64-bit WebAssembly target. SharedArrayBuffer remains required for threaded builds. For a future web port these header requirements are non-optional.

---

## Findings

### F1 — Godot 4.8: Object property access ~1.6× faster (engine-wide)
**Impact:** Medium-high for any GDScript that reads or writes node properties in `_process`/`_physics_process`. No code changes needed; the gain is automatic on upgrade.  
**Detail:** GH-122596 ("Accelerate Object property access 1.6×") and GH-122751 ("Save ~12 MB runtime RAM") both landed in 4.8 beta 1 (Oct 15, 2026). A third fix, GH-120942, speeds up removal of many child nodes at once. These are the most concrete engine-level performance numbers confirmed for the 4.7 → 4.8 cycle.  
**Recommended action:** Upgrade to 4.8 stable (expected Q4 2026) to receive these gains. No project-side changes required.  
**Citation:** Search snippet from Godot 4.8 beta 1 dev snapshot post (godotengine.org/article/dev-snapshot-godot-4-8-beta-1/, blocked in session; verified via search result excerpt).

---

### F2 — Godot 4.8: Non-allocating physics query methods (dev 7, Sep 29)
**Impact:** Low for this project now (single-character platformer, sparse physics queries). High if the project adds many enemies or projectiles that raycast every frame.  
**Detail:** Physics space-state classes gained new non-allocating query methods that reuse typed result objects instead of allocating fresh dictionaries/arrays per call. This directly eliminates per-query heap allocation and the GC pressure it causes. Shipped in 4.8 dev 7 (Sep 29, 2026); included in 4.8 beta 1.  
**Recommended action:** When the project's physics query count grows, prefer the new non-allocating APIs over the dictionary-returning equivalents.  
**Citation:** Search snippet from Godot 4.8 dev 7 coverage (godotengine.org/article/dev-snapshot-godot-4-8-dev-7/).

---

### F3 — macOS export: Universal binary, notarization, and executable-flag trap
**Impact:** High for shipping. Project currently targets macOS/Apple Silicon; export path must be validated before any external distribution.  
**Detail (Godot 4.7 docs):**
- Official export templates produce a "Universal 2" `.app` bundle (ARM + Intel in one binary). No separate ARM/Intel export needed.
- Notarization requires: (a) Apple Developer ID certificate, (b) `rcodesign` installed and configured in Editor Settings → Export → macOS, (c) Debugging entitlement **disabled**.
- After notarization, run `rcodesign staple` to attach the ticket.
- **Critical caveat:** `.app` bundles exported from Windows or Linux lose the executable flag. They will silently fail to run on macOS until the flag is restored (`chmod +x`) on a Mac or Linux machine.
- Without a Developer ID, ad-hoc signing is the fallback. Gatekeeper blocks ad-hoc or unsigned apps downloaded from the internet.
**Recommended action:** Export from macOS (already the case for this project). Configure `rcodesign` early. Disable Debugging entitlement in the export preset before distributing.  
**Citation:** Godot 4.7 macOS export docs (docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html, blocked; verified via search snippet).

---

### F4 — Web export: COOP/COEP required for threading; wasm64 now available in 4.7
**Impact:** Low now (no web target). Medium when a web port is attempted.  
**Detail:**
- wasm64 (64-bit WebAssembly) is new in Godot 4.7. It widens addressable memory for larger projects but requires a modern browser.
- Threaded builds still require `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` response headers. Without them, SharedArrayBuffer is unavailable and the export falls back to single-threaded mode, which is substantially slower.
- WebGL 2.0 is the only rendering backend for web (GL Compatibility). Older browsers or some iOS/macOS Safari versions may have partial support.
- Godot 4.x web exports on macOS/iOS had known issues with SharedArrayBuffer and WebGL 2.0 in older versions; check current status at ship time.
**Recommended action:** When adding a web target, configure the server (or CDN/itch.io) for COOP/COEP headers. Test threaded vs. single-threaded builds on target browsers.  
**Citation:** Godot web export docs snippets (multiple versions via search results); 4.7 release notes (sourcemap.md).

---

### F5 — GDScript performance: typed code faster; incremental gains each release
**Impact:** Low for this project currently; preventive guidance.  
**Detail:**
- Typed GDScript runs consistently faster than untyped code. The engine has shipped incremental interpreter and method-call optimizations in each 4.x release.
- A pending PR (godotengine/godot #70838) proposes a 40%+ speedup for typed opcode dispatch (benchmark: 5.76 ms → 3.31 ms). Merge status in 4.8 is unconfirmed.
- The primary bottleneck in typical 2D games is draw calls and scene/node complexity, not scripting speed.
- `Performance.TIME_PROCESS` is the recommended metric for script-side frame time. GPU frame time is reported as null/unsupported in some Godot 4.7 profiler environments.
**Recommended action:** Keep GDScript type annotations on all variables and function signatures. Profile with the built-in debugger before optimizing scripting logic; bottleneck is usually rendering.  
**Citation:** Godot benchmarks repo (github.com/godotengine/godot-benchmarks); search snippet from DEV Community 2026 profiling guide; strayspark.studio GDScript vs. C# post.

---

### F6 — 4.7 known regressions (performance / input)
**Impact:** Windows-only; not directly relevant to current macOS-only dev. Worth knowing for any future Windows packaging or Windows contributors.

| Issue | Symptom | Status |
|---|---|---|
| GH-109639 | High-polling-rate mouse on Windows degrades input performance | Patched in 4.7.2 RC1 (Aug 3, 2026) |
| GH-119872 | Polygon2D stale bounding-box culling after vertex edits (editor + runtime perf) | Fixed 4.7 beta 5 |
| 4.7.1 lighting regression | Flickering lighting on 3D scaled mesh instances (rendering perf/visual) | Fixed 4.7.1 (Jul 14, 2026) |

**No confirmed GL Compatibility 2D regressions on Apple Silicon in 4.7.** The ANGLE/Metal regression (Apple Silicon, 4.2) was fixed in 4.2.1 (reverted to native OpenGL). No recurrence found in 4.7 search results.  
**Citation:** sourcemap.md; linuxcompatible.org 4.7.1 snippet; godotengine.org 4.7.2 RC1 post.

---

### F7 — Refcount / leak patterns in GDScript (no new bugs found)
**Impact:** Background awareness only.  
**Detail:** No GDScript-native refcount leak bugs were found in 4.7 or 4.8 search results. The only refcount leak found in 2025-2026 results was in the godot-rust GDExtension bindings (not GDScript). The classical GDScript leak pattern remains: a `RefCounted` subclass that is stored in a `Callable` closure, a cyclic signal connection, or an unfreed child node. The engine's reference-counting frees objects as expected when no cyclic references exist.  
**Recommended action:** Disconnect signals in `_exit_tree` for nodes that reference `RefCounted` objects. Use `WeakRef` to break cycles. Run the editor's Memory debugger tab periodically during development.  
**Citation:** godot-rust PR #1302 (rust binding leak, not GDScript); godotengine.org migration guides.

---

## Version Guidance for This Project

| Current version | Recommendation |
|---|---|
| Godot 4.6.2 (project) | 4.7 stable (June 2026) is current stable. 4.7.1/4.7.2 are maintenance releases. Upgrade when stable for this project's schedule. |
| 4.8 stable | Expected Q4 2026 (imminent after Oct 15 beta 1 + feature freeze). Brings F1/F2 gains. No urgent reason to take beta risk for a 2D GL Compat project. |
| Migration | 4.6 → 4.7 guide required for: LinearToSRGB shader clamping change, CanvasItem line antialiasing feather removed (wider lines needed), `area_mask` audio default change, one-way collision API parameter addition. |

---

*Network note: godotengine.org, docs.godotengine.org, gamefromscratch.com, gamedevchronicles.com, dev.to, gamedev.net, and several others are blocked in this session. Facts are sourced from search-result excerpts only. Verify at docs.godotengine.org/en/4.7/ and the GitHub issue tracker when direct access is available.*
