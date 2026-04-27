# Plan: v1 — Animated Platformer

**Status:** complete (2026-04-24, commit `3fcc600`)

The first shippable phase of the project: a single-screen playground with a procedurally-drawn `CharacterBody2D` player rig (Polygon2D limbs, no sprites), tight platformer feel (coyote time, jump buffer, variable jump, fast-fall gravity), wall-slide + wall-jump, particle dust on landing/running/wall-sliding, and a foundational AnimationPlayer rig with idle/run/jump/fall/wall_slide/land states. 960x540 viewport, GL Compatibility renderer, no combat/enemies/multi-room, no textures or sprite sheets.

This plan was originally captured retrospectively as `early-requirements/v1-animated-platformer.md` — a 312-line technical spec. That detailed prompt-style retrospective was retired during the 2026-04-27 information-architecture refactor (see `plans/done/refactor-info-architecture.md`); this short description preserves the historical record without the prescriptive pseudocode that was never load-bearing for the project.
