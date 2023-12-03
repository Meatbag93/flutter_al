import "dart:ffi";
import "package:ffi/ffi.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
// TODO: less code (There's a lot of duplication here that  we should be able to remove)

/// A handle to the current context's listener
///
/// You must ensure a context is set as current before using methods here.
final class Listener {
  @pragma("vm:prefer-inline")
  static void _ensureAContextIsCurrent() {
    if (bindings.alcGetCurrentContext() == nullptr) {
      throw StateError("A context must be set current first.");
    }
  }

  @pragma("vm:prefer-inline")
  static double _getFloatProperty(int property) => using<double>((allocate) {
        _ensureAContextIsCurrent();
        Pointer<ALfloat> value = allocate<ALfloat>();
        bindings.alGetListenerf(property, value);
        return value.value;
      });
  @pragma("vm:prefer-inline")
  static void _setFloatProperty(int property, double value) {
    _ensureAContextIsCurrent();
    bindings.alListenerf(property, value);
  }

  @pragma("vm:prefer-inline")
  static List<double> _getVector3Property(int property) =>
      using<List<double>>((allocate) {
        _ensureAContextIsCurrent();
        Pointer<ALfloat> value = allocate<ALfloat>(3);
        bindings.alGetListener3f(property, value.elementAt(0),
            value.elementAt(1), value.elementAt(2));
        return [value[0], value[1], value[2]];
      });
  @pragma("vm:prefer-inline")
  static void _setVector3Property(int property, List<double> value) {
    _ensureAContextIsCurrent();
    if (value.isEmpty || value.length != 3) {
      throw ArgumentError("value must be a list of exactly 3 doubles");
    }
    bindings.alListener3f(property, value[0], value[1], value[2]);
  }

  @pragma("vm:prefer-inline")
  static List<double> _getVector6Property(int property) =>
      using<List<double>>((allocate) {
        _ensureAContextIsCurrent();
        Pointer<ALfloat> value = allocate<ALfloat>(6);
        bindings.alGetListenerfv(property, value);
        return [value[0], value[1], value[2], value[3], value[4], value[5]];
      });
  @pragma("vm:prefer-inline")
  static void _setVector6Property(int property, List<double> value) {
    _ensureAContextIsCurrent();
    if (value.isEmpty || value.length != 6) {
      throw ArgumentError("value must be a list of exactly 6 doubles");
    }
    Pointer<ALfloat> values = calloc<ALfloat>(6);
    try {
      for (int i = 0; i < 6; i++) {
        values[i] = value[i];
      }
      bindings.alListenerfv(property, values);
    } finally {
      calloc.free(values);
    }
  }

  static List<double> get position => _getVector3Property(AL_POSITION);
  static set position(List<double> value) =>
      _setVector3Property(AL_POSITION, value);
  static List<double> get velocity => _getVector3Property(AL_VELOCITY);
  static set velocity(List<double> value) =>
      _setVector3Property(AL_VELOCITY, value);
  static List<double> get orientation => _getVector6Property(AL_ORIENTATION);
  static set orientation(List<double> value) =>
      _setVector6Property(AL_ORIENTATION, value);
  static double get gain => _getFloatProperty(AL_GAIN);
  static set gain(double value) => _setFloatProperty(AL_GAIN, value);
}
