// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/Algorithm.swift#L78

import 'package:flutter/foundation.dart';
import 'package:flutter_mesh/src/mesh/provisioning/provisioning_pdu.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';

import '../types.dart';

// BTM: General reference to Bluetooth Mesh security or transport management.
// ECDH: Elliptic Curve Diffie-Hellman, a key agreement protocol for secure key exchange.
// P256: A specific elliptic curve (prime256v1 or secp256r1) used for cryptography in ECDH.
// CMAC: Cipher-based Message Authentication Code, used for message integrity and authenticity.
// AES128: A variant of the Advanced Encryption Standard using a 128-bit key for encryption.
// AES: Advanced Encryption Standard, a symmetric encryption algorithm used in mesh security.
// CCM: Counter with CBC-MAC, a mode for block ciphers combining encryption and authentication.
enum Algorithm {
  /// BTM ECDH P256 CMAC AES128 AES CCM algorithm will be used to calculate the
  /// shared secret.
  BTM_ECDH_P256_CMAC_AES128_AES_CCM,

  /// BTM ECDH P256 HMAC SHA256 AES CCM algorithm will be used to calculate the
  /// shared secret.
  ///
  /// This algorithm must be supported by devices claming support with Mesh Protocol 1.1.
  ///
  /// - since: Mesh Protocol 1.1.
  BTM_ECDH_P256_HMAC_SHA256_AES_CCM,
}

extension AlgorithmValue on Algorithm {
  int get lengthInBits {
    switch (this) {
      case Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
        return 128;

      // TODO: this is Mesh1.1?
      case Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
        return 256;
    }
  }

  Uint8 get value {
    switch (this) {
      case Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
        return 0x00;

      case Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
        return 0x01;
    }
  }
}

// TODO: freezed?
class Algorithms {
  final int rawValue;

  const Algorithms._(this.rawValue);

  factory Algorithms.fromPdu(ProvisioningPdu pdu, {required int offset}) {
    final data = pdu.data;
    final rawValue = data.readUint16(offset: offset, endian: Endian.big);
    return Algorithms._(rawValue);
  }

  // Algorithms
  static const Algorithms BTM_ECDH_P256_CMAC_AES128_AES_CCM =
      Algorithms._(1 << 0);
  static const Algorithms BTM_ECDH_P256_HMAC_SHA256_AES_CCM =
      Algorithms._(1 << 1);

  // Combination logic using bitwise OR to combine multiple algorithms.
  Algorithms operator |(Algorithms other) =>
      Algorithms._(rawValue | other.rawValue);

  // Checking if an algorithm is part of the set using bitwise AND.
  bool contains(Algorithms other) =>
      (rawValue & other.rawValue) == other.rawValue;

  // Strongest algorithm logic based on the original Swift code
  Algorithm get strongest {
    if (contains(Algorithms.BTM_ECDH_P256_HMAC_SHA256_AES_CCM)) {
      return Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM;
    }
    return Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM;
  }

  Set<Algorithm> get algorithms {
    final algorithms = <Algorithm>{};
    if (contains(Algorithms.BTM_ECDH_P256_CMAC_AES128_AES_CCM)) {
      algorithms.add(Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM);
    }
    if (contains(Algorithms.BTM_ECDH_P256_HMAC_SHA256_AES_CCM)) {
      algorithms.add(Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM);
    }
    return algorithms;
  }

  @override
  String toString() {
    final algorithms = <String>[];
    if (contains(Algorithms.BTM_ECDH_P256_CMAC_AES128_AES_CCM)) {
      algorithms.add('BTM_ECDH_P256_CMAC_AES128_AES_CCM');
    }
    if (contains(Algorithms.BTM_ECDH_P256_HMAC_SHA256_AES_CCM)) {
      algorithms.add('BTM_ECDH_P256_HMAC_SHA256_AES_CCM');
    }
    return "Algorithms: ${algorithms.join(' | ')}";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Algorithms &&
          runtimeType == other.runtimeType &&
          rawValue == other.rawValue;

  @override
  int get hashCode => rawValue;

  static Set<Algorithms> get supportedAlgorithms {
    return {
      Algorithms.BTM_ECDH_P256_CMAC_AES128_AES_CCM,
      Algorithms.BTM_ECDH_P256_HMAC_SHA256_AES_CCM,
    };
  }
}

extension AlgorithmDebugging on Algorithm {
  String get debugDescription {
    switch (this) {
      case Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
        return "BTM_ECDH_P256_CMAC_AES128_AES_CCM";
      case Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
        return "BTM_ECDH_P256_HMAC_SHA256_AES_CCM";
    }
  }
}

extension AlgorithmsDebugging on Algorithms {
  String get debugDescription {
    if (rawValue == 0) {
      return "None";
    }

    return algorithms.map((a) => a.debugDescription).join(", ");
  }
}
