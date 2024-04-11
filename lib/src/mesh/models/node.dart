// TODO: JSON Serialization + Equatable

import 'dart:math' as math;

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import '../utils/crypto.dart';

part 'node.p.keys.dart';
part 'node.p.address.dart';

class Node {
  Node._({
    required this.uuid,
    required this.name,
    required this.primaryUnicastAddress,
    required this.deviceKey,
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
          MeshElement.create(location: Location.unknown),
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

  final UUID uuid; // TODO: use the `Uuid` class
  final String? name;

  final List<MeshElement> elements = []; // TODO:

  Address primaryUnicastAddress;

  /// 128-bit device key for this Node.
  final Data? deviceKey;

  final List<ApplicationKey> appKeys = []; // TODO:

  void setNetworkKeys(List<NetworkKey> networkKeys) {
    logger.f("MISSING IMPLEMENTATION");
    // TODO
  }

  void setApplicationKeys(List<ApplicationKey> applicationKeys) {
    logger.f("MISSING IMPLEMENTATION");
    // TODO
  }
}

extension NodeElementsX on Node {
  // TODO: internal
  /// Adds given list of Elements to the Node.
  ///
  /// - parameter element: The list of Elements to be added.
  void addElements(List<MeshElement> elements) {
    for (var element in elements) {
      _addElement(element);
    }
  }

  // TODO: internal
  /// Adds the given Element to the Node.
  ///
  /// - parameter element: The Element to be added.
  void addElement(MeshElement element) {
    logger.f("MISSING IMPLEMENTATION");
  }

  void _addElement(MeshElement element) {
    final index = elements.length;
    elements.add(element);
    element.setParentNode(this);
    element.index = index;
  }

  /// Sets given list of Elements to the Node.
  ///
  /// Apart from simply replacing the Elements, this method copies properties of matching
  /// models from the old model to the new one. If at least one Model in the new Element
  /// was found in the new Element, the name of the Element is also copied.
  ///
  /// - parameter element: The new list of Elements to be added.
  void setElements(List<MeshElement> newElements) {
    // Look for matching Models. A matching model has the same Element index and Model id.

    final elementCount = math.min(elements.length, newElements.length);
    for (var e = 0; e < elementCount; e++) {
      final oldElement = elements[e];
      final newElement = newElements[e];

      final modelCount =
          math.min(oldElement.models.length, newElement.models.length);
      for (var m = 0; m < modelCount; m++) {
        final oldModel = oldElement.models[m];
        final newModel = newElement.models[m];
        if (oldModel.modelId == newModel.modelId) {
          newModel.applyFrom(oldModel);
          // If at least one Model matches, assume the Element didn't
          // change much and copy the name of it.
          if (oldElement.name != null) {
            newElement.name = oldElement.name;
          }
        }
      }
    }

    // Remove the old Elements.
    for (var element in elements) {
      element.setParentNode(null);
      element.index = 0;
    }
    elements.clear();

    // add new ones.
    addElements(newElements);
  }
}
