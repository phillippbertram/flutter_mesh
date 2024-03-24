import 'package:dart_mesh/src/mesh/models/key.dart';
import 'package:dart_mesh/src/mesh/models/key_refresh_phase.dart';
import 'package:dart_mesh/src/mesh/type_extensions/data_keys.dart';
import 'package:dart_mesh/src/mesh/types.dart';

// TODO: JSONSerialization + Equatable
class NetworkKey implements Key {
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

  factory NetworkKey.randomPrimary() {
    return NetworkKey(
      name: 'Primary NetworkKey',
      index: 0,
      key: DataUtils.random128BitKey(),
    );
  }

  final String name;
  final Uint16 index;
  final Data key;
  final KeyRefreshPhase phase;
  final DateTime timestamp;
}
