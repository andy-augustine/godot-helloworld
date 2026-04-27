# Art conventions

How the project handles visual quality. Aimed at Claude or a collaborator about to add a new entity, room, or UI element — answers "how do I make this look like it belongs in this game and not like a placeholder?"

This file is the policy. The first instances live in [`player/player.tscn`](player/player.tscn) (entity) and [`rooms/`](rooms/) (level geometry + backgrounds, after the [`visually-distinct-rooms`](plans/visually-distinct-rooms.md) ship).

---

## Visual tiers (borrowed from godot-ai-builder, adapted)

Tier table from godot-ai-builder's [`godot-assets/SKILL.md`](https://github.com/HubDev-AI/godot-ai-builder/blob/main/skills/godot-assets/SKILL.md), adopted as our policy:

| Tier | When | Means |
|---|---|---|
| **Procedural** *(default)* | Forward-going default | Stacked nodes / `_draw()` / shaders / particles, depending on sub-tier (below) |
| **Custom art** | User provides sprites | `Sprite2D` / `AnimatedSprite2D` + shader effects on top |
| **AI-generated** | Art generated externally | Prompts → sprite pipeline → shader enhancement |
| **Prototype** | Quick/simple builds only — **explicit escape hatch** | Flat ColorRects, basic shapes |

**Procedural is the default.** Prototype is an explicit escape hatch, not a default-to-be-polished-later. "Polish later" is the pattern that reliably gets cut when work runs long; the bar only sticks if it's the default. If a piece of work ships in prototype tier, the commit message must explicitly justify it ("placeholder pending art assets," "rapid playtest iteration," etc.).

---

## Three sub-tiers under "procedural"

The base godot-ai-builder pattern (per-entity `_draw()` + `_process` + pulse glow + shader) is right for **entities** but wrong for static level geometry — pulsing platforms read as "alive" and burn frame budget for no signal value. Our project splits "procedural" into three sub-tiers, picked by what the visual *is*:

### Procedural-static (level geometry)

For: platforms, walls, ground, ceiling, doors, fixed environmental decoration. Anything that doesn't move or pulse.

**Pattern — body + outline + shadow + highlight as stacked static nodes. No `_process`. No shaders. No animation.**

```
Platform (StaticBody2D)           ← physics body, unchanged
├── CollisionShape2D              ← physics shape, unchanged
└── Visual (Node2D)               ← formerly the single ColorRect
    ├── Shadow    (ColorRect, +4y offset, darkened, alpha 0.3, z_index −2)
    ├── Body      (ColorRect, the existing color, z_index 0)
    ├── Outline   (ColorRect, 2px wider/taller, body darkened ~40%, z_index −1)
    └── Highlight (ColorRect, ~3px tall, top edge, body lightened ~30%, z_index +1)
```

Color discipline: each room picks its palette intentionally — see "Per-room palette" below.

### Procedural-animated (entities)

For: player, pickups, projectiles, future enemies, anything that moves, attacks, gets hit, or signals "alive."

**Pattern — `_draw()` callback driven by `_process` + pulse/idle animation + at least one shader effect (hit-flash, glow-outline, or equivalent).** Direct port of godot-ai-builder's entity-drawing pattern; full sample code lives in their [`godot-assets/SKILL.md`](https://github.com/HubDev-AI/godot-ai-builder/blob/main/skills/godot-assets/SKILL.md) under "Entity Drawing Pattern."

Minimum elements per entity:
- Body (with gradient or layered colors — never a single flat fill)
- Outline (1–2px, contrast against background)
- Shadow (drop shadow / ambient occlusion suggestion)
- Highlight (inner glow / specular suggestion)
- Idle animation (bob, pulse, shimmer, rotation)

Existing reference: [`player/player.tscn`](player/player.tscn). The player rig is already a partial procedural-animated implementation — limbs as `Polygon2D` children of `Rig`, AnimationPlayer driving idle/run/jump/fall/wall-slide states, particle emitters for landings/wall-slide. Future entities should match or exceed this bar.

### Procedural-background (room/screen backdrops)

For: room atmospheric layer, world backdrop, screen-fill backgrounds (title, pause, menu).

**Pattern — layered: gradient (shader or stacked ColorRects) + ambient particle layer + optional vignette.**

Layers, back to front:
1. Gradient fill (full-bounds ColorRect with shader, or 2–3 stacked ColorRects with vertical alpha falloff). z_index ≈ −10.
2. Ambient particle drift (low density, alpha 0.1–0.2, slow velocity, neutral or thematic color). z_index ≈ −9.
3. *(Optional)* Vignette overlay — full-screen darkening at edges. z_index ≈ +90 (above gameplay, below HUD). **Skip if it interacts poorly with HUD readability.**

Foreground readability is the constraint: the background's job is to establish atmosphere without competing with silhouette. If a player or platform stops popping against the backdrop, the backdrop is too loud — desaturate or dim.

---

## Per-room palette discipline

Each room picks a palette intentionally. Three rules:

1. **One dominant hue, one accent hue, one neutral.** Don't mix four+ saturated colors per room.
2. **Foreground (player + interactable) must contrast against background.** If the player rig disappears against a wall, the wall is the wrong color.
3. **Adjacent rooms should diverge meaningfully.** If SecondRoom and StartingRoom feel the same, the room transition has lost its payoff.

Current room palettes (after the [`visually-distinct-rooms`](plans/visually-distinct-rooms.md) ship — fill in once shipped):

| Room | Dominant | Accent | Neutral | Mood |
|---|---|---|---|---|
| StartingRoom | TBD (cool / blue-grey) | TBD | TBD | Cradle — calm, neutral, "where you start" |
| SecondRoom | TBD (warm / amber) | TBD | TBD | Ascent — warmer, going somewhere |
| ThirdRoom | TBD (cool / violet) | TBD | TBD | Depths / next zone — darker, signals progression |

---

## When to downgrade to prototype tier

Cases where prototype is acceptable, with the rule that the commit message must say so:

- **Rapid playtest iteration** — testing a movement tweak, want a placeholder room geometry without spending the visual budget yet.
- **Plumbing-only stub** — `ThirdRoom` was prototype-tier as a stub closing the dash loop; it earned the upgrade once the loop was real.
- **Prototyping an unproven mechanic** — don't visual-polish a system that might get scrapped.

In all cases: when the work survives the prototype phase, **upgrade to procedural in the same ship** that promotes it from "prototype" to "real." Don't accumulate prototype-tier debt across rooms or entities.

---

## What's NOT in this doc

- **Specific shader code** — godot-ai-builder's [`godot-assets/SKILL.md`](https://github.com/HubDev-AI/godot-ai-builder/blob/main/skills/godot-assets/SKILL.md) has working samples for glow-outline, hit-flash, gradient-bg, dissolve. Lift them when first needed; keep the policy doc tier-level, not implementation-level.
- **Animation timing / easing curves** — game-feel territory; lives in [`CLAUDE.md`](CLAUDE.md) ("polish-mode") and per-feature plans, not here.
- **Audio cues paired with visuals** — see [`backlog/gamedev.md`](backlog/gamedev.md) item #11 (audio system) and item #6 (transition audio).
- **AI art generation pipeline** — the "AI-generated" tier is named in the table for completeness, but no pipeline exists yet. See [`backlog/tooling-pipeline.md`](backlog/tooling-pipeline.md) item #10 (Grok video → frames spike) and #10b (godot-ai-builder replay spike).
