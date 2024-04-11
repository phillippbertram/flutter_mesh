import 'package:flutter/material.dart' hide Element;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/ui/section.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

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
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SectionedListView(
      children: [
        Section.children(
          title: const Text('Node Information'),
          children: [
            ListTile(
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UUID: ${node.uuid}'),
                  Text('Name: ${node.name}'),
                ],
              ),
            ),
          ],
        ),
        Section.children(
          title: const Text("Keys"),
          children: [
            ListTile(
              title: const Text('Device Key'),
              trailing: Text(node.deviceKey?.toHex() ?? "None"),
            ),
            ListTile(
              title: const Text('App Keys'),
              trailing: Text(node.appKeys.length.toString()),
            ),
            const ListTile(
              title: Text('Network Keys'),
              trailing: Text("TBS"), // TODO:
            ),
          ],
        ),
        Section.children(
          children: [
            ListTile(
              title: const Text('Primary Unicast Address'),
              trailing: Text(node.primaryUnicastAddress.toString()),
            ),
            const ListTile(
              title: Text('Default TTL'),
              trailing: Text("TBD"), // TODO:
            ),
          ],
        ),
        Section.children(
          title: const Text('Elements'),
          children: [
            for (final element in node.elements)
              ListTile(
                title: Text(element.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${element.location}'),
                    Text('Models: ${element.models.length}'),
                  ],
                ),
              ),
          ],
        ),
        Section.children(
          title: const Text("Node Information"),
          children: const [
            ListTile(
              title: Text('Company Identifier'),
              trailing: Text('TBD'), // TODO:
            ),
            ListTile(
              title: Text('Product Identifier'),
              trailing: Text('TBD'), // TODO:
            ),
            ListTile(
              title: Text('Product Version'),
              trailing: Text('TBD'), // TODO:
            ),
            ListTile(
              title: Text('Replay Protection Count'),
              trailing: Text('TBD'), // TODO:
            ),
            ListTile(
              title: Text('Features'),
              trailing: Text('TBD'), // TODO:
            ),
            ListTile(
              title: Text('Security'),
              trailing: Text('TBD'), // TODO:
            ),
          ],
        ), // TODO:

        Section.children(
          children: [
            // TODO:
            HookBuilder(builder: (context) {
              final value = useState(false);
              return SwitchListTile(
                value: value.value,
                onChanged: (newValue) => value.value = newValue,
                title: const Text('Config Complete'),
              );
            }),

            // TODO:
            HookBuilder(builder: (context) {
              final value = useState(false);
              return SwitchListTile(
                value: value.value,
                onChanged: (newValue) => value.value = newValue,
                title: const Text('Excluded'),
              );
            })
          ],
        ),

        Section.children(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      // TODO:
                    },
                    child: Text("Reset"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          context.theme.appColors.error.defaultColor,
                    )),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      // TODO:
                    },
                    child: Text("Remove"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          context.theme.appColors.error.defaultColor,
                    )),
              ),
            )
          ],
        ),
      ],
    );
  }
}

extension on Element {
  String get displayName {
    return name ?? 'Element $index';
  }
}
