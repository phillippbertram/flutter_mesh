part of 'mesh_network.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20API/MeshNetwork%2BProvisioner.swift
extension MeshNetworkProvisioner on MeshNetwork {
  // TODO: internal
  /// Returns whether the Provisioner is in the mesh network.
  ///
  /// - parameter provisioner: The Provisioner to look for.
  /// - returns: `True` if the Provisioner was found, `false` otherwise.
  bool hasProvisioner(Provisioner provisioner) {
    return provisioners.contains(provisioner);
  }

  // TODO: internal
  /// Returns whether the Provisioner with given UUID is in the
  /// mesh network.
  ///
  /// - parameter uuid: The Provisioner's UUID to look for.
  /// - returns: `True` if the Provisioner was found, `false` otherwise.
  bool hasProvisionerWithUUID(UUID uuid) {
    return provisioners.any((provisioner) => provisioner.uuid == uuid);
  }

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
    logger.t("adding provisioner: ${provisioner.name}");

    final address = nextAvailableUnicastAddress(provisioner: provisioner);
    if (address == null) {
      return Result.error("No address available.");
    }

    return addProvisionerWithAddress(
      provisioner: provisioner,
      unicastAddress: address,
    );
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
    logger.f("MISSING IMPLEMENTATION - addProvisionerWithAddress (incomplete)");

    // TODO:
    if (provisioner.meshNetwork != null) {
      return Result.error("Provisioner already added to a mesh network.");
    }

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
      final isAddressInUse = nodes.any(
        (node) => node.containsElementWithAddress(unicastAddress),
      );
      if (isAddressInUse) {
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
        logger.f(
            "MISSING IMPLEMENTATION - not setting all values for provisioner node");
        // node.companyIdentifier = 0x004C // Apple Inc.
        // node.minimumNumberOfReplayProtectionList = Address.maxUnicastAddress
      } else {
        node.addElement(MeshElement.primaryElement);
      }

      final addNodeRes = addNode(node);
      if (addNodeRes.isError) {
        return Result.error(addNodeRes.asError!.error);
      }
    }

    provisioner.meshNetwork = this;
    provisioners.add(provisioner);
    _networkDidChange();

    // When the local provisioner has been added, save its UUID.
    if (provisioners.length == 1) {
      // TODO:
      logger.f("MISSING IMPLEMENTATION - save local provisioner UUID");
    }

    return Result.value(null);
  }
}
