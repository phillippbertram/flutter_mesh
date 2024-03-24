import 'package:dart_mesh/src/mesh/types.dart';
import 'package:dart_mesh/src/mesh/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene_number.freezed.dart';
part 'scene_number.g.dart';

// TODO: check serialization

@freezed
class SceneNumber with _$SceneNumber {
  static const SceneNumber invalidScene = SceneNumber(0x0000);
  static const SceneNumber minScene = SceneNumber(0x0001);
  static const SceneNumber maxScene = SceneNumber(0xFFFF);

  const factory SceneNumber(Uint16 value) = _SceneNumber;

  factory SceneNumber.fromJson(Map<String, dynamic> json) =>
      _$SceneNumberFromJson(json);
}

extension SceneNumberX on SceneNumber {
  bool get isValidSceneNumber {
    return this != SceneNumber.invalidScene;
  }
}

// Converts a SceneNumber to plain JSON value and back
class SceneNumberConverter implements JsonConverter<SceneNumber, String> {
  const SceneNumberConverter();

  @override
  SceneNumber fromJson(String json) {
    return SceneNumber(json.toIntFromHex());
  }

  @override
  String toJson(SceneNumber object) => object.value.toHex();
}
