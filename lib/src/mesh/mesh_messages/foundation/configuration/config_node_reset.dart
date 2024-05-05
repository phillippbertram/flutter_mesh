import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/mesh.dart';

// TODO:
class ConfigNodeReset implements AcknowledgedConfigMessage {
  static Uint32 opcode = 0x8049;

  const ConfigNodeReset();
  static ConfigNodeReset? fromData(Uint8List data) {
    if (data.isNotEmpty) {
      return null;
    }
    return const ConfigNodeReset();
  }

  Data? get parameters => null;

  @override
  // TODO: implement isSegmented
  bool get isSegmented => throw UnimplementedError();

  @override
  // TODO: implement opCode
  Uint32 get opCode => throw UnimplementedError();

  @override
  // TODO: implement security
  MeshMessageSecurity get security => throw UnimplementedError();
}
