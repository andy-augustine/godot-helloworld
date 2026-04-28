# Godot 4.6 Multiplayer — KOLs, Tooling, and Resources
**Generated:** 2026-04-28 | **Project:** 2D Metroidvania, GDScript, 2–8 player co-op  
**Source:** research/multiplayer/sourcemap.md (crawl date 2026-04-28)

---

## 1. TL;DR

### Top 5 KOLs to follow now
| Name | Why |
|------|-----|
| **Faless (Fabio Alessandrelli)** | Godot networking maintainer; PR #99963 merged 2026 |
| **Bippinbits** | Only public case-study of shipped 8-player Godot 4 GDScript co-op (Dome Keeper, Apr 2026) |
| **foxssake (netfox team)** | Authors of the leading GDScript CSP/lag-comp kit (937 stars) |
| **Glenn Fiedler** | Canonical game networking theory; blog active Jan 2026 |
| **David Snopek** | Author of godot-rollback-netcode; Nakama self-host guide |

### Top 3 sample repos
| Repo | Stars | Why |
|------|-------|-----|
| `foxssake/netfox` | 937 | Best GDScript CSP + lag-comp kit; ships noray P2P relay |
| `grazianobolla/godot-monke-net` | 238 | Most complete authoritative-server example in the ecosystem (C#) |
| `gitlab.com/snopek-games/godot-rollback-netcode` | N/A | Canonical rollback addon for Godot, GDScript |

### Top 3 plugins
| Plugin | Status |
|--------|--------|
| **GD-Sync** | v1.0 Apr 24 2026 — only managed backend built ground-up for Godot 4 |
| **GodotSteam** | v4.16.2; moved to Codeberg Apr 2026 — battle-tested for Steam titles |
| **EOSG (3ddelano)** | v2.2.9 Mar 2026 — free relay/lobby/matchmaking for non-Steam titles |

---

## 2. KOLs (Key Opinion Leaders)

### Godot Core / Engine

**Faless — Fabio Alessandrelli**
- Domain: GDScript RPC, MultiplayerAPI, ENet/WebRTC bindings  
- Link: https://github.com/faless  
- Activity: merged PR #99963 (dummy IP/NetSocket for Web platform) in 2026 — confirms active 2026 maintenance  
- Why follow: drove the entire 4.x multiplayer API redesign; authoritative on MultiplayerSpawner, MultiplayerSynchronizer, and transport choices  
- Example: PR #99963 — https://github.com/godotengine/godot/pull/99963

**reduz — Juan Linietsky**
- Domain: engine architecture, MultiplayerAPI direction | Link: https://github.com/reduz  
- Why follow: co-creator and technical director; his positions on networking are binding for 4.x/5.0 planning  
- Example: directed the MultiplayerAPI overhaul in Godot 4.0

**mhilbrunner**
- Domain: Godot networking docs and proposals | Link: https://github.com/mhilbrunner  
- Activity: authored the "Unofficial Godot 4.0 Pre-Alpha Multiplayer Changes Overview" gist — still cited in 2026  
- Example: search GitHub for "mhilbrunner godot multiplayer changes"

### Shipped Indie Proof Points

**Bippinbits** (Dome Keeper team)
- Domain: production co-op in GDScript at scale  
- Link: GodotCon 2025 recording (search "Bippinbits GodotCon 2025"); Steam: https://store.steampowered.com/app/1637320/Dome_Keeper/  
- Activity: shipped 8-player online co-op + competitive April 13, 2026; $6.1M Steam revenue  
- Why follow: the only public case-study of shipping online co-op in a Godot 4 GDScript title as of 2026. Presented methodology at GodotCon 2025 — techniques directly applicable to a 2–8 player co-op platformer  
- Example: Dome Keeper multiplayer update + GodotCon 2025 presentation (proof that GodotSteam + high-level API can scale to 8 players)

### Plugin / Addon Authors

**foxssake** (netfox team)
- Domain: lag compensation, client-side prediction, interpolation (GDScript)  
- Link: https://github.com/foxssake  
- Activity: netfox v1.35.3 released November 23, 2025; multiple shipped Steam games using it  
- Why follow: authors of the leading GDScript toolkit for responsive online games; also ships noray, a self-hosted relay for P2P NAT traversal  
- Example: netfox repo — https://github.com/foxssake/netfox (937 stars)

**grazianobolla**
- Domain: client-side prediction, authoritative server (C#)  
- Link: https://github.com/grazianobolla  
- Activity: godot-monke-net updated April 3, 2026  
- Why follow: most complete authoritative-server + client prediction implementation in the Godot ecosystem; even in C# the architecture patterns translate directly to GDScript  
- Example: https://github.com/grazianobolla/godot-monke-net (238 stars)

**David Snopek**
- Domain: rollback netcode, Nakama+Godot integration  
- Link: https://gitlab.com/dsnopek  
- Activity: author of godot-rollback-netcode addon; wrote the canonical "How to host Nakama for $10/mo" guide  
- Why follow: if the project ever targets fighting-game-style responsiveness (rollback is overkill for co-op platformer, but the theory is essential background)  
- Example: https://gitlab.com/snopek-games/godot-rollback-netcode

**GD-Sync team**
- Domain: managed Godot multiplayer backend (relay, lobby, matchmaking, cloud storage, leaderboards)  
- Link: https://www.gd-sync.com; Asset Library: https://godotengine.org/asset-library/asset/2347  
- Activity: plugin v1.0 updated April 24, 2026; 50,000+ MAU on platform; 6 shipped games showcased  
- Why follow: only managed service built ground-up for Godot 4 GDScript; Steam integration included; free tier, no credit card  
- Example: GD-Sync plugin v1.0 release (April 2026)

**TizWarp**
- Domain: SteamMultiplayerPeer — Steam Networking Sockets as a drop-in MultiplayerPeer  
- Link: https://github.com/TizWarp/SteamMultiplayerPeer  
- Activity: part of the GodotSteam ecosystem migration to Codeberg (2026)  
- Why follow: enables using Steam relay as a transparent transport without changing RPC code  
- Example: SteamMultiplayerPeer addon — https://github.com/TizWarp/SteamMultiplayerPeer

**3ddelano**
- Domain: Epic Online Services integration for Godot 4  
- Link: https://github.com/3ddelano/epic-online-services-godot  
- Activity: v2.2.9 released March 6, 2026 (Asset Library: Feb 10, 2026); 289 stars  
- Why follow: free relay, NAT traversal, lobby, and voice for non-Steam titles via Epic's C SDK  
- Example: EOSG plugin — https://github.com/3ddelano/epic-online-services-godot (289 stars)

**Talo / Sleepy Studios**
- Domain: open-source self-hostable backend (leaderboards, analytics, cloud saves, channel storage)  
- Link: https://trytalo.com; https://github.com/TaloDev; Asset Library: https://godotengine.org/asset-library/asset/2936  
- Activity: v0.45.0 released April 4, 2026; MIT license; channel storage added for shared multiplayer state  
- Why follow: lightweight, free-tier companion backend that sits alongside whatever transport layer you pick  
- Example: Talo Godot plugin v0.45.0 (April 2026)

### Game Networking Theory

**Glenn Fiedler** (gafferongames)
- Domain: UDP protocol design, client-side prediction, snapshot interpolation, rollback theory  
- Links: https://gafferongames.com/categories/game-networking/ (older articles) | https://mas-bandwidth.com/author/glenn/ (active 2026 blog)  
- Activity: netcode library commit January 28, 2026 at mas-bandwidth.com  
- Why follow: every Godot netcode implementation cites his articles; foundational texts for understanding CSP, interpolation, and UDP reliability  
- Example: "Networked Physics" series — https://gafferongames.com/categories/game-networking/

**Heroic Labs (Nakama team)**
- Domain: open-source game backend — auth, matchmaking, realtime, storage  
- Link: https://heroiclabs.com | https://github.com/heroiclabs  
- Activity: Nakama server v3.38.0 (March 20, 2026); Godot 4 client SDK last released March 2024  
- Example: Nakama v3.38.0 — https://github.com/heroiclabs/nakama

**Rivet engineering team**
- Domain: Godot multiplayer scalability benchmarking  
- Activity: Q1 2026 analysis quantifying Godot's ~40 CCU-per-server ceiling; cited in Ziva blog April 2026  
- Example: https://ziva.sh/blogs/godot-multiplayer

**Andrew Davis**
- Domain: GDScript netcode patterns (practitioner)  
- Link: https://jonandrewdavis.com/drafts/draft-of-godot-network-tips/  
- Example: "Godot Multiplayer: 3 Quick Tips for Better Netcode" — covers reducing RPC overhead in Godot 4

---

## 3. Sample / Reference Repos

**foxssake/netfox** — 937 stars  
- URL: https://github.com/foxssake/netfox  
- Last commit: November 23, 2025 (v1.35.3)  
- Demonstrates: client-side prediction, lag compensation, rollback-compatible state management, networked properties, noray P2P relay — all in GDScript  
- Applicability: HIGH. Direct drop-in for the 2D co-op platformer. GDScript, Godot 4, active. Start here.

**grazianobolla/godot-monke-net** — 238 stars  
- URL: https://github.com/grazianobolla/godot-monke-net  
- Last commit: April 3, 2026  
- Demonstrates: authoritative server with client-side prediction and server reconciliation; dedicated-server export pattern  
- Applicability: MED. C# only — not GDScript. But the architecture (prediction buffer, input serialization, reconciliation loop) translates directly. Read the code and the README before designing the authoritative-server loop.

**gitlab.com/snopek-games/godot-rollback-netcode** — stars: N/A (GitLab)  
- URL: https://gitlab.com/snopek-games/godot-rollback-netcode  
- Last commit: unconfirmed for 2026 — check GitLab directly before relying on it  
- Demonstrates: GGPO-style rollback netcode for Godot; GDScript; tick-based input  
- Applicability: MED. Overkill for co-op platformer but essential reading if precise input timing matters (boss fights, precision platforming in co-op)

**godot-demos/godot-demo-projects** (official)  
- URL: https://github.com/godotengine/godot-demo-projects  
- Last commit: actively maintained alongside each Godot release  
- Demonstrates: multiplayer-bomber (ENet lobby + state sync) and networking/ subdirectory — canonical "how the API is supposed to work" reference  
- Applicability: HIGH for understanding the baseline API before layering on netfox or GD-Sync

**heroiclabs/nakama-godot** — 741 stars  
- URL: https://github.com/heroiclabs/nakama-godot  
- Last commit: v3.4.0, March 2024 (not updated in 2025–2026)  
- Demonstrates: Nakama client SDK integration for Godot 4 — auth, matchmaking, realtime socket  
- Applicability: MED. Functional but stale SDK. Only needed if self-hosting Nakama as the backend.

**3ddelano/epic-online-services-godot** — 289 stars  
- URL: https://github.com/3ddelano/epic-online-services-godot  
- Last commit: March 6, 2026 (v2.2.9)  
- Demonstrates: EOS lobby, P2P relay, voice, auth via GDExtension wrapping Epic C SDK; Godot 4.2+  
- Applicability: MED-HIGH for non-Steam release. Free relay and NAT traversal without a managed service subscription.

**GD-Sync/GD-Sync**  
- URL: https://github.com/GD-Sync/GD-Sync  
- Last commit: February 3, 2026 (Asset Library); v1.0 April 24, 2026  
- Demonstrates: full-stack managed multiplayer for Godot 4 — relay, lobby, matchmaking, cloud storage, leaderboards, Steam integration  
- Applicability: HIGH if targeting a "batteries included" co-op launch with minimal backend work

---

## 4. Plugins / Addons

**GD-Sync**  
- Repo: https://github.com/GD-Sync/GD-Sync | Asset Library: https://godotengine.org/asset-library/asset/2347  
- Last commit: April 24, 2026 (v1.0)  
- Solves: relay, NAT traversal, lobby, matchmaking, cloud storage, leaderboards, Steam integration — all in one managed service  
- Doesn't solve: rollback/CSP (you add netfox on top); no dedicated-server-only self-hosted option  
- **Recommended for this project** if not targeting Steam exclusively

**GodotSteam**  
- Repo (active): https://codeberg.org/godotsteam (GitHub archived April 4, 2026)  
- Last release: v4.16.2, 2026  
- Solves: Steam Networking Sockets as MultiplayerPeer — relay, NAT traversal, lobby, matchmaking via Steamworks; most battle-tested integration in the ecosystem (used by Dome Keeper)  
- Doesn't solve: non-Steam platforms; requires Steamworks account  
- **Top recommendation if shipping on Steam**

**Epic Online Services Godot (EOSG)**  
- Repo: https://github.com/3ddelano/epic-online-services-godot  
- Last commit: March 6, 2026 (v2.2.9)  
- Solves: free lobby, P2P relay, NAT traversal, voice, auth via EOS for any platform  
- Doesn't solve: cloud storage/leaderboards (use Talo alongside); requires EOS dev account  
- Good free option for non-Steam 2–8 player co-op

**netfox (foxssake)**  
- Repo: https://github.com/foxssake/netfox  
- Last commit: November 23, 2025 (v1.35.3)  
- Solves: client-side prediction, lag compensation, interpolation, networked property sync, tick synchronization — all GDScript  
- Doesn't solve: transport/lobby/matchmaking (combine with GodotSteam, EOSG, or GD-Sync)  
- **Must-have if implementing CSP on top of any transport**

**Talo**  
- Repo: https://github.com/TaloDev | Asset Library: https://godotengine.org/asset-library/asset/2936  
- Last commit: April 4, 2026 (v0.45.0)  
- Solves: leaderboards, analytics, cloud saves, channel storage for shared multiplayer state; MIT, self-hostable  
- Doesn't solve: transport or relay  
- Good lightweight companion backend

**Godot WebRTC Native** (built-in)  
- Part of Godot 4.6 core; no separate install  
- Solves: browser-compatible P2P transport (WebRTC as MultiplayerPeer); required for web export multiplayer  
- Doesn't solve: signaling server (you provide), NAT traversal beyond STUN

**Photon Fusion for Godot** — DO NOT USE IN PRODUCTION  
- Docs: https://doc.photonengine.com/fusion-godot/current/  
- Status: "development preview, not intended for production" as of April 2026  
- Watch for stable release announcement via @ExitGames

---

## 5. Video Courses and Tutorial Series

**Bippinbits — GodotCon 2025 talk (Dome Keeper multiplayer)**  
- URL: search "Bippinbits GodotCon 2025" in GodotCon recordings (YouTube / Godot Foundation)  
- Length: conference talk (~30–60 min) — not a full course, but the highest-signal single video for this project  
- Last updated: 2025 (presented at GodotCon 2025, shipped April 2026)  
- Covers: adding online co-op + competitive to a 10k-line GDScript codebase; GodotSteam integration; architecture decisions at scale

**GDQuest — "Intro to Multiplayer in Godot" playlist**  
- URL: https://www.youtube.com/playlist?list=PLhqJJNjsQ7KHohKIdqyTHRr96zYreZMC7  
- Length: multi-video series (intro level); no exact total runtime in sourcemap  
- Last updated: 2024 (API still accurate for 4.6)  
- Covers: high-level API, lobby setup, peer connections, 2D shooting demo  
- Limitation: no CSP, no rollback, no authoritative server patterns — use as orientation only

**"Godot 4 Steam Multiplayer Tutorial" (Dec 17, 2025)**  
- URL: https://www.youtube.com/watch?v=FHBJ-auzaeM  
- Length: single video (unknown duration; Dec 2025)  
- Covers: GodotSteam + Steam Networking Sockets for Godot 4; most up-to-date Steam-specific tutorial found

**"Rollback netcode in Godot (part 1)"**  
- URL: https://www.youtube.com/watch?v=zvqQPbT8rAE  
- Length: single video (unknown duration)  
- Covers: what rollback netcode is, why it matters, before implementation; theory foundation

**GDQuest — Intro to Multiplayer (written primer)**  
- URL: https://www.gdquest.com/tutorial/godot/networking/intro-to-multiplayer/  
- Covers: high-level API basics, 2D shooting demo — good orientation, not architecture-level

---

## 6. Books / Written Resources

**Glenn Fiedler — "Game Networking" series (gafferongames.com)**  
- URL: https://gafferongames.com/categories/game-networking/  
- Vintage: 2014–2018 — principles are timeless; cited in every 2026 Godot networking discussion  
- Must-read articles: "UDP vs TCP", "Client-Side Prediction and Server Reconciliation", "Snapshot Interpolation", "Snapshot Compression"

**Glenn Fiedler — mas-bandwidth.com (active 2026 blog)**  
- URL: https://mas-bandwidth.com/author/glenn/  
- Latest: netcode library commit January 28, 2026  
- Covers: scalable game network engineering, backend performance

**Ziva blog — "Godot Multiplayer in 2026: What Actually Works"**  
- URL: https://ziva.sh/blogs/godot-multiplayer  
- Date: April 1, 2026  
- Best single survey of the current ecosystem: limits of 4.6, Dome Keeper as proof point, specific failure modes (40-player ceiling, no rollback, NAT traversal), GD-Sync and Nakama comparison

**StraySpark — "Godot 4 Multiplayer Authoritative Server"**  
- URL: https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server  
- Date: ~March 2026  
- Most current Godot-specific authoritative-server walkthrough: ENet peers, RPCs, Spawner/Synchronizer, common mistakes

**Godot Official Docs — Networking section (4.6)**  
- URL: https://docs.godotengine.org/en/4.6/tutorials/networking/  
- Status: updated for 4.6 — canonical reference for MultiplayerAPI, MultiplayerSpawner, MultiplayerSynchronizer, ENet, WebRTC

**GodotAwesome — Godot 4 Multiplayer Networking Guide 2025**  
- URL: https://godotawesome.com/godot-4-multiplayer-networking-guide-2025/  
- Date: 2025 — slightly stale but accurate for 4.6 fundamentals; good for ENet/WebSocket/WebRTC transport comparison

---

## 7. Recommended Reading Order (Zero → Production)

1. **Godot official docs, Networking section** — https://docs.godotengine.org/en/4.6/tutorials/networking/  
   Understand MultiplayerAPI, MultiplayerSpawner, MultiplayerSynchronizer before touching any external tool.

2. **Godot demo: multiplayer-bomber** — https://github.com/godotengine/godot-demo-projects  
   Run it, read it. Shows the canonical RPC + lobby pattern in minimal code.

3. **Ziva blog, April 2026** — https://ziva.sh/blogs/godot-multiplayer  
   Read this second, not first — it only makes sense after you know the API. Gives honest limits.

4. **Glenn Fiedler — "UDP vs TCP", "Client-Side Prediction", "Snapshot Interpolation"** — https://gafferongames.com  
   Core theory. Read before implementing any prediction or interpolation.

5. **StraySpark authoritative server post (~March 2026)** — https://www.strayspark.studio/blog/...  
   First Godot-specific implementation guide that ties the theory to GDScript.

6. **netfox README + examples** — https://github.com/foxssake/netfox  
   The GDScript implementation of everything from steps 4–5. Read alongside the theory articles.

7. **GDQuest multiplayer playlist** — https://www.youtube.com/playlist?list=PLhqJJNjsQ7KHohKIdqyTHRr96zYreZMC7  
   Watch after reading, not before — fills in visual gaps from the text-heavy resources.

8. **Bippinbits GodotCon 2025 talk** — GodotCon 2025 recordings  
   Watch this as a checkpoint before committing to an architecture. Real decisions from a shipped 8-player game.

9. **Pick your transport/lobby layer** based on platform:  
   - Steam → GodotSteam (codeberg.org/godotsteam) + SteamMultiplayerPeer  
   - Non-Steam / cross-platform → GD-Sync (gd-sync.com) or EOSG  
   - Self-hosted → Nakama (heroiclabs/nakama-godot) or Colyseus with custom Godot 4 client

10. **godot-monke-net architecture** — https://github.com/grazianobolla/godot-monke-net  
    Study for server-authoritative patterns even if you write GDScript. Best reference for the prediction/reconciliation loop.

---

## Warnings / Dead Ends (as of 2026-04-28)

| Source | Status |
|--------|--------|
| Hathora (any tutorial) | Platform shut down May 5, 2026 — ignore |
| GodotSteam GitHub (`GodotSteam/GodotSteam`) | Archived April 4, 2026 — use codeberg.org/godotsteam |
| Photon Fusion for Godot | Dev preview — not production-ready |
| `gsioteam/godot-colyseus` | Godot 3 SDK, not updated for Godot 4 |
| Godot 3.x multiplayer tutorials | RPC system redesigned in 4.x — incompatible patterns |
| AWS GameLift, PlayFab, Beamable | No Godot SDK; overkill/wrong platform for indie 2–8 player co-op |
