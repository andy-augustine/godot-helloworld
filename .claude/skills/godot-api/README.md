# godot-api skill — PARKED, NOT ACTIVE

This folder contains a fully-built Claude Code skill for looking up Godot's class API and GDScript syntax. It is **deliberately disabled**: `SKILL.md` has been renamed to `SKILL.md.disabled` so Claude Code's skill discovery ignores it.

## Why parked

The decision to keep this off the active-skills list is intentional: the project wants to first measure whether GDScript hallucinations or other in-session friction are common enough to justify changing how Claude works. Activating a skill can shift Claude's behavior in subtle ways (which docs it consults, how it phrases recommendations, how the context window is used). We're holding the change until we have a real signal.

The work itself — converter, docs, syntax reference — is fully usable for **humans** as is. `gdscript.md` is an 800-line GDScript cheat sheet anyone on the team can read.

## What's in here

| Path | Purpose |
|---|---|
| `SKILL.md.disabled` | The skill recipe (renamed to avoid discovery). Tells Claude how to look up classes when active. |
| `gdscript.md` | GDScript syntax reference — types, control flow, signals, lambdas, etc. Useful for humans now, for Claude when activated. |
| `doc_api/_common.md` | Index of ~128 commonly-used classes, with brief descriptions. |
| `doc_api/_other.md` | Index of all other classes. |
| `doc_api/<ClassName>.md` | One file per Godot class — methods, properties, signals, constants in compact form. ~130 files total. |
| `tools/godot_api_converter.py` | Python script that converts Godot's source XML class docs into compact Markdown. |
| `tools/class_list.py` | Curated lists of classes (CLASS_UNIFIED for the ~128-class core set). |
| `tools/build.sh` | Wrapper script that re-runs the converter — use after a new Godot release. |
| `_build/` (gitignored) | Sparse-checkout of Godot's source. Created by `tools/build.sh`. Don't commit. |

## How to activate (later, when ready)

One file rename:

```bash
git mv .claude/skills/godot-api/SKILL.md.disabled .claude/skills/godot-api/SKILL.md
git commit -m "Activate godot-api skill"
```

Restart any active Claude Code sessions to pick up the new skill. Verify with `/skills` in a session — `godot-api` should appear in the list.

To **deactivate** again later:

```bash
git mv .claude/skills/godot-api/SKILL.md .claude/skills/godot-api/SKILL.md.disabled
```

## How to rebuild after a Godot version bump

When Godot ships a new version (4.7+), regenerate the per-class docs so they match:

```bash
bash .claude/skills/godot-api/tools/build.sh
git add .claude/skills/godot-api/doc_api/
git commit -m "Regenerate godot-api doc_api for Godot X.Y"
```

The `_build/` directory is gitignored and will be cleaned up automatically by re-runs.

## When to revisit the parked decision

Activate this skill if/when:

- A team member reports Claude inventing a Godot method/signal/property that doesn't exist
- Audio, tilemap, or save-system work hits API uncertainty Claude can't resolve from its training memory
- The team starts a new project (card/rogue-like) where API recall matters from day one
- Godot 4.7+ ships and we want Claude to know the new APIs immediately rather than waiting for training updates

Until then, this skill stays parked.
