import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:flutter_mesh/src/mesh/utils/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

// TODO: write tests

void main() {
  group('Crypto', () {
    group('Random Data', () {
      test('generateRandomBytes', () {
        final rand1 = Crypto.generateRandomBytes(1);
        final rand1_2 = Crypto.generateRandomBytes(1);
        final rand2 = Crypto.generateRandomBytes(2);
        final rand16 = Crypto.generateRandomBytes(16);
        expect(rand1.length, 1);
        expect(rand1_2.length, 1);
        expect(rand1, isNot(rand1_2));
        expect(rand2.length, 2);
        expect(rand16.length, 16);
      });

      test('generateRandomBits', () {
        final rand16 = Crypto.generateRandomBits(128);
        final rand16_2 = Crypto.generateRandomBits(128);
        final rand32 = Crypto.generateRandomBits(256);
        expect(rand16.length, 16);
        expect(rand16_2.length, 16);
        expect(rand16, isNot(rand16_2));
        expect(rand32.length, 32);
      });

      test('generateRandom128BitKey', () {
        final key1 = Crypto.generateRandom128BitKey();
        final key2 = Crypto.generateRandom128BitKey();
        expect(key1.length, 16);
        expect(key2.length, 16);
        expect(key1, isNot(key2));
      });

      test('generateRandom256BitKey', () {
        final key1 = Crypto.generateRandom256BitKey();
        final key2 = Crypto.generateRandom256BitKey();
        expect(key1.length, 32);
        expect(key2.length, 32);
        expect(key1, isNot(key2));
      });
    });

    group("obfuscation", () {
      final source = DataUtils.fromHex("050102030001")!;
      final random = DataUtils.fromHex("00112233445566")!;
      final key = DataUtils.fromHex("0123456789ABCDEF0123456789ABCDEF")!;
      const Uint32 ivIndex = 0x12345678;

      test("obfuscate and deobfuscate", () {
        final expected = DataUtils.fromHex("9C0DAE8BC512")!;

        final obfuscated = Crypto.obfuscateData(
          source.toUint8List(),
          random: random.toUint8List(),
          ivIndex: ivIndex,
          privacyKey: key.toUint8List(),
        );
        expect(obfuscated, expected);

        final deobfuscated = Crypto.obfuscateData(
          obfuscated,
          random: random.toUint8List(),
          ivIndex: ivIndex,
          privacyKey: key.toUint8List(),
        );
        expect(deobfuscated, source);
      });
    });

    group("Key Derivatives", () {
      final key = DataUtils.fromHex("f7a2a44f8e8a8029064f173ddc1e2b00")!;
      const Uint8 expectedNID = 0x7F;
      final expectedEncryptionKey =
          DataUtils.fromHex("9f589181a0f50de73c8070c7a6d27f46");
      final expectedPrivacyKey =
          DataUtils.fromHex("4c715bd4a64b938f99b453351653124f");
      final expectedIdentityKey =
          DataUtils.fromHex("877DE1A131C87A8C6767E655061963A7");
      final expectedBeaconKey =
          DataUtils.fromHex("CCAE3C53A3BB6FAB728EE94A390DC91F");
      final expectedPrivateBeaconKey =
          DataUtils.fromHex("6be76842460b2d3a5850d4698409f1bb");

      test("calculateKeyDerivatives", () {
        final result = Crypto.calculateKeyDerivatives(key.toUint8List());
        expect(result.nid, expectedNID);
        expect(result.encryptionKey, expectedEncryptionKey);
        expect(result.privacyKey, expectedPrivacyKey);
        expect(result.identityKey, expectedIdentityKey);
        expect(result.beaconKey, expectedBeaconKey);
        expect(result.privateBeaconKey, expectedPrivateBeaconKey);
      });
    });

    group("encryption", () {
      final data = DataUtils.fromHex("00112233445566778899AABBCCDDEEFF")!;
      final key = DataUtils.fromHex("0123456789ABCDEF0123456789ABCDEF")!;
      final nonce = DataUtils.fromHex("00112233445566778899AABBCC")!;

      test("mic4", () {
        final expected =
            DataUtils.fromHex("6C7854C1E573CD62155BFA987C70673D273AB343");

        final result = Crypto.encryptData(
          data,
          encryptionKey: key,
          nonce: nonce,
          micSize: 4,
        );

        expect(result, expected);

        // final encrypted = result.sublist(0, data.length);
        // final mic = result.sublist(data.length, result.length);
        // final text = Crypto.decryptData(
        //   encrypted,
        //   encryptionKey: key,
        //   nonce: nonce,
        //   mic: mic,
        // );
      });

      test("mic8", () {
        final expected = DataUtils.fromHex(
            "6C7854C1E573CD62155BFA987C70673D5CFCB5AC7E3CEA62");

        final result = Crypto.encryptData(
          data,
          encryptionKey: key,
          nonce: nonce,
          micSize: 8,
        );

        expect(result, expected);
      });
    });

    group("virtual label", () {
      test("calculateVirtualLabel", () {
        const expected = Address(0xADD5);
        const label = UUID.fromString("12345678-1234-1234-1234-12345678ABCD");
        final result = Crypto.calculateVirtualAddress(label);
        expect(result, expected);
      });
    });

    group("NetworkId", () {
      test("calculateNetworkId", () {
        final key = DataUtils.fromHex("f7a2a44f8e8a8029064f173ddc1e2b00")!;
        final expected = DataUtils.fromHex("ff046958233db014")!;

        final nid = Crypto.calculateNetworkId(key.toUint8List());
        expect(nid, expected);
      });
    });

    group("Aid", () {
      test("calculateAid", () {
        final key = DataUtils.fromHex("3216d1509884b533248541792b877f98")!;
        const expectedAid = 0x38;
        final aid = Crypto.calculateAid(key);
        expect(aid, expectedAid);
      });
    });
  });
}
