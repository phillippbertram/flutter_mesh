import 'package:freezed_annotation/freezed_annotation.dart';
import '../types.dart';
import 'address.dart';

part 'address_range.freezed.dart';
part 'address_range.g.dart';

// TODO: make comparable so that this can be sorted?
// TODO: extend from RangeObject

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

  factory AddressRange.fromAddress({
    required Address address,
    required Uint8 elementsCount,
  }) =>
      AddressRange(
        low: address,
        high: address + elementsCount - 1,
      );

  factory AddressRange.fromJson(Map<String, dynamic> json) =>
      _$AddressRangeFromJson(json);
}

extension AddressRangeX on AddressRange {
  /// Checks if the given [address] is within the range.
  bool contains(Address address) {
    return address.value >= low.value && address.value <= high.value;
  }

  /// Checks if the given [range] is within the range.
  bool containsRange(AddressRange range) {
    return range.low.value >= low.value && range.high.value <= high.value;
  }

  /// Checks if the given [range] overlaps with the range.
  bool overlapsRange(AddressRange range) {
    return low.value <= range.high.value && high.value >= range.low.value;
  }
}

extension ListAddressRangeX on List<AddressRange> {
  /// Checks if the given [address] is within any of the ranges.
  bool containsAddress(Address address) {
    return any((range) => range.contains(address));
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/Ranges.swift#L255
extension ListAddressRangeRanges on List<AddressRange> {
  /// Returns `true` if all the address ranges are of unicast type.
  ///
  /// - returns: `True` if the all address ranges are of unicast type,
  ///            `false` otherwise.
  bool get isUnicastRange {
    return !any((range) => !range.isUnicastRange);
  }

  /// Returns `true` if all the address ranges are of group type.
  ///
  /// - returns: `True` if the all address ranges are of group type,
  ///            `false` otherwise.
  bool get isGroupRange {
    return !any((range) => !range.isGroupRange);
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/Ranges.swift#L200
extension AddressRangeRanges on AddressRange {
  /// Returns `true` if the address range is valid. Valid address ranges
  /// are in Unicast or Group ranges.
  ///
  /// - returns: `True` if the address range is in Unicast or Group range,
  ///            `false` otherwise.
  bool get isValid {
    return isUnicastRange || isGroupRange;
  }

  /// Returns `true` if the address range is in Unicast address range
  ///
  /// - returns: `True` if the address range is in Unicast address range,
  ///            `false` otherwise.
  bool get isUnicastRange {
    return low.isUnicast && high.isUnicast;
  }

  /// Returns `true` if the address range is in Group address range.
  ///
  /// - returns: `True` if the address range is in Group address range,
  ///            `false` otherwise.
  // var isGroupRange: Bool {
  //     return lowAddress.isGroup && highAddress.isGroup
  // }
  bool get isGroupRange {
    return low.isGroup && high.isGroup;
  }
}
