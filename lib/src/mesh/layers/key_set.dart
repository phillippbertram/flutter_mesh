import '../models/application_key.dart';
import '../models/key_refresh_phase.dart';
import '../models/network_key.dart';
import '../models/node.dart';
import '../types.dart';

abstract class KeySet {
  /// The Network Key used to encrypt the message.
  NetworkKey get networkKey;

  /// The Access Layer key used to encrypt the message.
  Data get accessKey;

  /// Application Key identifier, or `nil` for Device Key.
  Uint8? get aid;
}

class AccessKeySet implements KeySet {
  AccessKeySet({
    required this.applicationKey,
  });

  final ApplicationKey applicationKey;

  @override
  NetworkKey get networkKey {
    return applicationKey.boundNetworkKey!;
  }

  @override
  Data get accessKey {
    if (networkKey.phase == KeyRefreshPhase.keyDistribution) {
      return applicationKey.oldKey ?? applicationKey.key;
    }
    return applicationKey.key;
  }

  @override
  Uint8? get aid {
    if (networkKey.phase == KeyRefreshPhase.keyDistribution) {
      return applicationKey.oldAid ?? applicationKey.aid;
    }
    return applicationKey.aid;
  }
}

class DeviceKeySet implements KeySet {
  const DeviceKeySet._({
    required this.networkKey,
    required this.node,
    required this.accessKey,
  });

  final Node node;

  @override
  final NetworkKey networkKey;

  @override
  final Data accessKey;

  @override
  final Uint8? aid = null;

  static DeviceKeySet? from({
    required NetworkKey networkKey,
    required Node node,
  }) {
    final deviceKey = node.deviceKey;
    if (deviceKey == null) {
      return null;
    }

    return DeviceKeySet._(
      networkKey: networkKey,
      node: node,
      accessKey: deviceKey,
    );
  }
}
