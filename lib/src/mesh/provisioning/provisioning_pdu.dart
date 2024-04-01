// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningPdu.swift#

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../types.dart';
import 'algorithms.dart';
import 'oob.dart';
import 'provisioning_capabilities.dart';
import 'public_key.dart';

part 'provisioning_pdu.freezed.dart';

// @see https://www.bluetooth.com/blog/provisioning-a-bluetooth-mesh-network-part-1/

// Swift uses a typealias to define the Provisioning PDU type.
// We use a class to represent the PDU type.
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

  /// Checks whether the PDU is valid and supported.
  ///
  /// Validation is performed only based on length.
  bool get isValid {
    if (type == null) {
      return false;
    }

    // TODO: test this
    return switch (type!.value) {
      (ProvisioningPduType.invite | ProvisioningPduType.failed) =>
        data.length == 1 + 1,
      (ProvisioningPduType.capabilities) => data.length == 1 + 11,
      (ProvisioningPduType.start) => data.length == 1 + 5,
      (ProvisioningPduType.publicKey) => data.length == 1 + 32 + 32,
      (ProvisioningPduType.inputComplete | ProvisioningPduType.complete) =>
        data.length == 1 + 0,
      (ProvisioningPduType.confirmation | ProvisioningPduType.random) =>
        data.length == 1 + 16 || data.length == 1 + 32,
      (ProvisioningPduType.data) => data.length == 1 + 25 + 8,
      _ => false,
    };
  }

  ProvisioningPdu operator +(Data data) {
    return ProvisioningPdu(this.data + data);
  }
}

class ProvisioningPduType {
  const ProvisioningPduType._(this.value);

  final int value;

  /// A Provisioner sends a Provisioning Invite PDU to indicate to the intended
  /// Provisionee that the provisioning process is starting.
  static const Uint8 invite = 0;

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

@freezed
sealed class ProvisioningRequest with _$ProvisioningRequest {
  /// A Provisioner sends a Provisioning Start PDU to indicate the method it
  /// has selected from the options in the Provisioning Capabilities PDU.
  const factory ProvisioningRequest.invite({required Uint8 attentionTimer}) =
      ProvisioningRequestInvite;

  /// A Provisioner sends a Provisioning Start PDU to indicate the method it
  /// has selected from the options in the Provisioning Capabilities PDU.
  const factory ProvisioningRequest.start({
    required Algorithm algorithm,
    required PublicKeyMethod publicKey,
    required AuthenticationMethod authenticationMethod,
  }) = ProvisioningRequestStart;

  /// The Provisioner sends a Provisioning Public Key PDU to deliver the public
  /// key to be used in the ECDH calculations.
  const factory ProvisioningRequest.publicKey({required Data key}) =
      ProvisioningRequestPublicKey;

  /// The Provisioner or the Provisionee sends a Provisioning Confirmation PDU
  /// to its peer to confirm the values exchanged so far, including the
  /// OOB Authentication value and the random number that has yet to be exchanged.
  const factory ProvisioningRequest.confirmation({required Data data}) =
      ProvisioningRequestConfirmation;

  /// The Provisioner sends a Provisioning Public Key PDU to deliver the public
  /// key to be used in the ECDH calculations.
  const factory ProvisioningRequest.random({required Data data}) =
      ProvisioningRequestRandom;

  /// The Provisioner sends a Provisioning Data PDU to deliver provisioning data
  /// to a Provisionee.
  const factory ProvisioningRequest.data({required Data encryptedDataWithMic}) =
      ProvisioningRequestData;
}

extension ProvisioningRequestX on ProvisioningRequest {
  ProvisioningPdu get pdu {
    return switch (this) {
      ProvisioningRequestInvite(attentionTimer: final attentionTimer) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.invite) +
            Data.from([attentionTimer]),
      ProvisioningRequestStart(
        algorithm: final algorithm,
        publicKey: final publicKey,
        authenticationMethod: final authenticationMethod,
      ) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.start) +
            Data.from([
              // TODO:
              // algorithm.value,
              // publicKey.value,
              // authenticationMethod.value,
            ]),
      ProvisioningRequestPublicKey(key: final key) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.publicKey) + key,
      ProvisioningRequestConfirmation(data: final data) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.confirmation) + data,
      ProvisioningRequestRandom(data: final data) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.random) + data,
      ProvisioningRequestData(
        encryptedDataWithMic: final encryptedDataWithMic
      ) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.data) +
            encryptedDataWithMic,
    };
  }
}

