# Multiplayer Architecture Patterns — 2D Action Games
**Project:** 2D Metroidvania, Godot 4.6.2, GDScript, 2–8 player co-op (possible PvP)
**Written:** 2026-04-28 | **Audience:** technical decision-maker, cost-aware, cheat-conscious

---

## TL;DR

- **Authoritative server** is the gold standard for cheat resistance and consistency, but requires real server hosting spend (~$10–40/mo for 2–8 player indie scale) and meaningful dev complexity.
- **P2P listen-server** (one player hosts) is how most indie co-op games actually ship — zero infra cost, host migration is the hard part, and cheating is trivially easy.
- **Client-side prediction + server reconciliation** is the technique (not an architecture) that makes either topology feel responsive; `netfox` (GDScript, 937 stars) implements this for Godot 4.
- **Snapshot interpolation** handles non-player entities cheaply; lag compensation and lockstep/GGPO are mostly irrelevant at our player count and genre.
- **Recommendation for this project:** Start with GodotSteam P2P listen-server (if shipping on Steam) or GD-Sync (if cross-platform). Layer `netfox` for client-side prediction on player movement. Add dedicated server hosting only when design requires it (e.g., persistent world state, anti-cheat enforcement).

---

## Pattern 1: Authoritative Server

### How it works
A headless server process owns all game state and gameplay logic — position, health, item pickups, hit detection. Clients send inputs; the server computes outcomes and sends authoritative snapshots back. Clients render predictions of their own inputs (see Pattern 4) and reconcile on correction.

### When to use
- You need cheat resistance as a hard requirement (competitive PvP, ranked leaderboards, real-money items).
- Player count and session length justify server hosting costs.
- Your team has backend/devops experience.

### Pitfalls
- Hosting cost: even minimal Fly.io/Edgegap instances add up. For 2–8 players at ~$0.10/session-hour, 10,000 monthly sessions = ~$1,000/mo. Budget this early.
- Dev complexity roughly doubles: you build two versions of physics (client prediction + server authority) and a reconciliation loop.
- Godot's headless server mode is functional but not heavily documented; the community reference is StraySpark's March 2026 walkthrough.
- Godot's built-in MultiplayerAPI degrades above ~40 CCU per server (Rivet benchmarks, cited in Ziva blog Apr 1, 2026).

### Shipped examples at 2–8 player scale
Games like Deeprock Galactic (4-player) and Phasmophobia (4-player) use dedicated servers for session integrity. These are Unity titles, but the architecture is engine-agnostic.

### Citations
- Fiedler, "Dedicated Servers" (principles): https://gafferongames.com/categories/game-networking/ (content ~2014–2018, principles timeless, cited in 2026 Godot threads)
- StraySpark, "Godot 4 Multiplayer Authoritative Server": https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server (~March 2026)
- Ziva, "Godot Multiplayer in 2026: What Actually Works": https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026) — 40 CCU ceiling, Rivet benchmarks
- Edgegap (Hathora replacement): https://edgegap.com/comparison/edgegap-vs-hathora (2026)

---

## Pattern 2: P2P Listen-Server (One Player Hosts)

### How it works
One player's machine acts as both the host and a playing client. Other players connect to the host directly (via relay if NAT prevents direct connection). Godot's `ENetMultiplayerPeer` or `WebRTCMultiplayerPeer` supports this natively. Steam Networking Sockets (via GodotSteam) provides the relay automatically.

### When to use
- Co-op games where cheating between friends is not a concern.
- Zero infra budget — the host pays nothing beyond bandwidth.
- Small player counts (2–8) where host latency advantage is annoying but acceptable.
- Your distribution platform is Steam (GodotSteam handles NAT, relay, and lobbies for free).

### Pitfalls
- **Host advantage:** The host has 0 ms RTT to the server simulation. Other players see 40–120 ms of added lag. In fast-action games this is perceptible; in exploration/co-op Metroidvania, usually tolerable.
- **Host migration:** If the host drops, the session dies. Implementing host migration in Godot requires manual state snapshot + handoff; there is no built-in mechanism.
- **Cheat resistance: zero.** The host runs the authoritative simulation and can trivially modify it. Not suitable for competitive PvP.
- **NAT traversal:** Without Steam or a relay service (GD-Sync, EOSG, noray from netfox), direct P2P connections fail for most home networks.

