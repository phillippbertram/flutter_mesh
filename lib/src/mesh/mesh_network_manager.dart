import 'package:async/async.dart';
import 'package:dart_mesh/src/mesh/mesh.dart';

import 'layers/network_manager.dart';

// STATUS: IN PROGRESS

// TODO: implements NetworkParametersProvider
// @see https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/MeshNetworkManager.swift
class MeshNetworkManager with BearerDataDelegate {
  MeshNetworkManager() : _meshData = MeshData(meshNetwork: null);

  MeshData _meshData;
  MeshNetwork? get meshNetwork => _meshData.meshNetwork;

  NetworkManager? _networkManager;

  // TODO: Storage storage;

  // TODO: ProxyFilter proxyFilter;

  WeakReference<Transmitter>? _transmitter;
  Transmitter? get transmitter => _transmitter?.target;
  void setTransmitter(Transmitter transmitter) {
    _transmitter = WeakReference(transmitter);
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
    // TODO:
    final network = MeshNetwork(meshName: name);

    final res = network.addProvisioner(provisioner);
    if (res.isError) {
      return Result.error(res.asError!.error);
    }

    _meshData = MeshData(
      meshNetwork: network,
    );
    return Result.value(network);
  }

  Result<void> save() {
    // TODO:
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
  List<Element> get localElements =>
      []; // TODO: meshNetwork?.localElements ?? [];
  void setLocalElements(List<Element> elements) {
    // TODO:
    throw UnimplementedError("setLocalElements");

    // meshNetwork?.localElements = elements;
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
