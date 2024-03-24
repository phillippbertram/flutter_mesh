// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningPdu.swift#

import '../types.dart';

class ProvisioningPdu {
  const ProvisioningPdu(this.data);

  static ProvisioningPdu fromPduType(int pduType) {
    return ProvisioningPdu(Data.from([pduType]));
  }

  final Data data;

  ProvisioningPduType? get type {
    if (data.isEmpty) {
      return null;
    }
    return ProvisioningPduType._(data[0]);
  }
}

class ProvisioningPduType {
  const ProvisioningPduType._(this.value);

  final int value;

  /// A Provisioner sends a Provisioning Invite PDU to indicate to the intended
  /// Provisionee that the provisioning process is starting.
  static const invite = 0;

  /// The Provisionee sends a Provisioning Capabilities PDU to indicate its
  /// supported provisioning capabilities to a Provisioner.
  static const capabilities = 1;

  /// A Provisioner sends a Provisioning Start PDU to indicate the method it
  /// has selected from the options in the Provisioning Capabilities PDU.
  static const start = 2;

  /// The Provisioner sends a Provisioning Public Key PDU to deliver the
  /// public key to be used in the ECDH calculations.
  static const publicKey = 3;

  /// The Provisionee sends a Provisioning Input Complete PDU when the user
  /// completes the input operation.
  static const inputComplete = 4;

  /// The Provisioner or the Provisionee sends a Provisioning Confirmation PDU
  /// to its peer to confirm the values exchanged so far, including the
  /// OOB Authentication value and the random number that has yet to be exchanged.
  static const confirmation = 5;

  /// The Provisioner or the Provisionee sends a Provisioning Random PDU to
  /// enable its peer device to validate the confirmation.
  static const random = 6;

  /// The Provisioner sends a Provisioning Data PDU to deliver provisioning
  /// data to a Provisionee.
  static const data = 7;

  /// The Provisionee sends a Provisioning Complete PDU to indicate that it
  /// has successfully received and processed the provisioning data.
  static const complete = 8;

  /// The Provisionee sends a Provisioning Failed PDU if it fails to process
  /// a received provisioning protocol PDU.
  static const failed = 9;
}

sealed class ProvisioningRequest {}

// public enum ProvisioningRequest {
//     /// A Provisioner sends a Provisioning Invite PDU to indicate to the intended
//     /// Provisionee that the provisioning process is starting.
//     case invite(attentionTimer: UInt8)
//     /// A Provisioner sends a Provisioning Start PDU to indicate the method it
//     /// has selected from the options in the Provisioning Capabilities PDU.
//     case start(algorithm: Algorithm, publicKey: PublicKeyMethod, authenticationMethod: AuthenticationMethod)
//     /// The Provisioner sends a Provisioning Public Key PDU to deliver the public
//     /// key to be used in the ECDH calculations.
//     case publicKey(_ key: Data)
//     /// The Provisioner or the Provisionee sends a Provisioning Confirmation PDU
//     /// to its peer to confirm the values exchanged so far, including the
//     /// OOB Authentication value and the random number that has yet to be exchanged.
//     case confirmation(_ data: Data)
//     /// The Provisioner or the Provisionee sends a Provisioning Random PDU to
//     /// enable its peer device to validate the confirmation.
//     case random(_ data: Data)
//     /// The Provisioner sends a Provisioning Data PDU to deliver provisioning data
//     /// to a Provisionee.
//     case data(_ encryptedDataWithMic: Data)
// }

class ProvisioningRequestInvite extends ProvisioningRequest {
  ProvisioningRequestInvite({required this.attentionTimer});

  final Uint8 attentionTimer;
}

// class ProvisioningRequestStart extends ProvisioningRequest {
//   const ProvisioningRequestStart({
//     required this.algorithm,
//     required this.publicKey,
//     required this.authenticationMethod,
//   });

//   final Algorithm algorithm;
//   final PublicKeyMethod publicKey;
//   final AuthenticationMethod authenticationMethod;
// }

extension ProvisioningRequestX on ProvisioningRequest {
  ProvisioningPdu get pdu {
    // TODO:
    if (this is ProvisioningRequestInvite) {
      return ProvisioningPdu.fromPduType(ProvisioningPduType.invite);
    }

    throw UnimplementedError();
  }
}
