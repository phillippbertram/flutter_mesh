import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'provisioning_capabilities.freezed.dart';

@freezed
class ProvisioningCapabilities with _$ProvisioningCapabilities {
  const factory ProvisioningCapabilities({
    required Uint8 numberOfElements,
    required Algorithms algorithms,
    // required PublicKeyType publicKeyType, // TODO:
    // required OobType oobType, // TODO:
    required Uint8 outputOobSize,
    // required OutputOobActions outputOobActions, // TODO:
    required Uint8 inputOobSize,
    // required InputOobActions inputOobActions, // TODO:
  }) = _ProvisioningCapabilities;

  static ProvisioningCapabilities fromPdu(ProvisioningPdu pdu) {
    final data = pdu.data;
    final numberOfElements = data.readUint8(offset: 1);
    final outputOobSize = data.readUint8(offset: 6);
    final inputOobSize = data.readUint8(offset: 9);

    final algorithms = Algorithms.BTM_ECDH_P256_CMAC_AES128_AES_CCM; // TODO:
    // final algorithms = Algorithms.fromValue(data.readUint16(offset: 2));

    // final inputOobActions // TODO:
    // final outputOobActions // TODO:
    // final oobType // TODO:

    return ProvisioningCapabilities(
      numberOfElements: numberOfElements,
      algorithms: algorithms,
      outputOobSize: outputOobSize,
      inputOobSize: inputOobSize,
    );
  }
}

extension ProvisioningCapabilitiesX on ProvisioningCapabilities {
  // https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningPdu.swift#L141
  Data get value {
    // TODO: this might not be very efficient?
    return Data.from([numberOfElements])
      ..addUint16(algorithms.rawValue, endian: Endian.big)
      ..addUint8(0) // TODO: publicKeyType.rawValue
      ..addUint8(0) // TODO: oobType.rawValue
      ..addUint8(outputOobSize)
      ..addUint16(0, endian: Endian.big) // TODO: outputOobActions.rawValue
      ..addUint8(inputOobSize)
      ..addUint16(0, endian: Endian.big); // TODO: inputOobActions.rawValue
  }
}