### Shipped examples
- **Dome Keeper** (Bippinbits, Apr 13, 2026): 8-player online co-op + competitive, built on GodotSteam + Steam Networking Sockets. The GodotCon 2025 talk is the most relevant public case study — Bippinbits added online co-op to an existing ~10,000-line GDScript codebase. This is the closest architectural proof point to our project. $6.1M Steam revenue. Source: Bippinbits GodotCon 2025 presentation; GodotSteam on Codeberg: https://codeberg.org/godotsteam (moved from GitHub Apr 4, 2026).
- Most indie co-op games on Steam use this model: Valheim, Deep Rock Galactic (early versions), Terraria.

### Citations
- Fiedler, "What Every Programmer Needs To Know About Game Networking": https://gafferongames.com/categories/game-networking/
- GodotSteam docs/Codeberg: https://codeberg.org/godotsteam (v4.16.2, 2026; GitHub archived Apr 4, 2026)
- Godot Networking docs (ENet, WebRTC): https://docs.godotengine.org/en/4.6/tutorials/networking/
- Ziva blog (Dome Keeper proof point): https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026)
- GD-Sync (relay + lobby, native Godot 4): https://www.gd-sync.com / Asset Library: https://godotengine.org/asset-library/asset/2347 (v1.0, Apr 24, 2026)

---

## Pattern 3: Pure P2P Lockstep / GGPO Rollback

### How it works
All peers share an identical deterministic simulation. Every frame, each peer sends its inputs for that frame. Classic lockstep waits for all inputs before advancing (adds latency equal to the slowest peer). GGPO-style rollback predicts missing inputs, advances the simulation speculatively, and rolls back + replays when the real input arrives — giving the illusion of zero added latency.

### When to use
- 2D fighting games (Street Fighter, Guilty Gear Strive — the canonical GGPO users).
- Real-time strategy games where determinism is easy to maintain.
- Small player counts (2–4) with tight timing requirements.

### Why it's overkill for a Metroidvania
- Determinism is extremely hard to maintain in GDScript + Godot physics: floating-point differences across platforms, physics steps, and GDScript's dynamic typing all break lockstep silently.
- Metroidvania co-op is not frame-precision-sensitive the way fighting games are. A 50 ms correction is fine when players are exploring different rooms.
- David Snopek's rollback addon (https://gitlab.com/snopek-games/godot-rollback-netcode) exists for Godot but has not had confirmed 2026 updates; production readiness is uncertain.
- Rivet engineering called Godot's lack of built-in rollback "a deal-breaker for serious development" — but that statement applies to competitive games, not co-op exploration.

### Citations
- GGPO library: https://github.com/pond3r/ggpo
- Snopek rollback addon: https://gitlab.com/snopek-games/godot-rollback-netcode (check for 2026 updates before use)
- YouTube: "Rollback netcode in Godot (part 1)": https://www.youtube.com/watch?v=zvqQPbT8rAE
- Ziva blog (Rivet quote on rollback): https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026)

---

## Pattern 4: Client-Side Prediction + Server Reconciliation

### How it works
This is a technique layered on top of an authoritative server (Pattern 1) or a listen-server with one authoritative peer. The client predicts the result of its own inputs immediately (no waiting for a round-trip), then reconciles when the server's authoritative state arrives. If there's a mismatch, the client replays buffered inputs from the correction point forward. Fiedler's 2015 article "Snapshot Interpolation" and "Client Side Prediction" are the definitive references.

Specifically:
1. Client sends input + timestamp.
2. Client immediately applies input locally (prediction).
3. Server applies input, sends back authoritative state + input sequence number.
4. Client discards all buffered inputs before that sequence number.
5. If server state differs from client prediction, client snaps to server state and replays subsequent buffered inputs.

### Cost
- CPU: replaying buffered inputs every reconciliation frame (typically every few frames). For 2–8 players with simple movement physics, this is negligible.
- Complexity: significant. You need a input history buffer, a way to snapshot and restore entity state, and replay logic.

