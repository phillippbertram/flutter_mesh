import 'package:flutter_mesh/src/mesh/type_extensions/shared_pref_seq_auth.dart';
import 'package:flutter_mesh/src/mesh/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/address.dart';
import '../network_manager.dart';

class NetworkLayer {
  const NetworkLayer(this._networkManager);

  final NetworkManager _networkManager;
}

// Internal extensions

extension NetworkLayerInternal on NetworkLayer {
  Future<Uint32> nextSequenceNumber({required Address source}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.nextSequenceNumber(source: source);
  }
}
