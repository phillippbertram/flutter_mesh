import 'package:flutter_mesh/src/mesh/models/address_range.dart';
import 'package:flutter_mesh/src/mesh/models/scene_range.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:flutter_mesh/src/mesh/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'provisioner.freezed.dart';
part 'provisioner.g.dart';

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

  factory Provisioner.fromJson(Map<String, dynamic> json) =>
      _$ProvisionerFromJson(json);
}
