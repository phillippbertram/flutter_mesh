part of 'network_key.dart';

extension NetworkKeyMeshNetworkX on NetworkKey {
  /// Returns whether the Network Key is the Primary Network Key.
  /// The Primary key is the one which Key Index is equal to 0.
  ///
  /// A Primary Network Key may not be removed from the mesh network,
  /// but can be removed from any Node using Config Net Key Delete
  /// messages encrypted using an Application Key bound to a different
  /// Network Key.
  bool get isPrimary => index == 0;

  /// Returns whether the Network Key is a secondary Network Key,
  /// that is the Key Index is NOT equal to 0.
  bool get isSecondary => !isPrimary;
}
