import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../types.dart';

// TODO: store information separately for each network uuid in an own file(?)

// e.g UserDefaults(suiteName: meshNetwork.uuid.uuidString)!

abstract class SharedPrefs {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);

  Future<bool> setInt(String key, int value);
  Future<int?> getInt(String key);

  /// Removes all key-value pairs from the storage.
  Future<bool> clear();
}

/// A custom SharedPreferences manager that prefixes keys based on a network UUID.
/// This allows for separating preferences by different network contexts within the same application.
///
/// The class requires an initialization with a UUID string that it uses to prefix the keys,
/// thereby simulating the behavior of having separate "namespaces" or "suites" as seen in some other platforms like iOS.
class NetworkSharedPreferences extends SharedPrefs {
  final String uuid;
  SharedPreferences? __prefs;

  NetworkSharedPreferences({required this.uuid});

  Future<SharedPreferences> get _prefs async {
    __prefs ??= await SharedPreferences.getInstance();
    return __prefs!;
  }

  @override
  Future<bool> setString(String key, String value) async {
    return await (await _prefs).setString('$uuid-$key', value);
  }

  @override
  Future<String?> getString(String key) async {
    return (await _prefs).getString('$uuid-$key');
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return await (await _prefs).setInt('$uuid-$key', value);
  }

  @override
  Future<int?> getInt(String key) async {
    return (await _prefs).getInt('$uuid-$key');
  }

  @override
  Future<bool> clear() async {
    // clear only the keys with the prefix
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((key) => key.startsWith('$uuid-'));
    for (final key in keys) {
      await prefs.remove(key);
    }
    return true; // TODO: check if all keys were removed
  }
}

// @see UserDefaults+SeqAuth.swift

// This extension contains helper methods for handling Sequence Numbers
// of outgoing messages from the local Node. Each message must contain
// a unique 24-bit Sequence Number, which together with 32-bit IV Index
// ensure that replay attacks are not possible.
extension SharedPrefSeqAuth on SharedPrefs {
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
    final seq = await getInt(key) ?? 0;

    // TODO: throw error or return null if seq is out of bounds? I think, a IV-Index update is required in that case.
    final nextSeq = (seq + 1) & 0xFFFFFFFF; // 0xFFFFFFFF is for 32-bit overflow
    await setInt(key, nextSeq);

    return nextSeq;
  }
}
