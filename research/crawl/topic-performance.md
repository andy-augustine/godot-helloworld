# Godot 4.6 Performance & Deployment — Research Notes
**Baseline:** Godot 4.6.2 (current stable, ~2026-04-01)
**Window:** Jan 2026 – Apr 2026
**Last updated:** 2026-04-26

---

## TL;DR — Top 3 Findings

1. **GL Compatibility on macOS gets a critical ANGLE/Metal fix in 4.6.2.** Running under a VM (and some real hardware) could silently fall back to a broken driver path; 4.6.2 forces ANGLE (GL over Metal) in those cases. Confirm you are on 4.6.2 before shipping any macOS build.

2. **Canvas renderer had accidental write-combined memory reads (4.6.0/4.6.1).** This is a silent frame-budget killer on Apple Silicon — write-combined memory is fast to write but extremely slow to read. Fixed in 4.6.2 (GH-115757). Upgrade immediately if you have not.

3. **4.6.0 launched with a sky-shader/VoxelGI regression and a ReflectionProbe crash.** Neither affects a 2D GL Compatibility project directly, but they confirm that 4.6.0 and 4.6.1 should be treated as stepping stones — 4.6.2 is the only stable 4.6 target for production work.

---

## Per-Finding Entries

### 1. Canvas Renderer Write-Combined Memory Reads (Silent Frame Hog)

**Impact:** HIGH for 2D/Compatibility projects on Apple Silicon.
Write-combined (WC) memory regions are write-only by design on Apple Silicon; reading from them causes extreme stalls. The 2D canvas renderer was accidentally reading from WC memory in 4.6.0 and 4.6.1, causing unexplained frame-time spikes that would not show up as obvious CPU or GPU load in basic profiling.

**Recommended action:** Upgrade to 4.6.2 (minimum). If profiling a 960×540 scene and you see inexplicable CPU stalls on draw calls, this is the likely culprit if you are still on 4.6.0/4.6.1. No GDScript or scene changes needed — the fix is engine-side.

**Citation:** GH-115757, Godot 4.6.2 release notes — "Fix accidental write-combined memory reads in canvas renderer."
Source: https://godotengine.org/article/maintenance-release-godot-4-6-2/

---

### 2. macOS ANGLE-on-Metal Forced in VMs (4.6.2)

**Impact:** HIGH for macOS export / CI pipeline.
The GL Compatibility renderer on macOS routes through ANGLE (GL emulation over Metal). In 4.6.0/4.6.1, running inside a VM (GitHub Actions macOS runners, Parallels, etc.) could cause ANGLE init to fail and fall back silently, producing a broken or degraded renderer. 4.6.2 detects this and forces ANGLE. A companion fix sets the current driver correctly when ANGLE init fails on Windows too.

**Recommended action:** Verify export testing runs on Godot 4.6.2. If you run CI or build-verification in a macOS VM, this fix is load-bearing. No project settings change required.

**Citation:** GH-117371 (macOS: force ANGLE when running in VM), GH-117253 (Windows: set current driver when ANGLE init fails).
Source: https://godotengine.org/article/maintenance-release-godot-4-6-2/

---

### 3. 2D Batching and Rendering Pipeline Speed-Ups (4.6.0)

