# Cloud / Managed Multiplayer Services — Godot 4.6 Comparison Matrix

**Generated:** 2026-04-28  
**Project:** 2D Metroidvania, Godot 4.6.2, GDScript, targeting 2–8 player co-op  
**Intel window:** Q4 2025 → Apr 28, 2026

---

## 1. TL;DR — Direct Verdict on Four User Hopes

**Hope 1: "Godot built-in is enough"** — Conditionally yes for 2–8 player co-op with caveats. The built-in high-level API (ENet + MultiplayerSpawner/Synchronizer + RPCs) is what Dome Keeper used for 2–8 players and shipped on Apr 13, 2026 to $6.1M in Steam revenue. However: no built-in NAT traversal (you need a relay), no lobby/matchmaking, and the ~40 CCU server ceiling is not a concern at 2–8 players. For co-op specifically, built-in is viable as your transport layer if you bolt on one of the relay/lobby options below.

**Hope 2: "An OSS option"** — Yes, multiple credible ones. Nakama (self-host Docker) is the most mature OSS backend. Talo is a lighter OSS companion for leaderboards/saves/channels. Colyseus (OSS Node.js) works for room-based servers but its Godot 4 SDK is stale. netfox (OSS, 937 stars, GDScript) gives you CSP + lag compensation without any backend dependency.

**Hope 3: "Steam services"** — Yes, and it's the top recommendation if you ship on Steam. GodotSteam (v4.18.1, Codeberg, active Apr 2026) wraps Steamworks as a drop-in MultiplayerPeer with relay, NAT traversal, and lobbies already handled. Used by Dome Keeper. GitHub repo archived Apr 4, 2026 but Codeberg is fully active. Zero ongoing cost.

**Hope 4: "AWS cheap+scalable"** — No. AWS GameLift is enterprise-grade, has no free managed tier, and runs $1,330+/month in a single region before scaling. Pure EC2 + Godot headless export is viable for self-managed hosting (costs ~$20-50/month for a small always-on VPS) but adds DevOps overhead. For indie 2–8 player co-op, AWS is the wrong tool.

**Top 3 picks for this project:**
1. **GodotSteam + Steam Networking** — if shipping on Steam (likely). Zero cost, best Godot integration, battle-tested.
2. **GD-Sync** — if you want managed infrastructure fast, GDScript-native, with relay+lobby+storage. $7/month Indie plan supports 8 players/lobby — an exact fit.
3. **Nakama (self-hosted) + netfox** — if you want OSS control with no recurring vendor cost and are willing to run a Docker server.

---

## 2. One-Line Summaries

| Service | One-Line |
|---------|----------|
| **GD-Sync** | Managed backend built exclusively for Godot 4; relay + lobby + matchmaking + storage, $0–$7/mo for 2–8 players. |
| **Nakama** | Best-in-class OSS game backend; free to self-host, enterprise-priced on managed cloud; Godot SDK functional but last released Mar 2024. |
| **Photon Fusion** | Battle-tested netcode SDK, now available for Godot as GDExtension; still "development preview, not for production" as of Apr 2026. |
| **GodotSteam** | The Steamworks integration for Godot 4; free relay + lobby on Steam, best real-world track record, Codeberg-active post GitHub archive. |
| **Epic Online Services (EOS)** | Free cross-platform lobby/P2P/relay from Epic; third-party Godot plugin (289 stars) actively maintained; good for non-Steam or multi-platform. |
| **Hathora** | SHUT DOWN. Acquired by Fireworks AI Mar 2026, closes May 5, 2026. Document as cautionary tale only. |
| **Edgegap** | Global dedicated-server orchestration; Docker-based; free 1-server trial + pay-as-you-go ($0.00115/min/vCPU); no Godot-specific plugin. |
| **PlayFab** | Microsoft backend platform; massive scale, no Godot SDK, REST-only; skippable for indie. |
| **AWS GameLift** | Enterprise dedicated-server fleet management; $1,330+/mo per region; no Godot SDK; overkill for 2–8 players. |
| **Beamable** | Unity-focused backend with social/leaderboards; no Godot integration; skip. |
| **Colyseus** | OSS Node.js authoritative server; Godot 4 SDK exists but stale (Godot 3-era); viable if you own the server; 6.4K GitHub stars. |
| **Talo** | OSS self-hostable backend; leaderboards + analytics + cloud saves + channels; Godot 4.6 plugin v0.45.0 (Apr 4, 2026); free ≤10K players. |
| **GameFabric (Nitrado)** | Hathora's official migration target; global infra, Docker-native, enterprise-tier, opaque pricing (sales call required). |

---

