part of 'network_key.dart';

extension NetworkKeyListX on List<NetworkKey> {
  /// The primary Network Key, that is the one with key index 0.
  /// If the primary Network Key is not known, it's set to `nil`.
  NetworkKey? get primary {
    return firstWhereOrNull((key) => key.isPrimary);
  }

  /// Returns a new list of Network Keys containing all the Network Keys
  /// of this list known to the given Node.
  ///
  /// - parameter node: The Node used to filter Network Keys.
  /// - returns: A new list containing all the Network Keys of this list
  ///            known to the given node.
  List<NetworkKey> knownToNode(Node node) {
    return where((key) => node.knowsNetworkKey(key)).toList();
  }

  /// Returns a new list of Network Keys containing all the Network Keys
  /// of this list NOT known to the given Node.
  ///
  /// - parameter node: The Node used to filter Network Keys.
  /// - returns: A new list containing all the Network Keys of this list
  ///            NOT known to the given node.
  List<NetworkKey> notKnownToNode(Node node) {
    return where((key) => !node.knowsNetworkKey(key)).toList();
  }
}
