import 'package:flutter_mesh/src/mesh/types.dart';
import 'dart:math' as math;

import '../bearer.dart';

// TODO: https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Bearer/GATT/ProxyProtocolHandler.swift

//  Segmentation and Reassembly (SAR)
// @see https://www.bluetooth.com/mesh-feature-enhancements-summary/
abstract class SAR {
  final Uint8 value;

  const SAR._(this.value);

  factory SAR.fromData(List<int> data) {
    final int sarValue = data[0] >> 6;
    switch (sarValue) {
      case 0:
        return CompleteMessage();
      case 1:
        return FirstSegment();
      case 2:
        return Continuation();
      case 3:
        return LastSegment();
      default:
        throw ArgumentError('Invalid SAR value');
    }
  }
}

class CompleteMessage extends SAR {
  CompleteMessage() : super._(0 << 6);
}

class FirstSegment extends SAR {
  FirstSegment() : super._(1 << 6);
}

class Continuation extends SAR {
  Continuation() : super._(2 << 6);
}

class LastSegment extends SAR {
  LastSegment() : super._(3 << 6);
}

class ProxyProtocolHandler {
  List<Data> segment({
    required Data data,
    required PduType messageType,
    required int mtu,
  }) {
    final packets = <Data>[];

    if (data.length <= mtu - 1) {
      final singlePacket =
          Data.from([CompleteMessage().value | messageType.value]);
      singlePacket.addAll(data); // TODO: test this
      packets.add(singlePacket);
      return packets;
    }

    for (int i = 0; i < data.length; i += mtu - 1) {
      final SAR sar;
      if (i == 0) {
        sar = FirstSegment();
      } else if (i + mtu - 1 >= data.length) {
        sar = LastSegment();
      } else {
        sar = Continuation();
      }

      // Creating the single packet
      final List<int> singlePacket = [
        sar.value | messageType.value
      ]; // Adjusted for messageType's Dart equivalent

      singlePacket.addAll(data.sublist(i, math.min(data.length, i + mtu - 1)));
      packets.add(singlePacket);
    }

    return packets;
  }
}