## 3. Comparison Matrix

| Service | Godot SDK | Includes | Free Tier | First Paid Tier | Self-Host | Usage Scale | Satisfaction Signal | Verdict |
|---------|-----------|----------|-----------|-----------------|-----------|-------------|---------------------|---------|
| **GD-Sync** | GDScript plugin, v1.0 (Apr 24, 2026), Asset Lib | Relay, lobby, matchmaking, cloud storage, leaderboards, Steam integration, proximity voice | 4 players/lobby, 200 MB/day, 25 MB storage | $7/mo (8 players, 50 GB/mo) | No | 50K+ MAU, 6 shipped games | Positive; 50K MAU on free tier is real adoption | **Best managed pick for 2–8 co-op** |
| **Nakama** | GDScript, v3.4.0 (Mar 2024), 741 stars | Auth, matchmaking, storage, realtime, leaderboards, social, chat | Self-host free (Docker) | Heroic Cloud: custom quote (CPU-based, dev tier available) | Yes (Docker, MIT) | SOC2 Type II, GCP/AWS marketplace | "Nakama simply provides services your game may or may not need" — forum; good for self-hosters | **Best OSS backend; managed cloud overpriced** |
| **Photon Fusion** | GDExtension, SDK 3, dev preview (Apr 2026) | State sync, RPCs, room matchmaking, cloud servers | 20 CCU dev / 100 CCU free (single app) | $95 one-time (100 CCU, 12 months) or $125/mo (500 CCU) | No (managed only) | 200M+ players on Photon Unity titles; Godot SDK unproven | Dev preview caution; docs say "not for production" | **Watch list only; not production-ready** |
| **GodotSteam** | GDExtension MultiplayerPeer, v4.18.1 (Apr 5, 2026) | Steam relay, NAT traversal, lobbies, matchmaking, friends, P2P | Free (Steam rev-share applies) | Free | No (Valve infra) | Used by Dome Keeper (8-player, $6.1M revenue) | "Easy to implement wrapper… wouldn't be able to ship without it" — Asset Store | **Top pick if shipping on Steam** |
| **EOS (EOSG)** | GDExtension, v2.2.9 (Mar 6, 2026), 289 stars | Auth (Steam/Discord/Epic), lobbies, P2P sessions, voice, leaderboards, storage | Free (all tiers; Epic monetizes via EGS cut) | Free | No (Epic infra) | Active maintenance; 289 stars modest | Generally positive; plugin complexity is noted; HEOS API helps | **Good Steam alternative; free + cross-platform** |
| **Hathora** | Had GDScript addon (now dead) | Dedicated server hosting | N/A — SHUT DOWN | N/A | N/A | Shut down May 5, 2026 | Cautionary tale | **Do not use. Platform is dead.** |
| **Edgegap** | None (Docker deploy) | Dedicated server orchestration, global regions, matchmaking add-on | 1 concurrent deploy, 1h uptime/session | Pay-as-you-go: $0.00115/min/vCPU + $0.10/GB egress | No (managed orchestration) | 615+ locations; Hathora's official migration partner | No strong Godot community signal | **Viable for dedicated-server hosting; no Godot plugin** |
| **PlayFab** | REST only | Backend services, party, matchmaking, storage | 10 CCU free | Usage-based (complex) | No | AAA-grade; Microsoft backing | "Too heavyweight for indie" is the recurring take | **Skip for indie co-op** |
| **AWS GameLift** | None | Fleet management, matchmaking, auto-scaling | 12-month AWS Free Tier (EC2 only) | ~$1,330/mo (1 region) | Partial (EC2 self-managed alternative) | Enterprise | "It can be pricey and complex if new to server hosting" — G2 2026 | **Skip. Overkill + expensive for 2–8 players** |
| **Beamable** | None | Social, leaderboards, economy (Unity SDK) | Freemium | N/A for Godot | No | Unity-only effectively | N/A | **Skip. No Godot integration.** |
| **Colyseus** | Godot 3-era SDK (stale); Godot 4 via HTTP/WS DIY | Authoritative room server (Node.js), state sync | Self-host free | Self-host free; managed pricing unclear | Yes (Node.js) | 6.4K GitHub stars, 750K+ downloads; web/Phaser community | Popular in JS community; Godot 4 path is DIY | **OSS option if willing to write Godot 4 client from scratch** |
| **Talo** | Godot 4.6 plugin, v0.45.0 (Apr 4, 2026), MIT | Leaderboards, analytics, cloud saves, channels/multiplayer messaging, social | Free ≤10K players (all features) | $24.99/mo (≤100K players) | Yes (Docker, MIT) | Small but active; Godot forum thread active | Positive; "Thanks for adding the Friends feature!" — forum | **Best OSS companion backend for non-transport services** |
| **GameFabric** | None (Docker) | Dedicated server orchestration (Hathora migration target) | None documented | Sales call required (opaque) | No | 250K+ concurrent game servers (Nitrado infra) | Limited indie signal; enterprise-tier focus | **Hathora refugees only; not indie-friendly** |

