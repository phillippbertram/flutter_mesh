part of 'model.dart';

extension ModelNameX on Model {
  /// The Model name as defined in Bluetooth Mesh Model Specification.
  String? get name {
    if (!isBluetoothSIGAssigned) {
      return 'Vendor Model';
    }
    switch (modelIdentifier) {
      // Foundation
      case 0x0000:
        return 'Configuration Server';
      case 0x0001:
        return 'Configuration Client';
      case 0x0002:
        return 'Health Server';
      case 0x0003:
        return 'Health Client';
      // Generic
      case 0x1000:
        return 'Generic OnOff Server';
      case 0x1001:
        return 'Generic OnOff Client';
      case 0x1002:
        return 'Generic Level Server';
      case 0x1003:
        return 'Generic Level Client';
      case 0x1004:
        return 'Generic Default Transition Time Server';
      case 0x1005:
        return 'Generic Default Transition Time Client';
      case 0x1006:
        return 'Generic Power OnOff Server';
      case 0x1007:
        return 'Generic Power OnOff Setup Server';
      case 0x1008:
        return 'Generic Power OnOff Client';
      case 0x1009:
        return 'Generic Power Level Server';
      case 0x100A:
        return 'Generic Power Level Setup Server';
      case 0x100B:
        return 'Generic Power Level Client';
      case 0x100C:
        return 'Generic Battery Server';
      case 0x100D:
        return 'Generic Battery Client';
      case 0x100E:
        return 'Generic Location Server';
      case 0x100F:
        return 'Generic Location Setup Server';
      case 0x1010:
        return 'Generic Location Client';
      case 0x1011:
        return 'Generic Admin Property Server';
      case 0x1012:
        return 'Generic Manufacturer Property Server';
      case 0x1013:
        return 'Generic User Property Server';
      case 0x1014:
        return 'Generic Client Property Server';
      case 0x1015:
        return 'Generic Property Client';
      // Sensors
      case 0x1100:
        return 'Sensor Server';
      case 0x1101:
        return 'Sensor Setup Server';
      case 0x1102:
        return 'Sensor Client';

      default:
        return null;
    }
  }
}
