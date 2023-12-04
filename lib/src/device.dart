import "dart:ffi";
import "package:ffi/ffi.dart";
import "./disposable.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./utils.dart";
import "./exceptions.dart";

/// An output device
final class Device extends Disposable {
  late final Pointer<ALCdevice> _device;

  /// Opens a device by [name]. If [name] is an empty string, open the default device.
  ///
  /// Throws a [StateError] if the device cannot be opened
  Device({String name = ""}) {
    Pointer<Char> cName =
        (name.isNotEmpty ? name.toNativeUtf8(allocator: malloc) : nullptr)
            .cast<Char>();
    try {
      _device = bindings.alcOpenDevice(cName);
      if (_device == nullptr) {
        throw DeviceNotFoundError(deviceName: name);
      }
    } finally {
      if (name.isNotEmpty) malloc.free(cName);
    }
  }

  /// @nodoc
  Pointer<ALCdevice> get devicePointer {
    ensureNotDisposed();
    return _device;
  }

  /// The name of this device
  String get name {
    ensureNotDisposed();
    return bindings
        .alcGetString(_device, ALC_DEVICE_SPECIFIER)
        .cast<Utf8>()
        .toDartString();
  }

  /// closes [this] device.
  ///
  /// If [this] device contains any contexts or buffers, the operation will fail and [this] will not be disposed
  @override
  void dispose() {
    ensureNotDisposed();
    int result = bindings.alcCloseDevice(_device);
    checkAlcError(this);
    if (result == AL_FALSE) {
      throw StateError(
          "This device contains buffers and/or sources and cannot be disposed"); // in case no error was generated.
    } else {
      super.dispose();
    }
  }

  /// a complete list of device strings identifying all the available rendering devices and paths present on the system.
  ///
  /// Strings obtained through this list can be used as the name param when constructing a new [Device]
  static List<String> get specifiers =>
      parseAlcList(bindings.alcGetString(nullptr, ALC_ALL_DEVICES_SPECIFIER));

  /// The specifier of the default device.
  static String get defaultSpecifier => bindings
      .alcGetString(nullptr, ALC_DEFAULT_ALL_DEVICES_SPECIFIER)
      .cast<Utf8>()
      .toDartString();
}
