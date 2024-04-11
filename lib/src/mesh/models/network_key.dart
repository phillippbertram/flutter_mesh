import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/models/key.dart';
import 'package:flutter_mesh/src/mesh/models/key_refresh_phase.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data_keys.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

// TODO: JSONSerialization + Equatable
class NetworkKey implements MeshKey {
  NetworkKey._({
    required this.name,
    required this.index,
    required this.key,
    required this.phase,
    required this.timestamp,
  });

  factory NetworkKey({
    required String name,
    required Uint16 index,
    required Data key,
  }) {
    return NetworkKey._(
      name: name,
      index: index,
      key: key,
      phase: KeyRefreshPhase.normalOperation,
      timestamp: DateTime.now(),
    );
  }

  factory NetworkKey.primaryRandom() {
    return NetworkKey(
      name: 'Primary Network Key',
      index: 0,
      key: randomKeyData(),
    );
  }

  static Data randomKeyData() {
    return KeyUtils.random128BitKey();
  }

  @override
  final String name;

  @override
  final Uint16 index;

  @override
  final Data key;

  Data? get oldKey => _oldKey;
  Data? _oldKey;
  void setOldKey(Data? key) {
    _oldKey = key;
    if (oldKey == null) {
      // TODO:
      logger.f("MISSING IMPLEMENTATION: oldKey is null");
      // oldNetworkId = null
      // oldKeys = null;
      // phase = KeyRefreshPhase.normalOperation;
    }
  }

  final KeyRefreshPhase phase;
  final DateTime timestamp;
}
