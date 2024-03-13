import 'package:dart_mesh/src/mesh/models/mesh_network.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesh_data.freezed.dart';
part 'mesh_data.g.dart';

@freezed
class MeshData with _$MeshData {
  const factory MeshData({
    MeshNetwork? meshNetwork,
  }) = _MeshData;

  factory MeshData.fromJson(Map<String, dynamic> json) =>
      _$MeshDataFromJson(json);
}
