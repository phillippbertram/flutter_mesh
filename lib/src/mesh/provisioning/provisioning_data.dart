import '../types.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningData.swift#L33

class ProvisioningData {
  ProvisioningData();

  /// The Confirmation Inputs is built over the provisioning process.
  ///
  /// It is composed of (in that order):
  /// - Provisioning Invite PDU,
  /// - Provisioning Capabilities PDU,
  /// - Provisioning Start PDU,
  /// - Provisioner's Public Key,
  /// - Provisionee's Public Key.
  /// TODO: Data(capacity: 1 + 11 + 5 + 64 + 64)
  final confirmationInputs = Data.from([]);
}

extension ProvisioningDataX on ProvisioningData {
  /// This method adds the given PDU to the Provisioning Inputs.
  /// Provisioning Inputs are used for authenticating the Provisioner
  /// and the Unprovisioned Device.
  ///
  /// This method must be called (in order) for:
  /// - Provisioning Invite,
  /// - Provisioning Capabilities,
  /// - Provisioning Start,
  /// - Provisioner's Public Key,
  /// - Provisionee's Public Key.
  void accumulate(Data data) {
    confirmationInputs.addAll(data);
  }
}
