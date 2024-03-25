import 'provisioning_capabilities.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningState.swift

sealed class ProvisioningState {
  const ProvisioningState();
}

class ProvisioningStateReady implements ProvisioningState {
  const ProvisioningStateReady();
}

class ProvisioningStateRequestingCapabilities implements ProvisioningState {
  const ProvisioningStateRequestingCapabilities();
}

class ProvisioningStateCapabilitiesReceived implements ProvisioningState {
  const ProvisioningStateCapabilitiesReceived(this.capabilities);

  final ProvisioningCapabilities capabilities;
}

class ProvisioningStateProvisioning implements ProvisioningState {
  const ProvisioningStateProvisioning();
}

class ProvisioningStateComplete implements ProvisioningState {
  const ProvisioningStateComplete();
}

class ProvisioningStateFailed implements ProvisioningState {
  const ProvisioningStateFailed(this.error);

  final Object? error;
}
