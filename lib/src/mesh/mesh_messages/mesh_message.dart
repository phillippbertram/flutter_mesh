import '../types.dart';

// @see https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20Messages/MeshMessage.swift#L74

/// The Message Integrity Check for Transport (TransMIC) is a 32-bit or 64-bit
/// field that authenticates that the Access payload has not been changed.
///
/// For a segmented message, where SEG is set to 1, the size of the TransMIC
/// is determined by the value of the SZMIC field in the Lower Transport PDU.
/// For unsegmented messages, the size of the TransMIC is 32 bits for data messages.
///
/// Control messages do not have a TransMIC.
enum MeshMessageSecurity {
  /// Message will be sent with 32-bit Transport MIC.
  low,

  /// Message will be sent with 64-bit Transport MIC.
  ///
  /// Unsegmented messages cannot be sent with this option.
  high
}

/// The base class of every mesh message. Mesh messages can be sent to and
/// received from a mesh network.
abstract class BaseMeshMessage {
  /// Access Layer payload, including the Op Code.
  Data? get parameters;

  /// This initializer should construct the message based on the received
  /// parameters.
  ///
  /// - parameter parameters: Received Access Layer parameters.
  factory BaseMeshMessage.fromParameters(Data parameters) {
    throw UnimplementedError();
  }
}

/// The base class of every mesh message. Mesh messages can be sent to and
/// received from the mesh network. For messages with the Op Code known
/// during compilation a ``StaticMeshMessage`` protocol should be preferred.
///
/// Parameters ``MeshMessage/security-5eige`` and ``MeshMessage/isSegmented-891sy``
/// are checked and should be set only for outgoing messages.
abstract class MeshMessage implements BaseMeshMessage {
  /// The message Op Code.
  Uint32 get opCode;

  /// Returns whether the message should be sent or has been sent using
  /// 32-bit or 64-bit TransMIC value. By default ``MeshMessageSecurity/low``
  /// is returned.
  ///
  /// Only Segmented Access Messages can use 64-bit MIC. If the payload
  /// is shorter than 11 bytes, make sure you return `true` from
  /// ``MeshMessage/isSegmented-891sy``, otherwise this field will be ignored.
  MeshMessageSecurity get security;

  /// Returns whether the message should be sent or was sent as
  /// Segmented Access Message. By default, this parameter returns
  /// `false`.
  ///
  /// To force segmentation for shorter messages return `true` despite
  /// payload length. If payload size is longer than 11 bytes this
  /// field is not checked as the message must be segmented.
  bool get isSegmented;
}

/// The base class for unacknowledged messages.
abstract class UnacknowledgedMessage implements MeshMessage {
  // No additional fields.
}

/// The base class for response messages.
abstract class MeshResponse implements UnacknowledgedMessage {
  // No additional fields.
}

/// The base class for acknowledged messages.
///
/// An acknowledged message is transmitted and acknowledged by each
/// receiving element by responding to that message. The response is
/// typically a status message. If a response is not received within
/// an arbitrary time period, the message will be retransmitted
/// automatically until the timeout occurs.
///
/// Acknowledged messages are expected to be replied with a status message
/// with a message of type set as ``AcknowledgedMeshMessage/responseOpCode``.
///
/// Access Layer timer will wait for
/// ``NetworkParameters/acknowledgmentMessageTimeout`` seconds
/// before throwing a timeout.
abstract class AcknowledgedMeshMessage implements MeshMessage {
  /// The Op Code of the response message.
  Uint32 get responseOpCode;
}
