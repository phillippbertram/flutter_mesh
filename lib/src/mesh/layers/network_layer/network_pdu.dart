import 'package:flutter/foundation.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';

import '../../models/address.dart';
import '../../models/network_key.dart';
import '../../types.dart';
import '../../utils/crypto.dart';
import '../bearer_layer/bearer.dart';
import '../lower_transport_layer/lower_transport_pdu.dart';

// TODO: internal
class NetworkPdu {
  /// Raw PDU data.
  final Data pdu;

  /// The Network Key used to decode/encode the PDU.
  final NetworkKey networkKey;

  /// The IV Index used to decode/encode the PDU.
  final Uint32 ivIndex;

  /// Least significant bit of IV Index.
  final Uint8 ivi;

  /// Value derived from the NetKey used to identify the Encryption Key
  /// and Privacy Key used to secure this PDU.
  final Uint8 nid;

  /// PDU type.
  final LowerTransportPduType type;

  /// Time To Live.
  final Uint8 ttl;

  /// Sequence Number.
  final Uint32 sequence;

  /// Source Address.
  final Address source;

  /// Destination Address.
  final Address destination;

  /// Transport Protocol Data Unit. It is guaranteed to have 1 to 16 bytes.
  final Data transportPdu;

  const NetworkPdu._({
    required this.pdu,
    required this.networkKey,
    required this.ivIndex,
    required this.ivi,
    required this.nid,
    required this.type,
    required this.ttl,
    required this.sequence,
    required this.source,
    required this.destination,
    required this.transportPdu,
  });

  /// Creates the Network PDU. This method encrypts and obfuscates data
  /// that are to be send to the mesh network.
  ///
  /// - parameters:
  ///   - lowerTransportPdu: The data received from higher layer.
  ///   - pduType: The type of the PDU: ``PduType/networkPdu`` or ``PduType/proxyConfiguration``.
  ///   - sequence: The SEQ number of the PDU. Each PDU between the source
  ///                       and destination must have strictly increasing sequence number.
  ///   - ttl: Time To Live.
  /// - returns: The Network PDU object.
  factory NetworkPdu.encode({
    required LowerTransportPdu lowerTransportPdu,
    required PduType pduType,
    required Uint32 sequence,
    required Uint8 ttl,
  }) {
    if (pduType != PduType.networkPdu &&
        pduType != PduType.proxyConfiguration) {
      throw ArgumentError.value(
        pduType,
        'pduType',
        'Only .networkPdu and .proxyConfiguration are allowed.',
      );
    }

    // The key set used for encryption depends on the Key Refresh Phase.
    final networkKey = lowerTransportPdu.networkKey;
    final keys = networkKey.transmitKeys;

    final ivIndex = lowerTransportPdu.ivIndex;
    final Uint8 ivi = (ivIndex & 0x1);
    final nid = keys.nid;
    final type = lowerTransportPdu.type;
    final source = lowerTransportPdu.source;
    final destination = lowerTransportPdu.destination;
    final transportPdu = lowerTransportPdu.transportPdu;

    final Uint8 iviNid = (ivi << 7) | (nid & 0x7F);
    final Uint8 ctlTtl = (type.value << 7) | (ttl & 0x7F);

    // Data to be obfuscated: CTL/TTL, Sequence Number, Source Address.
    final seq = Uint8List.fromList([])
        .addUint32(sequence, endian: Endian.big)
        .combineWith(transportPdu)
        .toUint8List();
    final deobfuscatedData = Uint8List.fromList([])
        .addUint8(ctlTtl)
        .combineWith(seq)
        .addUint16(source.value, endian: Endian.big)
        .toUint8List();

    // Data to be encrypted: Destination Address, Transport PDU.
    final decryptedData = Uint8List.fromList([])
        .addUint16(destination.value, endian: Endian.big)
        .combineWith(transportPdu)
        .toUint8List();

    final nonce = Uint8List.fromList([pduType.nonceId])
        .combineWith(decryptedData)
        .combineWith(Uint8List.fromList([0x00, 0x00]))
        .addUint32(ivIndex, endian: Endian.big)
        .toUint8List();

    if (pduType == PduType.proxyConfiguration) {
      nonce[1] = 0x00; // Pad
    }

    final encryptedData = Crypto.encryptData(
      decryptedData,
      encryptionKey: keys.encryptionKey,
      nonce: nonce,
      micSize: type.netMicSize,
      additionalData: null,
    );
    final obfuscatedData = Crypto.obfuscateData(
      deobfuscatedData,
      random: encryptedData,
      ivIndex: ivIndex,
      privacyKey: Uint8List.fromList(keys.privacyKey),
    );

    final pdu = Uint8List.fromList([])
        .addUint8(iviNid)
        .combineWith(obfuscatedData)
        .combineWith(encryptedData);

    return NetworkPdu._(
      pdu: pdu,
      networkKey: networkKey,
      ivIndex: ivIndex,
      ivi: ivi,
      nid: nid,
      type: type,
      ttl: ttl,
      sequence: sequence,
      source: source,
      destination: destination,
      transportPdu: transportPdu,
    );
  }
}

extension on PduType {
  Uint8 get nonceId {
    switch (this) {
      case PduType.networkPdu:
        return 0x00;
      case PduType.proxyConfiguration:
        return 0x03;
      default:
        throw UnimplementedError("Unsupported PDU Type: $this");
    }
  }
}

extension on LowerTransportPduType {
  Uint8 get netMicSize {
    switch (this) {
      case LowerTransportPduType.accessMessage:
        return 4; // 32 bits
      case LowerTransportPduType.controlMessage:
        return 8; // 64 bits
    }
  }
}
