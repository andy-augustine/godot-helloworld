# Godot 4.6 Performance & Deployment — Research Notes
**Baseline:** Godot 4.6.2 (current stable, released 2026-04-01)
**Window:** Jan 2026 – May 2026
**Last updated:** 2026-05-01

---

## TL;DR — Top 3 Findings

1. **Canvas renderer had accidental write-combined memory reads (4.6.0/4.6.1) — directly hits 2D/Compatibility on Apple Silicon.** Reading from write-combined memory is extremely slow on discrete and Apple Silicon GPUs. Fixed in 4.6.2 (GH-115757). If you haven't upgraded, frame-time stalls in 2D draws will be mysterious and hard to attribute in the profiler.

2. **4.6.2 introduced a sky-shader regression (TIME variable breaks lighting), cherry-picked to 4.6.3.** Using `TIME` in a sky shader in 4.6.2 makes the scene go dark (GH-118110, #118317). Patch targeted for 4.6.3. If your project uses sky shaders with TIME, stay on 4.6.1 or wait for 4.6.3; otherwise 4.6.2 is the correct baseline.

3. **macOS ANGLE-on-Metal forced in VMs in 4.6.2 — load-bearing for CI export pipelines.** Previously, ANGLE init failure in a macOS VM (GitHub Actions, Parallels) silently degraded the renderer. Now it forces ANGLE. Windows gets the same fallback fix for AMD GPUs (GH-117253).

---

## Per-Finding Entries

### 1. Canvas Renderer Write-Combined Memory Reads (Frame Hog, Apple Silicon)

**Impact:** HIGH for 2D/Compatibility on Apple Silicon and discrete GPUs.
After GH-111183 in 4.6, `new_instance_data` returned a pointer into a GPU buffer mapping. The `|=` accumulation pattern then read from that pointer — catastrophically slow on write-combined memory regions. Apple M-series chips and discrete GPUs all exhibit this characteristic. Measured overhead: CPU performance dropped relative to 4.5.1. Fix returns an intermediary data pointer so future reads are never from WC memory. Minor regression on UMA (~200–300 µs/frame at 120k instances) is negligible for a 960×540 game.

**Recommended action:** Must be on 4.6.2. If you profiled your game on 4.6.0/4.6.1 and saw inexplicable CPU stalls in CanvasItem draw calls, rebaseline on 4.6.2. No project-level changes required.

**Citation:** GH-115757, merged 2026-02-02; cherry-picked to 4.6.2 (2026-03-06).
https://github.com/godotengine/godot/pull/115757 (accessed 2026-05-01)
https://godotengine.org/article/maintenance-release-godot-4-6-2/ (2026-04-01)

---

### 2. `TIME` in Sky Shader Breaks Lighting — 4.6.2 Regression

**Impact:** HIGH if you use animated sky shaders. Scene goes fully dark when `TIME` is sampled in the sky shader. Introduced by the interaction between the sky roughness layer fix (GH-116154, cherry-picked into 4.6.2) and how backing textures are allocated: 8 layers are allocated but the shader only fills 7; the final layer stays black, making fully rough objects receive black reflections. Fix (GH-118317) tracks fallback mode earlier and recreates backing textures on mode change.

**Recommended action:** For 2D GL Compatibility games without custom sky shaders this is a non-issue. If you do use a sky shader with `TIME`: pin to 4.6.1 or wait for 4.6.3 (cherry-pick confirmed by Repiteo on 2026-04-13).

**Citation:** GH-118110 (opened ~Apr 8, 2026, assigned 4.7); GH-118317 (fix, cherry-picked to 4.6.3); GH-116154 (root trigger, merged 4.7 then 4.6.2).
https://github.com/godotengine/godot/issues/118110 (accessed 2026-05-01)
https://github.com/godotengine/godot/pull/118317 (accessed 2026-05-01)

---

### 3. macOS ANGLE-on-Metal: VM Detection Forced in 4.6.2

**Impact:** HIGH for CI export pipelines; MEDIUM for general macOS development.
GL Compatibility renderer on macOS routes through ANGLE (OpenGL emulation over Metal). In 4.6.0/4.6.1, running inside a macOS VM (GitHub Actions, UTM/QEMU, Parallels) could crash or silently degrade at startup. GH-117371 detects the VM and forces ANGLE. Tested on macOS 15 VM, macOS 26 VM, and native macOS 26 — all pass. Requires ANGLE libraries compiled in; without them, expect an EGL library load error instead of a silent crash.

Companion fix GH-117253 addresses the same failure mode on Windows with AMD Radeon GPUs where ANGLE init fails (packHalf2x16/unpackHalf2x16 driver bug) — now falls back to next driver instead of hanging.

**Recommended action:** On 4.6.2 this is resolved automatically. If you set up a macOS CI runner for export verification, no extra flags are needed. Confirm ANGLE libraries are present in your export template.

**Citation:** GH-117371 (macOS VM forces ANGLE, merged 2026-03-14, cherry-picked 4.6.2); GH-117253 (Windows AMD ANGLE fallback, cherry-picked 4.6.2); GH-117184 (AMD packHalf2x16 issue).
https://github.com/godotengine/godot/pull/117371 (accessed 2026-05-01)
https://github.com/godotengine/godot/issues/117184 (accessed 2026-05-01)

---

### 4. Shader Material RAM Usage 6.5× Too High (4.6 launch, pre-stable fix)

**Impact:** HIGH if many shader materials; already fixed in 4.6.0-stable.
Between 4.6dev5 and dev6, the Vulkan driver stored full SPIR-V bytecode in RAM at all times instead of only when pipeline statistics profiling is active — ~6.5× expected footprint per shader material. Fixed in GH-115049 (merged 2026-01-19) by gating SPIR-V storage on `pipeline_statistics` flag. No action needed on 4.6.0-stable or later; documented to explain early-4.6 RAM complaints in forum threads.

**Citation:** GH-115032, GH-115049.
https://github.com/godotengine/godot/issues/115032 (accessed 2026-05-01)

---

### 5. GDScript Closures / Await + PackedArray Crash (4.7-dev, not 4.6.x)

**Impact:** LOW for 4.6.2 users; HIGH if evaluating 4.7 beta.
A 4.7-dev regression (introduced by GH-116711) crashes GDScript when a `PackedArray` variable appears between two `await` statements. Root cause: stack cleanup during coroutine unwinding triggers a `SafeRefCount` error. Fixed by reverting GH-116711 and landing GH-117053. Does NOT affect 4.6.x — milestone is 4.7 only.

Separate GDScript issue: type inference for inferred return values became stricter in 4.7.dev2 (GH-117081), breaking functions that return mixed types. Also 4.7-dev only.

**Recommended action:** None for 4.6.2. If testing on 4.7 beta, check your scripts for mixed-type returns and `await` + PackedArray patterns.

**Citation:** GH-117049 (PackedArray crash, 4.7 milestone); GH-117081 (return type inference, 4.7-dev2); GH-117053 (fix).
https://github.com/godotengine/godot/issues/117049 (accessed 2026-05-01)
https://github.com/godotengine/godot/issues/117081 (accessed 2026-05-01)

---

### 6. Tracy/Perfetto/Instruments Profiler Integration

**Impact:** MEDIUM for deep frame-budget work; no impact on shipped game performance.
Godot 4.6.0 added native tracing support (GH-113279): Tracy (cross-platform), Perfetto (Android), and Instruments (macOS/iOS). Enables profiling individual GDScript calls and Godot API calls at system level, not just inside the editor profiler. Requires a custom engine build with the tracing flag — not available in official export templates. **Coming in 4.7:** Tracy/Perfetto is automatic with no manual code annotations needed (build system integration) — noted in 4.7 beta 1 announcement.

**Recommended action:** For macOS/Apple Silicon debugging of frame spikes, Instruments integration in 4.6.0+ is worth a custom build when the editor profiler isn't granular enough. For routine development, the editor's built-in profiler is sufficient.

**Citation:** GH-113279 (4.6.0); 4.7 beta 1 announcement (2026-04-24/27).
https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627 (accessed 2026-05-01)
https://www.phoronix.com/news/Godot-4.7-Beta (accessed 2026-05-01)

---

### 7. Core Container Optimizations (4.6.0) — Indirect GDScript Benefit

**Impact:** LOW-MEDIUM — engine throughput, not GDScript bytecode speed.
`HashMap` fast-clear without zeroing (GH-108932), `Array::resize` avoids repeated copy-on-write (GH-110535), `Vector`/`CowData` `push_back`/`insert` avoids extra copy (GH-112630), `NodePath`-to-String caching (GH-110478), scene-tree group lookups (GH-108507). GDScript touches these structures constantly. No GDScript bytecode execution speed improvement was announced for 4.6 — interpreter overhead is unchanged. The `String` append performance fix (GH-90203, closed 2026-02-12) addresses quadratic-time behavior on very large string concatenation.

**Recommended action:** No action. Prefer `PackedStringArray` / `PackedFloat32Array` over plain GDScript arrays in tight inner loops; prefer `_physics_process` over polling signals.

**Citation:** CHANGELOG.md (4.6 section); GH-90203.
https://github.com/godotengine/godot/blob/master/CHANGELOG.md (accessed 2026-05-01)

---

### 8. Jolt Physics Energy Leak Fixed (4.6.2)

**Impact:** LOW for 2D; HIGH if/when 3D is added.
Elastic collision energy bug in Jolt caused dynamic bodies to gradually gain spurious velocity, wasting CPU on unnecessary recalculation and producing wrong gameplay behavior. Fixed in 4.6.2 (GH-115305 region). Kinematic rotation accuracy also improved.

**Recommended action:** Nothing for current 2D project. Use 4.6.2+ when 3D is introduced.

**Citation:** GH-115305; Godot 4.6.2 release notes (2026-04-01).
https://godotengine.org/article/maintenance-release-godot-4-6-2/ (2026-04-01)

---

### 9. NVIDIA RTX Godot Fork (GDC 2026, Experimental)

**Impact:** INFORMATIONAL only. NVIDIA's RTX/DLSS Godot fork (announced 2026-03-13) is not upstream. Irrelevant for GL Compatibility 2D work.

**Citation:** GameFromScratch.com, ~2026-03-13.

---

## 4.6-Specific Performance Regressions Summary

| Regression | Versions Affected | Status | Notes |
|---|---|---|---|
| Canvas renderer WC memory reads | 4.6.0, 4.6.1 | **Fixed in 4.6.2** (GH-115757) | Directly affects 2D/Compatibility on Apple Silicon |
| Sky shader / VoxelGI / SDFGI lighting broken | 4.6.0 | **Fixed in 4.6.1** (GH-116155 backport) | 3D/Forward+ only; 2D GL Compat unaffected |
| ReflectionProbe crash (dual probes) | 4.6.0 | **Fixed in 4.6.1** (GH-115284) | 3D only |
| Shader material 6.5× RAM spike | 4.6.dev6–rc1 | **Fixed before 4.6.0 stable** (GH-115049) | Documented here for forum-thread context |
| macOS ANGLE silent fallback in VMs | 4.6.0, 4.6.1 | **Fixed in 4.6.2** (GH-117371) | Affects CI/VM-based export testing |
| Windows AMD ANGLE init crash | 4.6.0, 4.6.1 | **Fixed in 4.6.2** (GH-117253) | AMD Radeon R-series driver packHalf2x16 |
| Sky shader TIME variable breaks lighting | **4.6.2** | **Targeted for 4.6.3** (GH-118317) | New regression introduced by GH-116154 backport |
| Animation use-after-free (AHashMap realloc) | 4.6.0 | **Fixed in 4.6.1** (GH-115931) | Non-deterministic crash during heavy animation |

**Net takeaway:** 4.6.2 is correct baseline except for projects using `TIME` in sky shaders — those need 4.6.3 when available, or pin to 4.6.1.

---

## Web / Mobile Caveats

- **Web export (4.6.x):** No GL Compatibility web export regressions landed in 4.6.x. The shader type-mismatch issue on WebGL 2.0 (GH-118684, GH-118927) affects **4.7-dev only** — mixed int/float implicit conversion that desktop drivers accept but WebGL 2.0 (strict GLSL ES 3.00) does not. Custom build template failures with Emscripten 5.0.0 are a known archived issue (GH-115979) with no 4.6.x fix confirmed. Web threading still requires `SharedArrayBuffer` + COOP/COEP server headers — unchanged in 4.6.
- **Mobile:** Android Vulkan crash rates improved dramatically in 4.6 via driver workarounds for Mali/Adreno. Android instrumented testing added. Native debug symbols ship with official Android templates. No changes in 4.6.2.
- **Apple Silicon (macOS desktop):** GL Compatibility via ANGLE-on-Metal confirmed production-stable in 4.6.2. WC-memory fix (GH-115757) and VM ANGLE fix (GH-117371) both directly apply.

---

*Sources: godotengine.org/releases/4.6, maintenance-release-godot-4-6-1, maintenance-release-godot-4-6-2, godot interactive changelog (4.6.2), godotengine/godot GitHub issues and PRs, phoronix.com Godot 4.7 beta, forum.godotengine.org 4.7 beta 1 thread, sourcemap.md (updated 2026-05-01 crawl).*
