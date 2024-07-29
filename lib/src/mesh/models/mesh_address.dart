import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/crypto.dart';
import 'address.dart';

part 'mesh_address.freezed.dart';

/// The mesh address.
///
/// An address in Mesh may be of type:
/// * Unassigned Address
/// * Unicast Address
/// * Group Address
/// * Virtual Label - a 16-byte UUID
@freezed
class MeshAddress with _$MeshAddress {
  const factory MeshAddress._({
    required Address address,
    UUID? virtualLabel,
  }) = _MeshAddress;

  factory MeshAddress.fromAddress(Address address) {
    return MeshAddress._(address: address);
  }

  factory MeshAddress.fromVirtualLabel(UUID virtualLabel) {
    return MeshAddress._(
      virtualLabel: virtualLabel,
      address: Crypto.calculateVirtualAddress(virtualLabel),
    );
  }
}
