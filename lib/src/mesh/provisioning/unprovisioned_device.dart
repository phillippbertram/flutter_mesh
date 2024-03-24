import 'package:dart_mesh/src/mesh/mesh.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


part 'unprovisioned_device.freezed.dart';

/// A class representing an unprovisioned device.
/// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Provisioning/UnprovisionedDevice.swift#L34
@freezed
class UnprovisionedDevice with _$UnprovisionedDevice {
  const factory UnprovisionedDevice._({
    String? name,
    required Guid uuid,
    required OobInformation oobInformation,
  }) = _UnprovisionedDevice;

  static UnprovisionedDevice? fromAdvertisementData(AdvertisementData data) {
    final uuid = data.unprovisionedDeviceUUID;
    if (uuid == null) {
      return null;
    }

    final oob = data.oobInformation;
    if (oob == null) {
      return null;
    }

    return UnprovisionedDevice._(
      name: data.advName,
      uuid: uuid,
      oobInformation: oob,
    );
  }
}
