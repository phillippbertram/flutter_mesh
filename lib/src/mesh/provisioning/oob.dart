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

  static const other = OobInformation._(1 << 0);
  static const electronicURI = OobInformation._(1 << 1);
  static const qrCode = OobInformation._(1 << 2);
  static const barCode = OobInformation._(1 << 3);
  static const nfc = OobInformation._(1 << 4);
  static const number = OobInformation._(1 << 5);
  static const string = OobInformation._(1 << 6);
  static const supportForCertificateBasedProvisioning =
      OobInformation._(1 << 7);
  static const supportForProvisioningRecords = OobInformation._(1 << 8);
  // Bits 9-10 are reserved for future use.
  static const onBox = OobInformation._(1 << 11);
  static const insideBox = OobInformation._(1 << 12);
  static const onPieceOfPaper = OobInformation._(1 << 13);
  static const insideManual = OobInformation._(1 << 14);
  static const onDevice = OobInformation._(1 << 15);

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
  blink._(1),
  beep._(2),
  vibrate._(3),
  outputNumeric._(4),
  outputAlphanumeric._(5);

  final Uint8 value;

  const OutputAction._(this.value);
}

/// A set of supported Output Out-of-band actions.
class OutputOobActions {
  final Uint16 rawValue;

  const OutputOobActions._(this.rawValue);

  static const blink = OutputOobActions._(1 << 0);
  static const beep = OutputOobActions._(1 << 1);
  static const vibrate = OutputOobActions._(1 << 2);
  static const outputNumeric = OutputOobActions._(1 << 3);
  static const outputAlphanumeric = OutputOobActions._(1 << 4);

  bool contains(OutputOobActions action) {
    return rawValue & action.rawValue == action.rawValue;
  }

  factory OutputOobActions.fromPdu(
    ProvisioningPdu pdu, {
    required int offset,
  }) {
    return OutputOobActions._(pdu.data.readUint16(offset: offset));
  }

  @override
  String toString() {
    return debugDescription;
  }
}

/// Available input actions to be performed during provisioning.
///
/// For example,if the Unprovisioned Device is a light, then it would blink random
/// number of times. That number should be provided to
/// ``ProvisioningDelegate/authenticationActionRequired(_:)``.
enum InputAction {
  push._(1),
  twist._(2),
  inputNumeric._(3),
  inputAlphanumeric._(4);

  final Uint8 value;

  const InputAction._(this.value);
}

/// A set of supported Input Out-of-band actions.
class InputOobActions {
  final Uint16 rawValue;

  const InputOobActions._(this.rawValue);

  static const push = InputOobActions._(1 << 0);
  static const twist = InputOobActions._(1 << 1);
  static const inputNumeric = InputOobActions._(1 << 2);
  static const inputAlphanumeric = InputOobActions._(1 << 3);

  bool contains(InputOobActions action) {
    return rawValue & action.rawValue == action.rawValue;
  }

  factory InputOobActions.fromPdu(
    ProvisioningPdu pdu, {
    required int offset,
  }) {
    return InputOobActions._(pdu.data.readUint16(offset: offset));
  }

  @override
  String toString() {
    return debugDescription;
  }
}

/// A set of supported Out-Of-Band types.
class OobType {
  final Uint8 rawValue;

  const OobType._(this.rawValue);

  factory OobType.fromPdu(
    ProvisioningPdu pdu, {
    required int offset,
  }) {
    return OobType._(pdu.data.readUint8(offset: offset));
  }

  /// Static OOB Information is available.
  static const staticOobInformationAvailable = OobType._(1 << 0);

  /// Only OOB authenticated provisioning supported.
  ///
  /// - since: Mesh Protocol 1.1.
  static const onlyOobAuthenticatedProvisioningSupported = OobType._(1 << 1);

  /// Checks if a particular option is set.
  bool contains(OobType option) {
    return rawValue & option.rawValue == option.rawValue;
  }

  @override
  String toString() {
    return debugDescription;
  }
}

