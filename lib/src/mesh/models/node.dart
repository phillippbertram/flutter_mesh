// TODO: JSON Serialization + Equatable

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

class Node {
  Node._({
    required this.uuid,
    required this.name,
    required this.primaryUnicastAddress,
  });

  factory Node.create({
    required String uuid,
    String? name,
    required Address primaryUnicastAddress,
  }) {
    return Node._(
      uuid: uuid,
      name: name,
      primaryUnicastAddress: primaryUnicastAddress,
    );
  }

  /// Initializes the Provisioner's Node.
  ///
  /// The Provisioner's node has the same name and node UUID as the Provisioner.
  ///
  /// - parameter provisioner: The Provisioner for which the node is added.
  /// - parameter address:     The unicast address to be assigned to the Node.
  /// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20Model/Node.swift#L282
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
      uuid: device.uuid.str,
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
          Element.create(location: Location.unknown),
        ),
      },
    );
    return node;
  }

  factory Node._create({
    required String uuid,
    String? name,
    required Data deviceKey,
    required Security security,
    required NetworkKey networkKey,
    required Address primaryUnicastAddress,
  }) {
    final node = Node.create(
      uuid: uuid,
      name: name,
      primaryUnicastAddress: primaryUnicastAddress,
    );

    logger.f("MISSING IMPLEMENTATION");
    // TODO: set missing properties

    // self.uuid = uuid
    // self.name = name
    // self.primaryUnicastAddress = address
    // self.deviceKey = deviceKey
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

  final UUID uuid; // TODO: use the `Uuid` class
  final String? name;

  final List<Element> elements = []; // TODO:

  Address primaryUnicastAddress;

  final List<ApplicationKey> appKeys = []; // TODO:

  void setNetworkKeys(List<NetworkKey> networkKeys) {
    logger.f("MISSING IMPLEMENTATION");
    // TODO
  }

  void setApplicationKeys(List<ApplicationKey> applicationKeys) {
    logger.f("MISSING IMPLEMENTATION");
    // TODO
  }

  // TODO: internal
  /// Adds given list of Elements to the Node.
  ///
  /// - parameter element: The list of Elements to be added.
  void addElements(List<Element> elements) {
    for (var element in elements) {
      _addElement(element);
    }
  }

  // TODO: internal
  /// Adds the given Element to the Node.
  ///
  /// - parameter element: The Element to be added.
  void addElement(Element element) {
    logger.f("MISSING IMPLEMENTATION");
  }

  void _addElement(Element element) {
    final index = elements.length;
    elements.add(element);
    element.setParentNode(this);
    element.index = index;
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20API/Node%2BAddress.swift
extension NodeAddressX on Node {
  /// Number of Node's Elements.
  Uint8 get elementsCount {
    return elements.length;
  }

  /// The Unicast Address range assigned to all Elements of the Node.
  ///
  /// The address range is continuous and starts with ``primaryUnicastAddress``
  /// and ends with ``lastUnicastAddress``.
  AddressRange get unicastAddressRange {
    return AddressRange.fromAddress(
      address: primaryUnicastAddress,
      elementsCount: elementsCount,
    );
  }

  /// Returns whether the Node has the given Unicast Address assigned to one
  /// of its Elements.
  ///
  /// - parameter address: Address to check.
  /// - returns: `True` if any of node's elements (or the node itself) was assigned
  ///            the given address, `false` otherwise.
  bool containsElementWithAddress(Address address) {
    return unicastAddressRange.contains(address);
  }
}

extension NodeKeysX on Node {
  /// Returns whether the Node has knowledge about the given Application Key.
  /// The Application Key comparison bases only on the Key Index.
  ///
  /// - parameter applicationKey: The Application Key to look for.
  /// - returns: `True` if the Node has knowledge about the Application Key
  ///            with the same Key Index as given key, `false` otherwise.
  bool knowsApplicationKey(ApplicationKey key) {
    return knowsApplicationKeyIndex(key.index);
  }

  /// Returns whether the Node has knowledge about Application Key with the
  /// given index.
  ///
  /// - parameter applicationKeyIndex: The Application Key Index to look for.
  /// - returns: `True` if the Node has knowledge about the Application Key
  ///            index, `false` otherwise.
  bool knowsApplicationKeyIndex(KeyIndex keyIndex) {
    return appKeys.any((element) => element.index == keyIndex);
  }
}

extension NodeKeysListX on Iterable<Node> {
  /// Returns whether the Node has knowledge about the given list of Application Keys.
  ///
  /// - parameter keys: The list of Application Keys to look for.
  /// - returns: `True` if the Node has knowledge about all the Application Keys
  ///            with the same Key Index as given keys, `false` otherwise.
  bool knowsApplicationKey(ApplicationKey key) {
    return knowsApplicationKeyIndex(key.index);
  }

  /// Returns whether any of elements of this array is using an
  /// Application Key with given Key Index.
  ///
  /// - parameter applicationKeyIndex: The Application Key Index to look for.
  /// - returns: `True` if any of the Nodes have knowledge about the
  ///            Application Key Index, `false` otherwise.
  bool knowsApplicationKeyIndex(KeyIndex keyIndex) {
    // return contains(where: { $0.knows(applicationKeyIndex: applicationKeyIndex) })
    return any((node) => node.knowsApplicationKeyIndex(keyIndex));
  }
}
