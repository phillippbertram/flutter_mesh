// TODO: JSON Serialization + Equatable

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import '../types.dart';
import 'address.dart';
import 'address_range.dart';
import 'element.dart';

class Node {
  Node._({
    required this.uuid,
    required this.name,
    required this.primaryUnicastAddress,
  });

  factory Node.create({
    required String uuid,
    required String name,
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

  final String uuid;
  final String name;

  final List<Element> elements = []; // TODO:

  Address primaryUnicastAddress;

  void setNetworkKeys(List<NetworkKey> networkKeys) {
    logger.e("MISSING IMPLEMENTATION");
    // TODO
  }

  void setApplicationKeys(List<ApplicationKey> applicationKeys) {
    logger.e("MISSING IMPLEMENTATION");
    // TODO
  }

  void addElements(List<Element> elements) {
    logger.e("MISSING IMPLEMENTATION");
    // TODO: implement this
    this.elements.addAll(elements);
  }

  void addElement(Element element) {
    logger.e("MISSING IMPLEMENTATION");
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
  /// The address range is continous and starts with ``primaryUnicastAddress``
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
