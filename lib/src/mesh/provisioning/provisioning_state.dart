import 'package:freezed_annotation/freezed_annotation.dart';

import 'provisioning_capabilities.dart';

part 'provisioning_state.freezed.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Provisioning/ProvisioningState.swift

// TODO: use the described 5 phases from the documentation?
// 1. Beaconing
// 2. Invitation
// 3. Exchange public keys
// 4. Authentication
// 5. Distribution of provisioning data

@freezed
sealed class ProvisioningState with _$ProvisioningState {
  /// The device is ready to start provisioning.
  const factory ProvisioningState.ready() = ProvisioningStateReady;

  /// The device is requesting capabilities from the Unprovisioned Device.
  const factory ProvisioningState.requestingCapabilities() =
      ProvisioningStateRequestingCapabilities;

  /// The device has received the capabilities from the Unprovisioned Device.
  const factory ProvisioningState.capabilitiesReceived({
    required ProvisioningCapabilities capabilities,
  }) = ProvisioningStateCapabilitiesReceived;

  /// The device is provisioning the Unprovisioned Device.
  const factory ProvisioningState.provisioning() =
      ProvisioningStateProvisioning;

  /// The device has completed provisioning the Unprovisioned Device.
  const factory ProvisioningState.complete() = ProvisioningStateComplete;

  /// The device has failed to provision the Unprovisioned Device.
  const factory ProvisioningState.failed({
    Object? error,
  }) = ProvisioningStateFailed;
}
