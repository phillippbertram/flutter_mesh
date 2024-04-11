part of 'application_key.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/ApplicationKey%2BMeshNetwork.swift
extension ApplicationKeyNetworkKey on ApplicationKey {
  /// Bounds the Application Key to the given Network Key.
  /// The Application Key must not be in use. If any of the network Nodes
  /// already knows this key, this method throws an error.
  ///
  /// - parameter networkKey: The Network Key to bound the Application Key to.
  Result<void> bindToNetworkKey(NetworkKey networkKey) {
    if (meshNetwork == null) {
      return Result.error("Mesh Network is not set");
    }

    if (isUsedInNetwork(meshNetwork!)) {
      return Result.error("Application Key is already used in the network");
    }

    boundNetworkKeyIndex = networkKey.index;
    return Result.value(null);
  }

  /// The Network Key bound to this Application Key.
  NetworkKey? get boundNetworkKey {
    if (boundNetworkKeyIndex == null) {
      return null;
    }

    return meshNetwork?.networkKeys[boundNetworkKeyIndex!];
  }

  bool isUsedInNetwork(MeshNetwork meshNetwork) {
    return meshNetwork.applicationKeys.contains(this) &&
        meshNetwork.nodes
            .where((node) => node.uuid != meshNetwork.localProvisioner?.uuid)
            .knowsApplicationKey(this);
  }

  bool get isInUse {
    if (meshNetwork == null) {
      return false;
    }

    return isUsedInNetwork(meshNetwork!);
  }
}
