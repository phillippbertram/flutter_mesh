import 'dart:async';

import 'package:flutter_mesh/src/logger/logger.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/provisioning/algorithms.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';
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

  var _provisioningState = const ProvisioningState.ready();

  @override
  void initState() {
    super.initState();
    // TODO:  auto connect to device
    widget.device.bearer.open();
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
          _disconnectAndClosePage();
          return;
        }
      }
    }).addTo(_subscriptions);

    _provisioningManager.stateStream.listen((state) {
      setState(() {
        _provisioningState = state;
      });

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
          break;
        case ProvisioningStateProvisioning():
          logger.d('ProvisioningPage: Provisioning');
          break;
        case ProvisioningStateComplete():
          logger.d('ProvisioningPage: Provisioning Complete');
          logger.t('Disconnecting...');
          bearer.close();
          AppNetworkManager.instance.save();
          _showProvisioningComplete();
          break;
        case ProvisioningStateFailed(error: final error):
          logger.d('ProvisioningPage: Provisioning Failed: $error');
          _showProvisioningError(error);
          break;
      }
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
          // IconButton(
          //   icon: const Icon(Icons.stop),
          //   onPressed: () {
          //     _abort();
          //   },
          // ),
          TextButton(
            onPressed: _provisioningManager.provisioningCapabilities == null
                ? null
                : _startProvisioning,
            child: const Text("Provision"),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // TODO: refactor this
    return StreamBuilder<bool>(
      stream: widget.device.bearer.isOpenStream,
      builder: (context, snapshot) {
        final isLoading = switch (_provisioningState) {
          ProvisioningStateReady() ||
          ProvisioningStateRequestingCapabilities() =>
            true,
          _ => false,
        };

        if (isLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator.adaptive(),
                SizedBox(height: 8),
                Text("Requesting Capabilities..."),
              ],
            ),
          );
        }

        return _buildDeviceInfo();
      },
    );
  }

  Widget _buildDeviceInfo() {
    return SectionedListView(
      children: [
        Section(
          child: ListTile(
            title: const Text('Name'),
            trailing: Text(widget.device.device.name ?? ''),
          ),
        ),
        Section.children(
          header: const Text("Provisioning Data"),
          children: [
            // TODO: make this configurable
            ListTile(
              title: const Text('Unicast Address'),
              trailing: _provisioningManager.unicastAddress == null
                  ? const Text("Automatic")
                  : Text(_provisioningManager.unicastAddress!.value.toHex()),
            ),
            // TODO: make this configurable
            ListTile(
              title: const Text('Network Key'),
              trailing: _provisioningManager.networkKey == null
                  ? const Text("Automatic")
                  : Text(_provisioningManager.networkKey!.name),
            ),
          ],
        ),
        Section.children(
          header: const Text("Device Capabilities"),
          children: [
            ListTile(
              title: const Text('Elements Count'),
              subtitle: _unwrap(
                  _provisioningManager.provisioningCapabilities
                      ?.numberOfElements, unwrap: (value) {
                return Text(value.toString());
              }, orElse: const Text("N/A")),
            ),
            ListTile(
              title: const Text('Supported Algorithms'),
              subtitle: _unwrap(
                  _provisioningManager.provisioningCapabilities?.algorithms,
                  unwrap: (value) {
                return Text(value.debugDescription);
              }, orElse: const Text("N/A")),
            ),
            ListTile(
              title: const Text('Public Key Type'),
              subtitle: _unwrap(
                _provisioningManager.provisioningCapabilities?.publicKeyType,
                unwrap: (value) => Text(value.debugDescription),
                orElse: const Text("N/A"),
              ),
            ),
            ListTile(
              title: const Text('OOB Types'),
              subtitle: _unwrap(
                _provisioningManager.provisioningCapabilities?.oobType,
                unwrap: (value) => Text(value.debugDescription),
                orElse: const Text("N/A"),
              ),
            ),
            ListTile(
              title: const Text("Output OOB Size"),
              subtitle: _unwrap(
                _provisioningManager.provisioningCapabilities?.outputOobSize,
                unwrap: (value) => Text(value.toString()),
                orElse: const Text("N/A"),
              ),
            ),
            ListTile(
              title: const Text("Supported Output OOB Actions"),
              subtitle: _unwrap(
                _provisioningManager.provisioningCapabilities?.outputOobActions,
                unwrap: (value) => Text(value.debugDescription),
                orElse: const Text("N/A"),
              ),
            ),
            ListTile(
              title: const Text("Input OOB Size"),
              subtitle: _unwrap(
                _provisioningManager.provisioningCapabilities?.inputOobSize,
                unwrap: (value) => Text(value.toString()),
                orElse: const Text("N/A"),
              ),
            ),
            ListTile(
              title: const Text("Supported Input OOB Actions"),
              subtitle: _unwrap(
                _provisioningManager.provisioningCapabilities?.inputOobActions,
                unwrap: (value) => Text(value.debugDescription),
                orElse: const Text("N/A"),
              ),
            )
          ],
        ),
      ],
    );
  }

  void _connect() {
    widget.device.bearer.open();
  }

  void _showProvisioningError(Object? error) {
    showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Provisioning Error"),
            content: Text(error?.toString() ?? "Unknown Error"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _disconnectAndClosePage();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  void _showProvisioningComplete() {
    showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Provisioning Complete"),
            content: const Text("Device has been successfully provisioned"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _disconnectAndClosePage();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  Future<void> _disconnectAndClosePage() async {
    widget.device.bearer.close();
    Navigator.of(context).pop();
  }

  Future<void> _startProvisioning() async {
    logger.d('Provisioning Page Starting Provisioning');
    final capabilities = _provisioningManager.provisioningCapabilities;
    if (capabilities == null) {
      logger.d('Provisioning capabilities not received yet');
      return;
    }

    // TODO: if device supports oob, present the options to the user
    const publicKey = PublicKey.noOob();
    const authenticationMethod = AuthenticationMethod.noOob();

    await _provisioningManager.provision(
      algorithm: capabilities.algorithms.strongest,
      publicKey: publicKey,
      authenticationMethod: authenticationMethod,
    );
  }
}

Y _unwrap<T, Y>(T? value,
    {required Y Function(T value) unwrap, required Y orElse}) {
  if (value == null) {
    return orElse;
  }
  return unwrap(value);
}
