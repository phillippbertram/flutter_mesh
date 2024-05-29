import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

import 'proxy_selection_page.dart';

class ProxyPage extends StatefulWidget {
  const ProxyPage({super.key});

  @override
  State<ProxyPage> createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage> {
  var _isConnectionModeAutomatic = false;

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
                title: const Text('Automatic Connection'),
                trailing: Switch(
                  value: _isConnectionModeAutomatic,
                  onChanged: (value) => setState(() {
                    _isConnectionModeAutomatic = value;
                  }),
                ),
              ),
              ListTile(
                title: const Text("Proxy"),
                subtitle: Text(connection?.name ?? 'Unknown'),
                trailing: _isConnectionModeAutomatic
                    ? const Icon(Icons.chevron_right)
                    : null,
                onTap: !_isConnectionModeAutomatic
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const ProxySelectionPage(),
                          ),
                        );
                      },
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
