import 'dart:async';

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
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
    final res = manager.provisionManager(
      unprovisionedDevice: device,
      bearer: bearer,
    );
    if (res.isError) {
      logger.d('Error: ${res.asError!.error}');
      // TODO: showError
      return;
    }

    _provisioningManager = res.asValue!.value;
    // TODO: provisioningManager.logger =

    bearer.isOpenStream.listen((isOpen) async {
      if (isOpen) {
        final res = await _provisioningManager.identify(
          attentionTimer: const Duration(minutes: 2), // same as in JungHome App
        );
        if (res.isError) {
          logger.d('Error: ${res.asError!.error}');
          _abort();
          return;
        }
      }
    }).addTo(_subscriptions);

    _provisioningManager.stateStream.listen((state) {
      switch (state) {
        case ProvisioningStateReady():
          logger.d('ProvisioningPage: Ready');
          break;
        case ProvisioningStateRequestingCapabilities():
          logger.d('ProvisioningPage: Requesting Capabilities');
          break;
        case ProvisioningStateCapabilitiesReceived(
            capabilities: final capabilities
          ):
          logger.d('ProvisioningPage: Capabilities Received: $capabilities');
          _startProvisioning();
          break;
        case ProvisioningStateProvisioning():
          logger.d('ProvisioningPage: Provisioning');
          break;
        case ProvisioningStateComplete():
          logger.d('ProvisioningPage: Provisioning Complete');
          break;
        case ProvisioningStateFailed(error: final error):
          logger.d('ProvisioningPage: Provisioning Failed: $error');
          break;
      }

      // state.when(ready: () {
      //   logger.d('Ready');
      //   // nothing to do
      // }, requestingCapabilities: () {
      //   logger.d('Requesting Capabilities');
      //   _startProvisioning(); // TODO: remove this here
      // }, capabilitiesReceived: (capabilities) {
      //   logger.d('Capabilities Received: $capabilities');
      // }, provisioning: () {
      //   logger.d('Provisioning');
      // }, complete: () {
      //   logger.d('Provisioning Complete');
      // }, failed: (error) {
      //   logger.d('Provisioning Failed: $error');
      // });
    }).addTo(_subscriptions);
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

  Widget _buildProvisioningState() {
    return StreamBuilder<ProvisioningState>(
      stream: _provisioningManager.stateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data!;
          switch (state) {
            case ProvisioningStateReady():
              return const Text('Ready');
            case ProvisioningStateRequestingCapabilities():
              return const Text('Requesting Capabilities');
            case ProvisioningStateCapabilitiesReceived(
                capabilities: final capabilities
              ):
              return Text('Capabilities Received: $capabilities');
            case ProvisioningStateProvisioning():
              return const Text('Provisioning');
            case ProvisioningStateComplete():
              return const Text('Provisioning Complete');
            case ProvisioningStateFailed(error: final error):
              return Text('Provisioning Failed: $error');
          }
        }

        return const SizedBox();
      },
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
        _buildProvisioningState(),

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

    // TODO: dismiss this view?
  }

  Future<void> _startProvisioning() async {
    logger.d('Provisioning Page Starting Provisioning');
    final capabilities = _provisioningManager.provisioningCapabilities;
    if (capabilities == null) {
      logger.d('Provisioning capabilities not received yet');
      return;
    }

    // TODO: do stuff

    await _provisioningManager.provision(
      algorithm: capabilities.algorithms.strongest,
      publicKey: const PublicKey.noOob(), // TODO: obtain dynamically
      authenticationMethod:
          const AuthenticationMethod.noOob(), // TODO: obtain dynamically
    );
  }
}
