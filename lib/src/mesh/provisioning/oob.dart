// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/Oob.swift#L36

// TODO: sealed class?

import 'package:flutter/foundation.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'oob.freezed.dart';

// @see https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/Oob.swift

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

/// The authentication method chosen for provisioning.
@freezed
sealed class AuthenticationMethod with _$AuthenticationMethod {
  /// No OOB authentication.
  /// - warning: This method is considered not secure.
  const factory AuthenticationMethod.noOob() = NoOob;

  /// Static OOB authentication.
  ///
  /// User will be asked to provide 16 or 32 byte hexadecimal value.
  /// The value can be read from the device, QR code, website, etc.
  /// See ``UnprovisionedDevice/oobInformation`` for location.
  const factory AuthenticationMethod.staticOob() = StaticOob;

  /// Output OOB authentication.
  ///
  /// The Provisionee will signal a random value using specified method.
  /// The value should be provided during provisioning using
  /// ``ProvisioningDelegate/authenticationActionRequired(_:)``.
  ///
  /// - parameters:
  ///   - action: The chosen action.
  ///   - size: Number of digits or letters that can be output
  ///           (e.g., displayed or spoken). Size must be in range 1...8.
  const factory AuthenticationMethod.outputOob({
    required OutputAction action,
    required int size,
  }) = OutputOob;

  /// Input OOB authentication.
  ///
  /// User need to input a value displayed on the Provisioner's screen on the
  /// Unprovisioned Device. The value to display to the user will be given using
  /// ``ProvisioningDelegate/authenticationActionRequired(_:)``.
  ///
  /// When user completes entering the value ``ProvisioningDelegate/inputComplete()``
  /// will be called.
  ///
  /// - parameters:
  ///   - action: The chosen input action.
  ///   - size: Number of digits or letters that can be entered.
  ///           Size must be in range 1...8.
  const factory AuthenticationMethod.inputOob({
    required InputAction action,
    required int size,
  }) = InputOob;
}

/// Available output actions to be performed during provisioning.
///
/// For example,if the Unprovisioned Device is a light, then it would blink random
/// number of times. That number should be provided to
/// ``ProvisioningDelegate/authenticationActionRequired(_:)``.
enum OutputAction {
  blink,
  beep,
  vibrate,
  outputNumeric,
  outputAlphanumeric,
}

extension OutputActionExtension on OutputAction {
  Uint8 get value {
    switch (this) {
      case OutputAction.blink:
        return 0;
      case OutputAction.beep:
        return 1;
      case OutputAction.vibrate:
        return 2;
      case OutputAction.outputNumeric:
        return 3;
      case OutputAction.outputAlphanumeric:
        return 4;
    }
  }
}

/// Available output actions to be performed during provisioning.
///
/// For example,if the Unprovisioned Device is a light, then it would blink random
/// number of times. That number should be provided to
/// ``ProvisioningDelegate/authenticationActionRequired(_:)``.
enum InputAction {
  push,
  twist,
  inputNumeric,
  inputAlphanumeric,
}

extension InputActionExtension on InputAction {
  Uint8 get value {
    switch (this) {
      case InputAction.push:
        return 0;
      case InputAction.twist:
        return 1;
      case InputAction.inputNumeric:
        return 2;
      case InputAction.inputAlphanumeric:
        return 3;
    }
  }
}
