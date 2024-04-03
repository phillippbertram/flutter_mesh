/// The type representing Security level for the subnet on which a
/// node has been originally provisioned.
enum Security {
  // A key is considered insecure if at least one Node has been provisioned
  /// without using Out-Of-Band Public Key exchange. This Node is also considered
  /// insecure.
  secure,

  // A key is considered secure if all Nodes which know the key have been
  /// provisioned using Secure Procedure, that is using Out-Of-Band Public Key.
  insecure;

  factory Security.fromJson(String value) {
    switch (value) {
      case 'secure':
      case 'high':
        return Security.secure;
      case 'insecure':
      case 'low':
        return Security.insecure;
      default:
        throw ArgumentError('Unknown Security value: $value');
    }
  }

  String toJson() {
    switch (this) {
      case Security.secure:
        return 'secure';
      case Security.insecure:
        return 'insecure';
    }
  }
}
