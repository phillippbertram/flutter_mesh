import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/mesh_extensions.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class ModelConfigPage extends StatelessWidget {
  const ModelConfigPage({super.key, required this.model});

  final Model model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Configuration'),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SectionedListView(
      children: [
        Section.children(
          title: const Text("Model Information"),
          children: [
            ListTile(
              title: const Text("Name"),
              trailing: Text('${model.name}'),
            ),
            ListTile(
              title: const Text("Model ID"),
              trailing: Text(model.modelIdentifier.asString()),
            ),
            ListTile(
              title: const Text("Company"),
              trailing: Text(model.companyName()),
            ),
            const ListTile(
              title: Text("Related Models"),
            ),
          ],
        ),
        Section.children(
          title: const Text("Bound Application Keys"),
          children: const [],
        )
      ],
    );
  }
}
