// TODO: JSON Serialization + Equatable

import 'dart:math' as math;

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import '../utils/crypto.dart';
import 'node_features.dart';

part 'node.p.keys.dart';
part 'node.p.address.dart';
part 'node.p.elements.dart';
part 'node.p.provisioner.dart';

class Node {
  Node._({
    required this.uuid,
    required this.name,
    required this.primaryUnicastAddress,
    required this.deviceKey,
    required this.security,
    required bool isConfigComplete,
    required this.features,
    required this.netKeys,
    required this.appKeys,
    required List<MeshElement> elements,
    required this.minimumNumberOfReplayProtectionList,
    required Uint8? ttl,
  })  : _isConfigComplete = isConfigComplete,
        _ttl = ttl,
        _elements = elements;

  // factory Node.create({
  //   required UUID uuid,
  //   String? name,
  //   required Address primaryUnicastAddress,
  // }) {
  //   return Node._(
  //     uuid: uuid,
  //     name: name,
  //     primaryUnicastAddress: primaryUnicastAddress,
  //     deviceKey: Crypto.generateRandom128BitKey(),
  //   );
  // }

  /// Initializes the Provisioner's Node.
  ///
  /// The Provisioner's node has the same name and node UUID as the Provisioner.
  ///
  /// - parameter provisioner: The Provisioner for which the node is added.
  /// - parameter address:     The unicast address to be assigned to the Node.
  /// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20Model/Node.swift#L282
  factory Node.forProvisioner(
    Provisioner provisioner, {
    required Address address,
  }) {
    logger.f("MISSING IMPLEMENTATION: Node.forProvisioner");

    return Node._(
      uuid: provisioner.uuid,
      name: provisioner.name,
      primaryUnicastAddress: address,
      deviceKey: Crypto.generateRandom128BitKey(),
      security: Security.secure,
      ttl: null,
      isConfigComplete: false,
      features: const NodeFeaturesState.allNotSupported(),
      minimumNumberOfReplayProtectionList: Address.maxUnicastAddress.value,
      netKeys: [],
      appKeys: [],
      elements: [],
    );
  }

  /// Initializes a Node for given unprovisioned device.
  ///
  /// The Node will have the same UUID as the device in the advertising
  /// packet.
  ///
  /// - parameters:
  ///   - unprovisionedDevice: The newly provisioned device.
  ///   - n: Number of Elements on the new Node.
  ///   - deviceKey: The Device Key.
  ///   - security: The Node's security. A Node is considered secure if it was
  ///               provisioned using a OOB Public Key.
  ///   - networkKey: The Network Key.
  ///   - address: The Unicast Address to be assigned to the Node.
  factory Node.forUnprovisionedDevice(
    UnprovisionedDevice device, {
    required Uint8 elementCount,
    required Data deviceKey,
    required Security security,
    required NetworkKey networkKey,
    required Address address,
  }) {
    final node = Node._create(
      uuid: device.uuid.toUUID(),
      name: device.name,
      deviceKey: deviceKey,
      security: security,
      networkKey: networkKey,
      primaryUnicastAddress: address,
    );
    // Elements will be queried with Composition Data.
    // Let's just add n empty Elements to reserve addresses.
    List.generate(
      elementCount,
      (index) => {
        node._addElement(
          MeshElement.create(location: Location.unknown),
        ),
      },
    );
    return node;
  }

  factory Node._create({
    required UUID uuid,
    String? name,
    required Data deviceKey,
    required Security security,
    required NetworkKey networkKey,
    required Address primaryUnicastAddress,
  }) {
    // If the Node as provisioned in an insecure way, lower the minimum security
    // of the Network Key.
    if (security == Security.insecure) {
      networkKey.lowerSecurity();
    }

    // The updated flag is set to true if the Node was provisioned using
    // a Network Key in Phase 2 (Using New Keys).
    final updated = networkKey.phase == KeyRefreshPhase.usingNewKeys;
    final netKeys = [NodeKey(index: networkKey.index, updated: updated)];

    return Node._(
      uuid: uuid,
      name: name,
      primaryUnicastAddress: primaryUnicastAddress,
      deviceKey: deviceKey,
      isConfigComplete: false,
      security: security,
      netKeys: netKeys,
      appKeys: [],
      elements: [],
      features: null,
      minimumNumberOfReplayProtectionList: null,
      ttl: null,
    );
  }

  // TODO: internal
  MeshNetwork? meshNetwork;

  final UUID uuid; // TODO: use the `Uuid` class
  final String? name;

  /// The 16-bit Company Identifier (CID) assigned by the Bluetooth SIG.
  /// The value of this property is obtained from node composition data.
  /// TODO: internal set
  Uint16? companyIdentifier;

