# Multiplayer Survey — Decision-Grade Synthesis

**Generated:** 2026-04-28
**Project:** 2D Metroidvania, Godot 4.6.2 + GDScript, single-player Beta (v0.1.0-beta, 2026-04-27), targeting 2–8 player co-op (possibly PvP)
**Platforms:** macOS dev → Windows/Linux/Steam release
**Inputs synthesized:** sourcemap.md, topic-godot-builtin.md, topic-architecture.md, topic-cloud-services.md, topic-2d-coop-patterns.md, topic-kols-tooling.md

---

## 1. TL;DR — The Recommended Path

- **Architecture: P2P listen-server with one host as authority.** Lowest infra cost ($0), proven by Dome Keeper at 8-player scale in GDScript on Apr 13, 2026. Genre-appropriate; cheating between friends is not the threat model.
- **Transport (Steam build): GodotSteam + Steam Networking Sockets.** Drop-in `MultiplayerPeer`; Valve handles relay, NAT traversal, lobbies, matchmaking; zero recurring cost; battle-tested. (Codeberg, v4.18.1, Apr 5 2026.)
- **Transport (cross-platform fallback): Epic Online Services via the EOSG plugin (3ddelano, v2.2.9, 289 stars).** Free relay + lobby + voice for non-Steam builds; cleanest second transport.
- **Responsiveness layer: `netfox` (foxssake, 937 stars, GDScript, v1.35.3 Nov 2025).** Built-in API has no client-side prediction — without netfox, remote players rubber-band above ~50ms RTT, which is fatal for a platformer.
- **Backend / persistence: Talo (MIT, v0.45.0 Apr 4 2026), self-hosted or free tier.** Leaderboards, cloud saves, channels — sits alongside the transport, not replacing it.
- **Defer dedicated servers until PvP demands them.** If competitive PvP ships, deploy a Godot `--headless` export on Edgegap (~$0.14/session-hour, no Godot plugin required); architect Phase 1 with clear host/client role separation so the migration is incremental.
- **Player cap target: ship 2-player co-op v1, architect for 4, gate 8 behind a bounded mode.** Genre-converged answer (Salt and Sacrifice, Spelunky 2, Castle Crashers).
- **Save model: host-owns-world, guest-owns-character.** 15+ years of Castle Crashers / Salt and Sacrifice validation; commit `GameState` vs `PlayerState` schemas before writing networking code.

**Verdict on the user's four hopes:**

| Hope | Verdict | One-line reason |
|---|---|---|
| 1. Godot built-in is enough | **PARTIAL** | Transport + replication + RPC are free and shipped Dome Keeper; missing CSP, lobby, NAT traversal, matchmaking — bolt-ons required. |
| 2. Good OSS option | **TRUE** | netfox (CSP, GDScript) + Nakama (backend, Docker) + Talo (persistence, MIT) cover the stack with no vendor lock-in. |
| 3. Steam services | **TRUE** | GodotSteam is the strongest pick in the entire matrix; Dome Keeper is the proof point. |
| 4. AWS cheap+scalable | **FALSE** | GameLift is ~$1,330/mo single-region with no Godot SDK; raw EC2 works (~$20–50/mo) but is self-managed VPS, not "AWS cheap+scalable" as a managed service. |

---

## 2. The Decision Tree

- **Are you shipping on Steam (now or v1)?**
  - **Yes** → **GodotSteam + Steam Networking Sockets** (free, relay, NAT, lobbies). Skip the rest of this tree unless you also need cross-platform.
    - Need CSP for player movement? → add **netfox**.
    - Need leaderboards / cloud saves? → add **Talo** (MIT, free).
    - Doing competitive PvP? → keep GodotSteam transport, deploy Godot `--headless` to **Edgegap** as the authority.
  - **No / cross-platform / itch / web** → continue.
- **Do you want managed infra (zero DevOps)?**
  - **Yes** → **GD-Sync** (free → $7/mo Indie). GDScript-native, 8-player lobby, relay, storage. Single-vendor risk; no self-host path.
  - **No / want OSS control** → continue.
- **Do you need NAT traversal?**
  - **Yes** (most home-network players will be behind NAT) → **EOSG** (free, Epic relay) **or** **netfox + noray** (self-hosted relay) **or** Steam (loops back).
  - **No** (LAN, port-forwarded) → bare ENet via the built-in API.
