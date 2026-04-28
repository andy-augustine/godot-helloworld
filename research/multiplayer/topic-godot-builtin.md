# Godot 4.6.2 Built-In Multiplayer Stack — State of Play (April 2026)

**Generated:** 2026-04-28  
**Engine version:** Godot 4.6.2 (4.6.1 maintenance Feb 16, 2026; no networking fixes — subsystem stable)  
**Audience:** 2D Metroidvania, GDScript, 2–8 player co-op evaluation

---

## 1. TL;DR

- The built-in API (MultiplayerAPI, ENet, Spawner, Synchronizer, @rpc) is fully functional and unchanged between 4.5 and 4.6.2. Dome Keeper shipped online co-op for up to 8 players with it in April 2026 — proof the path works at this scale.  
- What you get for free: reliable transport, property sync, RPC routing, authority gating. What you must build yourself: client-side prediction, rollback, NAT traversal, lobby/matchmaking, interest management, delta compression.  
- ENet (UDP) is the default and right choice for a 2–8 player game on a dedicated/listen server. WebRTC adds browser-native NAT traversal but at operational complexity cost. WebSocket is for web exports only.  
- The ~40 CCU per server ceiling is a real constraint — irrelevant at 2–8 players but rules out any future MMO-style ambition without a third-party layer.  
- For our project the three load-bearing concerns are: (a) autoloads `Inventory` and `Skills` are singletons — they will diverge per peer unless explicitly synced via RPC; (b) the room-swap in `World.gd` must be driven by the authority and replicated; (c) the state machine in `_physics_process` is input-driven and will feel broken without client-side prediction, which the built-in stack does not provide.

---

## 2. Feature-by-Feature

### 2.1 MultiplayerAPI + Peer Implementations

`SceneMultiplayer` is the concrete implementation of the abstract `MultiplayerAPI`. It attaches to the `SceneTree` and routes RPCs and replication by peer ID. Every peer gets a unique integer ID; the host/server is always peer ID **1**. Clients are assigned IDs > 1 at connection time.

```gdscript
# Host (server or listen-server)
var peer := ENetMultiplayerPeer.new()
peer.create_server(4242, 8)          # port, max_clients
multiplayer.multiplayer_peer = peer

# Client
var peer := ENetMultiplayerPeer.new()
peer.create_client("127.0.0.1", 4242)
multiplayer.multiplayer_peer = peer

# Signals
multiplayer.peer_connected.connect(_on_peer_connected)
multiplayer.peer_disconnected.connect(_on_peer_disconnected)
multiplayer.connected_to_server.connect(_on_connected)   # client only
```

**Peer implementations (all built-in, no plugin needed):**

| Peer class | Transport | Built-in? | NAT traversal |
|---|---|---|---|
| `ENetMultiplayerPeer` | UDP (ENet) | Yes | None — needs relay or external holepunch |
| `WebRTCMultiplayerPeer` | DTLS/UDP (WebRTC) | Yes (via GDExtension in export) | Built-in via STUN/TURN |
| `WebSocketMultiplayerPeer` | TCP/WS | Yes | None (same as TCP) |

Source: https://docs.godotengine.org/en/4.6/tutorials/networking/ (2026-04-28)

---

### 2.2 High-Level Scene Replication: Spawner + Synchronizer

**`MultiplayerSpawner`** watches a node path and auto-spawns/despawns scenes on all peers when the authority adds or removes children. Only the authority (server) spawns; clients receive the spawn signal automatically.

```gdscript
# Server side — just add the child; MultiplayerSpawner broadcasts the spawn
var player := PlayerScene.instantiate()
$Players.add_child(player)
player.name = str(peer_id)
```

The spawner must have the target scene in its `spawnable_scenes` list (Inspector or `add_spawnable_scene()`). The spawner node lives in a scene shared by all peers.

**`MultiplayerSynchronizer`** replicates specific properties and/or calls on a configurable schedule. Two replication modes:

- **Always** — sends every physics tick (reliable or unreliable per property)
- **On change** — diff-sends, but Godot's diff check is equality-based, not delta-compressed

Properties are wired in the Inspector on the `MultiplayerSynchronizer` node (e.g., `position` unreliable/always, `animation` reliable/on-change). Only the authority peer sends; others receive.

```gdscript
player.set_multiplayer_authority(peer_id)
```

