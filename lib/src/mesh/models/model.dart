import '../types.dart';
import 'element.dart';

// TODO: JSON Serialization + Equatable

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20Model/Model.swift#L45
class Model {
  Model._({required this.modelId});

  factory Model({
    required Uint32 modelId,
  }) {
    return Model._(modelId: modelId);
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
  Uint16 get modelIdentitfier => modelId & 0x0000FFFF;

  /// The Company Identifier or `nil`, if the model is Bluetooth SIG-assigned.
  Uint16? get companyIdentifier {
    if (modelId > 0xFFFF) {
      return modelId >> 16;
    }
    return null;
  }

  // TODO:
  // final List<String> subscribe;

  Element? get parentElement => _parentElement?.target;
  WeakReference<Element>? _parentElement;

  void setParentElement(Element parentElement) {
    _parentElement = WeakReference(parentElement);
  }
}