/// Provisioning responses are sent by the Provisionee to the Provisioner
/// as a response to ``ProvisioningRequest``.
@freezed
sealed class ProvisioningResponse with _$ProvisioningResponse {
  /// The Provisionee sends a Provisioning Capabilities PDU to indicate its
  /// supported provisioning capabilities to a Provisioner.
  const factory ProvisioningResponse.capabilities({
    required ProvisioningCapabilities capabilities,
  }) = ProvisioningResponseCapabilities;

  /// The Provisionee sends a Provisioning Input Complete PDU when the user
  /// completes the input operation.
  const factory ProvisioningResponse.inputComplete() =
      ProvisioningResponseInputComplete;

  /// The Provisioner sends a Provisioning Public Key PDU to deliver the
  /// public key to be used in the ECDH calculations.
  const factory ProvisioningResponse.publicKey({required Data key}) =
      ProvisioningResponsePublicKey;

  /// The Provisioner or the Provisionee sends a Provisioning Confirmation PDU
  /// to its peer to confirm the values exchanged so far, including the
  /// OOB Authentication value and the random number that has yet to be exchanged.
  const factory ProvisioningResponse.confirmation({required Data key}) =
      ProvisioningResponseConfirmation;

  /// The Provisioner or the Provisionee sends a Provisioning Random PDU to
  /// enable its peer device to validate the confirmation.
  const factory ProvisioningResponse.random({required Data key}) =
      ProvisioningResponseRandom;

  /// The Provisionee sends a Provisioning Complete PDU to indicate that it
  /// has successfully received and processed the provisioning data.
  const factory ProvisioningResponse.complete() = ProvisioningResponseComplete;

  /// The Provisionee sends a Provisioning Failed PDU if it fails to process
  /// a received provisioning protocol PDU.
// TODO: RemoteProvisioningError
  const factory ProvisioningResponse.failed({Object? error}) =
      ProvisioningResponseFailed;

  static Result<ProvisioningResponse> fromPdu(ProvisioningPdu pdu) {
    if (pdu.type == null) {
      return Result.error("Invalid PDU type: ${pdu.data[0]}");
    }

    final response = switch (pdu.type!.value) {
      ProvisioningPduType.capabilities => ProvisioningResponseCapabilities(
          capabilities: ProvisioningCapabilities.fromPdu(pdu),
        ),
      ProvisioningPduType.inputComplete =>
        const ProvisioningResponseInputComplete(),
      ProvisioningPduType.publicKey =>
        ProvisioningResponsePublicKey(key: pdu.data.suffix(from: 1)),
      ProvisioningPduType.confirmation =>
        ProvisioningResponseConfirmation(key: pdu.data.suffix(from: 1)),
      ProvisioningPduType.random =>
        ProvisioningResponseRandom(key: pdu.data.suffix(from: 1)),
      ProvisioningPduType.complete => const ProvisioningResponseComplete(),
      ProvisioningPduType.failed =>
        const ProvisioningResponseFailed(error: "Provisioning failed."),
      _ => null,
    };

    if (response == null) {
      return Result.error('Invalid PDU type: ${pdu.type}');
    }

    return Result.value(response);
  }
}

extension ProvisioningResponseX on ProvisioningResponse {
  // TODO: test this
  ProvisioningPdu get pdu {
    return switch (this) {
      ProvisioningResponseCapabilities(capabilities: final capabilities) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.capabilities) +
            capabilities.value,
      ProvisioningResponseInputComplete() =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.inputComplete),
      ProvisioningResponsePublicKey(key: final key) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.publicKey) + key,
      ProvisioningResponseConfirmation(key: final data) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.confirmation) + data,
      ProvisioningResponseRandom(key: final data) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.random) + data,
      ProvisioningResponseComplete() =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.complete),
      ProvisioningResponseFailed(error: final error) =>
        ProvisioningPdu.fromPduType(ProvisioningPduType.failed) +
            Data.from([0]),
    };
  }
}



//     var pdu: ProvisioningPdu {
//         switch self {
//         case let .capabilities(capabilities):
//             return ProvisioningPdu(pdu: .capabilities) + capabilities.value
//         case .inputComplete:
//             return ProvisioningPdu(pdu: .inputComplete)
//         case let .publicKey(key):
//             return ProvisioningPdu(pdu: .publicKey) + key
//         case let .confirmation(confirmation):
//             return ProvisioningPdu(pdu: .confirmation) + confirmation
//         case let .random(random):
//             return ProvisioningPdu(pdu: .random) + random
//         case .complete:
//             return ProvisioningPdu(pdu: .complete)
//         case let .failed(error):
//             return ProvisioningPdu(pdu: .failed) + error.rawValue
//         }
//     }
// }
