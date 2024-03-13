import 'package:freezed_annotation/freezed_annotation.dart';

part 'range_object.freezed.dart';

@freezed
class RangeObject with _$RangeObject {
  const factory RangeObject({
    required int lowerBound,
    required int upperBound,
  }) = _RangeObject;
}
