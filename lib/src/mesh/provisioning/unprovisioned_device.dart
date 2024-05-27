import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unprovisioned_device.freezed.dart';

/// A class representing an unprovisioned device.
/// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Provisioning/UnprovisionedDevice.swift
@freezed
class UnprovisionedDevice with _$UnprovisionedDevice {
  const factory UnprovisionedDevice._({
    String? name,
    required Guid uuid,
    required OobInformation oobInformation,
  }) = _UnprovisionedDevice;

  static UnprovisionedDevice? fromAdvertisementData(
    AdvertisementData data, {
    BluetoothDevice? device,
  }) {
    final uuid = data.unprovisionedDeviceUUID;
    if (uuid == null) {
      return null;
    }

    final oob = data.oobInformation;
    if (oob == null) {
      return null;
    }

    String deviceName = data.advName;
    if (deviceName.isEmpty && device != null) {
      deviceName = device.platformName;
    }

    return UnprovisionedDevice._(
      name: deviceName,
      uuid: uuid,
      oobInformation: oob,
    );
  }
}
