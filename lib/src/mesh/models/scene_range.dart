import 'package:flutter_mesh/src/mesh/models/range_object.dart';
import 'package:flutter_mesh/src/mesh/models/scene_number.dart';

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20Model/SceneRange.swift

class SceneRange extends RangeObject {
  SceneRange({
    required SceneNumber first,
    required SceneNumber last,
  }) : super(
          lowerBound: first.value,
          upperBound: last.value,
        );

  /// A range containing all valid Scene Numbers.
  static final allScenes = SceneRange(
    first: SceneNumber.minScene,
    last: SceneNumber.maxScene,
  );

  SceneNumber get firstScene => SceneNumber(lowerBound);
  SceneNumber get lastScene => SceneNumber(upperBound);
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/4.2.0/Library/Mesh%20API/Ranges.swift
extension SceneRangeX on SceneRange {
  /// Returns `true` if the scene range is valid.
  ///
  /// - returns: `True` if the scene range is valid, `false` otherwise.
  bool get isValid {
    return firstScene.isValidSceneNumber && lastScene.isValidSceneNumber;
  }
}

extension SceneRangeListX on List<SceneRange> {
  /// Returns `true` if all the scene ranges are valid.
  ///
  /// - returns: `True` if the all scene ranges are valid, `false` otherwise.
  bool get isValid {
    return !any((range) => !range.isValid);
  }
}
