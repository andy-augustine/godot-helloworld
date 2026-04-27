# Plan: Visually distinct rooms — adopt procedural visual-tier policy + lift StartingRoom / SecondRoom / ThirdRoom off prototype

**Status:** in progress (claimed by Andy + Claude, branch main, 2026-04-27)

This plan is multi-phase ("polish mode" per [`CLAUDE.md`](../CLAUDE.md)) because it (a) introduces a project-wide visual-quality policy that all future entities and rooms inherit and (b) applies that policy across three rooms with per-room palette divergence and signature visual elements. Phase order is policy-first → infra-first → divergence-second → polish-last.

Source: [`backlog/gamedev.md`](../backlog/gamedev.md) item #1 + [`backlog/tooling-pipeline.md`](../backlog/tooling-pipeline.md) item #9 (this plan closes both in the same ship).

---

## Why now

Three reasons converge:

1. **Backlog #1 is the highest-leverage non-system work.** SecondRoom and ThirdRoom are plumbing-only clones of StartingRoom. Door transitions don't yet feel like "going somewhere new." Even moderate visual divergence dramatically lifts the room-system payoff that already shipped.
2. **Visual-quality bar should land before content-volume work.** Once enemies/weapons/more rooms ship, retrofitting a visual-tier policy onto N entity types is painful. Setting the rule first means new entities inherit it as a default.
3. **godot-ai-builder's `godot-assets` SKILL gave us a well-articulated tier table** — borrowing it is a small lift with outsized policy clarity. (See "Visual-tier policy" below.)

---

## Visual-tier policy (the borrow from godot-ai-builder)

godot-ai-builder's `godot-assets/SKILL.md` defines four tiers:

| Tier | When | Means |
|---|---|---|
| **Procedural** (default) | Full game builds | Shaders + layered `_draw()` + particles + post-processing |
| **Custom art** | User provides sprites | Sprite2D / AnimatedSprite2D + shader effects on top |
| **AI-generated** | Art generated externally | Prompts → sprite pipeline → shader enhancement |
| **Prototype** | Quick/simple builds only | Basic shapes (only when explicitly chosen) |

**Our adopted policy: procedural is the forward-going default. Prototype is an explicit escape hatch (justified per-instance), not a default-to-be-polished-later.** The "polish later" pattern reliably gets cut when work runs long; the bar only sticks if it's the default.

**Three sub-tiers under "procedural" — our project's interpretation:**

- **Procedural-static** — for level geometry (platforms, walls, ground, ceiling). Body+outline+shadow+highlight as **stacked static nodes**. No `_process`, no pulse, no shader. Static geometry is not alive and shouldn't read as alive.
- **Procedural-animated** — for entities (player, pickups, future enemies/projectiles). The full godot-ai-builder pattern: `_draw()` callback driven by `_process` + pulse glow + shader effects. Player rig is already a partial implementation; future entities inherit this as the bar.
- **Procedural-background** — for room/screen backdrops. Layered: gradient shader (or stacked ColorRects) + ambient particles + (eventually) vignette overlay. Establishes per-room atmosphere without competing with foreground readability.

The full policy doc lives at [`ART_CONVENTIONS.md`](../ART_CONVENTIONS.md) (written in Phase 1).

---

## Phases

### Phase 1 — Plan + policy doc + backlog #10b + tooling #9 closure

**Deliverables:**

1. This plan file, committed.
2. `ART_CONVENTIONS.md` at repo root — the visual-tier policy doc. Closes [`backlog/tooling-pipeline.md`](../backlog/tooling-pipeline.md) item #9.
3. New backlog entry: `backlog/tooling-pipeline.md` item #10b — "Spike: drive godot-ai-builder end-to-end as Claude using our game as the spec" (sequenced after this ship).
4. `ROADMAP.md` — active-plan pointer updated.

No scene/script changes. One commit.

**Risk:** none — pure planning.

---

