import 'package:async/async.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

class LoggingModelDelegate implements ModelDelegate {
  LoggingModelDelegate({this.messageTypes = const {}});

  @override
  Map<Uint32, Type> messageTypes;

  @override
  Result<MeshResponse> modelDidReceiveAcknowledgedMessage(
      MeshMessage message, Address source, Address destination) {
    logger.d('Received acknowledged message: $message');
    throw UnsupportedError("not possible");
  }

  @override
  Result<void> modelDidReceiveUnacknowledgedMessage(
      MeshMessage message, Address source, Address destination) {
    logger.d(
      'Received unacknowledged message: $message from: $source to: $destination',
    );
    return Result.value(null);
  }

  @override
  Result<void> modelDidReceiveResponse(
      MeshMessage response, MeshMessage toAcknowledgedMessage, Address source) {
    logger.d(
        'Received response: $response to: $toAcknowledgedMessage from: $source');
    return Result.value(null);
  }
}
