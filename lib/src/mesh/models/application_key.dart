// application_key.dart

import 'package:dart_mesh/src/mesh/models/mesh_network.dart';
import 'package:dart_mesh/src/mesh/models/network_key.dart';
import 'package:dart_mesh/src/mesh/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'key.dart'; // Import the Key interface

part 'application_key.freezed.dart';
part 'application_key.g.dart'; // For JSON serialization

// TODO: not complete merged

@freezed
class ApplicationKey with _$ApplicationKey implements Key {
  // TODO:  WeakReference<MeshNetwork>? _meshNetwork;

  const factory ApplicationKey({
    required String name,

    // TODO: internal set
    required Uint16 index,

    // TODO: internal set
    required Data key,

    // TODO: internal set + updateMesh Timestamp
    @JsonKey(name: 'boundNetKey') required int? boundNetworkKeyIndex,

    // TODO: internal set
    List<int>? oldKey,
  }) = _ApplicationKey;

  factory ApplicationKey.fromJson(Map<String, dynamic> json) =>
      _$ApplicationKeyFromJson(json);
}

extension ApplicationKeyExtension on ApplicationKey {
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

  ApplicationKey bindToNetworkKey(NetworkKey networkKey) {
    // TODO: check if _meshNetwork is not null, throw error if null

    // TODO: check if networkKey is already bound, throw error if already bound

    return copyWith(boundNetworkKeyIndex: networkKey.index);
  }
}

// TODO:
// extension ListApplicationKeyExtension on List<ApplicationKey> {
//   List<ApplicationKey> knownToNode(Node node) {
//     return where((element) => false)
//   }
// }