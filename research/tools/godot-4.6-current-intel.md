# Godot 4.6 Current Intel — Community Crawl Synthesis

**Synthesized:** 2026-06-01 · **Window:** post-January 2026
**Project:** 2D Metroidvania, Godot 4.6.2, GDScript, macOS Apple Silicon, GL Compatibility (GLES3) renderer, 960×540, CharacterBody2D + custom GameCamera room-locking, TileMapLayer rooms, AnimationPlayer rig, driven via godot-mcp-pro.
**Sources:** six topic-research files under `research/crawl/`. Every claim is cited to the upstream issue/PR/release it came from.

---

## 1. TL;DR

- **Upgrade to 4.6.3 now.** It fixes the GLES3 batching bug that silently drops entire TileMapLayer render passes at specific tile counts (GH-117725) plus RefCounted/signal thread-safety races — both hit our GL Compatibility 2D stack. [engine-quirks F1; perf F-03]
- **Lambda outer-variable capture is a value snapshot, not a live reference** (open bug #117348). Never mutate an outer var inside a lambda; use the 1-element Array accumulator. [gdscript #1]
- **GdUnit4 (v6.1.3, Apr 2026) has overtaken GUT (v9.6.0, 15 months stale) in momentum** — better for greenfield test suites, though not worth mid-project migration. [tooling]
- **Camera2D `position_smoothing` + `limit_smoothed` causes glitchy room entry**; the fix is calling `reset_smoothing()` after repositioning on transition — directly applicable to our GameCamera. [2d-platformer #1]
- **CharacterBody2D slope jitter grows with distance from origin** (open #118130, ~16k px onset); keep room geometry within ~10k px of (0,0) on long maps. [engine-quirks F2]

---

## 2. Active sources, ranked

### HIGH
| Source | Type | Why |
|---|---|---|
| [godotengine/godot](https://github.com/godotengine/godot) | GitHub | Ground-truth on fixed/broken; 4.6.3 = 86 fixes / 41 contributors |
| [godot-proposals](https://github.com/godotengine/godot-proposals/discussions) | GitHub | Canonical design-decision record; core devs respond |
| [godot-docs](https://github.com/godotengine/godot-docs) | GitHub | Official docs + doc-bug deltas |
| [godotengine.org/blog](https://godotengine.org/blog/) | Blog | All release/Foundation announcements (403 on fetch, browser-OK) |
| [forum.godotengine.org](https://forum.godotengine.org/) | Forum | Foundation-run official forum, active 2026 |
| [bitwes/Gut](https://github.com/bitwes/Gut) | GitHub | Primary GDScript test framework (in our test patterns) |
| [godot-gdunit-labs/gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) | GitHub | Alt test framework; faster cadence |
| [GDQuest](https://gdquest.com) | YouTube/web | Deep open-source GDScript courses |
| [Godot Engine official YT](https://youtube.com/c/GodotEngineOfficial) | YouTube | GodotCon 2026 talks, dev vlogs |

### MED
| Source | Type | Why |
|---|---|---|
| [ramokz/phantom-camera](https://github.com/ramokz/phantom-camera) | GitHub/asset | Top 4.6 camera plugin; relevant if camera system expands |
| [chickensoft-games](https://github.com/chickensoft-games) | GitHub | C# tooling; low signal for pure GDScript |
| [awesome-godot](https://github.com/godotengine/awesome-godot) | GitHub | Plugin discovery index |
| r/godot · official Discord · @godotengine (Mastodon/X) | Community | Real-time Q&A; not archivable |
| [jettelly.com](https://jettelly.com/blog) · [gamefromscratch.com](https://gamefromscratch.com) | Blogs | Good 4.6/4.7 feature coverage |
| StayAtHomeDev · Lukky | YouTube | Practical tutorials |

### LOW / SKIP
- **SKIP (retired):** `answers.godotengine.org` (superseded by official forum), old IRC (dead).
- **LOW:** `godotforums.org` (fan Flarum, fallback only), Stack Overflow godot tag (Godot 3.x era), Hacker News (shallow on GDScript), pre-2024 YouTube tutorials (TileMap/pre-Jolt APIs superseded).
- **VERIFY before citing:** kidscancode.org recipes (Godot 3 era).

**Topic-agent S/N updates:** Tooling agent flags GUT as a yellow-signal (15-month release gap) vs GdUnit4 momentum. 2D agent confirms `forum.godotengine.org` Metroidvania threads as actively useful. No source was downgraded out of its sourcemap tier.

---

## 3. Contributors to follow

| Name / handle | Domain | Primary link | Why useful | Example contribution |
|---|---|---|---|---|
| Juan Linietsky (reduz) | Engine architecture, GDScript VM, renderer | [github.com/reduz](https://github.com/reduz) | Creator/lead; core internals | Drove LibGodot in 4.6 |
| Rémi Verschelde (akien-mga) | Release mgmt, CI, governance | [github.com/akien-mga](https://github.com/akien-mga) | Authoritative on what changed/why each release | Coordinates every stable; AI-slop PR statements (Feb 2026) |
| George Marques (vnen) | GDScript language, type system | [github.com/vnen](https://github.com/vnen) | Best follow for GDScript semantics | Type inference + static-analyzer work in 4.6 |
| Clay John (clayjohn) | Rendering (Vulkan, GLES3, forward+) | [github.com/clayjohn](https://github.com/clayjohn) | Owns renderers incl. GLES3 (our renderer) | Led 4.6 SSR rewrite |
| Tomasz Chabora (KoBeWi) | Editor usability + MetSys | [github.com/KoBeWi](https://github.com/KoBeWi) | Authors Metroidvania-System framework | MetSys room/map mgmt; curve-point fixes (2026) |
| Michael Alexsander (YeldhamDev) | Editor UX, canvas scaling | [github.com/YeldhamDev](https://github.com/YeldhamDev) | Inspector + Game debug tab | Favorite-properties + "Game" debug tab |
| Thaddeus Crews (Repiteo) | Build system, SCons, exports | [github.com/Repiteo](https://github.com/Repiteo) | Export-template + thread-safety fixes | May–Jun 2026 thread-safety fixes |
| Pāvels Nadtočajevs (bruvzg) | Text rendering, i18n | [github.com/bruvzg](https://github.com/bruvzg) | Go-to for font/text/CJK | Theora init + editor icon fixes (2026) |
| Yuri Sizov (YuriSizov) | Editor UX, production | [github.com/YuriSizov](https://github.com/YuriSizov) | Deep editor-toolchain knowledge | Ex-Foundation PM; inspector internals |
| bitwes (Tom) | GUT test framework | [github.com/bitwes](https://github.com/bitwes) | Sole maintainer of our test framework | GUT v9.6.0 singleton-doubling |
| MikeSchulze | gdUnit4 | [github.com/MikeSchulze](https://github.com/MikeSchulze) | Alt test framework author | v6.1.3 (Apr 2026) flaky-test detection |
| ramokz | Phantom Camera plugin | [github.com/ramokz](https://github.com/ramokz) | Top 4.6 camera plugin, responsive | Lookahead 2D; docs at phantom-camera.dev |
| GDQuest (Nathan Lovato + team) | Education, demo projects | [gdquest.com](https://gdquest.com) | Authoritative patterns (hitbox/hurtbox, save) | Updated Godot 4 hitbox/hurtbox library |
| Raul Santos (raulsntos) | C# / .NET | [github.com/raulsntos](https://github.com/raulsntos) | C# bridge owner (only if we add C#) | Owns Mono/GodotSharp |

---

## 4. Findings

### 4A. Engine quirks & regressions
Ranked by relevance to our GL Compatibility 2D platformer.

1. **GLES3 batching drops entire TileMapLayer render passes** (HIGH) — at tile counts hitting a multiple of `max_instances_per_buffer`, an `if (index == 0)` guard skipped all accumulated instances; layers vanish/flash, TileMap crashes under SubViewport. **Fixed in 4.6.3** (GH-117725). Pre-4.6.3 workaround: pad tile counts or use Forward+. We run GLES3 + TileMapLayer → upgrade is mandatory. [engine-quirks F1] https://github.com/godotengine/godot/pull/117725
2. **CharacterBody2D slope jitter at distance from origin** (HIGH, OPEN #118130, filed Apr 2 2026) — FP precision loss; jitter onset ~16k px, severe at 30k–100k px, worst at ~11–13° slopes; `max_angle`/`snap_length` don't help. Workaround: keep geometry within ~10k px of (0,0) / stream large maps. [engine-quirks F2] https://github.com/godotengine/godot/issues/118130
3. **TileMapLayer collision phantom cuts / ghost seams** (MED, OPEN #119163, confirmed 4.6-stable & 4.7.dev3) — `move_and_slide()` with square shapes snags on invisible tile seams. Workaround: use a slightly-undersized capsule/circle collider. NOTE conflict with the one-way-platform bug below (see 4D.2) — rect is needed there, capsule here; pick per room layout. [engine-quirks F6] https://github.com/godotengine/godot/issues/119163
4. **CharacterBody2D misses RigidBody2D collision from above** (MED, OPEN #119824, filed May 27 2026, repros 4.5.2–4.7-beta3) — when grounded, `get_slide_collision()` returns nothing for a falling RigidBody2D. Workaround: detect from the RigidBody2D side or via Area2D. Relevant to hazard/enemy hit detection. [engine-quirks F5] https://github.com/godotengine/godot/issues/119824
5. **UID assignment silent failure 4.6.0–4.6.2** (HIGH, fixed 4.6.3, GH-118037) — reimported assets didn't get UIDs assigned; `ResourceSaver` resolved stale data, scene references drifted silently. Another reason to be on 4.6.3 before expanding the asset pipeline. [engine-quirks F3] https://github.com/godotengine/godot/pull/118037
6. **NodePath errors when referenced node deleted** (LOW, fixed 4.6.3, GH-115274) — editor error spam, edge-case instability. [engine-quirks F8]
7. **Label `add_child` 150–400× slower for certain Unicode glyphs** (LOW, OPEN #116216) — e.g. ☠ ☥ 𝜎 cost 35k–106k µs vs ~240 µs ASCII; affects runtime HUD. Avoid those code points in runtime Labels. [engine-quirks F10] https://github.com/godotengine/godot/issues/116216
8. *(3D-only, future reference)* GLB scene Unique-ID regeneration on reimport (fixed 4.6.3, F4); volumetric fog visual break with legacy-blending escape hatch in 4.6.3 (F9); AnimationTree StateMachine inspector not refreshing without deselect (LOW, OPEN #119249, F7).

### 4B. GDScript language traps & proposals
Ranked by how likely our code paths hit them.

1. **Lambda outer-variable capture = value snapshot** (OPEN #117348, confirmed 4.6.1) — `func(): x += 1` never mutates outer `x`; repeat calls reuse the creation-time snapshot. Use the 1-element Array accumulator (`var acc := [0]`; mutate `acc[0]`). Risk for tween `finished` closures in our transitions. [gdscript #1] https://github.com/godotengine/godot/issues/117348
2. **Lambda capturing `self` leaks RefCounted** (OPEN #102327) — reference cycle blocks GC; accumulates across scene reloads. Fix: connect named methods, or `weakref(self)` + `is_instance_valid()` guard; also #94641 (each anonymous lambda is a non-equal Callable → duplicate connections on reload). Directly relevant given our room/scene reloads. [gdscript #2] https://github.com/godotengine/godot/issues/102327
3. **`await` on a signal whose emitter is freed → hung coroutine + leak** (OPEN #99383/#72629/#74449) — coroutine suspends forever; `GDScriptFunctionState` orphans accumulate. Guard with `is_instance_valid(node)` before awaiting externally-owned nodes; prefer `CONNECT_ONE_SHOT`. High relevance to door/room transition await chains. [gdscript #6]
4. **Typed `Dictionary[K,V]` nested-for silent crash** (closed dup of #88753, NOT fixed in 4.6.1/4.6.2) — type-checks pass, game window freezes with no Output. Workaround: drop the type annotation. [gdscript #3] https://github.com/godotengine/godot/issues/116947
5. **Typed Array/Dictionary can't be initialised via ternary** (OPEN #110628, "up for grabs", 4.5+) — runtime type-assign error; use an `if/else` assignment instead. [gdscript #4]
6. **Freed-object lambda error uses opaque capture index, not var name** (OPEN #117840; fix PR #118552 pending) — debugging trial-and-error; guard captures with `is_instance_valid()`. [gdscript #7]
7. **`weakref()` holds resources alive in `@tool` scripts** (OPEN #115448, regression vs 4.5.1, milestone 4.7, no 4.6.x backport) — avoid `weakref()` in `@tool` exported-property trackers. [gdscript #5]
8. **4.6.3 fixed RefCounted/threaded-signal race** (no API change; upgrade benefit) — *deduped: cross-listed in 4E.2 as the perf-relevant framing.* [gdscript #8]

**Proposals to track:** `await` multiple signals `all()/any()` (#13597, high signal — would replace custom helpers); Typed WeakRef `WeakRef[T]` (#9174, relevant to #115448); unused-signal-inheritance warning (#13951). Archived/rejected: GDScript 3.0 namespaces/generics (#12685, closed Jun 2025). 4.7-beta opt-in `UNTYPED_DECLARATION` warning has a highlight bug (#118550) — don't enable until fixed.

### 4C. Tooling
Ranked by decision relevance.

1. **Testing frameworks — GdUnit4 vs GUT.** GdUnit4 v6.1.3 (Apr 27 2026) leads on momentum: flaky-test detection, session hooks, HTML/XML reports out of the box, variadic args, parse-error detection at CLI discovery; requires Godot 4.5+ (fine, we're on 4.6.2); v7.0.0 on roadmap. GUT v9.6.0 (Feb 24 2025, 15 months stale) is already in our test patterns and uniquely doubles Godot singletons (Input/Time/OS). **Verdict:** stay on GUT mid-project; pick GdUnit4 for a greenfield suite; if GUT goes 6 more months without a release, backlog a migration. [tooling]
2. **In-editor AI agents (new class in 2026).** **Ziva** (~Feb 2026, free tier $3/mo credit, asset/4879) is most capable: live scene-tree manipulation via editor API (vs raw .tscn patching), runs GUT tests, reads debugger errors, screenshot-as-context, sprite/TileMap gen, Claude/Gemini/ChatGPT backends. Likely additive to our godot-mcp-pro workflow — worth a trial. **Summer Engine** (open-source, MCP built into engine) — monitor only; adds a layer over vanilla Godot, risky mid-project. **AI Assistant Hub** (free, Ollama/Gemini) — backlog; we already have the lead MCP seat. [tooling]
3. **CI/CD — godot-ci (abarichello)** tracking 4.6.3-stable is the de-facto GitHub Actions standard; adopt when CI is prioritized (already in backlog), no alternative needed. **GodotEnv (Chickensoft, v2.16.2)** is C#-focused — skip for pure GDScript. [tooling]
4. **Profilers — no new dominant plugin.** Built-in Godot profiler + ObjectDB debugger (4.6.0) covers our needs; no action. [tooling; cross-ref 4E.4]

*Out of scope (tracked elsewhere):* godot-mcp-pro internals, godogen, MCP alternatives, PR #25.

### 4D. 2D platformer patterns
Ranked by applicability to our shipped/in-flight systems.

1. **Camera2D room locking + smoothing** (HIGH) — `limit_*` room locking is still canonical (no new node in 4.6). Enabling both `position_smoothing_enabled` and `limit_smoothed` causes start-offset and one-frame-late snapping; consensus: disable `limit_smoothed`, call `reset_smoothing()` after repositioning on a transition. Screen shake: noise-based trauma pattern (`trauma`²→`shake_amount`); Camera2D `offset` is clipped by tight limits, so apply shake via sub-viewport/`RemoteTransform2D`, not Camera2D offset. PR #115397 (Jan 2026) "improve Camera2D" — check if merged pre-4.6.3. [2d #1] https://github.com/godotengine/godot/pull/115397
2. **TileMapLayer collision & physics layers** (HIGH) — physics layers live on the **TileSet resource**, not the node (common upgrade gotcha). Multiple physics layers per TileSet recommended (solid vs one-way). **OPEN #102887 (4.3–4.6.x):** capsule/circle collider falsely triggers `is_on_wall()` on one-way-platform top corners → use a **rectangular** primary collider when one-way platforms exist. (Conflicts with the ghost-seam capsule advice in 4A.3 — choose per layout.) `set_cell()` physics changes apply next frame, not synchronously. [2d #2] https://github.com/godotengine/godot/issues/102887
3. **Room transitions (door/scene load)** (HIGH, in flight) — Area2D trigger → `change_scene_to_file()` + ColorRect fade Tween. Zelda-style scroll transitions must disable smoothing during the pan and `reset_smoothing()` at destination or the camera slides back through the door seam. **MetSys (KoBeWi/Metroidvania-System)** is the most complete open-source room/map framework — worth studying. 4.6.0 Unique Node IDs reduce signal-connection fragility during room iteration. [2d #5] https://github.com/KoBeWi/Metroidvania-System
4. **Hitbox/hurtbox layering** (MED, future combat) — dedicated `HitArea2D`/`HurtArea2D` children over CharacterBody2D contacts; named layers (Player/Enemy/PlayerHitbox/EnemyHitbox); toggle `monitoring = false` when inactive for a real perf win in enemy-dense rooms. [2d #3]
5. **Animation state machines** (MED) — community threshold: **5+ states → AnimationTree pays off**; our AnimationPlayer `match`-over-enum rig is appropriate now. Migrate to `AnimationNodeStateMachine` for cross-fades/blend-spaces/attack-chaining at ~6+ states. Pitfall #69382: spammed transitions skip states — gate with min-duration or manual `travel()`. Keep `animation_finished` for one-shots. [2d #4] https://github.com/godotengine/godot/issues/69382
6. **Save/load** (MED, not built) — prefer custom Resource pattern (`@export` + `ResourceSaver.save("user://save.tres")`) for structured Metroidvania data; `.tres` in dev, `.res` to ship. **Always check `ResourceSaver.save()` return code** — active 4.6 silent-failure report on nested custom resources without explicit sub-resource paths. `user://` only writable path post-export. [2d #6]

### 4E. Performance & deployment
Ranked by impact on our GL Compatibility 2D build.

1. **2D renderer batching overhaul (4.6.0)** (HIGH) — 1.1×–7× GPU throughput gain, GL Compatibility explicitly included, automatic on upgrade, no code changes. Profile before/after to confirm in our scenes. [perf F-01] https://godotengine.org/releases/4.6/
2. **4.6.3 fixes GLES3 batching bugs + RefCounted/signal thread-safety** (HIGH/MED) — *deduped: rendering-side detail lives in 4A.1.* Perf framing: 4.6.0–4.6.2 carry live refcount/signal races (exposed via `Thread`/`WorkerThreadPool`/`load_threaded_request`) and batching visual glitches. Upgrade is low-risk, zero known incompatibilities with 4.6.2. [perf F-02/F-03] https://godotengine.org/article/maintenance-release-godot-4-6-3/
3. **GDScript static analyzer expanded (4.6.0)** (MED) — flags unused vars + unreachable code; address warnings especially in `_physics_process`/`_process` (unused locals still allocate/nil-check). Free correctness+micro-perf win; lambda closures fully supported. [perf F-05]
4. **ObjectDB debugger (4.6.0)** (MED) — snapshot/diff live object counts to catch RefCounted leaks (esp. the self-capture cycles in 4B.2) between room transitions. Baseline memory now. [perf F-04]
5. **macOS export** (LOW) — no GL Compatibility desktop regressions in window; 4.6.3 macOS-clean (its mobile fixes were iOS Xcode 26 + Android API 36). 4.7 HDR-on-macOS may shift GL Compatibility behavior — watch the stable notes. [perf F-06]
6. **Web export** (LOW now) — 4.6.x has a 4 GB wasm32 heap limit; wasm64 is 4.7-beta-only. If web export lands before 4.7 stable, budget <1 GB assets. [perf F-07]

---

## 5. Open / unresolved issues we may hit

| Issue | Status | Last seen | Re-scan trigger |
|---|---|---|---|
| CharacterBody2D slope jitter at distance (#118130) | OPEN | 2026-06-01 | 4.6.4 or 4.7-stable; if we build maps >10k px from origin |
| CharacterBody2D misses falling RigidBody2D collision (#119824) | OPEN (repros to 4.7-beta3) | 2026-05-27 | 4.7-stable; when we add falling hazards/enemies |
| TileMapLayer ghost-seam snag (#119163) | OPEN (4.6-stable, 4.7.dev3) | 2026-05-02 | 4.7-stable; if players report micro-stops on flat ground |
| `is_on_wall()` false positive, capsule + one-way platform (#102887) | OPEN (4.3–4.6.x) | 2026-06-01 | When we add one-way/pass-through platforms |
| `on_floor` false positive on moving platform (#117288) | OPEN | 2026-06-01 | When we add AnimatableBody2D moving platforms |
| Lambda value-snapshot capture (#117348) | OPEN (4.6.1) | 2026-06-01 | On any lambda relying on outer-var mutation |
| Lambda `self`-capture RefCounted leak (#102327 / #94641) | OPEN | 2026-06-01 | ObjectDB shows orphan growth across room reloads |
| `await` on freed emitter hangs + leaks (#99383/#72629) | OPEN | 2026-06-01 | Coroutine that never resumes after a transition |
| Typed Dictionary nested-for silent crash (#116947 / dup #88753) | OPEN (not fixed 4.6.2) | 2026-06-01 | If we adopt typed Dictionary[K,V] containers |
| `weakref()` keeps resources alive in `@tool` (#115448) | OPEN (milestone 4.7) | 2026-01-27 | 4.7-stable; if we write `@tool` editor scripts |
| Label `add_child` slow for Unicode glyphs (#116216) | OPEN | 2026-02 | If HUD frame spikes with non-ASCII glyphs |
| AnimationTree inspector not refreshing (#119249) | OPEN | 2026-06-01 | When we migrate the rig to AnimationTree |
| AnimationTree state-skip on spammed transitions (#69382) | OPEN | 2026-06-01 | When we migrate the rig to AnimationTree |
| `ResourceSaver` silent failure on nested resources | OPEN (forum report) | 2026-06-01 | When we build save/load |
| Camera2D improvement PR (#115397) | UNKNOWN merge state | 2026-01 | Confirm whether merged into 4.6.3 |
| Await-multiple-signals proposal (#13597) | OPEN proposal | 2026-06-01 | If accepted, replace custom timeout/any helpers |

---

## 6. Recurring scan recommendation

**Self-recommendation: refresh this intel MONTHLY until Godot 4.7 ships stable, then drop to QUARTERLY.**

Rationale: 4.7 is in active beta (Beta 4, late May 2026) with stable expected **late June 2026** — the next ~6 weeks carry the highest churn (1,265 fixes since 4.6, 2D physics changes, HDR-on-macOS affecting GL Compatibility). After 4.7 stabilizes, the 4.x maintenance cadence is slow enough that quarterly suffices, with an ad-hoc scan on any new stable/maintenance release.

**Monthly (until 4.7 stable):**
- `godotengine/godot` releases + the open watch-list issues in §5 (priority: #118130, #119824, #119163).
- `godotengine.org/blog` for 4.7 beta→stable progression and maintenance releases (watch for 4.6.4).
- GdUnit4 + GUT release pages (is GUT still stale? did v7.0.0 ship?).

**Quarterly (post-4.7-stable):**
- Re-rank sources; sweep contributor activity; re-check Phantom Camera / MetSys / godot-ci version bumps; revisit the AI-agent landscape (Ziva, Summer Engine).

**Watch for specifically:** 4.7-stable release; any new 4.6.x regression announcement; CharacterBody2D/TileMapLayer physics fixes; resolution of the lambda capture and typed-container bugs; whether PR #115397 (Camera2D) landed.

**Who to ping if blocked:** GDScript semantics → vnen (George Marques); GLES3/renderer → clayjohn; release/regression status → akien-mga (Rémi Verschelde); test framework → bitwes (GUT) / MikeSchulze (GdUnit4); Metroidvania camera/room patterns → KoBeWi (MetSys) and the official forum's Help/Programming category.

---

## 7. Surprises

Two scope-changers were flagged by the pre-scan/topic agents:

1. **Godot 4.7 is in active beta, not yet stable** (Beta 1 Apr 24 2026; Beta 4 late May 2026 fixed critical regressions; stable expected late June 2026). 1,265 fixes from 309 contributors since 4.6. Any 4.7 feature advice is **beta-only / provisional** until stable. Directly relevant: 4.7 ships **one-way collision direction control for CollisionShape2D** (4.7-dev1), which will fix the one-way-platform authoring pain in §4D.2 — but do not adopt until stable. HDR output on macOS may shift GL Compatibility behavior. [sourcemap; 2d-platformer]
2. **Godot maintainers are drowning in AI-generated PRs** (reported Feb 2026, PC Gamer / The Register, citing Rémi Verschelde). Maintainer throughput is constrained and PR review latency is elevated — set expectations accordingly before suggesting anyone submit engine PRs to fix the open issues above. [sourcemap]

---

## 8. Glossary

- **GLES3 / GL Compatibility renderer** — Godot's OpenGL-based renderer (our project's renderer), distinct from Forward+ (Vulkan).
- **LibGodot** — 4.6 feature letting you embed Godot as a library inside an external application.
- **Jolt Physics** — third-party physics engine promoted to default for *new 3D* projects in 4.6; 2D still uses GodotPhysics by default.
- **ObjectDB debugger** — 4.6.0 editor tool that snapshots/diffs live object counts to find RefCounted leaks.
- **MetSys (Metroidvania-System)** — KoBeWi's open-source framework for Metroidvania room association, transitions, and map tracking.
- **Phantom Camera** — ramokz's Cinemachine-inspired Godot 4 camera addon (Lookahead 2D; no built-in room-lock primitive).
- **GUT** — bitwes' GDScript unit-testing framework (in-editor / headless CLI).
- **GdUnit4** — godot-gdunit-labs' GDScript+C# test framework with flaky-test detection and HTML/XML reports.
- **Ziva** — in-editor AI agent (Feb 2026) that manipulates the live scene tree via editor API, runs tests, and generates assets.
- **Summer Engine** — open-source Godot 4 plugin embedding an MCP-compatible AI-native layer into the engine.
- **godot-ci** — abarichello's Docker image + GitHub Actions/GitLab CI templates for headless export.
- **GodotEnv** — Chickensoft's C# CLI for managing Godot versions and `addons.json` installs.
- **Unique Node IDs** — 4.6.0 feature giving nodes stable internal IDs so connections survive renames/refactors.
- **wasm64** — 4.7-beta WebAssembly target that removes the 4 GB heap limit of wasm32.
- **TileMapLayer** — current tile node (replaced deprecated TileMap in 4.3); physics layers configured on the TileSet resource, not the node.
- **`reset_smoothing()`** — Camera2D method to hard-snap position, used after repositioning during room transitions to avoid smoothing seam glitches.
- **AnimationNodeStateMachine** — AnimationTree's visual state-machine graph; the upgrade path from script-driven AnimationPlayer at 5+ states.
