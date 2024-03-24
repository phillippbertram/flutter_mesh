import 'package:async/async.dart';
import 'package:collection/collection.dart';

import 'package:dart_mesh/src/mesh/types.dart';
import 'package:dart_mesh/src/mesh/utils/utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bearer.dart';
import 'proxy_protocol_handler.dart';

class BaseGattProxyBearer<Service extends MeshService> implements Bearer {
  BaseGattProxyBearer.fromPeripheral(
    this.service,
    this.basePeripheral,
  );

  final Service service;

  final BluetoothDevice basePeripheral;
  BluetoothCharacteristic? _dataInCharacteristic;
  BluetoothCharacteristic? _dataOutCharacteristic;

  final _protocolHandler = ProxyProtocolHandler();

  // MARK: - Bearer

  @override
  List<PduType> get supportedPduTypes => [
        PduType.networkPdu,
        PduType.proxyConfiguration,
        PduType.provisioningPdu,
        PduType.meshBeacon,
      ];

  @override
  Future<Result<void>> close() async {
    // TODO: Make checks for bluetooth support and adapter state
    print(
      "BaseGattBearer: Disconnecting from base peripheral: ${basePeripheral.advName}",
    );
    await basePeripheral.disconnect();
    _isOpen = false;
    return Result.value(null);
  }

  @override
  // TODO: implement isOpen
  bool get isOpen => _isOpen;
  bool _isOpen = false;

  @override
  Future<Result<void>> open() async {
    // TODO: Make checks for bluetooth support and adapter state

    print(
      "BaseGattBearer: Connecting to base peripheral: ${basePeripheral.advName}",
    );

    // TODO: hold subscription and cancel when done
    basePeripheral.connectionState.listen((state) {
      print("BaseGattBearer: Connection state: $state");

      switch (state) {
        case BluetoothConnectionState.connected:
          _handleDidConnectToPeripheral();
          break;
        case BluetoothConnectionState.disconnected:
          _handleDidDisconnectFromPeripheral();
          break;
        default:
          break;
      }
      _isOpen = state == BluetoothConnectionState.connected;
    });

    await basePeripheral.connect();

    _isOpen = true;
    return Result.value(null);
  }

  @override
  Future<Result<void>> sendData({
    required Data data,
    required PduType type,
  }) async {
    if (!isOpen) {
      return Result.error("Bearer is not open");
    }

    if (!supportedPduTypes.contains(type)) {
      return Result.error("Unsupported PDU type: $type");
    }

    if (_dataInCharacteristic == null) {
      return Result.error("Data In characteristic is not available");
    }

    try {
      // TODO: use .maximumWriteValueLength(for: .withoutResponse)?
      final mtu = basePeripheral.mtuNow;
      final packets = _protocolHandler.segment(
        data: data,
        messageType: type,
        mtu: mtu,
      );

      for (final packet in packets) {
        print("BaseGattBearer: Sending packet: ${packet.toHex()}");
        await _dataInCharacteristic!.write(packet, withoutResponse: true);
      }
    } catch (e) {
      return Result.error("Failed to send data: $e");
    }

    return Result.value(null);
  }

  // MARK: Private BLE methods

  void _handleDidConnectToPeripheral() {
    print("BaseGattBearer: Connected to peripheral: ${basePeripheral.advName}");
    _isOpen = true;
    _discoverServices();
  }

  void _handleDidDisconnectFromPeripheral() {
    print(
        "BaseGattBearer: Disconnected from peripheral: ${basePeripheral.advName}");

    _isOpen = false;
    _dataInCharacteristic = null;
    _dataOutCharacteristic = null;
  }

  void _discoverServices() async {
    final services = await basePeripheral.discoverServices();

    _dataInCharacteristic = services
        .expand((s) => s.characteristics)
        .firstWhereOrNull((c) => c.uuid == Guid(service.dataInUuid));
    if (_dataInCharacteristic == null) {
      print("BaseGattBearer: Missing Data In characteristic");
      await close();
      return;
    }

    _dataOutCharacteristic =
        services.expand((s) => s.characteristics).firstWhereOrNull(
              (c) => c.uuid == Guid(service.dataOutUuid),
            );
    if (_dataOutCharacteristic == null) {
      print("BaseGattBearer: Missing Data Out characteristic");
      await close();
      return;
    }

    // enable notifications
    print(
        "BaseGattBearer: Enabling notifications for Data Out characteristic: ${_dataOutCharacteristic?.uuid}");
    await _dataOutCharacteristic?.setNotifyValue(true);
  }
}
