import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/screens/network/provisioning/device_scan_service.dart';
import 'package:flutter_mesh/src/screens/network/provisioning/provisioning_page.dart';
import 'package:flutter/material.dart';

class DeviceScannerPage extends StatefulWidget {
  const DeviceScannerPage({super.key});

  @override
  State<DeviceScannerPage> createState() => _DeviceScannerPageState();
}

class _DeviceScannerPageState extends State<DeviceScannerPage> {
  final _deviceScanService = DeviceProvisioningScanService();

  @override
  initState() {
    super.initState();
    // TODO:
    // _deviceScanService.checkPermissions().then((hasPermissions) {
    //   if (!hasPermissions) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Bluetooth not enabled or permission denied'),
    //       ),
    //     );
    //   } else {
    //     _deviceScanService.startScan();
    //   }
    // });
    _deviceScanService.startScan();
  }

  @override
  void dispose() {
    _deviceScanService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provision Device'),
        actions: [
          StreamBuilder<bool>(
            stream: _deviceScanService.isScanningStream,
            initialData: false,
            builder: (context, snapshot) {
              final isScanning = snapshot.data!;
              return IconButton(
                // TODO: disable stop action, when scanning, not needed. Its just for testing
                icon: isScanning
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.search),
                onPressed: () {
                  if (isScanning) {
                    _deviceScanService.stopScan();
                  } else {
                    _deviceScanService.startScan();
                  }
                },
              );
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<DiscoveredPeripheral>>(
      stream: _deviceScanService.scanResults,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        final scanResults = snapshot.data!;
        if (scanResults.isEmpty) {
          return const Center(
            child: Text('No devices found'),
          );
        }

        return ListView.builder(
          itemCount: scanResults.length,
          itemBuilder: (context, index) {
            final device = scanResults[index];
            return DiscoveredDeviceTile(
              device: device,
              onTap: () {
                _deviceScanService.stopScan();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProvisioningPage(device: device),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class DiscoveredDeviceTile extends StatelessWidget {
  const DiscoveredDeviceTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  final DiscoveredPeripheral device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.scanResult.device.platformName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataRow(
            title: "Localname",
            value: device.scanResult.advertisementData.advName,
          ),
          _buildDataRow(
            title: "UUID",
            value: device.device.uuid.toString(),
          ),
          _buildDataRow(
            title: 'OOB',
            value: device.device.oobInformation.rawValue.toHex(),
          ),
          _buildDataRow(
            title: "Manufacturer",
            value:
                device.scanResult.advertisementData.manufacturerData.toString(),
          ),
          _buildDataRow(
            title: "Advertisement",
            value: device.scanResult.advertisementData.toString(),
          ),
          const SizedBox(height: 12),
          RssiIndicator(rssi: device.scanResult.rssi),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDataRow({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(width: 8),
        Flexible(child: Text(value)),
      ],
    );
  }
}

class RssiIndicator extends StatelessWidget {
  const RssiIndicator({
    super.key,
    required this.rssi,
  });

  final num rssi;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getRssiColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'RSSI: $rssi dBm',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Color _getRssiColor() {
    if (rssi >= -50) {
      return Colors.green;
    } else if (rssi >= -70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
