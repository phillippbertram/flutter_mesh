import 'package:freezed_annotation/freezed_annotation.dart';

import 'provisioning_capabilities.dart';

part 'provisioning_state.freezed.dart';
// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningState.swift

@freezed
sealed class ProvisioningState with _$ProvisioningState {
  const factory ProvisioningState.ready() = _Ready;
  const factory ProvisioningState.requestingCapabilities() =
      _RequestingCapabilities;
  const factory ProvisioningState.capabilitiesReceived(
      ProvisioningCapabilities capabilities) = _CapabilitiesReceived;
  const factory ProvisioningState.provisioning() = _Provisioning;
  const factory ProvisioningState.complete() = _Complete;
  const factory ProvisioningState.failed(Object? error) = _Failed;
}
