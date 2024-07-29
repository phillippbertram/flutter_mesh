import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/layers/upper_transport_layer/upper_transport_pdu.dart';
import 'package:flutter_mesh/src/mesh/models/address.dart';

import 'package:flutter_mesh/src/mesh/models/network_key.dart';

import 'package:flutter_mesh/src/mesh/types.dart';

import 'lower_transport_pdu.dart';

class AccessMessage with LowerTransportPdu {
  const AccessMessage._({
    required this.destination,
    required this.ivIndex,
    required this.networkKey,
    required this.source,
    required this.upperTransportPdu,
    this.aid,
    required this.sequence,
    required this.transportMicSize,
  });

  AccessMessage.fromUnsegmentedUpperTransportPdu(
    UpperTransportPdu pdu, {
    required NetworkKey networkKey,
  }) : this._(
          aid: pdu.aid,
          upperTransportPdu: pdu.transportPdu,
          transportMicSize: 4,
          source: pdu.source,
          destination: pdu.destination.address,
          sequence: pdu.sequence,
          networkKey: networkKey,
          ivIndex: pdu.ivIndex,
        );

  @override
  final Address source;

  @override
  final Address destination;

  @override
  final NetworkKey networkKey;

  @override
  final Uint32 ivIndex;

  @override
  Data get transportPdu {
    Uint8 octet0 = 0x00; // SEG = 0
    if (aid != null) {
      octet0 |= 0x40; // 0b01000000 -> AKF = 1
      octet0 |= aid!; // Directly use `aid` since it's now confirmed non-null
    }
    return Uint8List.fromList([octet0] + upperTransportPdu);
  }

  @override
  final LowerTransportPduType type = LowerTransportPduType.accessMessage;

  @override
  final Data upperTransportPdu;

  /// 6-bit Application Key identifier. This field is set to `nil`
  /// if the message is signed with a Device Key instead.
  final Uint8? aid;

  /// The sequence number used to encode this message.
  final Uint32 sequence;

  /// The size of Transport MIC: 4 or 8 bytes.
  final Uint8 transportMicSize;
}