Source: https://docs.godotengine.org/en/4.6/tutorials/networking/ (2026-04-28); confirmed unchanged in 4.6 by interactive changelog https://godotengine.github.io/godot-interactive-changelog/ (2026-04-28)

---

### 2.3 RPC System

`@rpc` is GDScript's remote procedure call annotation. In 4.x the annotation fully replaces the old keyword syntax.

```gdscript
# Syntax: @rpc(mode, call_local, transfer_mode, channel)
@rpc("any_peer", "call_local", "reliable")
func take_damage(amount: int) -> void:
    health -= amount
    _update_hud()

# Call — server sends to all clients:
take_damage.rpc(10)                  # broadcasts to all peers
take_damage.rpc_id(peer_id, 10)     # sends to specific peer
```

**`mode` options:**

| Mode | Who can call |
|---|---|
| `"authority"` | Only the authority of that node (default) |
| `"any_peer"` | Any connected peer |

**`call_local`:** If present, the function also runs locally on the caller. Omit (default) to run only on remote peers.

**`transfer_mode` options:**

| Mode | Guarantee | Use for |
|---|---|---|
| `"reliable"` | Ordered, delivered | state changes, damage, pickups |
| `"unreliable"` | No guarantee, no order | raw position snapshots |
| `"unreliable_ordered"` | No guarantee, but ordered | input streams |

**Authority gating** is not automatic — you must guard RPCs manually:

```gdscript
@rpc("any_peer")
func request_spawn() -> void:
    if not is_multiplayer_authority():
        return   # ignore if we're not the server
    _do_spawn()
```

Source: https://docs.godotengine.org/en/4.6/tutorials/networking/ (2026-04-28); StraySpark authoritative server walkthrough https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server (~March 2026, accessed 2026-04-28)

---

### 2.4 Transport Layers

#### ENet (default, UDP)

- Best choice for a LAN or server-hosted game. Low latency, configurable reliability channels.
- **No built-in NAT traversal.** A host behind NAT is unreachable without a relay (e.g., Edgegap server, GD-Sync relay) or external holepunch library.
- MTU: ENet fragments packets above ~1400 bytes automatically.
- Pros: battle-tested (Dome Keeper used it), lowest latency, simplest setup.
- Cons: players cannot host P2P sessions without a relay or port-forwarding.

Source: Ziva blog "Godot Multiplayer in 2026: What Actually Works" https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026); Godot docs networking section (2026-04-28)

#### WebRTC (P2P, browser-native NAT traversal)

- Uses DTLS over UDP; built-in ICE/STUN for NAT traversal. Each peer connects directly to others without a server after signaling.
- **Signaling is not included.** You need a separate signaling server (WebSocket-based) to exchange ICE candidates. Godot provides `WebRTCMultiplayerPeer` but you wire the signaling yourself.
- TURN relay fallback (for symmetric NAT) is not included — you provision a TURN server separately (e.g., Cloudflare TURN, Metered TURN).
- The `webrtc-native` GDExtension is the shipping path. Status as of 4.6.2: functional but considered the harder operational path for a dedicated-server game.
- Best fit: browser exports where ENet sockets are unavailable, or pure P2P games where you want to avoid a relay server.

Source: Godot docs WebRTC section https://docs.godotengine.org/en/4.6/tutorials/networking/ (2026-04-28)

#### WebSocket (TCP-based)

- Use when: exporting to Web (HTML5), or building a simple authoritative server where latency tolerance is high (turn-based, puzzle, lobby).
- `WebSocketMultiplayerPeer` drops in as a `MultiplayerPeer` replacement — the rest of the API is identical.
- Not suitable for a physics-driven platformer: TCP head-of-line blocking hurts latency noticeably vs ENet.

Source: Godot docs networking section (2026-04-28)

---

### 2.5 Authority / Server Modes

**Listen server** (one player hosts, also plays): Simplest to ship. The host has zero latency for themselves and unfair advantage in competitive play. For co-op this is acceptable and common. Godot supports this natively — the hosting peer runs both server and client logic in the same process.

**Dedicated server (headless export)**: Export with the `--headless` flag. Godot 4 supports headless server exports; the display server is disabled and no GPU is required. This is the right choice for a co-op game with a reliable server experience. Edgegap or any VPS can host a headless Godot binary.

Export with `--headless`; the display server is disabled and no GPU is required. Edgegap or any VPS can host a headless Godot binary.

**Pure P2P**: Possible via WebRTC but you still need a signaling server. The authority model gets messy — you need to designate one peer as "authority" for shared state. Not recommended for a physics-driven game.

