import "dart:ffi";
import "dart:typed_data";
import "package:ffi/ffi.dart";
import "./disposable.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./context.dart";

/// A buffer
///
/// Holds audio data
final class Buffer extends Disposable {
  late final Context _context;
  late final Pointer<ALuint> _idPointer;
  Buffer(this._context, int id) {
    _idPointer = calloc<ALuint>()..value = id;
  }
  int get id => _idPointer.value;

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

  int get size => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_SIZE, value);
        return value.value;
      });
  int get bits => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_BITS, value);
        return value.value;
      });
  int get channels => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_CHANNELS, value);
        return value.value;
      });
  int get sampleRate => using<int>((alocate) {
        ensureNotDisposed();
        Pointer<ALint> value = alocate<ALint>();
        bindings.alGetBufferi(id, AL_FREQUENCY, value);
        return value.value;
      });

  /// Deletes [this]
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
