import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mesh/src/mesh/utils/service_uuid_mapping.dart';

import "characteristic_tile.dart";

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {super.key, required this.service, required this.characteristicTiles});

  Widget buildUuid(BuildContext context) {
    final uuid = '0x${this.service.serviceUuid.str.toUpperCase()}';
    final service =
        BluetoothServicesLookup.findService(this.service.serviceUuid.str);
    final full = "${service.name} ($uuid)";
    return Text(full, style: const TextStyle(fontSize: 13));
  }

  @override
  Widget build(BuildContext context) {
    return characteristicTiles.isNotEmpty
        ? ExpansionTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Service', style: TextStyle(color: Colors.blue)),
                buildUuid(context),
              ],
            ),
            children: characteristicTiles,
          )
        : ListTile(
            title: const Text('Service'),
            subtitle: buildUuid(context),
          );
  }
}
