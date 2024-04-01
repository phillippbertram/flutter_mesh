import 'package:flutter_mesh/src/mesh/models/address_range.dart';
import 'package:flutter_mesh/src/mesh/models/scene_range.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:flutter_mesh/src/mesh/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'provisioner.freezed.dart';

@freezed
class Provisioner with _$Provisioner {
  // TODO:
  const factory Provisioner({
    required UUID uuid,
    required String name,
    required List<AddressRange> allocatedUnicastRange,
    required List<AddressRange> allocatedGroupRange,
    required List<SceneRange> allocatedSceneRange,
  }) = _Provisioner;

  factory Provisioner.create({
    required String name,
    List<AddressRange>? allocatedUnicastRange,
    List<AddressRange>? allocatedGroupRange,
    List<SceneRange>? allocatedSceneRange,
  }) {
    return Provisioner(
        uuid: generateUuid(),
        name: name,
        allocatedUnicastRange:
            allocatedUnicastRange ?? [AddressRange.allUnicastAddresses],
        allocatedGroupRange:
            allocatedGroupRange ?? [AddressRange.allGroupAddresses],
        allocatedSceneRange: allocatedSceneRange ?? [SceneRange.allScenes]);
  }

// TODO:
  // factory Provisioner.fromJson(Map<String, dynamic> json) =>
  //     _$ProvisionerFromJson(json);
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20API/Provisioner%2BRanges.swift
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
