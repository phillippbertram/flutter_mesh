// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningManager.swift

import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/provisioning/provisioning_capabilities.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:rxdart/rxdart.dart';

import 'algorithms.dart';
import 'provisioning_data.dart';

// TODO: implement ChangeNotifier?

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningManager.swift

/// @see https://www.bluetooth.com/blog/provisioning-a-bluetooth-mesh-network-part-1/
///
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
/// The provisioning is completed when `ProvisioningState/complete` state is returned.
class ProvisioningManager implements BearerDataDelegate {
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
    final manager = ProvisioningManager._(
      unprovisionedDevice: unprovisionedDevice,
      bearer: bearer,
      meshNetwork: meshNetwork,
    );
    manager.networkKey = meshNetwork.networkKeys.firstOrNull;
    manager.deviceName = unprovisionedDevice.name;
    return manager;
  }

  final UnprovisionedDevice unprovisionedDevice;
  final ProvisioningBearer bearer;
  final MeshNetwork meshNetwork;

  ProvisioningState get state => _stateSubject.value;
  Stream<ProvisioningState> get stateStream => _stateSubject.stream;
  final _stateSubject =
      BehaviorSubject<ProvisioningState>.seeded(const ProvisioningStateReady());

  AuthenticationMethod? _authenticationMethod;
  ProvisioningData? _provisioningData;

  /// The original Bearer delegate. It will be notified on bearer state updates.
  // NOTE: no WeakReference needed in dart?
  // TODO: BearerDelegate? _bearerDelegate;
  BearerDataDelegate? _bearerDataDelegate;

  // MARK: - Public properties

  /// The provisioning capabilities of the device. This information
  /// is retrieved from the remote device during identification process.
  ProvisioningCapabilities? get provisioningCapabilities =>
      _provisioningCapabilities;
  ProvisioningCapabilities? _provisioningCapabilities;

  /// The name of the device that will be used as node name
  String? deviceName;

  /// The Unicast Address that will be assigned to the device.
  /// After device capabilities are received, the address is automatically set to
  /// the first available unicast address from Provisioner's range.
  Address? unicastAddress;

  /// Automatically assigned Unicast Address. This is the first available
  /// Unicast Address from the Provisioner's range with enough free following
  /// addresses to be assigned to the device. This value is available after
  /// the Provisioning Capabilities have been received and such address was found.
  Address? get suggestedUnicastAddress => _suggestedUnicastAddress;
  Address? _suggestedUnicastAddress;

  /// The Network Key to be sent to the device during provisioning.
  /// Setting this property is mandatory before calling
  /// ``provision(usingAlgorithm:publicKey:authenticationMethod:)``.
  NetworkKey? networkKey;

  /// Returns whether the Unprovisioned Device can be provisioned using this
  /// Provisioner Manager.
  ///
  /// If ``identify(andAttractFor:)`` has not been called, and the Provisioning
  /// Capabilities are not known, this property returns `nil`.
  ///
  /// - returns: Whether the device can be provisioned by this manager, that is
  ///            whether the manager supports at least one of the provisioning
  ///            algorithms supported by the device.
  bool? get isDeviceSupported {
    if (_provisioningCapabilities == null) {
      return null;
    }
    // TODO: test this
    final supportedAlgorithms = Algorithms.supportedAlgorithms;
    return supportedAlgorithms
        .intersection(_provisioningCapabilities!.algorithms.algorithms)
        .isEmpty;
  }

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
    logger.d(
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
    // bearer.delegate = self
    if (bearer.dataDelegate != null) {
      _bearerDataDelegate = bearer.dataDelegate!;
    }
    bearer.setDataDelegate(this);

    // Initialize provisioning data.
    _provisioningData = ProvisioningData();

    final invite = ProvisioningRequestInvite(
      attentionTimer: attentionTimer.inSeconds,
    );
    logger.d("ProvisioningManager: Sending $invite}");
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
  Future<Result<void>> provision({
    required Algorithm algorithm,
    required PublicKey publicKey,
    required AuthenticationMethod authenticationMethod,
  }) async {
    logger.t(
      "start provisioning with algorithm $algorithm, public key $publicKey, and authentication method $authenticationMethod",
    );

    // are we in the right state?
    if (state is! ProvisioningStateCapabilitiesReceived) {
      logger.e("Not in capabilities received state");
      return Result.error("Invalid state");
    }
    if (_provisioningCapabilities == null) {
      logger.e("Provisioning capabilities not available");
      return Result.error("Provisioning capabilities not available");
    }

    // can the unprovisioned device be provisioned?
    if (isDeviceSupported == false) {
      logger.e("Device not supported");
      return Result.error("Device not supported");
    }

    // was the unicast address specified?
    unicastAddress ??= _suggestedUnicastAddress;
    if (unicastAddress == null) {
      logger.d(
          "Unicast address not specified, setting to suggested: ${suggestedUnicastAddress?.value.toHex()}");
      return Result.error("Unicast address not specified");
    }

    // Ensure the Network Key is set.
    if (networkKey == null) {
      logger.e("Network Key not set");
      return Result.error("Network Key not set");
    }

    // is the bearer open?
    if (!bearer.isOpen) {
      logger.e("Bearer is not open");
      return Result.error("Bearer is closed");
    }

    // Try generating Private and Public Keys. This may fail if the given
    // algorithm is not supported.
    final keysKes = await _provisioningData!.generateKeys(algorithm: algorithm);
    if (keysKes.isError) {
      logger.e("Failed to generate keys: ${keysKes.asError!.error}");
      return Result.error("Failed to generate keys: ${keysKes.asError!.error}");
    }

    // If the device's Public Key was obtained OOB, we are now ready to
    // calculate the device's Shared Secret.
    switch (publicKey) {
      // The OOB Public Key is for sure different than the one randomly generated
      // moment ago. Even if not, it truly has been randomly generated, so it's not
      // an attack.
      case OobPublicKey(key: final key):
        final res =
            await _provisioningData!.provisionerDidObtainDevicePublicKey(
          key,
          oob: true,
        );
        if (res.isError) {
          logger.e("Failed to obtain OOB Public Key: ${res.asError!.error}");
          _stateSubject.add(
            const ProvisioningStateFailed(
                error: "Failed to obtain OOB Public Key"),
          );
        }
        break;

      default:
        break; // No OOB Public Key
    }

    // send provisioning start request
    _stateSubject.add(const ProvisioningState.provisioning());
    _provisioningData!.prepare(
      network: meshNetwork,
      netKey: networkKey!,
      unicastAddress: unicastAddress!,
    );
    final startRequest = ProvisioningRequest.start(
      algorithm: algorithm,
      publicKey: publicKey.method,
      authenticationMethod: authenticationMethod,
    );
    logger.d("Sending $startRequest");
    final reqStartRes = await _sendProvisioningRequest(
      startRequest,
      accumulatedData: _provisioningData,
    );
    if (reqStartRes.isError) {
      final errMess =
          "Failed to send provisioning start request: ${reqStartRes.asError!.error}";
      logger.e(errMess);
      return Result.error(errMess);
    }
    _authenticationMethod = authenticationMethod;

    // Send the Public Key of the Provisioner.
    final provisionerPublicKey = ProvisioningRequest.publicKey(
      key: _provisioningData!.provisionerPublicKey!,
    );
    logger.d("Sending $provisionerPublicKey");
    final reqPubKeyRes = await _sendProvisioningRequest(
      provisionerPublicKey,
      accumulatedData: _provisioningData,
    );
    if (reqPubKeyRes.isError) {
      logger.e(
          "Failed to send Provisioner's Public Key: ${reqPubKeyRes.asError!.error}");
      return Result.error(
          "Failed to send Provisioner's Public Key: ${reqPubKeyRes.asError!.error}");
    }

    // If the device's Public Key was obtained OOB, we are now ready to
    // authenticate.
    switch (publicKey) {
      case OobPublicKey(key: final key):
        _provisioningData!.accumulate(key);
        _obtainAuthValue();
        break;
      default: // No OOB Public Key
        break;
    }

    return Result.value(null);
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

    final pdu = request.pdu;

    // The first byte is the type. We only accumulate payload
    accumulatedData.accumulate(pdu.data.dropFirst());

    // send the request.
    return bearer.sendData(data: pdu.data, type: PduType.provisioningPdu);
  }

  // MARK: - MISC

  void _reset() {
    _authenticationMethod = null;
    _provisioningCapabilities = null;
    _provisioningData = null;
    _stateSubject.add(const ProvisioningStateReady());
  }

  /// This method asks the user to provide a OOB value based on the
  /// authentication method specified in the provisioning process.
  ///
  /// For ``AuthenticationMethod/noOob`` case, the value is automatically
  /// set to 0s.
  ///
  /// This method will call `authValueReceived(:)` when the value
  /// has been obtained.
  void _obtainAuthValue() {
    logger.d("Obtain Auth Value for $_authenticationMethod");
    // The AuthValue is 16 or 32 bytes long, depending on the selected algorithm.
    final sizeInBytes = _provisioningData!.algorithm!.lengthInBits >> 3;

    switch (_authenticationMethod!) {
      case NoOob():
        logger.d("No OOB Auth Value");
        final authValue = Data.from(List.filled(sizeInBytes, 0));
        _authValueReceived(authValue);
        break;

      case StaticOob(value: final value):
        // TODO:
        logger.f("IMPLEMENTATION MISSING - Static OOB Auth Value: $value");
        break;

      case OutputOob():
        // TODO:
        logger.f("IMPLEMENTATION MISSING - Output OOB Auth");
        break;

      case InputOob():
        // TODO:
        logger.f("IMPLEMENTATION MISSING - Input OOB Auth");
        break;
    }
  }

  /// This method should be called when the OOB value has been received
  /// and Auth Value has been calculated.
  ///
  /// It computes and sends the Provisioner Confirmation to the device.
  ///
  /// - parameter value: The 16 or 32 byte long Auth Value, depending on the
  ///                    selected algorithm.
  Future<void> _authValueReceived(Data authValue) async {
    logger.d("Auth Value received: 0x${authValue.toHex()}");

    // Accumulate the Auth Value.
    _provisioningData!.provisionerDidObtainAuthValue(authValue);

    // Calculate the Confirmation.
    final confirmation = ProvisioningRequest.confirmation(
      data: _provisioningData!.provisionerConfirmation,
    );

    logger.d("Sending $confirmation");
    final res = await _sendProvisioningRequest(confirmation);

    if (res.isError) {
      logger.e(
          "Failed to send Provisioner's Confirmation: ${res.asError!.error}");
      _stateSubject.add(
        const ProvisioningState.failed(
            error: "Failed to send Provisioner's Confirmation"),
      );
    }
  }

  // MARK: - BearerDataDelegate

  @override
  Future<void> bearerDidDeliverData(Data data, PduType type) async {
    logger.d(
      "ProvisioningManager: bearerDidDeliverData. Data: 0x${data.toHex()}, type: ${type.value}",
    );
    _bearerDataDelegate?.bearerDidDeliverData(data, type);

    // TODO: implement bearerDidDeliverData
    final provisioningPdu = ProvisioningPdu(data);
    print("<<< provisioningPdu: ${provisioningPdu.type?.value}");
    final responseRes = ProvisioningResponse.fromPdu(provisioningPdu);
    final response = responseRes.asValue?.value;
    if (response == null) {
      logger.d(
          "ProvisioningManager: Invalid response: ${responseRes.asError!.error}");
      return;
    }

    // TODO:
    //  guard response.isValid(forAlgorithm: provisioningData.algorithm) else {
    //         state = .fail(ProvisioningError.invalidPdu)
    //         return
    //     }
    //     logger?.v(.provisioning, "\(response) received")

    logger.d(
      "ProvisioningManager: handling received response: $response in state $state",
    );

    switch ((state, response)) {
      // Provisioning Capabilities have been received.
      case (
          ProvisioningStateRequestingCapabilities _,
          ProvisioningResponseCapabilities response
        ):
        logger.t("Handling Response Capabilities: $response");

        _provisioningCapabilities = response.capabilities;
        _provisioningData?.accumulate(data.dropFirst());

        // Calculate the Unicast Address automatically based on the
        // elements count.
        final localProvisioner = meshNetwork.localProvisioner;
        if (unicastAddress == null && localProvisioner != null) {
          final count = response.capabilities.numberOfElements;
          unicastAddress = meshNetwork.nextAvailableUnicastAddress(
            elementsCount: count,
            provisioner: localProvisioner,
          );
          logger.t("Calculated unicast address: $unicastAddress");
          _suggestedUnicastAddress = unicastAddress;
        } else {
          logger.w("Uni-cast address already set or local provisioner missing");
        }

        // TODO: set state ProvisioningStateCapabilitiesReceived in else case below?

        _stateSubject.add(ProvisioningState.capabilitiesReceived(
          capabilities: response.capabilities,
        ));
        if (unicastAddress == null) {
          _stateSubject.add(
              const ProvisioningState.failed(error: "No address available"));
        }

        break;

      // Device Public Key has been received.
      case (
          ProvisioningStateProvisioning _,
          ProvisioningResponsePublicKey response
        ):
        logger.t("Handling response PublicKey: $response");

        // Errata E16350 added an extra validation whether the received Public Key
        // is different than Provisioner's one.
        if (response.key == _provisioningData?.provisionerPublicKey) {
          logger.e("Invalid Public Key: same as Provisioner's");

          _stateSubject
              .add(const ProvisioningStateFailed(error: "Invalid Public Key"));
          return;
        }

        _provisioningData!.accumulate(data.dropFirst());
        final pubKeyRes =
            await _provisioningData!.provisionerDidObtainDevicePublicKey(
          response.key,
          oob: false,
        );
        if (pubKeyRes.isError) {
          logger.e(
              "Failed to obtain device Public Key: ${pubKeyRes.asError!.error}");
          _stateSubject.add(
            const ProvisioningState.failed(
                error: "Failed to obtain device Public Key"),
          );
          return;
        }
        _obtainAuthValue();

        // TODO:

        break;

      // The user has performed the Input Action on the device.
      case (
          ProvisioningStateProvisioning _,
          ProvisioningResponseInputComplete response
        ):
        // TODO:
        logger.f(
            "ProvisioningManager: IMPLEMENTATION MISSING - Response InputComplete: $response");

        break;

      // The Provisioning Confirmation value has been received.
      case (
          ProvisioningStateProvisioning _,
          ProvisioningResponseConfirmation response
        ):
        logger.t("Handling Response Confirmation: $response");
        // Errata E16350 added an extra validation whether the received Confirmation
        // is different than Provisioner's one.
        if (response.key == _provisioningData!.provisionerConfirmation) {
          logger.e("Confirmation failed");
          _stateSubject.add(
            const ProvisioningState.failed(error: "Confirmation failed"),
          );
          return;
        }

        _provisioningData!.provisionerDidObtainDeviceConfirmation(response.key);
        final request = ProvisioningRequest.random(
          data: _provisioningData!.provisionerRandom!,
        );
        logger.d("Sending $request");
        final result = await _sendProvisioningRequest(request);
        if (result.isError) {
          logger.e(
              "Failed to send Provisioner's Random: ${result.asError!.error}");
          _stateSubject.add(
            const ProvisioningState.failed(
                error: "Failed to send Provisioner's Random"),
          );
        }

        break;

      // The device Random value has been received. We may now authenticate the device.
      case (
          ProvisioningStateProvisioning _,
          ProvisioningResponseRandom response
        ):
        // TODO:
        logger.f(
            "ProvisioningManager: IMPLEMENTATION MISSING - Response Random: $response");

        _provisioningData!.provisionerDidObtainDeviceRandom(response.key);
        final confirmed = _provisioningData!.validateConfirmation();
        if (!confirmed) {
          logger.e("Confirmation failed");
          _stateSubject.add(
            const ProvisioningState.failed(error: "Confirmation failed"),
          );
          return;
        }

        final request = ProvisioningRequest.data(
          encryptedDataWithMic:
              _provisioningData!.encryptedProvisioningDataWithMic,
        );
        logger.d("Sending $request");

        final result = await _sendProvisioningRequest(request);
        if (result.isError) {
          logger
              .e("Failed to send Provisioner's Data: ${result.asError!.error}");
          _stateSubject.add(
            const ProvisioningState.failed(
                error: "Failed to send Provisioner's Data"),
          );
        }

        break;

      // The provisioning process is complete.
      case (
          ProvisioningStateProvisioning _,
          ProvisioningResponseComplete response
        ):
        // TODO:
        logger.t("Handling Provisioning complete: $response");

        final security = _provisioningData!.security;
        final deviceKey = _provisioningData!.deviceKey;
        final numberOfElements = _provisioningCapabilities!.numberOfElements;
        final networkKey = _provisioningData!.networkKey;

        logger.f("IMPLEMENTATION MISSING - Create node and add to network");
        // ignore: unnecessary_this
        final unprovisionedDevice = this.unprovisionedDevice.copyWith(
              name: deviceName,
            );
        final node = Node.forUnprovisionedDevice(
          unprovisionedDevice,
          networkKey: networkKey!,
          address: unicastAddress!,
          deviceKey: deviceKey!,
          security: security,
          elementCount: numberOfElements,
        );
        final addRes = meshNetwork.addNode(node);
        if (addRes.isError) {
          logger.e("Failed to add node to network: ${addRes.asError!.error}");
          _stateSubject.add(
            const ProvisioningState.failed(
                error: "Failed to add node to network"),
          );
          return;
        }

        _stateSubject.add(const ProvisioningState.complete());
        break;

      // The provisioned device sent an error.
      case (_, ProvisioningResponseFailed response):
        logger.e("Provisioning failed: ${response.error}");
        _stateSubject.add(ProvisioningState.failed(error: response.error));
        break;

      default:
        logger.e(
            "ProvisioningManager: Unexpected response: $response for state $state");
        _stateSubject
            .add(const ProvisioningState.failed(error: "Invalid state"));

        break;
    }
  }
}
