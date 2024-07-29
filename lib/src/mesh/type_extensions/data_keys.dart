// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Type%20Extensions/Data%2BKeys.swift

import 'dart:math';

import '../types.dart';
import '../utils/crypto.dart';

final random = Random.secure();

// TODO: needed?
abstract class KeyUtils {
  static Data random128BitKey() {
    return Crypto.generateRandom128BitKey();
  }

  static Data random256BitKey() {
    return Crypto.generateRandom256BitKey();
  }
}
