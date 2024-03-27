// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Type%20Extensions/Data%2BKeys.swift#L36

import 'dart:math';


import '../types.dart';
import '../utils/crypto.dart';

final random = Random.secure();

class DataUtils {
  // TODO: use crypto library?
  static Data random128BitKey() {
    final d = Crypto.generateRandomBits(256);
    return d.toList();
  }
}
