import 'package:uuid/uuid.dart';

import '../types.dart';

export 'beacon.dart';
export 'mesh_constants.dart';

extension IntegerHex on int {
  /// Returns a string representation of the integer as a hexadecimal number.
  ///
  /// The string is prefixed with `0x`. With padding
  String toHex({
    int? pad,
    bool includePrefix = false,
  }) {
    final hex = toRadixString(16).toUpperCase().padLeft(pad ?? 0, '0');
    if (includePrefix) {
      return '0x$hex';
    }
    return hex;
  }

  String asString() => toHex(includePrefix: true);
}

extension DataHex on Data {
  String toHex({
    bool includePrefix = false,
  }) {
    final hex =
        map((byte) => byte.toRadixString(16).toUpperCase().padLeft(2, '0'))
            .join();
    if (includePrefix) {
      return '0x$hex';
    }
    return hex;
  }
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