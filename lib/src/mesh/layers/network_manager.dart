import 'package:flutter_mesh/src/mesh/layers/access_layer/access_layer.dart';
import 'package:flutter_mesh/src/mesh/layers/lower_transport_layer/lower_transport_layer.dart';
import 'package:flutter_mesh/src/mesh/layers/network_layer/network_layer.dart';
import 'package:flutter_mesh/src/mesh/layers/upper_transport_layer/upper_transport_layer.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Layers/NetworkManager.swift

class NetworkManager {
  // TODO:
  final NetworkLayer _networkLayer;
  final LowerTransportLayer _lowerTransportLayer;
  final UpperTransportLayer _upperTransportLayer;
  final AccessLayer _accessLayer;

  const NetworkManager._({
    required NetworkLayer networkLayer,
    required LowerTransportLayer lowerTransportLayer,
    required UpperTransportLayer upperTransportLayer,
    required AccessLayer accessLayer,
  })  : _networkLayer = networkLayer,
        _lowerTransportLayer = lowerTransportLayer,
        _upperTransportLayer = upperTransportLayer,
        _accessLayer = accessLayer;

  factory NetworkManager() {
    const networkLayer = NetworkLayer();
    const lowerTransportLayer = LowerTransportLayer();
    const upperTransportLayer = UpperTransportLayer();
    const accessLayer = AccessLayer();

    return const NetworkManager._(
      networkLayer: networkLayer,
      lowerTransportLayer: lowerTransportLayer,
      upperTransportLayer: upperTransportLayer,
      accessLayer: accessLayer,
    );
  }
}
