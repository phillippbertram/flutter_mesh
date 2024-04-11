import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/mesh_constants.dart';
import 'node.dart';

/// The Node Identity contains information from Node Identity or Private Node Identity
/// beacon.
///
/// It can be used to match advertising device to a specific ``Node`` in the network.
///
/// - since: 4.0.0
/// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20Model/NodeIdentity.swift
abstract class NodeIdentity {
  /// Returns whether the identity matches given ``Node``.
  ///
  /// - parameter node: The Node to check.
  /// - returns: True, if the identity matches the Node; false otherwise.
  bool matchesNode(Node node);
}

class PublicNodeIdentity implements NodeIdentity {
  /// Creates a Node Identity object from the given advertisement data.
  /// The data must contain Hash and Random values.
  /// - parameter advertisementData: The advertisement data.
  /// - returns: The Node Identity object, or nil if the data is invalid.
  /// - since: 4.0.0
  PublicNodeIdentity({required this.hash, required this.random});

  /// Creates a Node Identity object from the given advertisement data.
  /// The data must contain Hash and Random values.
  /// - parameter advertisementData: The advertisement data.
  static PublicNodeIdentity? fromAdvertisementData(
    AdvertisementData advertisementData,
  ) {
    final serviceData = advertisementData.serviceData;
    if (serviceData.isEmpty) {
      return null;
    }

    final data = serviceData[Guid(MeshProxyService().uuid)];
    if (data == null || data.length != 17 || data[0] != 0x01) {
      return null;
    }

    return PublicNodeIdentity(
      hash: Data.from(data.sublist(1, 9)),
      random: Data.from(data.sublist(9, 17)),
    );
  }

  /// Function of the included random number and identity information.
  final Data hash;

  /// 64-bit random number.
  final Data random;

  // MARK: - NodeIdentity

  @override
  bool matchesNode(Node node) {
    // TODO:
    throw UnimplementedError();
  }
}
