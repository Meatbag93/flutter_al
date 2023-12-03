import "dart:ffi";
import "package:ffi/ffi.dart";
import "./disposable.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./device.dart";
import "./source.dart";
import "./buffer.dart";

/// A context
final class Context extends Disposable {
  late final Device device;
  late final Pointer<ALCcontext> _context;
  late Map<String, int> _attributes;

  /// Create a context from a device
  ///
  /// You can optionally pass in a map of attribute names to values
  Context(this.device, {Map<String, int> attributes = const {}})
      : _attributes = attributes {
    Pointer<ALCint>? cAttributes = _makeContextAttributes(_attributes);
    _context =
        bindings.alcCreateContext(device.devicePointer, cAttributes ?? nullptr);
    if (cAttributes != null) {
      calloc.free(cAttributes);
    }
    if (_context == nullptr) {
      throw StateError("Couldn't create Context");
    }
  }

  Pointer<ALCint>? _makeContextAttributes(Map<String, int> attributes) {
    Pointer<ALCint>? cAttributes;
    if (attributes.isNotEmpty) {
      List<int> attributeList = _getAttributeList(device, attributes);
      cAttributes = calloc<ALCint>(attributeList.length);
      for (int i = 0; i < attributeList.length; i++) {
        cAttributes[i] = attributeList[i];
      }
    }
    return cAttributes;
  }

  /// Resets the device associated with this context.
  ///
  /// if [attributes] is null, uses the same attributes as this context
  void resetDevice({Map<String, int>? attributes}) {
    _attributes = attributes ?? _attributes;
    Pointer<ALCint>? cAttributes = _makeContextAttributes(_attributes);
    bindings.alcResetDeviceSOFT(device.devicePointer, cAttributes ?? nullptr);
    if (cAttributes != null) {
      calloc.free(cAttributes);
    }
  }

  /// Generates [count] buffers.
  List<Buffer> generateBuffers(int count) {
    if (count <= 0) return [];
    List<Buffer> result = [];
    Pointer<ALuint> ids = calloc<ALuint>(count);
    try {
      bindings.alGenBuffers(count, ids);
      for (int i = 0; i < count; i++) {
        result.add(Buffer(this, ids[i]));
      }
      return result;
    } finally {
      calloc.free(ids);
    }
  }

  /// Generates [count] sources
  List<Source> generateSources(int count) {
    if (count <= 0) return [];
    List<Source> result = [];
    Pointer<ALuint> ids = calloc<ALuint>(count);
    try {
      bindings.alGenSources(count, ids);
      for (int i = 0; i < count; i++) {
        result.add(Source(this, ids[i]));
      }
      return result;
    } finally {
      calloc.free(ids);
    }
  }

  /// Sets [this] as the current context while [callback] is running.
  ///
  /// [callback] cannot be an async function.
  void whileCurrent(void Function() callback) {
    ensureNotDisposed();
    Pointer<ALCcontext> previousContext = bindings.alcGetCurrentContext();
    try {
      makeCurrent();
      callback();
    } finally {
      bindings.alcMakeContextCurrent(previousContext);
    }
  }

  /// Must not be used by users.
  Pointer<ALCcontext> get contextPointer {
    ensureNotDisposed();
    return _context;
  }

  /// make [this] the current context
  ///
  /// Will throw [StateError] if the operation fails
  void makeCurrent() {
    ensureNotDisposed();
    int result = bindings.alcMakeContextCurrent(_context);
    if (result == ALC_FALSE) {
      throw StateError("Couldn't make context current");
    }
  }

  /// Destroys [this] context.
  ///
  /// does not destroy the device asociated with [this].
  ///
  /// All sources related to [this] will be destroied, and you must not call dispose on them nor use them after this operation.
  @override
  void dispose() {
    super.dispose();
    if (isCurrent) {
      bindings.alcMakeContextCurrent(nullptr);
    }
    bindings.alcDestroyContext(_context);
  }

  /// Whether [this] is the current context
  bool get isCurrent => bindings.alcGetCurrentContext() == _context;

  /// Returns a dart list for an OpenAL representation of the context attributes given to initialize a context
  static List<int> _getAttributeList(
      Device device, Map<String, int> attributesMap) {
    List<int> attributes = [];
    for (var entry in attributesMap.entries) {
      String key = entry.key;
      int value = entry.value;
      String enumName = "ALC_${key.toUpperCase()}";
      int enumVal = bindings.alcGetEnumValue(
          device.devicePointer, enumName.toNativeUtf8().cast<Char>());
      if (enumVal == AL_NONE) {
        throw ArgumentError("'$key' is an invalid context attribute");
      }
      attributes.add(enumVal);
      attributes.add(value);
    }
    attributes.add(0);
    return attributes;
  }
}
