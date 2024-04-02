// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/Algorithm.swift#L78

import 'package:flutter/foundation.dart';
import 'package:flutter_mesh/src/mesh/provisioning/provisioning_pdu.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';

import '../types.dart';

enum Algorithm {
  // Algorithms
  BTM_ECDH_P256_CMAC_AES128_AES_CCM,
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
