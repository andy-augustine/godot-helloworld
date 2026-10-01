# Performance & Deployment — October 2026 Intel
**Crawl date:** 2026-10-01 | **Window:** September 2026 onward | **Agent:** topic-performance

---

## TL;DR — Top 3 Findings

1. **Metal/Vulkan deadlock on M4/M5 Macs running macOS 26.x (4.7.1 regression)** — CanvasShaderRD
   compilation deadlocks the engine on M4/M5 hardware under macOS 26. The project's GL Compatibility
   renderer is the confirmed workaround. No patch in 4.7.x; fix is 4.8-milestone only.

2. **Web export JS heap leak is unresolved in 4.7.2** — WebGL framebuffers and textures accumulate
   indefinitely. Affects even a minimal empty-scene project. No workaround. Open issue #123134.
   Relevant if a web build is ever added.

3. **4.8 dev5 adds a Frame Time panel to the 2D editor** (Sept 2026) — the first in-editor
   2D frame-time indicator. Combined with dev4's Visual Profiler tree-folding and 1.6× property
   access speedup, 4.8 is a meaningful profiling upgrade over 4.7. Not yet stable.

---

## Findings

### F-01 · macOS 26.x Metal/Vulkan CanvasShaderRD deadlock (4.7.1 regression)

| Field | Detail |
|-------|--------|
| **Version** | 4.7.1+ regression; not present in 4.6.3 |
| **Hardware** | MacBook Pro M5, Mac mini M4; macOS 26.6.2 confirmed |
| **Renderer** | Metal (primary) and Vulkan via MoltenVK 1.4.1 |
| **Symptom** | Splash screen appears but is not animated; engine freezes on CanvasShaderRD
  GPU pipeline construction (deadlock in Metal compiler scheduler). Requires force-quit. |
| **Impact** | HIGH risk if upgrading engine and switching away from GL Compatibility. |
| **Workaround** | GL Compatibility renderer (OpenGL) — the project already uses this. Safe. |
| **Fix status** | Open, assessed for 4.8 milestone. No 4.7.3 patch scheduled. |
| **Action** | Stay on GL Compatibility. Do not switch to Metal/Vulkan renderer on macOS until
  4.8 stable is out and the issue is confirmed resolved. When evaluating a renderer upgrade,
  test on M-series hardware explicitly. |
| **Citation** | https://github.com/godotengine/godot/issues/123481 |

---

### F-02 · Web export JS heap leak (4.6–4.7.2, open)

| Field | Detail |
|-------|--------|
| **Version** | Godot 4.6, 4.7.2, 4.8 dev4 (all affected) |
| **Root cause** | WebGLFramebuffer and WebGLTexture objects accumulate in system arrays and
  are never garbage-collected. Reproducible in a minimal Node2D project with no scripts. |
| **Impact** | In a 40-minute session, typed arrays grew from ~128 MB to ~154 MB; JS arrays
  from 173 kB to 5.5 MB. Long-play web sessions will eventually exhaust browser memory. |
| **Workaround** | None documented. |
| **Fix status** | Open, awaiting platform team triage. Issue #123134. |
| **Action** | No immediate action (macOS-only project). If a web build is planned, delay
  until this is resolved or build in a page-reload/restart mechanism for long sessions. |
| **Citation** | https://github.com/godotengine/godot/issues/123134 |

---

### F-03 · 4.8 dev5: Frame Time panel in 2D editor (Sept 2026)

| Field | Detail |
|-------|--------|
| **Version** | Godot 4.8 dev5 (September 10, 2026) — **not yet stable** |
| **Impact** | MEDIUM (future) — adds Information and Frame Time panels directly to the 2D
  editor toolbar. Combined with dev4's Visual Profiler tree-folding, this makes per-frame
  diagnosis feasible without leaving the 2D workspace. |
| **Also in dev5** | Mip-level texture streaming (VRAM reduction for open-world 3D titles;
  low relevance for 960×540 2D projects but present in the build). 183 changes from 78
  contributors. Feature freeze is imminent for 4.8. |
| **Action** | No action now. Revisit when 4.8 reaches stable (est. Q1 2027). |
| **Citation** | Godot blog: dev-snapshot-godot-4-8-dev-5 (Sept 2026) |

---

### F-04 · 4.8 dev4: Object property access 1.6× faster + 12 MB RAM saved

| Field | Detail |
|-------|--------|
| **Version** | Godot 4.8 dev4 (Aug 26, 2026) — **not yet stable** |
| **Mechanism** | GDType unification: property maps moved from ClassDB to GDType, stored
  in a single unified map. Cuts redundant lookups and saves ~12 MB runtime RAM. |
