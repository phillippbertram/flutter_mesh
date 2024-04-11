import 'package:flutter_mesh/src/mesh/mesh.dart';

extension ModelX on Model {
  /// Returns the Company Identifier as a `String`.
  String companyName() {
    if (isBluetoothSIGAssigned) {
      return "Bluetooth SIG";
    }

    if (companyIdentifier != null) {
      final companyIdName = companyIdentifier!.companyNameForId();
      if (companyIdName != null) {
        return companyIdName;
      } else {
        return "Company ID: $companyIdentifier";
      }
    } else {
      return "Company ID: Unknown";
    }
  }
}