- **Are you OK self-hosting a backend?**
  - **Yes** → **Nakama** on a $10–20/mo VPS (David Snopek's guide). Pair with **netfox** for CSP.
  - **No** → GD-Sync or Talo SaaS.
- **Do you need a friends list / social graph?**
  - **Steam-only** → Steamworks via GodotSteam (free).
  - **Cross-platform** → EOSG (free) or Talo's social/friends (Apr 2026 release).
- **Are you Steam-exclusive forever?**
  - **Yes** → stop here. GodotSteam is sufficient end-to-end.
  - **No** → architect transport behind a `MultiplayerPeer` interface so you can swap GodotSteam ↔ EOSG ↔ ENet without rewriting RPC code.

---

## 3. Architectures, Ranked for Our Use Case

### 1. P2P Listen-Server (one player hosts) — **complexity 2/5**

The host machine runs the authoritative simulation and also plays. Other players connect via relay (Steam, EOSG, GD-Sync, or netfox/noray). Godot's `ENetMultiplayerPeer` or `WebRTCMultiplayerPeer` supports this natively; GodotSteam wraps it as a transparent transport.

- **When to pick:** co-op with friends; zero infra budget; Steam distribution; 2–8 players; Metroidvania pacing tolerates ~50–120 ms host-advantage delta.
- **When to avoid:** competitive PvP with rankings; public matchmaking with strangers; cheat-sensitive economy; need for host migration.
- **Proof point:** Dome Keeper, 8-player co-op + competitive, GDScript, shipped Apr 13 2026.

### 2. Authoritative Dedicated Server — **complexity 4/5**

A headless Godot binary owns the simulation; clients send inputs, render predictions (CSP), reconcile on correction. Host on Edgegap (Docker, $0.00115/min/vCPU + $0.10/GB egress) or a VPS.

- **When to pick:** competitive PvP, ranked leaderboards, cheat resistance is a hard requirement, persistent world state.
- **When to avoid:** budget-sensitive 2–8 player co-op (~$1,000/mo at 10k sessions × $0.10/hr); team without backend/devops experience.
- **Proof points (engine-agnostic):** Deep Rock Galactic, Phasmophobia, Spelunky 2 (Mossmouth fleet).

### 3. Pure P2P with Lockstep / Rollback (GGPO) — **complexity 5/5**

All peers run identical deterministic simulations; rollback predicts and replays missing inputs. Snopek's `godot-rollback-netcode` is the GDScript reference (2026 update status unconfirmed — verify before relying on it).

- **When to pick:** 2D fighting games, frame-precise RTS, 2–4 player tight-timing genres.
- **When to avoid:** Metroidvanias. Determinism is brutal in GDScript + Godot physics across platforms; genre is not frame-precision-sensitive; correction snaps in exploration are imperceptible.
- **Proof points:** Brawlhalla (custom rollback + Network Next), Street Fighter / Guilty Gear Strive (GGPO).

---

## 4. Cloud Services, Ranked for Our Use Case

### 1. GodotSteam (Steam Networking Sockets) — **free** under Steam rev-share

- **One-line:** Drop-in `MultiplayerPeer` wrapping Steamworks; relay, NAT, lobby, matchmaking, friends — all included.
- **Pricing:** $0 ongoing (Steam takes 30% of sales as their normal cut, unrelated to multiplayer).
- **Usage scale:** Dome Keeper ($6.1M Steam revenue, 8-player co-op + competitive, shipped Apr 13 2026); v4.18.1 (Apr 5 2026) on Codeberg after the GitHub repo was archived Apr 4 2026.
- **Satisfaction signals:** Asset Store reviews — *"wouldn't be able to ship games without it"*; *"one of the best experiences with a plugin."*
- **When to pick:** anytime you ship on Steam.
- **When to avoid:** non-Steam platforms; web export.
- **Source:** https://codeberg.org/godotsteam (visited 2026-04-28).

### 2. GD-Sync — **free tier (4 players); $7/mo Indie (8 players, 50 GB/mo)**

- **One-line:** Only managed backend built ground-up for Godot 4 GDScript; relay + lobby + matchmaking + cloud storage + leaderboards + Steam integration in one plugin.
- **Pricing transparency:** published self-serve tiers; flat-rate data, not per-CCU.
- **Usage scale:** 50,000+ MAU on platform, 6 showcased shipped games; v1.0 released Apr 24 2026 (signals production readiness after long beta).
- **Satisfaction signals:** active community Discord, direct dev access; small team is the durability risk (no self-host path).
- **When to pick:** cross-platform target, want zero DevOps, want lobby/matchmaking solved out of the box.
- **When to avoid:** vendor lock-in is unacceptable; need self-host for compliance/control.
- **Source:** https://www.gd-sync.com/pricing (visited 2026-04-28); Asset Library https://godotengine.org/asset-library/asset/2347.

### 3. Epic Online Services Godot (EOSG, 3ddelano) — **free**

- **One-line:** Free cross-platform lobby + P2P relay + NAT traversal + voice + auth via Epic's C SDK; 289 stars, v2.2.9 (Mar 6 2026).
- **Pricing transparency:** fully free; Epic monetizes via Epic Games Store cut, not via EOS.
- **Usage scale:** active maintenance; HEOS (High-Level EOS) API in v2.2.9 makes lobby/auth dramatically simpler.
- **Satisfaction signals:** generally positive; setup complexity (Epic dev account, app registration) noted but manageable.
- **When to pick:** non-Steam or multi-platform release; want free relay without a vendor subscription.
- **When to avoid:** Steam-only ship (GodotSteam is simpler).
- **Source:** https://github.com/3ddelano/epic-online-services-godot (visited 2026-04-28).

### DIY: Nakama self-host + netfox — **~$10–20/mo VPS**

- **One-line:** Best-in-class OSS backend (Docker), Godot 4 SDK (741 stars, v3.4.0 Mar 2024 — functional but stale), paired with netfox for CSP on the transport layer.
- **Pricing:** $0 software (Apache 2.0); $10–20/mo VPS (David Snopek's "$10/mo Nakama" guide).
- **Usage scale:** SOC 2 Type II; Nakama server v3.38.0 (Mar 20 2026); 7-year track record.
- **Satisfaction signals:** community sentiment is "complete but overkill for small games that just need relay+lobby"; Heroic Cloud managed tier is enterprise-priced (Satori from $600/mo, no published Nakama Cloud rates).
- **When to pick:** OSS purist; vendor lock-in concerns (Hathora is a vivid lesson); willing to do DevOps once.
- **When to avoid:** zero ops capacity; want managed SLA.
- **Source:** https://heroiclabs.com/pricing/ (visited 2026-04-28); https://github.com/heroiclabs/nakama-godot.

### Skip entirely

| Service | Why skip |
|---|---|
| **AWS GameLift** | ~$1,330/mo single region, no Godot SDK, enterprise complexity. |
| **PlayFab** | REST-only, no Godot SDK, Unity-centric docs. |
| **Beamable** | Unity-only, no Godot integration. |
| **Photon Fusion Godot** | "Development preview, not for production" as of Apr 2026. |
| **Hathora** | Shut down May 5 2026. |
| **GameFabric** | Opaque enterprise pricing, sales-call gating, not indie-friendly. |
| **Colyseus** | Godot 4 client SDK is stale (Godot 3-era); requires DIY rewrite. |

---

## 5. Godot-Specific Notes (4.6.2)

**What works well:**
- `MultiplayerAPI` + `SceneMultiplayer` + ENet/WebSocket/WebRTC peers — fully functional, unchanged 4.5 → 4.6.2.
- `MultiplayerSpawner` auto-spawns/despawns scenes on all peers when authority adds children.
- `MultiplayerSynchronizer` replicates properties (always / on-change modes) with reliable or unreliable per-property channels.
- `@rpc` annotation system — clean syntax, supports `authority`/`any_peer`, `call_local`, `reliable`/`unreliable`/`unreliable_ordered`, channels.
- Headless server export (`--headless`) works; runs on any VPS without GPU.
- 4.6.1 (Feb 16 2026) shipped zero networking fixes — confirms subsystem is stable, not broken.

**What's missing (must build or bolt on):**
- Client-side prediction (use **netfox**)
- Rollback (use Snopek's addon, with caution)
- Delta compression (hand-roll diffs before RPC)
- Interest management (manual visibility gating)
- NAT traversal (use Steam/EOSG/GD-Sync relay)
- Lobby / matchmaking (same)
- ~40 CCU server stability ceiling (Rivet benchmarks, Ziva Apr 2026) — irrelevant at 2–8 players, but rules out future MMO ambitions on the built-in stack alone.

**Three load-bearing concerns for THIS project specifically:**

1. **Autoload divergence (`Inventory`, `Skills`).** Both are `extends Node` autoloads — singletons per peer. Without explicit RPC sync, Peer A picking up the dash ability leaves Peer B's `Inventory` unaware. Pattern: every mutation goes through a server-authoritative RPC path. Per-player inventories sidestep this; shared inventories require it.
   ```gdscript
   @rpc("authority", "call_local", "reliable")
   func _rpc_grant(id: StringName) -> void:
       owned[id] = true
       ability_granted.emit(id)
   ```

2. **Room-swap state sync (`World.gd._do_room_transition()`).** Server detects door trigger, decides target, broadcasts swap, clients pause physics, load room, reposition player, ack back. The existing `_transitioning` guard becomes a server-gated lock. `MultiplayerSpawner` does NOT auto-handle room contents (enemies, pickups) — put a spawner in each room scene.

3. **`_physics_process` rubber-banding.** `Player.gd` reads `Input.*` directly and applies physics immediately. On remote clients without CSP: server simulates their movement with input arriving 50–100 ms late → client sees its own player rubber-band back to server position every input. Unacceptable for a platformer. Either:
   - Listen-server, local player on host: fine.
   - Listen-server, remote player: client sends input RPCs (`unreliable_ordered`), server applies and synchronizes back — naive version is rubber-band.
   - **With netfox `RollbackSynchronizer` on `CharacterBody2D`:** input is applied locally immediately, reconciliation replays buffered inputs on correction. This is the path.

**HUD is local-only** — `CanvasLayer` reads `Inventory` / `Skills` signals which are per-peer; no rendering changes needed once the underlying autoload state is synced.

Sources: https://docs.godotengine.org/en/4.6/tutorials/networking/ (2026-04-28); StraySpark (~Mar 2026); Ziva (Apr 1 2026); 4.6.1 release notes (Feb 16 2026).

---

## 6. Patterns from Shipped Games

### Dome Keeper (Bippinbits, Apr 13 2026) — closest direct proof point

8-player online co-op + competitive, added to a 10,000+ line GDScript codebase. Listen-server over GodotSteam (Steam Networking Sockets) — drop-in MultiplayerPeer, no RPC restructuring needed. Round-based session, no persistent campaign save. Community reports "no lag at all, very clean netcode." Works because Dome Keeper is slow-paced (mining loop, turn-structured waves) → high latency tolerance. **Takeaway: this is the literal blueprint.** GodotCon 2025 talk "Keeper to Keepers" (https://talks.godotengine.org/godotcon-us-2025/talk/XMBFFK/) is the must-watch single resource. $6.1M Steam revenue.

### Salt and Sacrifice (Ska Studios, 2022)

Most Metroidvania-adjacent in the dataset: area-locked Soulslike co-op, host-progression. P2P with password-protected sessions, no relay → persistent NAT failure as community pain point. 2 cooperative slots (3 with limitations). Drop-in via candle item; drop-out by death or boss completion. **Save model: host owns world state (mages spawned, area unlocks); both players retain salt/items.** Failed online mission does NOT reset salt — teleport to hub instead. **Takeaway: this is the save-model template; lift it directly.**

### Spelunky 2 (Mossmouth, 2020)

Dedicated servers (Mossmouth-run fleet); 4-player co-op + deathmatch. Two desync classes: hard (wrong level) and soft (clock drift on slow CPU). **Camera tethered to player 1 → widely criticised; community shipped a zoom-out mod.** **Takeaway: shared elastic-zoom camera is non-negotiable for exploration co-op; never tether to one player.** Source: Derek Yu on X (Sep 2020) https://x.com/mossmouth/status/1305944380524515328.

### Castle Crashers (The Behemoth, 2008/2012 PC)

P2P (host = lobby creator), Steam matchmaking, no dedicated servers. 4-player co-op. **Pioneered the "your character is yours, the world is shared" save model** — each player's XP/gold/unlocks persist independently across sessions. P2P requires relaxed firewall settings; VPN/strict NAT cause connection failures. **Takeaway: 18-year-old template still the genre default in 2026.** https://support.thebehemoth.com/hc/en-us/articles/360033513992.

### Risk of Rain 1 (Hopoo Games, 2013)

Listen-server (GameMaker:Studio); 4 players; **manual port-forwarding required** on TCP+UDP 11100 — no relay, no UPnP. Hamachi/Tunngle were community workarounds. Multiplayer was bolted on post-launch and described as "a crapshoot." Risk of Rain 2 moved to listen-server-over-Steam specifically because port-forwarding killed casual session formation. **Takeaway: never ship raw ENet without a relay layer.**

### TowerFall Ascension (Matt Thorson, 2014) — local-only by design

Thorson explicitly researched online netcode and concluded TowerFall's pixel-precise hitboxes made even "perfect netcode" feel broken. The ratio of positional uncertainty to hitbox size is much higher in fast 2D arenas than in 3D shooters. **Takeaway: fast 2D demands rollback or you ship local-only. For exploration Metroidvania this is a non-issue; for a precision-platforming boss fight, plan a lag-comp pass on hits.**

### Brawlhalla (Blue Mammoth / Ubisoft, 2017) — bonus point

Authoritative dedicated servers (regional fleet), full rollback netcode + hybrid input-delay for high-latency players, Network Next routing layer. One of the few 2D titles shipping full rollback — possible because the game is deterministic and hitboxes are large vs. movement speed. **Takeaway: rollback is achievable for 2D action — but only with deterministic engine and budget for both rollback and routing.**

---

## 7. Contributors to Follow

1. **Faless (Fabio Alessandrelli)** — Godot networking maintainer. PR #99963 (dummy IP/NetSocket for Web) merged 2026. https://github.com/faless
2. **Bippinbits** (Dome Keeper team) — only public 8-player Godot 4 GDScript co-op proof point; GodotCon 2025 talk. https://store.steampowered.com/app/1637320/
3. **foxssake** (netfox team) — leading GDScript CSP + lag-comp kit (937 stars), ships noray relay. https://github.com/foxssake
4. **Glenn Fiedler** (gafferongames) — canonical game-networking theory; active 2026 at https://mas-bandwidth.com (netcode lib commit Jan 28 2026).
5. **David Snopek** — `godot-rollback-netcode` author; "Nakama for $10/mo" self-host guide. https://gitlab.com/dsnopek
6. **grazianobolla** — `godot-monke-net` (238 stars, Apr 3 2026); most complete authoritative-server example in the ecosystem (C#, but architecture transfers). https://github.com/grazianobolla
7. **GD-Sync team** — only managed Godot 4 backend; v1.0 Apr 24 2026; 50k+ MAU. https://www.gd-sync.com
8. **3ddelano** — EOSG plugin maintainer (v2.2.9 Mar 6 2026, 289 stars). https://github.com/3ddelano/epic-online-services-godot
9. **TizWarp** — `SteamMultiplayerPeer` addon; Steam Sockets as drop-in `MultiplayerPeer`. https://github.com/TizWarp/SteamMultiplayerPeer
10. **Talo / Sleepy Studios** — MIT self-hostable backend; v0.45.0 Apr 4 2026 added channel storage for shared multiplayer state. https://trytalo.com / https://github.com/TaloDev
11. **reduz (Juan Linietsky)** — directional authority on engine architecture; binding for 4.7/5.0 networking direction. https://github.com/reduz

---

## 8. Sample Repos to Study

1. **`foxssake/netfox`** — 937 stars, v1.35.3 (Nov 23 2025). CSP, lag compensation, rollback-compatible state, networked properties, noray relay. **Start here.** https://github.com/foxssake/netfox
2. **`grazianobolla/godot-monke-net`** — 238 stars, Apr 3 2026. Authoritative server + CSP + reconciliation pattern. C# only, but the architecture is the load-bearing read. https://github.com/grazianobolla/godot-monke-net
3. **`godotengine/godot-demo-projects`** (multiplayer-bomber) — canonical "how the API is supposed to work." Run it, read it, before layering on anything else. https://github.com/godotengine/godot-demo-projects
4. **Bippinbits public material** — GodotCon 2025 talk "Keeper to Keepers" (https://talks.godotengine.org/godotcon-us-2025/talk/XMBFFK/, YouTube https://www.youtube.com/watch?v=MEZoKKAoUAU). Watch as architecture checkpoint before committing.
5. **`gitlab.com/snopek-games/godot-rollback-netcode`** — canonical Godot rollback addon, GDScript. 2026 update status unconfirmed; verify on GitLab before relying on it.

---

## 9. Recommended Reading Order

1. **Godot official docs — Networking section (4.6).** https://docs.godotengine.org/en/4.6/tutorials/networking/. Understand `MultiplayerAPI`, `MultiplayerSpawner`, `MultiplayerSynchronizer`, `@rpc` annotations before touching anything external.
2. **Run + read `godot-demo-projects/networking/multiplayer-bomber`.** Canonical RPC + lobby pattern in minimal code. Makes the docs concrete.
3. **Ziva blog — "Godot Multiplayer in 2026: What Actually Works"** (Apr 1 2026). https://ziva.sh/blogs/godot-multiplayer. Honest limits of 4.6, Dome Keeper as proof point, 40-CCU ceiling, rollback gap. Read AFTER step 2 — it only makes sense once you know the API.
4. **Glenn Fiedler — "Client-Side Prediction" + "Snapshot Interpolation."** https://gafferongames.com/categories/game-networking/. Theory you must know before implementing or evaluating netfox.
5. **Bippinbits GodotCon 2025 talk + netfox README/examples.** Watch the talk as the architecture checkpoint; read netfox to see CSP and lag-comp implemented in GDScript on `CharacterBody2D`. https://github.com/foxssake/netfox.

---

## 10. Open Questions for the User

These are decisions only you can make. They block implementation choices.

1. **PvP weight.** Will competitive PvP ship in v1, or is co-op the only mode? PvP shifts architecture toward authoritative dedicated servers and anti-cheat; co-op-only keeps you on listen-server forever.
2. **Anti-cheat priority.** If players will compete on rankings/leaderboards with strangers, a listen-server is unacceptable (host trivially modifies state). For friends-only co-op, listen-server is genre-standard.
3. **Web-export support.** HTML5 export needs WebRTC (signaling server + TURN), not ENet. If web is on the table, the transport choice changes substantially.
4. **Steam-exclusive vs cross-platform.** Steam-exclusive → GodotSteam end-to-end. Cross-platform → architect transport behind an interface so EOSG / GD-Sync can swap in.
5. **Hosted-server budget tolerance.** $0 (listen-server only) vs $10–20/mo (Nakama VPS) vs $50–500/mo (Edgegap-scale dedicated). Determines architectural ceiling.
6. **Save-format lock-in.** Convergent pattern is host-owns-world / guest-owns-character. Are you committing to this schema now, or designing for shared-progression? Reversal cost is high — saves are forever.
7. **Player cap target.** Ship 2-player v1 (genre default), architect for 4, gate 8 behind a bounded mode? Or commit to 8 from the start (Dome Keeper precedent, much higher complexity)?
8. **Drop-in / drop-out scope.** Session-gated entry only (Salt and Sacrifice model — simpler) vs. mid-room join (requires full mid-room state serialization — significantly harder, defer to v2).

---

## 11. Surprises

- **Hathora shut down.** Acquired by Fireworks AI ~Mar 4 2026; platform frozen immediately; permanent shutdown May 5 2026. Migration target: GameFabric by Nitrado. Any Hathora tutorial/integration is dead. https://hathora.dev/pricing.
- **GodotSteam GitHub repo archived Apr 4 2026.** Development continues on Codeberg at https://codeberg.org/godotsteam (v4.18.1 shipped Apr 5 2026, one day after the archive). Functionality unchanged but bookmarks need updating.
- **Photon Fusion for Godot is dev-preview only** as of Apr 2026, despite GDC/GothamCon 2026 marketing presence. Docs explicitly state "not intended for production use." Watch for stable release; don't build on it now.
- **AWS GameLift is not indie-viable for 2–8 player co-op.** Edgegap's analysis puts single-region cost at ~$1,330/mo (jumping to ~$3,713/mo across 8 regions). No Godot SDK. The user's "AWS cheap+scalable" hope falls cleanly here.
- **Bippinbits / Dome Keeper is fresh proof.** Apr 13 2026 ship of 8-player online co-op + competitive in a 10k-line GDScript codebase, with $6.1M Steam revenue. This is the strongest case study to land in the past month and didn't exist when most ecosystem surveys were written.
- **Nakama Godot SDK is stale.** Server is v3.38.0 (Mar 20 2026); Godot client SDK is still v3.4.0 from Mar 2024. Functional, but not getting Godot-4-specific updates — relevant if you self-host Nakama.
- **Rivet benchmarked Godot's ~40 CCU ceiling.** Cited in Ziva Apr 2026; called Godot's lack of rollback "a deal-breaker for serious development." Both irrelevant at 2–8 players, but worth knowing if ambitions ever scale.

---

## 12. Glossary

- **Authority / authoritative peer:** the peer that owns the canonical state of a node or simulation; in Godot, set via `set_multiplayer_authority(peer_id)`. Server is always peer ID 1.
- **CCU (Concurrent Users):** simultaneous connected players; the unit most managed services bill on.
- **CSP (Client-Side Prediction):** technique where the client immediately applies its own input locally rather than waiting for server round-trip; reconciles when authoritative state arrives.
- **Dedicated server:** a server-only process (no player on it); typically a `--headless` Godot export running on a VPS or Edgegap.
- **Delta compression:** sending only changed fields between snapshots, not full state. Not built into Godot 4.
- **ENet:** UDP-based reliable transport library; Godot's default `ENetMultiplayerPeer`.
- **GGPO:** library + technique pattern for rollback netcode, originally developed for fighting games.
- **Headless export:** Godot binary built with `--headless` flag; runs without GPU/display, suitable for server roles.
- **Interest management:** culling state updates so peers only receive data about entities relevant to them (e.g., same room).
- **Lag compensation:** server-side technique to rewind world state to the time a client fired a shot, validating the hit at the historical position.
- **Listen-server:** one player's machine acts as both host (server) and a playing client; zero infra cost; host has 0 ms latency to themselves.
- **Lockstep:** all peers run identical deterministic simulations, advancing only when all inputs for that frame arrive. Latency = slowest peer. Pre-rollback model.
- **MultiplayerAPI / SceneMultiplayer:** Godot's high-level networking API; routes RPCs and replication by peer ID over a `MultiplayerPeer`.
- **MultiplayerPeer:** abstract transport interface in Godot; concrete impls are `ENetMultiplayerPeer`, `WebRTCMultiplayerPeer`, `WebSocketMultiplayerPeer`, `SteamMultiplayerPeer`.
- **MultiplayerSpawner:** Godot node that auto-spawns/despawns scenes on all peers when authority adds/removes children.
- **MultiplayerSynchronizer:** Godot node that replicates specific properties on a configurable schedule (always / on-change, reliable / unreliable).
- **NAT traversal:** techniques (STUN, TURN, UPnP, hole-punching) to establish direct peer connections through home-router NATs.
- **netfox:** GDScript CSP + lag-compensation toolkit by foxssake (937 stars). Ships noray for P2P relay.
- **noray:** self-hostable relay server bundled with netfox, used for NAT traversal in P2P games.
- **Relay:** intermediate server that forwards packets between peers when direct connection is impossible (symmetric NAT, etc.). Steam, EOS, GD-Sync, and noray all provide relay.
- **Rollback netcode:** technique where the client speculatively advances simulation using predicted inputs and rolls back + replays when real input arrives. Canonical for fighting games.
- **RPC (Remote Procedure Call):** function called on one peer that executes on others. In Godot 4, the `@rpc` annotation marks functions.
- **Snapshot interpolation:** smoothing remote-entity motion between received state snapshots; applied to non-locally-controlled entities.
- **STUN:** lightweight protocol for NAT traversal that discovers a peer's public-facing address. Free public STUN servers exist.
- **TURN:** heavier NAT traversal fallback that relays all traffic through a server (used when STUN-based hole-punching fails on symmetric NATs). Not free at scale.
- **Transfer mode:** Godot RPC option — `reliable`, `unreliable`, or `unreliable_ordered`. Reliable for state changes; unreliable for raw position; unreliable_ordered for input streams.

---

*Source citations carried through from topic files; all URLs verified in topic files dated 2026-04-28.*
