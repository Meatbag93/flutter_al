import "./bindings.dart";
import "./openal_generated_bindings.dart";
import "./device.dart";

class FlutterALError extends Error {}

class AlcError extends FlutterALError {}

class DeviceNotFoundError extends AlcError {
  final String deviceName;

  DeviceNotFoundError({this.deviceName = ""}) : super();

  @override
  String toString() {
    if (deviceName.isEmpty) {
      return "No OpenAL devices found";
    } else {
      return "OpenAL device $deviceName not found";
    }
  }
}

class InvalidDeviceError extends AlcError {
  @override
  String toString() => "Invalid OpenAL device";
}

class InvalidContextError extends AlcError {
  @override
  String toString() => "Invalid OpenAL context";
}

class InvalidAlcEnumError extends AlcError {
  @override
  String toString() => "Invalid OpenAL context enum value";
}

class InvalidAlcValueError extends AlcError {
  @override
  String toString() => "Invalid OpenAL context parameter value";
}

class OutOfMemoryError extends FlutterALError {
  @override
  String toString() => "Out of memory!";
}

class UnknownAlcError extends AlcError {
  final int alcErrorCode;

  UnknownAlcError({required this.alcErrorCode});

  @override
  String toString() =>
      "Unknown OpenAL context error (code ${alcErrorCode.toRadixString(16)})";
}

void checkAlcError(Device? device) {
  int errCode = bindings.alcGetError(device!.devicePointer);
  switch (errCode) {
    case ALC_NO_ERROR:
      return;
    case ALC_INVALID_DEVICE:
      throw InvalidDeviceError();
    case ALC_INVALID_CONTEXT:
      throw InvalidContextError();
    case ALC_INVALID_ENUM:
      throw InvalidAlcEnumError();
    case ALC_INVALID_VALUE:
      throw InvalidAlcValueError();
    case ALC_OUT_OF_MEMORY:
      throw OutOfMemoryError();
    default:
      throw UnknownAlcError(alcErrorCode: errCode);
  }
}

class AlError extends FlutterALError {}

class InvalidNameError extends AlError {
  @override
  String toString() {
    return "Invalid OpenAL object name";
  }
}

class InvalidOperationError extends AlError {
  @override
  String toString() {
    return "Invalid OpenAL operation";
  }
}

class InvalidAlEnumError extends AlError {
  @override
  String toString() {
    return "Invalid OpenAL enum value";
  }
}

class InvalidAlValueError extends AlError {
  @override
  String toString() {
    return "Invalid OpenAL parameter value";
  }
}

class UnknownAlError extends AlError {
  final int alErrorCode;

  UnknownAlError({required this.alErrorCode});

  @override
  String toString() {
    return "Unknown OpenAL error (code ${alErrorCode.toRadixString(16)})";
  }
}

/// @nodoc
void checkAlError() {
  int errCode = bindings.alGetError();
  switch (errCode) {
    case AL_NO_ERROR:
      return; // Fast path
    case AL_INVALID_NAME:
      throw InvalidNameError();
    case AL_INVALID_ENUM:
      throw InvalidAlEnumError();
    case AL_INVALID_VALUE:
      throw InvalidAlValueError();
    case AL_INVALID_OPERATION:
      throw InvalidOperationError();
    case AL_OUT_OF_MEMORY:
      throw OutOfMemoryError();
    default:
      throw UnknownAlError(alErrorCode: errCode);
  }
}
