import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter_mesh/src/mesh/models/key.dart';
import 'package:flutter_mesh/src/mesh/models/key_refresh_phase.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data_keys.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

import '../utils/crypto.dart';
import 'security.dart';

// TODO: JSONSerialization + Equatable

class NetworkKeyDerivatives {
  /// The Identity Key.
  final Data identityKey;

  /// The Beacon Key.
  final Data beaconKey;

  /// The Private Beacon Key.
  final Data privateBeaconKey;

  /// The Encryption Key.
  final Data encryptionKey;

  /// The Privacy Key.
  final Data privacyKey;

  /// Network identifier.
  final Uint8 nid;

  const NetworkKeyDerivatives({
    required this.identityKey,
    required this.beaconKey,
    required this.privateBeaconKey,
    required this.encryptionKey,
    required this.privacyKey,
    required this.nid,
  });

  factory NetworkKeyDerivatives.fromKey(Data key) {
    return Crypto.calculateKeyDerivatives(Uint8List.fromList(key));
  }
}

class NetworkKey implements MeshKey {
  NetworkKey._({
    required this.name,
    required this.index,
    required this.key,
    required this.phase,
    required this.minSecurity,
    required this.timestamp,
  });

  static Result<NetworkKey> withName(
    String name, {
    required KeyIndex index,
    required Data key,
  }) {
    if (key.length != 16) {
      return Result.error("Invalid key length");
    }
    if (!index.isValidKeyIndex) {
      return Result.error("Invalid key index");
    }

    final nKey = NetworkKey._(
      name: name,
      index: index,
      key: key,
      phase: KeyRefreshPhase.normalOperation,
      // Initially, a Network Key is considered secure, as there are no Nodes
      // that know it other than the Provisioner's one.
      minSecurity: Security.secure,
      timestamp: DateTime.now(),
    );

    nKey._regenerateKeyDerivatives();
    return Result.value(nKey);
  }

  // TODO: internal
  /// Creates the primary Network Key for a mesh network.
  factory NetworkKey.primaryRandom() {
    return NetworkKey.withName(
      'Primary Network Key',
      index: 0,
      key: randomKeyData(),
    ).asValue!.value;
  }

  static Data randomKeyData() {
    return KeyUtils.random128BitKey();
  }

  @override
  final String name;

  @override
  final Uint16 index;

  @override
  final Data key;
  // TODO:
  //  willSet {
  //       oldKey = key
  //       oldNetworkId = networkId
  //       oldKeys = keys
  //   }
  //   didSet {
  //       phase = .keyDistribution
  //       regenerateKeyDerivatives()
  //   }

  Data? get oldKey => _oldKey;
  Data? _oldKey;
  void setOldKey(Data? key) {
    _oldKey = key;
    if (oldKey == null) {
      oldNetworkId = null;
      oldKeys = null;
      phase = KeyRefreshPhase.normalOperation;
    }
  }

  /// Minimum security level for a subnet associated with this Network Key.
  ///
  /// If all Nodes on the subnet associated with this network key have been
  /// provisioned using the Secure Provisioning procedure, then
  /// the value of this property for the subnet is set to ``Security/secure``;
  /// otherwise the value is set to ``Security/insecure`` and the subnet
  /// is considered less secure.
  /// TODO: private(set)
  Security minSecurity;

  /// The Network ID derived from this Network Key. This identifier
  /// is public information.
  /// TODO: private(set)
  late Data networkId;

  /// The Network ID derived from the old Network Key. This identifier
  /// is public information. It is set when ``NetworkKey/oldKey`` is set.
  /// TODO: private(set)
  Data? oldNetworkId;

  /// Key Refresh phase.
  /// TODO: internal(set)
  KeyRefreshPhase phase;

  /// The timestamp represents the last time the phase property has been
  /// updated.
  final DateTime timestamp;

  // TODO: internal
  // TODO: private(set)
  /// Network Key derivatives.
  late NetworkKeyDerivatives keys;

  // TODO: private(set)
  /// Network Key derivatives.
  NetworkKeyDerivatives? oldKeys;

  // TODO: internal
  /// Returns the key set that should be used for encrypting outgoing packets.
  NetworkKeyDerivatives get transmitKeys {
    if (phase == KeyRefreshPhase.keyDistribution && oldKey != null) {
      return oldKeys!;
    }

    return keys;
  }

  void _regenerateKeyDerivatives() {
    // Calculate Network ID.
    networkId = Crypto.calculateNetworkId(Uint8List.fromList(key));
    // Calculate other keys.
    keys = NetworkKeyDerivatives.fromKey(key);

    // When the Network Key is imported from JSON, old key derivatives must
    // be calculated.
    if (oldKey != null && oldNetworkId == null) {
      // Calculate Network ID.
      oldNetworkId = Crypto.calculateNetworkId(Uint8List.fromList(oldKey!));
      // Calculate other keys.
      oldKeys = NetworkKeyDerivatives.fromKey(oldKey!);
    }
  }
}

extension NetworkKeySecurity on NetworkKey {
  void lowerSecurity() {
    minSecurity = Security.insecure;
  }
}
