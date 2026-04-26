---
description: Orient on this Godot project — read ROADMAP.md, find active plan, confirm before executing.
---

Read [`ROADMAP.md`](ROADMAP.md) to orient on this project. ROADMAP.md is the single TOC — it covers current state, active in-flight plans, recent ships, the backlog, the lifecycle (idea → backlog → plan → execute → archive), and where every doc lives.

After ROADMAP.md, check the [`plans/`](plans/) directory for any active specs. If a plan is ready to execute (status: not started, or in-progress paused), read it in full. Confirm the approach with me before starting any code or scene changes.

Per project conventions:

- **New subsystems run in polish-mode** ([`CLAUDE.md`](CLAUDE.md)) — plan in phases, confirm, build polished, don't skip game-feel passes.
- **Commit after each phase**, with the phase name in the message subject and the rationale in the body.
- **Archive completed plans** to `plans/done/` per the rule in CLAUDE.md.
- **Always log major work first** (project memory) — write the plan to disk before executing if one doesn't already exist.

If `plans/` is empty, ask me what to pick up next — the answer is usually in [`backlog/gamedev.md`](backlog/gamedev.md) or [`backlog/tooling-pipeline.md`](backlog/tooling-pipeline.md).

If `plans/` has multiple files, ask which one I'm picking up before reading them all (saves tokens).
