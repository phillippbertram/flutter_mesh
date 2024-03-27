import 'package:freezed_annotation/freezed_annotation.dart';

import '../types.dart';

part 'public_key.freezed.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/PublicKey.swift

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
