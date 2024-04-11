import 'package:flutter_mesh/src/mesh/models/mesh_network.dart';

// STATUS: TODO

//TODO: Serialization + Equatable

/// The Mesh Network configuration saved internally.
/// It contains the Mesh Network and additional data that
/// are not in the JSON schema, but are used by in the app.
class MeshData {
  MeshData({required this.meshNetwork});

  final MeshNetwork? meshNetwork;
}
