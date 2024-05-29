import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/screens/settings/bluetooth/widgets/extra.dart';

import 'device_page.dart';
import 'widgets/widgets.dart';

class ScanResultsPage extends StatelessWidget {
  const ScanResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.scanResults,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Scan Results (${snapshot.data?.length ?? 0})"),
            actions: [
              StreamBuilder<bool>(
                stream: FlutterBluePlus.isScanning,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!) {
                    return const IconButton(
                      onPressed: null,
                      icon: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          body: _buildBody(context, snapshot),
        );
      },
    );
  }

  Future<void> _onConnectPressed(
    BuildContext context,
    BluetoothDevice device,
  ) async {
    device.connectAndUpdateStream().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error connecting to device: $error"),
      ));
    });

    final route =
        MaterialPageRoute(builder: (context) => DevicePage(device: device));
    Navigator.of(context).push(route);
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<ScanResult>> snapshot,
  ) {
    if (!snapshot.hasData) {
      return const SizedBox();
    }

    final results = snapshot.data!;
    results.sort((a, b) => -a.rssi.compareTo(b.rssi));

    return ListView(
      children: results
          .map((result) => ScanResultTile(
                result: result,
                onTap: () => _onConnectPressed(context, result.device),
              ))
          .toList(),
    );
  }
}
