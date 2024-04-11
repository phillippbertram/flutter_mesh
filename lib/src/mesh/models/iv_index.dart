import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'iv_index.freezed.dart';

@freezed
class IvIndex with _$IvIndex {
  const factory IvIndex({
    required int index,
    @Default(false) bool updateActive,
  }) = _IvIndex;
}

extension IvIndexX on IvIndex {
  /// The IV Index used for transmitting messages.
  Uint32 get transmitIndex {
    if (updateActive && index > 0) {
      return index - 1;
    }
    return index;
  }
}
