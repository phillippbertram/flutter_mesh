import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter_mesh/src/logger/logger.dart';
import '../provisioning/algorithms.dart' as algo;
import '../types.dart';

// import 'package:pointycastle/export.dart';

// TODO: use `cryptography_flutter.FlutterCryptography.enable();`
// this makes the cryptography library a lot faster (up to 100 times)
// @see https://pub.dev/packages/cryptography

class Crypto {
  const Crypto._();

  // TODO: test this
  /// Generates a random number of bytes.
  /// - parameter length: The length of the random bytes.
  /// - returns: The random bytes.
  static Uint8List generateRandomBytes(int length) {
    final random = crypto.SecureRandom.fast;

    return Uint8List.fromList(
      List.generate(
        length,
        (index) => random.nextInt(256),
      ),
    );

    // ALTERNATIVE:
    // final random = pointycastle.FortunaRandom(); // use another algorithm in constructor.
    // return random.nextBytes(length);
  }

  static Uint8List generateRandomBits(int lengthInBits) {
    final lengthInBytes = lengthInBits >> 3;
    return generateRandomBytes(lengthInBytes);
  }

  // TODO: test this
  /// Generates a pair of Private and Public Keys using P256 Elliptic Curve
  /// algorithm.
  ///
  /// @see https://www.bluetooth.com/blog/provisioning-a-bluetooth-mesh-network-part-1/
  ///
  /// - parameter algorithm: The algorithm for key pair generation.
  /// - returns: The Private and Public Key pair.
  /// - throws: This method throws an error if the key pair generation has failed
  ///           or the given algorithm is not supported.
  static Future<Result<crypto.EcKeyPair>> generateKeyPair({
    required algo.Algorithm algorithm,
  }) async {
    // TODO: this is the implementation for shared generating shared secreet
    try {
      // Elliptic Curve Diffie-Hellman (ECDH) with P-256 curve
      final algo = crypto.Ecdh.p256(length: 32); // 32 bytes == 256 bits
      final keyPair = await algo.newKeyPair();
      return Result.value(keyPair);
    } catch (e) {
      logger.e("Error generating key pair: $e");
      return Result.error(e);
    }
  }

  /// Calculates the Shared Secret based on the given Public Key
  /// and the local Private Key.
  ///
  /// Elliptic Curve Diffie–Hellman (ECDH) is an anonymous key agreement protocol that allows two parties,
  /// each having an elliptic curve public–private key pair, to establish a shared secret over an insecure channel.
  /// ECDH’s purpose in Bluetooth mesh provisioning is to allow the creation of a secure link between
  /// the provisioner and the unprovisioned device.
  /// It uses public and private keys to distribute a symmetric secret key
  /// which the two devices can then use for encryption and decryption of subsequent messages.
  ///
  /// - parameters:
  ///   - privateKey: The local device's Private Key.
  ///   - publicKey: The device's Public Key as bytes.
  /// - returns: The ECDH Shared Secret.
  static Future<Result<Data>> calculateSharedSecret({
    required crypto.KeyPair privateKey,
    required Data publicKey,
  }) async {
    // TODO: test this!
    try {
      publicKey = publicKey.markUncompressed(publicKey);

      // Elliptic Curve Diffie-Hellman (ECDH) with P-256 curve
      final algo = crypto.Ecdh.p256(length: 32); // 32 bytes == 256 bits

      final wand = await algo.newKeyExchangeWandFromKeyPair(privateKey);
      final sharedSecret = await wand.sharedSecretKey(
        remotePublicKey: crypto.SimplePublicKey(
          publicKey,
          type: crypto.KeyPairType.p256,
        ),
      );

      final sskBytes = await sharedSecret.extractBytes();
      return Result.value(sskBytes);
    } catch (e) {
      logger.e("Error generating key pair: $e");
      return Result.error(e);
    }
  }

  //
  // static Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateKeyPair({
  //   required algo.Algorithm algorithm,
  // }) async {
  //   switch (algorithm) {
  //     case algo.Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
  //     case algo.Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
  //       return generateP256KeyPair();
  //   }
  // }

  // static AsymmetricKeyPair<PublicKey, PrivateKey> generateP256KeyPair() {
  //   final keyGen = KeyGenerator("EC");
  //   keyGen.init(
  //     ParametersWithRandom(
  //       ECKeyGeneratorParameters(ECCurve_prime256v1()),
  //       SecureRandom('Fortuna'),
  //     ),
  //   );

  //   return keyGen.generateKeyPair();
  // }

  // static Future<crypto.KeyPair> generateKeyPair({
  //   required algo.Algorithm algorithm,
  // }) async {
  //   final algo = crypto.Ecdh.p256(length: 256);
  //   final keyPair = await algo.newKeyPair();
  //   return keyPair;
  // }
}

extension on Data {
  Data markUncompressed(
    Data publicKey,
  ) {
    final publicKeyBytes = publicKey;
    // Create a new Uint8List with an additional byte at the start
    final uncompressedKey = Uint8List(publicKeyBytes.length + 1);

    // Set the first byte to 0x04 to mark it as uncompressed
    uncompressedKey[0] = 0x04;

    // Copy the original public key data after the 0x04
    uncompressedKey.setRange(1, uncompressedKey.length, publicKeyBytes);

    return uncompressedKey;
  }
}
