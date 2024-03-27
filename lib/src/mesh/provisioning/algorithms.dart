// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/Algorithm.swift#L78

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
}

// TODO: freezed?
class Algorithms {
  final int rawValue;

  const Algorithms._(this.rawValue);

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