| **Impact** | HIGH (future) — property access in hot paths (`_physics_process`, animation
  callbacks, camera follow loops) is the dominant GDScript runtime cost in a platformer. |
| **Action** | No action now. Benchmark `_physics_process` property reads against 4.7 baseline
  before upgrading to 4.8 stable. |
| **Citation** | sourcemap.md §3 milestones; GH-122596 |

---

### F-05 · GDScript typing: up to 59% faster for vector operations

| Field | Detail |
|-------|--------|
| **Version** | Godot 4.x (established, confirmed on 4.7 benchmarks) |
| **Impact** | HIGH — typed GDScript skips runtime type resolution. Independent benchmarks
  on Apple Silicon (M2 Max) show: Vec2 distance 58.8% faster, Multiply 35.9% faster,
  Add 34.2% faster vs untyped. Games using `Vector2`, `Vector3`, and typed node refs in
  `_physics_process` see the largest gains. |
| **Action** | Audit platformer scripts for untyped variables in hot paths. Add `: Vector2`,
  `: float`, `: int` annotations. Use typed array syntax (`Array[EnemyState]`) in loops. |
| **Regression** | None. This is a stable optimization path. |
| **Citation** | University of Twente benchmark study; beep.blog (2024, confirmed stable in 4.7) |

---

### F-06 · Web export: single-thread mode is now the recommended default (4.7)

| Field | Detail |
|-------|--------|
| **Version** | Godot 4.3+ (established), confirmed default in 4.7 |
| **Impact** | LOW now, MEDIUM if web build added — multi-thread web exports require COOP/COEP
  HTTP headers which break third-party embeds (ads, analytics). Single-thread mode avoids
  this but cannot use threads and is measurably slower. wasm64 (4.7.0) removes the 4 GB
  memory ceiling for both modes. |
| **Action** | If adding a web build: start with single-thread export to simplify hosting.
  Enable COOP/COEP headers only if thread performance proves necessary, and accept that
  third-party scripts will not load. |
| **Citation** | Godot 4.7 web export docs; sourcemap.md §3 milestones (dsnopek / wasm64) |

---

### F-07 · macOS export: notarization required for Gatekeeper (4.7 templates)

| Field | Detail |
|-------|--------|
| **Version** | Godot 4.7 (current export templates) |
| **Impact** | MEDIUM for distribution — unsigned builds trigger "unidentified developer"
  Gatekeeper block. 4.7 export templates include the required entitlement structure. |
| **Options** | (a) Full: Apple Developer ID + `xcode-select codesign` + `notarytool` + `rcodesign staple`.
  (b) Ad-hoc: Built-in codesign, Notarization disabled — users must right-click > Open. |
| **Action** | For playtest distribution use ad-hoc. For public release, set up full
  notarization pipeline. No 4.7-specific surprises in the docs. |
| **Citation** | docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html |

---

## 4.7.x Performance Regressions (September 2026 update)

| # | Issue | Renderer | Status |
|---|-------|----------|--------|
| R-01 | CanvasShaderRD deadlock on M4/M5, macOS 26.x | Metal, Vulkan/MoltenVK | Open; GL Compat workaround works |
| R-02 | Mobile renderer crash on launch (no fallback to GL) | Mobile renderer | Open, 4.7.2 affected |
| R-03 | Web export JS heap leak (WebGL resources) | Web (all) | Open, unresolved since 4.6 |

No 2D Compatibility renderer regressions confirmed in 4.7.x. The project's current renderer
(GL Compatibility) and platform (macOS Apple Silicon) are unaffected as long as Metal/Vulkan
are not enabled.

---

## Sources

| Source | Coverage |
|--------|----------|
| https://github.com/godotengine/godot/issues/123481 | M4/M5 Metal/Vulkan deadlock |
| https://github.com/godotengine/godot/issues/123134 | Web build JS heap leak |
| Godot blog: dev-snapshot-godot-4-8-dev-5 (Sept 2026) | Frame Time panel, mip streaming |
| Godot blog: dev-snapshot-godot-4-8-dev-4 (Aug 2026) | Property access 1.6×, profiler folding |
| https://essay.utwente.nl/essays/107857 | GDScript typed vs untyped benchmark |
| Godot 4.7 web export docs (docs.godotengine.org) | wasm64, COOP/COEP, single-thread default |
| Godot 4.7 macOS export docs (docs.godotengine.org) | Notarization, ad-hoc signing |
| research/crawl/sourcemap.md §3 | 4.7.2 changelog, 4.8 dev snapshot summaries |
