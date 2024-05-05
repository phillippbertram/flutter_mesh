import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/models/models.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import '../provisioning/algorithms.dart' as algo;
import 'package:pointycastle/export.dart' as pointy;

import '../types.dart';

// TODO: use `cryptography_flutter.FlutterCryptography.enable();`
// this makes the cryptography library a lot faster (up to 100 times)
// @see https://pub.dev/packages/cryptography

// TODO: pointycastle: use Registry for algorithms to make binary smaller
//

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
  }

  static Uint8List generateRandomBits(int lengthInBits) {
    final lengthInBytes = lengthInBits >> 3;
    return generateRandomBytes(lengthInBytes);
  }

  static Uint8List generateRandom128BitKey() {
    return generateRandomBits(128);
  }

  static Uint8List generateRandom256BitKey() {
    return generateRandomBits(256);
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

  static Future<Result<pointy.AsymmetricKeyPair>> generateKeyPairPointy({
    required algo.Algorithm algorithm,
  }) async {
    switch (algorithm) {
      case algo.Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
      case algo.Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
        try {
          final keyGen = pointy.KeyGenerator('EC');
          final ecParams = pointy.ECDomainParameters('prime256v1');
          keyGen.init(pointy.ParametersWithRandom(
            pointy.ECKeyGeneratorParameters(ecParams),
            pointy.SecureRandom('Fortuna')
              ..seed(
                pointy.KeyParameter(
                  Uint8List.fromList(List.generate(32, (i) => i)),
                ),
              ),
          ));

          final keyPair = keyGen.generateKeyPair();
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
    required crypto.EcKeyPair privateKey,
    required Data publicKey,
  }) async {
    // TODO: test this!
    try {
      // we have to add 0x04 as first byte to indicate uncompressed representation.
      final devicePublicKeyData = publicKey.uncompressedRepresentation();

      // Create an algorithm instance
      final algorithm = crypto.Ecdh.p256(length: 32); // 32 bytes == 256 bits

      final devicePublicKey = crypto.EcPublicKey(
        type: crypto.KeyPairType.p256,
        // TODO: I assume, that x and y are 32 bytes each and can easily split up
        x: devicePublicKeyData.sublist(1, 33),
        y: devicePublicKeyData.sublist(33, 65),
      );

      // Calculate the shared secret
      final sharedSecret = await algorithm.sharedSecretKey(
        keyPair: privateKey,
        remotePublicKey: devicePublicKey,
      );

      // Extract the shared secret bytes
      final sharedSecretBytes = await sharedSecret.extractBytes();
      return Result.value(sharedSecretBytes);
    } catch (e) {
      logger.e("Error generating key pair: $e");
      return Result.error(e);
    }
  }

  // Function to calculate the shared secret
  Future<Data> calculateSharedSecretPointy({
    required pointy.ECPrivateKey privateKey,
    // required pointy.ECPublicKey publicKey,
    required Data publicKey,
  }) async {
    final keyAgree = pointy.ECDHBasicAgreement();

    keyAgree.init(privateKey);

    final rawRes = keyAgree
        .calculateAgreement(decodePublicKey(Uint8List.fromList(publicKey)));
    return _bigIntToUint8List(rawRes);
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
    logger.t("Crypto.calculateConfirmation");
    switch (algorithm) {
      case algo.Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:

        // Calculate the Confirmation Salt = s1(confirmationInputs).
        final confirmationSalt =
            calculateS1(Uint8List.fromList(confirmationInputs));

        // Calculate the Confirmation Key = k1(ECDH Secret, confirmationSalt, 'prck')
        final confirmationKey = calculateK1(
          N: Uint8List.fromList(sharedSecret),
          salt: confirmationSalt,
          P: utf8.encode("prck"),
        );

        // Calculate the Confirmation Provisioner using CMAC(random + authValue)
        return calculateCMAC(
          Uint8List.fromList(random + authValue),
          key: confirmationKey,
        );
      case algo.Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
        logger.f(
            "MISSING IMPLEMENTATION: calculateConfirmation for HMAC_SHA256_AES_CCM");
        return Data.empty(); // TODO:
    }
  }

  /// Encrypts the provisioning data using given session key and nonce.
  ///
  /// - parameters:
  ///   - data: Provisioning data to be encrypted.
  ///   - key: Session Key.
  ///   - nonce: Session Nonce.
  /// - returns: Encrypted data.
  static Data encryptProvisioningData(
    Data data, {
    required Data sessionKey,
    required Data sessionNonce,
  }) {
    return calculateCCM(
      data: data,
      key: sessionKey,
      nonce: sessionNonce,
      micSize: 8,
      withAdditionalData: null,
    );
  }

  /// Encrypts given data using the Encryption Key, Nonce and adds MIC
  /// (Message Integrity Check) of given size to the end of the returned cipher text.
  ///
  /// - parameters:
  ///   - data:  The data to be encrypted and authenticated, also known as plaintext.
  ///   - key:   The 128-bit key.
  ///   - nonce: A 104-bit nonce.
  ///   - size:  Length of the MIC to be generated, in bytes.
  ///   - aad:   Additional data to be authenticated.
  /// - returns: Encrypted data concatenated with MIC of given size.
  static Data encryptData(
    Data data, {
    required Data encryptionKey,
    required Data nonce,
    required Uint8 micSize,
    Data? additionalData,
  }) {
    return calculateCCM(
      data: data,
      key: encryptionKey,
      nonce: nonce,
      micSize: micSize,
      withAdditionalData: additionalData,
    );
  }

  /// This method calculates the Session Key, Session Nonce and the Device Key based
  /// on the Confirmation Inputs, 16 or 32-byte Provisioner Random and 16 or 32-byte
  /// device Random.
  ///
  /// - parameters:
  ///   - confirmationInputs: The Confirmation Inputs is built over the provisioning
  ///                         process.
  ///   - sharedSecret: Shared secret obtained in the previous step.
  ///   - provisionerRandom: An array of 16 or 32 random bytes.
  ///   - deviceRandom: An array of 16 or 32 random bytes received from the Device.
  ///   - algorithm: The algorithm to be used.
  /// - returns: The Session Key, Session Nonce and the Device Key.
  static ({
    Data sessionKey,
    Data sessionNonce,
    Data deviceKey,
  }) calculateKeys({
    required Data confirmationInputs,
    required Data sharedSecret,
    required Data provisionerRandom,
    required Data deviceRandom,
    required algo.Algorithm algorithm,
  }) {
    Data confirmationSalt;

    switch (algorithm) {
      case algo.Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM:
        // Calculate the Confirmation Salt = s1(confirmationInputs).
        confirmationSalt =
            Crypto.calculateS1(Uint8List.fromList(confirmationInputs));

      case algo.Algorithm.BTM_ECDH_P256_HMAC_SHA256_AES_CCM:
        confirmationSalt =
            Crypto.calculateS2(Uint8List.fromList(confirmationInputs));
    }

    // Calculate the Provisioning Salt = s1(confirmationSalt + provisionerRandom + deviceRandom)
    final provisioningSalt = Crypto.calculateS1(
      Uint8List.fromList(confirmationSalt + provisionerRandom + deviceRandom),
    );

    // The Session Key is derived as k1(ECDH Shared Secret, provisioningSalt, "prsk")
    final sessionKey = Crypto.calculateK1(
      N: Uint8List.fromList(sharedSecret),
      salt: provisioningSalt,
      P: utf8.encode("prsk"),
    );

    // The Session Nonce is derived as k1(ECDH Shared Secret, provisioningSalt, "prsn")
    // Only 13 least significant bits of the calculated value are used.
    final sessionNonce = Crypto.calculateK1(
      N: Uint8List.fromList(sharedSecret),
      salt: provisioningSalt,
      P: utf8.encode("prsn"),
    ).dropFirst(3);

    // The Device Key is derived as k1(ECDH Shared Secret, provisioningSalt, "prdk")
    final deviceKey = Crypto.calculateK1(
      N: Uint8List.fromList(sharedSecret),
      salt: provisioningSalt,
      P: utf8.encode("prdk"),
    );

    return (
      sessionKey: sessionKey,
      sessionNonce: sessionNonce,
      deviceKey: deviceKey
    );
  }

  /// Calculates salt over given data.
  ///
  /// - parameter data: A non-zero length octet array or ASCII encoded string.
  static Uint8List calculateS1(Uint8List data) {
    final key = Uint8List(16);
    return calculateCMAC(data, key: key);
  }

  static Uint8List calculateS2(Uint8List data) {
    final key = Uint8List(32);
    return calculateHMAC_SHA256(data, key: key);
  }

  /// Calculates Cipher-based Message Authentication Code (CMAC) that uses
  /// AES-128 as the block cipher function, also known as AES-CMAC.
  ///
  /// - parameters:
  ///   - data: Data to be authenticated.
  ///   - key:  The 128-bit key.
  /// - returns: The 128-bit authentication code (MAC).
  static Uint8List calculateCMAC(Uint8List data, {required Uint8List key}) {
    final cmac = pointy.CMac(pointy.AESEngine(), 128)
      ..init(pointy.KeyParameter(key));

    // Process the data to calculate the CMAC
    return cmac.process(data);
  }

  /// RFC 2104 defines HMAC, a mechanism for message authentication using
  /// cryptographic hash functions. FIPS 180-4 defines the SHA-256 secure
  /// hash algorithm.
  ///
  /// The SHA-256 algorithm is used as a hash function for the HMAC mechanism
  /// for the HMAC-SHA-256 function.
  ///
  /// - parameters:
  ///   - data: Data to be authenticated.
  ///   - key:  The 256-bit key.
  /// - returns: The 128-bit authentication code (MAC).
  static Uint8List calculateHMAC_SHA256(Uint8List data,
      {required Uint8List key}) {
    final hmac = pointy.HMac(
        pointy.SHA256Digest(), 64) // HMAC SHA-256: block must be 64 bytes
      ..init(pointy.KeyParameter(key));

    return hmac.process(data);
  }

  /// The network key material derivation function k1 is used to generate
  /// instances of Identity Key and Beacon Key.
  ///
  /// The definition of this derivation function makes use of the MAC function
  /// AES-CMAC(T) with 128-bit key T.
  ///
  /// - parameters:
  ///   - N: 0 or more octets.
  ///   - salt: 128 bit salt.
  ///   - P: 0 or more octets.
  /// - returns: 128-bit key.
  static Uint8List calculateK1({
    required Uint8List N,
    required Uint8List salt,
    required Uint8List P,
  }) {
    final T = calculateCMAC(N, key: salt);
    return calculateCMAC(P, key: T);
  }

  /// RFC3610 defines teh AES Counter with CBC-MAC (CCM).
  /// This method generates ciphertext and MIC (Message Integrity Check).
  ///
  /// @see https://infocenter.nordicsemi.com/index.jsp?topic=%2Fcom.nordic.infocenter.nrf52832.ps.v1.1%2Fccm.html
  ///
  /// - parameters:
  ///   - data:  The data to be encrypted and authenticated, also known as plaintext.
  ///   - key:   The 128-bit key.
  ///   - nonce: A 104-bit nonce.
  ///   - size:  Length of the MIC to be generated, in bytes.
  ///   - aad:   Additional data to be authenticated.
  /// - returns: Encrypted data concatenated with MIC of given size.
  static Data calculateCCM({
    required Data data,
    required Data key,
    required Data nonce,
    required Uint8 micSize,
    Data? withAdditionalData,
  }) {
    final ccm = pointy.CCMBlockCipher(pointy.AESEngine())
      ..init(
        true,
        pointy.AEADParameters(
          pointy.KeyParameter(Uint8List.fromList(key)),
          micSize * 8, // TODO: * 8?
          Uint8List.fromList(nonce),
          Uint8List.fromList(withAdditionalData ?? Data.empty()),
        ),
      );

    return ccm.process(Uint8List.fromList(data));
  }

  // Calculate the 16-bit Virtual Address based on the 128-bit Label UUID.
  ///
  /// - parameter virtualLabel: The Virtual Label of a Virtual Group.
  /// - returns: 16-bit hash, known as Virtual Address.
  static Address calculateVirtualAddress(UUID virtualLabel) {
    final vtad = utf8.encode("vtad");
    final salt = calculateS1(vtad);
    final virtualLabelData = Uint8List.fromList(virtualLabel.hex);
    final hash = calculateCMAC(virtualLabelData, key: salt);

    // Extracting specific bytes and interpreting them as a big-endian UInt16
    var address = (hash[14] << 8) + hash[15];
    address |= 0x8000; // Setting a specific bit high
    address &= 0xBFFF; // Setting a specific bit low

    return Address(address);
  }

  /// Generates the Application Key Identifier based on the key.
  ///
  /// - parameter key: The Application Key.
  /// - returns: The generated AID.
  static Uint8 calculateAid(Data key) {
    return _calculateK4WithN(Uint8List.fromList(key));
  }

  /// The derivation function k4 us used to generate a public value of 6 bits
  /// derived from a private key.
  ///
  /// The definition of this derivation function makes use of the MAC function
  /// AES-CMAC(T) with 128-bit key T.
  ///
  /// - parameter N: 128-bit key.
  /// - returns: UInt8 with 6 LSB bits of a public value derived from the key.
  static Uint8 _calculateK4WithN(Uint8List N) {
    final smk4 = Uint8List.fromList([0x73, 0x6D, 0x6B, 0x34]); // "smk4" as Data
    final s1 = calculateS1(smk4);
    final T = calculateCMAC(N, key: s1);
    final id6_0x01 =
        Uint8List.fromList([0x69, 0x64, 0x36, 0x01]); // "id6" || 0x01
    final result = calculateCMAC(id6_0x01, key: T);
    return result[15] & 0x3F;
  }
}

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

// Helper function to convert BigInt to Uint8List
Uint8List _bigIntToUint8List(BigInt bigInt) {
  // Ensure the byte array is big enough to hold the shared secret
  final bytes = (bigInt.bitLength + 7) >> 3;
  final b256 = BigInt.from(256);
  final result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[bytes - i - 1] = (bigInt % b256).toInt();
    bigInt = bigInt >> 8;
  }
  return result;
}

// Helper function to decode a Uint8List to an ECPublicKey
pointy.ECPublicKey decodePublicKey(Uint8List publicKeyBytes) {
  final ecDomainParameters = pointy.ECDomainParameters('prime256v1');

  // Assume the public key bytes include the 0x04 prefix indicating an uncompressed key
  // Skip the first byte (0x04) and split the rest into x and y coordinates
  final int length = (publicKeyBytes.length - 1) ~/ 2;
  final x = BigInt.parse(
      publicKeyBytes.sublist(1, 1 + length).fold<String>(
          '',
          (previousValue, element) =>
              previousValue + element.toRadixString(16).padLeft(2, '0')),
      radix: 16);
  final y = BigInt.parse(
      publicKeyBytes.sublist(1 + length).fold<String>(
          '',
          (previousValue, element) =>
              previousValue + element.toRadixString(16).padLeft(2, '0')),
      radix: 16);

  // Create an ECPoint from x and y, and then an ECPublicKey from the point
  final point = ecDomainParameters.curve.createPoint(x, y);
  return pointy.ECPublicKey(point, ecDomainParameters);
}
