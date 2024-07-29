part of 'mesh_network.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/MeshNetwork%2BAddress.swift
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

      // If the range has available space, return the address.
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
    // TODO: https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/MeshNetwork%2BAddress.swift#L84

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
