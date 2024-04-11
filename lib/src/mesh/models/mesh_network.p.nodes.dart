part of 'mesh_network.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/MeshNetwork%2BNodes.swift
extension MeshNetworkNodes on MeshNetwork {
  /// Returns Provisioner's Node object, if such exist and the Provisioner
  /// is in the mesh network; `nil` otherwise.
  ///
  /// The provisioner must be added to the network before calling this method,
  /// otherwise `nil` is returned.
  ///
  /// - important: Provisioners without a Node assigned cannot send mesh messages
  ///              (i.e. cannot configure nodes), but still can provision new devices.
  /// - parameter provisioner: The provisioner which node is to be returned.
  /// - returns: The Provisioner's node object, or `nil`.
  Node? nodeForProvisioner(Provisioner provisioner) {
    if (!hasProvisioner(provisioner)) {
      return null;
    }

    return nodeWithUuid(provisioner.uuid);
  }

  /// Returns the first found Node with given UUID.
  ///
  /// - parameter uuid: The Node UUID to look for.
  /// - returns: The Node found, or `nil` if no such exists.
  Node? nodeWithUuid(UUID uuid) {
    return nodes.firstWhereOrNull((node) => node.uuid == uuid);
  }

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

    logger.e("MISSING IMPLEMENTATION - addNode");

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
    _networkDidChange();
    return Result.value(null);
  }
}
