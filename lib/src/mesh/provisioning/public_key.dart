import '../types.dart';

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

sealed class PublicKey {
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

class NoOobPublicKey extends PublicKey {}

class OobPublicKey extends PublicKey {
  OobPublicKey({required this.key});

  final Data key;
}
