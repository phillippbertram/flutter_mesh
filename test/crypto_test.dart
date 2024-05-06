// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

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

    group("Key Pair", () {
      // test("generateKeyPair", () {
      //   final keyPair = Crypto.generateKeyPair(
      //     algorithm: Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM,
      //   );

      //   print(keyPair);
      //   expect(keyPair, isNotNull);
      // });
    });

    group("virtual label", () {
      test("calculateVirtualLabel", () {
        const expected = Address(0xADD5);
        const label = UUID.fromString("12345678-1234-1234-1234-12345678ABCD");
        final result = Crypto.calculateVirtualAddress(label);
        expect(result, expected);
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
