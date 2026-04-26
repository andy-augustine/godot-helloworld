# Gamedev backlog

Game-feature work specific to this Metroid-style platformer. Unlike `tooling-pipeline.md`, items here are project-specific — they don't have a portability obligation. See [`README.md`](README.md) for conventions.

Roughly grouped: deferred-from-shipped-work first, then "missing systems," then polish.

---

## Deferred from the camera/room system (already shipped)

These were called out as "explicitly NOT in scope this round" in the camera/room plan. The system shipped, these are the natural follow-ups.

### 1. Visually distinct rooms

**Why:** `SecondRoom.tscn` is a plumbing-only clone of `StartingRoom`. Transitions don't yet feel like "going somewhere new." Even a tinted background / different platform color would dramatically lift the room-system payoff.
**Source:** Internal — `plans/done/camera-room-system.md` "Explicitly NOT in scope this round" section.
**Effort:** 1–2 hours per room (color palette + ambient tint + a couple of distinguishing prop polygons).
**Deliverable:** `SecondRoom.tscn` with a clearly different palette and at least one signature visual element. Optionally: a third room to make the world feel more than two-room.
**Notes:** Pairs well with the `godot-assets` quality-bar doc (tooling item #9).

---

### 2. TileMapLayer conversion

**Why:** Rooms are hand-placed `StaticBody2D` polygons. Tile art is the eventual path — it's the standard Godot 2D pattern, scales better than hand placement, and unlocks tilemap editor workflows.
**Source:** Internal — `plans/done/camera-room-system.md` and original camera/room plan.
**Effort:** Days. Likely a major capability — should produce a `plans/tilemap-conversion.md` first.
**Deliverable:** Each room converted to a `TileMapLayer` with collision. Hand-placed StaticBody2Ds replaced. Tilesets authored or sourced (likely procedural for a first pass).
**Notes:** Sequence after #1 (visually distinct rooms — start with simple color variation, then promote to tilesets). Could be the trigger for the first asset-generation spike (tooling-pipeline #10).

---

### 3. Save/load of current room

**Why:** Without persistence, every session restarts at `StartingRoom`. Save/load is also a foundation for the bigger gameplay arc (returning to abilities, checkpointing, etc.).
**Source:** Internal — `plans/done/camera-room-system.md` "Explicitly NOT in scope this round" section.
**Effort:** Half day.
**Deliverable:** Persistent state covering at minimum: current room, player position. Probably a small `SaveSystem.gd` autoload + JSON file at `user://`. Save on door transition (good checkpoint), load on `_ready`.
**Notes:** First system that benefits from `decompose-feature.md` skill (tooling item #6) — natural place to test the risk-first decomposition.

---

### 4. Multiple camera sub-zones within a single big room

**Why:** Hollow-Knight-style — one large room with several camera-clamp sub-rectangles. Lets a "boss arena" or "fall room" feel different from corridor sections without requiring separate room files.
**Source:** Internal — camera/room plan.
**Effort:** Half day.
**Deliverable:** Add `CameraZone` Area2D children to rooms; on player overlap, GameCamera switches its `limit_*` to the zone's rect. Falls back to the room's `bounds` when no zone is active.
**Notes:** Lower priority until we have rooms big enough to need it.

---

### 5. Cinematic door sequences

**Why:** Metroid-style door reveals (pause, glow, fade, unlock animation) make door transitions feel earned. Today they're a flat 0.5s pan.
**Source:** Internal — camera/room plan.
**Effort:** Days. Tied to ability/upgrade system (locked doors imply unlocking ⇒ pickups).
**Deliverable:** Door variants (e.g. `LockedDoor`) with their own open animation, blocking until a flag is set. Camera pause during open. Optional dialogue/UI prompt.
**Notes:** Defer until the pickup system exists (#7 below).

---

### 6. Music / SFX on transitions specifically

**Why:** Even before a full audio system exists, a transition stinger and a footstep loop would dramatically lift the existing motion. Cheapest piece of the audio system to ship first.
**Source:** Internal — camera/room plan.
**Effort:** 2–4 hours after item #11 (audio system) is in.
**Deliverable:** `AudioStreamPlayer` sourced from the audio system, played on door enter and on land. Background music looped per room.
**Notes:** Sequenced after #11.

---

## Missing systems (the big ones)

### 7. Pickups system (Metroid-style permanent upgrades)

**Why:** The genre-defining loop. Without pickups, there's no progression, no reason to revisit, no payoff for traversal. Even one pickup (double jump, dash) would change how the game plays.
**Source:** Internal — gameplay analysis.
**Effort:** Days. Major capability — should produce `plans/pickups.md`.
**Deliverable:** `Pickup` scene (Area2D + visual + sound), `Inventory` autoload tracking obtained abilities, player ability gates (e.g. `_handle_double_jump` checks `Inventory.has("double_jump")`). At least one shipped pickup (recommend: double jump — unlocks more level design).
**Notes:** Foundation for #5 (locked doors), #8 (HUD), #14 (title screen has "new game / continue"). Also the trigger for the procedural-visual-quality bar (tooling #9).

---

### 8. HUD / UI system

**Why:** Health bar shipped via [`plans/done/hud-health.md`](../plans/done/hud-health.md). What's still missing: ability indicators (when pickups exist), item-count tracker, "you got X" pickup notification overlay, mini-map, pause overlay. Without these, the game still has no feedback channel for non-health state.
**Source:** Internal.
**Effort:** Days for the remaining pieces, but each sub-piece is a half-day. The pickup notification is the most pressing — it's a hard dependency for #7.
**Deliverable:** Extend `hud/HUD.tscn` with ability slot icons, an item-count Label, and a `PickupNotification` Control that animates "Got: <name>" on pickup. Mini-map can wait.
**Notes:** Sequence with or after #7 — the first thing to add is whatever the first pickup grants.

---

### 9. Enemies / combat

**Why:** Eventually every Metroidvania has them. Without combat, the player has nothing to overcome but level layout — the game stays a movement showcase.
**Source:** Internal.
**Effort:** Days each (one per archetype). The system architecture is one major capability; the content (each enemy type) is incremental.
**Deliverable:** Base `Enemy` class with health, hit reaction, death. Player attack input + hitbox. At least two enemy archetypes (a stationary turret-ish and a patrolling walker is the genre baseline). Pairs with #8 for damage feedback.
**Notes:** Significant scope — own `plans/enemies.md`. Defer until pickups (#7) and HUD (#8) are in; combat without progression is hollow.

---

### 10. Save system (full version)

**Why:** Item #3 covers minimal current-room persistence. Full save/load — inventory, picked-up flags, defeated bosses, room visit map, world state — is a separate, larger thing.
**Source:** Internal.
**Effort:** Days. Major capability.
**Deliverable:** Save slots (3 typical), versioned save format, migration path for save-format changes during development. Probably JSON at `user://saves/`.
**Notes:** Defer until the world state is rich enough to be worth saving — i.e., after pickups (#7) and at least one boss/objective.

---

### 11. Audio system

**Why:** Foundation shipped via [`plans/done/audio-foundations.md`](../plans/done/audio-foundations.md): `AudioManager` autoload with pooled `AudioStreamPlayer`s, three SFX (jump, heavy landing, wall slide loop), bus configuration. Still missing: music tracks, transition stinger, more SFX coverage (footsteps, hit/death — see #16 — pickup, ability gain).
**Source:** Internal.
**Effort:** Half day for music infrastructure (a `play_music(track)` API + Master/Music/SFX bus polish); ongoing for content.
**Deliverable:** `AudioBus` configuration (Master / Music / SFX with separate volumes). `AudioManager` autoload exposing `play_sfx(name)` and `play_music(track)`. Hooks in `player.gd` for footstep, jump, land, wall slide. Hooks in `World.gd` for transition stinger.
**Notes:** Likely the **highest-ROI single item** in this backlog — game feel jumps enormously from one audio pass.

---

### 12. Pause menu / title screen

**Why:** Today the game starts immediately at `StartingRoom` and there's no way to quit without closing the window. Standard polish.
**Source:** Internal.
**Effort:** Half day each.
**Deliverable:** `TitleScreen.tscn` with New Game / Continue / Quit. `PauseMenu.tscn` overlay triggered by Esc. Set `run/main_scene` to `TitleScreen.tscn`; title transitions to `World.tscn`.
**Notes:** Sequence after #10 so "Continue" actually loads something.

---

## Polish & content

### 13. More movement / animation states

**Why:** Current state set is solid (idle / run / jump / fall / wall_slide / land). Future additions to consider: dash, crouch, attack, hurt, dead. Each pulls weight visually.
**Source:** Internal — depends on combat (#9) and pickup (#7) directions.
**Effort:** 1–2 hours per state once the player rig is the precedent.
**Deliverable:** New `AnimationPlayer` clip + branch in `_update_animation` for each state.
**Notes:** Driven by other systems — don't add states without gameplay reason to use them.

---

### 14. Screen-shake budget

**Why:** Heavy landings (already shipped) and hit-taken (shipped via `plans/done/hud-health.md`) both shake. Still uncovered: pickup / upgrade gain shake, boss impact, environmental impacts. The `add_shake(intensity)` API on `GameCamera` is already there.
**Source:** Internal — `camera/GameCamera.gd` `add_shake` method.
**Effort:** Per-event 5 min; whole remaining pass ~30 min.
**Deliverable:** Pickup/upgrade gain shake, boss-impact shake, environmental impact shake. Polish-checklist skill (tooling #2) should reference this.
**Notes:** Lift directly when polish-checklist is written — they belong together.

---

### 15. Editor → in-game asset cleanup

**Why:** `screenshots/` has 26 local QA images (gitignored). Periodically prune locally so they don't bloat the disk. Not project-affecting; reminder rather than work.
**Source:** Internal.
**Effort:** Trivial.
**Deliverable:** Local `rm -rf screenshots/*` periodically. No automation needed.
**Notes:** Mentioned for completeness; doesn't deserve a real backlog item but worth saying once.

---

### 16. Health/HUD polish — deferred from `plans/done/hud-health.md`

**Why:** The hud-health plan shipped Phases 1–5 (health state, HUD, color gradient, hit-stop, critical pulse, death sequence with fade). A handful of "sizzle" items were intentionally punted as either dependent on missing systems or needing real playtesting against enemies. This is the bin for them.

**Source:** Internal — final discussion in the hud-health work session.

**Effort:** Each sub-item is a sub-half-day. Pick off opportunistically; not a single session.

**Deliverable (sub-items):**

- **Audio assets — `player_hit.ogg` + `player_death.ogg`.** The call sites are already wired in `player.gd:take_damage` and `player.gd:_handle_death`, but the keys are not in `AudioManager.SFX` because `preload` would crash without the files. To activate: drop the `.ogg` files into `assets/audio/sfx/` and add two rows to `AudioManager.SFX` (per the comment in that file). Until then, both calls silently `push_warning`.
- **Movement-speed reduction at low health.** Floor `MOVE_SPEED` to ~70% when `_health / MAX_HEALTH < 0.25`. Risk: feels punishing without enemies to tune against. Hold until enemies (#9) ship.
- **Critical-health music duck / ominous loop.** Depends on a music subsystem, which we don't have yet. Sequence after #11 (audio system music tracks) and #6 (transition stinger) — not before.
- **Damage vignette / chromatic aberration.** Red glow at screen edges when low; subtle CA when critical. Shader work — own session.
- **Knockback on hit.** Push the player away from the damage source. Requires a damage *source* parameter on `take_damage(amount, source: Node2D)` — only meaningful once enemies (#9) call into it. Defer.
- **Hit-flash sprite (white silhouette flicker).** A shader on the rig that drives modulate-additive-white during the hit-stop. Plays well with the existing 1.2s i-frame alpha flicker but adds the "I just got *hit*" punch beat. Pairs with hit-stop; small shader job.
- **Floating damage numbers.** A short-lived `Label` that spawns at hit position, drifts up, fades. Mostly meaningful with multi-tier damage values, i.e. once enemies have damage variation.

**Notes:** Cross-references: #9 (enemies) gates knockback + meaningful damage numbers; #11 (audio music) gates critical music. The hit-flash and audio assets can ship independently of any other work whenever there's appetite.

---

