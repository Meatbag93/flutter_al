import "dart:ffi";
import "dart:math";
import "package:ffi/ffi.dart";
import "./disposable.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./context.dart";
import "./buffer.dart";
import "./source_state.dart";

/// Represents an OpenAL source.
///
/// The [Source] class manages the
/// position, volume, and playback of audio in 3D space.
///
/// [Source] must not be instantiated directly. Instead see [Context.generateSources]
final class Source extends Disposable {
  late final Context _context;
  late final Pointer<ALuint> _idPointer;
  late final Map<int, Buffer> _queuedBuffers;

  /// @nodoc
  Source(this._context, int id) : _queuedBuffers = {} {
    _idPointer = calloc<ALuint>()..value = id;
  }

  /// @nodoc
  int get id => _idPointer.value;
  @pragma("vm:prefer-inline")
  int _getIntProperty(int property) => using<int>((allocate) {
        ensureNotDisposed();
        Pointer<ALint> value = allocate<ALint>();
        bindings.alGetSourcei(id, property, value);
        return value.value;
      });
  @pragma("vm:prefer-inline")
  void _setIntProperty(int property, int value) {
    ensureNotDisposed();
    bindings.alSourcei(id, property, value);
  }

  @pragma("vm:prefer-inline")
  bool _getBoolProperty(int property) =>
      (_getIntProperty(property) == AL_FALSE ? false : true);
  @pragma("vm:prefer-inline")
  void _setBoolProperty(int property, bool value) =>
      _setIntProperty(property, (value ? AL_TRUE : AL_FALSE));
  @pragma("vm:prefer-inline")
  double _getFloatProperty(int property) => using<double>((allocate) {
        ensureNotDisposed();
        Pointer<ALfloat> value = allocate<ALfloat>();
        bindings.alGetSourcef(id, property, value);
        return value.value;
      });
  @pragma("vm:prefer-inline")
  void _setFloatProperty(int property, double value) {
    ensureNotDisposed();
    bindings.alSourcef(id, property, value);
  }

  @pragma("vm:prefer-inline")
  List<double> _getVector3Property(int property) =>
      using<List<double>>((allocate) {
        ensureNotDisposed();
        Pointer<ALfloat> value = allocate<ALfloat>(3);
        bindings.alGetSource3f(id, property, value.elementAt(0),
            value.elementAt(1), value.elementAt(2));
        return [value[0], value[1], value[2]];
      });
  @pragma("vm:prefer-inline")
  void _setVector3Property(int property, List<double> value) {
    ensureNotDisposed();
    if (value.isEmpty || value.length != 3) {
      throw ArgumentError("value must be a list of exactly 3 doubles");
    }
    bindings.alSource3f(id, property, value[0], value[1], value[2]);
  }

  /// Plays [this].
  ///
  /// Will change the state to [SourceState.playing]. When called on a [Source] which is already playing, the [Source] will restart at the beginning. When the attached [Buffer] (s) are done playing, the source will progress to the [SourceState.stopped] state.
  void play() {
    ensureNotDisposed();
    bindings.alSourcePlay(id);
  }

  /// Stops [this].
  ///
  /// Will change the state to [SourceState.stopped]
  void stop() {
    ensureNotDisposed();
    bindings.alSourceStop(id);
  }

  /// Stops [this] and sets state to [SourceState.initial].
  void rewind() {
    ensureNotDisposed();
    bindings.alSourceRewind(id);
  }

  /// Pauses [this]
  ///
  /// Will change state to [SourceState.paused].
  void pause() {
    ensureNotDisposed();
    bindings.alSourcePause(id);
  }

  /// The amount of buffers in the queue that have been processed
  int get processedBuffers => _getIntProperty(AL_BUFFERS_PROCESSED);

  /// Queues a set of [Buffer]s on [this]. All [Buffer]s attached to [this] will be played in sequence, and the number of processed buffers can be detected using [processedBuffers].
  void queueBuffers(List<Buffer> buffers) {
    ensureNotDisposed();
    if (buffers.isEmpty) {
      throw ArgumentError("buffers list is empty");
    }
    using((alocate) {
      int length = buffers.length;
      Pointer<ALuint> cBuffers = alocate<ALuint>(buffers.length);
      for (int i = 0; i < length; i++) {
        cBuffers[i] = buffers[i].id;
      }
      bindings.alSourceQueueBuffers(id, length, cBuffers);
      for (Buffer buffer in buffers) {
        _queuedBuffers[buffer.id] = buffer;
      }
    });
  }

