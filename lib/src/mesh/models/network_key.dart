import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_key.freezed.dart';
part 'network_key.g.dart';

@freezed
class NetworkKey with _$NetworkKey {
  const factory NetworkKey({
    required int index,
  }) = _NetworkKey;

  factory NetworkKey.fromJson(Map<String, dynamic> json) =>
      _$NetworkKeyFromJson(json);
}
