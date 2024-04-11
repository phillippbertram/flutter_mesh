import 'package:equatable/equatable.dart';
import 'package:flutter_mesh/src/logger/logger.dart';

import '../model_delegate.dart';
import '../types.dart';
import 'element.dart';

part 'model.g.name.dart';

// TODO: JSON Serialization + Equatable + Hashable

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20Model/Model.swift#L45
class Model extends Equatable {
  Model._({
    required this.modelId,
    required this.delegate,
    // TODO:
    //   self.subscribe = []
    //   self.bind      = []
    //   self.delegate  = nil
  });

  factory Model.createWithSigModelId(
    Uint16 sigModelId, {
    required ModelDelegate delegate,
  }) {
    return Model._(modelId: sigModelId, delegate: delegate);
  }

  factory Model.createWithVendorModelId(
    Uint16 vendorModelId, {
    required Uint16 companyId,
    required ModelDelegate delegate,
  }) {
    final modelId = (companyId << 16) | vendorModelId;
    return Model._(modelId: modelId, delegate: delegate);
  }

  /// Bluetooth SIG or vendor-assigned model identifier.
  ///
  /// In case of vendor models the 2 most significant bytes of this property are
  /// the Company Identifier, as registered in Bluetooth SIG Assigned Numbers database.
  ///
  /// For Bluetooth SIG defined models these 2 bytes are `0x0000`.
  ///
  /// Use ``Model/modelIdentifier`` to get the 16-bit model identifier and
  /// ``Model/companyIdentifier`` to obtain the Company Identifier.
  ///
  /// Use ``Model/isBluetoothSIGAssigned`` to check whether the Model is defined by
  /// Bluetooth SIG.
  ///
  /// - since: 4.0.0
  final Uint32 modelId;

  // TODO: test this
  /// Bluetooth SIG or vendor-assigned model identifier.
  Uint16 get modelIdentifier => modelId & 0x0000FFFF;

  /// The Company Identifier or `nil`, if the model is Bluetooth SIG-assigned.
  Uint16? get companyIdentifier {
    if (modelId > 0xFFFF) {
      return modelId >> 16;
    }
    return null;
  }

  // TODO:
  // final List<String> subscribe;

  MeshElement? get parentElement => _parentElement;
  MeshElement? _parentElement; // NOTE: no WeakReference needed in dart?
  void setParentElement(MeshElement parentElement) {
    _parentElement = parentElement;
  }

  /// The model message handler. This is non-`nil` for supported local Models
  /// and `nil` for Models of remote Nodes.
  final ModelDelegate? delegate;

  /// Returns `true` for Models with identifiers assigned by Bluetooth SIG,
  /// `false` otherwise.
  bool get isBluetoothSIGAssigned {
    return modelId <= 0xFFFF;
  }

  // EQUATABLE
  @override
  List<Object?> get props => [
        modelId, parentElement,
        // TODO:
        // bind, subscribe, publish
      ];
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20API/Models.swift#L536

// The following are the Bluetooth SIG Model Identifiers.
// These are used to identify the models defined by the Bluetooth SIG.
// The Bluetooth SIG has assigned a 16-bit Model Identifier for each model.
// The Model Identifier is a unique 16-bit number that identifies a model within a SIG Model.
class ModelIdentifier {
  // Foundation
  static const Uint16 configurationServer = 0x0000;
  static const Uint16 configurationClient = 0x0001;
  static const Uint16 healthServer = 0x0002;
  static const Uint16 healthClient = 0x0003;

  // TODO: add the remaining models

  // Generic
  static const genericOnOffServer = 0x1000;
  static const genericOnOffClient = 0x1001;
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20Model/Model.swift#L232
extension ModelExtensions on Model {
  bool get isConfigurationServer =>
      modelIdentifier == ModelIdentifier.configurationServer;
  bool get isConfigurationClient =>
      modelIdentifier == ModelIdentifier.configurationClient;

  bool get isHealthServer => modelIdentifier == ModelIdentifier.healthServer;
  bool get isHealthClient => modelIdentifier == ModelIdentifier.healthClient;

  // TODO: add the remaining models
}

// internal

extension ModelInternalExtensions on Model {
  /// Copies the properties from the given Model.
  ///
  /// - parameter model: The Model to copy from.
  // NOTE: renamed from `copy(from:)`
  void applyFrom(Model model) {
    logger.f("MISSING IMPLEMENTATION: applyFrom");

    // TODO:
    // bind = model.bind;
    // subscribe = model.subscribe;
    // publish = model.publish;
  }
}
