// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningManager.swift

import 'package:async/async.dart';
import 'package:dart_mesh/src/mesh/mesh.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningManager.swift

/// The manager responsible for provisioning a new device into the mesh network.
///
/// To create an instance of a `ProvisioningManager` use ``MeshNetworkManager/provision(unprovisionedDevice:over:)``.
///
/// Provisioning is initiated by calling ``identify(andAttractFor:)``. This method will make the
/// provisioned device to blink, make sound or attract in any supported way, so that the user could
/// verify which device is being provisioned. The target device will return ``ProvisioningCapabilities``,
/// returned to ``delegate`` as ``ProvisioningState/capabilitiesReceived(_:)``.
///
/// User needs to set the ``unicastAddress`` (by default set to ``suggestedUnicastAddress``), ``networkKey``
/// and call ``provision(usingAlgorithm:publicKey:authenticationMethod:)``. If user interaction is required
/// during provisioning process corresponding delegate callbacks will be invoked.
///
/// The provisioning is completed when ``ProvisioningState/complete`` state is returned.
class ProvisioningManager {
  ProvisioningManager._({
    required this.unprovisionedDevice,
    required this.bearer,
    required this.meshNetwork,
  });

  factory ProvisioningManager.forUnprovisionedDevice({
    required UnprovisionedDevice unprovisionedDevice,
    required ProvisioningBearer bearer,
    required MeshNetwork meshNetwork,
  }) {
    return ProvisioningManager._(
      unprovisionedDevice: unprovisionedDevice,
      bearer: bearer,
      meshNetwork: meshNetwork,
    );
  }

  final UnprovisionedDevice unprovisionedDevice;
  final ProvisioningBearer bearer;
  final MeshNetwork meshNetwork;

  Future<Result<void>> identify(Duration attentionTimer) async {
    if (!bearer.supports(PduType.provisioningPdu)) {
      return Result.error("Bearer does not support Provisioning PDUs");
    }

    // TODO:
    // Has the provisioning been restarted?
    // if case .failed = state {
    //     reset()
    // }

    // TODO:
    // Is the Provisioner Manager in the right state?
    // guard case .ready = state else {
    //     logger?.e(.provisioning, "Provisioning manager is in invalid state")
    //     throw ProvisioningError.invalidState
    // }

    if (!bearer.isOpen) {
      return Result.error("Bearer is not open");
    }

    // TODO:
    // Assign bearer delegate to self. If one was already set, events
    // will be forwarded. Don't modify Bearer delegate from now on.
    // bearerDelegate = bearer.delegate
    // bearerDataDelegate = bearer.dataDelegate
    // bearer.delegate = self
    // bearer.dataDelegate = self

    return Result.value(null);
  }
}
