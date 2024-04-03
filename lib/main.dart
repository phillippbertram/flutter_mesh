import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/logger/logger.dart';

import 'src/app.dart';
import 'src/screens/settings/settings_controller.dart';

void main() async {
  logger.t("starting application");

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController.instance;

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp());
}
