import 'package:dart_mesh/src/mesh/layers/access_layer/access_layer.dart';
import 'package:dart_mesh/src/mesh/layers/lower_transport_layer/lower_transport_layer.dart';
import 'package:dart_mesh/src/mesh/layers/network_layer/network_layer.dart';
import 'package:dart_mesh/src/mesh/layers/upper_transport_layer/upper_transport_layer.dart';

class NetworkManager {
  final NetworkLayer _networkLayer;
  final LowerTransportLayer _lowerTransportLayer;
  final UpperTransportLayer _upperTransportLayer;
  final AccessLayer _accessLayer;
}
