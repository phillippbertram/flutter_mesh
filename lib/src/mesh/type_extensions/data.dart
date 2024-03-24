import 'dart:typed_data';

import '../types.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Type%20Extensions/Data.swift

extension DataAccessX on Data {
  /// Converts the required number of bytes, starting from `offset`
  /// to a Uint16.
  ///
  /// - parameter offset: The offset from where the bytes are to be read.
  /// - returns: The value of type of the return type.
  /// TODO: test this
  Uint16 readUint16<T>({int offset = 0, Endian? endian}) {
    final bytes = Uint8List.fromList(this);
    final byteData = ByteData.sublistView(bytes, offset);
    return byteData.getUint16(
      0,
      endian ?? Endian.little, // TODO: or Endian.big?
    );
  }
}
