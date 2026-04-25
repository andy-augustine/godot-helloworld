# godogen — research notes

| | |
|---|---|
| Repo | https://github.com/htdt/godogen |
| License | MIT |
| Status | **Active** — pushed 2026-04-25, ~3,000 stars |
| Researched | 2026-04-25 |

## Verdict

**Mine concepts; do not adopt.** godogen is .NET / C#-locked and 3D-leaning. Wholesale adoption would force the team onto C# and the Mono build of Godot — explicitly out of scope. But several of its conventions translate cleanly to a GDScript project.

## Hard constraints (why we can't adopt wholesale)

**Important nuance — the `godot-api` skill is the exception.** It's a doc-lookup tool (Godot class API reference + GDScript syntax sheet) that's language-agnostic; the converter has a `--lang gdscript` flag. We **can** lift that skill on its own without inheriting any C# baggage. See backlog item 5b.

The .NET lock applies to godogen's **code-generation** skills (task-execution, scene-generation, asset-gen pipelines, etc.). Three independent confirmations of the .NET requirement for those:

1. `setup.md`: *"The **.NET edition** is required — the standard Godot build cannot run C# scripts."*
2. README "What skills do" section: *"**C# / .NET 9** — all generated code uses C#."*
3. April 2026 changelog: *"All skills and generated code migrated from GDScript to C# / .NET 9"* — explicit migration commit, GDScript path was deliberately removed.
4. `gdscript-vs-csharp.md` is a justification document for the migration, not a fallback path.

Every code template, scaffold stub, and engine-quirk rule in the repo assumes C#.

## What's actually in there

godogen is a **single-orchestrator pipeline** with sub-skills loaded progressively to stay within one context window. The README emphasizes "single context, progressive loading" — it is not a multi-agent system.

### Skills (3 top-level, ~12 sub-files)

| Skill / sub-file | Purpose |
|---|---|
| `godogen/SKILL.md` | Orchestrator, routes to sub-files |
| `godogen/visual-target.md` | Generate one reference image first, anchor downstream stages |
| `godogen/decomposer.md` | Risk-first PLAN.md generation |
| `godogen/scaffold.md` | Architecture + skeleton + STRUCTURE.md |
| `godogen/asset-planner.md` | Budget-aware asset plan |
| `godogen/asset-gen.md` | Image / video / 3D generation tooling |
| `godogen/task-execution.md` | Implementation loop |
| `godogen/scene-generation.md` | Scene-builder vs runtime-script split |
| `godogen/quirks.md` | Engine gotchas (some C#-only, many universal) |
| `godogen/capture.md` | Per-platform `run_godot` screenshot/video wrapper |
| `godogen/visual-qa.md` | Static / Dynamic / Question modes |
| `godogen/test-harness.md`, `rembg.md`, `android-build.md` | Niche |
| `godot-api/SKILL.md` | **Forked-context** API lookup (heavy docs in side context). **Language-agnostic** — the converter has `--lang gdscript`. Liftable as-is for GDScript projects. |
| `visual-qa/SKILL.md` | **Forked-context** visual diff (heavy screenshot bytes in side context) |

### LLM asset pipeline (real, not aspirational)

godogen has working integrations with paid LLM image / video / 3D APIs:

| Backend | Cost (theirs) | Use |
|---|---|---|
| Gemini 3.1 flash image | 5–15¢ / image | Reference characters, precise prompt following |
| xAI Grok image | ~2¢ | Textures, simple objects |
| **xAI Grok video** | varies | **Animated sprite generation** — reference → pose → video → frame extraction → loop trim |
| Tripo3D | ~37¢ / model | Image → 3D + biped rig + retarget (3D-only) |

The Grok-video → 2D-animated-sprite path is the genuinely 2D-relevant piece. Implementation lives in `claude/skills/godogen/tools/` (Python). We did not enumerate the source.

### Document protocol

PROJECT.md describes versioned files used as inter-stage communication: `PLAN.md`, `STRUCTURE.md`, `ASSETS.md`, `MEMORY.md`. Stages produce/consume these instead of relying on chat history — survives context compaction.

### Forked-context skills

Two skills (`godot-api`, `visual-qa`) declare `context: fork` and `model: sonnet` in frontmatter. Heavy payloads load in a side context with their own model selection; main orchestrator stays focused. **Caveat: I did not verify Claude Code natively recognizes `context: fork` — may be godogen-specific tooling. Test before relying on it.**

### Engine quirks file

`claude/skills/godogen/quirks.md` accumulates real engine-level gotchas. Several are C#-specific (SetScript disposal, etc.), but the **Godot-engine** ones (Camera2D.MakeCurrent ordering, ArrayMesh GenerateNormals, MultiMesh save bug, deferred collision state changes) apply to GDScript projects equally.

## What's worth lifting (concept-by-concept)

| Concept | Translatable? | Effort | Value |
|---|---|---|---|
| Visual-QA Static/Dynamic/Question taxonomy | **Yes** — wraps our existing `get_game_screenshot` / `compare_screenshots` MCP tools | 2–4 hr | High |
| Document protocol (PLAN.md + MEMORY.md added to our docs set) | **Yes** | 30 min convention + ongoing | Medium |
| Engine quirks file (seed from theirs, drop C#-only) | **Yes** | 1 hr | Medium |
| Risk-first decomposition (`decomposer.md`) | **Yes** — useful before any major capability | 1–2 hr | Medium |
| Forked-context skills | **Untested** in our setup; needs verification | Spike (1 hr) | Unknown — could be high if it works |
| Animated sprite pipeline (Grok video → frame extraction) | **Yes for 2D**, but cost-uncertain | Spike (half day) | Speculative |
| Capture command builder (`capture.md`) | **No** — we use MCP, not CLI screenshots | — | — |
| Asset planner / asset-gen / 3D model pipeline | **No** for 2D | — | — |
| Scene-builder vs runtime split | **Partial** — godot-mcp-pro creates scenes via tool calls; concept of "what state exists at which phase" still useful as a note | 15 min note in GODOT_NOTES.md | Low |

## Caveats / what wasn't verified

- I read `SKILL.md` heads and key sub-files; did not exhaustively review every line.
- I did not run godogen's animated-sprite pipeline. Cost claims are theirs; would need to validate on a real character.
- `context: fork` frontmatter behavior in Claude Code is **unverified**. May require godogen's `publish.sh` machinery.
- The "single context, 1M-token" claim is plausible based on file structure but I did not run a long pipeline to verify in practice.
