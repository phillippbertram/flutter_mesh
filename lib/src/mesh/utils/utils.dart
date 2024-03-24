import 'package:uuid/uuid.dart';

import '../types.dart';

export 'beacon.dart';
export 'mesh_constants.dart';

extension IntegerHex on int {
  /// Returns a string representation of the integer as a hexadecimal number.
  ///
  /// The string is prefixed with `0x`.
  String toHex() => '0x${toRadixString(16).toUpperCase()}';
}

extension DataHex on Data {
  String toHex() =>
      map((byte) => byte.toRadixString(16).toUpperCase().padLeft(2, '0'))
          .join();
}

extension StringHex on String {
  /// Returns a string representation of the integer as a hexadecimal number.
  ///
  /// The string is prefixed with `0x`.
  int toIntFromHex() => int.parse(this, radix: 16);
}

// ================
// TODO: create own UUID type?
const _uuid = Uuid();
String generateUuid() => _uuid.v4().replaceAll("-", "");
// ================