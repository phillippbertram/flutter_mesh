// application_key.dart

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data_keys.dart';
import '../types.dart';
import 'key.dart';
import 'mesh_network.dart';
import 'network_key.dart'; // Import the Key interface

// TODO: Equatable + Serializable
// TODO: not complete

class ApplicationKey extends Equatable implements MeshKey {
  @override
  List<Object?> get props =>
      [index, key]; // only these keys are used in nRF lib

  MeshNetwork? get meshNetwork => _meshNetwork;
  MeshNetwork? _meshNetwork;

  // TODO: internal
  void setMeshNetwork(MeshNetwork meshNetwork) {
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

  ApplicationKey._({
    required this.name,
    required this.index,
    required this.key,
    this.boundNetworkKeyIndex,
    this.oldKey,
  });

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
}

extension ApplicationKeyDataValidation on Data {
  bool get isValidApplicationKey {
    return length == 16;
  }
}

extension ApplicationKeyNetworkKey on ApplicationKey {
  /// Return whether the Application Key is used in the given mesh network.
  ///
  /// A Application Key must be added to Application Keys array of the network
  /// and be known to at least one node to be used by it.
  ///
  /// An used Application Key may not be removed from the network.
  ///
  /// - parameter meshNetwork: The mesh network to look the key in.
  /// - returns: `True` if the key is used in the given network,
  ///            `false` otherwise.
  bool isUsedInNetwork(MeshNetwork meshNetwork) {
    // TODO:
    // final localProvisioner = meshNetwork.localProvisioner
    // return meshNetwork.applicationKeys.contains(self) &&
    //        // Application Key known by at least one node.
    //        meshNetwork.nodes
    //             .filter { $0.uuid != localProvisioner?.uuid }
    //             .knows(applicationKey: self)
    return false;
  }

  /// Bounds the Application Key to the given Network Key.
  /// The Application Key must not be in use. If any of the network Nodes
  /// already knows this key, this method throws an error.
  ///
  /// - parameter networkKey: The Network Key to bound the Application Key to.
  Result<void> bindToNetworkKey(NetworkKey networkKey) {
    if (meshNetwork == null) {
      return Result.error("Mesh Network is not set");
    }

    if (isUsedInNetwork(meshNetwork!)) {
      return Result.error("Application Key is already used in the network");
    }

    boundNetworkKeyIndex = networkKey.index;
    return Result.value(null);
  }

  /// The Network Key bound to this Application Key.
  NetworkKey? get boundNetworkKey {
    if (boundNetworkKeyIndex == null) {
      return null;
    }

    return meshNetwork?.networkKeys[boundNetworkKeyIndex!];
  }
}

// TODO:
// extension ListApplicationKeyExtension on List<ApplicationKey> {
//   List<ApplicationKey> knownToNode(Node node) {
//     return where((element) => false)
//   }
// }
