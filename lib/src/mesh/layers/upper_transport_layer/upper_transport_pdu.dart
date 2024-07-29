// TODO: internal
import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/models/iv_index.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';
import 'package:flutter_mesh/src/mesh/types.dart';

import '../../mesh_messages/mesh_messages.dart';
import '../../models/address.dart';
import '../../models/mesh_address.dart';
import '../../utils/crypto.dart';
import '../access_layer/access_pdu.dart';
import '../key_set.dart';

class UpperTransportPdu {
  const UpperTransportPdu._({
    required this.message,
    required this.userInitiated,
    required this.source,
    required this.destination,
    required this.aid,
    required this.sequence,
    required this.ivIndex,
    required this.transportMicSize,
    required this.accessPdu,
    required this.transportPdu,
  });

  factory UpperTransportPdu.fromAccessPdu(
    AccessPdu pdu, {
    required KeySet keySet,
    required Uint32 sequence,
    required IvIndex ivIndex,
  }) {
    final accessPdu = pdu.accessPdu;
    final security = pdu.message!.security;
    final destination = pdu.destination;
    final source = pdu.source;

    // The nonce type is 0x01 for messages signed with Application Key and
    // 0x02 for messages signed using Device Key (Configuration Messages).
    final Uint8 type = keySet.aid != null ? 0x01 : 0x02;

    // ASZMIC is set to 1 for messages that shall be sent with high security
    // (64-bit TransMIC). This is possible only for Segmented Access Messages.
    final Uint8 aszmic = security == MeshMessageSecurity.high &&
            (accessPdu.length > 11 || pdu.isSegmented)
        ? 1
        : 0;

    // Convert sequence to big-endian bytes
    final sequenceBigEndian = Uint8List(4)
      ..buffer.asByteData().setInt32(0, sequence, Endian.big);

    // SEQ is 24-bit value, in Big Endian.
    final seq = sequenceBigEndian.dropFirst();

    final nonce = Data.from([type, aszmic << 7])
        .combineWith(seq)
        .addUint16(source.value, endian: Endian.big)
        .addUint16(destination.address.value, endian: Endian.big)
        .addUint32(ivIndex.transmitIndex, endian: Endian.big);

    final transportMicSize = aszmic == 0 ? 4 : 8;
    final transportPdu = Crypto.encryptData(
      accessPdu,
      encryptionKey: keySet.accessKey,
      nonce: nonce,
      micSize: transportMicSize,
      additionalData: pdu.destination.virtualLabel?.data, // TODO: check this
    );

    return UpperTransportPdu._(
      message: pdu.message,
      userInitiated: pdu.userInitiated,
      source: source,
      destination: destination,
      aid: keySet.aid,
      sequence: sequence,
      ivIndex: ivIndex.transmitIndex,
      transportMicSize: transportMicSize,
      accessPdu: accessPdu,
      transportPdu: transportPdu,
    );
  }

  /// The Mesh Message that is being sent, or `nil`, when the message
  /// was received.
  final MeshMessage? message;

  /// Whether sending this message has been initiated by the user.
  final bool userInitiated;

  /// Source Address.
  final Address source;

  /// Destination Address.
  final MeshAddress destination;

  /// 6-bit Application Key identifier. This field is set to `nil`
  /// if the message is signed with a Device Key instead.
  final Uint8? aid;

  /// The sequence number used to encode this message.
  final Uint32 sequence;

  /// The IV Index used to encode this message.
  final Uint32 ivIndex;

  /// The size of Transport MIC: 4 or 8 bytes.
  final Uint8 transportMicSize;

  /// The Access Layer data.
  final Data accessPdu;

  /// The raw data of Upper Transport Layer PDU.
  final Data transportPdu;
}
