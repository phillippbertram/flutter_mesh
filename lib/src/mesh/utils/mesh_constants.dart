import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Utils/MeshConstants.swift

/// A base protocol for mesh service objects.
abstract class MeshService {
  /// Service UUID.
  UUID get uuid;

  /// Data In characteristic UUID.
  UUID get dataInUuid;

  /// Data Out characteristic UUID.
  UUID get dataOutUuid;

  /// Returns whether the mesh service matches given Core Bluetooth service object.
  bool matches(BluetoothService service);
}

/// A structore defining Mesh Proxy service, which shall be present on
/// provisioned Nodes.
///
/// The Mesh Proxy service is used to send mesh messages over GATT.
class MeshProxyService implements MeshService {
  static final MeshProxyService _instance = MeshProxyService._internal();

  factory MeshProxyService() {
    return _instance;
  }

  MeshProxyService._internal();

  @override
  String get uuid => "1828";

  @override
  String get dataInUuid => "2ADD";

  @override
  String get dataOutUuid => "2ADE";

  @override
  bool matches(BluetoothService service) {
    return service.isMeshProxyService;
  }
}

class MeshProvisioningService extends MeshService {
  static final MeshProvisioningService _instance =
      MeshProvisioningService._internal();

  factory MeshProvisioningService() {
    return _instance;
  }

  MeshProvisioningService._internal();

  @override
  String get uuid => "1827";

  @override
  String get dataInUuid => "2ADB";

  @override
  String get dataOutUuid => "2ADC";

  @override
  bool matches(BluetoothService service) {
    return service.isMeshProvisioningService;
  }
}

extension BluetoothServiceExtension on BluetoothService {
  bool get isMeshProxyService {
    return uuid == Guid(MeshProxyService().uuid);
  }

  bool get isMeshProvisioningService {
    return uuid == Guid(MeshProvisioningService().uuid);
  }
}
