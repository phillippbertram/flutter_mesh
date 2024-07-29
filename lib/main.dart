import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/logger/logger.dart';

import 'src/app.dart';

void main() async {
  logger.t("starting application");

  WidgetsFlutterBinding.ensureInitialized();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(const MyApp());
}
