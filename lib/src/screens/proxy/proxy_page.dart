import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class ProxyPage extends StatelessWidget {
  const ProxyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: this will not refresh
    final connection = AppNetworkManager.instance.connection;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy'),
      ),
      body: SectionedListView(
        children: [
          Section.children(
            children: [
              ListTile(
                title: Text('Open NetworkConnection'),
                trailing: TextButton(
                  onPressed: () {
                    connection?.open();
                  },
                  child: const Text("Open"),
                ),
              ),
              // TODO:
              const ListTile(
                title: Text('Automatic Connection'),
                trailing: Switch(value: false, onChanged: null),
              ),
              ListTile(
                title: Text('Proxy'),
                trailing: Text(connection?.name ?? 'Unknown'),
              ),
              ListTile(
                trailing: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          context.theme.appColors.error.defaultColor,
                    ),
                    onPressed: null,
                    child: const Text("Disconnect")),
              )
            ],
          ),
          Section.children(
            title: const Text("Proxy Filter"),
            children: const [],
          )
        ],
      ),
    );
  }
}