### Phase 2 — Procedural-static across all 3 rooms (uniform pass)

Apply body+outline+shadow+highlight stacked-node treatment to every existing platform / wall / ground / ceiling in `StartingRoom`, `SecondRoom`, `ThirdRoom`. Single shared color scheme this phase (palette divergence comes in Phase 4) — focus is purely on the **depth lift** off flat ColorRects.

**Pattern (per platform):**

```
Platform (StaticBody2D) — unchanged
├── CollisionShape2D    — unchanged
└── Visual (Node2D)     — formerly the single ColorRect
    ├── Shadow          (ColorRect, +4y offset, darkened, alpha 0.3, z_index −2)
    ├── Body            (ColorRect — the existing color, z_index 0)
    ├── Outline         (ColorRect, 2px wider/taller, color = body darkened 40%, z_index −1)
    └── Highlight       (ColorRect, ~3px tall, top edge, color = body lightened 30%, z_index +1)
```

Done via godot-mcp scene editing. No GDScript. No shaders. No animation. ~10 platforms × 3 rooms ≈ 30 visuals to upgrade. Mechanical work.

**Verification:** `get_editor_errors` clean after `save_scene` on each room. Visual confirm via `get_editor_screenshot` of each room.

**Commit:** "P2 (visually-distinct-rooms): procedural-static — body+outline+shadow+highlight on all level geometry, uniform palette."

**Risk:** node count grows ~4×. Watch for any frame-time regression in `get_editor_performance` after the third room. If meaningful, simplify (drop the highlight stripe is the cheapest cut).

---

### Phase 3 — Procedural-background per room + StartingRoom palette intent

Add a per-room background layer to all three rooms — full-bounds gradient (top-darker → bottom-lighter, or vice versa per room mood) + a low-density ambient particle layer (z_index −10, behind all geometry, alpha 0.1–0.2).

This phase also intentionally **re-tunes StartingRoom's palette** so the existing blue-grey reads as "the cradle — chosen, not default." Concretely: StartingRoom keeps a desaturated cool palette but the background gradient establishes intent (e.g. dim teal top → warmer slate bottom, the player's starting world).

No SecondRoom / ThirdRoom palette divergence yet — those rooms get the *background-layer pattern* but with the same StartingRoom palette as a control. That separation lets us evaluate whether the divergence in Phase 4 lands cleanly against a known-good baseline.

**Verification:** walk through all three rooms via play + door transitions, confirm backgrounds don't compete with foreground silhouettes.

**Commit:** "P3 (visually-distinct-rooms): procedural-background — gradient + ambient particle layer per room, StartingRoom palette intent set."

**Risk:** ambient particles can read as snow/dust and break tone if poorly chosen. Pick neutral first (dust motes, slow drift); save thematic particles for Phase 4 if a room calls for them.

---

### Phase 4 — Per-room palette divergence + signature visual elements

The point of the ship — make each room feel different.

- **StartingRoom** — keep the cool/cradle palette established in Phase 3. No new signature element this round (it already has the high-jump pickup as visual interest). Treat it as the baseline.
- **SecondRoom** — warm "ascent" palette (orange/amber wall + platform tones, warmer background). One signature visual element TBD on first look — leaning toward a glowing pedestal silhouette where the dash pickup conceptually originates, OR a parallax-suggestive backdrop layer hinting at elevation gained.
- **ThirdRoom** — cool/violet "depths or next zone" palette, darker overall. One signature visual element TBD — leaning toward a portal/void silhouette on the far wall that pairs with the existing "TO BE CONTINUED" stub label.

The "TBD on first look" framing is intentional: choose the signature element after seeing each room with palette divergence applied — what's missing reveals what to add.

May split into 2 commits if SecondRoom or ThirdRoom runs long.

**Commit(s):**
- "P4a (visually-distinct-rooms): SecondRoom warm palette + signature element."
- "P4b (visually-distinct-rooms): ThirdRoom cool palette + signature element."

