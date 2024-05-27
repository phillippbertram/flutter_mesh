import 'package:flutter_mesh/src/mesh/layers/network_layer/network_layer.dart';

import '../../../logger/logger.dart';
import '../../models/mesh_network.dart';
import '../../models/network_key.dart';
import '../../types.dart';
import '../access_layer/access_pdu.dart';
import '../key_set.dart';
import '../network_manager.dart';
import 'upper_transport_pdu.dart';

class UpperTransportLayer {
  const UpperTransportLayer._(this._networkManager, this._meshNetwork);

  factory UpperTransportLayer(NetworkManager networkManager) {
    return UpperTransportLayer._(
      networkManager,
      networkManager.meshNetwork,
    );
  }

  final NetworkManager _networkManager;
  final MeshNetwork _meshNetwork;

  /// Encrypts the Access PDU using given key set and sends it down to
  /// Lower Transport Layer.
  ///
  /// - parameters:
  ///   - pdu: The Access PDU to be sent.
  ///   - initialTtl: The initial TTL (Time To Live) value of the message.
  ///                 If `nil`, the default Node TTL will be used.
  ///   - keySet: The set of keys to encrypt the message with.
  ///
  /// TODO:
  /// func send(_ accessPdu: AccessPdu, withTtl initialTtl: UInt8?, using keySet: KeySet) {
  Future<void> sendAccessPdu(
    AccessPdu accessPdu, {
    Uint8? initialTtl,
    required KeySet keySet,
  }) async {
    // TODO:
    logger.f("INCOMPLETE implementation: sendAccessPdu");

    // Get the current sequence number for source Element's address.
    final sequence = await _networkManager.networkLayer.nextSequenceNumber(
      source: accessPdu.source,
    );

    final pdu = UpperTransportPdu.fromAccessPdu(
      accessPdu,
      keySet: keySet,
      sequence: sequence,
      ivIndex: _meshNetwork.ivIndex,
    );

    logger.i("Sending Upper Transport PDU: $pdu encrypted using key: $keySet");

    final isSegmented = pdu.transportPdu.length > 15 || accessPdu.isSegmented;
    if (isSegmented) {
      // Enqueue the PDU. If the queue was empty, the PDU will be sent
      // immediately.
      enqueue(
        pdu: pdu,
        initialTtl: initialTtl,
        networkKey: keySet.networkKey,
      );
    } else {
      _networkManager.lowerTransportLayer.sendUnsegmentedUpperTransportPdu(
        pdu,
        initialTtl: initialTtl,
        networkKey: keySet.networkKey,
      );
    }
  }
}

extension on UpperTransportLayer {
  /// Enqueues the PDU to be sent using the given Network Key.
  ///
  /// - parameters:
  ///   - pdu: The Upper Transport PDU to be sent.
  ///   - initialTtl: The initial TTL (Time To Live) value of the message.
  ///                 If `nil`, the default Node TTL will be used.
  ///   - networkKey: The Network Key to encrypt the PDU with.
  void enqueue({
    required UpperTransportPdu pdu,
    Uint8? initialTtl,
    required NetworkKey networkKey,
  }) {
    // TODO:
    logger.f("INCOMPLETE implementation: enqueue");
    throw UnimplementedError();
  }
}
