import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:collection/collection.dart';

import '../types.dart';
import '../utils/utils.dart';
import 'address_range.dart';
import 'address.dart';
import 'application_key.dart';
import 'element.dart';
import 'iv_index.dart';
import 'network_key.dart';
import 'node_identity.dart';
import 'network_identify.dart';
import 'node.dart';
import 'exclusion_list.dart';
import 'provisioner.dart';

// const _meshSchema = "http://json-schema.org/draft-04/schema#";
// const _meshVersion = "1.0.1";
// const _meshId =
//     "https://www.bluetooth.com/specifications/specs/mesh-cdb-1-0-1-schema.json#";

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
    required this.networkExclusions,
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
      networkExclusions: null,
    );
  }

  final UUID uuid;
  final String meshName;
  DateTime timestamp;

  final List<Node> nodes;

  final List<NetworkKey> networkKeys;
  final List<ApplicationKey> applicationKeys;

  final List<Provisioner> provisioners;

  /// An array containing Unicast Addresses that cannot be assigned to new Nodes.
  final List<ExclusionList>? networkExclusions;

  /// The local Elements that will be added to the Provisioner's Node.
  List<Element> get localElements => _localElements;
  List<Element> _localElements = []; // TODO:
  void setLocalElements(List<Element> elements) {
    // https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20Model/MeshNetwork.swift#L92
    // TODO:
    logger.e("MISSING IMPLEMENTATION . setLocalElements");
    _localElements = elements;
  }

  /// The IV Index of the mesh network.
  IvIndex get ivIndex => _ivIndex;
  IvIndex _ivIndex =
      const IvIndex(index: 0, updateActive: false); // TODO: Implement
  void setIvIndex(IvIndex ivIndex) {
    _ivIndex = ivIndex;

    // TODO:
    // Clean up the network exclusions.
    // networkExclusions?.cleanUp(forIvIndex: ivIndex)
    // if networkExclusions?.isEmpty ?? false {
    //     networkExclusions = nil
    // }
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20API/MeshNetwork%2BNodes.swift
extension MeshNetworkNodes on MeshNetwork {
  /// Returns whether the given Node is in the mesh network.
  ///
  /// - parameter node: The Node to look for.
  /// - returns: `True` if the Node was found, `false` otherwise.
  /// - since: 4.0.0
  bool containsNode(Node node) {
    return containsNodeWithUuid(node.uuid);
  }

  /// Returns whether the Node with given UUID is in the
  /// mesh network.
  ///
  /// - parameter uuid: The Node's UUID to look for.
  /// - returns: `True` if the Node was found, `false` otherwise.
  /// - since: 4.0.0
  bool containsNodeWithUuid(UUID uuid) {
    return nodes.any((node) => node.uuid == uuid);
  }

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

  /// Returns whether any of the Network Keys in the mesh network
  /// matches the given Network Identity.
  ///
  /// - parameter networkId: The Network Identity.
  /// - returns: `True` if the Network ID matches any subnetwork of
  ///            this mesh network, `false` otherwise.
  bool matches(NetworkIdentity networkIdentity) {
    return networkKeys.any((key) => networkIdentity.matches(key));
  }

  /// Adds the Node to the local database.
  ///
  /// - important: This method should only be used to add debug Nodes, or Nodes
  ///              that have already been provisioned.
  ///              Use ``MeshNetworkManager/provision(unprovisionedDevice:over:)``
  ///              to provision a Node to the mesh network.
  ///
  /// - parameter node: A Node to be added.
  /// - throws: This method throws if the Node's address is not available,
  ///           the Node does not have a Network Key, the Network Key does
  ///           not belong to the mesh network, or a Node with the same UUID
  ///           already exists in the network.
  Result<void> addNode(Node node) {
    // make sure the node does not exist already
    if (containsNode(node)) {
      return Result.error("Node with the same UUID already exists.");
    }

    // verify if the address range is available for the new node
    if (!isAddressAvailableForNode(node.primaryUnicastAddress, node: node)) {
      return Result.error("Address is not available.");
    }

    logger.e("MISSING IMPLENENTATION - addNode");

    // Ensure the Network Key exists.
    // TODO:
    //      guard let netKeyIndex = node.netKeys.first?.index else {
    //     throw MeshNetworkError.noNetworkKey
    // }

    // Make sure the network contains a Network Key with the same Key Index.
    // TODO:
    // guard networkKeys.contains(where: { $0.index == netKeyIndex }) else {
    //       throw MeshNetworkError.invalidKey
    //   }

    // TODO:
    // node.meshNetwork = this;
    nodes.add(node);
    timestamp = DateTime.now();
    return Result.value(null);
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20API/MeshNetwork%2BAddress.swift
extension MeshNetworkAddress on MeshNetwork {
  List<Address> get usedAddresses {
    final exclusions =
        networkExclusions?.excludedAddressesForIvIndex(ivIndex).sorted() ?? [];

    final nodeAddresses = nodes
        .expand((node) => node.elements)
        .map((element) => element.unicastAddress);

    return [...exclusions, ...nodeAddresses].sorted();
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
    int elementsCount = 1,
    Provisioner? provisioner,
  }) {
    provisioner ??= localProvisioner;
    if (provisioner == null) {
      logger.w("No provisioner found in the mesh network.");
      return null;
    }

    final usedAddresses = this.usedAddresses;

    for (final range in provisioner.allocatedUnicastRange) {
      var address = range.low;

      if (range.contains(offset) && address < offset) {
        address = offset;
      }

      for (var usedAddress in usedAddresses) {
        if (address > usedAddress) continue;

        if (address + elementsCount - 1 < usedAddress) {
          return address;
        }

        address = usedAddress + 1;

        if (address + elementsCount - 1 > range.high) {
          break;
        }
      }

      if (address + elementsCount - 1 <= range.high) {
        return address;
      }
    }

    logger.w("no address available.");
    return null; // No address found.
  }

  /// Returns whether the given address can be reassigned to the given Node.
  ///
  /// The Unicast Addresses already assigned to the given Node are excluded from
  /// checking address collisions, that is `true` is returned as if they were available.
  ///
  /// - parameters:
  ///   - address: The first address to check.
  ///   - node:    The Node, which address is to change. It will be excluded
  ///              from checking address collisions.
  /// - returns: `True`, if the address is available, `false` otherwise.
  bool isAddressAvailableForNode(Address address, {required Node node}) {
    // TODO: https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20API/MeshNetwork%2BAddress.swift#L84

    logger.e("MISSING IMPLEMENTATION - isAddressAvailableForNode");

    final range = AddressRange.fromAddress(
      address: address,
      elementsCount: node.elementsCount,
    );
    final otherNodes = nodes.where((n) => n != node);

    // TODO:
    // return range.isUnicastRange &&
    //     !otherNodes.any(
    //         (n) => n.containsElementsWithAddressesOverlappingRange(range)) &&
    //     !(networkExclusions?.contains(range, forIvIndex: ivIndex) ?? false);
    return true;
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20API/MeshNetwork%2BProvisioner.swift
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

  Result<void> addProvisioner(Provisioner provisioner) {
    logger.e("MeshNetork: AddProvisioner Not implemented");

    // Find the Unicast Address to be assigned.
    // guard let address = nextAvailableUnicastAddress(for: provisioner) else {
    //     throw MeshNetworkError.noAddressAvailable
    // }
    // try add(provisioner: provisioner, withAddress: address)

    final address = nextAvailableUnicastAddress(provisioner: provisioner);
    if (address == null) {
      return Result.error("No address available.");
    }

    return addProvisionerWithAddress(
        provisioner: provisioner, unicastAddress: address);
  }

  /// Adds the Provisioner and assigns the given Unicast Address to it.
  ///
  /// This method does nothing if the Provisioner is already added to the
  /// mesh network.
  ///
  /// - parameter provisioner:    The Provisioner to be added.
  /// - parameter unicastAddress: The Unicast Address to be used by the Provisioner.
  ///                             A `nil` address means that the Provisioner is not
  ///                             able to perform configuration operations.
  /// - throws: ``MeshNetworkError`` - if validation of the Provisioner has failed.
  Result<void> addProvisionerWithAddress({
    required Provisioner provisioner,
    Address? unicastAddress,
  }) {
    logger.e("MISSING IMPLEMENTATION - addProvisionerWithAddress");

    // TODO:
    // if (provisioner.meshNetwork != null) {
    //   return Result.error("Provisioner already added to a mesh network.");
    // }

    if (!provisioner.isValid) {
      return Result.error("Provisioner is not valid.");
    }

    // check for overlapping ranges
    for (final other in provisioners) {
      if (provisioner.hasOverlappingRange(other)) {
        return Result.error(
            "Provisioner's range overlaps with another provisioner.");
      }
    }

    // check for overlapping addresses
    if (unicastAddress != null) {
      // Is the given address inside Provisioner's address range?
      if (!provisioner.allocatedUnicastRange.containsAddress(unicastAddress)) {
        return Result.error(
            "Unicast address is not in the provisioner's range.");
      }

      // Is the address already used?
      if (nodes
          .any((node) => node.containsElementWithAddress(unicastAddress))) {
        return Result.error("Unicast address is already used.");
      }
    }

    // is the provisioner already added?
    if (containsProvisioner(provisioner)) {
      return Result.value(null);
    }

    // Is there a node with the Provisioner's UUID?
    if (containsNodeWithUuid(provisioner.uuid)) {
      // The UUID conflict is super unlikely to happen. All UUIDs are
      // randomly generated.
      // TODO: Should a new UUID be autogenerated instead?
      return Result.error("Node with the same UUID already exists.");
    }

    // Add the Provisioner's Node.
    if (unicastAddress != null) {
      final node = Node.forProvisioner(provisioner, address: unicastAddress);

      // The new Provisioner will be aware of all currently existing
      // Network and Application Keys.
      node.setNetworkKeys(networkKeys);
      node.setApplicationKeys(applicationKeys);

      // Set the Node's Elements.
      // TODO: is this what we want?
      if (provisioners.isEmpty) {
        node.addElements(localElements);

        // TODO: implement this
        logger.e(
            "MISSING IMPLEMENTATION - not setting all values for provisioner node");
        // node.companyIdentifier = 0x004C // Apple Inc.
        // node.minimumNumberOfReplayProtectionList = Address.maxUnicastAddress
      } else {
        node.addElement(Element.primaryElement);
      }

      final addNodeRes = addNode(node);
      if (addNodeRes.isError) {
        return Result.error(addNodeRes.asError!.error);
      }
    }

    logger.e("MISSING IMPLEMENTATION - addProvisionerWithAddress");
    // TODO:
    // provisioner.meshNetwork = this;
    provisioners.add(provisioner);
    timestamp = DateTime.now();

    // When the local provisioner has been added, save its UUID.
    if (provisioners.length == 1) {
      // TODO:
      logger.e("MISSING IMPLEMENTATION - save local provisioner UUID");
    }

    return Result.value(null);
  }
}
