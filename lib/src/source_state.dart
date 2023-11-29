import "./openal_generated_bindings.dart";

abstract final class SourceState {
  static const int initial = AL_INITIAL;
  static const int playing = AL_PLAYING;
  static const int paused = AL_PAUSED;
  static const int stopped = AL_STOPPED;
}
