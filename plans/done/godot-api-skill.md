# Plan: Add `godot-api` Claude Code skill — local searchable Godot class reference

**Status:** complete (2026-04-26). Skill built end-to-end by a side-Claude session per this plan. Implementation landed in commits `f9c4d5e` (scaffold) + `9cadb16` (generated doc_api/). Merged to main as `e819c5e` (merge commit) and then deliberately parked in `f4ee582` — `SKILL.md` renamed to `SKILL.md.disabled` so Claude Code's discovery ignores it pending evidence the team needs it. See `.claude/skills/godot-api/README.md` for parked state and re-enable instructions.

**Estimated time:** 2–3 hours, mostly spent waiting on the sparse-checkout and the converter.

**Recommended model:** Sonnet 4.6 (`claude-sonnet-4-6`). This plan is fully specified mechanical work — no architectural reasoning needed, just careful execution. Sonnet is meaningfully faster and cheaper than Opus with no quality loss on tasks like this. If launching the side-Claude with the wrong default model, switch with `/model claude-sonnet-4-6` after starting. Haiku 4.5 may work but Sonnet is the safer middle for multi-file edits.

## Why this exists

Today, when Claude needs to know "is the method called `move_and_slide()` or `move_and_collide()`?" or "what signals does `Area2D` emit?", it relies on training memory + reading project code + occasional web search. This skill makes Godot's class API directly readable in-session — fast, definitive answers, no guessing.

It also gives the team a 800-line `gdscript.md` syntax reference that doubles as a human-readable cheat sheet.

The skill is **language-agnostic** (despite living inside the .NET-locked godogen repo) — godogen's converter has a `--lang gdscript` flag. We lift just this skill, strip C# references, ship to GDScript-only.

Background: see `backlog/tooling-pipeline.md` item 5b and `research/tools/godogen.md`. Source files live at https://github.com/htdt/godogen/tree/master/claude/skills/godot-api .

---

## Hard constraints (read before starting)

1. **Branch:** create and work on `skill/godot-api`. **Never push to `main`. Never merge.**
2. **Scope is locked to `.claude/skills/godot-api/` and the project root `.gitignore`.** Do not modify any game code, scenes, or other docs.
3. **GDScript only.** Strip all C# references from the SKILL.md you lift. Do not lift `csharp.md` from godogen.
4. **At the end, hand back to the user** with a `git diff main..HEAD` summary. Do not push. Do not merge.
5. **`doc_api/` IS committed** (the generated per-class Markdown). The `_build/` working directory containing Godot's source clone is **NOT** committed (gitignored).

---

## Step-by-step

### 1. Branch from the latest main

```bash
git status                           # should be clean
git checkout main && git pull        # match remote
git checkout -b skill/godot-api
```

### 2. Lift files from godogen master

Use `curl` to fetch raw GitHub URLs (no fork needed, MIT-licensed). Save into `.claude/skills/godot-api/`:

| Source URL | Save to |
|---|---|
| `https://raw.githubusercontent.com/htdt/godogen/master/claude/skills/godot-api/SKILL.md` | `.claude/skills/godot-api/SKILL.md` (then edit — see step 4) |
| `https://raw.githubusercontent.com/htdt/godogen/master/claude/skills/godot-api/gdscript.md` | `.claude/skills/godot-api/gdscript.md` (as-is) |
| `https://raw.githubusercontent.com/htdt/godogen/master/claude/skills/godot-api/tools/godot_api_converter.py` | `.claude/skills/godot-api/tools/godot_api_converter.py` (as-is) |
| `https://raw.githubusercontent.com/htdt/godogen/master/claude/skills/godot-api/tools/class_list.py` | `.claude/skills/godot-api/tools/class_list.py` (as-is — imported by the converter) |

Do **not** lift `csharp.md`. We're GDScript-only.

Verify each download succeeded (non-zero size, looks like its expected content).

### 3. Build `doc_api/` — generate the per-class Markdown

Sparse-checkout Godot's class XML docs. The output `_build/` directory is gitignored (step 6) — it just holds Godot's source long enough to run the converter:

```bash
mkdir -p .claude/skills/godot-api/_build
cd .claude/skills/godot-api/_build
git clone --depth 1 --filter=blob:none --sparse https://github.com/godotengine/godot.git
cd godot && git sparse-checkout set doc/classes
cd ../..   # back to .claude/skills/godot-api/
```

Run the converter to produce per-class files + `_common.md` and `_other.md` indexes:

```bash
python3 tools/godot_api_converter.py \
  -i _build/godot/doc/classes \
  --split-dir doc_api \
  --unified-classes \
  --method-desc first \
  --lang gdscript
```

Expected output: ~128 common-class files + several hundred other classes, all in `.claude/skills/godot-api/doc_api/`.

Verify:
- `.claude/skills/godot-api/doc_api/_common.md` exists and lists ~128 classes
- `.claude/skills/godot-api/doc_api/_other.md` exists
- Per-class files exist — spot-check `CharacterBody2D.md`, `Camera2D.md`, `AudioStreamPlayer.md`
- A spot-checked file lists methods, properties, signals in compact form

### 4. Edit `SKILL.md` — strip C# refs and adjust frontmatter

