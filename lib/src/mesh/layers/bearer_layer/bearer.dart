import 'package:dart_mesh/src/mesh/types.dart';

enum PduType {
  /// The message is a Network PDU.
  ///
  /// See: Section 3.4.4 of Bluetooth Mesh Specification 1.0.1.
  networkPdu(0),

  /// The message is a mesh beacon.
  ///
  /// See: Section 3.9 of Bluetooth Mesh Specification 1.0.1.
  meshBeacon(1),

  /// The message is a proxy configuration message.
  ///
  /// This message type may be used only for GATT Bearer.
  ///
  /// See: Section 6.5 of Bluetooth Mesh Specification 1.0.1.
  proxyConfiguration(2),

  /// The message is a Provisioning PDU.
  ///
  /// This message type may be used only in Provisioning Bearers (PB).
  ///
  /// See: Section 5.4.1 of Bluetooth Mesh Specification 1.0.1.
  provisioningPdu(3);

  const PduType(this.value);

  final Uint8 value;
}

abstract class Transmitter {
  /// This method sends the given data over the bearer.
  ///
  /// Data longer than MTU will automatically be segmented if bearer
  /// implements segmentation.
  ///
  /// - parameter data: The data to be sent over the Bearer.
  /// - parameter type: The PDU type.
  /// - throws: This method throws an error if the PDU type
  ///           is not supported, or data could not be sent for
  ///           some other reason.
  sendData({required Data data, required PduType type});
}
