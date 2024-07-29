import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/screens/network/node_config/node_config_page.dart';
import 'package:flutter_mesh/src/screens/network/provisioning/device_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showDeviceScanner(context);
            },
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final appNetworkManager = AppNetworkManager.instance;
    final network = appNetworkManager.meshNetworkManager.meshNetwork;
    final nodes = network?.nodes ?? [];
    if (network == null || nodes.isEmpty) {
      return _buildEmptyView(context);
    }

    // TODO: group nodes?

    return RefreshIndicator(
      onRefresh: () async {
        appNetworkManager.reload();
      },
      child: ListenableBuilder(
          listenable: appNetworkManager.meshNetworkManager.meshNetwork!,
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final node = network.nodes[index];
                final elements = node.elements.length;
                final models = node.elements.fold<int>(
                  0,
                  (previousValue, element) =>
                      previousValue + element.models.length,
                );
                return ListTile(
                  tileColor: Theme.of(context).hoverColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NodeConfigPage(node: node),
                      ),
                    );
                  },
                  title: Text(
                    node.name ?? "Node ${node.uuid}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          children: [
                            const Text("Name"),
                            Text(node.name ?? "n/a"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("UUID"),
                            Text(node.uuid.uuidString),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Address"),
                            Text("${node.primaryUnicastAddress}"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Elements"),
                            Text("$elements"),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text("Models"),
                            Text("$models"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: EmptyView(
          image: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Image.network(
              "https://picsum.photos/seed/home/100/100",
            ),
          ),
          title: const Text("Network"),
          subtitle: const Text(
            "No nodes or provisioners found in the network.",
          ),
          action: ElevatedButton(
            onPressed: () {
              _showDeviceScanner(context);
            },
            child: const Text("Scan for devices"),
          )),
    );
  }
}

void _showDeviceScanner(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        return const DeviceScannerPage();
      },
    ),
  );
}
