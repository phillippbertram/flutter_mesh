import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:flutter_mesh/src/mesh/utils/utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/rxdart.dart';

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

  // hold stream subscriptions that need to be cancelled when done
  final _subscriptions = CompositeSubscription();

  // MARK: - Bearer

  @override
  List<PduType> get supportedPduTypes => [
        PduType.networkPdu,
        PduType.proxyConfiguration,
        PduType.provisioningPdu,
        PduType.meshBeacon,
      ];

  @override
  BearerDataDelegate? get dataDelegate => _dataDelegate?.target;
  WeakReference<BearerDataDelegate>? _dataDelegate;
  @override
  void setDataDelegate(BearerDataDelegate delegate) {
    _dataDelegate = WeakReference(delegate);
  }

  @override
  Future<Result<void>> close() async {
    // TODO: Make checks for bluetooth support and adapter state
    print(
      "BaseGattBearer: Disconnecting from base peripheral: ${basePeripheral.remoteId}",
    );
    await basePeripheral.disconnect();
    _isOpenSubject.add(false);
    return Result.value(null);
  }

  @override
  // TODO: implement isOpen
  bool get isOpen => _isOpenSubject.value;

  @override
  Stream<bool> get isOpenStream => _isOpenSubject.stream;

  final _isOpenSubject = BehaviorSubject.seeded(false);

  void dispose() {
    close();
    _subscriptions.dispose();
  }

  @override
  Future<Result<void>> open() async {
    // TODO: Make checks for bluetooth support and adapter state

    print(
      "BaseGattBearer: Connecting to base peripheral: ${basePeripheral.remoteId}",
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
    }).addTo(_subscriptions);

    // cleanup: cancel subscriptions when disconnected
    // TODO:
    // basePeripheral.cancelWhenDisconnected(_subscriptions);

    await basePeripheral.connect();

    return Result.value(null);
  }

  @override
  Future<Result<void>> sendData({
    required Data data,
    required PduType type,
  }) async {
    print("BaseGattBearer: send data: ${data.length} bytes, type: $type");

    if (!isOpen) {
      print("BaseGattBearer: Bearer is not open");
      return Result.error("Bearer is not open");
    }

    if (!supportedPduTypes.contains(type)) {
      print("BaseGattBearer: Unsupported PDU type: $type");
      return Result.error("Unsupported PDU type: $type");
    }

    if (_dataInCharacteristic == null) {
      print("BaseGattBearer: Data In characteristic is not available");
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
      print(
          "BaseGattBearer: Segmented into ${packets.length} packets with mtu: $mtu");

      for (final packet in packets) {
        print("BaseGattBearer: send -> 0x${packet.toHex()}");
        await _dataInCharacteristic!.write(packet, withoutResponse: true);
      }
    } catch (e) {
      print("BaseGattBearer: Failed to send data: $e");
      return Result.error("Failed to send data: $e");
    }

    return Result.value(null);
  }

  // MARK: Private BLE methods

  void _handleDidConnectToPeripheral() async {
    print(
        "BaseGattBearer: Connected to peripheral: ${basePeripheral.remoteId}");

    await _discoverServices();

    // after services & characteristics are discovered, the bearer is ready to use
    // TODO: maybe we should add another state `isReady`?
    _isOpenSubject.add(true);
  }

  void _handleDidDisconnectFromPeripheral() {
    print(
        "BaseGattBearer: Disconnected from peripheral: ${basePeripheral.remoteId}");

    _isOpenSubject.add(false);
    _dataInCharacteristic = null;
    _dataOutCharacteristic = null;

    // TODO: notify bearer delegate
  }

  Future<void> _discoverServices() async {
    print("BaseGattBearer: Discovering services for peripheral");
    var services = await basePeripheral.discoverServices();
    services = services.where((s) => service.matches(s)).toList();

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

    // enable notifications & subscribe
    print(
        "BaseGattBearer: Enabling notifications for Data Out characteristic: ${_dataOutCharacteristic?.uuid}");

    _dataOutCharacteristic!.onValueReceived.listen((value) {
      print("BaseGattBearer: received <- 0x${value.toHex()}");
      final message = _protocolHandler.reassemble(value);
      if (message == null) {
        print("BaseGattBearer: Failed to reassemble message");
        return;
      }
      print('BaseGattBearer: Reassembled message type: ${message.messageType}');
      dataDelegate?.bearerDidDeliverData(message.data, message.messageType);
    }).addTo(_subscriptions);

    await _dataOutCharacteristic!.setNotifyValue(true);
  }
}