  /// The 16-bit vendor-assigned Product Identifier (PID).
  /// The value of this property is obtained from node composition data.
  /// TODO: internal(set)
  Uint16? productIdentifier;

  /// The 16-bit vendor-assigned Version Identifier (VID).
  /// The value of this property is obtained from node composition data.
  Uint16? versionIdentifier;

  /// The minimum number of Replay Protection List (RPL) entries for this
  /// node. The value of this property is obtained from node composition
  /// data.
  final Uint16? minimumNumberOfReplayProtectionList;

  /// Node's features.
  NodeFeaturesState? features;

  /// Primary Unicast Address of the Node.
  Address primaryUnicastAddress;

  /// 128-bit device key for this Node.
  final Data? deviceKey;

  /// The level of security for the subnet on which the node has been
  /// originally provisioner.
  final Security security;

  /// An array of Node Network Key objects that include information
  /// about the Network Keys known to this node.
  final List<NodeKey> netKeys;

  /// An array of Node Application Key objects that include information
  /// about the Application Keys known to this node.
  final List<NodeKey> appKeys;

  List<MeshElement> _elements = [];

  /// An array of node's elements.
  List<MeshElement> get elements => _elements;

  /// Returns list of Network Keys known to this Node.
  ///
  /// - note: If the Node has been removed from the mesh network this
  ///         property returns an empty array.
  List<NetworkKey> get networkKeys => [];

  /// Sets the Network Keys to the Node.
  ///
  /// This method overwrites previous keys.
  ///
  /// - parameter networkKeys: The Network Keys to set.
  set networkKeys(List<NetworkKey> networkKeys) {
    logger.f("MISSING IMPLEMENTATION: Node.networkKeys setter");
    // TODO: set(networkKeysWithIndexes: networkKeys.map { $0.index })
  }

  /// Returns list of Application Keys known to this Node.
  ///
  /// - note: If the Node has been removed from the mesh network this
  ///         property returns an empty array.
  List<ApplicationKey> get applicationKeys => [];

  /// Sets the Application Keys to the Node.
  /// This will overwrite the previous keys.
  ///
  /// - parameter applicationKeys: The Application Keys to set.
  set applicationKeys(List<ApplicationKey> applicationKeys) {
    logger.f("MISSING IMPLEMENTATION: Node.applicationKeys setter");
    // TODO: set(applicationKeysWithIndexes: applicationKeys.map { $0.index })
  }

  /// The boolean value represents whether the Mesh Manager
  /// has finished configuring this Node. The property is set to `true`
  /// once a Mesh Manager is done completing this node's
  /// configuration, otherwise it is set to `false`.
  bool _isConfigComplete = false;
  bool get isConfigComplete => _isConfigComplete;
  set isConfigComplete(bool isConfigComplete) {
    _isConfigComplete = isConfigComplete;
    meshNetwork?.networkDidChange();
  }

  Uint8? _ttl;
  Uint8? get ttl => _ttl;
  set ttl(Uint8? ttl) {
    _ttl = ttl;
    meshNetwork?.networkDidChange();
  }

  /// The default Time To Live (TTL) value used when sending messages.
  /// The TTL may only be set for a Provisioner's Node, or for a Node
  /// that has not been added to a mesh network.
  ///
  /// Use ``ConfigDefaultTtlGet`` and ``ConfigDefaultTtlSet`` messages to
  /// read or set the default TTL value of a remote Node.
  Uint8? get defaultTtl => ttl;
  set defaultTtl(Uint8? ttl) {
    if (meshNetwork != null && !isProvisioner) {
      logger.w(
          "Default TTL may only be set for a Provisioner's Node. Use ConfigDefaultTtlSet(ttl) message to send new TTL value to a remote Node.");
      return;
    }

    this.ttl = ttl;
  }
}

// TODO: Codable
class NodeKey {
  NodeKey({
    required this.index,
    required this.updated,
  });

  final KeyIndex index;
  final bool updated;
}

/// The state of a network or application key distributed to a mesh
/// node by a Mesh Manager.
// struct NodeKey: Codable {
//     /// The Key index for this network key.
//     public internal(set) var index: KeyIndex
//     /// This flag contains value set to `false`, unless a Key Refresh
//     /// procedure is in progress and the network has been successfully
//     /// updated.
//     public internal(set) var updated: Bool

//     internal init(index: KeyIndex, updated: Bool) {
//         self.index   = index
//         self.updated = updated
//     }

//     internal init(of key: Key) {
//         self.index   = key.index
//         self.updated = false
//     }
// }
