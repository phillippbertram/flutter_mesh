import 'package:async/async.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

import '../../provisioning/provisioning_pdu.dart';

export './gatt/gatt.dart';
export 'bearer_delegate.dart';

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

// TODO:
/// A set of supported PDU types by the bearer object.
// public struct PduTypes: OptionSet {
//     public let rawValue: UInt8

//     /// Set, if the bearer supports Network PDUs.
//     public static let networkPdu         = PduTypes(rawValue: 1 << 0)
//     /// Set, if the bearer supports Mesh Beacons.
//     public static let meshBeacon         = PduTypes(rawValue: 1 << 1)
//     /// Set, if the bearer supports proxy filter configuration.
//     public static let proxyConfiguration = PduTypes(rawValue: 1 << 2)
//     /// Set, if the bearer supports Provisioning PDUs.
//     public static let provisioningPdu    = PduTypes(rawValue: 1 << 3)

//     public init(rawValue: UInt8) {
//         self.rawValue = rawValue
//     }

// }

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
  Future<Result<void>> sendData({required Data data, required PduType type});
}

/// The Bearer object is responsible for sending and receiving the data
/// to the mesh network.
abstract class Bearer extends Transmitter {
  /// The Bearer delegate object will receive callbacks whenever the
  /// Bearer state changes.
  // TODO: var delegate: BearerDelegate? { get set }

  Stream<bool> get isOpenStream;

  /// The data delegate will receive callbacks whenever a message is
  /// received from the Bearer.
  // TODO: var dataDelegate: BearerDataDelegate? { get set }

  /// Returns the PDU types supported by this bearer.
  List<PduType> get supportedPduTypes;

  /// This property returns `true` if the Bearer is open, otherwise `false`.
  bool get isOpen;

  /// This method opens the Bearer.
  Future<Result<void>> open();

  /// This method closes the Bearer.
  Future<Result<void>> close();
}

extension BearerSupportsX on Bearer {
  /// Returns whether the bearer supports the given PDU type.
  ///
  /// - parameter type: The PDU type.
  /// - returns: `True` if the bearer supports the given PDU type, `false` otherwise.
  bool supports(PduType type) {
    // TODO: original code uses "return supportedPduTypes.contains(PduTypes(rawValue: pduType.mask))"
    return supportedPduTypes.contains(type);
  }
}

mixin ProvisioningBearer on Bearer {
  /// This method sends the given Provisioning Request over the bearer.
  ///
  /// Data longer than MTU will automatically be segmented if bearer
  /// implements segmentation.
  ///
  /// - parameter request: The Provisioning request to be sent over
  ///                      the Bearer.
  /// - throws: This method throws an error if the PDU type
  ///           is not supported, or data could not be sent for
  ///           some other reason.
  Future<Result<void>> sendProvisioningRequest(ProvisioningRequest request) {
    return sendData(data: request.pdu.data, type: PduType.provisioningPdu);
  }
}
