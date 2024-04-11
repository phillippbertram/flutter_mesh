import 'package:flutter_mesh/src/mesh/types.dart';

typedef KeyIndex = Uint16;

/// A Key Index is 12-bit long Unsigned Integer.
/// This property returns `true` if the value is in range 0...4095.
extension KeyIndexExtension on KeyIndex {
  bool get isValidKeyIndex => this >= 0 && this <= 4095;
}

abstract class MeshKey {
  String get name;
  Uint16 get index;
  Data get key;
}
