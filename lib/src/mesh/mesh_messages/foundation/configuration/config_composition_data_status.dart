import 'dart:typed_data';

import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh/models/node_features.dart';
import 'package:flutter_mesh/src/mesh/type_extensions/data.dart';

import '../../../../logger/logger.dart';

/// A base protocol of a single Page of Composition Data.
///
/// The Composition Data state contains information about a Node,
/// the Elements it includes, and the supported models.
///
/// The Composition Data is composed of a number of pages of information.
abstract class CompositionDataPage {
  // Page number of the Composition Data to get.
  Uint8 get page;

  /// Composition Data parameters as Data.
  Data? get parameters;
}

class ConfigCompositionDataStatus {
  static const Uint32 opCode = 0x02;

  Data? get parameters => page?.parameters;

  final CompositionDataPage? page;

  ConfigCompositionDataStatus._({this.page});

  static ConfigCompositionDataStatus? fromData(Data data) {
    if (data.isEmpty) {
      return null;
    }

    switch (data[0]) {
      case 0:
        final page = Page0.fromData(data);
        return ConfigCompositionDataStatus._(page: page);
      default:
        return null;
    }
  }
}

/// Composition Data Page 0 shall be present on a Node.
///
/// Composition Data Page 0 shall not change during a term of a Node
/// on the network.
class Page0 extends CompositionDataPage {
  @override
  final Uint8 page = 0;

  @override
  Data? get parameters => null;

  final Uint16 companyIdentifier;
  final Uint16 productIdentifier;
  final Uint16 versionIdentifier;
  final Uint16 minimumNumberOfReplayProtectionList;
  final NodeFeaturesState features;
  final List<MeshElement> elements;

  Page0._({
    required this.companyIdentifier,
    required this.productIdentifier,
    required this.versionIdentifier,
    required this.minimumNumberOfReplayProtectionList,
    required this.features,
    required this.elements,
  });

  static Page0? fromData(Data data) {
    if (data.length < 11 || data[0] != 0) {
      return null;
    }

    final byteReader = ByteData.sublistView(data.toUint8List());

    final companyIdentifier = byteReader.getUint16(1);
    final productIdentifier = byteReader.getUint16(3);
    final versionIdentifier = byteReader.getUint16(5);
    final minimumNumberOfReplayProtectionList = byteReader.getUint16(7);
    final features = NodeFeaturesState.fromMask(byteReader.getUint16(9));

    // TODO:
    logger.f("MISSING IMPLEMENTATION: Page0.fromData - ELements not parsed.");
    final List<MeshElement> elements = [];

    return Page0._(
      companyIdentifier: companyIdentifier,
      productIdentifier: productIdentifier,
      versionIdentifier: versionIdentifier,
      minimumNumberOfReplayProtectionList: minimumNumberOfReplayProtectionList,
      features: features,
      elements: elements,
    );
  }
}
