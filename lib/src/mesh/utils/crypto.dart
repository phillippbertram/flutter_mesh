import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter_mesh/src/logger/logger.dart';
import '../provisioning/algorithms.dart' as algo;
import 'package:pointycastle/export.dart' as pointy;

import '../types.dart';

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
    switch (algorithm) {
      case algo.Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
      case algo.Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
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
      publicKey = publicKey.uncompressedRepresentation();

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

  /// This method calculates the Provisioning Confirmation based on the
  /// Confirmation Inputs, 16 or 32-byte Random and 16 or 32-byte AuthValue.
  ///
  /// - parameters:
  ///   - confirmationInputs: The Confirmation Inputs is built over the provisioning
  ///                         process.
  ///   - sharedSecret: Shared secret obtained in the previous step.
  ///   - random: An array of 16 or 32 bytes random bytes, depending on the algorithm.
  ///   - authValue: The Auth Value calculated based on the Authentication Method.
  ///   - algorithm: The algorithm to be used.
  /// - returns: The Provisioning Confirmation value.
  static Data calculateConfirmation({
    required Data confirmationInputs,
    required Data sharedSecret,
    required Data random,
    required Data authValue,
    required algo.Algorithm algorithm,
  }) {
    logger.f("MISSING IMPLEMENTATION: Crypto.calculateConfirmation");
    return Data.empty(); // TODO:
  }

  /// Calculates salt over given data.
  ///
  /// - parameter data: A non-zero length octet array or ASCII encoded string.

  static Uint8List calculateS1(Uint8List data) {
    final key = Uint8List(16);
    return calculateCMAC(data, key);
  }

  static Uint8List calculateCMAC(Uint8List data, Uint8List key) {
    // Create a BlockCipher using AES
    final blockCipher = pointy.BlockCipher('AES/CMAC');

    // Initialize the cipher with the key
    blockCipher.init(true, pointy.KeyParameter(key));

    // Process the data to calculate the CMAC
    return blockCipher.process(data);
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

extension DataCrypto on Data {
  Data uncompressedRepresentation() {
    final publicKeyBytes = Data.from(this);
    // Create a new Uint8List with an additional byte at the start
    final uncompressedKey = Uint8List(publicKeyBytes.length + 1);

    // Set the first byte to 0x04 to mark it as uncompressed
    uncompressedKey[0] = 0x04;

    // Copy the original public key data after the 0x04
    uncompressedKey.setRange(1, uncompressedKey.length, publicKeyBytes);

    return uncompressedKey;
  }
}

// void generateECDHKeyPairPointy() {
//   // Create an ECC domain parameters object.
//   var ecDomainParameters = pointy.ECDomainParameters('prime256v1');

//   // Create a secure random generator.
//   var secureRandom = pointy.FortunaRandom();
//   var randomSeed = List<int>.generate(
//       32, (i) => i); // This should be replaced with a secure random seed.
//   secureRandom.seed(pointy.KeyParameter(Uint8List.fromList(randomSeed)));

//   // Generate the key pair.
//   var keyGenerator = pointy.ECKeyGenerator()
//     ..init(pointy.ParametersWithRandom(
//         pointy.ECKeyGeneratorParameters(ecDomainParameters), secureRandom));
//   var keyPair = keyGenerator.generateKeyPair();

//   final privateKey = keyPair.privateKey as pointy.ECPrivateKey;
//   final publicKey = keyPair.publicKey as pointy.ECPublicKey;

//   // Your private and public keys are now ready to be used.
//   // You can access the private and public key bytes as needed.
//   print("Private Key: ${privateKey.d}");
//   print("Public Key: ${publicKey.Q}");
// }

// Future<void> generateECDHKeyPair() async {
//   // Use the cryptography package to generate an elliptic curve key pair
//   final algorithm = crypto.Ecdh.p256(length: 32);
//   final keyPair = await algorithm.newKeyPair();

//   // Extract the private key and public key
//   final privateKey = await keyPair.extract();
//   final publicKey = await keyPair.extractPublicKey();

//   // The privateKey and publicKey are now Uint8List byte arrays that can be used directly.
//   // You can encode these bytes to Base64 or any other format if you need to store or transmit them.
//   print('Private Key: $privateKey');
//   print('Public Key: $publicKey');

//   final publicKeyData = Uint8List.fromList(publicKey.x + publicKey.y);
//   print('Public Key Data: 0x${publicKeyData.toHex()}');
// }
