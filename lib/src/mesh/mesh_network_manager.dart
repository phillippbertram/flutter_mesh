import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

import 'layers/network_manager.dart';

// STATUS: IN PROGRESS

// TODO: implements NetworkParametersProvider
// @see https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/MeshNetworkManager.swift
class MeshNetworkManager with BearerDataDelegate {
  MeshNetworkManager() : _meshData = MeshData(meshNetwork: null);

  MeshData _meshData;
  MeshNetwork? get meshNetwork => _meshData.meshNetwork;

  NetworkManager? _networkManager;

  // TODO: Storage storage;

  // TODO: ProxyFilter proxyFilter;

  // NOTE: no WeakReference needed in dart?

  set transmitter(Transmitter? transmitter) {
    _networkManager?.transmitter = transmitter;
  }

  Transmitter? get transmitter {
    return _networkManager?.transmitter;
  }

  // TODO: NetworkParameters networkParameters;

  /// Generates a new Mesh Network configuration with default values.
  ///
  /// This method will override the existing configuration, if such exists.
  /// The mesh network will contain one ``Provisioner`` with the given name
  /// and randomly generated Primary Network Key.
  ///
  /// - parameters:
  ///   - name:            The user given network name.
  ///   - provisionerName: The user given local provisioner name.
  Result<MeshNetwork> createNewMeshNetwork({
    required String name,
    required Provisioner provisioner,
  }) {
    final network = MeshNetwork(meshName: name);

    // Add a new default provisioner.
    final res = network.addProvisioner(provisioner);
    if (res.isError) {
      return Result.error(res.asError!.error);
    }

    _meshData = MeshData(
      meshNetwork: network,
    );

    _networkManager = NetworkManager.fromMeshNetworkManager(this);

    return Result.value(network);
  }

  Result<void> save() {
    logger.f("MISSING IMPLEMENTATION: save");
    // TODO:

    // final meshJson = jsonEncode(_meshData);

    return Result.value(null);
  }

  /// An array of Elements of the local Node.
  ///
  /// Use this property if you want to extend the capabilities of the local
  /// Node with additional Elements and Models. For example, you may add an
  /// additional Element with Generic On/Off Client Model if you support this
  /// feature in your app. Make sure there is enough addresses for all the
  /// Elements created. If a collision is found, the colliding Elements will
  /// be ignored.
  ///
  /// The mandatory Models (Configuration Server and Client and Health Server
  /// and Client) will be added automatically to the Primary Element,
  /// and should not be added explicitly.
  ///
  /// The mesh network must be created or loaded before setting this field,
  /// otherwise it has no effect.
  ///
  /// - important: This property has to be set even if no custom Models are
  ///              defined as the set operation initializes the mandatory Models.
  ///              It can be set to an empty array.
  List<MeshElement> get localElements => meshNetwork?.localElements ?? const [];
  void setLocalElements(List<MeshElement> elements) {
    meshNetwork?.setLocalElements(elements);

    // TODO:
    logger.f(
        "MISSING IMPLEMENTATION: setLocalElements -> reinitializePublishers");
    // networkManager?.accessLayer.reinitializePublishers();
  }

  // BearerDataDelegate

  @override
  void bearerDidDeliverData(Data data, PduType type) {
    _internalBearerDidDeliverData(data, type);
  }

  /// This method should be called whenever a PDU has been received from the mesh
  /// network using any bearer.
  ///
  /// When a complete Mesh Message is received and reassembled, the delegate's
  /// ``MeshNetworkDelegate/meshNetworkManager(_:didReceiveMessage:sentFrom:to:)``
  /// will be called.
  ///
  /// For easier integration with ``GattBearer``, instead of calling this method,
  /// set the manager as Bearer's ``Bearer/dataDelegate``.
  ///
  /// - parameters:
  ///   - data: The PDU received.
  ///   - type: The PDU type.
  void _internalBearerDidDeliverData(Data data, PduType type) {
    if (_networkManager == null) {
      return;
    }

    // TODO: _networkManager.handle(incomingPdu: data, ofType: type);
  }
}

extension MeshNetworkManagerProvisioning on MeshNetworkManager {
  /// This method returns the ``ProvisioningManager`` that can be used
  /// to provision the given device.
  ///
  /// - parameter unprovisionedDevice: The device to be added to mesh network.
  /// - parameter bearer: The Provisioning Bearer to be used for sending
  ///                     provisioning PDUs.
  /// - returns: The Provisioning manager that should be used to continue
  ///            provisioning process after identification.
  /// - throws: This method throws when the mesh network has not been created,
  ///           or a Node or a Provisioner with the same UUID already exist in the network.
  Result<ProvisioningManager> provisionManager({
    required UnprovisionedDevice unprovisionedDevice,
    required ProvisioningBearer bearer,
  }) {
    if (meshNetwork == null) {
      return Result.error("Mesh network has not been created");
    }

    final manager = ProvisioningManager.forUnprovisionedDevice(
      unprovisionedDevice: unprovisionedDevice,
      bearer: bearer,
      meshNetwork: meshNetwork!,
    );
    return Result.value(manager);
  }
}

