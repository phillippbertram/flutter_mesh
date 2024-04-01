import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

import 'network_keys/network_keys.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  static const routeName = '/settings';

  final _settingsController = SettingsController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SectionedListView(
        children: [
          Section.children(
            header: const Text("UI"),
            children: [
              ListTile(
                title: const Text("Appearance"),
                trailing: ListenableBuilder(
                    listenable: _settingsController,
                    builder: (context, _) {
                      return DropdownButton<ThemeMode>(
                        // Read the selected themeMode from the controller
                        value: _settingsController.themeMode,
                        // Call the updateThemeMode method any time the user selects a theme.
                        onChanged: _settingsController.updateThemeMode,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System Theme'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light Theme'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark Theme'),
                          )
                        ],
                      );
                    }),
              ),
            ],
          ),
          _buildNetworkSettingsSection(context),
        ],
      ),
    );
  }

  Section _buildNetworkSettingsSection(BuildContext context) {
    final network = AppNetworkManager.instance.meshNetworkManager.meshNetwork;
    if (network == null) {
      return Section.children(
        header: const Text("Mesh Network"),
        children: [
          ListTile(
              title: const Text("No network"),
              trailing: ElevatedButton(
                onPressed: () {
                  AppNetworkManager.instance.createNewMeshNetwork();
                },
                child: const Text("Create Network"),
              )),
        ],
      );
    }
    return Section.children(
      header: const Text("Mesh Network"),
      children: [
        ListTile(
          title: const Text("Provisioners"),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(network.provisioners.length.toString()),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        ListTile(
          title: const Text("Network Keys"),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(network.networkKeys.length.toString()),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const NetworkKeysPage();
            }));
          },
        ),
        ListTile(
          title: const Text("Application Keys"),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(network.applicationKeys.length.toString()),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        ListTile(
          title: const Text("Last Modified"),
          trailing: Text(network.timestamp.toString()),
        ),
      ],
    );
  }
}