### `netfox` — the GDScript implementation
`foxssake/netfox` (937 stars, last release Nov 23, 2025) implements client-side prediction, lag compensation, and snapshot interpolation for Godot 4 GDScript. It also ships `noray` — a free relay server for P2P NAT traversal. This is the most complete open-source kit available in GDScript today. It has shipped games on Steam. For our project, netfox is the path of least resistance to adding CSP.

- GitHub: https://github.com/foxssake/netfox

### Citations
- Fiedler, "Client Side Prediction": https://gafferongames.com/categories/game-networking/ (~2015, principles current)
- Fiedler, mas-bandwidth.com (active 2026): https://mas-bandwidth.com/author/glenn/ (netcode lib updated Jan 28, 2026)
- netfox: https://github.com/foxssake/netfox (937 stars, GDScript, Godot 4)

---

## Pattern 5: Snapshot Interpolation + Extrapolation

### How it works
For entities not directly controlled by the local player (remote players, enemies, projectiles), the client buffers a short window of received state snapshots (typically 2–3 frames worth at the target tick rate). On each render frame it interpolates between the two most recent snapshots, producing smooth motion even when network packets arrive irregularly. When packets are late, the client extrapolates forward using the last known velocity.

### Why it matters
Prediction is expensive to implement and only makes sense for the locally-controlled entity. Snapshot interpolation is cheap and handles everything else. Combined with CSP for player movement, this gives the appearance of a fully responsive world.

### Godot relevance
`MultiplayerSynchronizer` (built into Godot 4.6) does basic snapshot sync but does not interpolate or extrapolate by default. `netfox` adds proper interpolation on top. For a Metroidvania with 2–8 players, one interpolated `MultiplayerSynchronizer` per player is sufficient; enemies can be server-controlled with simple sync (no prediction needed from the client's perspective).

### Citations
- Fiedler, "Snapshot Interpolation": https://gafferongames.com/categories/game-networking/
- Godot MultiplayerSynchronizer docs: https://docs.godotengine.org/en/4.6/tutorials/networking/

---

## Pattern 6: Delta Compression + Interest Management

### How it works
Instead of broadcasting full world state every tick, only changed fields are sent (delta compression). Interest management culls entities outside a player's relevant area — a player in Room A doesn't receive updates about Room B.

### When to use
- Large open worlds with many entities (MMOs, battle royale, survival sandboxes).
- Player counts where per-player bandwidth becomes meaningful (40+).

### For our project
Overkill at 2–8 players in a Metroidvania. Rooms are already natural interest zones — Metroid-style camera locking means players in different rooms need only minimal cross-room sync (shared item pickup events, boss HP). Basic `MultiplayerSynchronizer` with per-room scope is sufficient. Delta compression is not needed until you exceed ~20 players or have highly dynamic large worlds.

### Citations
- Fiedler, "State Synchronization": https://gafferongames.com/categories/game-networking/
- Mirror Networking docs (Unity, principles transfer): https://mirror-networking.gitbook.io/docs/

---

## Pattern 7: Lag Compensation (Server-Side Rewind)

### How it works
When a player fires a shot, the server rewinds world state to the moment the player clicked (accounting for their RTT) and checks the hit at that historical position. This prevents the "I clearly hit them" problem in hitscan shooters.

### Relevance to a Metroidvania
Low. Metroidvania combat is typically melee, contact-based, or uses slow-moving projectiles — not hitscan. You don't need lag compensation for sword swings or fireballs with visible travel time. If you add guns, it becomes relevant.

### Citations
- Fiedler, "Lag Compensation": https://gafferongames.com/categories/game-networking/
- Valve developer wiki (CS:GO lag compensation, engine-agnostic principles): https://developer.valvesoftware.com/wiki/Lag_compensation

---

## Pattern 8: Anti-Cheat Baseline

| Architecture | What you get for free | What you must bolt on |
|---|---|---|
| Authoritative server | Server validates all inputs; clients cannot lie about outcomes. Item pickups, damage, death — all server-authoritative. | Input validation (sanity-check velocity, teleportation, out-of-range inputs). Rate limiting. Replay analysis. |
| P2P listen-server | Nothing. The host simulates the world and can change any value. Guests can modify memory to lie about inputs. | Social trust (friend groups). Platform reporting (Steam). External cheat scanning (impractical for indie). |
| Pure P2P lockstep | Determinism gives you hash-checking per frame — any deviation is detectable. | Enforcing consequences after detection is still needed. |

For a co-op game played by friends, listen-server anti-cheat is acceptable — the threat model is "griefer in a public lobby," not a coordinated cheat economy. If you add public PvP matchmaking with rankings, you must move to an authoritative server or accept that cheating will occur.

### Citations
- Fiedler, "Hacker Safe Networking" (principles): https://gafferongames.com/categories/game-networking/
- Ziva blog (anti-cheat discussion): https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026)

