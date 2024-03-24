// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/Oob.swift#L36

// TODO: sealed class?
import 'dart:typed_data';

import 'package:dart_mesh/src/mesh/mesh.dart';
import 'package:dart_mesh/src/mesh/type_extensions/data.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// TODO: use sealed class?
// abstract class OobInformation {
//   const OobInformation();

//   void handle();
// }

// class ElectronicURI extends OobInformation {
//   final String uri;
//   const ElectronicURI(this.uri);

//   @override
//   void handle() {
//     // Handle electronic URI
//   }
// }

// class QrCode extends OobInformation {
//   final String qrData;
//   const QrCode(this.qrData);

//   @override
//   void handle() {
//     // Handle QR code
//   }
// }

class OobInformation {
  final Uint16 rawValue;

  const OobInformation._(this.rawValue);

  static const OobInformation other = OobInformation._(1 << 0);
  static const OobInformation electronicURI = OobInformation._(1 << 1);
  static const OobInformation qrCode = OobInformation._(1 << 2);
  static const OobInformation barCode = OobInformation._(1 << 3);
  static const OobInformation nfc = OobInformation._(1 << 4);
  static const OobInformation number = OobInformation._(1 << 5);
  static const OobInformation string = OobInformation._(1 << 6);
  static const OobInformation supportForCertificateBasedProvisioning =
      OobInformation._(1 << 7);
  static const OobInformation supportForProvisioningRecords =
      OobInformation._(1 << 8);
  // Bits 9-10 are reserved for future use.
  static const OobInformation onBox = OobInformation._(1 << 11);
  static const OobInformation insideBox = OobInformation._(1 << 12);
  static const OobInformation onPieceOfPaper = OobInformation._(1 << 13);
  static const OobInformation insideManual = OobInformation._(1 << 14);
  static const OobInformation onDevice = OobInformation._(1 << 15);

  /// Checks if a particular option is set.
  bool contains(OobInformation option) {
    return rawValue & option.rawValue == option.rawValue;
  }

  /// Parses the raw advertisement data to extract OOB Information.
  /// This is a placeholder to demonstrate the concept. You'll need to adapt
  /// it based on how you're receiving and parsing your advertisement data in Dart.
  static OobInformation? fromAdvertisementData(
      AdvertisementData advertisementData) {
    if (advertisementData.serviceData.isEmpty) {
      return null;
    }

    final data =
        advertisementData.serviceData[Guid(MeshProvisioningService().uuid)];
    if (data == null || !(data.length == 18 || data.length == 22)) {
      return null;
    }

    // OOB Information is using Little Endian in the Advertising Data.
    final rawValue = data.readUint16(offset: 16, endian: Endian.little);
    return OobInformation._(rawValue);
  }
}
