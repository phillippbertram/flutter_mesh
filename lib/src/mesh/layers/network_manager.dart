import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/layers/access_layer/access_layer.dart';
import 'package:flutter_mesh/src/mesh/layers/lower_transport_layer/lower_transport_layer.dart';
import 'package:flutter_mesh/src/mesh/layers/network_layer/network_layer.dart';
import 'package:flutter_mesh/src/mesh/layers/upper_transport_layer/upper_transport_layer.dart';

import '../mesh.dart';
import '../models/mesh_address.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Layers/NetworkManager.swift

// TODO: internal class
class NetworkManager {
  final MeshNetwork meshNetwork;

  late final NetworkLayer networkLayer;
  late final LowerTransportLayer lowerTransportLayer;
  late final UpperTransportLayer upperTransportLayer;
  late final AccessLayer _accessLayer;

  NetworkManager(this.meshNetwork) {
    networkLayer = NetworkLayer(this);
    lowerTransportLayer = LowerTransportLayer(this);
    upperTransportLayer = UpperTransportLayer(this);
    _accessLayer = AccessLayer(this);
  }
}

extension NetworkManagerMessaging on NetworkManager {
  /// Encrypts the message with the Device Key and the first Network Key
  /// known to the target device, and sends to the given destination address.
  ///
  /// The ``ConfigNetKeyDelete`` will be signed with a different Network Key
  /// that is removing.
  ///
  /// This method does not send nor return PDUs to be sent. Instead,
  /// for each created segment it calls transmitter's ``Transmitter/send(_:ofType:)``
  /// method, which should send the PDU over the air. This is in order to support
  /// retransmission in case a packet was lost and needs to be sent again
  /// after block acknowledgment was received.
  ///
  /// - parameters:
  ///   - configMessage: The message to be sent.
  ///   - fromElement:       The source Element.
  ///   - destination:   The destination address.
  ///   - initialTtl:    The initial TTL (Time To Live) value of the message.
  ///                    If `nil`, the default Node TTL will be used.
  ///
  /// TODO:
  /// NetworkManager:
  /// func send(_ configMessage: UnacknowledgedConfigMessage,
  ///   from element: Element, to destination: Address,
  ///   withTtl initialTtl: UInt8?) async throws {
  Future<Result<void>> sendConfigMessageToDestination(
    ConfigMessage configMessage, {
    required MeshElement fromElement,
    required Address destination,
    Uint8? initialTtl, // TODO:
  }) async {
    logger.f("INCOMPLETE implementation: sendConfigMessageToDestination");

    final meshAddress = MeshAddress.fromAddress(destination);
    // TODO: implement this

    // TODO: make future cancellable
    // final cancelableOperation = CancelableOperation.fromFuture(
    // TODO: use outgoing messages queue
    _accessLayer.sendConfigMessage(
      configMessage,
      fromElement: fromElement,
      toDestination: destination,
    );
    //   onCancel: () {
    //     // TODO: cleanup
    //     logger.t("Operation cancelled");
    //   },
    // );

    return Result.value(null);
  }
}
