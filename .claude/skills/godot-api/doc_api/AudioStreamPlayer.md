## AudioStreamPlayer <- Node

The AudioStreamPlayer node plays an audio stream non-positionally. It is ideal for user interfaces, menus, or background music. To use this node, `stream` needs to be set to a valid AudioStream resource. Playing more than one sound at the same time is also supported, see `max_polyphony`. If you need to play audio at a specific position, use AudioStreamPlayer2D or AudioStreamPlayer3D instead.

**Props:**
- autoplay: bool = false
- bus: StringName = &"Master"
- max_polyphony: int = 1
- mix_target: int (AudioStreamPlayer.MixTarget) = 0
- pitch_scale: float = 1.0
- playback_type: int (AudioServer.PlaybackType) = 0
- playing: bool = false
- stream: AudioStream
- stream_paused: bool = false
- volume_db: float = 0.0
- volume_linear: float

**Methods:**
- get_playback_position() -> float - Returns the position in the AudioStream of the latest sound, in seconds.
- get_stream_playback() -> AudioStreamPlayback - Returns the latest AudioStreamPlayback of this node, usually the most recently created by `play`.
- has_stream_playback() -> bool - Returns `true` if any sound is active, even if `stream_paused` is set to `true`.
- play(from_position: float = 0.0) - Plays a sound from the beginning, or the given `from_position` in seconds.
- seek(to_position: float) - Restarts all sounds to be played from the given `to_position`, in seconds.
- stop() - Stops all sounds from this node.

**Signals:**
- finished

**Enums:**
**MixTarget:** MIX_TARGET_STEREO=0, MIX_TARGET_SURROUND=1, MIX_TARGET_CENTER=2

