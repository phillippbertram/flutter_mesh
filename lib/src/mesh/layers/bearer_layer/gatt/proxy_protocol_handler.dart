import 'package:flutter_mesh/src/mesh/types.dart';
import 'dart:math' as math;

import '../bearer.dart';

// TODO: @freezed?

// TODO: https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Bearer/GATT/ProxyProtocolHandler.swift

//  Segmentation and Reassembly (SAR)
// @see https://www.bluetooth.com/mesh-feature-enhancements-summary/
sealed class SAR {
  final Uint8 value;

  const SAR._(this.value);

  static SAR? fromData(List<int> data) {
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
        return null;
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
  Data? _buffer;
  PduType? _bufferType;

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

  /// This method consumes the given data. If the data were segmented,
  /// they are buffered until the last segment is received.
  /// This method returns the message and its type when the last segment
  /// (or the only one) has been received, otherwise it returns `nil`.
  ///
  /// The packets must be delivered in order. If a new message is
  /// received while the previous one is still reassembled, the old
  /// one will be disregarded. Invalid messages are disregarded.
  ///
  /// - parameter data: The data received.
  /// - returns: The message and its type, or `nil`, if more data
  ///            are expected.
  ({Data data, PduType messageType})? reassemble(Data data) {
    if (data.isEmpty) {
      return null;
    }

    final sar = SAR.fromData(data);
    if (sar == null) {
      return null;
    }

    final messageType = PduType.fromData(data);
    if (messageType == null) {
      return null;
    }

    // Ensure, that only complete message or the first segment may be
    // processed if the buffer is empty.
    if (_buffer == null && (sar is! CompleteMessage && sar is! FirstSegment)) {
      return null;
    }

    // If the new packet is a continuation/lastSegment, it should have the
    // same message type as the current buffer.
    if (_buffer != null &&
        _bufferType != messageType &&
        (sar is! CompleteMessage && sar is! FirstSegment)) {
      return null;
    }

    // If a new message was received while the old one was
    // processed, disregard the old one.
    if (_buffer != null && (sar is CompleteMessage || sar is FirstSegment)) {
      _buffer = null;
      _bufferType = null;
    }

    // Save the message type and append newly received data.
    _bufferType = messageType;
    if (sar is CompleteMessage || sar is LastSegment) {
      _buffer = Data.empty(growable: true);
    }
    _buffer!.addAll(data.sublist(1));

    // If the complete message was received, return it.
    if (sar is CompleteMessage || sar is LastSegment) {
      final tmp = _buffer!;
      _buffer = null;
      _bufferType = null;
      return (data: tmp, messageType: messageType);
    }

    // just return null
    return null;
  }
}
