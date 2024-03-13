import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesh_network.freezed.dart';
part 'mesh_network.g.dart';

@freezed
class MeshNetwork with _$MeshNetwork {
  const factory MeshNetwork({
    required String uuid, // TODO: UUID type
    required String meshName,
  }) = _MeshNetwork;

  factory MeshNetwork.fromJson(Map<String, dynamic> json) =>
      _$MeshNetworkFromJson(json);
}
