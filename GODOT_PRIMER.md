# Godot Primer — for Unreal / Unity developers

**Audience:** developers coming from **Unreal** or **Unity** who want to read this codebase without stalling on unfamiliar Godot syntax. Read top-to-bottom once, then skim back for anything specific.

This is *only* a translation primer — Godot constructs that appear in this project, mapped to their Unreal / Unity equivalents. It is not a Godot reference (use the [official docs](https://docs.godotengine.org/en/stable/) for that), not a project-architecture doc (use [`STRUCTURE.md`](STRUCTURE.md)), and not a list of common engine traps (those live in the auto-memory feedback files for Claude sessions; if you're a human and want them, search the issue tracker on the Godot repo).

---

## Quick analogy table

| Godot | Unreal | Unity |
|---|---|---|
| Scene (`.tscn`) | Blueprint asset / Level | Prefab / Scene |
| Node | Actor / Component | GameObject / Component |
| Script (`.gd`) | Blueprint or C++ class | MonoBehaviour |
| Signal | Event Dispatcher / Multicast Delegate | UnityEvent / C# event |
| Group | Actor Tag | Tag |
| `@export` | `UPROPERTY(EditAnywhere)` | `[SerializeField]` |
| `_ready()` | `BeginPlay()` | `Start()` |
| `_process(delta)` | `Tick(DeltaTime)` | `Update()` |
| `_physics_process(delta)` | `Tick` w/ "Tick on Physics" | `FixedUpdate()` |
| `_input(event)` | `InputComponent` action mapping | `Update` polling `Input.*` |
| Resource (`.tres`) | DataAsset | ScriptableObject |
| `PackedScene` | `TSubclassOf<AActor>` (template to spawn) | Prefab reference |
| `Node2D` | 2D Actor | 2D GameObject (Transform) |
| `CharacterBody2D` | `Character` (with movement component) | `CharacterController` (2D rigidbody pattern) |
| `Area2D` | `TriggerVolume` / overlap-only collider | Trigger `Collider2D` |
| `StaticBody2D` | static collision Actor | static `Collider2D` (kinematic rigidbody) |
| `Tween` | Timeline | DOTween / coroutine + lerp |
| Autoload (singleton scene) | `GameInstance` / `GameMode` singletons | `DontDestroyOnLoad` singleton |
| Editor / Game split | Editor module vs runtime module | EditMode vs PlayMode |

---

## Scenes and nodes

A **scene** is a tree of **nodes** saved as a `.tscn` file. Every node has a name, a type (built-in like `Node2D`, `Camera2D`, or a custom script-defined `class_name`), a parent, and children.

```gdscript
# A typical scene root, declared by attaching this script:
extends CharacterBody2D       # the root node IS-A CharacterBody2D
class_name Player             # name this class so other code can refer to "Player"
```

- **Unreal**: `extends X` ≈ inheriting from `AActor`/`UActorComponent`. `class_name` ≈ the class name in `UCLASS()`.
- **Unity**: `extends MonoBehaviour` is implicit in C#; `class_name` ≈ just having `class Player : MonoBehaviour`.

Scenes can be **instantiated**: another scene loads a `.tscn` as a `PackedScene` and calls `.instantiate()` to spawn a copy. That's how doors load their target room in this codebase:

```gdscript
var packed: PackedScene = load("res://rooms/SecondRoom.tscn")
var instance: Node = packed.instantiate()
add_child(instance)
```

- **Unreal**: `World->SpawnActor<ARoom>(RoomClass)` with a `TSubclassOf<ARoom>`.
- **Unity**: `Instantiate(prefab)`.

`res://` is Godot's project-root prefix (like Unreal's `/Game/...` or Unity's `Assets/...`).

---

## Lifecycle methods

Override these `_`-prefixed callbacks; Godot calls them automatically.

| Callback | When | Unreal | Unity |
|---|---|---|---|
| `_ready()` | once, after node + all children enter the tree | `BeginPlay()` | `Start()` |
| `_enter_tree()` | when the node is added to the active tree (before children are ready) | `OnConstruction` / `PostInitializeComponents` | `Awake()` |
| `_exit_tree()` | when the node is removed from the tree | `EndPlay()` | `OnDestroy()` |
| `_process(delta)` | every rendered frame | `Tick(DeltaTime)` (default) | `Update()` |
| `_physics_process(delta)` | every physics tick (60 Hz default) | `Tick` w/ physics tick group | `FixedUpdate()` |
| `_input(event)` | per input event | `InputComponent` bindings | `Update` polling |
| `_draw()` | when the node redraws itself (`queue_redraw()` to request) | `OnPaint` (UMG) | `OnGUI` / `OnDrawGizmos` |

Use `_physics_process` for anything that calls `move_and_slide()` or reads physics state — Godot guarantees a fixed timestep there. The player controller and camera both run in `_physics_process` for that reason.

---

## Variables, types, and `@export`

GDScript is dynamically typed but supports type hints:

```gdscript
var speed: float = 220.0           # typed
var counter = 0                    # untyped; inferred Variant
var things: Array[Node] = []       # typed array
const COYOTE: float = 0.15         # compile-time constant
```

`@export` exposes a variable in the **Inspector** so you can edit it on a node instance without touching the script:

```gdscript
@export var smoothing_speed: float = 8.0
@export var bounds: Rect2 = Rect2(0, 0, 960, 540)
@export var target_room_path: String = ""
@export_file("*.tscn") var room_path: String   # file picker filtered to .tscn
```

- **Unreal**: `UPROPERTY(EditAnywhere, BlueprintReadWrite)`.
- **Unity**: `[SerializeField]` (or just `public`).

`@onready` defers a `var`'s initializer until `_ready()` runs — needed when initializing from a child node that isn't ready yet at parse time:

```gdscript
@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _camera: GameCamera = $GameCamera
```

`$NodeName` is shorthand for `get_node("NodeName")` — a path lookup relative to `self`. `$Rig/LandDust` is a child path.

---

## Signals

Signals are Godot's pub/sub primitive. Define on a class, emit, connect.

```gdscript
# In Door.gd:
signal player_entered(door: Door, player: Node2D)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_entered.emit(self, body)
```

```gdscript
# In World.gd:
door.player_entered.connect(_on_door_entered)

func _on_door_entered(door: Door, player: Node2D) -> void:
    ...
```

- **Unreal**: signal ≈ Multicast Delegate / Event Dispatcher. `connect` ≈ `AddDynamic`. `emit` ≈ `Broadcast`.
- **Unity**: signal ≈ `UnityEvent` or C# `event`. `connect` ≈ `+= handler`. `emit` ≈ `Invoke()`.

Built-in nodes also emit signals — `Area2D` emits `body_entered` when a `CharacterBody2D` overlaps it; that's how Door triggers fire.

`signal.is_connected(handler)` lets you check before connecting again — useful when rooms are repeatedly entered/left.

---

## Groups (tags)

Add a node to a named group; later, anyone can query the tree for all members:

```gdscript
add_to_group("player")           # in player scene's _ready or scene file
get_tree().get_first_node_in_group("player")
get_tree().get_nodes_in_group("camera")
```

- **Unreal**: `Tags` array on `AActor` + `UGameplayStatics::GetAllActorsWithTag`. Groups are a faster lookup since Godot indexes them.
- **Unity**: `tag` string + `GameObject.FindGameObjectsWithTag`. Same idea.

This codebase uses two groups: `"player"` (so the camera can find the player) and `"camera"` (so the player can push shake events). See [`STRUCTURE.md`](STRUCTURE.md).

---

## Physics — `CharacterBody2D`, `Area2D`, `StaticBody2D`

| Body type | Use for | Unreal | Unity |
|---|---|---|---|
| `CharacterBody2D` | player/NPCs that move via code | `Character` + `CharacterMovementComponent` | `Rigidbody2D.Kinematic` + custom controller (or `CharacterController`) |
| `StaticBody2D` | walls, platforms that don't move | static `AStaticMeshActor` w/ collision | `Collider2D` w/o Rigidbody |
| `RigidBody2D` (not used here) | physics-driven (bouncing crate) | `APhysicsActor` w/ simulate physics | `Rigidbody2D` |
| `Area2D` | overlap triggers, no collision response | `UTriggerVolume` | trigger `Collider2D` |

**`CharacterBody2D` workflow** (player.gd):

```gdscript
extends CharacterBody2D

func _physics_process(delta: float) -> void:
    velocity.y += GRAVITY * delta              # set the velocity vector
    velocity.x = move_toward(velocity.x, 0, decel * delta)
    move_and_slide()                           # built-in: applies velocity, resolves collisions
    if is_on_floor():                          # post-move helper
        ...
```

`move_and_slide()` is the rough equivalent of Unity's `CharacterController.Move()` or building velocity-based movement on a kinematic Rigidbody2D. It updates `velocity` if you slide along a wall, and exposes `is_on_floor()`, `is_on_wall()`, `is_on_ceiling()` afterwards.

`get_slide_collision(i)` returns each collision the move resolved against — used in `_get_wall_direction()` to read which side a wall is on.

**Area2D**: `body_entered(body)` and `body_exited(body)` signals fire when a physics body overlaps. The `Door` node uses this.

---

## Input

Input bindings live in **Project Settings → Input Map** (saved into `project.godot`). Each binding is an "action" name like `"jump"` or `"move_left"`.

```gdscript
if Input.is_action_just_pressed("jump"): ...
if Input.is_action_pressed("jump"): ...      # held down
if Input.is_action_just_released("jump"): ...
var dir: float = Input.get_axis("move_left", "move_right")  # -1 / 0 / +1
```

- **Unreal**: actions ≈ Input Actions (Enhanced Input). `is_action_just_pressed` ≈ `IA_Triggered` once. `get_axis` ≈ axis input value.
- **Unity**: actions ≈ Input System actions. `Input.GetAxis` and `Input.GetButtonDown` are the legacy direct equivalents.

---

## Animation — `AnimationPlayer`

Godot's primary animation tool. It animates **any** property of any node — position, scale, modulate (tint), shader uniforms, even calling functions on a track. The player rig uses one `AnimationPlayer` to drive all limb transforms across `idle`, `run`, `jump`, `fall`, `wall_slide`, `land`.

```gdscript
@onready var _anim: AnimationPlayer = $AnimationPlayer
_anim.play("run")
_anim.speed_scale = 1.5            # play 1.5× speed
if _anim.is_playing(): ...
```

- **Unreal**: closer to `Sequencer` for a single Actor than to AnimBlueprint. AnimBlueprints (state machines + blendspaces) map to Godot's `AnimationTree`, which we don't use here.
- **Unity**: ≈ `Animation` (legacy, single-clip). Unity's `Animator` (state machine) maps to Godot's `AnimationTree`.

The state→animation mapping in this project is hand-rolled in `_update_animation()` rather than using `AnimationTree`. Simpler and more legible for a small set of states.

---

## Resources and `PackedScene`

A **Resource** is reference-counted serializable data — anything saveable to a `.tres` file (themes, materials, Rect2 templates, custom data containers).

A **PackedScene** is a `Resource` representing a `.tscn` file — a "frozen" scene tree you can stamp out copies of:

```gdscript
@export var target_room_path: String     # set in inspector
var packed: PackedScene = load(target_room_path)
var instance: Node = packed.instantiate()
add_child(instance)
```

- **Unreal**: a Resource ≈ `UDataAsset` / `UAsset` in general. A `PackedScene` ≈ `TSubclassOf<AActor>` template.
- **Unity**: a Resource ≈ `ScriptableObject`. A `PackedScene` ≈ a Prefab reference.

`load()` is synchronous; `preload()` is parse-time and shows up as a constant. Both return the same kind of resource.

---

## Tweens

Tweens animate property values over time. In `World.gd`, the door transition uses one to slide both the player and the camera in parallel:

```gdscript
var tween := create_tween()
tween.set_parallel(true)
tween.set_trans(Tween.TRANS_SINE)
tween.set_ease(Tween.EASE_IN_OUT)
tween.tween_property(player, "global_position", spawn_pos, 0.5)
tween.tween_property(_camera, "global_position", camera_target, 0.5)
await tween.finished        # suspend until done
```

- **Unreal**: ≈ `Timeline` node, or `MoveComponentTo` async. `set_trans` chooses the curve (sine, cubic, expo).
- **Unity**: ≈ `DOTween` chained tweens, or coroutine + `Mathf.SmoothStep` lerp.

`await` is GDScript's coroutine-suspend keyword — pairs with any signal or method that returns one.

---

## Editor vs runtime — `@tool` and `Engine.is_editor_hint()`

Scripts run in the **editor** if marked `@tool`. This lets you draw debug overlays, validate properties, or react to inspector edits — but the same script also runs in the game.

Used here for:
- `Room.gd` — draws the `bounds` rect in the editor so designers can see a room's camera-clamp area
- `Door.gd` — draws a small arrow in `direction` so the layout is readable

```gdscript
@tool
extends Node2D

func _draw() -> void:
    if not Engine.is_editor_hint():
        return                       # don't draw at runtime
    draw_rect(bounds, color, false, 2.0)
```

- **Unreal**: ≈ `Editor-only Construction Script` / `EditorUtilityWidget`.
- **Unity**: ≈ `[ExecuteInEditMode]` / `OnDrawGizmos`.

---

For where each of these constructs actually lives in this project's code, see [`STRUCTURE.md`](STRUCTURE.md) — it's the per-file responsibility map and the runtime scene tree.
