import "dart:ffi";
import "package:ffi/ffi.dart";
import "./openal_generated_bindings.dart";

/// Converts an alclist thing (a list of null-ceperated strings, ended by 2 nulls) to a list of dart strings
List<String> parseAlcList(Pointer<ALCchar> pointer) {
  List<String> result = [];
  int index = 0;
  while (pointer[index] != 0) {
    Pointer<Utf8> cString = pointer.elementAt(index).cast<Utf8>();
    String dartString = cString.toDartString();
    result.add(dartString);
    index += (dartString.length + 1);
  }
  return result;
}