The lifted file has:
- A `**C# syntax reference:**` paragraph pointing at `csharp.md`. **Remove it entirely** (we're GDScript-only).
- A bootstrap line: `Bootstrap if doc_api is empty: bash ${CLAUDE_SKILL_DIR}/tools/ensure_doc_api.sh`. **Replace** with a reference to the build wrapper from step 5: `Bootstrap if doc_api is empty: bash .claude/skills/godot-api/tools/build.sh`
- Frontmatter has `context: fork`, `model: sonnet`, `agent: Explore` — these are godogen-specific conventions and may not be honored by Claude Code natively. **Keep them for now** but add an HTML comment after the frontmatter:
  ```
  <!-- NOTE: context/model/agent fields lifted from godogen. Whether Claude Code
       honors them natively is verified in backlog/tooling-pipeline.md item #5.
       Until that's confirmed, this skill may run inline in the main context.  -->
  ```

### 5. Write `tools/build.sh` — rebuild wrapper

Create `.claude/skills/godot-api/tools/build.sh`:

```bash
#!/usr/bin/env bash
# Rebuild .claude/skills/godot-api/doc_api/ from the latest Godot source.
# Run from the project root. Re-run after Godot ships a new version.
set -euo pipefail

SKILL_DIR=".claude/skills/godot-api"
BUILD_DIR="$SKILL_DIR/_build"

# Sparse-checkout Godot's doc/classes (skip if already present)
if [ ! -d "$BUILD_DIR/godot/doc/classes" ]; then
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    git clone --depth 1 --filter=blob:none --sparse https://github.com/godotengine/godot.git
    cd godot
    git sparse-checkout set doc/classes
    cd ../../../..
else
    echo "Godot source already present in $BUILD_DIR — pulling latest"
    cd "$BUILD_DIR/godot"
    git pull --depth 1 origin master
    cd ../../../..
fi

# Run the converter
python3 "$SKILL_DIR/tools/godot_api_converter.py" \
    -i "$BUILD_DIR/godot/doc/classes" \
    --split-dir "$SKILL_DIR/doc_api" \
    --unified-classes \
    --method-desc first \
    --lang gdscript

echo "Done. doc_api/ regenerated in $SKILL_DIR/doc_api/"
```

Make it executable: `chmod +x .claude/skills/godot-api/tools/build.sh`.

### 6. Update root `.gitignore`

Append:
```
# godot-api skill build cache (Godot source clone, regenerated by tools/build.sh)
.claude/skills/godot-api/_build/
```

The `doc_api/` directory IS committed.

### 7. Verify before committing

```bash
git status
# Expected: only .claude/skills/godot-api/** and .gitignore changes.
# NOT expected: any changes to game code, scenes, README.md, etc.

ls -la .claude/skills/godot-api/
# Expected: SKILL.md, gdscript.md, doc_api/ (folder), tools/ (folder)
# NOT expected to be in git: _build/ (gitignored)

wc -l .claude/skills/godot-api/doc_api/CharacterBody2D.md
# Expected: tens of lines (compact format), not hundreds

head -20 .claude/skills/godot-api/doc_api/_common.md
# Expected: a markdown list of class names with brief descriptions
```

If any of these are off, stop and figure out why before committing.

### 8. Commit

Make 1–3 commits on the branch. One commit is fine if it's tidy. If splitting:

1. **Add godot-api skill scaffold** — `SKILL.md`, `gdscript.md`, `tools/godot_api_converter.py`, `tools/class_list.py`, `tools/build.sh`, `.gitignore` update
2. **Generate godot-api doc_api/ from Godot source** — the per-class `doc_api/*.md` files

Don't squash. Don't amend. Just commit.

### 9. Hand back

Run and report:

```bash
git log main..HEAD --oneline
git diff main..HEAD --stat
ls .claude/skills/godot-api/doc_api/ | head -20
```

Then end your turn with a brief summary:
- What got built
- Total file count under `doc_api/`
- One spot-checked class file (the contents look reasonable)
- Reminder: branch is `skill/godot-api`, **not pushed, not merged**, ready for review

**Do not push. Do not merge to main. Do not run `git push -f` for any reason.**

---

## If something goes wrong

- **`python3` missing**: macOS ships it; `which python3` to confirm. If absent, `brew install python` or stop and report.
- **Sparse checkout returns the full Godot repo (slow, ~GB)**: confirm `git sparse-checkout set doc/classes` ran successfully. The flags `--filter=blob:none --sparse` should keep the download small. If it's taking >10 min, abort with Ctrl-C and re-do step 3.
- **Converter errors with `from class_list import …`**: confirm `tools/class_list.py` was lifted from godogen. The converter `import`s it as a sibling module.
- **`doc_api/` ends up empty**: check the converter's stdout for warnings. The `--unified-classes` flag filters to the ~128-class CLASS_UNIFIED list — verify that list exists in `class_list.py`.
- **Anything else unexpected**: stop, commit current state to the branch, report to the user. Don't try to be clever.

---

## Open questions you can decide yourself

- **Frontmatter `context: fork`** — keep it (we'll test natively later). Don't strip preemptively.
- **Whether to commit `gdscript.md` as-is or trim** — commit as-is. It's already concise (804 lines covering the whole language).

## Open questions to surface to the user, not decide yourself

- Whether to also generate a separate `doc_api_full/` with `--method-desc full` for cases where Claude needs full method descriptions, not just first-sentence. (Default: skip this in v1; flag the option in your hand-back.)

---

## When this is done

The user will review on `skill/godot-api`. If they're happy:
- Merge to main (their call, not yours).
- Move backlog item 5b to "completed" — contents archive into this same plan file under a new "Status: complete" header per the convention in `CLAUDE.md`.
- The skill is then live for every Claude session in this project folder.

If they want changes, expect a follow-up plan or direct edits.
