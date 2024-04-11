import 'package:async/async.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/models/key.dart';

import '../types.dart';
import '../utils/utils.dart';
import 'address_range.dart';
import 'address.dart';
import 'application_key.dart';
import 'element.dart';
import 'iv_index.dart';
import 'network_key.dart';
import 'node_identity.dart';
import 'network_identify.dart';
import 'node.dart';
import 'exclusion_list.dart';
import 'provisioner.dart';

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

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20Model/MeshNetwork.swift
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
      uuid: uuid ?? generateUuid(),
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
  List<Element> get localElements => _localElements;
  List<Element> _localElements = [Element.primaryElement]; // TODO:
  void setLocalElements(List<Element> elements) {
    // make copy so we can make changes without affecting the original list
    elements = [...elements];

    // https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20Model/MeshNetwork.swift#L92
    // TODO:
    logger.e("MISSING IMPLEMENTATION .setLocalElements");

    // Remove all empty Elements.
    elements.removeWhere((element) => element.models.isEmpty);

    // add required models and primary element if needed
    // TODO:
    // if elements.isEmpty {
    //   elements.append(Element(location: .unknown))
    //  }
    // elements[0].addPrimaryElementModels(self)
    if (elements.isEmpty) {
      elements.add(Element.primaryElement);
    }

    // TODO: // Make sure the indexes are correct.

    _localElements = elements;

    // TODO:  Make sure there is enough address space for all the Elements
    // that are not taken by other Nodes and are in the local Provisioner's
    // address range. If required, cut the Elements array.

    // if (localProvisioner?.node) {
    // // Assign the Elements to the Provisioner's Node.
    //   node.set(elements: availableElements)
    // }
  }

  /// The IV Index of the mesh network.
  IvIndex get ivIndex => _ivIndex;
  IvIndex _ivIndex =
      const IvIndex(index: 0, updateActive: false); // TODO: Implement
  void setIvIndex(IvIndex ivIndex) {
    _ivIndex = ivIndex;

    // TODO:
    // Clean up the network exclusions.
    // networkExclusions?.cleanUp(forIvIndex: ivIndex)
    // if networkExclusions?.isEmpty ?? false {
    //     networkExclusions = nil
    // }
  }

  void _networkDidChange() {
    timestamp = DateTime.now();
    notifyListeners();
  }
}
