part of 'node.dart';

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
