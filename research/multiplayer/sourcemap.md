# Multiplayer Source Map — Godot 4 + Co-op Platformer
**Generated:** 2026-04-28  
**Target project:** 2D Metroidvania, Godot 4.6.2, GDScript, 2–8 player co-op  
**Intel window:** Q4 2025 → present

---

## ⚠️ Surprises

**Hathora shut down (March 2026).** Hathora was acquired by Fireworks AI on approximately March 4, 2026. The game-server hosting platform was frozen immediately upon acquisition and will permanently shut down May 5, 2026. Existing customers are being redirected to GameFabric by Nitrado. Any guide, tutorial, or plugin referencing Hathora as a hosting option is now dead.  
Source: https://hathora.dev/pricing (shutdown notice live as of 2026-04-28)

**GodotSteam main GitHub repo archived (April 4, 2026).** The primary `GodotSteam/GodotSteam` GitHub repo went read-only on April 4, 2026. Development continues on Codeberg at `codeberg.org/godotsteam`. Links to GitHub issues/PRs on that repo are now dead ends.  
Source: GodotSteam GitHub page, confirmed 2026-04-28

**Photon Fusion for Godot is still a dev preview (not production-ready).** Fusion Godot SDK 3 explicitly states "development preview, not intended for production use." Despite marketing presence at GDC/GothamCon 2026, it is not a viable option today.  
Source: https://doc.photonengine.com/fusion-godot/current/fusion-intro

---

## Section 1: Active Venues, Ranked by Signal

### Godot Multiplayer Specifically

| Rank | Venue | URL | Signal | Justification |
|------|-------|-----|--------|---------------|
| HIGH | Godot official docs — Networking section (4.6) | https://docs.godotengine.org/en/4.6/tutorials/networking/ | Load-bearing | The canonical reference for MultiplayerAPI, MultiplayerSpawner, MultiplayerSynchronizer, ENet, WebRTC. Updated for 4.6. Read before anything else. |
| HIGH | forum.godotengine.org / Networking category | https://forum.godotengine.org/c/help/networking | Active | Thread "Realistically, how complicated is implementing multiplayer in Godot?" posted ~4 days ago (Apr 2026) shows ongoing community traffic. Maintainers respond here. |
| HIGH | godotengine/godot GitHub — topic:network issues/PRs | https://github.com/godotengine/godot/issues?q=label%3Atopic%3Anetwork | Active | Faless (Fabio Alessandrelli) merged PR #99963 (dummy IP/NetSocket for Web) showing 2026 maintenance. Filter by `topic:network` label. |
| HIGH | Ziva blog: "Godot Multiplayer in 2026: What Actually Works" | https://ziva.sh/blogs/godot-multiplayer | HIGH — best 2026 survey | Apr 1, 2026 post. Synthesizes Godot 4.6 limits, names Dome Keeper as shipped proof point, mentions GD-Sync and Nakama, lists specific failure modes (40-player ceiling, no rollback, no NAT traversal). |
| MED | r/godot (Reddit) — search "multiplayer" or "netcode" | https://www.reddit.com/r/godot/ | Noisy but current | High volume of "should I use X or Y" sentiment. Good for reading community satisfaction about specific services. Use for GD-Sync reviews, Nakama complaints, etc. |
| MED | godotengine/godot-proposals — networking tag | https://github.com/godotengine/godot-proposals/issues?q=is%3Aissue+label%3Atopic%3Anetwork | Architecture insight | Shows what the core team is (or isn't) planning. Useful for understanding the 4.7/5.0 networking roadmap — absence of big proposals signals no major API changes incoming. |
| MED | GodotAwesome — Godot 4 Multiplayer Networking Guide 2025 | https://godotawesome.com/godot-4-multiplayer-networking-guide-2025/ | Good tutorial index | Dated 2025; covers ENet, WebSocket, WebRTC transport options, Spawner/Synchronizer patterns. Slightly stale but still accurate for 4.6 fundamentals. |
| MED | Godot Interactive Changelog | https://godotengine.github.io/godot-interactive-changelog/ | Fact-checking tool | Filter by "network" or "multiplayer" to find exact commits per release. Use to verify what actually changed in 4.6 vs 4.5. |
| LOW | godotforums.org (unofficial) | https://godotforums.org/ | Low — split community | There are two Godot forums. This is the unofficial one; the official one (forum.godotengine.org) has more maintainer presence. Check the unofficial one only if the official forum has no hits. |
| LOW | GDQuest "Intro to Multiplayer in Godot" | https://www.gdquest.com/tutorial/godot/networking/intro-to-multiplayer/ | Good primer, not deep | Covers high-level API basics with a 2D shooting demo. Intro-level; no rollback, no authoritative server patterns. Useful for orientation, not architecture decisions. |

