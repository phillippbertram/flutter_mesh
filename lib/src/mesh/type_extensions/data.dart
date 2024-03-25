import 'dart:ffi';
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

  Uint8 readUint8({int offset = 0}) {
    return this[offset];
  }

  Data addUint8(Uint8 value) {
    return Data.from([...this, value]);
  }

  Data addUint16(Uint16 value, {Endian endian = Endian.little}) {
    final byteData = ByteData(2);
    byteData.setUint16(0, value, endian);
    return Data.from([...this, ...byteData.buffer.asUint8List()]);
  }

  /// drops the first `n` bytes from the data.
  Data dropFirst([int n = 1]) {
    return sublist(n);
  }

  Data suffix({required int from}) {
    return sublist(from);
  }
}
