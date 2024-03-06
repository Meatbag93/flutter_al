import "dart:ffi";
import "dart:math";
import "dart:typed_data";
import "package:ffi/ffi.dart";
import "./buffer_format.dart";
import "./disposable.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "exceptions.dart";

class CaptureDevice extends Disposable {
  static final _noSamples = UnmodifiableUint8ListView(Uint8List(0));
  final Pointer<ALCdevice> _device;
  final Pointer<Uint8> _cBuffer;
  late final Uint8List _buffer;
  final int _bytesPerSample;

  /// @nodoc
  CaptureDevice(this._device,
      {required int bufferSize, required int bytesPerSample})
      : _cBuffer = malloc<Uint8>(bufferSize),
        _bytesPerSample = bytesPerSample {
    _buffer = _cBuffer.asTypedList(bufferSize, finalizer: malloc.nativeFree);
  }

  /// begins the capture operation
  void start() {
    ensureNotDisposed();
    bindings.alcCaptureStart(_device);
  }

  /// stops the capture operation
  void stop() {
    ensureNotDisposed();
    bindings.alcCaptureStop(_device);
  }

  /// The name of [this] device.
  String get name {
    ensureNotDisposed();
    return bindings
        .alcGetString(_device, ALC_CAPTURE_DEVICE_SPECIFIER)
        .cast<Utf8>()
        .toDartString();
  }

  int get availableSamples {
    ensureNotDisposed();
    final value = malloc<ALCint>();
    bindings.alcGetIntegerv(_device, ALC_CAPTURE_SAMPLES, 1, value);
    return value.value;
  }

  /// Complete a capture operation (non-blocking), returning a [Record] consisting of the captured data as [Uint8List] and the amount of samples read as [int]
  (Uint8List, int) snapshot({int? sampleCount}) {
    ensureNotDisposed();
    final maxSampleCount = _buffer.length ~/ _bytesPerSample;
    // never let sampleCount overflow beyond maxSampleCount!
    sampleCount = min((sampleCount ?? maxSampleCount), _buffer.length);
    final samplesToRead = min(sampleCount, availableSamples);
    if (samplesToRead <= 0) {
      return (_noSamples, 0);
    }
    bindings.alcCaptureSamples(_device, _cBuffer.cast(), samplesToRead);
    return (
      _buffer.buffer.asUint8List(0, samplesToRead * _bytesPerSample),
      samplesToRead
    );
  }

  @override
  void dispose() {
    super.dispose();
    bindings.alcCloseDevice(_device);
  }

  static CaptureDevice open(
      {String name = "",
      int bufferSize = 512,
      int sampleRate = 44100,
      int format = BufferFormat.mono16}) {
    Pointer<Char> cName =
        (name.isNotEmpty ? name.toNativeUtf8(allocator: malloc) : nullptr)
            .cast<Char>();
    try {
      final device =
          bindings.alcCaptureOpenDevice(cName, sampleRate, format, bufferSize);
      if (device == nullptr) {
        throw DeviceNotFoundError(deviceName: name);
      }
      final int bytesPerSample = switch (format) {
        BufferFormat.mono8 => 1,
        BufferFormat.mono16 => 2,
        BufferFormat.stereo8 => 2,
        BufferFormat.stereo16 => 4,
        _ => throw StateError(
            "Couldn't calculate bytes per sample for the format given")
      };
      return CaptureDevice(device,
          bufferSize: bufferSize, bytesPerSample: bytesPerSample);
    } finally {
      if (name.isNotEmpty) malloc.free(cName);
    }
  }
}
