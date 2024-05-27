import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/mesh_messages/foundation/foundation.dart';
import 'package:flutter_mesh/src/mesh/mesh_messages/mesh_message.dart';

import '../../../types.dart';

class ConfigCompositionDataGet extends AcknowledgedConfigMessage {
  // TODO
  // static const Uint32 opCode = 0x8008;
  // static ConfigCompositionDataStatus.type responseType;

  ConfigCompositionDataGet({this.page = 0});

  final Uint8 page;

  Data? get parameters {
    return Uint8List.fromList([page]);
  }

  @override
  bool get isSegmented => false; // TODO: implement isSegmented

  @override
  Uint32 get opCode => 0x8008;

// TODO: implement security
  @override
  MeshMessageSecurity get security => MeshMessageSecurity.low;
}

class ConfigCompositionDataStatus {}
