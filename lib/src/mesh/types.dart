import 'dart:ffi' as ffi;
import 'dart:typed_data' as typed;

// @see https://suragch.medium.com/working-with-bytes-in-dart-6ece83455721

typedef Data = typed.Uint8List;
typedef Uint16 = ffi.Uint16;
typedef Uint8 = int;// TODO: ffi.Uint8;
