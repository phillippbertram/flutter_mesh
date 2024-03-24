// Abstract class equivalent to the NetworkIdentity protocol in Swift.
import 'package:dart_mesh/src/mesh/models/network_key.dart';
import 'package:dart_mesh/src/mesh/types.dart';
import 'package:dart_mesh/src/mesh/utils/mesh_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class NetworkIdentity {
  bool matches(NetworkKey networkKey);
}

// TODO: test this

// Representation of Public Network Identity in Dart.
class PublicNetworkIdentity implements NetworkIdentity {
  final Data networkId;

  PublicNetworkIdentity({required this.networkId});

  // Factory constructor to create an instance from advertisement data.
  // This assumes you have a way to parse the advertisement data similar to Swift.
  static PublicNetworkIdentity? fromAdvertisementData(
    AdvertisementData
        advertisementData, // TODO: try to be flutter_blue agnostic
  ) {
    final serviceData = advertisementData.serviceData;
    if (serviceData.isEmpty) {
      return null;
    }

    final data = serviceData[Guid(MeshProxyService.uuid)];
    if (data == null || data.length != 9 || data[0] != 0x00) {
      return null;
    }

    return PublicNetworkIdentity(networkId: data.sublist(1));
  }

  @override
  bool matches(NetworkKey networkKey) {
    // TODO: Implement matching logic.
    // This is a placeholder implementation.
    return false;
    // return networkId == networkKey.networkId ||
    //     networkId == networkKey.oldNetworkId;
  }

  @override
  String toString() => 'Network Identity (0x${networkId.hex})';
}

// Representation of Private Network Identity in Dart.
class PrivateNetworkIdentity implements NetworkIdentity {
  final Data hash;
  final Data random;

  PrivateNetworkIdentity({required this.hash, required this.random});

  factory PrivateNetworkIdentity.fromAdvertisementData(
      Map<String, dynamic> advertisementData) {
    // Similar to PublicNetworkIdentity, implement parsing logic.
    throw UnimplementedError(
        'Parsing from advertisement data is not implemented.');
  }

  @override
  bool matches(NetworkKey networkKey) {
    // Implement matching logic, including hash calculation.
    // Placeholder for crypto operations.
    throw UnimplementedError('Matching logic is not implemented.');
  }

  @override
  String toString() =>
      'Network Identity (hash: 0x${hash.hex}, random: 0x${random.hex})';
}

extension on Data {
  // Helper extension to convert Uint8List to a hex string.
  // This is a simple implementation. Consider edge cases and optimizations as needed.
  String get hex => map((e) => e.toRadixString(16).padLeft(2, '0')).join();
}
