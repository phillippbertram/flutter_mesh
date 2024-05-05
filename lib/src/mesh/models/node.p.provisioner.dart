part of 'node.dart';

extension NodeProvisionerX on Node {
  /// Returns weather Composition Data has been applied to the Node.
  bool get isCompositionDataReceived {
    return companyIdentifier != null;
  }
}
