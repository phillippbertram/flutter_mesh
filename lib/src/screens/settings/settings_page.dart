import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/screens/settings/app_keys/app_keys.dart';
import 'package:flutter_mesh/src/screens/settings/bluetooth/device_page.dart';
import 'package:flutter_mesh/src/screens/settings/bluetooth/scan_results_page.dart';
import 'package:flutter_mesh/src/ui/ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'bluetooth/widgets/widgets.dart';
import 'network_keys/network_keys.dart';
import 'shared_prefs_debug_page.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SectionedListView(
        children: [
          Section.children(
            title: const Text("UI"),
            children: [
              ListTile(
                title: const Text("Appearance"),
                trailing: Consumer<AppTheme>(builder: (context, appTheme, _) {
                  return DropdownButton<ThemeMode>(
                    // Read the selected themeMode from the controller
                    value: appTheme.themeMode,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: (mode) {
                      if (mode != null) {
                        appTheme.themeMode = mode;
                      }
                    },
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
          _bluetoothSection(context),
          _networkSettingsSection(context),
          _miscSection(context),
          const Section(
            child: AppVersion(),
          ),
        ],
      ),
    );
  }

  Section _networkSettingsSection(BuildContext context) {
    final network = AppNetworkManager.instance.meshNetworkManager.meshNetwork;
    if (network == null) {
      return Section.children(
        title: const Text("Mesh Network"),
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Mesh Network"),
          IconButton(
              onPressed: () {
                AppNetworkManager.instance.reload();
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      children: [
        ListTile(
          title: const Text("Name"),
          trailing: Text(network.meshName),
        ),
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
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const AppKeysPage();
            }));
          },
        ),
        ListTile(
          title: const Text("Last Modified"),
          trailing: Text(network.timestamp.toString()),
        ),
        ListTile(
          trailing: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.theme.appColors.error.defaultColor,
              ),
              onPressed: () async {
                final shouldReset = await _showForgetNetworkPrompt(context);
                if (shouldReset) {
                  AppNetworkManager.instance.createNewMeshNetwork();
                  AppNetworkManager.instance.save();
                }
              },
              child: const Text("Forget this Network")),
        )
      ],
    );
  }

  Section _miscSection(BuildContext context) {
    return Section.children(
      title: const Text("Misc"),
      children: [
        ListTile(
            title: const Text("Shared Prefs"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SharedPrefsDebugPage(),
                ),
              );
            }),
      ],
    );
  }

  Section _bluetoothSection(BuildContext context) {
    return Section.children(
      title: const Text("Bluetooth"),
      children: [
        ListTile(
          dense: true,
          title: const Text("Status"),
          trailing: StreamBuilder<BluetoothAdapterState>(
            stream: FlutterBluePlus.adapterState,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data!) {
                  case BluetoothAdapterState.on:
                    return const Text("On");
                  case BluetoothAdapterState.off:
                    return const Text("Off");
                  case BluetoothAdapterState.turningOn:
                    return const Text("Turning On");
                  case BluetoothAdapterState.turningOff:
                    return const Text("Turning Off");
                  case BluetoothAdapterState.unknown:
                    return const Text("Unknown");
                  case BluetoothAdapterState.unavailable:
                    return const Text("Unavailable");
                  case BluetoothAdapterState.unauthorized:
                    return const Text("Unauthorized");
                }
              }
              return const SizedBox();
            },
          ),
        ),
        ListTile(
          dense: true,
          title: const Text("Scanning"),
          trailing: StreamBuilder<bool>(
            stream: FlutterBluePlus.isScanning,
            builder: (context, snapshot) {
              final isScanning = snapshot.data ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      AppNetworkManager.instance.connection?.open();
                    },
                    child: Text(isScanning ? "Stop" : "Start"),
                  ),
                  const SizedBox(width: 8),
                  Text(isScanning ? "Yes" : "No"),
                ],
              );
            },
          ),
        ),
        ListTile(
          dense: true,
          title: const Text("Scan Results"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const ScanResultsPage();
            }));
          },
        ),
        ListTile(
          dense: true,
          title: const Text("Connected Devices"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const BluetoothConnectedDevicesPage();
            }));
          },
        ),
        ListTile(
          dense: true,
          title: const Text("Events"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const BluetoothEventsPage();
            }));
          },
        ),
      ],
    );
  }
}

Future<bool> _showForgetNetworkPrompt(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Forget Network"),
            content:
                const Text("Are you sure you want to forget this network?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.theme.appColors.error.defaultColor,
                ),
                child: const Text("Forget"),
              ),
            ],
          );
        },
      ) ??
      false;
}

class AppVersion extends HookWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfo = useState<PackageInfo?>(null);
    useEffect(() {
      PackageInfo.fromPlatform().then((packageInfo) {
        appInfo.value = packageInfo;
      });

      return null;
    }, const []);

    return appInfo.value == null
        ? const SizedBox()
        : ListTile(
            title: const Text("App Version"),
            trailing: Text(appInfo.value!.version),
          );
  }
}

class BluetoothEventsPage extends StatelessWidget {
  const BluetoothEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = FlutterBluePlus.events;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Events"),
      ),
      body: ListView(
        children: [
          StreamBuilder(
            stream: events.onConnectionStateChanged,
            builder: (context, snapshot) {
              return ListTile(
                title: const Text("Connection State Changed"),
                subtitle: Text(snapshot.data?.connectionState.toString() ??
                    "No connection state"),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BluetoothConnectedDevicesPage extends StatefulWidget {
  const BluetoothConnectedDevicesPage({super.key});

  @override
  State<BluetoothConnectedDevicesPage> createState() =>
      _BluetoothConnectedDevicesPageState();
}

class _BluetoothConnectedDevicesPageState
    extends State<BluetoothConnectedDevicesPage> {
  List<BluetoothDevice> _connectedDevices = FlutterBluePlus.connectedDevices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connected Devices"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _connectedDevices = FlutterBluePlus.connectedDevices;
        },
        child: _connectedDevices.isEmpty ? _buildEmpty() : _buildDeviceList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text("No connected devices"),
    );
  }

  Widget _buildDeviceList() {
    return ListView(
      children: _connectedDevices
          .map(
            (device) => SystemDeviceTile(
                device: device,
                onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DevicePage(device: device),
                      ),
                    ),
                onConnect: () {
                  // TODO:
                }),
          )
          .toList(),
    );
  }
}
