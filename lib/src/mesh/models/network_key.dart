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
      name: 'Primary NetworkKey',
      index: 0,
      key: DataUtils.random128BitKey(),
    );
  }

  @override
  final String name;

  @override
  final Uint16 index;

  @override
  final Data key;

  final KeyRefreshPhase phase;
  final DateTime timestamp;
}
