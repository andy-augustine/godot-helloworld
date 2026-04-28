# Multiplayer-for-Godot research crawl — RUNBOOK

| | |
|---|---|
| Drafted | 2026-04-28 |
| Trigger | User-requested research project, post-Beta release |
| Knowledge cutoff being patched | January 2026 (assistant training cutoff) |
| Today | 2026-04-28 — target window for "new" intel is Q4 2025 forward |
| Project context | 2D Metroidvania platformer, Godot 4.6.2 + GDScript, single-player today; Beta released as v0.1.0-beta on 2026-04-27. Want a survey of what it would take to make this game multiplayer. |
| Final deliverable path | `research/multiplayer/survey.md` |

This is a self-contained runbook. A fresh Claude session reading it should be able to execute the entire crawl without any conversation context. If anything in the briefs is ambiguous, prefer following the brief as written — DON'T add scope.

This plan mirrors `research/crawl/PLAN.md` (the Godot-engine intel crawl that ran 2026-04-26). Same shape, same model rules, same phase structure. If you've executed that one, you can skim this and just read the topic briefs.

For the orientation step (e.g., the next session running `/orient`): the user wants this research delivered. They are heading to sleep when this plan is queued, expect to wake up to the synthesis output at `research/multiplayer/survey.md`. **No clarifying questions remain blocking** — the user-decisions checklist below has pre-authorized defaults.

---

## ⚠️ User-decisions checklist (handle BEFORE starting Phase 0)

These are pre-authorized defaults the user accepted before sleeping. If the user updates this PLAN before kicking off, replace the defaults inline and remove this notice.

| Decision | Default | Why this default |
|---|---|---|
| **Game style** | Both **co-op** (shared world, drop-in / drop-out) AND **competitive** (deathmatch / racing). Weight co-op heavier (~70/30) given the current Metroidvania genre. | A Metroidvania extension is naturally co-op — "play through the world together". But the user asked for "best method available" so PvP/competitive should not be excluded. |
| **Player-count target** | **2–8 players** per session. Skip MMO-scale (>32) for this survey. | Realistic for a side-scrolling 2D platformer. Most Godot multiplayer infrastructure targets this range. |
| **Implementation timeline** | **Exploratory / planning** (not active implementation). Survey to inform later choice. | The user said "research project" + heading to sleep. They want a decision-grade map, not an implementation. |
| **Budget posture** | **Cover the spectrum**: free + open-source + paid services. Note pricing where relevant. Don't filter. | The user explicitly asked about "3rd party cloud multiplayer apis/services" so pricing matters but they're collecting options. |
| **Hosting preference** | **No preference assumed.** Cover dedicated server, P2P, relay, listen-server, and managed-service hosting. | Same — user is in survey mode. |
| **Anti-cheat priority** | **Mention but don't deep-dive.** Note where each architecture stands on cheat-resistance; don't enumerate anti-cheat services. | A Metroidvania co-op doesn't need DRM-grade anti-cheat. PvP path may need light validation; cover at a "what you get for free" level. |
| **Platform target** | **Desktop first** (macOS dev, eventual Windows/Linux export). **Web export** noted as a stretch since Godot supports it and changes networking constraints. | Project is currently macOS-only; broader desktop is the natural next step. Web is interesting because of WebRTC implications. |

If any of those are wrong, edit this section before kicking off Phase 0 — the topic agents read this PLAN as their context.

## Pre-authorized decisions (don't re-ask the user)

1. **Five parallel topic agents are OK.** General-purpose agents with web access. Token cost is bounded.
2. **Auto-proceed on surprise.** If the pre-scan finds something concerning (e.g., Godot 5.0 just released with new networking, or Nakama got acquired and changed pricing), DO NOT pause. Note the surprise prominently in the synthesis output and proceed with the plan as written.
3. **Output paths are fixed.** All under `research/multiplayer/`.

## Model selection per role

