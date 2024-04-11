part of 'mesh_network.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/MeshNetwork%2BKeys.swift
extension MeshNetworkKeys on MeshNetwork {
  // TODO: implement something like this?
  // ApplicationKey? nextRandomApplicationKey() {
  //   final keyIndex = nextAvailableApplicationKeyIndex;
  //   if (keyIndex == null) {
  //     return null;
  //   }

  //   return ApplicationKey.random(index: keyIndex, name: ...);
  // }

  /// Next available Key Index that can be assigned to a new Application Key.
  ///
  /// - note: This method does not look for gaps in key indexes. It returns the
  ///         next available Key Index after the last Key Index used.
  KeyIndex? get nextAvailableApplicationKeyIndex {
    if (applicationKeys.isEmpty) {
      return 0;
    }

    final lastAppKey = applicationKeys.last;
    final nextKeyIndex = lastAppKey.index + 1;
    if (!nextKeyIndex.isValidKeyIndex) {
      return null;
    }

    return nextKeyIndex;
  }

  /// Adds a new Application Key and binds it to the first Network Key.
  ///
  /// - parameter applicationKey: The 128-bit Application Key.
  /// - parameter index:          An optional Key Index to assign. If `nil`,
  ///                             the next available Key Index will be assigned
  ///                             automatically.
  /// - parameter name:           The human readable name.
  /// - throws: This method throws an error if the key is not 128-bit long,
  ///           there isn't any Network Key to bind the new key to
  ///           or the assigned Key Index is out of range.
  Result<ApplicationKey> addApplicationKey({
    required String name,
    required Data keyData,
    KeyIndex? index,
  }) {
    if (!keyData.isValidApplicationKey) {
      return Result.error("Key must be 128-bit long.");
    }

    index ??= nextAvailableApplicationKeyIndex;
    if (index == null || !index.isValidKeyIndex) {
      return Result.error("No available key index.");
    }

    final defaultNetworkKey = networkKeys.firstOrNull;
    if (defaultNetworkKey == null) {
      return Result.error("No network key found.");
    }

    final appKeyRes = ApplicationKey.create(
      name: name,
      index: index,
      key: keyData,
      boundNetworkKey: defaultNetworkKey,
    );
    if (appKeyRes.isError) {
      return Result.error(appKeyRes.asError!.error);
    }
    final appKey = appKeyRes.asValue!.value;
    _addApplicationKey(appKey);
    return Result.value(appKey);
  }

  /// Adds the given Application Key to the network.
  ///
  /// - parameter key: The new Application Key to be added.
  void _addApplicationKey(ApplicationKey key) {
    logger.t("adding application key: ${key.name} (${key.index})");
    key.setMeshNetwork(this);
    applicationKeys.add(key);

    // Make the local Provisioner aware of the new key.
    logger.f("MISSING IMPLEMENTATION - Update AppKey for LocalProvisioner!");
    // TODO:
    // localProvisioner?.node?.add(applicationKey: key);

    _networkDidChange();
  }

  Result<ApplicationKey?> removeApplicationKeyWithKeyIndex(KeyIndex keyIndex,
      {bool force = false}) {
    final firstIndex =
        applicationKeys.indexWhere((key) => key.index == keyIndex);
    if (firstIndex == -1) {
      return Result.value(null);
    }
    return removeApplicationKeyAt(firstIndex, force: force);
  }

  /// Removes Application Key at the given index.
  ///
  /// - parameter index: The position of the element to remove.
  ///                    `index` must be a valid index of the array.
  /// - parameter force: If set to `true`, the key will be deleted even
  ///                    if there are other Nodes known to use this key.
  /// - returns: The removed key.
  /// - throws: The method throws if the key is in use and cannot be
  ///           removed (unless `force` was set to `true`).
  Result<ApplicationKey?> removeApplicationKeyAt(int index,
      {bool force = false}) {
    final key = applicationKeys.elementAtOrNull(index);
    if (key == null) {
      return Result.value(null);
    }

    if (!(force || !key.isUsedInNetwork(this))) {
      return Result.error("Key is in use.");
    }

    key.setMeshNetwork(null);
    final removedKey = applicationKeys.removeAt(index);
    _networkDidChange();
    return Result.value(removedKey);
  }
}
