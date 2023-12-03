import "./openal_generated_bindings.dart";

abstract final class BufferFormat {
  /// Mono, 8-bit PCM.
  static const int mono8 = AL_FORMAT_MONO8;

  /// Mono, 16-bit PCM.
  static const int mono16 = AL_FORMAT_MONO16;

  /// Stereo, 8-bit PCM.
  static const int stereo8 = AL_FORMAT_STEREO8;

  /// Stereo, 16-bit PCM.
  static const int stereo16 = AL_FORMAT_STEREO16;
}
