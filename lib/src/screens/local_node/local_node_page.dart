import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/screens/network/provisioning/device_scanner_page.dart';

class LocalNodePage extends StatelessWidget {
  const LocalNodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Node'),
        centerTitle: false,
      ),
      body: const Center(
        child: SignalStrengthIndicator(signalStrength: 4),
      ),
    );
  }
}
