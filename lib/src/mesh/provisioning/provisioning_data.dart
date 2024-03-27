import 'package:async/async.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/models/address.dart';
import 'package:flutter_mesh/src/mesh/models/mesh_network.dart';
import 'package:flutter_mesh/src/mesh/models/network_key.dart';
import 'package:flutter_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:flutter_mesh/src/mesh/utils/crypto.dart';

import '../types.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningData.swift#L33

class ProvisioningData {
  ProvisioningData();

  // TODO: private setter
  NetworkKey? networkKey;
  Address? unicastAddress;
  // IvIndex? ivIndex; TODO:

  // TODO: make private
  crypto.SecretKey? privateKey; // TODO: SecKey
  crypto.PublicKey? publicKey; // TODO: SecKey
  Data? sharedSecret;
  bool? oobPublicKey;

  // TODO: private setter
  Algorithm? algorithm;
  Data? provisionerRandom;
  Data? provisionerPublicKey;

  /// The Confirmation Inputs is built over the provisioning process.
  ///
  /// It is composed of (in that order):
  /// - Provisioning Invite PDU,
  /// - Provisioning Capabilities PDU,
  /// - Provisioning Start PDU,
  /// - Provisioner's Public Key,
  /// - Provisionee's Public Key.
  /// TODO: Data(capacity: 1 + 11 + 5 + 64 + 64) was set in Swift
  final confirmationInputs = Data.from([]);

  void prepare({
    required MeshNetwork network,
    required NetworkKey netKey,
    required Address unicastAddress,
  }) {
    logger.e("MISSING IMPLEMENTATION - IVIndex");
    networkKey = netKey;
    this.unicastAddress = unicastAddress;
    // this.ivIndex = network.ivIndex; // TODO:
  }
}

extension ProvisioningDataX on ProvisioningData {
  /// This method adds the given PDU to the Provisioning Inputs.
  /// Provisioning Inputs are used for authenticating the Provisioner
  /// and the Unprovisioned Device.
  ///
  /// This method must be called (in order) for:
  /// - Provisioning Invite,
  /// - Provisioning Capabilities,
  /// - Provisioning Start,
  /// - Provisioner's Public Key,
  /// - Provisionee's Public Key.
  void accumulate(Data data) {
    confirmationInputs.addAll(data);
  }

  Future<Result<void>> generateKeys({required Algorithm algorithm}) async {
    // TODO: implement this
    logger.t("Generating keys for algorithm: $algorithm");

    final keyPairRes = await Crypto.generateKeyPair(algorithm: algorithm);
    if (keyPairRes.isError) {
      return Result.error(keyPairRes.asError!.error);
    }
    final keyPair = keyPairRes.asValue!.value;

    privateKey = keyPair.privateKey;
    publicKey = keyPair.publicKey;
    provisionerPublicKey =
        keyPair.publicKey.toDer(); // TODO: is toDer() correct?

    this.algorithm = algorithm;
    provisionerRandom = Crypto.generateRandomBits(algorithm.lengthInBits);

    return Result.value(null);
  }

  /// Call this method when the Provisionee's Public Key has been
  /// obtained.
  ///
  /// This must be called after generating keys.
  ///
  /// - parameters:
  ///   - key: The Provisionee's Public Key.
  ///   - oob: A flag indicating whether the Public Key was obtained Out-Of-Band.
  /// - throws: This method throws when generating ECDH Secure
  ///           Secret failed.
  Result<void> provisionerDidObtainPublicKey(Data key, {required bool oob}) {
    // TODO: implement this
    if (privateKey == null) {
      return Result.error('Invalid state: Private key is missing.');
    }

    logger.e("MISSING IMPLEMENTATION");
    // sharedSecret =
    //     calculateSharedSecret(privateKey: privateKey!, publicKey: key);
    oobPublicKey = oob;

    return Result.error('Not implemented');
  }
}
