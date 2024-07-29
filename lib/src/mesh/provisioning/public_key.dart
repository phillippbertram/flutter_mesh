import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../types.dart';
import 'provisioning_pdu.dart';

part 'public_key.freezed.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Provisioning/PublicKey.swift

/// The type of Device Public key to be used.
///
/// This enumeration is used in ``ProvisioningRequest/start(algorithm:publicKey:authenticationMethod:)``
/// to encode the selected Public Key type.
enum PublicKeyMethod {
  /// No OOB Public Key is used.
  noOobPublicKey,

  /// OOB Public Key is used. The key must contain the full value of the Public Key,
  /// depending on the chosen algorithm.
  oobPublicKey
}

extension PublicKeyMethodValue on PublicKeyMethod {
  Uint8 get value {
    switch (this) {
      case PublicKeyMethod.noOobPublicKey:
        return 0x00;

      case PublicKeyMethod.oobPublicKey:
        return 0x01;
    }
  }
}

@freezed
sealed class PublicKey with _$PublicKey {
  const factory PublicKey.noOob() = NoOobPublicKey;

  const factory PublicKey.oobPublicKey({
    required Data key,
  }) = OobPublicKey;
}

extension PublicKeyX on PublicKey {
  PublicKeyMethod get method {
    if (this is NoOobPublicKey) {
      return PublicKeyMethod.noOobPublicKey;
    } else if (this is OobPublicKey) {
      return PublicKeyMethod.oobPublicKey;
    } else {
      throw Exception('Unknown PublicKey type');
    }
  }
}

// TODO: this is not used in the library 🤷‍♂️
/// The type of Public Key information.
class PublicKeyType {
  final Uint8 rawValue;

  const PublicKeyType._(this.rawValue);

  factory PublicKeyType.fromPdu(ProvisioningPdu pdu, {required int offset}) {
    return PublicKeyType._(pdu.data.readUint8(offset: offset));
  }

  /// Public Key OOB Information is available.
  static const publicKeyOobInformationAvailable = PublicKeyType._(1 << 0);

  bool contains(PublicKeyType option) {
    return rawValue & option.rawValue == option.rawValue;
  }

  @override
  String toString() {
    return debugDescription;
  }
}

extension PublicKeyMethodDebugging on PublicKeyMethod {
  String get debugDescription {
    switch (this) {
      case PublicKeyMethod.noOobPublicKey:
        return "No OOB Public Key";
      case PublicKeyMethod.oobPublicKey:
        return "OOB Public Key";
    }
  }
}

extension PublicKeyDebugging on PublicKey {
  String get debugDescription {
    return when(
      noOob: () => "No OOB Public Key",
      oobPublicKey: (_) => "OOB Public Key",
    );
  }
}

extension PublicKeyTypeDebugging on PublicKeyType {
  String get debugDescription {
    if (rawValue == 0) {
      return "None";
    }

    if (contains(PublicKeyType.publicKeyOobInformationAvailable)) {
      return "Public Key OOB Information Available";
    }

    return "None";
  }
}
