import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:collection/collection.dart';
import 'package:flutter_mesh/src/mesh/utils/utils.dart';

import 'application_key.dart';
import 'node_identity.dart';
import 'provisioner.dart';
import 'address.dart';
import 'network_identify.dart';
import 'network_key.dart';
import 'node.dart';

const _meshSchema = "http://json-schema.org/draft-04/schema#";
const _meshVersion = "1.0.1";
const _meshId =
    "https://www.bluetooth.com/specifications/specs/mesh-cdb-1-0-1-schema.json#";

// TODO: JSONSerialization + Equatable

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20Model/MeshNetwork.swift
class MeshNetwork {
  MeshNetwork._({
    required this.uuid,
    required this.meshName,
    required this.timestamp,
    required this.nodes,
    required this.networkKeys,
    required this.applicationKeys,
    required this.provisioners,
  });

  factory MeshNetwork({
    required String meshName,
    UUID? uuid,
  }) {
    return MeshNetwork._(
      uuid: uuid ?? generateUuid(),
      meshName: meshName,
      timestamp: DateTime.now(),
      nodes: [],
      networkKeys: [NetworkKey.primaryRandom()],
      applicationKeys: [],
      provisioners: [],
    );
  }

  final UUID uuid;
  final String meshName;
  final DateTime timestamp;

  final List<Node> nodes;

  final List<NetworkKey> networkKeys;
  final List<ApplicationKey> applicationKeys;

  final List<Provisioner> provisioners;
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20API/MeshNetwork%2BNodes.swift
extension MeshNetworkNodes on MeshNetwork {
  /// Returns whether any of the Network Keys in the mesh network
  /// matches the given Network Identity.
  ///
  /// - parameter networkId: The Network Identity.
  /// - returns: `True` if the Network ID matches any subnetwork of
  ///            this mesh network, `false` otherwise.
  bool matchesNetworkIdentity(NetworkIdentity networkIdentity) {
    return networkKeys.any((key) => networkIdentity.matches(key));
  }

  bool matchesNodeIdentity(NodeIdentity nodeIdentity) {
    return nodes.any((node) => nodeIdentity.matchesNode(node));
  }

