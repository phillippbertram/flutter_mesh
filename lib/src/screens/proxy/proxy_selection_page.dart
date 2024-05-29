import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/screens/settings/bluetooth/widgets/extra.dart';

import '../settings/bluetooth/widgets/widgets.dart';

class ProxySelectionPage extends StatelessWidget {
  const ProxySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Selection'),
      ),
      body: _buildDevices(context),
    );
  }

  Widget _buildDevices(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.scanResults,
      builder: ((context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final results = snapshot.data!;
        results.sort((a, b) => -a.rssi.compareTo(b.rssi));

        // TODO: filter out devices that are not Mesh devices

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return ScanResultTile(
              result: result,
              onTap: () async {
                final proxy = GattBearer.targetPeripheral(result.device);

                try {
                  await proxy.open();
                  await AppNetworkManager.instance.connection?.useProxy(proxy);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Error connecting to device: $error"),
                    ));
                  }
                }
              },
            );
          },
        );
      }),
    );
  }
}
