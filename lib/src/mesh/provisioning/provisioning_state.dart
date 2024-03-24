import 'package:freezed_annotation/freezed_annotation.dart';

import 'provisioning_capabilities.dart';

part 'provisioning_state.freezed.dart';
// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningState.swift

@freezed
sealed class ProvisioningState with _$ProvisioningState {
  const factory ProvisioningState.ready() = ProvisioningStateReady;
  const factory ProvisioningState.requestingCapabilities() =
      ProvisioningStateRequestingCapabilities;
  const factory ProvisioningState.capabilitiesReceived(
          ProvisioningCapabilities capabilities) =
      ProvisioningStateCapabilitiesReceived;
  const factory ProvisioningState.provisioning() =
      ProvisioningStateProvisioning;
  const factory ProvisioningState.complete() = ProvisioningStateComplete;
  const factory ProvisioningState.failed(Object? error) =
      ProvisioningStateFailed;
}