### Game-Networking General (Principles)

| Rank | Venue | URL | Signal | Justification |
|------|-------|-----|--------|---------------|
| HIGH | Gaffer on Games — game networking series | https://gafferongames.com/categories/game-networking/ | Canonical reference | Glenn Fiedler's articles (UDP basics, snapshot interpolation, client-side prediction) are the foundational texts. Content is ~2014–2018 vintage but principles are timeless and still cited in 2026 Godot discussions. |
| HIGH | mas-bandwidth.com (Glenn Fiedler's new blog) | https://mas-bandwidth.com/author/glenn/ | Active in 2026 | Fiedler's newer blog on game network programming and scalable backend engineering. netcode library updated Jan 28, 2026. Primary venue for his current thinking. |
| MED | multiplayernetworking.com — curated resource list | https://multiplayernetworking.com/ | Good index | Curated list of game network programming resources maintained by the community. Good for finding deep-cut references. |
| MED | StraySpark blog: Godot 4 Multiplayer Authoritative Server | https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server | ~1 month old | Published ~March 2026. Covers ENet peers, RPCs, Spawner/Synchronizer, common mistakes. Most current Godot-specific authoritative server walkthrough found. |
| LOW | Mirror Networking docs (Unity) | https://mirror-networking.gitbook.io/docs/ | Principles only | Concepts transfer but Unity-specific. Skip unless comparing architecture patterns specifically. |

### Cloud / Managed Multiplayer Services

Listed with pricing transparency, usage signals, and Godot integration status.

| Rank | Service | Pricing Transparency | Godot Integration | Usage Signal | Notes |
|------|---------|---------------------|-------------------|--------------|-------|
| HIGH | **GD-Sync** | Free tier (LAN, no account). Paid tiers by capacity — no credit card for free. Prices not published but upgrade is self-serve. | Native — built exclusively for Godot 4. GDScript plugin. v1.0 updated Apr 24, 2026. | 50,000+ MAU on platform; 6 shipped games showcased. | The only service built ground-up for Godot 4. Handles relay, lobbies, matchmaking, cloud storage, leaderboards, Steam integration. Self-serve pricing is a plus. Community Discord exists. Asset Library: https://godotengine.org/asset-library/asset/2347 |
| HIGH | **Nakama / Heroic Labs** | Open-source (self-host free). Heroic Cloud managed: from ~$600/mo (Satori); Nakama Cloud pricing is CPU-core-based (custom quote). Studio support: $2,000–$6,000+/mo. No free managed tier. | Godot 4 client SDK: 741 stars, v3.4.0 (Mar 2024). Server active: v3.38.0 (Mar 20, 2026). | Used by studios on GCP/AWS marketplaces. SOC 2 Type II. | Strong self-host option (Docker). Managed cloud is enterprise-priced — not indie-friendly unless self-hosting. Godot SDK last released March 2024; functional but not getting rapid updates. Pricing page: https://heroiclabs.com/pricing/ |
| HIGH | **GodotSteam + Steam Networking Sockets** | Free (Steam rev-share model). | GDExtension — integrates as MultiplayerPeer. v4.16.2 (2026). Main GitHub archived Apr 4, 2026; now on Codeberg. | Most battle-tested Godot multiplayer integration for Steam games. Dome Keeper used it. | Provides relay, NAT traversal, lobby, matchmaking via Steamworks. Only works on Steam. If shipping on Steam, this is the top recommendation. Codeberg: https://codeberg.org/godotsteam |
| MED | **Epic Online Services Godot (EOSG)** | EOS is free for any engine (Epic's monetization is via Epic Games Store cut). Plugin itself is free/open-source. | GDExtension. 289 stars. Last commit Mar 6, 2026 (v2.2.9). Godot 4.2+. | Active maintenance. Supports auth, lobbies, P2P, voice. | Good free relay/matchmaking for non-Steam games. Requires EOS account setup. Plugin by `3ddelano` is the main maintained option. GitHub: https://github.com/3ddelano/epic-online-services-godot |
| MED | **Talo Game Services** | Free tier for indie. Self-hostable (Docker). SaaS pricing not publicly listed — check trytalo.com. | Godot 4.6 plugin. v0.45.0 updated Apr 4, 2026. MIT license. | Active dev; leaderboards, analytics, multiplayer channels, cloud saves. | Open-source, self-hostable backend. Lighter than Nakama. Good for leaderboards + save data alongside multiplayer. Asset Library: https://godotengine.org/asset-library/asset/2936 |
| MED | **Colyseus** | Open-source server. Self-host free. Managed hosting pricing not well-documented. | Community Godot SDK exists (`gsioteam/godot-colyseus`) — Godot 3-era, not actively updated for Godot 4. | Popular in web/Phaser community. Edgegap uses it as a reference backend. | Viable if self-hosting Node.js server; the Godot client SDK is stale. Would require rewriting SDK for Godot 4 or using HTTP/WebSocket directly. |
| MED | **Edgegap** | Starts free. Usage-based pricing. More transparent than Nakama cloud. | No Godot-specific plugin. Docker-based deployment works with any Godot dedicated server. | Actively competes with (now-dead) Hathora. Positioned as alternative. | Good for hosting dedicated GDScript/headless Godot servers globally. No NAT/relay — pure orchestration. Comparison page (vs Hathora): https://edgegap.com/comparison/edgegap-vs-hathora |
| LOW | **Photon Fusion for Godot** | Photon has free tier (up to 20 CCU for development). Enterprise pricing opaque — sales call. | GDExtension SDK. Officially "development preview, not for production" as of Apr 2026. | Photon powers thousands of Unity titles (200M+ player titles cited). Godot SDK is brand new and unproven. | Do not use for production yet. Watch for stable release. Announced via @ExitGames on X. Docs: https://doc.photonengine.com/fusion-godot/current/ |
| LOW | **Hathora** | SHUT DOWN. Platform frozen Mar 2026, closes May 5, 2026. | Had a Godot GDScript addon (Mar 2025). Now meaningless. | N/A | Do not reference. Any tutorials using Hathora are now broken. Migrate recommendations to Edgegap or GameFabric. |
| LOW | **PlayFab (Microsoft)** | Free tier up to 10 CCU. Pricing scales with usage. | No official Godot SDK. REST API only. | Massive Microsoft backing. Used in AAA titles. | Too heavyweight for indie. Requires REST integration from scratch. Skip for 2–8 player co-op project. |
| LOW | **AWS GameLift** | No free tier for core service. Complex pricing. | No Godot SDK. | Enterprise-grade. | Far too complex and expensive for indie 2–8 player co-op. Skip. |
| LOW | **Beamable** | Freemium. Pricing tiers exist but Unity-focused. | No Godot integration. | Unity-only ecosystem effectively. | Skip. |

### GitHub Repos — Godot-Specific Multiplayer

| Repo | Stars | Last Updated | Verdict |
|------|-------|-------------|---------|
| `foxssake/netfox` | 937 | Nov 23, 2025 | HIGH — best open-source client-side prediction + lag comp kit for Godot 4 GDScript. Ships noray for P2P relay. https://github.com/foxssake/netfox |
| `heroiclabs/nakama-godot` | 741 | (v3.4.0, Mar 2024) | MED — functional, not rapidly updated. https://github.com/heroiclabs/nakama-godot |
| `3ddelano/epic-online-services-godot` | 289 | Mar 6, 2026 | MED — actively maintained EOSG plugin. https://github.com/3ddelano/epic-online-services-godot |
| `grazianobolla/godot-monke-net` | 238 | Apr 3, 2026 | MED — C# only (not GDScript). Authoritative server with client-side prediction. https://github.com/grazianobolla/godot-monke-net |
| `gitlab.com/snopek-games/godot-rollback-netcode` | N/A (GitLab) | Unknown (check directly) | MED — David Snopek's rollback netcode addon for Godot. GDScript. No confirmed 2026 updates found; check GitLab directly before relying on it. https://gitlab.com/snopek-games/godot-rollback-netcode |
| `GD-Sync/GD-Sync` | N/A (private?) | Feb 3, 2026 (Asset Lib) | HIGH — source behind gd-sync.com managed service. https://github.com/GD-Sync/GD-Sync |

### YouTube / Video

| Rank | Creator/Series | Signal | Notes |
|------|---------------|--------|-------|
| HIGH | Bippinbits — GodotCon 2025 talk (Dome Keeper multiplayer) | Proof point | Developers of a $6.1M-revenue Godot game explaining how they added online co-op + competitive to a 10k-line GDScript codebase. Find via GodotCon 2025 recordings. |
| MED | GDQuest — "Intro to Multiplayer in Godot" playlist | Fundamentals | Covers high-level API, lobby, peer connections. Best starting-point video series though intro-level. https://www.youtube.com/playlist?list=PLhqJJNjsQ7KHohKIdqyTHRr96zYreZMC7 |
| MED | "Godot 4 Steam Multiplayer Tutorial" (Dec 17, 2025) | Steam-specific | Up-to-date tutorial on GodotSteam + Steam Networking for Godot 4. URL: https://www.youtube.com/watch?v=FHBJ-auzaeM |
| MED | "Rollback netcode in Godot (part 1)" | Rollback theory | Covers what rollback is before you implement. https://www.youtube.com/watch?v=zvqQPbT8rAE |
| LOW | Generic "Godot Makes Multiplayer Easy" shorts | Skip | Beginner-grade, no depth on authoritative server / rollback / CSP. |

### Discord / Mastodon

| Rank | Venue | Signal | Notes |
|------|-------|--------|-------|
| HIGH | Godot official Discord — #networking channel | Live Q&A | Faless and other core contributors occasionally respond. Best place for edge-case API questions. https://chat.godotengine.org/ |
| MED | GD-Sync Discord | Service-specific | Direct line to GD-Sync developers. Good for pricing/feature questions. Linked from gd-sync.com. |
| LOW | Mastodon #godot / #netcode tags | Sparse | Occasional posts by core team, but low SNR for multiplayer specifically. |

### Blogs

| Rank | Blog | URL | Signal |
|------|------|-----|--------|
| HIGH | mas-bandwidth.com (Glenn Fiedler) | https://mas-bandwidth.com/ | Active 2026. Game network engineering principles from the author of yojimbo/netcode. |
| HIGH | godotsteam.com/blog | https://godotsteam.com/blog/ | GodotSteam release notes; Oct 2025 archive confirms active cadence. |
| MED | StraySpark — authoritative server post | https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server | ~Mar 2026. |
| MED | Heroic Labs blog | https://heroiclabs.com/blog/ | Nakama release news; Godot 4 integration post: https://heroiclabs.com/blog/nakama-godot-4/ |
| LOW | godotawesome.com | https://godotawesome.com/ | 2025-dated guide. Useful but not 2026-updated. |

---

## Section 2: High-Signal Individual Contributors (~15 targets)

| Name / Handle | Domain | Primary Venue | Why Useful | Example Contribution |
|---------------|--------|---------------|------------|----------------------|
| **Faless** (Fabio Alessandrelli) | GDScript RPC, MultiplayerAPI, ENet/WebRTC bindings | GitHub: https://github.com/faless | Networking maintainer for Godot core. Historically drove the entire 4.x multiplayer API redesign. Still merging PRs in 2026. | PR #99963: Implement dummy IP and NetSocket for Web platform (2026) |
| **reduz** (Juan Linietsky) | Engine architecture, GDScript design | GitHub: https://github.com/reduz | Co-creator and technical director. His positions on networking API direction are binding. Follow for 5.0 architecture signals. | Directional authority on MultiplayerAPI design in Godot 4.0 overhaul |
| **David Snopek** | Rollback netcode, Nakama+Godot integration | GitLab: https://gitlab.com/dsnopek | Author of the canonical Godot rollback netcode addon; wrote the "How to host Nakama for $10/mo" guide. | godot-rollback-netcode addon; blog post on Nakama self-hosting |
| **Bippinbits team** (handle: Bippinbits) | Production co-op in GDScript at scale | GodotCon 2025 talk; Steam page | Shipped Dome Keeper multiplayer (up to 8 players online) Apr 13, 2026. Presented methodology at GodotCon 2025. The only public case study of shipping online co-op in a Godot 4 GDScript title as of 2026. | Dome Keeper multiplayer update + GodotCon 2025 presentation |
| **grazianobolla** | Client-side prediction, authoritative server (C#) | GitHub: https://github.com/grazianobolla | Author of godot-monke-net (238 stars, updated Apr 3, 2026). Most complete authoritative-server addon in the Godot ecosystem, though C# only. | godot-monke-net: client prediction + server reconciliation addon |
| **foxssake** (team) | Lag compensation, CSP, interpolation (GDScript) | GitHub: https://github.com/foxssake | Authors of netfox (937 stars), the leading GDScript toolkit for responsive online games. Ships noray for relay. | netfox v1.35.3 released Nov 2025; multiple shipped Steam games |
| **GD-Sync team** | Managed Godot multiplayer backend | Website: https://www.gd-sync.com | Only managed service built ground-up for Godot 4. 50k+ MAU. Active development (v1.0 Apr 24, 2026). Best single vendor to watch for "batteries included" co-op. | GD-Sync plugin v1.0, Apr 2026; integrated relay + lobby + cloud storage |
| **Glenn Fiedler** (gafferongames) | UDP protocol design, client-side prediction, rollback theory | https://mas-bandwidth.com + gafferongames.com | The canonical reference author for game networking fundamentals. Not Godot-specific but every Godot netcode implementation cites his articles. Active in 2026 (netcode lib commit Jan 28, 2026). | "Game Networking" series; yojimbo, netcode open-source libraries |
| **3ddelano** | Epic Online Services integration for Godot 4 | GitHub: https://github.com/3ddelano | Author of the main EOSG plugin (289 stars, v2.2.9 Mar 2026). Provides free lobby/matchmaking/relay via EOS for non-Steam titles. | EOSG plugin: GDExtension wrapping Epic C SDK for Godot 4.2+ |
| **TizWarp** | Steam MultiplayerPeer | GitHub: https://github.com/TizWarp | Maintains SteamMultiplayerPeer addon, which lets you use Steam Networking Sockets as a drop-in MultiplayerPeer. Part of the GodotSteam ecosystem migration to Codeberg. | SteamMultiplayerPeer addon https://github.com/TizWarp/SteamMultiplayerPeer |
| **Heroic Labs (Nakama team)** | Open-source game backend: auth, matchmaking, storage | https://heroiclabs.com / https://github.com/heroiclabs | Most mature open-source backend in the space. Nakama v3.38.0 (Mar 20, 2026). Godot 4 SDK available. Useful for self-hosted backend work if you need more than GD-Sync. | Nakama server v3.38.0; Heroic Cloud managed offering |
| **mhilbrunner** | Godot networking docs/proposals | GitHub: https://github.com/mhilbrunner | Authored the "Unofficial Godot 4.0 Pre-Alpha Multiplayer Changes Overview" gist — still frequently cited in 2025/2026 networking discussions as a reference for the 4.x redesign rationale. | Godot 4.0 multiplayer changes overview gist |
| **Talo/Sleepy Studios** | Open-source backend for Godot | GitHub: https://github.com/TaloDev + https://trytalo.com | Talo is a free, self-hostable backend with leaderboards, analytics, cloud saves, and a Godot 4.6 plugin (v0.45.0, Apr 4, 2026). Good lightweight complement to whatever transport layer you choose. | Talo Godot plugin, channel storage for shared multiplayer state |
| **Andrew Davis** | Godot netcode tips (practitioner) | https://jonandrewdavis.com/drafts/draft-of-godot-network-tips/ | Practitioner-level blog: "Godot Multiplayer: 3 Quick Tips for Better Netcode." Small signal but specific to GDScript patterns. | Blog post on reducing RPC overhead in Godot 4 |
| **Rivet engineering team** | Godot + cloud scalability benchmarking | (found via Ziva blog, Apr 2026) | Conducted and published benchmarking analysis on Godot's multiplayer scalability ceiling (~40 CCU per server limit). Quoted as calling Godot's lack of rollback "a deal-breaker for serious development." Worth tracking for follow-on technical posts. | Scalability analysis quoted in Ziva Apr 2026 post |

---

## Section 3: Recent Milestones (Post-Jan 2026)

### Godot 4.6 (Released ~Jan 28, 2026)

- **No major multiplayer API changes** in 4.6. The high-level API (MultiplayerAPI, MultiplayerSpawner, MultiplayerSynchronizer, ENet, WebRTC, WebSocket) is functionally identical to 4.5.
- 4.6.1 maintenance release (Feb 16, 2026): zero networking/multiplayer fixes — confirms the subsystem is stable, not broken.
- Jolt became the default 3D physics engine; LibGodot introduced. Neither affects networking.
- ENet remains the default transport (UDP). WebSocket (TCP) and WebRTC (P2P) are the other built-in options.
- **Known limits confirmed as of 4.6:** No client-side prediction, no rollback, no NAT traversal, no built-in matchmaking/lobby. Stability degrades above ~40 CCU per server.
- Source: https://godotengine.org/article/maintenance-release-godot-4-6-1/ + Ziva blog

### Godot 4.7 (Beta 1, ~Apr 2026)

- **No significant multiplayer/networking changes found** in 4.7 beta 1. Focus is on editor QoL, HDR output, 2D physics improvements, VirtualJoystick, tween await.
- Interactive changelog at https://godotengine.github.io/godot-interactive-changelog/ is the authoritative filter tool to verify this as stable releases arrive.
- Source: https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627 + 80.lv coverage

### Godot 5.0

- **No release. No announced release date.** As of April 2026, Godot 5.0 is not released and no shipping date has been announced. Do not plan around it.

### Service Updates (Q4 2025–Q2 2026)

| Service | Update | Date | Impact |
|---------|--------|------|--------|
| **Hathora** | Acquired by Fireworks AI; game platform shut down | Mar 4, 2026 → May 5, 2026 | Any Hathora integration is dead. Existing devs migrating to Edgegap/GameFabric. |
| **GD-Sync** | v1.0 released; updated to Godot 4.5 support | Apr 24, 2026 | Major milestone — v1.0 signals production readiness. |
| **Nakama** | v3.38.0 server released | Mar 20, 2026 | Routine release; no Godot SDK-specific changes. Godot client SDK last released Mar 2024. |
| **GodotSteam** | v4.16.2; GitHub repo archived (now Codeberg) | Apr 4, 2026 | Update bookmarks to codeberg.org/godotsteam. Functionality unchanged. |
| **EOSG** | v2.2.9; added HEOS (High-Level EOS) API | Mar 6, 2026 (Feb 10, 2026 Asset Lib) | Easier high-level authentication and lobby API for non-Steam games. |
| **Photon Fusion Godot** | SDK 3 announced; still dev preview | 2025 (exact date unclear) | Not production-ready. Watch for stable release announcement. |
| **Talo** | v0.45.0; added channel storage for shared multiplayer state | Apr 4, 2026 | Useful lightweight companion backend. |
| **netfox** | v1.35.3 | Nov 23, 2025 | Last known release. Monitor for 2026 releases. |

### Shipped Multiplayer Games in Godot (Proof Points, 2025–2026)

| Game | Studio | Detail | Signal |
|------|--------|--------|--------|
| Dome Keeper (multiplayer update) | Bippinbits | Online co-op + competitive, up to 8 players. Shipped Apr 13, 2026. $6.1M in Steam revenue. Presented at GodotCon 2025. | STRONGEST proof that 2–8 player Godot co-op is viable in production. |
| Hazmat Henry | Unknown | First-person multiplayer shooter. Released Apr 22, 2026. | Smaller proof point; confirms multiplayer pattern works in 2026. |
| Cassette Beasts | Bytten Studio | Local co-op (partner character). Steam + Xbox + Switch. | Proof of local co-op; not online. |
| Road to Vostok | Solo dev | Hardcore survival shooter. Early Access 2026. | Godot single-player; notable for engine credibility. |

---

## Section 4: Sources to Skip (Stale or Dead)

| Source | Reason to Skip |
|--------|---------------|
| Any Hathora tutorial or integration guide | Platform shut down May 2026. |
| GodotSteam GitHub (`GodotSteam/GodotSteam`) | Archived Apr 4, 2026. Use Codeberg instead. |
| Photon GDScript Client SDK for Godot 3.x (`Daylily-Zeleen/Photon-GDScript-SDK-for-Godot-3.x`) | Godot 3 era; superseded by Fusion Godot. |
| `gsioteam/godot-colyseus` | Godot 3 SDK, not updated for Godot 4. |
| `DoubleDeez/MDFramework` | Godot 3.4 Mono. Dead. |
| `Pamtic/godot-photon-bolt` | No such repo found under that name; the prompt referenced a speculative repo. Skip. |
| Godot 3.x multiplayer tutorials | API is substantially different from Godot 4. RPC system was redesigned. |
| BeamableSDK | No Godot integration. Unity-only. |
| AWS GameLift | No Godot SDK; enterprise-only pricing; overkill for indie 2–8 player co-op. |
| PlayFab | No Godot SDK; REST-only; Unity-focused documentation. |
| godotforums.org (unofficial forum) | Lower signal than official forum.godotengine.org; maintainers rarely present. |

---

*Crawl sources: GitHub Topics, Godot Asset Library, forum.godotengine.org, ziva.sh, godotsteam.com, hathora.dev, heroiclabs.com, gafferongames.com, mas-bandwidth.com, foxssake/netfox, 3ddelano/EOSG, gd-sync.com, trytalo.com, strayspark.studio, doc.photonengine.com, GamingOnLinux, 80.lv.*
