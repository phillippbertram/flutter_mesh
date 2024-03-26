// from AppDelegate.swift example

import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/network_connection.dart';

// @see https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Example/Source/AppDelegate.swift
class AppNetworkManager {
  AppNetworkManager._() {
    _initializeNetwork();
  }

  // singleton
  static final AppNetworkManager instance = AppNetworkManager._();

  final meshNetworkManager = MeshNetworkManager();
  NetworkConnection? connection;

  void _initializeNetwork() {
    // TODO: set parameters
    // meshNetworkManager.networkParameters = MeshNetworkParameters.basic

    // TODO: set logger
    // meshNetworkManager.logger = this

    // TODO: try load meshNetwork
    // try {
    //   meshNetworkManager.load()
    //    meshNetworkDidChange()
    // } catch {

    // }

    final localProvisioner = Provisioner.create(
      name: 'Local Provisioner',
    );
    meshNetworkManager.createNewMeshNetwork(
      name: "Mesh Network",
      provisioner: localProvisioner,
    );
  }

// TODO:
// void createNewMeshNetwork() {
//   final localProvisioner = Provisioner.create(
//     name: 'Local Provisioner',
//   );

//   final networkRes = meshNetworkManager.createMeshNetwork(
//     name: "My MeshNetwork",
//     provisioner: localProvisioner,
//   );
//   if (networkRes.isError) {
//     logger.d('Error: ${networkRes.asError!.error}');
//   }

//   final saveRes = meshNetworkManager.save();
//   if (saveRes.isError) {
//     logger.d('Error: ${saveRes.asError!.error}');
//   }

//   meshNetworkDidChange()
// }

  void meshNetworkDidChange() {
    this.connection?.close();
    this.connection = null;

    final meshNetwork = meshNetworkManager.meshNetwork;
    if (meshNetwork == null) {
      return;
    }

    // TODO:
    //  // Generic Default Transition Time Server model:
    //     let defaultTransitionTimeServerDelegate = GenericDefaultTransitionTimeServerDelegate(meshNetwork)
    //     // Scene Server and Scene Setup Server models:
    //     let sceneServer = SceneServerDelegate(meshNetwork,
    //                                           defaultTransitionTimeServer: defaultTransitionTimeServerDelegate)
    //     let sceneSetupServer = SceneSetupServerDelegate(server: sceneServer)

    // TODO: create elements and models for this phone
    final element0 = Element.create(
      name: "Primary Element",
      location: Location.first,
      models: [
        // Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
      ],
    );

    // TODO: element1

    // TODO: setLocalElements
    meshNetworkManager.setLocalElements([
      element0, /*element1*/
    ]);

    // create new connection
    final connection = NetworkConnection(meshNetwork: meshNetwork);
    connection.setDataDelegate(meshNetworkManager);
    meshNetworkManager.setTransmitter(connection);
    connection.open();
    // TODO: connection.logger = self
    this.connection = connection;
  }
}