---

## Decision Matrix

| Game type | Player count | Budget | Cheat tolerance | Recommended pattern |
|---|---|---|---|---|
| Co-op exploration (Metroidvania, Valheim-style) | 2–8 | Low / zero infra | High (friends) | P2P listen-server + GodotSteam or GD-Sync |
| Co-op action (timing-sensitive, public lobbies) | 2–8 | Low–mid | Medium | Listen-server + CSP via netfox |
| Competitive PvP (ranked, public) | 2–8 | Mid ($20–50/mo) | Low | Authoritative server + CSP + lag comp |
| Fighting game / RTS (frame-precise timing) | 2 | Low | Low | GGPO rollback |
| Survival sandbox (public, many entities) | 16–64 | High | Low | Authoritative server + delta + interest mgmt |

---

## Recommendation for This Project (2D Metroidvania, 2–8 Players, Co-op)

**Phase 1 (ship it): P2P listen-server via GodotSteam + `netfox` for CSP**

If shipping on Steam: use GodotSteam (Codeberg, v4.16.2) for relay, NAT traversal, lobby, and matchmaking — all free under Steam's rev-share model. This is exactly what Bippinbits did for Dome Keeper's April 2026 co-op launch. Cost: $0 infra. Complexity: moderate (GodotSteam setup + netfox integration for player movement prediction).

If cross-platform (itch.io, web): use GD-Sync (v1.0, Apr 24, 2026) — the only managed backend built ground-up for Godot 4 GDScript, with a free tier, relay included, and a Discord for support.

Add `netfox` (https://github.com/foxssake/netfox) for client-side prediction on player `CharacterBody2D` movement. Without CSP, remote players feel rubber-banded; with it, local input is instant. Enemies and hazards don't need CSP — use `MultiplayerSynchronizer` with snapshot interpolation for those.

**Phase 2 (if PvP is added): migrate to dedicated server**

If you add competitive PvP (deathmatches, rankings), deploy a headless Godot server on Edgegap (usage-based, starts free). Keep GodotSteam for transport; replace the listen-server peer with a dedicated server peer. This migration is architecturally incremental if Phase 1 is structured with clear host/client role separation.

**What to skip entirely (for now):**
- Rollback / GGPO: not applicable to exploration platformer genre
- Lag compensation: not applicable unless adding hitscan weapons
- Delta compression / interest management: not needed at 2–8 players
- Photon Fusion Godot: still dev preview as of Apr 2026, not production-ready
- Hathora: shut down, closes May 5, 2026
- AWS GameLift / PlayFab: no Godot SDK, enterprise pricing, severe overkill

### Key proof point
Bippinbits (Dome Keeper, $6.1M Steam revenue) added 8-player online co-op + competitive play to a ~10,000-line GDScript codebase using GodotSteam and shipped April 13, 2026. They presented the methodology at GodotCon 2025. This is the strongest available evidence that this stack is viable at our target scale.

---

*Sources: gafferongames.com (Glenn Fiedler, ~2014–2018, principles current); mas-bandwidth.com (Fiedler, active 2026, netcode lib Jan 28, 2026); ziva.sh/blogs/godot-multiplayer (Apr 1, 2026); strayspark.studio (Mar 2026); foxssake/netfox GitHub (Nov 23, 2025); codeberg.org/godotsteam (Apr 2026); gd-sync.com v1.0 (Apr 24, 2026); docs.godotengine.org/en/4.6/tutorials/networking/; Godot forum thread (Apr 2026); Bippinbits GodotCon 2025 talk.*
