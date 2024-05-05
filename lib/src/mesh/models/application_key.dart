import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mesh/src/mesh/models/node.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data_keys.dart';
import '../types.dart';
import '../utils/crypto.dart';
import 'key.dart';
import 'mesh_network.dart';
import 'network_key.dart'; // Import the Key interface

part 'application_key.p.network.dart';

// TODO: Equatable + Serializable
// TODO: immutable
// TODO: not complete

class ApplicationKey extends Equatable implements MeshKey {
  @override
  List<Object?> get props =>
      [index, key]; // only these keys are used in nRF lib

  MeshNetwork? get meshNetwork => _meshNetwork;
  MeshNetwork? _meshNetwork;

  // TODO: internal
  void setMeshNetwork(MeshNetwork? meshNetwork) {
    _meshNetwork = meshNetwork;
  }

  @override
  final String name;

  // TODO: internal set
  @override
  final KeyIndex index;

  // TODO: internal set
  @override
  final Data key;

  // TODO: internal set + updateMesh Timestamp
  // @JsonKey(name: 'boundNetKey')
  KeyIndex? boundNetworkKeyIndex;

  // TODO: internal set
  final Data? oldKey;

  // TODO: internal
  /// Application Key identifier.
  late Uint8 aid;

  // TODO: internal
  /// Application Key identifier derived from the old key.
  Uint8? oldAid;

  ApplicationKey._({
    required this.name,
    required this.index,
    required this.key,
    this.boundNetworkKeyIndex,
    this.oldKey,
  }) {
    regenerateKeyDerivatives();
  }

  static Data randomKeyData() {
    return KeyUtils.random128BitKey();
  }

  // TODO: internal
  static Result<ApplicationKey> create({
    required String name,
    required KeyIndex index,
    required Data key,
    required NetworkKey boundNetworkKey,
  }) {
    if (!index.isValidKeyIndex) {
      return Result.error("KeyIndex is out of range");
    }

    return Result.value(ApplicationKey._(
      name: name,
      index: index,
      key: key,
      boundNetworkKeyIndex: boundNetworkKey.index,
      oldKey: null,
    ));
  }

  // TODO: remove this
  static ApplicationKey random({
    String? name,
    KeyIndex? index,
  }) {
    index ??= 0;
    name ??= "App Key $index";
    return ApplicationKey._(
      name: name,
      index: index,
      key: randomKeyData(),
      boundNetworkKeyIndex: null,
      oldKey: null,
    );
  }

  void regenerateKeyDerivatives() {
    aid = Crypto.calculateAid(key);
    if (oldKey != null && oldAid == null) {
      oldAid = Crypto.calculateAid(oldKey!);
    }
  }
}

extension ApplicationKeyDataValidation on Data {
  bool get isValidApplicationKey => length == 16;
}
