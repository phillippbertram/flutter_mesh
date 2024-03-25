import 'package:flutter_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
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
}