extension OobTypeDebugging on OobType {
  String get debugDescription {
    if (rawValue == 0) {
      return "None";
    }

    final options = <String>[];
    if (contains(OobType.staticOobInformationAvailable)) {
      options.add("Static OOB Information Available");
    }
    if (contains(OobType.onlyOobAuthenticatedProvisioningSupported)) {
      options.add("Only OOB Authenticated Provisioning Supported");
    }

    return options.join(", ");
  }
}

extension OobInformationDebugging on OobInformation {
  String get debugDescription {
    if (rawValue == 0) {
      return "None";
    }

    final options = <String>[];
    if (contains(OobInformation.other)) {
      options.add("Other");
    }
    if (contains(OobInformation.electronicURI)) {
      options.add("Electronic URI");
    }
    if (contains(OobInformation.qrCode)) {
      options.add("QR Code");
    }
    if (contains(OobInformation.barCode)) {
      options.add("Bar Code");
    }
    if (contains(OobInformation.nfc)) {
      options.add("NFC");
    }
    if (contains(OobInformation.number)) {
      options.add("Number");
    }
    if (contains(OobInformation.string)) {
      options.add("String");
    }
    if (contains(OobInformation.supportForCertificateBasedProvisioning)) {
      options.add("Support for certificate-based provisioning");
    }
    if (contains(OobInformation.supportForProvisioningRecords)) {
      options.add("Support for provisioning records");
    }
    if (contains(OobInformation.onBox)) {
      options.add("On Box");
    }
    if (contains(OobInformation.insideBox)) {
      options.add("Inside Box");
    }
    if (contains(OobInformation.onPieceOfPaper)) {
      options.add("On Piece Of Paper");
    }
    if (contains(OobInformation.insideManual)) {
      options.add("Inside Manual");
    }
    if (contains(OobInformation.onDevice)) {
      options.add("On Device");
    }

    return options.join(", ");
  }
}

extension OutputActionDebugging on OutputAction {
  String get debugDescription {
    switch (this) {
      case OutputAction.blink:
        return "Blink";
      case OutputAction.beep:
        return "Beep";
      case OutputAction.vibrate:
        return "Vibrate";
      case OutputAction.outputNumeric:
        return "Output Numeric";
      case OutputAction.outputAlphanumeric:
        return "Output Alphanumeric";
    }
  }
}

extension OutputOobActionsDebugging on OutputOobActions {
  String get debugDescription {
    if (rawValue == 0) {
      return "None";
    }

    final options = <String>[];
    if (contains(OutputOobActions.blink)) {
      options.add("Blink");
    }
    if (contains(OutputOobActions.beep)) {
      options.add("Beep");
    }
    if (contains(OutputOobActions.vibrate)) {
      options.add("Vibrate");
    }
    if (contains(OutputOobActions.outputNumeric)) {
      options.add("Output Numeric");
    }
    if (contains(OutputOobActions.outputAlphanumeric)) {
      options.add("Output Alphanumeric");
    }

    return options.join(", ");
  }
}

extension InputActionDebugging on InputAction {
  String get debugDescription {
    switch (this) {
      case InputAction.push:
        return "Push";
      case InputAction.twist:
        return "Twist";
      case InputAction.inputNumeric:
        return "Input Numeric";
      case InputAction.inputAlphanumeric:
        return "Input Alphanumeric";
    }
  }
}

extension InputOobActionsDebugging on InputOobActions {
  String get debugDescription {
    if (rawValue == 0) {
      return "None";
    }

    final options = <String>[];
    if (contains(InputOobActions.push)) {
      options.add("Push");
    }
    if (contains(InputOobActions.twist)) {
      options.add("Twist");
    }
    if (contains(InputOobActions.inputNumeric)) {
      options.add("Input Numeric");
    }
    if (contains(InputOobActions.inputAlphanumeric)) {
      options.add("Input Alphanumeric");
    }

    return options.join(", ");
  }
}
