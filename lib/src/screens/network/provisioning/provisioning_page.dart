import 'dart:async';

import 'package:dart_mesh/src/mesh/mesh.dart';
import 'package:dart_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:dart_mesh/src/mesh/provisioning/provisioning_manager.dart';
import 'package:dart_mesh/src/mesh/provisioning/public_key.dart';
import 'package:dart_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'device_scan_service.dart';

class ProvisioningPage extends StatefulWidget {
  const ProvisioningPage({
    super.key,
    required this.device,
  });

  final DiscoveredPeripheral device;

  @override
  State<ProvisioningPage> createState() => _ProvisioningPageState();
}

class _ProvisioningPageState extends State<ProvisioningPage> {
  late ProvisioningManager _provisioningManager;

  final _subscriptions = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    // TODO:  auto connect to device
    // widget.device.bearer.open();
    final device = widget.device.device;
    final bearer = widget.device.bearer;

    final manager = AppNetworkManager.instance.meshNetworkManager;
    final res = manager.provision(
      unprovisionedDevice: device,
      bearer: bearer,
    );
    if (res.isError) {
      print('Error: ${res.asError!.error}');
      // TODO: showError
      return;
    }

    _provisioningManager = res.asValue!.value;
    // TODO: provisioningManager.logger =

    _subscriptions.add(bearer.isOpenStream.listen((isOpen) async {
      if (isOpen) {
        final res = await _provisioningManager.identify(
          attentionTimer: const Duration(minutes: 2), // same as in JungHome App
        );
        if (res.isError) {
          print('Error: ${res.asError!.error}');
          _abort();
          return;
        }
      }
    }));

    _subscriptions.add(_provisioningManager.stateStream.listen((state) {
      state.when(ready: () {
        // nothing to do
      }, requestingCapabilities: () {
        print('Requesting Capabilities');
        _startProvisioning(); // TODO: remove this here
      }, capabilitiesReceived: (capabilities) {
        print('Capabilities Received: $capabilities');
      }, provisioning: () {
        print('Provisioning');
      }, complete: () {
        print('Provisioning Complete');
      }, failed: (error) {
        print('Provisioning Failed: $error');
      });
    }));
  }

  @override
  void dispose() {
    widget.device.bearer.close();
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Capabilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              _abort();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<bool>(
      stream: widget.device.bearer.isOpenStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return _buildDeviceInfo();
        }

        return Center(
          child: ElevatedButton(
            onPressed: () {
              widget.device.bearer.open();
            },
            child: const Text("Connect to device and identify"),
          ),
        );
      },
    );
  }

  Widget _buildDeviceInfo() {
    return ListView(
      children: [
        ListTile(
          title: const Text('Name'),
          trailing: Text(widget.device.device.name ?? ''),
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
          title: Text('Elements Count'),
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
    );
  }

  Future<void> _abort() async {
    await widget.device.bearer.close();

    // TODO: dismiss
  }

  void _startProvisioning() {
    // TODO:
    // if (_provisioningManager.provisioningCapabilities == null) {
    //   print('Provisioning capabilities not received yet');
    //   return;
    // }

    // // TODO: do stuff

    // _provisioningManager.provision();
    _provisioningManager.startProvisioning(
      algorithm: Algorithm.BTM_ECDH_P256_CMAC_AES128_AES_CCM,
      publicKey: NoOobPublicKey(),
      authenticationMethod: NoOob(),
    );
  }
}
