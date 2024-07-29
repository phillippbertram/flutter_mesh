import 'package:flutter_mesh/src/mesh/types.dart';

import '../../models/address.dart';
import '../../models/network_key.dart';

enum LowerTransportPduType {
  accessMessage._(0),
  controlMessage._(1);

  const LowerTransportPduType._(this.value);

  final Uint8 value;
}

mixin LowerTransportPdu {
  /// Source Address.
  Address get source;

  /// Destination Address.
  Address get destination;

  /// The Network Key used to decode/encode the PDU.
  NetworkKey get networkKey;

  /// The IV Index used to decode/encode the PDU.
  Uint32 get ivIndex;

  /// Message type.
  LowerTransportPduType get type;

  /// The raw data of Lower Transport Layer PDU.
  Data get transportPdu;

  /// The raw data of Upper Transport Layer PDU.
  Data get upperTransportPdu;
}
