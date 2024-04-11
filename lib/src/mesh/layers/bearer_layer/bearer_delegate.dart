import '../../types.dart';
import 'bearer.dart';

// TODO: just tried out "mixin" here instead of "abstract class"

/// A bearer data delegate processes mesh messages received by the bearer.
mixin BearerDataDelegate {
  /// Callback called when a packet has been received using the Bearer.
  /// Data longer than MTU will automatically be reassembled
  /// using the bearer protocol if bearer implements segmentation.
  ///
  /// - parameters:
  ///   - bearer: The Bearer on which the data were received.
  ///   - data:   The data received.
  ///   - type:   The type of the received data.
  void bearerDidDeliverData(Data data, PduType type);
}
