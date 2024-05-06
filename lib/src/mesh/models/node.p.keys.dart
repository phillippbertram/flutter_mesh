part of 'node.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/Node%2BKeys.swift
extension NodeKeysX on Node {
  /// Returns whether the Node has knowledge about the given Application Key.
  /// The Application Key comparison bases only on the Key Index.
  ///
  /// - parameter applicationKey: The Application Key to look for.
  /// - returns: `True` if the Node has knowledge about the Application Key
  ///            with the same Key Index as given key, `false` otherwise.
  bool knowsApplicationKey(ApplicationKey key) {
    return knowsApplicationKeyIndex(key.index);
  }

  /// Returns whether the Node has knowledge about Application Key with the
  /// given index.
  ///
  /// - parameter applicationKeyIndex: The Application Key Index to look for.
  /// - returns: `True` if the Node has knowledge about the Application Key
  ///            index, `false` otherwise.
  bool knowsApplicationKeyIndex(KeyIndex keyIndex) {
    return appKeys.any((ak) => ak.index == keyIndex);
  }

  /// Returns whether the Node has knowledge about the given Network Key.
  /// The Network Key comparison bases only on the Key Index.
  ///
  /// - parameter networkKey: The Network Key to look for.
  /// - returns: `True` if the Node has knowledge about the Network Key
  ///            with the same Key Index as given key, `false` otherwise.
  bool knowsNetworkKey(NetworkKey key) {
    return knowsNetworkKeyIndex(key.index);
  }

  /// Returns whether the Node has knowledge about Network Key with the
  /// given index.
  ///
  /// - parameter networkKeyIndex: The Network Key Index to look for.
  /// - returns: `True` if the Node has knowledge about the Network Key
  ///            index, `false` otherwise.
  bool knowsNetworkKeyIndex(KeyIndex keyIndex) {
    return netKeys.any((nk) => nk.index == keyIndex);
  }
}

extension NodeKeysListX on Iterable<Node> {
  /// Returns whether the Node has knowledge about the given list of Application Keys.
  ///
  /// - parameter keys: The list of Application Keys to look for.
  /// - returns: `True` if the Node has knowledge about all the Application Keys
  ///            with the same Key Index as given keys, `false` otherwise.
  bool knowsApplicationKey(ApplicationKey key) {
    return knowsApplicationKeyIndex(key.index);
  }

  /// Returns whether any of elements of this array is using an
  /// Application Key with given Key Index.
  ///
  /// - parameter applicationKeyIndex: The Application Key Index to look for.
  /// - returns: `True` if any of the Nodes have knowledge about the
  ///            Application Key Index, `false` otherwise.
  bool knowsApplicationKeyIndex(KeyIndex keyIndex) {
    // return contains(where: { $0.knows(applicationKeyIndex: applicationKeyIndex) })
    return any((node) => node.knowsApplicationKeyIndex(keyIndex));
  }
}
