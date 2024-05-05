import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../types.dart';

// @see UserDefaults+SeqAuth.swift

// This extension contains helper methods for handling Sequence Numbers
// of outgoing messages from the local Node. Each message must contain
// a unique 24-bit Sequence Number, which together with 32-bit IV Index
// ensure that replay attacks are not possible.
extension SharedPrefSeqAuth on SharedPreferences {
  /// Returns the next SEQ number to be used to send a message from
  /// the given Unicast Address.
  ///
  /// Each time this method is called returned value is incremented by 1.
  ///
  /// Size of SEQ is 24 bits.
  ///
  /// - parameter source: The Unicast Address of local Element.
  /// - returns: The next SEQ number to be used.
  Future<Uint32> nextSequenceNumber({required Address source}) async {
    final key = "S${source.toString()}";
    final seq = getInt(key) ?? 0;
    final nextSeq = (seq + 1) & 0xFFFFFF;
    await setInt(key, nextSeq);
    return nextSeq;
  }
}
