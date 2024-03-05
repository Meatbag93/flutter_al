import "./openal_generated_bindings.dart";

///     When spatialization features are applied on a [Source] playing a non-mono
///[Buffer], if the [Source] occupies the same 3D position as the [Listener] the
///buffer's channels are placed around the [Listener] according to the format
///(e.g. a stereo buffer has the left channel 30 degrees left of front, and
///the right channel 30 degrees right of front). This panning is NOT effected
///by the source direction or listener orientation.
///
///If the source does not occupy the same 3D position as the listener, the
///proper panning direction is calculated and all channels of the buffer will
///be panned to that direction (effectively down-mixing the buffer to mono
///dynamically). The buffer's channels will also receive a gain correction of
///1/num_channels when panned, to preserve peak amplitude of the mixed
///channels. An exception is the LFE channel in buffer formats that include
///one. The LFE channel may be sent to the LFE output as normal and not be
///part of the panned mix, however it is still attenuated according to the
///source distance and cone.
abstract final class SourceSpatialize {
  /// spatialization is never applied to the source.
  static const int FALSE = AL_FALSE;

  /// spatialization is always  applied regardless of source type.
  static const int TRUE = AL_TRUE;

  /// spatialization is only applied if playing a
  /// buffer with one channel, and not if the buffer has more than one channel. This is the default.
  static const int AUTO = AL_AUTO_SOFT;
}
