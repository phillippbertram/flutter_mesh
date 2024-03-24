// Bluetooth Mesh address type in Dart.
// Represents various address types used in Bluetooth mesh networking.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  // Using int to represent UInt16 values from Swift, since Dart does not have an UInt16.
  // Static constants for address ranges.
  static const Address unassignedAddress = Address(0x0000);
  static const Address minUnicastAddress = Address(0x0001);
  static const Address maxUnicastAddress = Address(0x7FFF);
  static const Address minVirtualAddress = Address(0x8000);
  static const Address maxVirtualAddress = Address(0xBFFF);
  static const Address minGroupAddress = Address(0xC000);
  static const Address maxGroupAddress = Address(0xFEFF);
  static const Address allProxies = Address(0xFFFC);
  static const Address allFriends = Address(0xFFFD);
  static const Address allRelays = Address(0xFFFE);
  static const Address allNodes = Address(0xFFFF);

  const factory Address(int value) = _Address;

  const Address._();

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  // Helper methods as getters in Dart.

  // Checks if the address is valid (not in the reserved range).
  bool get isValidAddress => value < 0xFF00 || value > 0xFFFB;

  // Checks if the address is unassigned.
  bool get isUnassigned => value == Address.unassignedAddress.value;

  // Checks if the address is a unicast address.
  bool get isUnicast => (value & 0x8000) == 0x0000 && !isUnassigned;

  // Checks if the address is a virtual address.
  bool get isVirtual => (value & 0xC000) == 0x8000;

  // Checks if the address is a group address.
  bool get isGroup => (value & 0xC000) == 0xC000 && isValidAddress;

  // Checks if the address is a special group address.
  bool get isSpecialGroup => value >= 0xFF00;
}
