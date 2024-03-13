import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'model.dart'; // Assuming you have a Model class defined somewhere
import 'location.dart'; // Assuming you have a Location enum or class defined

part 'element.freezed.dart';
part 'element.g.dart';

@freezed
class Element with _$Element {
  const factory Element({
    String? name,
    required int index,
    required Location location,
    required List<Model> models,
    // parentNode is not directly included, as weak references don't directly translate to Dart.
    // Consider how you manage back references in Dart, possibly using identifiers.
  }) = _Element;

  // Custom methods and getters can be added here. For example:
  // bool get isPrimary => index == 0;

  factory Element.fromJson(Map<String, dynamic> json) =>
      _$ElementFromJson(json);

  // Additional methods or logic can be implemented here, such as initialization logic
  // that was in the Swift's init methods. Consider using factory constructors or static methods.
}
