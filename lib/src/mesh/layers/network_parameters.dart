import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_parameters.freezed.dart';

@freezed
class NetworkParameters with _$NetworkParameters {
  const factory NetworkParameters({
    required int defaultTtl, // TODO: UInt8 type
  }) = _NetworkParameters;
}

abstract class NetworkParametersProvider {
  NetworkParameters get networkParameters;
}