  /// Returns a Node that matches the Node Identity, or `nil`.
  ///
  /// This method may be used to match the Node Identity or Private Node Identity beacons.
  ///
  /// - parameter nodeIdentity: Node Identity obtained from the advertising packet.
  /// - returns: A Node that matches the given Node Identity; or `nil` otherwise.
  Node? nodeMatchingNodeIdentity(NodeIdentity nodeIdentity) {
    return nodes.firstWhereOrNull((node) => nodeIdentity.matchesNode(node));
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20API/MeshNetwork%2BAddress.swift
extension MeshNetworkAddress on MeshNetwork {
  /// Returns the next available Unicast Address from the Unicast Address range
  /// assigned to the given Provisioner that can be assigned to a new Node with 1 Element.
  ///
  /// The returned address can be set as the Unicast Address of the Node.
  ///
  /// - parameters:
  ///   - offset: The primary Unicast Address to be assigned.
  ///   - provisioner:   The Provisioner that is creating the node.
  ///                    The address will be taken from it's allocated range.
  /// - returns: The next available Unicast Address that can be assigned to a node,
  ///            or `nil`, if there are no more available addresses in the allocated range.
  /// - seeAlso: ``nextAvailableUnicastAddress(startingFrom:for:elementsUsing:)``
  Address? nextAvailableUnicastAddress_({
    Address startingFrom = Address.minUnicastAddress,
    required Provisioner provisioner,
  }) {
    // TODO: Implement this
    return null;
    // return nextAvailableUnicastAddress(startingFrom: startingFrom, elementsCount: 1,
    //                                    provisioner: provisioner)
  }

  /// Returns the next available Unicast Address from the Unicast Address range
  /// assigned to the given Provisioner that can be assigned to a new Node with the given
  /// number of Elements.
  ///
  /// The returned address can be set as the primary Unicast Address of the Node.
  /// Each following Element will be identified by a subsequent Unicast Address.
  ///
  /// - parameters:
  ///   - offset: The primary Unicast Address to be assigned.
  ///   - elementsCount: The number of Node's Elements.
  ///   - provisioner:   The Provisioner that is creating the node.
  ///                    The address will be taken from it's allocated range.
  /// - returns: The next available Unicast Address that can be assigned to a Node,
  ///            or `nil`, if there are no more available addresses in the allocated range.
  Address? nextAvailableUnicastAddress({
    Address offset = Address.minUnicastAddress,
    required int elementsCount,
    required Provisioner provisioner,
  }) {
    logger.e("MISSING IMPLEMENTATION - nextAvailableUnicastAddress");
    // Assuming exclusions and usedAddresses are prepared outside this function for simplicity.
    // final exclusions = networkExclusions?.excludedAddresses(forIvIndex: ivIndex).sorted() ?? []
    // final usedAddresses = (exclusions + nodes
    //           .flatMap { node in node.elements }
    //           .map { element in element.unicastAddress })
    //           .sorted()

    // for (var range in provisioner.allocatedUnicastRange) {
    //   var address = range.lowAddress;

    //   if (range.contains(offset) && address < offset) {
    //     address = offset;
    //   }

    //   for (var usedAddress in allUsedAddresses) {
    //     if (address > usedAddress) continue;

    //     if (address + elementsCount - 1 < usedAddress) {
    //       return address;
    //     }

    //     address = usedAddress + 1;

    //     if (address + elementsCount - 1 > range.highAddress) {
    //       break;
    //     }
    //   }

    //   if (address + elementsCount - 1 <= range.highAddress) {
    //     return address;
    //   }
    // }

    // TODO: Implement this
    return const Address(0x01);
    return null; // No address found.
  }
}

extension MeshNetworkNodeExtensions on MeshNetwork {
  /// Returns whether any of the Network Keys in the mesh network
  /// matches the given Network Identity.
  ///
  /// - parameter networkId: The Network Identity.
  /// - returns: `True` if the Network ID matches any subnetwork of
  ///            this mesh network, `false` otherwise.
  bool matches(NetworkIdentity networkIdentity) {
    return networkKeys.any((key) => networkIdentity.matches(key));
  }
}

extension MeshNetworkProvisioner on MeshNetwork {
  /// Returns whether the Provisioner is in the mesh network.
  ///
  /// - parameter provisioner: The Provisioner to look for.
  /// - returns: `True` if the Provisioner was found, `false` otherwise.
  /// - since: 4.0.0
  bool containsProvisioner(Provisioner provisioner) {
    return containsProvisionerWithUuid(provisioner.uuid);
  }

  /// Returns whether the Provisioner with given UUID is in the
  /// mesh network.
  ///
  /// - parameter uuid: The Provisioner's UUID to look for.
  /// - returns: `True` if the Provisioner was found, `false` otherwise.
  /// - since: 4.0.0
  bool containsProvisionerWithUuid(UUID uuid) {
    return provisioners.any((provisioner) => provisioner.uuid == uuid);
  }

  /// Returns the local Provisioner, or `nil` if the mesh network
  /// does not have any.
  ///
  /// - seeAlso: ``setLocalProvisioner(_:)``
  Provisioner? get localProvisioner {
    return provisioners.firstOrNull;
  }

  Result<void> addProvisioner(Provisioner provisioner) {
    logger.e("MeshNetork: AddProvisioner Not implemented");

    // TODO: Implement this!!
    // Find the Unicast Address to be assigned.
    // guard let address = nextAvailableUnicastAddress(for: provisioner) else {
    //     throw MeshNetworkError.noAddressAvailable
    // }
    // try add(provisioner: provisioner, withAddress: address)

    provisioners.add(provisioner);

    return Result.value(null);
  }

  /// Sets the given Provisioner as the one that will be used for
  /// provisioning new Nodes.
  ///
  /// It will be moved to index 0 in the list of provisioners in the mesh network.
  ///
  /// The Provisioner will be added to the mesh network if it's not
  /// there already. Adding the Provisioner may throw an error,
  /// for example when the ranges overlap with ranges of another
  /// Provisioner or there are no free Unicast Addresses to be assigned.
  ///
  /// - parameter provisioner: The Provisioner to be used for provisioning.
  /// - throws: An error if adding the Provisioner failed.
  Result<void> setLocalProvisioner(Provisioner provisioner) {
    if (!containsProvisioner(provisioner)) {
      return addProvisioner(provisioner);
    }

    moveProvisioner(provisioner: provisioner, toIndex: 0);
    return Result.value(null);
  }

  /// Moves the given Provisioner to the new index.
  ///
  /// - important: The Provisioner at index 0 will be used as local Provisioner.
  /// - parameters:
  ///   - provisioner: The Provisioner to be moved.
  ///   - toIndex:     The destination index of the Provisioner.
  /// - seeAlso: ``setLocalProvisioner(_:)``
  void moveProvisioner({
    required Provisioner provisioner,
    required int toIndex,
  }) {
    final fromIndex =
        provisioners.indexWhere((p) => p.uuid == provisioner.uuid);
    if (fromIndex == -1) {
      return;
    }

    _moveProvisioner(fromIndex: fromIndex, toIndex: toIndex);
  }

  void _moveProvisioner({
    required int fromIndex,
    required int toIndex,
  }) {
    if (fromIndex == toIndex) {
      return;
    }

    final provisioner = provisioners.removeAt(fromIndex);
    provisioners.insert(toIndex, provisioner);
  }
}
