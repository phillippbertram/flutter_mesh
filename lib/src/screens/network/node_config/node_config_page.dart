import 'package:flutter/material.dart' hide Element;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

import '../element_config_page/element_config_page.dart';

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
    return RefreshIndicator(
      onRefresh: () async {
        await _loadCompositionData(context);
      },
      child: SectionedListView(
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
                trailing: Text(node.applicationKeys.length.toString()),
              ),
              const ListTile(
                title: Text('Network Keys'),
                trailing: Text("TBD"), // TODO:
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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ElementConfigPage(element: element),
                    ));
                  },
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
                  onChanged: (newValue) {
                    value.value = newValue;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not implemented yet'),
                        duration: Durations.medium3,
                      ),
                    );
                  },
                  title: const Text('Config Complete'),
                );
              }),

              // TODO:
              HookBuilder(builder: (context) {
                final value = useState(false);
                return SwitchListTile(
                  value: value.value,
                  onChanged: (newValue) {
                    value.value = newValue;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not implemented yet'),
                        duration: Durations.medium3,
                      ),
                    );
                    ;
                  },
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
                      onPressed: () async {
                        const message = ConfigNodeReset();
                        final res = await AppNetworkManager
                            .instance.meshNetworkManager
                            .sendConfigMessageToNode(
                          message,
                          node: node,
                        );
                        if (!context.mounted) {
                          return;
                        }

                        if (res.isValue) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Node reset successful'),
                              duration: Durations.long1,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to reset node: ${res.asError!.error}'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            context.theme.appColors.error.defaultColor,
                      ),
                      child: const Text("Reset")),
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
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            context.theme.appColors.error.defaultColor,
                      ),
                      child: const Text("Remove")),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadCompositionData(BuildContext context) async {
    final snack = ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loading composition data...'),
      ),
    );

    final message = ConfigCompositionDataGet();
    final res = await AppNetworkManager.instance.meshNetworkManager
        .sendConfigMessageToNode(
      message,
      node: node,
    );
    snack.close();

    if (!context.mounted) {
      return;
    }

    if (res.isValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Composition data loaded'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load composition data: ${res.asError!.error}'),
        ),
      );
    }
  }
}

extension on MeshElement {
  String get displayName {
    return name ?? 'Element $index';
  }
}
