import 'package:flutter_mesh/src/mesh/models/address_range.dart';
import 'package:flutter_mesh/src/mesh/models/mesh_network.dart';
import 'package:flutter_mesh/src/mesh/models/scene_range.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:flutter_mesh/src/mesh/utils/utils.dart';

import 'node.dart';

part 'provisioner.p.node.dart';

// TODO: immutable + codable + equatable

class Provisioner {
  Provisioner._({
    required this.uuid,
    required this.name,
    required this.allocatedUnicastRange,
    required this.allocatedGroupRange,
    required this.allocatedSceneRange,
  });

  factory Provisioner.create({
    required String name,
    List<AddressRange>? allocatedUnicastRange,
    List<AddressRange>? allocatedGroupRange,
    List<SceneRange>? allocatedSceneRange,
  }) {
    return Provisioner._(
        uuid: generateUuid(),
        name: name,
        allocatedUnicastRange:
            allocatedUnicastRange ?? [AddressRange.allUnicastAddresses],
        allocatedGroupRange:
            allocatedGroupRange ?? [AddressRange.allGroupAddresses],
        allocatedSceneRange: allocatedSceneRange ?? [SceneRange.allScenes]);
  }

  final UUID uuid;
  final String name;
  final List<AddressRange> allocatedUnicastRange;
  final List<AddressRange> allocatedGroupRange;
  final List<SceneRange> allocatedSceneRange;
  MeshNetwork? meshNetwork;
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/Provisioner%2BRanges.swift
extension ProvisionerRangeX on Provisioner {
  /// Returns `true` if all defined ranges are valid.
  ///
  /// The Unicast Address range may not be empty, as it needs to assign addresses
  /// during provisioning.
  bool get isValid {
    return allocatedUnicastRange.isNotEmpty &&
        allocatedUnicastRange.isUnicastRange &&
        allocatedGroupRange.isGroupRange &&
        allocatedSceneRange.isValid;
  }

  /// Returns `true` if at least one range overlaps with the given Provisioner.
  ///
  /// - parameter provisioner: The Provisioner to check ranges with.
  /// - returns: `True` if this and the given Provisioner have overlapping ranges,
  ///            `false` otherwise.
  bool hasOverlappingRange(Provisioner other) {
    return hasOverlappingUnicastRanges(other) ||
        hasOverlappingGroupRanges(other) ||
        hasOverlappingSceneRanges(other);
  }

  /// Returns `true` if at least one Unicast Address range overlaps with address
  /// ranges of the given Provisioner.
  ///
  /// - parameter provisioner: The Provisioner to check ranges with.
  /// - returns: `True` if this and the given Provisioner have overlapping unicast
  ///            ranges, `false` otherwise.
  bool hasOverlappingUnicastRanges(Provisioner other) {
    return allocatedUnicastRange.any(
      (range) => other.allocatedUnicastRange.any(
        (otherRange) => range.overlapsRange(otherRange),
      ),
    );
  }

  /// Returns `true` if at least one Group Address range overlaps with address
  /// ranges of the given Provisioner.
  ///
  /// - parameter provisioner: The Provisioner to check ranges with.
  /// - returns: `True` if this and the given Provisioner have overlapping group
  ///            ranges, `false` otherwise.
  bool hasOverlappingGroupRanges(Provisioner other) {
    return allocatedGroupRange.any(
      (range) => other.allocatedGroupRange.any(
        (otherRange) => range.overlapsRange(otherRange),
      ),
    );
  }

  /// Returns `true` if at least one Scene range overlaps with scene ranges of
  /// the given Provisioner.
  ///
  /// - parameter provisioner: The Provisioner to check ranges with.
  /// - returns: `True` if this and the given Provisioner have overlapping scene
  ///            ranges, `false` otherwise.
  bool hasOverlappingSceneRanges(Provisioner other) {
    return allocatedSceneRange.any(
      (range) => other.allocatedSceneRange.any(
        (otherRange) => range.overlapsWith(otherRange),
      ),
    );
  }
}
