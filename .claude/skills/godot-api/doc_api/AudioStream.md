## AudioStream <- Resource

Base class for audio streams. Audio streams are used for sound effects and music playback, and support WAV (via AudioStreamWAV), Ogg (via AudioStreamOggVorbis), and MP3 (via AudioStreamMP3) file formats.

**Methods:**
- can_be_sampled() -> bool - Returns if the current AudioStream can be used as a sample.
- generate_sample() -> AudioSample - Generates an AudioSample based on the current stream.
- get_length() -> float - Returns the length of the audio stream in seconds.
- instantiate_playback() -> AudioStreamPlayback - Returns a newly created AudioStreamPlayback intended to play this audio stream.
- is_meta_stream() -> bool - Returns `true` if the stream is a collection of other streams, `false` otherwise.
- is_monophonic() -> bool - Returns `true` if this audio stream only supports one channel (*monophony*), or `false` if the audio stream supports two or more channels (*polyphony*).

**Signals:**
- parameter_list_changed

