// TODO: JSON Serialization + Equatable

import 'element.dart';

class Node {
  Node._({
    required this.uuid,
    required this.name,
  });

  factory Node.create({
    required String uuid,
    required String name,
  }) {
    return Node._(
      uuid: uuid,
      name: name,
    );
  }

  final String uuid;
  final String name;

  final List<Element> elements = []; // TODO:
}
