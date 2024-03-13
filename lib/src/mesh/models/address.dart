// Bluetooth Mesh address type in Dart.
// Represents various address types used in Bluetooth mesh networking.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  // Using int to represent UInt16 values from Swift, since Dart does not have an UInt16.
  // Static constants for address ranges.
  static const int unassignedAddress = 0x0000;
  static const int minUnicastAddress = 0x0001;
  static const int maxUnicastAddress = 0x7FFF;
  static const int minVirtualAddress = 0x8000;
  static const int maxVirtualAddress = 0xBFFF;
  static const int minGroupAddress = 0xC000;
  static const int maxGroupAddress = 0xFEFF;
  static const int allProxies = 0xFFFC;
  static const int allFriends = 0xFFFD;
  static const int allRelays = 0xFFFE;
  static const int allNodes = 0xFFFF;

  const factory Address(int value) = _Address;

  const Address._();

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  // Helper methods as getters in Dart.

  // Checks if the address is valid (not in the reserved range).
  bool get isValidAddress => value < 0xFF00 || value > 0xFFFB;

  // Checks if the address is unassigned.
  bool get isUnassigned => value == Address.unassignedAddress;

  // Checks if the address is a unicast address.
  bool get isUnicast => (value & 0x8000) == 0x0000 && !isUnassigned;

  // Checks if the address is a virtual address.
  bool get isVirtual => (value & 0xC000) == 0x8000;

  // Checks if the address is a group address.
  bool get isGroup => (value & 0xC000) == 0xC000 && isValidAddress;

  // Checks if the address is a special group address.
  bool get isSpecialGroup => value >= 0xFF00;
}
