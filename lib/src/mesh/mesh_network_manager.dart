import 'package:dart_mesh/src/mesh/models/mesh_data.dart';
import 'package:dart_mesh/src/mesh/models/mesh_network.dart';
import 'package:dart_mesh/src/mesh/models/provisioner.dart';

import 'package:uuid/uuid.dart';

// ================
// TODO: create own UUID type?
final _uuid = Uuid();
String _generateUuid() => _uuid.v4().replaceAll("-", "");
// ================

class MeshNetworkManager {
  MeshNetworkManager() : _meshData = const MeshData(meshNetwork: null);

  MeshData _meshData;

  MeshNetwork createMeshNetwork({
    required String name,
    required String provisionerName,
  }) {
    // TODO: add provisioner
    var network = MeshNetwork(meshName: name, uuid: _generateUuid());

    final provisioner =
        Provisioner(uuid: _generateUuid(), name: provisionerName);
    try {
      network = network.addProvisioner(provisioner);
    } catch (e) {
      print(e);
    }

    _meshData = _meshData.copyWith(
      meshNetwork: network,
    );
    return network;
  }
}