---

## 4. Per-Service Deep Dives

### GD-Sync
Built exclusively for Godot 4 by a small team; the only managed service in this list where the entire product is purpose-built for GDScript. Plugin v1.0 shipped Apr 24, 2026, signaling production readiness after a long beta. Free tier supports 4 players per lobby — enough for prototyping but not shipping a co-op game. Indie plan at $7/mo unlocks 8 players per lobby (exact fit for this project's 2–8 target), 50 GB/month data transfer, 100 MB cloud storage, and no per-CCU charges. Billing model is flat-rate data transfer rather than per-user, which is friendly for predictable costs. 50,000+ MAU on the platform with 6 showcased shipped games confirms this is not vaporware. Includes proximity voice chat, Steam integration, and LAN/offline mode at no extra cost. Community Discord exists for direct dev access. One genuine concern: it's a small team and a single point of failure if they shut down; no self-host path. Pricing page: https://www.gd-sync.com/pricing (visited 2026-04-28).

### Nakama (Heroic Labs)
The most mature open-source game backend in the space, with server v3.38.0 (Mar 20, 2026) and a seven-year track record. Self-host via Docker is free with full features: auth, matchmaking, realtime sockets, storage, leaderboards, social graph, Lua/TypeScript server modules. The Godot client SDK (heroiclabs/nakama-godot, 741 stars) is functional but last released v3.4.0 in March 2024 — it works with Godot 4 but isn't being actively developed for 4.6 specifics. Heroic Cloud managed tier is enterprise-priced: no published rates, CPU-core-based quotes, dev-tier "micro" available but not free. Satori (live-ops layer) starts at $600/mo. Community forum sentiment: Nakama is praised for completeness but described as overkill for small games that just need relay + lobby. David Snopek's guide "How to host Nakama for $10/mo" on a cheap VPS is frequently cited as the viable indie path. Pricing page: https://heroiclabs.com/pricing/ (visited 2026-04-28). Forum quote: *"Nakama simply provides services that your game may or may not need"* (forum.godotengine.org, 2026).

### Photon Fusion for Godot
Photon powers 200M+ player-sessions across Unity titles, making it battle-tested infrastructure. The Godot SDK (Fusion Godot 3) was announced via @ExitGames on X and presented at GDC/GothamCon 2026. It ships as a GDExtension, supports GDScript and C#, and offers state-sync, snapshot-interpolation, room matchmaking, and RPCs. The documentation at https://doc.photonengine.com/fusion-godot/current/fusion-intro (visited 2026-04-28) describes it as a "development preview, not intended for production use." The sourcemap corroborates this. Pricing exists (free 100 CCU, $125/mo at 500 CCU) but is moot until the SDK exits preview. Community signal for the Godot SDK specifically is minimal since it's too new. Watch for a stable release announcement.

### GodotSteam + Steam Networking Sockets
The most battle-tested Godot multiplayer integration for Steam games. The GitHub repo (GodotSteam/GodotSteam) went read-only April 4, 2026 but development actively continues on Codeberg at https://codeberg.org/godotsteam — v4.18.1 shipped April 5, 2026 (one day after the GitHub archive). Provides a full MultiplayerPeer implementation using Steam Networking Sockets: NAT traversal, relay via Valve's global network, Steam lobbies, matchmaking, and friends list integration — all within Godot's existing RPC system. Dome Keeper shipped 2–8 player online co-op using this path on Apr 13, 2026, making it the strongest possible proof point for this exact project profile. Asset Store users say: *"Wouldn't be able to ship games without it"* and *"One of the best experiences with a plugin."* Hard constraint: only works for Steam-distributed games. Codeberg: https://codeberg.org/godotsteam (visited 2026-04-28).

### Epic Online Services Godot (EOSG)
EOS is Epic's answer to Steamworks: free infrastructure, cross-platform (Windows, Mac, Linux, iOS, Android), no revenue share outside the Epic Games Store. The maintained Godot plugin is by 3ddelano (EOSG, v2.2.9, Mar 6, 2026, 289 stars on GitHub: https://github.com/3ddelano/epic-online-services-godot, visited 2026-04-28). Covers auth (Steam, Discord, Epic, device ID), lobbies, P2P sessions, voice, stats, leaderboards, achievements, and storage. A second plugin, GD-EOS by Daylily-Zeleen, also exists with a more C++-oriented approach. The Feb 2026 v2.2.9 added HEOS (High-Level EOS) API making lobby/auth dramatically simpler. Good pick if you want free relay/lobby without requiring players to own the game on Steam. Setup complexity (Epic developer account, app registration) is higher than GodotSteam but manageable.

### Hathora (Cautionary Tale)
Hathora was the leading indie-friendly dedicated-server-as-a-service for Godot and Unity. It was acquired by Fireworks AI on approximately March 4, 2026 and immediately froze all game-platform operations. Permanent shutdown is May 5, 2026. A Godot GDScript addon existed (March 2025) and is now meaningless. Official migration path: GameFabric by Nitrado. Any tutorial, guide, or integration referencing Hathora is broken. Shutdown notice: https://hathora.dev/pricing (visited 2026-04-28). Lesson: vendor lock-in on an acquired startup can wipe out your multiplayer infrastructure with 60 days notice. Prefer services with self-host paths or Valve/Epic backing.

### Edgegap
The surviving alternative to Hathora for globally-distributed dedicated-server orchestration. Works by wrapping your Godot headless export in a Docker container and deploying it to Edgegap's 615+ global locations. No Godot-specific plugin — you deploy any Docker image. Free trial: 1 concurrent deployment, 1h session limit, no credit card required. Pay-as-you-go: $0.00115/min per vCPU + $0.10/GB egress. Relay service (separate) starts free (50 CCU, 160 GB egress included) with overage at $0.14/CCU and $0.10/GB. Matchmaking addon: $0.0312/hr (~$22/month). For a 2–8 player co-op game with modest player counts, a session costs roughly $0.14/hour of server time — a viable model if you have actual players. Comparison vs. Hathora: https://edgegap.com/comparison/edgegap-vs-hathora (visited 2026-04-28). Pricing: https://edgegap.com/pricing (visited 2026-04-28).

### PlayFab (Microsoft)
Enterprise-grade game backend with matchmaking, party, storage, economy, and analytics. Free tier exists (10 CCU, limited calls). No official Godot SDK — integration is REST-only, meaning you build your own GDScript HTTP client to every endpoint. Documentation is Unity-centric. The "no SDK" penalty is severe: you lose type safety, event-driven callbacks, and maintainability. Microsoft's backing is reassuring for longevity but the implementation burden is prohibitive for a small team. Skip unless you have specific Microsoft deal or Azure credits. No Godot community signal.

### AWS GameLift
Fleet-management service for dedicated game servers at scale. Supports container fleets (GA'd 2026) with scale-to-zero. Pricing: no free tier for the GameLift service itself; a 12-month AWS Free Tier covers EC2 compute only. Edgegap's analysis (https://edgegap.com/blog/the-hidden-cost-of-aws-gamelift-s-pricing, visited 2026-04-28) found single-region cost of ~$1,330/month, jumping to ~$3,713/month across 8 regions for global coverage. No Godot SDK — integration requires AWS SDK for C++ or a REST wrapper. G2 2026 review consensus: *"Can be pricey and complex for new users."* The "AWS cheap+scalable" hope does not hold for GameLift. Alternative: pure EC2 VPS + Godot headless export is self-managed and costs ~$20-50/month for a t3.micro, but you own uptime, patching, and scaling.

### Beamable
Unity-first backend platform with social, economy, leaderboards, and content management. No Godot SDK, no REST-only integration documented for Godot. Listed here for completeness. Skip entirely.

### Colyseus
OSS room-based multiplayer server in Node.js/TypeScript. Server v0.16 shipped Feb 6, 2026 with automatic reconnection and full-stack TypeScript safety. 6.4K GitHub stars, 750K+ downloads. The Godot client SDK (gsioteam/godot-colyseus, Godot Asset Library #1592) is Godot 3-era — not updated for Godot 4's API. Using Colyseus with Godot 4 today requires implementing a Godot 4 WebSocket client from scratch or adapting the stale SDK. Viable if you are comfortable in TypeScript and want full server control; not plug-and-play. Godot discuss thread on Colyseus support is from 2022. https://github.com/gsioteam/godot-colyseus (visited 2026-04-28).

### Talo Game Services
OSS, MIT-licensed, self-hostable backend with a Godot 4.6 plugin (v0.45.0, Apr 4, 2026, Asset Library #2936). Covers leaderboards, analytics, player auth, cloud saves, channel-based messaging (real-time multiplayer state sharing), and social relationships (friends/follow). The "channels" feature handles shared multiplayer state without writing your own networking code — useful as a companion to any transport layer. Free tier: all features, up to 10K players. Team tier: $24.99/mo (100K players). Self-host is free and MIT-licensed. Godot forum thread is active and positive. The dev team ships regularly (Feb 2026 added Steamworks client). Not a transport-layer replacement — it doesn't provide relay or NAT traversal. Best used alongside GodotSteam or EOS for lobby+leaderboard+save data. https://trytalo.com/pricing (visited 2026-04-28).

### GameFabric (Nitrado)
Hathora's designated migration target. Built on Nitrado's 20+ years of game server infrastructure (Bohemia Interactive, CCP Games, Studio Wildcard). Supports Docker-native workflows, observability (Grafana, Prometheus, Loki), 67 global locations, Agones SDK compatibility, and dedicated migration support for Hathora refugees. No published pricing — all inquiries go through a sales demo call. No Godot plugin; Docker-based like Edgegap. The enterprise positioning (DDoS protection, War Room support, dedicated Slack channels) signals this is not targeting indie developers. If you're migrating from Hathora: https://gamefabric.com/hathora/ (visited 2026-04-28). Otherwise, Edgegap is the more indie-accessible alternative.

---

## 5. Recommendation for This Project

**Start here (in order):**

**Tier 1 — If shipping on Steam: GodotSteam (free)**  
Drop-in MultiplayerPeer using Steam Networking Sockets. NAT traversal and relay are handled by Valve's global network. Lobbies and matchmaking via Steamworks. Zero recurring cost. Used by Dome Keeper's 8-player co-op — the exact scenario this project targets. Begin integration when you're ready to move from single-player to networked sessions. Pair with Talo for leaderboards/cloud saves.  
Source: https://codeberg.org/godotsteam (visited 2026-04-28)

**Tier 2 — Managed backend for fastest iteration: GD-Sync Indie ($7/mo)**  
If you want to prototype co-op without any server DevOps, GD-Sync's Indie plan at $7/month is purpose-built for this use case: Godot 4 GDScript plugin, 8-player lobby ceiling, relay included, cloud storage included. Upgrade from free tier (4 players) when you're ready to test at full 8-player count. The flat-rate data pricing avoids surprise CCU bills. Evaluate whether the $7/mo provides enough value vs. the Steam-free path above.  
Source: https://www.gd-sync.com/pricing (visited 2026-04-28)

**Tier 3 — OSS self-host for full control: Nakama + netfox**  
If vendor lock-in is a concern (Hathora is a vivid lesson), self-host Nakama via Docker on a $10-20/month VPS (David Snopek's guide). Nakama handles auth, matchmaking, leaderboards, and storage. Pair with netfox (937 stars, GDScript, updated Nov 2025) for client-side prediction and lag compensation on the transport layer. This path has no recurring vendor cost beyond server hosting but requires upfront DevOps investment.  
Sources: https://github.com/heroiclabs/nakama-godot (visited 2026-04-28), https://github.com/foxssake/netfox (visited 2026-04-28)

**Services to skip for this project:**  
AWS GameLift (enterprise pricing, no Godot SDK), Photon Fusion (dev preview), Hathora (shut down), Beamable (no Godot integration), PlayFab (REST-only), GameFabric (opaque enterprise pricing). Colyseus is worth reconsidering if the Godot 4 client SDK is rewritten, but that's a future bet.

---

*Sources consulted (visited 2026-04-28):*  
- https://www.gd-sync.com/pricing  
- https://heroiclabs.com/pricing/  
- https://edgegap.com/pricing  
- https://edgegap.com/comparison/edgegap-vs-hathora  
- https://edgegap.com/blog/the-hidden-cost-of-aws-gamelift-s-pricing  
- https://trytalo.com/pricing  
- https://doc.photonengine.com/fusion-godot/current/fusion-intro  
- https://www.photonengine.com/fusion/pricing  
- https://hathora.dev/pricing  
- https://gamefabric.com/hathora/  
- https://codeberg.org/godotsteam  
- https://github.com/3ddelano/epic-online-services-godot  
- https://github.com/heroiclabs/nakama-godot  
- https://github.com/gsioteam/godot-colyseus  
- https://github.com/foxssake/netfox  
- https://ziva.sh/blogs/godot-multiplayer  
- https://forum.godotengine.org/t/use-the-multiplayer-api-or-nakama/130135  
- https://godotengine.org/asset-library/asset/2347 (GD-Sync)  
- https://godotengine.org/asset-library/asset/2936 (Talo)  
- https://godotengine.org/asset-library/asset/2453 (EOSG)  