The orchestrating session (the post-`/clear` session running this plan) should be **Opus 4.7** — multi-step coordination + judgment calls + synthesis-quality evaluation make Opus's reasoning worth it. Set this BEFORE running the plan; switching mid-run is awkward.

Per-agent model overrides (pass via `Agent` tool's `model` parameter):

| Phase | Model | Why |
|---|---|---|
| Phase 0 pre-scan | `sonnet` | Bounded source-id + ranking task. Sonnet sufficient. |
| Phase 1 topic agents (×5) | `sonnet` | Tight briefs, web fetch + summarize. Sonnet speed/cost matters at 5× parallel. |
| Phase 2 synthesis | `opus` | Cross-cutting analysis: dedupe across 6 inputs, rank by relevance, identify contributors, recommend an entry approach. Worth Opus's reasoning premium. |

If for any reason Opus isn't available for the synthesis step, fall back to Sonnet — the briefs are tight enough that Sonnet produces a usable deliverable; just slightly less sharp on cross-cutting judgment.

## Project context (for the agents)

A 2D Metroidvania platformer in Godot 4.6.2 using GDScript. Single-player today. Driven via the godot-mcp-pro MCP plugin from Claude Code. Beta-released as `v0.1.0-beta` on 2026-04-27. 3 themed rooms, pickup-driven movement abilities, simple HUD, single-player save state. No combat / enemies yet. ~960×540 viewport, GL Compatibility renderer, macOS-first development.

Folder layout: see [`STRUCTURE.md`](../../STRUCTURE.md). Key codebase facts agents should know:
- `player/Player.gd` is `CharacterBody2D` with `_physics_process(delta)` running input → state → motion. State machine is enum + `match`, not AnimationTree.
- `autoload/Inventory.gd` and `skills/Skills.gd` are autoloads — multiplayer would have to either replicate them per-peer, run them server-authoritative, or split them into "shared" vs "per-player" state.
- HUD is a `CanvasLayer` with `add_to_group("hud")`.
- Rooms swap via `World.gd`; only the player persists across room transitions.

If the crawl finds *contradictions* with any of the above, surface them prominently. Otherwise no need to repeat known material.

---

## Phase 0 — Pre-scan (single agent, ~30 min, foreground)

**Dispatch as**: `subagent_type: general-purpose`, `model: sonnet`

**Output file**: `research/multiplayer/sourcemap.md`

**Brief (verbatim — copy into agent prompt):**

> Targeted reconnaissance task — under 45 minutes. Identify currently-active venues for multiplayer-game-development discussion in the Godot ecosystem AND in the broader cloud-multiplayer-services space, rank by signal quality, and identify high-signal individual contributors. Do NOT investigate technical content; that's for follow-on agents. This is sources-only.
>
> ## What to find
>
> 1. **Active venues, ranked by signal**:
>    - **Godot multiplayer specifically**: `godotengine/godot` issues + PRs labeled "topic:network", "multiplayer"; `godotengine/godot-proposals` networking-tagged proposals; `godotengine/godot-docs` Multiplayer section; `forum.godotengine.org` Multiplayer subforum; r/godot threads with "multiplayer" / "netcode" in titles.
>    - **Game-networking general**: GAFFER ON GAMES (gafferongames.com — Glenn Fiedler), Yojimbo, the Mirror Networking docs (Unity but principles transferable), Photon docs, ENet docs.
>    - **Cloud / managed multiplayer**: heroiclabs.com (Nakama), Photon Engine, PlayFab, Hathora, Edgegap, Beamable, Steamworks (Steam Networking), Epic Online Services. For each: pricing page, feature page, Godot integration status.
>    - **GitHub orgs**: `heroiclabs/nakama-godot`, `Pamtic/godot-photon-bolt`, any Godot-specific multiplayer integration repos. Note last commit date and stargazer count.
>    - **YouTube**: creators with substantial 2026 multiplayer-in-Godot tutorials (NOT beginner-1-hour-tutorials). Look for series.
>    - **Discord / Mastodon**: Godot official server's #multiplayer channel; gamedev.tv; #netcode tags on Mastodon if active.
>    - **Blogs**: Glenn Fiedler / gafferongames.com (canonical netcode reference), individual Godot dev blogs with 2026 multiplayer content.
>
>    For each: rank as **HIGH** (load-bearing) / **MED** (worth checking) / **LOW** (skip unless desperate). Justify rankings briefly.
>
> 2. **High-signal individual contributors active in 2026** — aim for ~15:
>    - **Godot core**: `lawnjelly` (rendering but adjacent), `Faless` (networking maintainer historically — verify still active), Juan Linietsky / `reduz` directionally, anyone reviewing networking PRs in 2026.
>    - **Community**: prolific multiplayer-tutorial authors, plugin authors who respond well to issues, Discord moderators in the #multiplayer channel.
>    - **Industry**: Glenn Fiedler (gafferongames.com), Nakama / Heroic Labs founders, Photon tech writers if they cover Godot.
>    - For each: name (or handle), domain (e.g., "GDScript RPC", "rollback netcode", "managed services architecture"), primary venue link, why useful (1 sentence), one example contribution if you can find it.
>
> 3. **Recent milestones (post-Jan 2026)**:
>    - Godot 4.6 multiplayer-related changes — `MultiplayerAPI`, `MultiplayerSpawner`, `MultiplayerSynchronizer`, ENet binding, WebRTC binding, what's new / fixed / broken.
>    - 4.7 / 5.0 networking roadmap items.
>    - Nakama, Photon, Hathora release notes 2026 (especially Godot SDK changes).
>    - Steam networking API changes affecting Godot integration.
>    - Any major multiplayer-Godot game launches (commercial titles using the engine for shipped multiplayer) — they're proof points for what's actually viable.
>
> 4. **Sources to skip** — venues that *used* to cover Godot multiplayer but went silent or stale. Saves topic agents from chasing dead links.
>
> ## Output format
>
> One markdown file at `research/multiplayer/sourcemap.md` (~150-250 lines). Sections matching the four areas above. Cite every source with URL + dated activity sample.
>
> ## Surprise reporting
>
> If you discover any of the following, prepend a **⚠️ Surprise** section at the top of the sourcemap:
> - Godot 5.0 has been released
> - A major Godot networking API has been deprecated or replaced (e.g. ENet replaced)
> - Nakama (or another major service) was acquired or changed pricing dramatically
> - Major regression in 4.6.x multiplayer specifically
> - A new multiplayer service launched in 2026 with strong Godot support
>
> Do NOT pause; just flag it.
>
> ## Reporting back
>
> Under 200 words. Where the file is, top-3-most-useful venues you found, top-3-most-useful people you found, and any surprises.

**After this agent returns**: read `research/multiplayer/sourcemap.md`, sanity-check it (no obvious broken sources, a reasonable number of contributors identified, no missing major venues like Nakama or Photon), then proceed to Phase 1.

---

## Phase 1 — Five parallel topic agents (~45 min each, background, dispatched together)

**Dispatch all five in a single message** as `subagent_type: general-purpose`, `model: sonnet`, with `run_in_background: true`. Pass each agent the path to `research/multiplayer/sourcemap.md` and tell them to use it as their source list.

When all five have signaled completion (you'll get notifications), proceed to Phase 2.

### Topic A — Godot built-in multiplayer (HighLevel API)

**Output file**: `research/multiplayer/topic-godot-builtin.md`

**Brief (verbatim):**

> Document the current state (Godot 4.6.2, 2026) of Godot's built-in multiplayer stack. Use the source map at `research/multiplayer/sourcemap.md` for citations. Cite every claim with URL + date.
>
> ## What to cover
>
> 1. **MultiplayerAPI + interfaces** — `SceneMultiplayer`, `MultiplayerPeer` implementations (ENet, WebRTC, WebSocket), how peer IDs work, host vs client distinction.
> 2. **High-level scene replication** — `MultiplayerSpawner`, `MultiplayerSynchronizer`, how they configure replication of properties / spawned scenes, how they interact with authority.
> 3. **RPC system** — `@rpc` annotations, transfer modes (reliable/unreliable/unreliable_ordered), call_local, the call_remote default, how authority gating actually works in 4.6.
> 4. **Transport layers**:
>    - **ENet** (default): use cases, NAT-traversal story (none — needs relay or P2P holepunch), MTU, pros/cons.
>    - **WebRTC**: NAT-traversal story (built-in), STUN/TURN signaling, viability for production deployments, the `webrtc-native` plugin status.
>    - **WebSocket**: when it's the right pick (web exports, simple TCP-based servers).
> 5. **Authority / server modes** — listen server, dedicated server (headless export), pure-P2P. What Godot does well vs poorly in each.
> 6. **Known gaps in 2026** — things devs commonly bolt on (delta compression, interest management, prediction/rollback). Cite Godot proposals tagged with `topic:network` that are accepted/in-progress.
> 7. **For our project specifically** — given the codebase facts (autoloads `Inventory` / `Skills`, `CharacterBody2D` player, room-swap World architecture, single-player save), what's load-bearing to know?
>
> Already known and shipped; do NOT re-discover unless contradicted: project's room/camera architecture (see `STRUCTURE.md`), skill-cards drag/drop, swing-tendril physics. References in `STRUCTURE.md` and `ROADMAP.md`.
>
> ## Output format
>
> Single markdown file ≤300 lines. Sections: (1) TL;DR ≤5 bullets; (2) per-feature subsections with code sketch + citation; (3) "What you get for free vs what you have to build" table; (4) verdict for our project: is built-in enough, or do we need a third-party layer?
>
> Reporting back: under 200 words.

### Topic B — Architecture patterns (authoritative server, P2P, prediction, interpolation, lockstep)

**Output file**: `research/multiplayer/topic-architecture.md`

**Brief (verbatim):**

> Survey the canonical architecture patterns for multiplayer 2D action games. Use the source map at `research/multiplayer/sourcemap.md` for citations. Reference Glenn Fiedler / gafferongames.com extensively — he's the canonical netcode reference. Cite every claim with URL + date.
>
> ## What to cover
>
> 1. **Authoritative server** — the gold standard. State, gameplay logic, hit detection on server. Clients render predictions. Pros: cheat-resistant, consistent. Cons: hosting cost, dev complexity. Identify games that ship this way at the 2-8 player scale we care about.
> 2. **P2P listen-server** — one player hosts, others connect peer-to-peer. Cheap, no infra, but host migration is hard, host has unfair latency advantage, cheat-resistance is poor. Identify games that ship this way (lots of indie co-op).
> 3. **Pure P2P with shared simulation** — lockstep / GGPO-style for fighting games. Probably overkill for our genre but worth a paragraph for completeness.
> 4. **Client-side prediction + server reconciliation** — the technique that makes authoritative-server feel responsive. How it works (predict locally, replay on correction), what it costs (CPU + complexity).
> 5. **Snapshot interpolation + extrapolation** — for non-controlled entities. Buffer received states, interpolate between, extrapolate when packets late.
> 6. **Delta compression / interest management** — how high-end games scale per-player bandwidth. Briefly; not every game needs it.
> 7. **Lag compensation** — server-side rewinding for hit detection (not directly relevant to a Metroidvania but worth knowing for design choices).
> 8. **Anti-cheat baseline** — what each architecture gives you for free, what you have to bolt on.
>
> ## For our project (2D side-scrolling Metroidvania, 2-8 players, mostly co-op)
>
> Which patterns are appropriate? Which are overkill? Provide a recommended architecture (or two, with tradeoffs).
>
> ## Output format
>
> Single markdown file ≤300 lines. Sections: (1) TL;DR ≤5 bullets; (2) per-pattern subsections with one-paragraph explanation, when-to-use, pitfalls, citation; (3) decision matrix: "given X game type, pick Y pattern"; (4) recommendation for our 2D Metroidvania.
>
> Reporting back: under 200 words.

### Topic C — Cloud / managed multiplayer services

**Output file**: `research/multiplayer/topic-cloud-services.md`

**Brief (verbatim):**

> Build a comparison matrix of cloud / managed multiplayer services that integrate (or could integrate) with a Godot 4.6 game. Use the source map at `research/multiplayer/sourcemap.md`. Cite every pricing / feature claim with a URL + the date you visited it.
>
> ## Services to evaluate
>
> Each MUST be assessed for: (a) Godot SDK availability and maturity, (b) what it gives you (matchmaking? lobbies? authoritative server hosting? friends/social? leaderboards? storage?), (c) pricing tiers including the free tier and where the cliff is, (d) self-host vs managed-only, (e) reputation in the indie / Godot community.
>
> 1. **Nakama** (Heroic Labs) — explicit Godot SDK at `heroiclabs/nakama-godot`. Self-hostable + managed (Heroic Cloud).
> 2. **Photon Engine** — PUN / Quantum / Fusion / Bolt. Godot integration story is third-party; quality?
> 3. **Steam Networking** — Steamworks API, P2P relay via Valve's network, free for Steam-distributed games. GodotSteam plugin.
> 4. **Epic Online Services (EOS)** — free for any platform, free for any number of players. Godot SDK status?
> 5. **Hathora** — managed dedicated-server hosting (no networking framework, just hosting). Pricing per session?
> 6. **Edgegap** — globally-distributed dedicated-server orchestration. Pricing model.
> 7. **PlayFab** (Microsoft) — backend services + matchmaking + party. Godot SDK?
> 8. **GameLift** (AWS) — fleet management for dedicated servers. Heavy? Probably yes.
> 9. **Beamable** — backend platform with social, leaderboards, etc.
> 10. **Colyseus** — open-source room-based multiplayer server, Node-based, has Godot client.
> 11. **GitHub: any 2026 newcomers** — flag if found.
>
> ## Output format
>
> Single markdown file ≤400 lines. Sections: (1) TL;DR ≤5 bullets; (2) one-line summary of each service (what it does); (3) **comparison matrix** (table) — service vs Godot SDK status / what's included / pricing tier / self-host availability / reputation; (4) per-service deep-dive (3-6 lines each, with cited features + pricing); (5) recommendation: which 2-3 to seriously evaluate for a 2D co-op Metroidvania, and why.
>
> Reporting back: under 250 words.

### Topic D — 2D platformer / side-scroller multiplayer patterns

**Output file**: `research/multiplayer/topic-2d-coop-patterns.md`

**Brief (verbatim):**

> Find what shipped 2D platformer / Metroidvania / side-scroller games actually do for multiplayer. Use the source map at `research/multiplayer/sourcemap.md`. Cite per-game claims with a postmortem / GDC talk / dev blog URL where possible.
>
> ## Specific games to investigate
>
> Pick from these and cover ~6 of them. The goal is to extract patterns, not exhaustively survey.
>
> - **Towerfall Ascension** — local co-op + competitive arena, 2D pixel art. P2P? Lockstep?
> - **Salt and Sanctuary / Salt and Sacrifice** — Metroidvania, online co-op. Drop-in / drop-out model?
> - **Hollow Knight: Silksong** — N/A as singleplayer, but check if mods or shipped multi.
> - **Castle Crashers** — 4-player co-op brawler.
> - **Risk of Rain 1** — 2D pixel-art roguelike, online co-op.
> - **Magicka 2** — top-down but 4-player co-op patterns are similar.
> - **Spelunky 2** — 4-player online, deathmatch + co-op.
> - **Chasm**, **Death's Gambit**, or other recent indie Metroidvanias with multi.
> - **Brawlhalla** — 2D fighter, rollback netcode at scale (Photon Quantum I think — verify).
>
> ## Patterns to extract
>
> 1. **Connection model** — listen-server / dedicated / P2P / matchmaking-based?
> 2. **Player-count cap** — typical 2/4/8?
> 3. **Drop-in / drop-out** — supported? How is mid-game state synced?
> 4. **Save game model** — host's progress only? Each player has their own saved progress that synthesizes? Co-op session is its own save?
> 5. **Latency tolerance** — does this genre forgive high ping (Metroidvania exploration) or demand low (combat)?
> 6. **Side-scrolling-specific gotchas** — camera following multiple players (split-screen vs zoomed shared camera), differential input lag, room-transition sync.
> 7. **What can we steal for our 2D Metroidvania**?
>
> ## Output format
>
> Single markdown file ≤300 lines. Sections: (1) TL;DR ≤5 bullets; (2) per-game ~4-line block: name + connection model + cap + notes + citation; (3) cross-game pattern summary: what does the genre converge on?; (4) recommendation for our project: design choices to lock in early.
>
> Reporting back: under 200 words.

### Topic E — KOLs, plugins, sample repos, video courses

**Output file**: `research/multiplayer/topic-kols-tooling.md`

**Brief (verbatim):**

> Identify the people, plugins, sample repos, and video courses that an indie dev should know about for Godot 4.6 multiplayer. Use the source map at `research/multiplayer/sourcemap.md`. Cite every individual / repo / course with URL + the activity / star / view count you observed.
>
> ## What to find
>
> 1. **KOLs (Key Opinion Leaders)** — aim for 10-15.
>    - Industry-wide netcode authorities relevant to game dev: Glenn Fiedler (gafferongames.com), the GGPO author Tony Cannon, anyone at Heroic Labs / Photon who writes publicly.
>    - Godot-community multiplayer specialists: tutorial-makers, plugin authors, the Faless networking maintainer (verify activity), forum top-answerers in #multiplayer.
>    - For each: name + handle, domain, link, why follow, ONE example post / video / commit.
> 2. **Sample / reference repos** — open-source Godot 4 multiplayer games or examples. Aim for 5-8.
>    - Official Godot demos (multiplayer-bomber, etc.) — current state.
>    - High-quality community repos showing: lobby + matchmaking, dedicated-server export, drop-in co-op, ENet vs WebRTC.
>    - For each: repo URL, last commit date, what it demonstrates, how applicable to our project.
> 3. **Plugins / addons** — Asset Library or GitHub-distributed.
>    - Multiplayer-specific: webrtc-native, GodotSteam (if it covers networking), nakama-godot, any 2026 newcomers.
>    - For each: name, repo, last commit, what it solves, what it doesn't.
> 4. **Video courses / tutorial series** — meaningful ones (4+ hour courses or 6+ video series, NOT 30-minute walkthroughs).
>    - YouTube series (GDQuest, kidscancode, Brackeys equivalent if active in Godot).
>    - Paid courses (Udemy, Zenva, GameDev.tv) with current content.
>    - For each: link, length, last updated, what it covers.
> 5. **Books / written resources** — Glenn Fiedler's articles, anything else canonical.
>
> ## Output format
>
> Single markdown file ≤300 lines. Sections: (1) TL;DR — top 5 KOLs, top 3 sample repos, top 3 plugins; (2) per-category lists with the citations above; (3) recommended-reading-order for someone starting from zero on Godot multiplayer.
>
> Reporting back: under 200 words.

---

## Phase 2 — Synthesis (single agent, ~30 min, foreground after all 5 finish)

**Dispatch as**: `subagent_type: general-purpose`, `model: opus`

**Output file**: `research/multiplayer/survey.md` (the canonical deliverable for the user)

**Brief (verbatim):**

> Synthesize five topic-research outputs into a single canonical decision-grade survey for the user. Inputs:
>
> - `research/multiplayer/sourcemap.md`
> - `research/multiplayer/topic-godot-builtin.md`
> - `research/multiplayer/topic-architecture.md`
> - `research/multiplayer/topic-cloud-services.md`
> - `research/multiplayer/topic-2d-coop-patterns.md`
> - `research/multiplayer/topic-kols-tooling.md`
>
> Read all six. Produce one markdown file at `research/multiplayer/survey.md`, ≤700 lines, with these sections in order:
>
> 1. **TL;DR — the recommended path** — given a 2D side-scrolling Metroidvania, currently single-player in Godot 4.6.2, that wants to add 2-8 player co-op (and possibly competitive). Make a concrete recommendation: which architecture, which transport, which (if any) cloud service. ≤8 bullets. Explain reasoning in one sentence per bullet.
> 2. **The decision tree** — a flowchart-shaped section (using markdown nesting) walking the user through the choices: "do you want hosted servers?", "do you need NAT traversal?", "are you OK with self-hosting?", "do you need a friends list?". Each node points to a specific recommendation.
> 3. **Architectures, ranked for our use case** — top-3 ranked. Each: 4-line description, when-to-pick, when-to-avoid, complexity rating (1-5).
> 4. **Cloud services, ranked for our use case** — top-3 (or top-3 + "DIY"). Same shape.
> 5. **Godot-specific notes** — what works well in 4.6.2, what's missing, what's commonly bolted on. Pull from topic A.
> 6. **Patterns from shipped games** — 4-6 case studies from topic D, each as a tight paragraph with takeaways.
> 7. **Contributors to follow** — top 8-10 from topic E.
> 8. **Sample repos to study** — top 4-5 from topic E.
> 9. **Recommended reading order** — 5-step ladder, "if you start from zero, read these in this order."
> 10. **Open questions for the user** — things only the user can decide that affect implementation: PvP weight, anti-cheat priority, web-export support, hosted-server budget tolerance, etc. List 4-8.
> 11. **Surprises** — anything pre-scan or topic agents flagged as a major scope-changer. If nothing surprising, state "none."
> 12. **Glossary** — terms encountered for the first time, with one-line definitions.
>
> Tone: terse, factual, source-cited. No hedging. If a finding is provisional, say "provisional" and explain why; otherwise state it as fact.
>
> When finished, post under 250 words: file path, the recommended path in one sentence, the top 3 contributors to follow, and the top 3 services / approaches.

---

## Final cleanup (after synthesis lands)

The orchestrating session should:

1. Read the synthesis output and verify it covers the 12 required sections.
2. Update `feedback_*.md` memory files ONLY if the synthesis surfaces a high-bar reproducible+root-caused+tested rule. Most multiplayer findings are forward-looking design decisions — not "rules to internalize". Skip the memory step unless something truly clicks.
3. Commit + push the entire `research/multiplayer/` directory.
4. Move `plans/multiplayer-research.md` → `plans/done/multiplayer-research.md` with status line marking complete + commit hashes.
5. Update `ROADMAP.md` "Most recent ship" / "Recent research artifacts" row to point at `research/multiplayer/survey.md`.
6. Report final summary to the user: where the deliverable is, how long the crawl took, the recommended path in one sentence, the top open questions for them.

## Estimated total time

~2.5 hours wall clock. ~30 min pre-scan + ~45 min topic-agents-in-parallel + ~45 min synthesis (longer than the Godot-intel synthesis because the recommendation-shape is more demanding) + ~15 min cleanup. User can sleep through it.

## On rerun

Re-running this crawl in N months: just delete `research/multiplayer/*.md` (keep this PLAN.md) and re-execute. The plan is intentionally calendar-agnostic — the agents will fetch what's new since *that* run, not since this one.
