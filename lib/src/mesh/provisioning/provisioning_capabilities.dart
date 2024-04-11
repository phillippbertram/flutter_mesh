import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'provisioning_capabilities.freezed.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningCapabilities.swift

/// The device sends this PDU to indicate its supported provisioning
/// capabilities to a Provisioner.
@freezed
class ProvisioningCapabilities with _$ProvisioningCapabilities {
  const factory ProvisioningCapabilities({
    required Uint8 numberOfElements,
    required Algorithms algorithms,
    required PublicKeyType
        publicKeyType, // TODO: this is not used in the library 🤷‍♂️
    required OobType oobType, // TODO:
    required Uint8 outputOobSize,
    required OutputOobActions outputOobActions,
    required Uint8 inputOobSize,
    required InputOobActions inputOobActions,
  }) = _ProvisioningCapabilities;

  static ProvisioningCapabilities fromPdu(ProvisioningPdu pdu) {
    final data = pdu.data;
    final numberOfElements = data.readUint8(offset: 1);
    final algorithms = Algorithms.fromPdu(pdu, offset: 2);
    final publicKeyType = PublicKeyType.fromPdu(pdu, offset: 4);
    final oobType = OobType.fromPdu(pdu, offset: 5);
    final outputOobSize = data.readUint8(offset: 6);
    final outputOobActions = OutputOobActions.fromPdu(pdu, offset: 7);
    final inputOobSize = data.readUint8(offset: 9);
    final inputOobActions = InputOobActions.fromPdu(pdu, offset: 10);

    return ProvisioningCapabilities(
      numberOfElements: numberOfElements,
      algorithms: algorithms,
      publicKeyType: publicKeyType,
      oobType: oobType,
      outputOobSize: outputOobSize,
      outputOobActions: outputOobActions,
      inputOobSize: inputOobSize,
      inputOobActions: inputOobActions,
    );
  }
}

extension ProvisioningCapabilitiesX on ProvisioningCapabilities {
  // https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/ProvisioningPdu.swift#L141
  Data get value => Data.from([numberOfElements])
      .addUint16(algorithms.rawValue, endian: Endian.big)
      .addUint8(publicKeyType.rawValue)
      .addUint8(oobType.rawValue)
      .addUint8(outputOobSize)
      .addUint16(outputOobActions.rawValue, endian: Endian.big)
      .addUint8(inputOobSize)
      .addUint16(inputOobActions.rawValue, endian: Endian.big);
}
