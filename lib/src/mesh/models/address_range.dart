import 'package:freezed_annotation/freezed_annotation.dart';
import 'address.dart';

part 'address_range.freezed.dart';
part 'address_range.g.dart';

// TODO: make comparable so that this can be sorted?

@freezed
class AddressRange with _$AddressRange {
  /// A range containing all valid Unicast Addresses.
  static const allUnicastAddresses = AddressRange(
    low: Address.minUnicastAddress,
    high: Address.maxUnicastAddress,
  );

  /// A range containing all Group Addresses.
  ///
  /// This range does not exclude Fixed Group Addresses or Virtual Addresses.
  static const allGroupAddresses = AddressRange(
    low: Address.minGroupAddress,
    high: Address.maxGroupAddress,
  );

  const factory AddressRange({
    required Address low,
    required Address high,
  }) = _AddressRange;

  factory AddressRange.fromJson(Map<String, dynamic> json) =>
      _$AddressRangeFromJson(json);
}

extension AddressRangeX on AddressRange {
  /// Checks if the given address is within the range.
  bool contains(Address address) {
    return address.value >= low.value && address.value <= high.value;
  }

  /// Checks if the given range is within the range.
  bool containsRange(AddressRange range) {
    return range.low.value >= low.value && range.high.value <= high.value;
  }
}
