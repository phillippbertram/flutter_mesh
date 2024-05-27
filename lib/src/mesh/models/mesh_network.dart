import 'package:async/async.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import 'iv_index.dart';
import 'node_identity.dart';
import 'network_identify.dart';

part 'mesh_network.p.address.dart';
part 'mesh_network.p.keys.dart';
part 'mesh_network.p.provisioner.dart';
part 'mesh_network.p.nodes.dart';

// const _meshSchema = "http://json-schema.org/draft-04/schema#";
// const _meshVersion = "1.0.1";
// const _meshId =
//     "https://www.bluetooth.com/specifications/specs/mesh-cdb-1-0-1-schema.json#";

// TODO: JSONSerialization + Equatable
// TODO: implement ChangeNotifier?

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20Model/MeshNetwork.swift
class MeshNetwork with ChangeNotifier {
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
      uuid: uuid ?? UUID(),
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
  List<MeshElement> get localElements => _localElements;
  List<MeshElement> _localElements = [MeshElement.primaryElement]; // TODO:
  void setLocalElements(List<MeshElement> elements) {
    // make copy so we can make changes without affecting the original list
    elements = [...elements];

    // https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20Model/MeshNetwork.swift#L92
    // TODO:
    logger.e("MISSING IMPLEMENTATION .setLocalElements (incomplete)");

    // Remove all empty Elements.
    elements.removeWhere((element) => element.models.isEmpty);

    // add required models and primary element if needed
    // TODO:
    // if elements.isEmpty {
    //   elements.append(Element(location: .unknown))
    //  }
    // elements[0].addPrimaryElementModels(self)
    if (elements.isEmpty) {
      elements.add(MeshElement.primaryElement);
    }

    // TODO: // Make sure the indexes are correct.

    _localElements = elements;

    // TODO:  Make sure there is enough address space for all the Elements
    // that are not taken by other Nodes and are in the local Provisioner's
    // address range. If required, cut the Elements array.
    final provisionerNode = localProvisioner?.node;
    if (provisionerNode != null) {
      var availableElements = [...elements];
      //   let availableElementsCount = provisioner.maxElementCount(for: node.primaryUnicastAddress)
      //   if availableElementsCount < elements.count {
      //       availableElements = elements.dropLast(elements.count - availableElementsCount)
      //   }
      // Assign the Elements to the Provisioner's Node.
      provisionerNode.setElements(availableElements);
    }
  }

  /// The IV Index of the mesh network.
  IvIndex get ivIndex => _ivIndex;
  IvIndex _ivIndex = const IvIndex(
    index: 0,
    updateActive: false,
  ); // TODO: Implement

  void setIvIndex(IvIndex ivIndex) {
    _ivIndex = ivIndex;

    // TODO:
    // Clean up the network exclusions.
    // networkExclusions?.cleanUp(forIvIndex: ivIndex)
    // if networkExclusions?.isEmpty ?? false {
    //     networkExclusions = nil
    // }
  }

  void networkDidChange() {
    timestamp = DateTime.now();
    notifyListeners();
  }

  /// Removes the Node with given UUID from the mesh network.
  ///
  /// - parameter uuid: The UUID of a Node to remove.
  Node? removeNodeWithUuid(UUID uuid) {
    final index = nodes.indexWhere((node) => node.uuid == uuid);
    if (index == -1) {
      return null;
    }

    final node = nodes.removeAt(index);

    // TODO (NRF): Verify that no Node is publishing to this Node.
    //       If such Node is found, this method should throw, as
    //       the Node is in use.

    // TODO: Remove Unicast Addresses of all Node's Elements from Scenes.
    logger.e(
        "MISSING IMPLEMENTATION: Remove Unicast Addresses of all Node's Elements from Scenes.");
    // scenes.forEach { scene in
    //     scene.remove(node: node);
    // }

    // As the Node is no longer part of the mesh network, remove
    // the reference to it.
    node.meshNetwork = null;

    networkDidChange();
    return node;
  }
}
