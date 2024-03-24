import 'package:dart_mesh/src/mesh/types.dart';

/// A base protocol for mesh service objects.
abstract class MeshService {
  /// Service UUID.
  static UUID get uuid => throw UnimplementedError();

  /// Data In characteristic UUID.
  static UUID get dataInUuid => throw UnimplementedError();

  /// Data Out characteristic UUID.
  static UUID get dataOutUuid => throw UnimplementedError();

  /// Returns whether the mesh service matches given Core Bluetooth service object.
  // TODO: static bool matches(service: CBService) -> Bool
}

/// A structore defining Mesh Proxy service, which shall be present on
/// provisioned Nodes.
///
/// The Mesh Proxy service is used to send mesh messages over GATT.
class MeshProxyService extends MeshService {
  static UUID get uuid => "1828";
  static UUID get dataInUuid => "2ADD";
  static UUID get dataOutUuid => "2ADE";

  // TODO:
  // public static func matches(_ service: CBService) -> Bool {
  //     return service.isMeshProxyService
  // }

  MeshProxyService._();
}

class MeshProvisioningService extends MeshService {
  static UUID get uuid => "1827";
  static UUID get dataInUuid => "2ADB";
  static UUID get dataOutUuid => "2ADC";

  // TODO:
  // public static func matches(_ service: CBService) -> Bool {
  //     return service.isMeshProxyService
  // }

  MeshProvisioningService._();
}