**Risk:** signature elements can over-decorate and break readability. Discipline: **one** element per room, not three. The procedural-static + procedural-background lift in Phases 2 + 3 is doing most of the work — Phase 4's signature elements are accents, not centerpieces.

---

### Phase 5 — Coherence walkthrough + post-ship docs sweep + plan archive + add #10b

End-of-ship pass.

1. **Coherence walkthrough**: play through StartingRoom → SecondRoom → ThirdRoom via door transitions in both directions. Watch for: tween-smoothness across palette shifts, foreground readability against new backgrounds, any per-room visual breaking the others' tone.
2. **Post-ship docs sweep** per [`CLAUDE.md`](../CLAUDE.md):
   - `ROADMAP.md` — Updated date, Most-recent-ship row, Backlog-top-picks row (item #1 falls off, item #9 / enemies likely surfaces).
   - `STRUCTURE.md` — Add `ART_CONVENTIONS.md` to root-docs line. Fix the "no UI/HUD, no enemies, no pickups" doc-drift in the "What's deliberately not here" section (HUD and pickups have shipped — those bullets are stale).
   - `backlog/gamedev.md` — Mark item #1 `**Status:** complete (YYYY-MM-DD)` with link to this plan archive. Adjust item #2 (TileMapLayer conversion) if priorities have shifted.
   - `backlog/tooling-pipeline.md` — Mark item #9 `**Status:** complete (YYYY-MM-DD)` with link to ART_CONVENTIONS.md.
   - Memory files — fold in any new GDScript / scene-editing rule discovered during the ship (e.g. Visual-as-Node2D-with-ColorRect-children patterns and how `update_property` interacts with them).
3. **Archive plan**: move this file to `plans/done/visually-distinct-rooms.md`, set `**Status:** complete (YYYY-MM-DD)` plus implementation commit hashes.

**Commit:** "P5 (visually-distinct-rooms): post-ship sweep — archive plan + ROADMAP/STRUCTURE/backlog updates."

---

## Explicitly NOT in scope this round

Documenting these so they don't pull scope mid-build.

- **Animated background elements** beyond ambient particles (e.g. parallax scrolling, animated silhouettes, weather). Future polish pass.
- **Vignette overlay shader.** Listed in godot-ai-builder's full procedural-background recipe but adds a screen-space layer that interacts with HUD readability — wants its own evaluation session.
- **Shader-based visuals on level geometry.** `glow_outline.gdshader` and friends from godot-ai-builder are great for *entities*, not for static geometry. Static geometry stays in Procedural-static (stacked nodes, no shader).
- **Hit-flash / dissolve / outline shaders for entities.** Player rig and pickups can absorb these later — out of scope for room-visual work.
- **TileMapLayer conversion** (gamedev backlog #2). Still hand-placed `StaticBody2D` polygons after this ship. Tile art is a Days-effort own-plan future phase.
- **Audio per room** (gamedev backlog #6 — transition stinger, room music). Sequenced after audio-system music infrastructure (gamedev #11).
- **Refactoring `Room.gd` to expose palette as `@export` properties.** Three rooms doesn't justify the abstraction. Hand-tune ColorRect colors per scene; promote to shared resource only when N rooms ≥ ~6 makes the duplication worse than the indirection.

---

## Success criteria

- [ ] All three rooms feel visually distinct on a screen-by-screen comparison.
- [ ] Procedural-static look applied uniformly to all level geometry — no flat ColorRects remain on platforms/walls/ground.
- [ ] Each room has a per-room background layer (gradient + ambient particle).
- [ ] No `get_editor_errors` regressions; no `get_editor_performance` regressions worse than ~5%.
- [ ] `ART_CONVENTIONS.md` exists and is referenced from STRUCTURE.md.
- [ ] Backlog #10b drafted; Backlog gamedev #1 + tooling #9 marked complete.
- [ ] Plan archived to `plans/done/`.
