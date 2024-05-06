// TODO: JSON Serialization + Equatable

import 'dart:math' as math;

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import '../utils/crypto.dart';

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
  });

  factory Node.create({
    required UUID uuid,
    String? name,
    required Address primaryUnicastAddress,
  }) {
    return Node._(
      uuid: uuid,
      name: name,
      primaryUnicastAddress: primaryUnicastAddress,
      deviceKey: Crypto.generateRandom128BitKey(),
    );
  }

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
    // TODO: set missing properties
    return Node.create(
      uuid: provisioner.uuid,
      name: provisioner.name,
      primaryUnicastAddress: address,
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
    final node = Node._(
      uuid: uuid,
      name: name,
      primaryUnicastAddress: primaryUnicastAddress,
      deviceKey: deviceKey,
    );

    logger.f("MISSING IMPLEMENTATION");
    // TODO: set missing properties

    // self.uuid = uuid
    // self.name = name
    // self.primaryUnicastAddress = address
    // this.deviceKey = deviceKey
    // self.security  = security
    // // Composition Data were not obtained.
    // self.isConfigComplete = false

    // // The updated flag is set to true if the Node was provisioned using
    // // a Network Key in Phase 2 (Using New Keys).
    // let updated = networkKey.phase == .usingNewKeys
    // self.netKeys  = [NodeKey(index: networkKey.index, updated: updated)]
    // self.appKeys  = []
    // self.elements = []

    // // If the Node as provisioned in an insecure way, lower the minimum security
    // // of the Network Key.
    // if security == .insecure {
    //     networkKey.lowerSecurity()
    // }

    return node;
  }

  // TODO: internal
  MeshNetwork? meshNetwork;

  final UUID uuid; // TODO: use the `Uuid` class
  final String? name;

  /// The 16-bit Company Identifier (CID) assigned by the Bluetooth SIG.
  /// The value of this property is obtained from node composition data.
  /// TODO: internal set
  Uint16? companyIdentifier;

  final List<MeshElement> elements = []; // TODO:

  Address primaryUnicastAddress;

  /// 128-bit device key for this Node.
  final Data? deviceKey;

  final List<ApplicationKey> appKeys = []; // TODO:

  final List<NetworkKey> networkKeys = []; // TODO:
  void setNetworkKeys(List<NetworkKey> networkKeys) {
    logger.f("MISSING IMPLEMENTATION");
    // TODO
  }

  void setApplicationKeys(List<ApplicationKey> applicationKeys) {
    logger.f("MISSING IMPLEMENTATION");
    // TODO
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
