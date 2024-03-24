import 'package:freezed_annotation/freezed_annotation.dart';

enum KeyRefreshPhase {
  @JsonValue(0)
  normalOperation,

  @JsonValue(1)
  keyDistribution,

  @JsonValue(2)
  usingNewKeys,
}
