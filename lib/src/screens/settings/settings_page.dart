import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

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
          Section.children(
            header: const Text("Mesh Network"),
            children: const [
              ListTile(
                title: Text("Provisioners"),
              ),
              ListTile(
                title: Text("Network Keys"),
              ),
              ListTile(
                title: Text("Application Keys"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
