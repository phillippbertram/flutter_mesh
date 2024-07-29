import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

extension CompanyIdentifierExtension on Uint16 {
  String? companyNameForId() => CompanyIdentifier.nameForId(this);
}

// Source: https://www.bluetooth.com/specifications/assigned-numbers/
// TODO:
abstract class CompanyIdentifier {
  static String? nameForId(Uint16 id) {
    logger.f("MISSING IMPLEMENTATION -  CompanyIdentifier.nameForId");
    switch (id) {
      case 0x0059:
        return "Nordic Semiconductor ASA";
      case 0x0527:
        return "Albrecht JUNG";
    }
    return null;
  }
}
