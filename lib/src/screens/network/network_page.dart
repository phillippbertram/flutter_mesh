import 'package:flutter_mesh/src/screens/network/provisioning/device_scanner_page.dart';
import 'package:flutter/material.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return const DeviceScannerPage();
                  },
                ),
              );
            },
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // TODO: show nodes and provisioners
    return const Center(
      child: Text('Network Page'),
    );
  }
}
