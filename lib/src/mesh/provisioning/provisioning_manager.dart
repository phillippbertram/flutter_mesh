// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningManager.swift

import 'package:async/async.dart';
import 'package:dart_mesh/src/mesh/mesh.dart';
import 'package:dart_mesh/src/mesh/provisioning/provisioning_capabilities.dart';
import 'package:dart_mesh/src/mesh/provisioning/provisioning_state.dart';
import 'package:dart_mesh/src/mesh/type_extensions/data.dart';
import 'package:rxdart/rxdart.dart';

import 'algorithms.dart';
import 'provisioning_data.dart';
import 'public_key.dart';

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

  ProvisioningState get state => _stateSubject.value;
  Stream<ProvisioningState> get stateStream => _stateSubject.stream;
  final _stateSubject =
      BehaviorSubject<ProvisioningState>.seeded(const ProvisioningStateReady());

  ProvisioningData? _provisioningData;

  /// The Unicast Address that will be assigned to the device.
  /// After device capabilities are received, the address is automatically set to
  /// the first available unicast address from Provisioner's range.
  // Address? unicastAddress;

  /// This method initializes the provisioning of the device.
  ///
  /// As a result of this method ``ProvisioningDelegate/provisioningState(of:didChangeTo:)``
  /// method will be called with the state ``ProvisioningState/capabilitiesReceived(_:)``.
  /// If the device is supported, ``ProvisioningManager/provision(usingAlgorithm:publicKey:authenticationMethod:)``
  /// shall be called to continue provisioning.
  ///
  /// - parameter attentionTimer: This value determines for how long (in seconds)
  ///                     the device shall remain attracting human's attention by
  ///                     blinking, flashing, buzzing, etc.
  ///                     The value 0 disables Attention Timer.
  /// - throws: A ``ProvisioningError`` can be thrown in case of an error.
  Future<Result<void>> identify({
    required Duration attentionTimer,
  }) async {
    print(
        "ProvisioningManager: Identifying device with attention timer $attentionTimer");

    if (!bearer.supports(PduType.provisioningPdu)) {
      return Result.error("Bearer does not support Provisioning PDUs");
    }

    // Has the provisioning been restarted?
    if (state is ProvisioningStateFailed) {
      _reset();
    }

    if (state is! ProvisioningStateReady) {
      return Result.error("Not in ready state");
    }

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

    // Initialize provisioning data.
    _provisioningData = ProvisioningData();

    final invite = ProvisioningRequestInvite(
      attentionTimer: attentionTimer.inSeconds,
    );
    print("Sending $invite");
    _stateSubject.add(const ProvisioningStateRequestingCapabilities());

    return _sendProvisioningRequest(invite, accumulatedData: _provisioningData);
  }

  /// This method starts the provisioning of the Unprovisioned Device.
  ///
  /// ``identify(andAttractFor:)`` has to be invoked prior to calling this method to receive
  /// the ``ProvisioningCapabilities``, which include information regarding supported algorithms,
  /// public key method and authentication method.
  ///
  /// For the provisioning process to be considered ``Security/secure``, it is required that
  /// the Provisionee's Public Key is provided Out-of-Band using ``PublicKey/oobPublicKey(key:)``.
  /// The Public Key information should be available in the Unprovisioned Device beacon.
  /// If the device does not provide OOB Public Key, ``PublicKey/noOobPublicKey`` shall
  /// be used and the provisioned Node and the Network Key will be considered ``Security/insecure``.
  ///
  /// If a different authentication method than ``AuthenticationMethod/noOob`` is
  /// chosen a ``ProvisioningDelegate/authenticationActionRequired(_:)`` callback
  /// will be called during provisioning to provide the Out-of-Band value in case of
  /// ``AuthenticationMethod/staticOob`` or ``AuthenticationMethod/outputOob(action:size:)``
  /// or display it to the user for providing it on the Provisionee in case of
  /// ``AuthenticationMethod/inputOob(action:size:)``. In the latter case, an additional
  /// ``ProvisioningDelegate/inputComplete()`` callback will be called when user has finished
  /// providing the value.
  ///
  /// - note: Mesh Protocol 1.1 introduced a new, stronger provisioning algorithm
  ///         ``Algorithm/BTM_ECDH_P256_HMAC_SHA256_AES_CCM``. It is recommended for
  ///         devices which support it.
  /// - throws: A ``ProvisioningError`` can be thrown in case of an error.
  void startProvisioning({
    required Algorithm algorithm,
    required PublicKey publicKey,
    required AuthenticationMethod authenticationMethod,
  }) async {
    print(
        "ProvisioningManager: start provisioning with algorithm $algorithm, public key $publicKey, and authentication method $authenticationMethod");
    // TODO:

    _stateSubject.add(
      const ProvisioningStateCapabilitiesReceived(
        ProvisioningCapabilities(
          numberOfElements: 2,
          algorithms: Algorithms.BTM_ECDH_P256_CMAC_AES128_AES_CCM,
          outputOobSize: 1,
          inputOobSize: 1,
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    _stateSubject.add(const ProvisioningStateProvisioning());
    await Future.delayed(const Duration(seconds: 1));
    _stateSubject.add(const ProvisioningStateComplete());
  }

  // MARK: - Sending

  /// This method sends the provisioning request to the device
  /// over the Bearer specified in the init.
  ///
  /// Additionally, it adds the request payload to given inputs.
  /// Inputs are required in device authorization.
  ///
  /// - parameter request: The request to be sent.
  Future<Result<void>> _sendProvisioningRequest(
    ProvisioningRequest request, {
    ProvisioningData? accumulatedData,
  }) async {
    if (accumulatedData == null) {
      return bearer.sendProvisioningRequest(request);
    }

    // The first byte is the type. We only accumulate payload.
    final reqPdu = request.pdu;
    final pdu = reqPdu.data.dropFirst();
    accumulatedData.accumulate(pdu);

    // send the request.
    return bearer.sendData(data: pdu, type: PduType.provisioningPdu);
  }

  // MARK: - misc

  void _reset() {
    // TODO:
    // authenticationMethod = nil
    // provisioningCapabilities = nil
    // provisioningData = nil

    _stateSubject.add(const ProvisioningStateReady());
  }
}
