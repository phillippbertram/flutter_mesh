// TODO: JSON Serialization + Equatable

class Node {
  const Node._({
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
}
