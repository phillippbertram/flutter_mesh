import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';

class NetworkKeysPage extends StatelessWidget {
  const NetworkKeysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final network = AppNetworkManager.instance.meshNetworkManager.meshNetwork;
    final networkKeys = network?.networkKeys ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text("Network Keys")),
      body: _buildNetworkKeysList(context, networkKeys),
    );
  }

  Widget _buildNetworkKeysList(
      BuildContext context, List<NetworkKey> networkKeys) {
    return ListView.builder(
      itemCount: networkKeys.length,
      itemBuilder: (context, index) {
        final networkKey = networkKeys[index];
        return ListTile(
            title: Text(networkKey.name),
            trailing: const Icon(Icons.chevron_right),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Key: ${networkKey.key.toHex()}"),
                Text("Index: ${networkKey.index}"),
              ],
            ),
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(
                  text: networkKey.key.toHex(),
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Network key copied to clipboard"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            });
      },
    );
  }
}
