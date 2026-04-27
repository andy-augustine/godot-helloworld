# Backlog

Things we want to act on later, separated by domain. Items capture the **what** and the **why** so a future session — including a freshly /clear'd Claude — can pick one up without re-research.

## What's in here

| File | Domain | Examples |
|---|---|---|
| [`gamedev.md`](gamedev.md) | Gameplay systems, content, polish, art for **this** game | Audio system, TileMapLayer art, save/load, enemies, HUD, room aesthetics |
| [`tooling-pipeline.md`](tooling-pipeline.md) | Game-dev tooling — skills, hooks, doc protocol, MCP usage, conventions for **game** work | `visual-qa.md` skill, polish playbook, MEMORY.md convention, forked-context experiment |
| [`claude-collab.md`](claude-collab.md) | Process / pipeline / tooling about **how Claude collaborates with the human dev**, project-agnostic | `/wrapup`, `/preflight`, periodic retrospective agent, skills-earned doc |

## Why split them

These three backlogs evolve at different cadences and serve different audiences:

- **Gamedev items** are specific to *this* game and its scope. They live and die with the project. Polish a heavy landing here, you're not lifting it elsewhere.
- **Tooling/pipeline items** mature into reusable artifacts that should eventually be portable across **other game projects** (card/deck, rogue-like, future Metroidvanias). When something here is stable, it's a candidate to extract into a Godot starter kit.
- **Claude-collab items** mature into reusable artifacts that are portable across **any Claude-Code-driven project**, not just games — slash commands, memory protocols, session bookends apply to a Rust backend project the same as a Godot game.

Mixing the three dilutes all three. When in doubt:
- "If I started a new **Godot project** tomorrow, would I want this?" — yes (about the game itself) → gamedev; yes (helps build *any* game) → tooling-pipeline.
- "If I started **any** Claude-Code project tomorrow (not even a game), would I want this?" — yes → claude-collab.

## Mental model: writers' room → production pipeline → shooting script

Three states an idea can live in. Each has one home:

| State | Lives in | Audience | Mutability |
|---|---|---|---|
| **Writers' room** (raw / WIP / unfinished) | `backlog/*.md` here | Solo lead + Claude | High — rename, merge, delete freely |
| **Production pipeline** (crystallized for team) | GitHub Issue *(starts later when team arrives)* | Whole team | Medium — labels evolve, comments thread |
| **Shooting script** (active execution) | `plans/<feature>.md` | One claimer at a time | Low — locked while in flight |

The `backlog/` folder is the writers' room: a place for Claude and the lead to brainstorm freely without filling the team's inbox with half-thoughts. When an idea is solid enough that another person could read it and act, it graduates out — for now into a refined backlog entry, later (when team arrives) into a GitHub Issue with `idea` or `discussion` labels for collaboration. See [`../ROADMAP.md`](../ROADMAP.md) for the full lifecycle.

## How to add an item

Each backlog item gets a numbered subsection with these fields:

```markdown
## N. Title

**Why:** one or two sentences on the value / pain it removes.
**Source:** link to the research file or note that justified this (or "internal" if it came from playtest).
**Effort:** rough estimate (≤30 min, 1–2 hr, half day, days).
**Deliverable:** the concrete thing we'd produce — a file path, a tool, a doc section.
**Notes:** anything else a future picker-upper would want to know — open questions, sequencing constraints.
```

Keep the title imperative and specific. "Add visual-QA skill" beats "Improve testing." Anchor to a deliverable, not an aspiration.

## How to take an item off the backlog

When work starts:
1. Move the item's contents into a `plans/<slug>.md` if it's multi-phase, OR just start working if it's a single commit.
2. Mark the backlog entry as `**Status:** in progress (YYYY-MM-DD, slug → plans/<slug>.md)` — don't delete it from the backlog yet.
3. When shipped: archive the plan to `plans/done/` per the rule in CLAUDE.md, and remove the item from the backlog file (the plan is now the historical record).

## Long-term vision

This hello-world doubles as a **tooling sandbox**. Items in `tooling-pipeline.md` that prove themselves here — skills used regularly, conventions that stick, hooks that catch real problems — are candidates for extraction into a portable Claude-Code-driven Godot starter kit. We don't extract until something has earned it through repeated use; the bar is "I would copy this into a brand-new Godot project tomorrow and use it on day one."

That extraction doesn't need a separate repo today. It does mean **writing each tooling-pipeline artifact as if it has to stand alone**: skills as standalone Markdown files with no cross-references to project specifics, hooks as standalone scripts, conventions documented in their own files rather than buried in CLAUDE.md. When the day comes to extract, the work should be mostly file-moves, not re-authoring.

`gamedev.md` items have no portability obligation — they're free to assume the full project context.
