import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/utils/company_identifier.dart';
import 'package:flutter_mesh/src/mesh_app/mesh_extensions.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

import '../model_config_page/model_config_page.dart';

class ElementConfigPage extends StatelessWidget {
  const ElementConfigPage({
    super.key,
    required this.element,
  });

  final MeshElement element;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Element Configuration'),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SectionedListView(
      children: [
        Section.children(
          children: [
            ListTile(
              title: const Text("Name"),
              trailing: Text('${element.name}'),
            ),
          ],
        ),
        Section.children(
          children: [
            ListTile(
              title: const Text("Unicast Address"),
              trailing: Text(element.unicastAddress.toString()),
            ),
            ListTile(
              title: const Text("Location"),
              trailing: Text(element.location.toString()),
            ),
          ],
        ),
        Section.children(
          title: const Text("Models"),
          children: [
            if (element.models.isEmpty)
              const ListTile(
                dense: true,
                title: Text("No models available."),
              ),
            ..._modelWidgets(context, element),
          ],
        )
      ],
    );
  }
}

List<Widget> _modelWidgets(BuildContext context, MeshElement element) {
  showModelConfig(Model model) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModelConfigPage(model: model),
      ),
    );
  }

  return element.models.map((model) {
    final isSIGModel = model.isBluetoothSIGAssigned;
    var modelName =
        model.name ?? "Unknown Model ${model.modelIdentifier.asString()}";
    final companyName = model.companyName();
    if (isSIGModel) {
      return ListTile(
        title: Text(modelName),
        subtitle: Text(companyName),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showModelConfig(model);
        },
      );
    }

    modelName = "Vendor Model ${model.modelIdentifier.asString()}";
    return ListTile(
      title: Text(modelName),
      subtitle: Text(companyName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModelConfig(model);
      },
    );
  }).toList();
}
