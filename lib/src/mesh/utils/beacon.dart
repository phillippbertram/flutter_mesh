import 'package:flutter_mesh/src/mesh/models/network_identify.dart';
import 'package:flutter_mesh/src/mesh/models/node_identity.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../provisioning/oob.dart';
import 'mesh_constants.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Utils/Beacon.swift#L102
extension AdvertisementDataX on AdvertisementData {
  NetworkIdentity? get networkIdentity {
    // TODO: also add PrivateNetworkIdentity (Mesh 1.1)
    return PublicNetworkIdentity.fromAdvertisementData(this);
  }

  /// Returns the Node Identity beacon data or `nil` if such value was not parsed.
  ///
  /// - note: Before version 4.0.0 this property returned Hash and Random pair.
  /// - seeAlso: ``NodeIdentity/matches(node:)``
  /// - seeAlso: ``MeshNetwork/node(matchingNodeIdentity:)``
  /// - since: 4.0.0
  NodeIdentity? get nodeIdentity {
    // TODO: also add PrivateNodeIdentity (Mesh 1.1)
    return PublicNodeIdentity.fromAdvertisementData(this);
  }

  /// Returns the Unprovisioned Device's UUID or `nil` if such value not be parsed.
  ///
  /// This value is taken from the Service Data with Mesh Provisioning Service
  /// UUID. The first 16 bytes are the converted to UUID.
  Guid? get unprovisionedDeviceUUID {
    final serviceData = this.serviceData;
    if (serviceData.isEmpty) {
      return null;
    }

    final guid = Guid(MeshProvisioningService().uuid);
    final data = serviceData[guid];
    if (data == null) {
      return null;
    }

    // TODO: check this
    if (!(data.length == 18 || data.length == 22)) {
      return null;
    }

    return Guid.fromBytes(data.sublist(0, 16));
  }

  /// Returns the Unprovisioned Device's OOB information or `nil` if such
  /// value not be parsed.
  ///
  /// This value is taken from the Service Data with Mesh Provisioning Service
  /// UUID. The last 2 bytes are parsed and returned as ``OobInformation``.
  OobInformation? get oobInformation {
    return OobInformation.fromAdvertisementData(this);
  }
}
