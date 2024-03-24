import 'dart:async';

import 'package:async/async.dart';
import 'package:dart_mesh/src/mesh/utils/utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:dart_mesh/src/mesh/mesh.dart';

// TODO: make this part of the library?
// TODO: @see SpecificMeshNetworkViaArbitraryProxyNodeStrategy

/// The `NetworkConnection` object maintains connections to Bluetooth
/// mesh proxies. It scans in the background and connects to nodes that
/// advertise with Network ID or Node Identity beacon.
///
/// The maximum number of simultaneous connections is defined by
/// ``NetworkConnection/maxConnections``. By connecting to more than one device, this
/// object allows quick switching to another proxy in case link
/// to one of the devices is lost. Only the first device will
/// receive outgoing messages. However, the ``NetworkConnection/dataDelegate`` will be
/// notified about messages received from any of the connected proxies.
///
/// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Example/Source/Mesh%20Network/NetworkConnection.swift
class NetworkConnection with BearerDataDelegate implements Bearer {
  NetworkConnection({
    required MeshNetwork meshNetwork,
  }) : _meshNetwork = meshNetwork;

  // TODO: WeakReference?
  final MeshNetwork _meshNetwork;

  final _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  WeakReference<BearerDataDelegate>? _dataDelegate;
  void setDataDelegate(BearerDataDelegate delegate) {
    _dataDelegate = WeakReference(delegate);
  }

  @override
  List<PduType> get supportedPduTypes => [
        PduType.networkPdu,
        PduType.meshBeacon,
        PduType.proxyConfiguration,
      ];

  @override
  // TODO: implement isOpen
  bool get isOpen => throw UnimplementedError();

  @override
  Future<Result<void>> close() async {
    // TODO: implement close
    await FlutterBluePlus.stopScan();
    return Result.value(null);
  }

  @override
  Future<Result<void>> open() async {
    print("Scanning for mesh proxies");
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return Result.error("Bluetooth not supported by this device");
    }

    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning
    // Use: `scanResults` if you want live scan results *or* the results from a previous scan
    _isScanning = true;
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          _handleScanResults(results);
        }
      },
      onError: (e) => print(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

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
    await FlutterBluePlus.startScan(
      withServices: [Guid(MeshProxyService.uuid)],
      timeout: const Duration(seconds: 30),
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    _isScanning = false;

    return Result.value(null);
  }

  @override
  Result<void> sendData({required Data data, required PduType type}) {
    print('Sending ${data.length} of type $type');
    // TODO: implement sendData
    throw UnimplementedError();
  }

  void _handleScanResults(List<ScanResult> results) {
    // @see JungHome SpecificMeshNetworkViaArbitraryProxyNodeStrategy
    final filtered = results.where((r) {
      final networkIdentity = r.advertisementData.networkIdentity;
      if (networkIdentity != null) {
        // A Node from another mesh network?
        return _meshNetwork.matchesNetworkIdentity(networkIdentity);
      }

      final nodeIdentity = r.advertisementData.nodeIdentity;
      if (nodeIdentity != null) {
        // A Node from another mesh network?
        return _meshNetwork.matchesNodeIdentity(nodeIdentity);
      }

      return false;
    });

    _scanResultsController.add(filtered.toList());
  }

  // TODO: GattBearerDelegate

  // BearerDataDelegate

  @override
  void bearerDidDeliverData(Data data, PduType type) {
    _dataDelegate?.target?.bearerDidDeliverData(data, type);
  }
}
