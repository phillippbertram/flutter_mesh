import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh/models/node.dart';
import 'package:flutter_mesh/src/ui/empty_view.dart';

class NodeConfigPage extends StatelessWidget {
  const NodeConfigPage({
    super.key,
    required this.node,
  });

  final Node node;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Node Configuration'),
      ),
      body: Center(
        child: EmptyView(
          title: Text(node.name ?? "Node"),
          subtitle: const Text(
            "Not implemented yet",
          ),
        ),
      ),
    );
  }
}
