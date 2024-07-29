import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/layers/lower_transport_layer/access_message.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:flutter_mesh/src/mesh/utils/shared_prefs.dart';

import '../../models/address.dart';
import '../bearer_layer/bearer.dart';
import '../lower_transport_layer/lower_transport_pdu.dart';
import '../network_manager.dart';
import 'network_pdu.dart';

class NetworkLayer {
  NetworkLayer(this._networkManager)
      : _prefs = NetworkSharedPreferences(
          uuid: _networkManager.meshNetwork.uuid.uuidString,
        ); // TODO: inject NetworkSharedPreferences instead?

  final NetworkManager _networkManager;
  final SharedPrefs _prefs;

  /// This method tries to send the Lower Transport Message of given type to the
  /// given destination address. If the local Provisioner does not exist, or
  /// does not have Unicast Address assigned, this method does nothing.
  ///
  /// - parameters:
  ///   - pdu:  The Lower Transport PDU to be sent.
  ///   - type: The PDU type.
  ///   - ttl:  The initial TTL (Time To Live) value of the message.
  /// - throws: This method may throw when the ``MeshNetworkManager/transmitter``
  ///           is not set, or has failed to send the PDU.
  Future<Result<void>> sendLowerTransportPdu(
    LowerTransportPdu pdu, {
    required PduType type,
    required Uint8 ttl,
  }) async {
    logger.f("INCOMPLETE implementation: sendLowerTransportPdu");
    final transmitter = _networkManager.transmitter;
    if (transmitter == null) {
      return Result.error("Bearer closed");
    }

    // TODO:
    final Uint32 sequence = (pdu is AccessMessage ? pdu.sequence : null) ??
        await nextSequenceNumber(source: pdu.source);
    final networkPdu = NetworkPdu.encode(
      lowerTransportPdu: pdu,
      pduType: type,
      sequence: sequence,
      ttl: ttl,
    );
    logger.i("Network Layer: Sending Network PDU: $networkPdu");

    // TODO:
    // Loopback interface.
    // if shouldLoopback(networkPdu) {
    //     handle(incomingPdu: networkPdu.pdu, ofType: type)
    //     // Messages sent with TTL = 1 will only be sent locally.
    //     guard ttl != 1 else { return }
    //     if isLocalUnicastAddress(networkPdu.destination) {
    //         // No need to send messages targeting local Unicast Addresses.
    //         return
    //     }
    //     // If the message was sent locally, don't report Bearer closer error.
    //     try? transmitter.send(networkPdu.pdu, ofType: type)
    // } else {
    //     // Messages sent with TTL = 1 may only be sent locally.
    //     guard ttl != 1 else { return }
    //     do {
    //         try transmitter.send(networkPdu.pdu, ofType: type)
    //     } catch {
    //         if case BearerError.bearerClosed = error {
    //             proxyNetworkKey = nil
    //         }
    //         throw error
    //     }
    // }

    // // Unless a GATT Bearer is used, the Network PDUs should be sent multiple times
    // // if Network Transmit has been set for the local Provisioner's Node.
    // if case .networkPdu = type, !(transmitter is GattBearer),
    //     let networkTransmit = meshNetwork.localProvisioner?.node?.networkTransmit,
    //     networkTransmit.count > 1 {
    //     var count = networkTransmit.count
    //     BackgroundTimer.scheduledTimer(withTimeInterval: networkTransmit.timeInterval,
    //                                     repeats: true) { [weak self] timer in
    //         guard let self = self,
    //               let networkManager = self.networkManager else {
    //             timer.invalidate()
    //             return
    //         }
    //         try? networkManager.transmitter?.send(networkPdu.pdu, ofType: type)
    //         count -= 1
    //         if count == 0 {
    //             timer.invalidate()
    //         }
    //     }
    // }

    final transmitRes =
        await transmitter.sendData(data: networkPdu.pdu, type: type);

    return transmitRes;
  }
}

// Internal extensions

extension NetworkLayerInternal on NetworkLayer {
  /// This method returns the next outgoing Sequence number for the given
  /// local source Address.
  ///
  /// - parameter source: The source Element's Unicast Address.
  /// - returns: The Sequence number a message can be sent with.
  Future<Uint32> nextSequenceNumber({required Address source}) async {
    return _prefs.nextSequenceNumber(source: source);
  }

  /// This method handles the received PDU of given type and
  /// passes it to Upper Transport Layer.
  ///
  /// - parameters:
  ///   - pdu:  The data received.
  ///   - type: The PDU type.
  void _handleIncomingPdu(Data pdu, PduType type) {
    // TODO:
    logger.f("INCOMPLETE implementation: _handleIncomingPdu");
  }
}
