# 2D Co-op Patterns: What Shipped Games Actually Do
**Generated:** 2026-04-28  
**Target project:** 2D Metroidvania, Godot 4.6.2 + GDScript, 2–8 player co-op  
**Intel window:** Post-launch / postmortem sources through April 2026

---

## TL;DR (5 bullets)

- **Steam relay + listen-server is the indie 2D co-op default.** Dome Keeper (8-player, shipped Apr 2026) used GodotSteam + Steam Networking Sockets as a drop-in MultiplayerPeer — no dedicated servers, no custom relay. That is the lowest-friction path for a Steam-shipped Godot game.
- **Player cap rarely exceeds 4 for Metroidvania / exploration genres; 2 is the sweet spot.** Salt and Sacrifice (2-player), Salt and Sanctuary (2-player), and Spelunky 2 (4-player) all converge here. 8-player only works for Dome Keeper because the "arena" is tiny and turn-structured.
- **Save model converges on host-owns-world-state, guest keeps character XP.** Castle Crashers pioneered this; Salt and Sacrifice confirmed it (host's world, both retain salt/progress). Avoid giving guests zero progress — players revolt.
- **Camera in 2D co-op is a genuine design hazard.** Spelunky 2 tethered the camera to player 1 and was roundly criticised; the community shipped a zoom-out mod because the base game felt broken. Shared elastic-zoom camera is the lesson.
- **Fast pixel-precise 2D games are hostile to high-latency netcode.** TowerFall (local-only by design) and Risk of Rain 1 (clunky P2P, port-forward required) both teach the same lesson: if your combat is frame-tight, you must budget for rollback or lag-compensation — Godot 4's built-in API has neither.

---

## Per-Game Blocks

### Dome Keeper (Bippinbits, Apr 13 2026)
**Connection model:** Listen-server over GodotSteam (Steam Networking Sockets relay + NAT traversal) — integrates as a drop-in `MultiplayerPeer`, so existing RPC/replication code needed no restructuring.  
**Player cap:** Up to 8 (online or local split-screen mix).  
**Drop-in / drop-out:** Not confirmed in public sources; game is round-based so mid-session joins are architecturally easier.  
**Save model:** Session-based round — no persistent campaign save to conflict.  
**Notes:** Added to a 10,000+ line GDScript codebase with no rollback. Works because Dome Keeper is slow-paced (mining loop with turn-structured waves) — high latency tolerance. Community reports "no lag at all, very clean netcode." GodotSteam is now on Codeberg (GitHub archived Apr 4 2026).  
**Citation:** GodotCon 2025 talk "Keeper to Keepers" — https://talks.godotengine.org/godotcon-us-2025/talk/XMBFFK/ ; YouTube recording https://www.youtube.com/watch?v=MEZoKKAoUAU ; launch coverage https://www.gamingonlinux.com/2026/04/dome-keeper-free-multiplayer-update-and-lost-keepers-dlc-have-launched/

---

### Spelunky 2 (Mossmouth, 2020)
**Connection model:** Dedicated servers (Mossmouth-run fleet, server-based not P2P). Derek Yu confirmed publicly: "S2's multiplayer is server-based, so distance from other players isn't a factor."  
**Player cap:** 4 (co-op and deathmatch).  
**Drop-in / drop-out:** Not mid-level; join at lobby between runs.  
**Save model:** Roguelike — no persistent save to conflict; each run starts fresh.  
**Notes:** Shipped with two desync classes: hard desyncs (wrong level) and soft desyncs (clock drift when CPU too slow). Camera follows player 1 only — widely criticised; community built a zoom-out mod. Takeaway: a shared elastic-zoom camera is non-negotiable for exploration co-op.  
**Citation:** Derek Yu on X (Sep 2020) https://x.com/mossmouth/status/1305944380524515328 ; co-op camera mod https://spelunky.fyi/mods/m/co-op-shared-camera/

---

### Salt and Sacrifice (Ska Studios, 2022)
**Connection model:** P2P via password-protected session (no observed relay infrastructure). Players connect via a hub board using rune passwords or consumable summon items.  
**Player cap:** 2 cooperative (3 with limitations).  
**Drop-in / drop-out:** Yes — asynchronous Soulslike summon model. Guest enters host's world via candle item; leaves by dying or finishing a mage boss.  
**Save model:** Host owns world state (which mages are spawned, area unlocks). Both players retain salt/items earned during the session. Failing an online mission does not reset your salt — you teleport back to hub.  
**Notes:** Invasion (PvP) is the third-player slot. No dedicated servers means NAT issues cause persistent connection failures — a known community pain point. Very Metroidvania-adjacent: area-locked co-op, host progression.  
**Citation:** Fextralife wiki multiplayer page https://saltandsacrifice.wiki.fextralife.com/Multiplayer ; Game Rant co-op guide https://gamerant.com/salt-and-sacrifice-how-to-co-op-multiplayer-local-online-friend-random/

---

### Risk of Rain 1 (Hopoo Games, 2013)
**Connection model:** Listen-server (host = one of the players). Built in GameMaker: Studio. Requires manual port-forwarding on port 11100 TCP+UDP — no relay, no UPnP. Hamachi/Tunngle were the community workarounds.  
**Player cap:** 4 (editable via config).  
**Drop-in / drop-out:** No mid-run joins; all players must be present at character select.  
**Save model:** No persistent save — roguelike run-based. Host's run state is authoritative.  
**Notes:** Multiplayer was bolted on post-launch. Community described it as "a crapshoot." High-latency tolerance because the game is third-person-ish with large hitboxes and no pixel-precise collision — but still showed desync with bad connections. Port-forwarding barrier killed session formation for casual players. Risk of Rain 2 moved to listen-server over Steam for this reason.  
**Citation:** PCGamingWiki https://www.pcgamingwiki.com/wiki/Risk_of_Rain ; Steam port-forwarding guide https://steamcommunity.com/sharedfiles/filedetails/?id=193316279

---

### Castle Crashers (The Behemoth, 2008/2012 PC)
**Connection model:** Peer-to-peer (host = lobby creator). Steam matchmaking for session discovery; no dedicated servers.  
**Player cap:** 4.  
**Drop-in / drop-out:** Players join before a level starts; mid-level joins not documented.  
**Save model:** Each player saves their own character's XP, gold, and unlocks across sessions. World level-completion is per-character. Guest progress IS saved in online mode (unlike local guest-profile on Switch, which requires a second Switch account). Classic template: "your character is yours, the world is shared."  
**Notes:** P2P requires lowered security settings; VPNs/strict NAT cause connectivity failures. Oldest template in the dataset: character-owns-progression, host-owns-world-unlock — still the genre default in 2026.  
**Citation:** The Behemoth support https://support.thebehemoth.com/hc/en-us/articles/360033513992-Local-Progress-is-not-saving-for-guests ; Steam co-op guide https://steamcommunity.com/sharedfiles/filedetails/?id=362495959

---

### Brawlhalla (Blue Mammoth / Ubisoft, 2017)
**Connection model:** Client-server with authoritative dedicated servers (Blue Mammoth/Ubisoft-run, regional: US-East, US-West, EU, SEA, AU, JP, BR).  
**Player cap:** Up to 8 in casual/training modes; 1v1 and 2v2 in ranked.  
**Drop-in / drop-out:** Lobby-based matchmaking; no mid-match joins.  
**Save model:** Account-based cloud progression — no per-session conflict.  
**Notes:** Uses rollback netcode with hybrid input-delay for high-latency players. Network Next routing layer reduces rollback spike magnitude. Players with poor connections get auto input-delay added so they don't cascade rollbacks to everyone else. Not Photon Quantum — that's Photon's deterministic framework for other titles (still a dev preview for Godot as of Apr 2026). Brawlhalla is one of the few 2D games that ships full rollback — achievable because the game is deterministic and hitboxes are relatively large vs. movement speed.  
**Citation:** Brawlhalla rollback discussion https://steamcommunity.com/app/291550/discussions/0/2796125475578125556/ ; Network Next https://www.playbrawlhalla.com/brawlhalla_server_status/

---

### TowerFall Ascension (Matt Thorson, 2014) — local-only case study
**Connection model:** Local multiplayer ONLY. No online. Deliberate design decision.  
**Player cap:** 4 local (2-player co-op campaign).  
**Drop-in / drop-out:** N/A.  
**Save model:** Local save.  
**Notes:** Thorson explicitly researched online netcode before shipping and concluded TowerFall's pixel-precise hitboxes made even "perfect netcode" feel broken. The core problem: in a fast 2D arena, the ratio of positional uncertainty to hitbox size is much higher than in 3D shooters. A 10ms input-lag discrepancy that's invisible in Counter-Strike is a full body-width miss in TowerFall. This is the canonical argument for why fast 2D platformers demand rollback if they want online. TowerFall chose to skip online rather than compromise feel.  
**Citation:** Creator quote via Shacknews https://www.shacknews.com/article/83560/towerfall-ascension-creator-discusses-local-multiplayer-only-approach ; Steam discussion thread https://steamcommunity.com/app/251470/discussions/1/620713633847139850/

---

## Cross-Game Pattern Summary

### 1. Connection model
The genre converges on **Steam relay (GodotSteam / SteamNetworkingSockets) or P2P for indie**, with dedicated servers reserved for well-funded or heavily PvP-oriented titles (Spelunky 2, Brawlhalla). P2P without relay (Risk of Rain 1, Castle Crashers, Salt and Sacrifice) creates persistent NAT/firewall hell. Relay is the minimum viable bar for a good player experience.

### 2. Player cap
- Metroidvania / exploration: **2 is standard**, 4 is ambitious, 8 is unusual and requires structural reasons (Dome Keeper's bounded arena).
- Brawler / arena: 4–8 with dedicated infra.
- Design heuristic: every additional player multiplies camera, room-transition, and save-state complexity non-linearly.

### 3. Drop-in / drop-out
Soulslike summon model (Salt and Sacrifice) is the Metroidvania solution: guest enters host's world at a defined checkpoint, exits cleanly. Mid-level join is rarely supported in any of these titles — too much state to sync. Design around session-gated entry.

### 4. Save game model
Universal pattern: **host owns world state (area unlocks, boss defeats), each player owns their character state (XP, items, abilities)**. Giving guests zero progress is the failure mode (documented player backlash in multiple titles). Giving guests full world progress with no session leads to sequence-break exploits. The "character-is-yours, world-belongs-to-host" split is the correct default.

### 5. Latency tolerance
Exploration / mining / roguelike co-op is **very high tolerance** (>150ms acceptable). Fast combat platformers (TowerFall, Brawlhalla) require <30ms effective latency and mandate rollback. A Metroidvania sits in the middle: exploration rooms are forgiving, boss fights are not. Plan for lag-compensation on combat interactions, tolerance elsewhere.

### 6. Camera gotchas
Shared camera with elastic zoom (pulls back as players separate) is the correct pattern. Tethered-to-P1 camera (Spelunky 2) is a documented failure that spawned community mods. Split-screen is technically complex and uncommon in indie 2D. For room-transition sync: the simplest approach is blocking transition until all players reach the door, then hard-cut together — messy alternatives have worse failure modes.

---

## Recommendation: Design Choices to Lock In Early

These decisions are expensive to reverse. Lock them before writing networking code.

**1. Transport: GodotSteam + Steam Networking Sockets as MultiplayerPeer.**  
Dome Keeper proves this works in production at up to 8 players in Godot 4 GDScript. Provides relay, NAT traversal, lobby, and friends-list for free. Only constraint: Steam-only. If you later add non-Steam platforms, layer in Epic Online Services (EOSG plugin, free) as a second transport. Do NOT use raw ENet without relay — you'll reproduce Risk of Rain 1's NAT problems.

**2. Player cap: 2 co-op for v1, architect for 4.**  
Two players is the correct Metroidvania default (Salt and Sacrifice, Salt and Sanctuary). Build the camera, room-transition, and save systems for 4 so you're not blocked later, but ship targeting 2. Defer 8-player until you have a bounded mode (arena/dungeon run) to contain the complexity.

**3. Save model: host-owns-world, guest-owns-character. Commit to this schema in your save file format early.**  
Design `GameState` (room clears, boss kills, gate unlocks) separately from `PlayerState` (abilities, upgrades, map exploration). On session join, the host sends `GameState` to sync guests. On session end, each player writes their `PlayerState` locally. This is the Castle Crashers / Salt and Sacrifice pattern and has 15+ years of validation.

**4. Camera: shared elastic zoom, single viewport.**  
Target a max zoom-out factor of ~1.8x before splitting or blocking. When players diverge beyond the zoom limit, soft-lock the far player at the screen edge until camera re-centers (don't teleport). Never tether to one player. Implement this before multiplayer netcode — it's a camera math problem, not a network problem, and getting it wrong poisons the whole feel.

**5. Room transitions: gate-and-hard-cut.**  
When any player touches a room-exit trigger, show a "waiting for party" indicator. Once all players are at the same exit, hard-cut to the next room together. This is synchronously safe with Godot's MultiplayerAPI. Async transitions (player 1 in room B, player 2 still in room A) require a streaming/zone model that is significantly more complex — defer to a later phase.

**6. Latency: build in a lag-compensation layer on combat hits, not on movement.**  
Godot 4's built-in API has no rollback and no client-side prediction (confirmed 4.6). For exploration and platforming, server-authority on position is acceptable. For hit detection on fast melee/projectile, you need at minimum a rewind-based hit-validation pass. See netfox (foxssake/netfox, 937 stars, GDScript) for the best available GDScript toolkit — it ships lag compensation without requiring full rollback.

**7. No mid-level drop-in for v1.**  
Lock the session at room-transition boundaries. If a player disconnects mid-room, their character becomes an NPC or freezes until they reconnect. Drop-in at any room boundary is v2 scope. This avoids having to serialize and sync full mid-room game state, which is the hard problem Salt and Sacrifice dodged by making the hub always the entry point.

---

*Sources: GodotCon 2025 talk abstract https://talks.godotengine.org/godotcon-us-2025/talk/XMBFFK/ ; YouTube talk https://www.youtube.com/watch?v=MEZoKKAoUAU ; Ziva 2026 survey https://ziva.sh/blogs/godot-multiplayer ; GamingOnLinux Dome Keeper https://www.gamingonlinux.com/2026/04/dome-keeper-free-multiplayer-update-and-lost-keepers-dlc-have-launched/ ; Derek Yu (Spelunky 2 server-based) https://x.com/mossmouth/status/1305944380524515328 ; Spelunky zoom-out mod https://spelunky.fyi/mods/m/co-op-shared-camera/ ; Salt and Sacrifice wiki https://saltandsacrifice.wiki.fextralife.com/Multiplayer ; PCGamingWiki Risk of Rain https://www.pcgamingwiki.com/wiki/Risk_of_Rain ; The Behemoth save support https://support.thebehemoth.com/hc/en-us/articles/360033513992-Local-Progress-is-not-saving-for-guests ; TowerFall creator quote https://www.shacknews.com/article/83560/towerfall-ascension-creator-discusses-local-multiplayer-only-approach ; Brawlhalla netcode threads https://steamcommunity.com/app/291550/discussions/0/2796125475578125556/*
