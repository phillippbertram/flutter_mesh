import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';
part 'model.g.dart'; // For JSON serialization

@freezed
class Model with _$Model {
  const factory Model({
    required int modelId,
    @Default([]) List<String> subscribe,
    // Additional fields and logic for publish, bind, etc.
  }) = _Model;

  // Convenience getters and methods for modelId, subscribe, etc., can be added here.

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);
}
