import "dart:ffi";
import "dart:typed_data";
import "package:ffi/ffi.dart";
import "./disposable.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./context.dart";

/// A buffer that holds audio data
///
/// [Buffer] must not be instantiated directly. Instead see [Context.generateBuffers].
final class Buffer extends Disposable {
  late final Context _context;
  late final Pointer<ALuint> _idPointer;

  /// @nodoc
  Buffer(this._context, int id) {
    _idPointer = calloc<ALuint>()..value = id;
  }

  /// @nodoc
  int get id {
    ensureNotDisposed();
    return _idPointer.value;
  }

  /// Sets the data of [this].
  ///
  /// The data is actually coppied (twice), once from dart to c, and then by OpenAL,
  /// so this might have performance implications for big data.
  void setData(Uint8List data, {required int sampleRate, required int format}) {
    ensureNotDisposed();
    using<void>((alocate) {
      Pointer<Uint8> cData = alocate<Uint8>(data.length);
      cData.asTypedList(data.length).setAll(0, data);
      bindings.alBufferData(
          id, format, cData.cast<Void>(), data.length, sampleRate);
    });
  }

  /// The size of [this] buffer, in bytes.
  int get size => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_SIZE, value);
        return value.value;
      });

  /// The bit depth of [this]
  int get bits => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_BITS, value);
        return value.value;
      });

  /// The channels of the audio in [this]
  int get channels => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_CHANNELS, value);
        return value.value;
      });

  /// The sample rate of the audio in [this]
  int get sampleRate => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_FREQUENCY, value);
        return value.value;
      });

  @override
  void dispose() {
    super.dispose();
    try {
      _context.whileCurrent(() {
        bindings.alDeleteBuffers(1, _idPointer);
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