  /// unqueues and returns [count] of buffers attached to [this].
  ///
  /// If [count] is null, unqueues all processed buffers.
  ///
  /// If [count] is less than the amount of processed buffers, unqueues and returns only the first [processedBuffers] items.
  ///
  /// Returns an empty list if [count] or [processedBuffers] is 0
  List<Buffer> unqueueBuffers(int? count) {
    ensureNotDisposed();
    List<Buffer> result = [];
    int length = min(count ?? processedBuffers, processedBuffers);
    if (length > 0) {
      using<void>((alocate) {
        Pointer<ALuint> cUnqueuedBuffers = alocate<ALuint>(length);
        bindings.alSourceUnqueueBuffers(id, length, cUnqueuedBuffers);
        for (int i = 0; i < length; i++) {
          int id = cUnqueuedBuffers[i];
          Buffer? buffer = _queuedBuffers.remove(id);
          if (buffer != null) {
            result.add(buffer);
          }
        }
      });
    }
    return result;
  }

  /// Whether the positions are relative to the listener. Defaults to false
  bool get relative => _getBoolProperty(AL_SOURCE_RELATIVE);
  set relative(bool value) => _setBoolProperty(AL_SOURCE_RELATIVE, value);

  /// The gain when inside the oriented cone
  double get coneInnerAngle => _getFloatProperty(AL_CONE_INNER_ANGLE);
  set coneInnerAngle(double value) =>
      _setFloatProperty(AL_CONE_INNER_ANGLE, value);

  /// Outer angle of the sound cone, in degrees. Default is 360
  double get coneOuterAngle => _getFloatProperty(AL_CONE_OUTER_ANGLE);
  set coneOuterAngle(double value) =>
      _setFloatProperty(AL_CONE_OUTER_ANGLE, value);

  /// Pitch multiplier. Always positive
  double get pitch => _getFloatProperty(AL_PITCH);
  set pitch(double value) => _setFloatProperty(AL_PITCH, value);

  /// X, Y, Z position
  List<double> get position => _getVector3Property(AL_POSITION);
  set position(List<double> value) => _setVector3Property(AL_POSITION, value);

  /// The direction vector
  List<double> get direction => _getVector3Property(AL_DIRECTION);
  set direction(List<double> value) => _setVector3Property(AL_DIRECTION, value);

  /// The Velocity vector.
  List<double> get velocity => _getVector3Property(AL_VELOCITY);
  set velocity(List<double> value) => _setVector3Property(AL_VELOCITY, value);

  /// Whether [this] loops when it ends.
  bool get looping => _getBoolProperty(AL_LOOPING);
  set looping(bool value) => _setBoolProperty(AL_LOOPING, value);

  /// Source gain. Value should be positive.
  double get gain => _getFloatProperty(AL_GAIN);
  set gain(double value) => _setFloatProperty(AL_GAIN, value);

  /// The minimum gain for [this]
  double get minGain => _getFloatProperty(AL_MIN_GAIN);
  set minGain(double value) => _setFloatProperty(AL_MIN_GAIN, value);

  /// The maximum gain for [this]
  double get maxGain => _getFloatProperty(AL_MAX_GAIN);
  set maxGain(double value) => _setFloatProperty(AL_MAX_GAIN, value);

  /// The state of [this]. Whether it's played, paused, stopped, etc. Check [SourceState]
  int get state => _getIntProperty(AL_SOURCE_STATE);

  /// The distance under which the volume for [this] would normally drop by half (before being influenced by [rolloffFactor] or [maxDistance])
  double get referenceDistance => _getFloatProperty(AL_REFERENCE_DISTANCE);
  set referenceDistance(double value) =>
      _setFloatProperty(AL_REFERENCE_DISTANCE, value);

  /// The rolloff rate for [this]. Default is 1.0
  double get rolloffFactor => _getFloatProperty(AL_ROLLOFF_FACTOR);
  set rolloffFactor(double value) =>
      _setFloatProperty(AL_ROLLOFF_FACTOR, value);

  /// The gain when outside the oriented cone
  double get coneOuterGain => _getFloatProperty(AL_CONE_OUTER_GAIN);
  set coneOuterGain(double value) =>
      _setFloatProperty(AL_CONE_OUTER_GAIN, value);

  /// Used with the Inverse Clamped Distance Model to set the distance where there will no longer be any attenuation of [this]
  double get maxDistance => _getFloatProperty(AL_MAX_DISTANCE);
  set maxDistance(double value) => _setFloatProperty(AL_MAX_DISTANCE, value);

  @override
  void dispose() {
    super.dispose();
    try {
      _context.whileCurrent(() {
        bindings.alDeleteSources(1, _idPointer);
      });
    } finally {
      calloc.free(_idPointer);
    }
  }

  @override
  int get hashCode => _idPointer.value;
  @override
  bool operator ==(Object other) {
    if (other is! Buffer) return false;
    return other.hashCode == hashCode;
  }
}
