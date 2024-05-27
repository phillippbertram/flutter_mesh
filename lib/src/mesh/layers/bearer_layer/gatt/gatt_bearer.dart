import 'package:flutter_mesh/src/mesh/mesh.dart';

import 'base_pb_gatt_proxy_bearer.dart';

/// The GATT bearer is responsible for sending and receiving mesh messages
/// to and from the GATT Proxy Node.
class GattBearer extends BaseGattProxyBearer<MeshProxyService>
    with ProvisioningBearer {
  GattBearer.fromPeripheral({
    required basePeripheral,
  }) : super.fromPeripheral(MeshProxyService(), basePeripheral);

  @override
  List<PduType> get supportedPduTypes => [
        PduType.networkPdu,
        PduType.proxyConfiguration,
        PduType.meshBeacon,
      ];
}
