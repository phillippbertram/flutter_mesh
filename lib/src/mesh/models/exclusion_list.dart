import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'iv_index.dart';

part 'exclusion_list.freezed.dart';

@freezed
class ExclusionList with _$ExclusionList {
  const factory ExclusionList({
    /// The IV Index of the mesh network that was in use while the Unicast Addresses
    /// were marked as excluded.
    required Uint32 ivIndex,

    /// Excluded Unicast Addresses for the particular IV Index.
    @Default([]) List<Address> addresses,
  }) = _ExclusionList;
}

extension ExclusionListAddress on ExclusionList {
  /// Checks if the given address is excluded.
  bool isExcluded(Address address) {
    return addresses.contains(address);
  }

  /// Adds the given address to the exclusion list.
  void excludeAddress(Address address) {
    // TODO: should not be possible with @freezed

    if (address.isUnicast) {
      return;
    }

    if (!addresses.contains(address)) {
      addresses.add(address);
    }
  }
}

extension ExclusionListX on List<ExclusionList> {
  /// List of excluded Unicast Addresses for the given IV Index.
  ///
  /// - parameter ivIndex: The current IV Index.
  List<Address> excludedAddressesForIvIndex(IvIndex ivIndex) {
    return where((element) =>
            element.ivIndex == ivIndex.index ||
            (ivIndex.index > 0 && element.ivIndex == ivIndex.index - 1))
        .expand((element) => element.addresses)
        .toList();
  }
}