Source: Godot docs + StraySpark authoritative server post https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server (~March 2026)

---

### 2.6 Known Gaps in 2026

These are things the built-in stack does **not** provide. You build them or use a third-party layer.

| Gap | Status in 4.6.2 | Notes |
|---|---|---|
| **Client-side prediction (CSP)** | Not built-in | Must implement input prediction + server reconciliation manually. `netfox` (GDScript, 937 stars) provides this. |
| **Rollback netcode** | Not built-in | `godot-rollback-netcode` by David Snopek (GitLab) exists; 2026 update status unclear — check directly. Mainly relevant for fighting/action games. |
| **Delta compression** | Not built-in | `MultiplayerSynchronizer` sends full property values, not diffs. For complex state this is wasteful. Must implement manually. |
| **Interest management** | Not built-in | All sync'd nodes replicate to all peers. No spatial partitioning or relevance filtering. Matters above ~8 players. |
| **NAT traversal** | Not built-in (ENet) | Must use relay (GD-Sync, GodotSteam, Edgegap) or WebRTC with external STUN/TURN. |
| **Lobby / matchmaking** | Not built-in | GD-Sync, GodotSteam/Steam, Epic Online Services (EOSG), or Nakama. |
| **~40 CCU ceiling** | Confirmed in 4.6 | Rivet engineering benchmarks and the Ziva Apr 2026 survey both cite ~40 simultaneous connections per server as the stability limit. Irrelevant at 2–8 players. |
| **Built-in relay** | Not built-in | Needs external relay for P2P or clients behind NAT. |

Godot proposals with `topic:network` label tracking these gaps: https://github.com/godotengine/godot-proposals/issues?q=is%3Aissue+label%3Atopic%3Anetwork (checked 2026-04-28 — no large CSP/rollback proposals accepted for 4.7 or 5.0; no major networking API changes in 4.7 beta 1).

Source: Ziva blog https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026); Godot proposals GitHub (2026-04-28); Godot 4.7 beta 1 thread https://forum.godotengine.org/t/dev-snapshot-godot-4-7-beta-1/137627 (2026-04-28)

---

### 2.7 For Our Project Specifically

Given `Player.gd` (`CharacterBody2D`), `Inventory.gd` + `Skills.gd` (autoloads), `World.gd` (room-swap), `CanvasLayer` HUD — here is what is load-bearing to understand before writing any multiplayer code.

#### Autoloads are singletons — they will diverge

`Inventory` and `Skills` are `extends Node` autoloads. They are **not** automatically replicated. Each peer has its own local instance. If Peer A picks up the dash ability, Peer B's `Inventory` is unaware unless you sync it explicitly.

Pattern to handle this:

```gdscript
# In Inventory.gd — broadcast grant to all peers
@rpc("authority", "call_local", "reliable")
func _rpc_grant(id: StringName) -> void:
    owned[id] = true
    ability_granted.emit(id)

func grant(id: StringName) -> void:
    if multiplayer.is_server():
        _rpc_grant.rpc(id)      # server broadcasts to all including self
```

**Skills** (active card selection) raises the same issue. If co-op means each player has independent inventory, this is easier — just never sync across peers. If shared inventory is the design, you must make every mutation go through a server-authoritative RPC path.

#### Room-swap must be server-driven

`World.gd`'s `_do_room_transition()` (triggered by door signals) frees the old room and loads the new one. In multiplayer:

- The server detects the door trigger and decides the new room.
- Clients must not swap rooms independently.
- Pattern: server calls `_swap_room.rpc(target_room_path)` on all clients. Clients pause physics, load the room, reposition player, ack back to server, server resumes.
- The player `_transitioning` guard in `World.gd` already exists for single-player timing — it needs to become a server-gated lock in multiplayer.
- `MultiplayerSpawner` handles spawning new players joining mid-session; it will not automatically handle room content (enemies, pickups) unless you put a spawner in each room scene.

#### The state machine in `_physics_process` and RPC latency

`Player.gd` reads `Input.*` directly in `_physics_process` and applies physics immediately. In a naive multiplayer setup:

- **Listen server, local player**: fine — zero latency, input is applied immediately.
- **Remote clients** (server simulating their movement): the server does not have their input. You must send input RPCs from clients to the server, and the server applies them. At 100ms RTT this produces ~5 frames of lag before the client sees a response.
- **Without CSP**: the client's player appears to rubber-band back to server position after each input. This is unacceptable for a platformer.

