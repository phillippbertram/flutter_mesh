import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:rxdart/rxdart.dart';

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
/// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Example/Source/Mesh%20Network/NetworkConnection.swift
class NetworkConnection
    with BearerDataDelegate
    implements Bearer /* TODO:, GattBearerDelegate */ {
  NetworkConnection({
    required MeshNetwork meshNetwork,
  }) : _meshNetwork = meshNetwork;

  /// The maximum number of simultaneous connections.
  static const maxConnections = 1;

  /// The mesh network.
  final MeshNetwork _meshNetwork;

  /// The connected proxies.
  final List<GattBearer> _proxies = [];
  List<GattBearer> get _openProxies => _proxies.where((p) => p.isOpen).toList();

  // final _scanResultsSubject = BehaviorSubject.seeded(<ScanResult>[]);
  // Stream<List<ScanResult>> get scanResults => _scanResultsSubject.stream;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  /// Returns the name of the first connected Proxy.
  String? get name {
    return _openProxies.firstOrNull?.name;
  }

  @override
  BearerDataDelegate? get dataDelegate => _dataDelegate;
  BearerDataDelegate? _dataDelegate;
  @override
  void setDataDelegate(BearerDataDelegate delegate) {
    _dataDelegate = delegate;
  }

  @override
  List<PduType> get supportedPduTypes => [
        PduType.networkPdu,
        PduType.meshBeacon,
        PduType.proxyConfiguration,
      ];

  // TODO: implement isOpen
  @override
  bool get isOpen => _isOpenSubject.value;

  @override
  Stream<bool> get isOpenStream => _isOpenSubject.stream;
  final _isOpenSubject = BehaviorSubject.seeded(false);

  /// Returns true if at least one proxy is connected.
  Stream<bool> get isConnectedStream => _isConnectedSubject.stream;
  final _isConnectedSubject = BehaviorSubject.seeded(false);

  @override
  Future<Result<void>> close() async {
    // TODO: implement close
    await FlutterBluePlus.stopScan();
    return Result.value(null);
  }

  @override
  Future<Result<void>> open() async {
    logger.d("Scanning for mesh proxies");
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      logger.d("Bluetooth not supported by this device");
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
      onError: (e) => logger.d(e),
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
      withServices: [Guid(MeshProxyService().uuid)],
      continuousUpdates: false,
      // timeout: const Duration(seconds: 30),
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    _isScanning = false;

    return Result.value(null);
  }

  @override
  Future<Result<void>> sendData(
      {required Data data, required PduType type}) async {
    logger.d('Sending ${data.toHex()} (${data.length}) of type $type');

    Result<void>? sendResult;
    for (final proxy in _openProxies) {
      final res = await proxy.sendData(data: data, type: type);
      if (res.isError) {
        logger.d('Failed to send data to proxy: $proxy');
        sendResult = res;
      }
    }

    return sendResult ?? Result.value(null);
  }

  void _handleScanResults(List<ScanResult> results) {
    // logger.t("_handleScanResults: ${results.length} results");

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

    if (filtered.isEmpty) {
      return;
    }

    for (final result in filtered) {
      final bearer = GattBearer.targetPeripheral(result.device);
      useProxy(bearer);
    }
  }

  /// Switches connection to the given GATT Bearer.
  /// If the maximum number of connections is reached, the last one is closed.
  Future<void> useProxy(GattBearer proxy) async {
    logger.d('Connecting to proxy: $proxy');

    // make sure the proxy is not already in the list
    if (_proxies.firstWhereOrNull((p) =>
            p.basePeripheral.remoteId == proxy.basePeripheral.remoteId) !=
        null) {
      return;
    }

    // if the maximum number of connections is reached, close the last one
    if (_proxies.length >= maxConnections) {
      _proxies.lastOrNull?.close();
    }

    // add new proxy
    logger.e("MISSING IMPLEMENTATION: not all delegates are set");
    // TODO: proxy.setDelegate(this);
    // TODO: proxy.setLogger(logger);
    proxy.setDataDelegate(this);
    _proxies.add(proxy);

    if (proxy.isOpen) {
      logger.e("MISSING IMPLEMENTATION: beaderDidOpen");
      // TODO: beaderDidOpen(this);
    } else {
      proxy.open();
    }

    if (_proxies.length > maxConnections) {
      await FlutterBluePlus.stopScan();
    }
  }

  // TODO: GattBearerDelegate

  // BearerDataDelegate

  @override
  void bearerDidDeliverData(Data data, PduType type) {
    logger.d('Received ${data.toHex()} (${data.length}) of type $type');
    _dataDelegate?.bearerDidDeliverData(data, type);
  }
}
