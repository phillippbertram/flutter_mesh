// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

import 'package:flutter_mesh/src/mesh/utils/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
