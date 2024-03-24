// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Bearer/GATT/PBGattBearer.swift

import 'package:dart_mesh/src/mesh/mesh.dart';
import 'package:dart_mesh/src/mesh/utils/utils.dart';

import 'base_pb_gatt_proxy_bearer.dart';

/// The PB GATT bearer is responsible for sending and receiving mesh
/// provisioning messages to and from the GATT Proxy Node.
class PBGattBearer extends BaseGattProxyBearer<MeshProvisioningService>
    with ProvisioningBearer {
  PBGattBearer.fromPeripheral({
    required basePeripheral,
  }) : super.fromPeripheral(MeshProvisioningService(), basePeripheral);

  @override
  List<PduType> get supportedPduTypes => [PduType.provisioningPdu];
}
