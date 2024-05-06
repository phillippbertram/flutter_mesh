import 'package:freezed_annotation/freezed_annotation.dart';

import '../types.dart';

part 'network_parameters.freezed.dart';

/// A set of network parameters that can be applied to the ``MeshNetworkManager``.
///
/// Network parameters configure the transmission and retransmission intervals,
/// acknowledge message timeout, the default Time To Live (TTL) and other.
///
/// Use one of the following builders to create an instance of this structure:
/// - ``NetworkParameters/default`` - the default configuration
/// - ``NetworkParameters/basic(_:)`` - using verbose builder
/// - ``NetworkParameters/advanced(_:)`` - for advanced users
///
/// - since: 4.0.0
/// TODO:
@freezed
class NetworkParameters with _$NetworkParameters {
  const factory NetworkParameters({
    required Uint8 defaultTtl,
  }) = _NetworkParameters;

  static const defaultNetworkParameters = NetworkParameters(
    defaultTtl: 5,
  );
}

// TODO: make use of this in `NetworkManager`
abstract class NetworkParametersProvider {
  NetworkParameters get networkParameters;
}
