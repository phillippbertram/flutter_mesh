// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Type%20Extensions/Data%2BKeys.swift#L36

import 'dart:math';

import '../types.dart';

final random = Random.secure();

class DataUtils {
  // TODO: use crypto library?
  static Data random128BitKey() {
    return Data.from(List.generate(16, (index) => random.nextInt(128)));
  }
}
