import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import 'base_gatt_proxy_bearer.dart';

/// The GATT bearer is responsible for sending and receiving mesh messages
/// to and from the GATT Proxy Node.
class GattBearer extends BaseGattProxyBearer<MeshProxyService>
    with ProvisioningBearer {
  GattBearer.targetPeripheral(BluetoothDevice basePeripheral)
      : super.fromPeripheral(MeshProxyService(), basePeripheral);

  @override
  List<PduType> get supportedPduTypes => [
        PduType.networkPdu,
        PduType.proxyConfiguration,
        PduType.meshBeacon,
      ];
}
