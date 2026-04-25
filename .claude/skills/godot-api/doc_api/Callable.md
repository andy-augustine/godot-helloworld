## Callable

Callable is a built-in Variant type that represents a function. It can either be a method within an Object instance, or a custom callable used for different purposes (see `is_custom`). Like all Variant types, it can be stored in variables and passed to other functions. It is most commonly used for signal callbacks. In GDScript, it's possible to create lambda functions within a method. Lambda functions are custom callables that are not associated with an Object instance. Optionally, lambda functions can also be named. The name will be displayed in the debugger, or when calling `get_method`. In GDScript, you can access methods and global functions as Callables: **Note:** Dictionary does not support the above due to ambiguity with keys. **Note:** In a boolean context, a callable will evaluate to `false` if it's null (see `is_null`). Otherwise, a callable will always evaluate to `true`.

**Methods:**
- bind() -> Callable - Returns a copy of this Callable with one or more arguments bound.
- bindv(arguments: Array) -> Callable - Returns a copy of this Callable with one or more arguments bound, reading them from an array.
- call() -> Variant - Calls the method represented by this Callable.
- call_deferred() - Calls the method represented by this Callable in deferred mode, i.
- callv(arguments: Array) -> Variant - Calls the method represented by this Callable.
- create(variant: Variant, method: StringName) -> Callable - Creates a new Callable for the method named `method` in the specified `variant`.
- get_argument_count() -> int - Returns the total number of arguments this Callable should take, including optional arguments.
- get_bound_arguments() -> Array - Returns the array of arguments bound via successive `bind` or `unbind` calls.
- get_bound_arguments_count() -> int - Returns the total amount of arguments bound via successive `bind` or `unbind` calls.
- get_method() -> StringName - Returns the name of the method represented by this Callable.
- get_object() -> Object - Returns the object on which this Callable is called.
- get_object_id() -> int - Returns the ID of this Callable's object (see `Object.
- get_unbound_arguments_count() -> int - Returns the total amount of arguments unbound via successive `bind` or `unbind` calls.
- hash() -> int - Returns the 32-bit hash value of this Callable's object.
- is_custom() -> bool - Returns `true` if this Callable is a custom callable.
- is_null() -> bool - Returns `true` if this Callable has no target to call the method on.
- is_standard() -> bool - Returns `true` if this Callable is a standard callable.
- is_valid() -> bool - Returns `true` if the callable's object exists and has a valid method name assigned, or is a custom callable.
- rpc() - Perform an RPC (Remote Procedure Call) on all connected peers.
- rpc_id(peer_id: int) - Perform an RPC (Remote Procedure Call) on a specific peer ID (see multiplayer documentation for reference).
- unbind(argcount: int) -> Callable - Returns a copy of this Callable with a number of arguments unbound.

