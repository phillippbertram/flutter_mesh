import 'package:dart_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../settings/settings_page.dart';
import 'sample_item.dart';
import 'device_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
  });

  static const routeName = '/';

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final appNetworkManager = AppNetworkManager.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Devices'),
        actions: [
          IconButton(
            onPressed: () {
              appNetworkManager.connection?.open();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsPage.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (appNetworkManager.connection == null) {
      return const Text("No connection");
    }

    return StreamBuilder<List<ScanResult>>(
      stream: appNetworkManager.connection!.scanResults,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No devices found'),
          );
        }

        final devices = snapshot.data!
            .map((scanResult) => DiscoveredDevice(scanResult))
            .toList();

        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (BuildContext context, int index) {
            final item = devices[index];

            return ListTile(
                title: Text(
                    "${item.scanResult.device.platformName} - ${item.scanResult.device.remoteId}"),
                subtitle: Text(item.scanResult.advertisementData.advName),
                // TODO: remove
                // leading: const CircleAvatar(
                //   // Display the Flutter Logo image asset.
                //   foregroundImage:
                //       AssetImage('assets/images/flutter_logo.png'),
                // ),
                trailing: Text(item.scanResult.rssi.toString()),
                onTap: () {
                  // Navigate to the details page. If the user leaves and returns to
                  // the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.restorablePushNamed(
                    context,
                    SampleItemDetailsView.routeName,
                  );
                });
          },
        );
      },
    );
  }
}
