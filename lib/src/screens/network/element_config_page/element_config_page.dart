import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/utils/company_identifier.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

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
              title: Text("Unicast Address"),
              trailing: Text(element.unicastAddress.toString()),
            ),
            ListTile(
              title: Text("Location"),
              trailing: Text(element.location.toString()),
            ),
          ],
        ),
        Section.children(
          title: Text("Models"),
          children: [
            if (element.models.isEmpty)
              ListTile(
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
  return element.models.map((model) {
    final isSIGModel = model.isBluetoothSIGAssigned;
    var modelName =
        model.name ?? "Unknown Model ${model.modelIdentifier.asString()}";
    if (isSIGModel) {
      return ListTile(
        title: Text(modelName),
        subtitle: const Text("Bluetooth SIG"),
      );
    }

    modelName = "Vendor Model ${model.modelIdentifier.asString()}";
    final String companyName;
    if (model.companyIdentifier != null) {
      final companyIdName = model.companyIdentifier!.companyNameForId();
      if (companyIdName != null) {
        companyName = companyIdName;
      } else {
        companyName = "Company ID: ${model.companyIdentifier}";
      }
    } else {
      companyName = "Company ID: Unknown";
    }
    return ListTile(
      title: Text(modelName),
      subtitle: Text(companyName),
    );
  }).toList();
}
