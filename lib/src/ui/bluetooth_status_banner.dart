import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class BluetoothStatusBanner extends HookWidget {
  const BluetoothStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final snapshot = useStream(FlutterBluePlus.adapterState);
    final status =
        snapshot.hasData ? snapshot.data! : FlutterBluePlus.adapterStateNow;

    if (status.isOn) {
      return const SizedBox.shrink();
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: context.theme.appColors.error.defaultColor,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "Bluetooth is ${status.title}",
              style: context.theme.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status.instruction,
              style: context.theme.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ));
  }
}

extension on BluetoothAdapterState {
  bool get isOn => this == BluetoothAdapterState.on;

  String get instruction {
    if (this == BluetoothAdapterState.unavailable) {
      return "Bluetooth is not available on this device.";
    }

    if (!isOn) {
      return "Please enable Bluetooth to use this app.";
    }

    return "";
  }

  String get title {
    switch (this) {
      case BluetoothAdapterState.unknown:
        return "Unknown";
      case BluetoothAdapterState.unavailable:
        return "Unavailable";
      case BluetoothAdapterState.unauthorized:
        return "Unauthorized";
      case BluetoothAdapterState.turningOn:
        return "Turning On";
      case BluetoothAdapterState.on:
        return "On";
      case BluetoothAdapterState.turningOff:
        return "Turning Off";
      case BluetoothAdapterState.off:
        return "Off";
    }
  }
}
