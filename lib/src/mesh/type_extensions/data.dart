import 'dart:typed_data';

import '../types.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Type%20Extensions/Data.swift

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
      endian ?? Endian.big, // TODO: or Endian.big?
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

  Data addUint32(Uint32 value, {Endian endian = Endian.little}) {
    final byteData = ByteData(4);
    byteData.setUint32(0, value, endian);
    return Data.from([...this, ...byteData.buffer.asUint8List()]);
  }

  /// drops the first `n` bytes from the data.
  Data dropFirst([int n = 1]) {
    return sublist(n);
  }

  Data suffix({required int from}) {
    return sublist(from);
  }

  Data combineWith(Data other) {
    return [...this, ...other];
  }

  Uint8List toUint8List() {
    if (this is Uint8List) {
      return this as Uint8List;
    }
    return Uint8List.fromList(this);
  }
}

// Extension on Uint8List for combining two Uint8List instances
// extension Uint8ListExtension on Uint8List {
//   Uint8List combineWith(Uint8List other) {
//     return Uint8List.fromList([...this, ...other]);
//   }
// }

abstract class DataUtils {
  static Data? fromHex(String hex) {
    if (hex.isEmpty) {
      return null;
    }
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final byte = hex.substring(i, i + 2);
      final byteValue = int.tryParse(byte, radix: 16);
      if (byteValue == null) {
        return null;
      }
      bytes.add(byteValue);
    }
    return Data.from(bytes);
  }
}
