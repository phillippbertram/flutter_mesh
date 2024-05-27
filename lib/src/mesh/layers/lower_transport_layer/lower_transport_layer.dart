import 'package:flutter_mesh/src/mesh/layers/upper_transport_layer/upper_transport_pdu.dart';
import 'package:flutter_mesh/src/mesh/models/network_key.dart';

import '../../../logger/logger.dart';
import '../../models/mesh_network.dart';
import '../../models/provisioner.dart';
import '../../models/node.dart';
import '../../types.dart';
import '../network_manager.dart';
import 'access_message.dart';

class LowerTransportLayer {
  const LowerTransportLayer._(this._networkManager, this._meshNetwork);

  LowerTransportLayer(NetworkManager networkManager)
      : _networkManager = networkManager,
        _meshNetwork = networkManager.meshNetwork;

  final NetworkManager _networkManager;
  final MeshNetwork _meshNetwork;

  /// This method tries to send the Upper Transport Message.
  ///
  /// - parameters:
  ///   - pdu:        The unsegmented Upper Transport PDU to be sent.
  ///   - initialTtl: The initial TTL (Time To Live) value of the message.
  ///                 If `nil`, the default Node TTL will be used.
  ///   - networkKey: The Network Key to be used to encrypt the message on
  ///                 on Network Layer.
  void sendUnsegmentedUpperTransportPdu(
    UpperTransportPdu pdu, {
    required NetworkKey networkKey,
    Uint8? initialTtl,
  }) {
    logger.f("INCOMPLETE implementation: sendUnsegmentedUpperTransportPdu");
    final provisionerNode = _meshNetwork.localProvisioner?.node;
    if (provisionerNode == null) {
      return;
    }

    final localElement = provisionerNode.elementWithAddress(pdu.source);
    if (localElement == null) {
      return;
    }

    final ttl = initialTtl ??
        provisionerNode.defaultTtl ??
        _networkManager.networkParameters.defaultTtl;

    final message = AccessMessage.fromUnsegmentedUpperTransportPdu(
      pdu,
      networkKey: networkKey,
    );

    // TODO:
    logger.f(
        "NOT IMPLEMENTED - Lower Transport Layer: Sending message: $message");
    // final res = _networkManager.networkLayer.sendLowerTransportPdu(
    //   message,
    //   type: PduType.networkPdu,
    //   ttl: ttl,
    // );
  }
}
