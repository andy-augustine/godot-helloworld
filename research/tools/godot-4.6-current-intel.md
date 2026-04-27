# Godot 4.6 Current Intel — Canonical Synthesis

**Generated:** 2026-04-26
**Baseline:** Godot 4.6.2-stable (production)
**Sources:** `research/crawl/sourcemap.md`, `topic-engine-quirks.md`, `topic-gdscript-language.md`, `topic-tooling.md`, `topic-2d-platformer.md`, `topic-performance.md`

---

## 1. TL;DR

- **Engine quirks:** AnimationPlayer manually-authored events are silently wiped on 4.6.0→4.6.1 upgrade (#116408, open, milestone 4.7); back up `.tscn` before any 4.6.1+ migration.
- **GDScript:** 4.6 ships a JIT compiler — typed code is now 5–8× faster than 4.5 interpreted, untyped JIT only 2–3×; explicit type annotations are now performance-critical, not just stylistic.
- **Tooling:** GUT 9.6.0 (2026-02-24) adds `wait_idle_frames`, singleton doubling (Input/Time/OS), and elapsed-time helpers — directly closes the MCP-timing gaps documented in TESTING.md.
- **2D platformer:** `ResourceSaver.save()` silently writes nulls for nested sub-resources after 4.5→4.6 upgrade; mandatory workaround is `.duplicate(true)` on each sub-resource before saving.
- **Performance:** Canvas renderer accidentally read write-combined memory in 4.6.0/4.6.1 — silent frame-time hog on Apple Silicon; fixed in 4.6.2 (GH-115757). Do not ship on 4.6.0 or 4.6.1.

---

## 2. Active Sources, Ranked

### HIGH

| Source | URL | Why |
|---|---|---|
| godotengine/godot (GitHub) | https://github.com/godotengine/godot | Bugs, fixes, release notes; 5,000+ open issues, daily commits |
| godotengine/godot-proposals | https://github.com/godotengine/godot-proposals | API design intent; new GIPs filed Apr 24–26 (#14729–#14741) |
| forum.godotengine.org | https://forum.godotengine.org/ | Primary Q&A; long-form, indexed, fast response |
| godotengine.org/blog | https://godotengine.org/blog/ | Authoritative release & foundation news |
| godot-rust dev updates | https://godot-rust.github.io/dev/ | Monthly; reveals GDExtension API surface |
| Mastodon (gamedev.place) | @godotengine, @reduz, @akien | Core dev signal post X-exodus |
| Signal Emitted (YouTube) | https://www.youtube.com/@signalemitted | Best weekly "what changed" digest |
| GDQuest (YouTube + Library) | https://www.gdquest.com/library/ | Substantive 4.6 workflow docs, hitbox/hurtbox, save-game canon |

### MED

| Source | URL | Why |
|---|---|---|
| godotengine/godot-docs | https://github.com/godotengine/godot-docs | Doc PRs reveal API intent |
| bitwes/Gut | https://github.com/bitwes/Gut | GUT 9.6.0 — primary GDScript test framework |
| godot-gdunit-labs/gdUnit4 | https://github.com/godot-gdunit-labs/gdUnit4 | Active alt; v5 (4.4) and v6 (4.5+) parallel |
| chickensoft-games | https://github.com/chickensoft-games | C# architecture patterns; updated Apr 22–26 |
| godot-rust/gdext | https://github.com/godot-rust/gdext | v0.5 (Mar 2026) typed dictionaries |
| Bluesky | — | Akien primary in 2026; growing core team share |
| GameFromScratch | https://gamefromscratch.com/ | Fast accurate news; 4.7 HDR, RTX fork coverage |
| Godot Engine official YouTube | https://www.youtube.com/channel/UCKIDvfZD1ZhY4_hhbotf7wA | GodotCon Amsterdam 2026 talks pending upload |
| r/godot | https://www.reddit.com/r/godot/ | Sentiment + trending pain; not deep-tech reliable |
| Official Discord | https://discord.com/invite/godotengine | Real-time help; ephemeral, not indexed |
| Asset Library | https://godotengine.org/asset-library/asset | Phantom Camera, Beehave, Terrain3D, etc. |
| GDNotes | https://gdnotes.com/ | Curated aggregator |
| jettelly.com/blog | https://jettelly.com/blog/ | Sporadic but accurate 4.7 summaries |

### LOW

| Source | Why skip |
|---|---|
| godotforums.org (unofficial) | Superseded by official forum |
| X/Twitter personal accounts | Core devs reduced activity post-2024 |
| HackerNews | No dedicated tag; only major releases surface |
| awesome-godot | Update cadence unclear |
| godot-sdk-integrations | Niche platform-specific |
| r/madeWithGodot | Showcase only |
| kidscancode (YouTube) | No confirmed 2026 activity |
| godotforums.org, Godot Café Discord, X (devs), GDScript 3.x docs, VisualScript content, pre-2024 Reddit | Dead / obsolete (per sourcemap §4) |

---

## 3. Contributors to Follow

| Name / Handle | Domain | Primary link | Why useful | Example contribution |
|---|---|---|---|---|
| Juan Linietsky (@reduz) | Core architecture, rendering, physics, audio | https://mastodon.gamedev.place/@reduz | Co-creator; sets fundamental API direction | Made Jolt Physics default in 4.6; LibGodot |
| Rémi Verschelde (@akien-mga) | Release management, build, GUI, input | https://mastodon.gamedev.place/@akien | Owns 4.x stable train | Coordinates every .x maintenance release |
| George Marques (@vnen) | GDScript language lead | https://github.com/vnen | Type-system decisions go through him | Typed arrays, lambda closures |
| Danil Alexeev (@dalexeev) | GDScript core | https://github.com/dalexeev | Static type inference improvements | PR #72677 typed-coroutine `await` inference |
| Clay John (@clayjohn) | Rendering, shaders | https://github.com/clayjohn | Rendering lead; SSR/SDFGI authority | Full SSR rewrite in 4.6 |
| Gilles Roudière (@groud) | 2D nodes, tilemap, editor | https://github.com/groud | Tilemap and 2D-physics author | TileMapLayer design |
| Tomasz Chabora (@KoBeWi) | 2D nodes, editor | https://github.com/KoBeWi | Extremely active 2D reviewer; also runs Metroidvania-System plugin | Animation timeline cursor fix in 4.6.2 |
| Hugo Locurcio (@Calinou) | Rendering, docs, demos, QA | https://github.com/Calinou | Most cross-cutting; first responder on docs | Maintains official demos/QA |
| @lawnjelly | Core, physics, low-level bugs | https://github.com/lawnjelly | Quiet but extremely active on physics edge cases | CharacterBody2D floor-snap fixes |
| Ricardo Buring (@rburing) | Physics (non-Jolt) | https://github.com/rburing | Primary 2D/3D Godot Physics maintainer | Elastic collision energy fix in 4.6.2 |
| A Thousand Ships (@AThousandShips) | Triage, docs | https://github.com/AThousandShips | First responder on bug reports | Closes/labels hundreds of issues |
| Pāvels Nadtočajevs (@bruvzg) | Editor, text rendering, Apple/Windows | https://github.com/bruvzg | Font/Control layout authority | TextServer improvements |
| Fabio Alessandrelli (@Faless) | Networking, debugger, Web | https://github.com/Faless | Multiplayer and ENet authority | WebSocket/ENet architecture |
| Paul Batty (@Paulb23) | Script editor, GUI | https://github.com/Paulb23 | GDScript editor / autocomplete | Code folding improvements |
| Bastiaan Olij (@BastiaanOlij) | Rendering, GDExtension, XR | https://github.com/BastiaanOlij | Senior cross-domain reviewer | XR architecture reviews |

---

## 4. Findings

### 4.1 Engine Quirks & Regressions

Ranked by relevance to a 2D platformer using CharacterBody2D + GL Compatibility + (eventually) TileMapLayer.

1. **`move_and_slide()` treats wall corner as floor — open through 4.6.2** (#109926). At one-tile platform edges, `CharacterBody2D` exact-aligned with a `StaticBody2D` corner gets classified as floor; `is_on_floor()` returns false but physics treats it as grounded. Workaround: capsule collision shape, or offset rectangles slightly off pixel grid. No milestone. [topic-engine-quirks §5]
2. **AnimationPlayer events silently wiped on 4.6.0→4.6.1 upgrade** (#116408, open, milestone 4.7). HIGH severity. Hand-authored method-call/signal tracks dropped; Blender-imported animations survive. Workaround: stay on 4.6.0 OR back up `.tscn` before upgrade and re-enter. [topic-engine-quirks §1]
3. **TSCN format change in 4.6: `load_steps` removed, `unique_id` per node added.** First open of a 4.5 project after running "Project > Tools > Upgrade Project Files" produces large diffs. Commit the upgrade as a dedicated commit. Forwards/backwards compatible with 4.5. [topic-engine-quirks §9]
4. **Vulkan canvas texture-region perf collapse — fixed in 4.6.2** (#115431, GH-115757). 4.6.0/4.6.1 caused 24,000+ draw calls vs ~18 baseline for TileMapLayer scenes. We are on 4.6.2; if we ever hold back, this is why we cannot. [topic-engine-quirks §7] [topic-performance §1]
5. **Animation path hash collisions corrupt multi-object scenes — fixed in 4.6.2** (#116231, PR #117030). Two paths hashing identically caused both tracks to drive the same property. If targeting <4.6.2, avoid procedurally generated numeric node names. [topic-engine-quirks §2]
6. **TextureButton/Control loses focus on click** (#117486, open, milestone 4.7). New `hide_focus` semantics (PR #110250) reverts focus state on mouse click. LOW for current project (no menus); HIGH when pause/HUD lands. Workaround: pass `grab_focus(false)` explicitly. [topic-engine-quirks §3]
7. **`@tool` script `_physics_process()` corrupts velocity into `.tscn`** (#118263, open). Always guard with `if Engine.is_editor_hint(): return` in tool scripts. If hit: hand-edit `.tscn` to remove the velocity sub-key. [topic-engine-quirks §4]
8. **GPUParticles2D angular_velocity inverted — fix only in 4.7** (#115547, PR #117861). Negate angular_velocity values for clockwise rotation. Not backported. [topic-engine-quirks §8]
9. **Jolt Physics 3D elastic-collision energy leak — fixed in 4.6.2** (#115169, GH-115305). 3D-only; tracking only for future scope. [topic-engine-quirks §6] [topic-performance §7]
10. **UID cache stale after editor file-dock overwrite — fixed before 4.6 stable** (#114493). If hit historically: delete `.godot/`. [topic-engine-quirks §10]

**4.7-beta watch (breaking when we upgrade):** RigidBody2D `angular_velocity` semantics fix (GH-117861), one-way collision now resolves all directions (GH-104736). Will require physics retuning. [topic-engine-quirks watch list]

### 4.2 GDScript Language Traps & Proposals

1. **JIT widens the typed-vs-untyped gap to 2–3× in 4.6.** Typed = 5–8× faster than 4.5 interpreted; untyped JIT = 2–3×. Practical hierarchy: `PackedXxxArray` > `Array[T]` > `Array`. Untyped `await` chains prevent JIT optimization of the surrounding function. [topic-gdscript §7]
2. **`is`-check type narrowing not propagated to type-checker** (#60499 / #115492; proposal #8530 active Apr 2026). Autocomplete narrows; type-checker doesn't. Workaround: explicit `as` cast or temp typed var inside the block. Daily friction. [topic-gdscript §1]
3. **Lambda signal connections silently multiply on scene reload** (#94641, open, no milestone). Each `func()` literal = fresh Callable; duplicate-connection guard never fires. Workaround: named methods only; or store Callable in member var and `disconnect` in `_exit_tree`. [topic-gdscript §3]
4. **Lambda capture asymmetry:** locals frozen at creation, members evaluated at call time. Use 1-element Array for accumulator pattern (already in project memory). New 4.6.1 wrinkle: cryptic "Lambda capture at index N was freed" error when captured object freed before lambda runs (#117840). Index is positional — count manually. [topic-gdscript §2]
5. **Signal `connect()` equality vs identity bug** (#116141, PR #117336 open). Two distinct objects with equal content trigger spurious "already connected" errors. Workaround: ensure differing content or use `CONNECT_REFERENCE_COUNTED`. [topic-gdscript §4]
6. **`WeakRef.get_ref()` returns Variant** — silently kills static analysis. Cast explicitly: `_ref.get_ref() as MyNode`. Proposal #9174 + PR #109268 open for `WeakRef[T]`. [topic-gdscript §5]
7. **`await` on untyped coroutine returns Variant.** Always annotate coroutine return types. PR #72677 improved typed-coroutine inference; untyped remain Variant. Spurious "await keyword not needed" on `-> void` coroutines (#74679). [topic-gdscript §6]

**Active proposals to watch:**

| # | Title | Priority |
|---|---|---|
| #8530 | Suppress unsafe-access in `is` blocks | HIGH (daily friction) |
| #10807 | Typed `Callable[Params, Return]` | HIGH (signal typing) |
| #9174 | `WeakRef[T]` (PR #109268 open) | MED |
| #7329 | Structs in GDScript | MED (long-running) |
| #13800 | Generics for GDScript | LOW / watch |
| #14652 | Migrate GDScript to GDExtension (5.0 vision) | LOW / future |
| #12685 | "GDScript 3.0" | **Closed/archived** |
| #14641 | Stateful Inline Blocks | **Closed not-planned** Apr 2026 |

Maintainers explicitly are not pursuing large language redesigns or implicit-state sugar.

### 4.3 Tooling

1. **GUT 9.6.0 (2026-02-24): adopt now.** New: `wait_idle_frames(n)`, `assert_push_warning`/`_count`, singleton doubling (`double("Input")`, `double("Time")`, `double("OS")`), `get_elapsed_sec`/`_msec`. Directly addresses MCP timing gaps in TESTING.md. Pure GDScript, no C# dep. [topic-tooling: GUT]
2. **GdUnit4 split: v5.0.4 (Godot 4.4, updated 2026-04-21) and v6.0.0 (Godot 4.5+).** Reorganized under godot-gdunit-labs org. Heavier, CI-first, stronger C# story. Decision: do not switch — GUT covers our needs, lighter, pure GDScript. Revisit if GUT stalls or C# lands. [topic-tooling: GdUnit4]
3. **godot-rust/gdext v0.5 (Mar 2026):** typed dictionaries, AnyArray, three safeguard tiers, GDExtension crate composition. File and ignore unless a perf-critical node needs Rust. [topic-tooling: gdext]
4. **MCP newcomers (post-Jan 2026), do not adopt:** `shameindemgg/godot-catalyst` (1 star, unproven); `ryanmazzolini/minimal-godot-mcp` (29 stars, LSP-only — already covered by godot-mcp-pro `validate_script`). See `mcp-alternatives.md` for full matrix. [topic-tooling: MCP]
5. **NVIDIA RTX-powered Godot fork (GDC 2026-03-13):** experimental, 3D-only, not upstream. Not relevant to our 2D platformer. Signals tier-1 vendor investment. [topic-tooling]
6. **GDQuest GDTour framework (updated Apr 23–25):** in-editor interactive tutorials. Pattern reference for guided onboarding only. [topic-tooling]
7. **Tracing profilers integrated in 4.6.0** (Tracy, Perfetto Android, Instruments macOS). Requires custom engine build with tracing flag — not in official export templates. Use Instruments on Apple Silicon when editor profiler lacks resolution. [topic-performance §4]
8. **No new external profiler emerged** in this window; built-in profiler + godot-mcp-pro `get_performance_monitors` remains sufficient.

### 4.4 2D Platformer Patterns

1. **`ResourceSaver` regression on nested sub-resources in 4.6** (forum 136658, ref #89961). Silent null writes after 4.5→4.6 upgrade. Mandatory workaround: call `.duplicate(true)` on every sub-resource before `ResourceSaver.save()`. Save to `user://`, never `res://`, in exported builds. HIGH applicability when save system lands. [topic-2d-platformer §9]
2. **Camera limit-snap on room transition still requires the manual fix.** No engine-level fix in 4.6.x. Pattern: pin camera to `get_screen_center_position()` before disabling follow, then tween. We already implement this (STRUCTURE.md transition step 5). Confirmed best practice. [topic-2d-platformer §3]
3. **Room transitions: scene-per-room with door Area2D nodes** remains canonical. Alternatives (all-loaded, additive) dismissed for memory. KoBeWi/Metroidvania-System plugin (active 2026) adds object-ID persistence — evaluate when persistent room state (breakable walls, collectibles) is needed. [topic-2d-platformer §8]
4. **Hitbox/Hurtbox layer convention (GDQuest 4.6 update):** Hitbox = Layer 2, Mask 0, Monitoring OFF (data-only); Hurtbox = Layer 0, Mask 2, fires `area_entered`. Damage handler lives on receiver. Set `monitorable = false` on inactive (sheathed) hitboxes to cut physics overhead. Commit layer numbers in project settings before combat work begins. [topic-2d-platformer §6]
5. **Camera2D screen shake — additive coroutine pattern.** Single async coroutine owns motion; repeat calls increment `current_strength` instead of spawning competing coroutines. Decay via `lerp()`. Verify our `GameCamera.add_shake()` stacks rather than resets. [topic-2d-platformer §1]
6. **Camera2D room locking — Rect2i + per-room limits remains canonical.** Phantom Camera (updated 2026-02-28) also rectangle-only. State-machine camera (follow/freeze/move-to-room/peek) is emerging for polished metroidvanias. Our pattern matches. Non-rectangular rooms would require custom logic. [topic-2d-platformer §2]
7. **Animation: script-driven AnimationPlayer with `current_animation` guard remains valid.** No deprecation. AnimationTree `travel()` is community consensus only when blend spaces or crossfades are needed. For discrete idle/run/jump/fall/wall-slide states our rig is fine. [topic-2d-platformer §7]
8. **TileMapLayer corner-edge stuck bug — open through 4.6.2.** `safe_margin` interacts badly with adjacent tile collision boundaries. Workarounds when we add tile art: set `safe_margin = 0` (re-test slopes), use rectangular per-tile collision (rectangles share edges cleanly), or single continuous StaticBody2D shapes. [topic-2d-platformer §5]
9. **TileMapLayer collision setup — physics layers live on TileSet, not the node.** Common trap: add physics layer to TileSet but forget to paint collision polygons per tile. Confirm physics layer numbers match CharacterBody2D mask. New in 4.6: scene tiles can be rotated in TileMapLayer (previously atlas-only). [topic-2d-platformer §4]
10. **Save/Load preference order:** Resources (preferred when shape matches) > `FileAccess.store_var/get_var` (binary, no exec risk) > JSON (only for external integrations). Godot 4 fixed array-of-resources from the 4.0 era. [topic-2d-platformer §9]

### 4.5 Performance & Deployment

1. **Canvas renderer write-combined memory reads — fixed in 4.6.2 (GH-115757).** Silent frame-budget killer on Apple Silicon: WC memory is fast to write, extremely slow to read. 4.6.0/4.6.1 had this bug. Upgrade is non-optional. [topic-performance §1]
2. **macOS ANGLE-on-Metal forced in VMs in 4.6.2 (GH-117371, GH-117253).** GL Compatibility on macOS routes through ANGLE; pre-4.6.2 the init could fail silently in VMs (GitHub Actions runners, Parallels) and fall back to broken renderer. Load-bearing for any macOS CI. [topic-performance §2]
3. **2D batching speed-ups in 4.6.0** (cumulative with WC fix). No published benchmark numbers. Increases headroom for more enemies/particles in 960×540 viewport. Profile after upgrade to set baseline. [topic-performance §3]
4. **4.6.0 launch regressions resolved by 4.6.2:** sky shader/VoxelGI (#115599, fixed 4.6.1; 3D-only), ReflectionProbe crash (#115284, fixed 4.6.1; 3D-only), animation use-after-free (#115931, fixed 4.6.1), viewport debanding with spatial scalers (GH-114890, fixed 4.6.2). **Do not ship on 4.6.0 or 4.6.1.** [topic-performance regressions table]
5. **Tracy/Perfetto/Instruments tracing integrated in 4.6.0** (GH-113279, GH-112702). Requires custom engine build with the tracing option; not in official export templates. Useful when editor profiler resolution is insufficient. [topic-performance §4]
6. **Core container optimizations in 4.6.0** — `HashMap` fast clear (GH-108932), scene-tree group lookups (GH-108507), `Array::resize` no-copy (GH-110535), `Vector`/`CowData` push (GH-112630), NodePath-to-String caching (GH-110478). GDScript benefits indirectly; **GDScript bytecode interpreter overhead is unchanged.** Prefer `_physics_process` over signal polling in tight loops. [topic-performance §5]
7. **Delta-encoded patch PCKs in 4.6.0 (GH-112011).** Patch files include only changed bytes. Relevant when setting up Steam/itch.io distribution; export preset gains a delta-patch option. [topic-performance §6]
8. **Mobile (Apr 2026 update):** Android Vulkan crash rates dramatically improved via Mali/Adreno workarounds. iOS export auto-prevents incompatible builds. Native debug symbols ship with official Android templates. [topic-performance: web/mobile]
9. **3D texture import up to 2× faster (GH-110060).** Editor-time only. Not relevant to current 2D project. [topic-performance §8]
10. **Web export:** No 4.6 GL Compatibility regressions. Threading still requires `SharedArrayBuffer` (COOP/COEP headers). Unchanged in 4.6. [topic-performance: web/mobile]

---

## 5. Open / Unresolved Issues

| Issue | Status | Last seen | Re-scan trigger |
|---|---|---|---|
| [#116408](https://github.com/godotengine/godot/issues/116408) AnimationPlayer events lost on 4.6.0→4.6.1 | Open, milestone 4.7 | 2026-04-26 | 4.7 stable release; 4.6.3 announcement |
| [#117486](https://github.com/godotengine/godot/issues/117486) TextureButton/Control focus reverts on click | Open, milestone 4.7 | 2026-04-26 | When we add pause/HUD menus; 4.7 stable |
| [#109926](https://github.com/godotengine/godot/issues/109926) `move_and_slide()` wall-corner-as-floor | Open, no milestone | 2026-04-26 | Any platformer edge bug we hit; @lawnjelly PR activity |
| [#118263](https://github.com/godotengine/godot/issues/118263) `@tool` physics writes velocity into .tscn | Open | 2026-04-26 | Before adding any `@tool` script to a physics body |
| [#115547](https://github.com/godotengine/godot/issues/115547) GPUParticles2D angular_velocity inverted | Fix in 4.7 only (PR #117861) | 2026-04-26 | 4.6.x backport announcement |
| [#94641](https://github.com/godotengine/godot/issues/94641) Lambda signal connections accumulate on reload | Open, no milestone | 2026-04-26 | Any signal-connection bug; named-method discipline review |
| [#116141](https://github.com/godotengine/godot/issues/116141) Signal connect equality-vs-identity false error | Open, PR #117336 | 2026-04-26 | Spurious "already connected" errors in our code |
| [#60499 / #115492](https://github.com/godotengine/godot/issues/115492) `is`-narrowing not propagated to type-checker | Open; proposal #8530 active | 2026-04-26 | 4.7 stable; #8530 implementation PR |
| [#117840](https://github.com/godotengine/godot/issues/117840) Cryptic "Lambda capture at index N was freed" | Open | 2026-04-26 | Any lambda-related crash we hit |
| [#9174](https://github.com/godotengine/godot-proposals/issues/9174) `WeakRef[T]` typed weak refs | Open, PR #109268 | 2026-04-26 | 4.7 stable; merge of #109268 |
| [#10807](https://github.com/godotengine/godot-proposals/issues/10807) Typed `Callable[Params, Return]` | Open, no impl | 2026-04-26 | Any signal-typing pain we accumulate |
| [forum 136658 / #89961](https://github.com/godotengine/godot/issues/89961) ResourceSaver nested-subresource nulls | Open regression | 2026-04-26 | Save-system implementation kickoff |
| forum 125521 TileMapLayer corner-seam stuck-player | Open, no fix in 4.6.2 | 2026-04-26 | When tile art replaces hand-placed StaticBody2D |
| GH-117861 (4.7) RigidBody2D angular_velocity semantics breaking | 4.7 beta | 2026-04-26 | 4.7 stable upgrade; physics retune |
| GH-104736 (4.7) one-way collision resolves all directions | 4.7 beta | 2026-04-26 | 4.7 stable upgrade; one-way platform retest |

---

## 6. Recurring Scan Recommendation

**Frequency: monthly** (next scan target: 2026-05-26).

Rationale: 4.6.x maintenance releases land on a roughly 6–8 week cadence; 4.7 stable is targeted Q2–Q3 2026. Monthly cadence catches each maintenance release and beta drop while in-flight, without churning on noise.

**Sources to scan each cycle:**

- godotengine.org/blog (release announcements, dev snapshots)
- godotengine/godot Issues filtered by `regression` label, milestones 4.6.x and 4.7
- godotengine/godot-proposals: top-of-feed since last scan
- forum.godotengine.org categories: bug-reports, help (search "4.6"/"4.7")
- Signal Emitted YouTube digest (catch-up on missed weeks)
- bitwes/Gut releases; godot-gdunit-labs/gdUnit4 releases
- Mastodon: @reduz, @akien recent posts since last scan

**What to watch for:**

- 4.6.3 release notes (changelog vs our open-issue table)
- 4.7 beta-N → RC → stable cadence; the two breaking 4.7 physics changes (GH-117861, GH-104736)
- Any backport of #115547 (GPUParticles2D) to 4.6.x
- Movement on #109926 (move_and_slide corner-as-floor) and #94641 (lambda-signal accumulation)
- New regressions filed against features we use (CharacterBody2D, AnimationPlayer, Camera2D, ResourceSaver)
- GDScript proposal #8530 implementation activity

**Escalate / shorten cadence to weekly if:**

- Godot 4.7 stable releases (run a one-off intel refresh same week; treat as new baseline)
- A regression directly blocking us is filed
- Maintainer announces a security release

**Who to ping if blocked:**

- GDScript language: @vnen (GitHub), @dalexeev
- 2D / tilemap: @groud (GitHub), @KoBeWi
- Physics edge cases: @lawnjelly, @rburing
- Rendering on Apple Silicon GL Compatibility: @clayjohn, @bruvzg
- Release scheduling / "is this fixed in next patch": @akien-mga (Mastodon, Bluesky)
- Forum first: forum.godotengine.org — long-form, indexed answers within hours

The user invoked the `/refresh-godot-intel` slash command for this crawl; re-running it monthly is the recommended cadence and matches the runbook intent.

---

## 7. Surprises

**None category-one.** Flags worth keeping in mind:

- **Godot 4.7 beta 1 dropped 2026-04-24** (two days before this synthesis). NOT yet stable; targeted Q2–Q3 2026. Treat 4.6.2 as production baseline. Two known breaking 2D physics changes coming (GH-117861 angular_velocity semantics, GH-104736 one-way collision direction).
- **JIT in 4.6 is the quiet scope-changer.** Typed-vs-untyped GDScript performance gap doubled. Existing codebases without explicit type annotations are leaving 2–3× perf on the table. Reinforces project memory entry on explicit typing.
- **AI-generated PRs straining maintainers (Feb 2026).** Core team publicly described the load as "draining and demoralizing." Relevant only if we ever submit upstream PRs.
- **GodotCon Amsterdam 2026 just happened (Apr 23–24).** Talks/videos pending on official YouTube — re-check Signal Emitted and the official channel in 2–4 weeks.
- **NVIDIA RTX Godot fork (GDC, Mar 2026):** signal of tier-1 vendor investment. Experimental, 3D-only, not upstream.
- **Godot Foundation funding up:** Mega Crit increased sponsorship, Scorewarrior top patron 2026.

---

## 8. Glossary

- **JIT (in 4.6 context)** — Just-in-time GDScript compiler shipped in Godot 4.6; speeds up GDScript execution 2–8× depending on type annotations.
- **Jolt Physics** — Default 3D physics engine in Godot 4.6 (replacing Godot Physics for new 3D projects). 2D unaffected.
- **LibGodot** — New in 4.6: ability to embed Godot engine as a library inside another host application.
- **TileMapLayer** — Per-layer 2D tilemap node (replaced legacy multi-layer TileMap node). Collision lives on the TileSet's physics layers.
- **ANGLE** — Almost Native Graphics Layer Engine; Google's GL-on-other-API translator. Godot's GL Compatibility renderer on macOS uses ANGLE-on-Metal.
- **GL Compatibility** — Godot 4 renderer targeting OpenGL ES 3.0 / WebGL 2 / GLES3. Lower hardware bar than Forward+ / Mobile renderers; what 2D-only desktop projects typically use.
- **Write-combined (WC) memory** — Memory regions optimized for sequential writes; reads from WC memory stall hard on Apple Silicon. The 4.6.0/4.6.1 canvas renderer bug accidentally read WC memory.
- **Phantom Camera** — Asset Library plugin for Camera2D/Camera3D control helpers (last updated 2026-02-28). Rectangle-only camera limits.
- **Beehave** — Behavior tree AI addon for Godot.
- **Terrain3D** — High-performance C++ GDExtension terrain plugin.
- **GUT** — Godot Unit Test, primary GDScript test framework. Current: 9.6.0.
- **GdUnit4** — Alternative test framework; v5 (4.4) and v6 (4.5+) parallel; hosted under godot-gdunit-labs org as of late 2025.
- **gdext** — godot-rust GDExtension Rust bindings. v0.5 March 2026.
- **GDExtension** — Godot 4's native-code extension API (replaces GDNative from Godot 3).
- **GDScript "3.0"** — Closed proposal #12685 for a redesigned language; not pursued.
- **GodotCon Amsterdam 2026** — Foundation's first conference in its home city; Apr 23–24, 2026, Pathé Amsterdam Noord.
- **KoBeWi/Metroidvania-System** — Plugin (Godot 4.x, active 2026) for object-ID persistence across rooms (collectibles, save state).
- **Signal Emitted** — Weekly YouTube Godot news digest channel; best single feed for "what changed."
- **godot-mcp-pro** — Paid MCP server granting Claude Code live access to the running Godot editor (this project uses it). Not the topic of this intel; covered in `mcp-alternatives.md`.
- **shameindemgg/godot-catalyst, ryanmazzolini/minimal-godot-mcp** — Newcomer MCP servers (Apr 2026). Not adopted; details in `topic-tooling.md`.
- **NVIDIA RTX Godot fork** — Experimental 3D-only ray-tracing fork from NVIDIA, GDC 2026. Not upstream, not stable.
- **GDQuest GDTour** — Interactive in-editor tutorial framework (updated Apr 2026).
- **Chickensoft LogicBlocks** — C# state-machine library for Godot; architecture reference only.
- **Tracy / Perfetto / Instruments** — Native-level profilers integrated into Godot 4.6 source via opt-in build flag. Not in official export templates.
