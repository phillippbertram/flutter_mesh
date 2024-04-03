
import 'package:async/async.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:flutter_mesh/src/mesh/utils/crypto.dart';

import '../models/iv_index.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningData.swift#L33
class ProvisioningData {
  ProvisioningData();

  // TODO: private setter
  NetworkKey? networkKey;
  Address? unicastAddress;
  IvIndex? ivIndex;

  // TODO: make private
  crypto.EcKeyPair? keyPair;
  Data? sharedSecret;
  Data? authValue;
  Data? deviceConfirmation;
  Data? deviceRandom;
  bool? oobPublicKey;

  // TODO: private setter
  Algorithm? algorithm;
  Data? deviceKey;
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
  final confirmationInputs = Data.from([], growable: true);

  void prepare({
    required MeshNetwork network,
    required NetworkKey netKey,
    required Address unicastAddress,
  }) {
    logger.t("ProvisioningData.prepare");
    networkKey = netKey;
    ivIndex = network.ivIndex;
    this.unicastAddress = unicastAddress;
  }
}

extension ProvisioningDataX on ProvisioningData {
  /// Returns the Node's security level based on the provisioning method.
  Security get security {
    if (oobPublicKey == true) {
      return Security.secure;
    }
    return Security.insecure;
  }

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
    final lengthBefore = confirmationInputs.length;
    confirmationInputs.addAll(data);
    print(
        "<<< accumulate: ${data.length} -> ${confirmationInputs.length} (was $lengthBefore)");
  }

  Future<Result<void>> generateKeys({required Algorithm algorithm}) async {
    // TODO: implement this
    logger.t("Generating keys for algorithm: $algorithm");

    final keyPairRes = await Crypto.generateKeyPair(algorithm: algorithm);
    if (keyPairRes.isError) {
      return Result.error(keyPairRes.asError!.error);
    }
    final keyPair = keyPairRes.asValue!.value;
    this.keyPair = keyPair;

    final pubKey = await keyPair.extractPublicKey();

    // TODO: I assume that this is how the public key get's concatenated as data
    provisionerPublicKey = Uint8List.fromList(pubKey.x + pubKey.y);

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
  Future<Result<void>> provisionerDidObtainDevicePublicKey(
    Data key, {
    required bool oob,
  }) async {
    logger.t(
      "ProvisioningData.provisionerDidObtainPublicKey key: ${key.length}, oob: $oob",
    );

    if (keyPair == null) {
      return Result.error('Invalid state: Private key is missing.');
    }

    final sharedSecretRes = await Crypto.calculateSharedSecret(
      privateKey: keyPair!,
      publicKey: key,
    );
    if (sharedSecretRes.isError) {
      return Result.error(sharedSecretRes.asError!.error);
    }

    sharedSecret = sharedSecretRes.asValue!.value;
    oobPublicKey = oob;

    return Result.value(null);
  }

  /// Call this method when the Auth Value has been obtained.
  void provisionerDidObtainAuthValue(Data authValue) {
    logger.t(
        "ProvisioningData.provisionerDidObtainAuthValue: ${authValue.length}");
    this.authValue = authValue;
  }

  /// Call this method when the device Provisioning Confirmation
  /// has been obtained.
  void provisionerDidObtainDeviceConfirmation(Data confirmation) {
    logger.t(
        "ProvisioningData.provisionerDidObtainDeviceConfirmation: ${confirmation.length}");
    deviceConfirmation = confirmation;
  }

  /// Call this method when the device Provisioning Random
  /// has been obtained.
  void provisionerDidObtainDeviceRandom(Data random) {
    deviceRandom = random;
  }

  /// This method validates the received Provisioning Confirmation and
  /// matches it with one calculated locally based on the Provisioning
  /// Random received from the device and Auth Value.
  ///
  /// - throws: The method throws when the validation failed, or
  ///           it was called before all data were ready.
  bool validateConfirmation() {
    if (deviceRandom == null || authValue == null || sharedSecret == null) {
      logger.e(
          "Invalid state: deviceRandom, authValue, or sharedSecret is missing.");
      return false;
    }

    final confirmation = Crypto.calculateConfirmation(
      confirmationInputs: confirmationInputs,
      sharedSecret: sharedSecret!,
      random: deviceRandom!,
      authValue: authValue!,
      algorithm: algorithm!,
    );

    if (listEquals(deviceConfirmation, confirmation)) {
      logger.t("Confirmation succeeded.");
      return true;
    }

    return false;
  }

  /// Returns the Provisioner Confirmation value.
  ///
  /// The Auth Value must be set prior to calling this method.
  Data get provisionerConfirmation {
    return Crypto.calculateConfirmation(
      confirmationInputs: confirmationInputs,
      sharedSecret: sharedSecret!,
      random: provisionerRandom!,
      authValue: authValue!,
      algorithm: algorithm!,
    );
  }

  /// Returns the encrypted Provisioning Data together with MIC.
  ///
  /// Data will be encrypted using Session Key and Session Nonce.
  /// For that, all properties should be set when this method is called.
  /// Returned value is 25 + 8 bytes long, where the MIC is the last 8 bytes.
  Data get encryptedProvisioningDataWithMic {
    final keys = Crypto.calculateKeys(
      confirmationInputs: confirmationInputs,
      sharedSecret: sharedSecret!,
      provisionerRandom: provisionerRandom!,
      deviceRandom: deviceRandom!,
      algorithm: algorithm!,
    );
    logger.e(
      "This might not be complete as we do not have ivIndex and networkKey properly implemented",
    );
    deviceKey = keys.deviceKey;
    final flags = _Flags(ivIndex: ivIndex!, networkKey: networkKey!);
    final key = networkKey!.phase == KeyRefreshPhase.keyDistribution
        ? networkKey!.oldKey!
        : networkKey!.key;

    // final bytes = BytesBuilder();

    final data = Data.from(key)
        .addUint16(
          networkKey!.index,
          endian: Endian.big,
        )
        .addUint8(flags.value)
        .addUint32(ivIndex!.index, endian: Endian.big)
        .addUint16(
          unicastAddress!.value,
          endian: Endian.big,
        );

    final encrypted = Crypto.encryptProvisioningData(
      data,
      sessionKey: keys.sessionKey,
      sessionNonce: keys.sessionNonce,
    );
    return encrypted;
  }
}

class _Flags {
  final Uint8 value;

  const _Flags._(this.value);

  static const useNewKeys = _Flags._(1 << 0);
  static const ivUpdateActive = _Flags._(1 << 1);

  factory _Flags({
    required IvIndex ivIndex,
    required NetworkKey networkKey,
  }) {
    var value = 0;
    if (networkKey.phase == KeyRefreshPhase.usingNewKeys) {
      value |= 1 << 0;
    }
    if (ivIndex.updateActive) {
      value |= 1 << 1;
    }
    return _Flags._(value);
  }
}