extension MeshNetworkManagerMessaging on MeshNetworkManager {
  /// Sends a Configuration Message to the primary Element on the given ``Node``.
  ///
  /// An appropriate callback of the ``MeshNetworkDelegate`` will be called when
  /// the message has been sent successfully or a problem occurred.
  ///
  /// - parameters:
  ///   - message:    The message to be sent.
  ///   - node:       The destination Node.
  ///   - initialTtl: The initial TTL (Time To Live) value of the message.
  ///                 If `nil`, the default Node TTL will be used.
  /// - throws: This method throws when the mesh network has not been created,
  ///           the local Node does not have configuration capabilities
  ///           (no Unicast Address assigned), or the destination address
  ///           is not a Unicast Address or it belongs to an unknown Node.
  ///           Error ``AccessError/cannotDelete`` is sent when trying to
  ///           delete the last Network Key on the device.
  /// - returns: Message handle that can be used to cancel sending.
  /// TODO: Response Type
  Future<Result<void>> sendConfigMessageToNode(
    AcknowledgedConfigMessage message, {
    required Node node,
    Uint8? initialTtl,
  }) async {
    return sendConfigMessageToDestination(
      message,
      destination: node.primaryUnicastAddress,
      initialTtl: initialTtl,
    );
  }

  /// Sends Configuration Message to the Node with given destination Address.
  ///
  /// The `destination` must be a Unicast Address, otherwise the method
  /// throws an ``AccessError/invalidDestination`` error.
  ///
  /// An appropriate callback of the ``MeshNetworkDelegate`` will be called when
  /// the message has been sent successfully or a problem occurred.
  ///
  /// - parameters:
  ///   - message:     The message to be sent.
  ///   - destination: The destination Unicast Address.
  ///   - initialTtl:  The initial TTL (Time To Live) value of the message.
  ///                  If `nil`, the default Node TTL will be used.
  /// - throws: This method throws when the mesh network has not been created,
  ///           the local Node does not have configuration capabilities
  ///           (no Unicast Address assigned), or the destination address
  ///           is not a Unicast Address or it belongs to an unknown Node.
  ///           Error ``AccessError/cannotDelete`` is sent when trying to
  ///           delete the last Network Key on the device.
  /// - returns: The response associated with the message.
  /// TODO: Response Type
  Future<Result<void>> sendConfigMessageToDestination(
    AcknowledgedConfigMessage message, {
    required Address destination,
    Uint8? initialTtl, // TODO:
  }) async {
    logger.d("MeshNetworkManager.sendConfigMessageToDestination: ${{
      "message": message,
      "destination": destination,
      "initialTtl": initialTtl,
    }}");
    // TODO:
    logger.f(
        "INCOMPLETE IMPLEMENTATION: MeshNetworkManager.sendConfigMessageToDestination");

    if (_networkManager == null) {
      return Result.error("No network manager available");
    }
    if (meshNetwork == null) {
      return Result.error("Mesh network has not been created");
    }

    final localProvisioner = meshNetwork!.localProvisioner;
    if (localProvisioner == null) {
      return Result.error("Local Provisioner has no Unicast Address assigned");
    }
    final element = localProvisioner.node?.primaryElement;
    if (element == null) {
      return Result.error("Local Provisioner has no primary Element");
    }

    if (!destination.isUnicast) {
      return Result.error(
          "Address: ${destination.asString()} is not a Unicast Address");
    }

    final node = meshNetwork!.nodeWithAddress(destination);
    if (node == null) {
      return Result.error("Unknown destination Node");
    }

    if (node.networkKeys.isEmpty) {
      return Result.error("The target Node does not have Network Key");
    }

    if (node.deviceKey == null) {
      return Result.error("Node's Device Key is unknown");
    }

    // TODO: ConfigNetKeyDelete
    // if (message is ConfigNetKeyDelete) {
    //   if (node.networkKeys.length <= 1) {
    //     return Result.error("Cannot remove last Network Key");
    //   }
    // }

    if (initialTtl != null && initialTtl > 127) {
      return Result.error("TTL value $initialTtl is invalid");
    }

    return await _networkManager!.sendConfigMessageToDestination(
      message,
      fromElement: element,
      destination: destination,
      initialTtl: initialTtl,
    );
  }
}
