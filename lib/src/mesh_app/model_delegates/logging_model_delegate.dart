import 'package:async/async.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';

class LoggingDelegate implements ModelDelegate {
  LoggingDelegate(this.messageTypes);

  @override
  Map<Uint32, Type> messageTypes;

  @override
  Result<MeshResponse> modelDidReceiveAcknowledgedMessage(
      MeshMessage message, Address source, Address destination) {
    print('Received acknowledged message: $message');
    throw UnsupportedError("not possible");
  }

  @override
  Result<void> modelDidReceiveUnacknowledgedMessage(
      MeshMessage message, Address source, Address destination) {
    print(
      'Received unacknowledged message: $message from: $source to: $destination',
    );
    return Result.value(null);
  }

  @override
  Result<void> modelDidReceiveResponse(
      MeshMessage response, MeshMessage toAcknowledgedMessage, Address source) {
    print(
        'Received response: $response to: $toAcknowledgedMessage from: $source');
    return Result.value(null);
  }
}
