import "./openal_generated_bindings.dart";

abstract final class SourceState {
  /// The source is not playing, and it either not been played yet or it has been rewind, and in both cases the playback position is reset to 0.
  static const int initial = AL_INITIAL;

  /// The source is already playing.
  static const int playing = AL_PLAYING;

  /// The source is paused, so its playback position is saved and can also be 0, if it was paused before it was played.
  static const int paused = AL_PAUSED;

  /// The source has finished playing, or stop has been called on it.
  static const int stopped = AL_STOPPED;
}
