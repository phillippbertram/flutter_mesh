import 'package:flutter_mesh/src/mesh/models/node.dart';

import '../types.dart';

/// The state of a feature.
///
/// A Node can have features enabled, disabled, or may not support one.
enum NodeFeatureState {
  /// The feature is disabled.
  notEnabled._(0),

  /// The feature is enabled.
  enabled._(1),

  /// The feature is not supported by the Node.
  notSupported._(2);

  const NodeFeatureState._(this.value);

  final Uint8 value;
}

/// The features state object represents the functionality of a mesh node
/// that is determined by the set features that the node supports.
class NodeFeaturesState {
  final NodeFeatureState? relay;
  final NodeFeatureState? proxy;
  final NodeFeatureState? friend;
  final NodeFeatureState? lowPower;

  // TODO:
  // internal var rawValue: UInt16 {
  //       var bitField: UInt16 = 0
  //       if relay    == .notSupported {} else { bitField |= 0x01 }
  //       if proxy    == .notSupported {} else { bitField |= 0x02 }
  //       if friend   == .notSupported {} else { bitField |= 0x04 }
  //       if lowPower == .notSupported {} else { bitField |= 0x08 }
  //       return bitField
  //   }

  const NodeFeaturesState({
    this.relay,
    this.proxy,
    this.friend,
    this.lowPower,
  });

  const NodeFeaturesState.allNotSupported()
      : relay = NodeFeatureState.notSupported,
        proxy = NodeFeatureState.notSupported,
        friend = NodeFeatureState.notSupported,
        lowPower = NodeFeatureState.notSupported;
}
