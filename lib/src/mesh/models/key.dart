import 'package:dart_mesh/src/mesh/types.dart';

typedef KeyIndex = Uint16;

abstract class Key {
  String get name;
  Uint16 get index;
  Data get key;
}
