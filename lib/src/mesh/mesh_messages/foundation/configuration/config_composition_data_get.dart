import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/mesh_messages/foundation/foundation.dart';
import 'package:flutter_mesh/src/mesh/mesh_messages/mesh_message.dart';

import '../../../types.dart';

class ConfigCompositionDataGet extends AcknowledgedConfigMessage {
  // static const Uint32 opCode = 0x8008;
  // static ConfigCompositionDataStatus.type responseType;

  ConfigCompositionDataGet({this.page = 0});

  final Uint8 page;

  Data? get parameters {
    return Uint8List.fromList([page]);
  }

  @override
  // TODO: implement isSegmented
  bool get isSegmented => throw UnimplementedError();

  @override
  // TODO: implement opCode
  Uint32 get opCode => 0x8008;

  @override
  // TODO: implement security
  MeshMessageSecurity get security => throw UnimplementedError();
}

class ConfigCompositionDataStatus {}
