import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/layers/access_layer/access_pdu.dart';

import '../../mesh_messages/mesh_messages.dart';
import '../../models/mesh_address.dart';
import '../../models/models.dart';
import '../../types.dart';
import '../key_set.dart';
import '../network_manager.dart';

class AccessLayer {
  const AccessLayer(this._networkManager);
  final NetworkManager _networkManager;

  /// Sends the ``ConfigMessage`` to the given destination. The message is encrypted
  /// using the Device Key which belongs to the target Node, and first
  /// Network Key known to this Node.
  ///
  /// - parameters:
  ///   - message:     The Mesh Config Message to send.
  ///   - element:     The source Element.
  ///   - destination: The destination address. This must be a Unicast Address.
  ///   - initialTtl:  The initial TTL (Time To Live) value of the message.
  ///                  If `nil`, the default Node TTL will be used.
  ///
  /// TODO:
  /// AccessLayer
  ///  func send(_ message: ConfigMessage,
  ///         from element: Element, to destination: Address,
  ///         withTtl initialTtl: UInt8?) {
  void sendConfigMessage(
    ConfigMessage message, {
    required MeshElement fromElement,
    required Address toDestination,
    Uint8? initialTtl,
  }) {
    // TODO:
    logger.f("INCOMPLETE implementation: sendConfigMessage");

    final node = _networkManager.meshNetwork.nodeWithAddress(toDestination);
    if (node == null) {
      return;
    }

    var networkKey = node.networkKeys.firstOrNull;
    if (networkKey == null) {
      return;
    }

    // TODO: ConfigNetKeyDelete
    // // ConfigNetKeyDelete must not be signed using the key that is being deleted.
    // if let netKeyDelete = message as? ConfigNetKeyDelete,
    //    netKeyDelete.networkKeyIndex == networkKey.index {
    //     // Existence of another Network Key was checked in MeshNetworkManager.send(...).
    //     networkKey = node.networkKeys.last!
    // }

    final keySet = DeviceKeySet.from(networkKey: networkKey, node: node);
    if (keySet == null) {
      return;
    }

    logger.i("Sending $message to:${toDestination.toString()}");

    final pdu = AccessPdu.fromMeshMessage(
      message,
      sentFrom: fromElement.unicastAddress,
      toDestination: MeshAddress.fromAddress(toDestination),
      userInitiated: true,
    );

    logger.i("AccessLayer: Sending $pdu to: ${toDestination.toString()}");

    // // Set timers for the acknowledged messages.
    // TODO: createReliableContext
    // createReliableContext(for: pdu, sentFrom: element, withTtl: initialTtl, using: keySet)

    _networkManager.upperTransportLayer.sendAccessPdu(
      pdu,
      initialTtl: initialTtl,
      keySet: keySet,
    );
  }
}
