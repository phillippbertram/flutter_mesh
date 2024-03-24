import 'package:async/src/result/result.dart';
import 'package:dart_mesh/src/mesh/mesh.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Example/Source/Mesh%20Network/GenericOnOffClientDelegate.swift

class GenericOnOffClientDelegate implements ModelDelegate {
  @override
  Map<Uint32, Type> messageTypes = {
    // 0x8201: GenericOnOffStatusMessage,
  };

  @override
  Result<MeshResponse> modelDidReceiveAcknowledgedMessage(
      MeshMessage message, Address source, Address destination) {
    throw UnsupportedError("not possible");
  }

  @override
  Result<void> modelDidReceiveUnacknowledgedMessage(
      MeshMessage message, Address source, Address destination) {
    // The status message may be received here if the Generic OnOff Server model
    // has been configured to publish. Ignore this message.
    return Result.value(null);
  }

  @override
  Result<void> modelDidReceiveResponse(
      MeshMessage response, MeshMessage toAcknowledgedMessage, Address source) {
    // Ignore.
    return Result.value(null);
  }
}
