import 'package:flutter_mesh/src/mesh/models/scene_number.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene_range.freezed.dart';
part 'scene_range.g.dart';

@freezed
class SceneRange with _$SceneRange {
  /// A range containing all valid Scene Numbers.
  static const allScenes = SceneRange(
    first: SceneNumber.minScene,
    last: SceneNumber.maxScene,
  );

  const factory SceneRange({
    required SceneNumber first,
    required SceneNumber last,
  }) = _SceneRange;

  factory SceneRange.fromJson(Map<String, dynamic> json) =>
      _$SceneRangeFromJson(json);
}
