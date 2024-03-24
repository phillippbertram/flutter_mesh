import 'package:flutter/material.dart';

import 'device_scan_service.dart';

class ProvisioningPage extends StatelessWidget {
  const ProvisioningPage({
    super.key,
    required this.device,
  });

  final DiscoveredPeripheral device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Capabilities'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Name'),
            trailing: Text(device.device.name ?? ''),
          ),

          const Text("Provisioning Data"),
          const ListTile(
            title: Text('Unicast Address'),
            trailing: Text("Automatic"),
          ),
          const ListTile(
            title: Text('Network Key'),
            trailing: Text("-"),
          ),

          const Text("Device Capabilities"),
          const ListTile(
            title: Text('Elements Cound'),
          ),
          const ListTile(
            title: Text('Supported Algorithms'),
          ),
          const ListTile(
            title: Text('Public Key Type'),
          ),
          const ListTile(
            title: Text('OOB Types'),
          ),
          // TODO: ...
        ],
      ),
    );
  }
}