Minimum viable approach (no CSP, smooth enough for co-op with 2–4 players at low latency):

```gdscript
# Client-side: send input each frame (unreliable_ordered is fine for inputs)
@rpc("authority", "unreliable_ordered")
func _apply_remote_input(dir: float, jump: bool, dash: bool) -> void:
    # server applies input → drives move_and_slide → Synchronizer sends position back
    pass

# Client calls on its player node (authority = client peer):
_apply_remote_input.rpc_id(1, input_dir, jump_pressed, dash_pressed)
```

For anything competitive or latency-sensitive, `netfox` (https://github.com/foxssake/netfox, 937 stars, GDScript) is the GDScript-native CSP toolkit. It integrates with `CharacterBody2D` and handles rollback-style input replay.

#### HUD is local-only

`CanvasLayer` HUD reads `Inventory` and `Skills` signals. Since those autoloads are per-peer, HUD update logic is already correct per-peer as long as you sync the underlying autoload state properly. No changes to HUD rendering code are needed.

---

## 3. What You Get Free vs What You Must Build

| Capability | Built-in? | Notes |
|---|---|---|
| Reliable UDP transport (ENet) | **Free** | `ENetMultiplayerPeer` |
| WebSocket transport | **Free** | drop-in swap |
| WebRTC P2P (with NAT traversal) | **Free** (signaling not included) | GDExtension + your signaling server |
| Property replication | **Free** | `MultiplayerSynchronizer` |
| Scene spawning/despawning | **Free** | `MultiplayerSpawner` |
| RPC (reliable/unreliable) | **Free** | `@rpc` annotation |
| Authority gating | **Free (manual)** | `is_multiplayer_authority()` check |
| Headless server export | **Free** | `--headless` flag |
| Peer ID management | **Free** | auto-assigned, signal-driven |
| Client-side prediction | **Must build** | or use `netfox` |
| Rollback netcode | **Must build** | or use `godot-rollback-netcode` |
| Delta compression | **Must build** | hand-roll diff before RPC |
| Lobby / matchmaking | **Must build** | or GD-Sync / Steam / EOSG |
| NAT traversal (ENet) | **Must build** | relay server or GD-Sync/Steam |
| Interest management | **Must build** | manual visibility gating |
| Autoload state sync | **Must build** | RPCs on `Inventory` / `Skills` |
| Room-swap replication | **Must build** | server-driven RPC + client ack |

---

## 4. Verdict: Is Built-In Enough?

**For 2–4 player local-network or low-latency co-op: yes, built-in is sufficient as a foundation.** Dome Keeper shipped 8-player co-op with the built-in stack in April 2026 (GodotCon 2025 presentation by Bippinbits; Steam release Apr 13, 2026). At 2–8 players the 40-CCU ceiling is not a concern.

**The catch is CSP.** A physics-driven platformer is the most latency-sensitive genre for netcode. Without client-side prediction the remote player will visibly rubber-band at any RTT above ~50ms. For a co-op campaign played over the internet (not LAN), you should plan for `netfox` from the start rather than retrofitting it — its `RollbackSynchronizer` integrates directly with `CharacterBody2D` state and is GDScript-native.

**Recommended minimum stack:**

1. Built-in `ENetMultiplayerPeer` + `SceneMultiplayer` (transport + routing — free)
2. `MultiplayerSpawner` + `MultiplayerSynchronizer` for position/state replication (free)
3. `netfox` for CSP on `Player.gd` (open-source, GDScript — https://github.com/foxssake/netfox)
4. GD-Sync or GodotSteam for relay + lobby (relay solves the NAT problem; matchmaking solves discovery)
5. Hand-written RPCs on `Inventory.grant()` and `Skills` mutation paths

**Do not use WebRTC unless targeting web export.** The signaling + TURN operational overhead is not justified for a desktop game when ENet + relay is simpler.

Source: Ziva blog https://ziva.sh/blogs/godot-multiplayer (Apr 1, 2026); Godot docs https://docs.godotengine.org/en/4.6/tutorials/networking/ (2026-04-28); netfox GitHub https://github.com/foxssake/netfox (checked 2026-04-28); Dome Keeper Steam page (Apr 13, 2026 multiplayer update); GD-Sync v1.0 release https://godotengine.org/asset-library/asset/2347 (Apr 24, 2026)
