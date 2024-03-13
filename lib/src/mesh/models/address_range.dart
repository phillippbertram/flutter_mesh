import 'package:freezed_annotation/freezed_annotation.dart';
import 'address.dart';

part 'address_range.freezed.dart';
part 'address_range.g.dart';

@freezed
class AddressRange with _$AddressRange {
  const factory AddressRange({
    required Address lowAddress,
    required Address highAddress,
  }) = _AddressRange;

  factory AddressRange.fromJson(Map<String, dynamic> json) =>
      _$AddressRangeFromJson(json);
}
