// TODO: make freezed

import 'package:flutter_mesh/src/mesh/mesh_messages/mesh_messages.dart';
import 'package:flutter_mesh/src/mesh/models/address.dart';
import 'package:flutter_mesh/src/mesh/models/mesh_address.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

class AccessPdu {
  const AccessPdu._({
    required this.message,
    required this.userInitiated,
    required this.source,
    required this.destination,
    required this.opCode,
    required this.parameters,
    required this.accessPdu,
  });

  factory AccessPdu.fromMeshMessage(
    MeshMessage message, {
    required Address sentFrom,
    required MeshAddress toDestination,
    required bool userInitiated,
  }) {
    final opCode = message.opCode;
    final parameters = message.parameters ?? Data.empty();

    // Op Code 0b01111111 is invalid. We will ignore this case here
    // for now and send as a single byte OpCode.
    // TODO FROM GITHUB: Handle 0b0111111 opcode correctly.
    final accessPdu = _accessPduFromOpCode(opCode, parameters);

    return AccessPdu._(
      message: message,
      userInitiated: userInitiated,
      source: sentFrom,
      destination: toDestination,
      opCode: opCode,
      parameters: parameters,
      accessPdu: accessPdu,
    );
  }

  /// The Mesh Message that is being sent, or `nil`, when the message
  /// was received.
  final MeshMessage? message;

  /// Whether sending this message has been initiated by the user.
  /// Status of automatic retries will not be reported to the app.
  final bool userInitiated;

  /// Source Address.
  final Address source;

  /// Destination Address.
  final MeshAddress destination;

  /// Message Op Code.
  final Uint32 opCode;

  /// Message parameters as Data.
  final Data parameters;

  /// The Access Layer PDU data that will be sent.
  final Data accessPdu;

  /// Whether the outgoing message will be sent as segmented, or not.
  bool get isSegmented {
    if (message == null) {
      return false;
    }

    return accessPdu.length > 11 || message!.isSegmented;
  }

  /// Number of packets for this PDU.
  /// ```
  /// Number of Packets | Maximum useful access payload size (octets)
  ///                   | 32 bit TransMIC  | 64 bit TransMIC
  /// ------------------+------------------+-------------------------
  /// 1                 | 11 (unsegmented) | n/a
  /// 1                 | 8 (segmented)    | 4 (segmented)
  /// 2                 | 20               | 16
  /// 3                 | 32               | 28
  /// n                 | (n×12)-4         | (n×12)-8
  /// 32                | 380              | 376
  /// ```
  int get segmentsCount {
    if (message == null) {
      return 0;
    }

    if (!message!.isSegmented) {
      return 1;
    }

    switch (message!.security) {
      case MeshMessageSecurity.low:
        return 1 + (accessPdu.length + 3) ~/ 12;
      case MeshMessageSecurity.high:
        return 1 + (accessPdu.length + 7) ~/ 12;
    }
  }
}

Data _accessPduFromOpCode(int opCode, Data parameters) {
  // Swift code
  // switch opCode {
  //       case let opCode where opCode < 0x80:
  //           accessPdu = Data([UInt8(opCode & 0xFF)]) + parameters
  //       case let opCode where opCode < 0x4000 || opCode & 0xFFFC00 == 0x8000:
  //           accessPdu = Data([UInt8(0x80 | ((opCode >> 8) & 0x3F)), UInt8(opCode & 0xFF)]) + parameters
  //       default:
  //           accessPdu = Data([
  //                           UInt8(0xC0 | ((opCode >> 16) & 0x3F)),
  //                           UInt8((opCode >> 8) & 0xFF),
  //                           UInt8(opCode & 0xFF)
  //                       ]) + parameters
  //
  // TODO: test this

  if (opCode < 0x80) {
    return Data.from([opCode & 0xFF]) + parameters;
  }

  if (opCode < 0x4000 || (opCode & 0xFFFC00) == 0x8000) {
    return Data.from([
          0x80 | ((opCode >> 8) & 0x3F),
          opCode & 0xFF,
        ]) +
        parameters;
  }

  return Data.from([
        0xC0 | ((opCode >> 16) & 0x3F),
        (opCode >> 8) & 0xFF,
        opCode & 0xFF,
      ]) +
      parameters;
}
