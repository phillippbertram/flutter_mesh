import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/screens/network/provisioning/device_scan_service.dart';
import 'package:flutter_mesh/src/screens/network/provisioning/provisioning_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

class DeviceScannerPage extends StatefulWidget {
  const DeviceScannerPage({super.key});

  @override
  State<DeviceScannerPage> createState() => _DeviceScannerPageState();
}

class _DeviceScannerPageState extends State<DeviceScannerPage> {
  final _deviceScanService = DeviceProvisioningScanService();
  final _subscriptions = CompositeSubscription();

  var _isScanning = false;

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

    _startScan();

    _deviceScanService.isScanningStream.listen((isScanning) {
      setState(() {
        _isScanning = isScanning;
      });
    }).addTo(_subscriptions);
  }

  @override
  void dispose() {
    _deviceScanService.dispose();
    _subscriptions.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provision Device'),
        actions: [
          IconButton(
            // TODO: disable stop action, when scanning, not needed. Its just for testing
            icon: _isScanning
                ? const CircularProgressIndicator.adaptive()
                : const Icon(Icons.search),
            onPressed: () {
              if (_isScanning) {
                _deviceScanService.stopScan();
              } else {
                _startScan();
              }
            },
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<DiscoveredPeripheral>>(
      stream: _deviceScanService.scanResults,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final scanResults = snapshot.data ?? [];

        if (scanResults.isEmpty && _isScanning) {
          return _buildLoadingState(context);
        }

        if (scanResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '😭\nNo devices found!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _startScan();
                  },
                  child: const Text('Scan again'),
                )
              ],
            ),
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

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("🔎\nLooking for unprovisioned devices...",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.secondary)),
          const SizedBox(height: 8),
          const CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }

  void _startScan() {
    _deviceScanService.startScan(
      stopAfter: const Duration(seconds: 30),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.scanResult.device.platformName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                value: device.scanResult.advertisementData.manufacturerData
                    .toString(),
              ),
              _buildDataRow(
                title: "Advertisement",
                value: device.scanResult.advertisementData.toString(),
              ),
              const SizedBox(height: 12),
              // RssiIndicator(rssi: device.scanResult.rssi),
              Row(
                children: [
                  SizedBox.square(
                    dimension: 42,
                    child: SignalStrengthIndicator(
                        signalStrength: device.scanResult.rssi),
                  ),
                  Text("${device.scanResult.rssi} dBm",
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
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

class SignalStrengthIndicator extends StatelessWidget {
  final int signalStrength; // Value between 1 and 4

  const SignalStrengthIndicator({
    super.key,
    required this.signalStrength,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60), // Specify the widget's size
      painter: _SignalStrengthPainter(signalStrength),
    );
  }
}

class _SignalStrengthPainter extends CustomPainter {
  final int signalStrength;

  const _SignalStrengthPainter(this.signalStrength);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Center of the canvas
    final center = Offset(size.width / 2, size.height / 2);
    // Maximum radius based on the size of the canvas
    final maxRadius = size.width / 2;

    final discreteSignal = _convertSignalStrength(signalStrength);

    // Draw each circle with the corresponding transparency
    for (int i = 0; i < discreteSignal; i++) {
      // Adjust alpha for each circle. 255 means no transparency, and we decrease it for each outer circle.
      final alpha = (255 * (1 - (i * 0.25))).toInt();
      paint.color = AppColors.blueJay.withAlpha(alpha);

      // Adjust the radius so the innermost circle is drawn first and is the smallest
      double radius = maxRadius * ((i + 1) / 4);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  int _convertSignalStrength(int signalStrength) {
    if (signalStrength >= -50) {
      return 4;
    } else if (signalStrength >= -70) {
      return 3;
    } else if (signalStrength >= -80) {
      return 2;
    } else {
      return 1;
    }
  }
}
