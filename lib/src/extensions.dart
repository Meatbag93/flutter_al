import "dart:ffi";
import "package:ffi/ffi.dart";
import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./source.dart";

/// performs atomic source operations on lists of sources.
extension AtomicSourceOperations on List<Source> {
  /// Plays all sources atomicly
  void play() => using<void>((alocate) {
        int length = this.length;
        Pointer<ALuint> ids = alocate<ALuint>(length);
        for (int i = 0; i < length; i++) {
          Source src = this[i];
          src.ensureNotDisposed();
          ids[i] = src.id;
        }
        bindings.alSourcePlayv(length, ids);
      });

  /// Stops all sources atomicly
  void stop() => using<void>((alocate) {
        int length = this.length;
        Pointer<ALuint> ids = alocate<ALuint>(length);
        for (int i = 0; i < length; i++) {
          Source src = this[i];
          src.ensureNotDisposed();
          ids[i] = src.id;
        }
        bindings.alSourceStopv(length, ids);
      });

  /// Pauses all sources atomicly.
  void pause() => using<void>((alocate) {
        int length = this.length;
        Pointer<ALuint> ids = alocate<ALuint>(length);
        for (int i = 0; i < length; i++) {
          Source src = this[i];
          src.ensureNotDisposed();
          ids[i] = src.id;
        }
        bindings.alSourcePausev(length, ids);
      });
}
