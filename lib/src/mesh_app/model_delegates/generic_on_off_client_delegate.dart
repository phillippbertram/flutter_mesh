
// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Example/Source/Mesh%20Network/GenericOnOffClientDelegate.swift

// abstract class BaseMeshMessage {
//   List<int>? get parameters;
// }

// abstract class MeshMessage implements BaseMeshMessage {
//   static int get opCode => throw UnimplementedError(); // TODO
//   // Other properties and methods as needed
// }

// abstract class UnacknowledgedMeshMessage implements MeshMessage {}

// abstract class MeshResponse implements UnacknowledgedMeshMessage {}

// class GenericOnOffStatusMessage implements MeshResponse {
//   static const int opCode = 0x8204;

//   final bool isOn;
//   final bool? targetState;
//   // final TransitionTime? remainingTime;

//   const GenericOnOffStatusMessage(this.isOn, {this.targetState});

//   // Implementing the method from BaseMeshMessage
//   // @override
//   // static GenericOnOffStatus fromParameters(List<int> parameters) {
//   //   if (parameters.length != 1 && parameters.length != 3) {
//   //     throw FormatException('Invalid parameters length');
//   //   }
//   //   final isOn = parameters[0] == 0x01;
//   //   final targetState = parameters.length == 3 ? parameters[1] == 0x01 : null;
//   //   final remainingTime =
//   //       parameters.length == 3 ? TransitionTime(parameters[2]) : null;
//   //   return GenericOnOffStatus(isOn,
//   //       targetState: targetState, remainingTime: remainingTime);
//   // }

//   @override
//   static BaseMeshMessage? fromParameters(List<int> parameters) {
//     return null;
//   }

//   @override
//   List<int>? get parameters {
//     var data = [isOn ? 0x01 : 0x00];
//     if (targetState != null && remainingTime != null) {
//       data.addAll([targetState! ? 0x01 : 0x00, remainingTime!.rawValue]);
//     }
//     return data;
//   }

//   // Implement other interface methods as needed
// }

// abstract class MessageFactory<T extends BaseMeshMessage> {
//   T? fromParameters(List<int> parameters);
// }

// class GenericOnOffStatusMessageFactory
//     implements MessageFactory<GenericOnOffStatusMessage> {
//   @override
//   GenericOnOffStatusMessage? fromParameters(List<int> parameters) {}
// }

// class GenericOnOffClientDelegate with ModelDelegate {
//   @override
//   Map<Uint32, MessageFactory> messageTypes = {
//     GenericOnOffStatusMessage.opCode: GenericOnOffStatusMessageFactory(),
//   };

//   @override
//   Result<MeshResponse> modelDidReceiveAcknowledgedMessage(
//       MeshMessage message, Address source, Address destination) {
//     throw UnsupportedError("not possible");
//   }

//   @override
//   Result<void> modelDidReceiveUnacknowledgedMessage(
//       MeshMessage message, Address source, Address destination) {
//     // The status message may be received here if the Generic OnOff Server model
//     // has been configured to publish. Ignore this message.
//     return Result.value(null);
//   }

//   @override
//   Result<void> modelDidReceiveResponse(
//       MeshMessage response, MeshMessage toAcknowledgedMessage, Address source) {
//     // Ignore.
//     return Result.value(null);
//   }
// }