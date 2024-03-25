import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'device_scan_service.freezed.dart';

@freezed
class DiscoveredPeripheral with _$DiscoveredPeripheral {
  const factory DiscoveredPeripheral({
    required UnprovisionedDevice device,
    required ProvisioningBearer bearer,
    required ScanResult scanResult,
    required int rssi,
  }) = _DiscoveredPeripheral;
}

// Service to scan for unprovisioned devices
class DeviceProvisioningScanService {
  final _scanResultController =
      StreamController<List<DiscoveredPeripheral>>.broadcast();
  Stream<List<DiscoveredPeripheral>> get scanResults =>
      _scanResultController.stream;

  final _isScanningSubject = BehaviorSubject.seeded(false);
  Stream<bool> get isScanningStream => _isScanningSubject.stream;
  bool get isScanning => _isScanningSubject.value;

  // Check permissions
  Future<bool> checkPermissions() async {
    final isSupported = await FlutterBluePlus.isSupported;
    final adapterState = FlutterBluePlus.adapterStateNow;
    print("isSupported: $isSupported, adapterState: $adapterState");
    return isSupported && adapterState == BluetoothAdapterState.on;
  }

  // Start scanning for BLE devices
  // TODO: no RemoteProvisioningScanStart scan implemented here
  void startScan({
    Duration? stopAfter,
  }) async {
    final scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      _handleResults(results);
    }, onError: (e) {
      print("Error scanning: $e");
      _scanResultController.addError(e);
    });

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(scanSubscription);

    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    // Start scanning w/ timeout
    // Optional: you can use `stopScan()` as an alternative to using a timeout
    // Note: scan filters use an *or* behavior. i.e. if you set `withServices` & `withNames`
    //   we return all the advertisements that match any of the specified services *or* any
    //   of the specified names.
    _isScanningSubject.add(true);
    await FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 5),
      withServices: [Guid(MeshProvisioningService().uuid)],
      timeout: stopAfter,
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    _isScanningSubject.add(false);
  }

  // Stop scanning
  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // Dispose resources
  void dispose() {
    _scanResultController.close();
  }

  void _handleResults(List<ScanResult> results) {
    results = results.where((result) {
      // ignore packets without unprovisioned device beacon
      final uuid = result.advertisementData.unprovisionedDeviceUUID;
      if (uuid == null) {
        return false;
      }

      return true;
    }).toList();

    final discoveryPeripherals = results
        .map((result) {
          final device = UnprovisionedDevice.fromAdvertisementData(
              result.advertisementData);

          if (device == null) {
            return null;
          }

          return DiscoveredPeripheral(
            device: device,
            scanResult: result,
            bearer: PBGattBearer.fromPeripheral(basePeripheral: result.device),
            rssi: result.rssi,
          );
        })
        .whereNotNull()
        .toList();

    _scanResultController.add(discoveryPeripherals);
  }
}