**Impact:** MEDIUM — throughput improvement for sprite-heavy 2D scenes.
The 2D renderer received batching improvements described by GDQuest as "faster" in their 4.6 workflow guide. This is on top of the canvas renderer WC-read bug (finding #1), which means post-4.6.2 the cumulative 2D rendering speed improvement versus 4.5.x is meaningful. No explicit benchmark numbers were published.

**Recommended action:** No action needed — baked into the engine. Useful to know when evaluating whether to increase draw complexity (more enemies, particles, background tiles) in the 960×540 viewport. Profile with the built-in profiler after upgrading to 4.6.2 to establish a baseline.

**Citation:** GDQuest "Godot 4.6 Workflow Changes" library page; Godot 4.6 release highlights.
Source: https://www.gdquest.com/library/godot_4_6_workflow_changes/

---

### 4. Tracy / Perfetto / Instruments Tracing Support Added (4.6.0)

**Impact:** MEDIUM — new capability for native-level profiling.
Godot 4.6.0 added memory profiling macros and tracing support for dedicated profilers: Tracy (cross-platform frame profiler), Perfetto (Android), and Instruments (macOS/iOS). This allows profiling GDScript function calls and Godot API calls at system level rather than just within the editor's built-in profiler. Perfetto support is specifically called out in the April 2026 Mobile update article for Android crash-rate investigation.

**Recommended action:** For macOS development on Apple Silicon, Instruments integration is now first-class. Use it when the editor profiler does not have enough resolution to isolate a frame spike. Requires a custom engine build with the tracing option enabled — not available in official export templates. Good to know for deep-dive debugging; not needed for routine development.

**Citation:** GH-113279 (C++ tracing profilers: Tracy, Perfetto, Instruments), GH-112702 (memory profiling macros for Tracy).
Source: https://godotengine.org/releases/4.6/; https://godotengine.org/article/godot-mobile-update-apr-2026/

---

### 5. Core Container Optimizations (4.6.0) — GDScript Indirect Benefit

**Impact:** LOW-MEDIUM — engine-side throughput, not GDScript bytecode speed.
A cluster of 4.6.0 changes optimize fundamental engine containers used constantly at runtime: `HashMap` fast clear without zeroing (GH-108932), `HashSet::clear` cleanup (GH-108698), scene-tree group lookups (GH-108507), `Array::resize` avoids repeated copy-on-write (GH-110535), `Vector`/`CowData` `push_back`/`insert` avoids extra copy (GH-112630), and `NodePath`-to-String caching (GH-110478). GDScript benefits indirectly because these are the structures it touches on every frame (groups, node lookup, array manipulation).

No GDScript bytecode execution speed improvement was announced for 4.6. The GDScript static analyzer was expanded (full closure/lambda support) but that is a correctness feature, not a runtime speed feature.

**Recommended action:** None required. Be aware that GDScript call overhead is unchanged at the interpreter level — still budget-conscious for tight inner loops. Prefer `_physics_process` over polling signals in performance-critical code.

**Citation:** CHANGELOG.md (Godot 4.6 section), GH-108507, GH-108932, GH-110535, GH-112630.
Source: https://github.com/godotengine/godot/blob/master/CHANGELOG.md

---

### 6. Delta-Encoded Patch PCKs (4.6.0)

**Impact:** LOW for desktop-only; relevant if you ever ship web or Steam updates.
Export now supports delta-encoded patch PCKs (GH-112011): patch files include only changed bytes within resources rather than entire files. For a small 2D game this mainly matters if you iterate frequently over a slow connection or via Steam depot. On macOS desktop it reduces patch download size.

**Recommended action:** No immediate action for local development. Keep in mind when setting up a Steam/itch.io distribution pipeline — the export preset gains a delta-patch option worth enabling.

**Citation:** GH-112011.
Source: https://godotengine.org/releases/4.6/

---

### 7. Jolt Physics Energy Leak Fixed (4.6.2)

**Impact:** LOW for 2D projects; HIGH if you ever add 3D.
Jolt Physics had an energy-increase bug on elastic collisions (gravity applied incorrectly to dynamic bodies), causing objects to gradually gain spurious velocity — a subtle simulation error that would waste CPU cycles on unnecessary physics recalculation over time and produce wrong gameplay behavior.

**Recommended action:** No action for a 2D-only project. File this for when 3D is added. Use 4.6.2+.

**Citation:** GH-115305.
Source: https://godotengine.org/article/maintenance-release-godot-4-6-2/

---

### 8. 3D Texture Import Up to 2× Faster (4.6.0)

**Impact:** LOW at runtime; HIGH for iteration speed during development.
GPU-based RGB-to-RGBA conversion during import makes 3D texture reimport up to 2× faster (GH-110060). No runtime rendering performance change — this is an editor/import-time improvement. Relevant if you add 3D elements later.

**Recommended action:** None for current 2D project. Noted for future reference.

**Citation:** GH-110060.
Source: https://godotengine.org/releases/4.6/

---

## 4.6-Specific Performance Regressions Reported

| Regression | Versions affected | Status in 4.6.2 | Notes |
|---|---|---|---|
| Sky shader / VoxelGI / SDFGI lighting broken | 4.6.0 | Fixed in 4.6.1 | Issue #115599. 3D/Forward+ only; does not affect GL Compatibility 2D. |
| ReflectionProbe crash | 4.6.0 | Fixed in 4.6.1 | Issue #115284. 3D only. |
| Canvas renderer WC memory reads | 4.6.0, 4.6.1 | Fixed in 4.6.2 | GH-115757. **Directly affects 2D/Compatibility on Apple Silicon.** |
| ANGLE init silent fallback on macOS | 4.6.0, 4.6.1 | Fixed in 4.6.2 | GH-117371. Affects VM-based CI and some hardware configs. |
| Viewport debanding broken with spatial scalers | 4.6.0, 4.6.1 | Fixed in 4.6.2 | GH-114890. Visual quality regression, not a perf regression per se. |
| Animation use-after-free (AHashMap realloc) | 4.6.0 | Fixed in 4.6.1 | GH-115931. Could cause non-deterministic crashes during heavy animation playback. |

**Summary:** 4.6.2 resolves all known regressions relevant to this project. Do not ship on 4.6.0 or 4.6.1.

---

## Web / Mobile Caveats (for future reference)

- **Web export:** No specific GL Compatibility web export regressions found in 4.6.x. Web threading still requires `SharedArrayBuffer` (requires COOP/COEP headers on server). No changes to this requirement in 4.6.
- **Mobile:** Android Vulkan crash rates dramatically improved in 4.6 via driver workarounds for Mali and Adreno GPUs. iOS export logic now auto-prevents shipping incompatible builds. Android instrumented testing added. Native debug symbols now shipped with official Android templates.
- **Apple Silicon (macOS desktop):** GL Compatibility via ANGLE-on-Metal is the correct renderer. Confirmed production-stable in 4.6.2. The WC memory read fix (GH-115757) is specifically relevant here.

---

*Sources: godotengine.org/releases/4.6, maintenance-release-godot-4-6-1, maintenance-release-godot-4-6-2, gdquest.com Godot 4.6 Workflow Changes, godot-mobile-update-apr-2026, godotengine/godot CHANGELOG.md, sourcemap.md (2026-04-26 crawl).*
