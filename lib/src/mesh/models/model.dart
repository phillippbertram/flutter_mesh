import '../types.dart';
import 'element.dart';

// TODO: JSON Serialization + Equatable

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20Model/Model.swift#L45
class Model {
  Model._({
    required this.modelId,
    // TODO:
    //   self.subscribe = []
    //   self.bind      = []
    //   self.delegate  = nil
  });

  factory Model({
    required Uint32 modelId,
  }) {
    return Model._(modelId: modelId);
  }

  factory Model.createWithSigModelId(Uint16 sigModelId) {
    return Model(modelId: sigModelId);
  }

  factory Model.createWithVendorModelId({
    required Uint16 companyIdentifier,
    required Uint16 modelIdentifier,
  }) {
    return Model(modelId: (companyIdentifier << 16) | modelIdentifier);
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

  Element? get parentElement => _parentElement;
  Element? _parentElement; // NOTE: no WeakReference needed in dart?

  void setParentElement(Element parentElement) {
    _parentElement = parentElement;
  }
}

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/267216832aaa19ba6ffa1b49720a34fd3c2f8072/Library/Mesh%20API/Models.swift#L536

// The following are the Bluetooth SIG Model Identifiers.
// These are used to identify the models defined by the Bluetooth SIG.
// The Bluetooth SIG has assigned a 16-bit Model Identifier for each model.
// The Model Identifier is a unique 16-bit number that identifies a model within a SIG Model.
class ModelIdentifier {
  // Foundation
  static const Uint16 configurationServer = 0x0000;
  static const configurationClient = 0x0001;
  static const healthServer = 0x0002;
  static const healthClient = 0x0003;

  // Configuration models added in Mesh Protocol 1.1

  // Generic
  static const genericOnOffServer = 0x1000;
}
