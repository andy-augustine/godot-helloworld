# Godot 4.6/4.7 Performance & Deployment — Intel Report
*Window: Jan 2026 – Jul 2026 | Generated: 2026-07-01*
*Project context: Godot 4.6.2, macOS Apple Silicon, GL Compatibility renderer, 960×540 2D platformer*

---

## TL;DR — Top 3 Findings

1. **Godot 4.6 shipped a major 2D batching upgrade** (Compatibility renderer) yielding 1.1×–7× GPU speedups in sprite-heavy scenes. This project is already on the right renderer to benefit. Typed GDScript also got 5–150% speedups via compile-time bytecode optimisation (most pronounced on Vector2 ops, ~59% faster).

2. **A Metal/Vulkan performance regression exists on Apple Silicon (M1+), open since 4.4** (GitHub #103723). The GL Compatibility renderer (GLES3/OpenGL) does not use the Metal backend and is therefore **not affected** by this specific regression. However, separate GPU-particle crash bugs on Compatibility + Apple Silicon have been reported (see #72469 — test before using GPUParticles).

3. **Upgrading from 4.6.2 to 4.7 is safe for most 2D projects** but has known breaking changes (audio spectrum API, BlendSpace internals, keyboard device IDs, shader preprocessor tightening). A first-export slowness bug on Apple Silicon (15+ min on M3, issue #115062) was reported against 4.6rc1 but has no confirmed fix; the workaround is to restart the machine before the first export run.

---

## Findings

### F1 — GDScript typed bytecode: 5–150% runtime speedup (4.6+)

**Impact:** Medium-high for game logic. All GDScript code with explicit type annotations benefits at runtime, not just at compile time. Vector2 attribute access and similar hot paths run ~59% faster than untyped equivalent. The gains are highest for pre-validated native function calls and lowest for simple attribute lookups.

**Recommended action:** Annotate all function parameters and return types in hot paths (`_physics_process`, `_process`, signal handlers). Use `@static_unload` on rarely-used static classes to avoid refcount overhead. The built-in profiler's "Script Functions" tab shows per-function time; for sub-millisecond resolution on macOS, use Apple Instruments (new in Godot 4.6 — no custom build required).

**Caveat:** C# projects still outperform GDScript by a wide margin for CPU-bound code; for a 2D platformer GDScript is sufficient if typed.

**Citations:**
- GDScript typed instructions article: https://godotengine.org/article/gdscript-progress-report-typed-instructions/
- GDScript vs C# comparison 2026: https://www.strayspark.studio/blog/gdscript-vs-csharp-godot-2026-choosing-scripting-language

---

### F2 — 2D Compatibility renderer batching overhaul (4.5/4.6)

**Impact:** High for sprite-heavy 2D scenes. The CanvasRenderRD batching work (PR #92797) reduced drawcall overhead for scenes with many similar sprites. Search-reported range is 1.1×–7× GPU speedup depending on scene; the gains require sprites to share the same texture atlas, material, blend mode, and Z-index.

**Recommended action:** Group scene-tree nodes by shared texture atlas. Use a single TileSet atlas rather than per-tile textures. Avoid mixing blend modes or materials mid-batch. Use the Rendering / Wireframe debug overlay to verify draw-call counts.

**Project-specific note:** The project uses GL Compatibility (GLES3) which has had batching the longest. Forward+ and Mobile renderers got RD-based batching more recently but that is irrelevant here.

**Citations:**
- Godot 4.6 release page: https://godotengine.org/releases/4.6/
- PR #92797 (batching for RendererCanvasRenderRD): https://github.com/godotengine/godot/pull/92797

---

### F3 — Metal backend regression on Apple Silicon (4.4+, still open)

**Impact:** Medium for this project (mitigated by renderer choice). The Metal rendering backend introduced in Godot 4.4 regressed FPS on M1 Macs compared to the prior Vulkan/MoltenVK path — a MacBook Air M1 dropped from ~54 FPS (4.3) to 43–50 FPS (4.4+) in one documented test (GitHub #103723). Metal stutters badly when render targets enter/exit view.

**This project's exposure:** GL Compatibility renderer uses OpenGL/ANGLE, NOT the Metal backend. This regression does not apply. However, if you ever switch renderer or test Forward+, expect this issue.

**Additional macOS rendering bug:** UI scaling issues in embedded game mode with the Metal renderer (issue #116120, filed in early 2026, no confirmed fix).

**Recommended action:** Stay on GL Compatibility for this project. If profiling shows GPU time is unexpectedly high, verify via Activity Monitor that the process is hitting OpenGL, not Metal.

**Citations:**
- GitHub #103723: https://github.com/godotengine/godot/issues/103723
- GitHub #116120: https://github.com/godotengine/godot/issues/116120

---

### F4 — New profiler integrations in Godot 4.6: Tracy, Perfetto, Apple Instruments

**Impact:** High for debugging real-world frame spikes. Godot 4.6 added first-party support for external tracing profilers without a custom engine build: Tracy, Perfetto, and Apple Instruments. These give microsecond-resolution flame graphs — particularly useful when the bottleneck is in the renderer or physics step rather than user scripts.

**Recommended action for this project (macOS Apple Silicon):**
- Use Apple Instruments → "CPU Profiler" template against the Godot process for low-overhead flame graphs.
- Use the built-in Visual Profiler (now with tree folding in 4.7, backport unknown) for GPU timing.
- The "Audio Thread" section of the profiler is **collapsed by default** — check it; audio spikes of 0.5ms→12ms from simultaneous AudioStreamPlayer calls have been documented in 4.6.2 projects.

**Citations:**
- Godot 4.6 dev 6 (Tracy integration): https://www.linuxcompatible.org/story/godot-46-dev-6-released/
- Tracy docs (stable): https://docs.godotengine.org/en/stable/engine_details/development/profiling/tracy.html

---

### F5 — Audio thread spikes causing frame drops in Godot 4.6.2

**Impact:** Medium. Documented in 2D Godot 4.6.2 projects: simultaneous AudioStreamPlayer nodes triggering in the same frame cause audio thread time spikes (0.5ms → 12ms). Combined with a physics tick, this can push a frame past the 16.67ms budget at 60 FPS.

**Recommended action:**
- Reduce Project Settings → Audio → Max Voices from default 32 to 16 or lower.
- Add a 50ms cooldown between repeated sound triggers (e.g. footstep sounds on landing).
- Use AudioStreamPlayer's "Bus" property to route sounds; don't create new AudioStreamPlayer nodes at runtime — reuse pooled nodes.

**GitHub reference:** AudioStreamPlayer process time spike: https://github.com/godotengine/godot/issues/84157

---

### F6 — macOS first-export slowness bug (4.6rc1, Apple Silicon)

**Impact:** Low (DX only, not runtime). First export on macOS 15.x on M3 MacBook Air can take 15+ minutes (subsequent exports are fast). Reported against 4.6rc1 (GitHub #115062). No confirmed root cause or fix as of the research date; the issue is tagged for assessment with no assigned developer.

**Recommended action:** Restart the machine before the first export run. If the issue persists on 4.6.2, check macOS Gatekeeper activity via `log stream --predicate 'process == "Godot"'` during the export to see if notarization lookups are blocking.

**Citation:** GitHub #115062: https://github.com/godotengine/godot/issues/115062

---

### F7 — Web export: Compatibility-only, COOP/COEP required for threads

**Impact:** Relevant if web export is added later. Web export uses GL Compatibility renderer only (Forward+ and Mobile not supported). Multithreaded WASM requires `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` HTTP headers. Missing headers cause a black screen or silent fallback to single-threaded mode.

WASM heap is not desktop RAM: avoid importing desktop-memory habits. Run 60-minute scripted sessions in Chrome DevTools Memory tab before releasing a web build.

**Recommended action:** Not urgent for this macOS-only project now; note when adding web export target. itch.io has a checkbox to enable SharedArrayBuffer/COOP headers.

**Citations:**
- Web export docs (stable): https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- WASM memory ceiling post: https://gamineai.com/blog/godot-4-5-web-export-wasm-memory-ceiling-h2-2026-browser-demo-trend-playbook

---

### F8 — Godot 4.7 breaking changes relevant to 2D projects

**Impact:** Low-medium for a 2D platformer. Migration is generally safe from 4.6 → 4.7, but these specific changes may affect the project:

| Change | Risk |
|--------|------|
| Audio spectrum analyzer API changed | Low (not used yet) |
| BlendSpace internals | Low (no AnimationTree yet) |
| Keyboard/mouse device ID numbering | Medium — test input remapping |
| Shader preprocessor tightened | Low (no custom shaders yet) |
| OBB Android export removed | N/A |
| GDScript analyzer: ignores internal globals → fewer false warnings | Positive |

**Visual Profiler:** 4.7 adds tree folding to the Visual Profiler, making it usable on complex frames. Upgrade to get this if profiling becomes important.

**HDR output:** 4.7 adds HDR output for macOS — opt-in, no performance cost if disabled.

**Citations:**
- 4.7 migration guide: https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html
- 4.7 release notes: https://godotengine.org/releases/4.7/
- Linuxcompatible 4.7 RC1 notes: https://www.linuxcompatible.org/story/godot-47-rc-1-released-what-developers-need-to-know-before-upgrading/

---

### F9 — GPUParticles crash on Compatibility + Apple Silicon (historic, verify)

**Impact:** Low (not currently using GPUParticles). GitHub #72469 documents crashes when creating/loading GPUParticles nodes in macOS with the Compatibility/GLES3 renderer on Apple Silicon. Status in 4.6.2 is unclear — verify before adding particle effects to this project.

**Recommended action:** Use CPUParticles2D instead of GPUParticles2D until verified fixed. File a minimal repro if the issue persists on 4.6.2 or 4.7.

**Citation:** GitHub #72469: https://github.com/godotengine/godot/issues/72469

---

## 4.6-Specific Performance Regressions Summary

| Issue | Renderer | Platform | Status |
|-------|----------|----------|--------|
| Metal backend FPS regression (4.4+) | Forward+/Mobile (Metal) | macOS Apple Silicon | Open (#103723) |
| GPU particle crash on GLES3 + Apple Silicon | GL Compatibility | macOS Apple Silicon | Status unclear (#72469) |
| First-export 15+ min slowness | N/A (editor) | macOS M3 (4.6rc1) | Open (#115062) |
| Audio thread spikes at multi-sound trigger | All | All platforms | Workaround documented |
| CSG auto-smooth performance drop | 3D | All | Fixed in 4.7 beta 3 |

---

## Upgrade Recommendation

**Stay on 4.6.2 for active development.** 4.7 is current stable (June 18, 2026) and migration is low-risk for a 2D platformer, but the Visual Profiler tree-folding and HDR additions are not urgent. Upgrade when a new feature in 4.7 is specifically needed, or at the start of a new development phase.
