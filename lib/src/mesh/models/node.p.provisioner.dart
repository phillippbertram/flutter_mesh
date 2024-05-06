part of 'node.dart';

extension NodeProvisionerX on Node {
  /// Returns weather Composition Data has been applied to the Node.
  bool get isCompositionDataReceived {
    return companyIdentifier != null;
  }

  /// Returns whether the Node belongs to one of the Provisioners
  /// of the mesh network.
  bool get isProvisioner {
    return meshNetwork?.containsProvisionerWithUuid(uuid) ?? false;
  }
}
