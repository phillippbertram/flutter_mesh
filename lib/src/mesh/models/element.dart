import 'package:dart_mesh/src/mesh/models/node.dart';
import 'model.dart'; // Assuming you have a Model class defined somewhere
import 'location.dart'; // Assuming you have a Location enum or class defined

// TODO: JSON Serialization + Equatable
class Element {
  Element._({
    this.name,
    required this.location,
    required this.models,
    required this.index,
  });

  static Element create({
    String? name,
    required Location location,
    required List<Model> models,
  }) {
    final element = Element._(
      name: name,
      location: location,
      models: models,
      // Set temporary index.
      // Final index will be set when Element is added to the Node.
      index: 0,
    );

    // Set parentElement for each model.
    for (final model in models) {
      model.setParentElement(element);
    }

    return element;
  }

  final String? name;
  final int index;
  final Location location;
  final List<Model> models;

  Node? get parentNode => _parentNode?.target;
  WeakReference<Node>? _parentNode;
  void setParentNode(Node parentNode) {
    _parentNode = WeakReference(parentNode);
  }
}

// TODO:
extension ElementX on Element {
  //  /// Adds given model to the Element.
  //   ///
  //   /// - parameter model: The model to be added.
  //   func add(model: Model) {
  //       models.append(model)
  //       model.parentElement = self
  //   }

  //   /// Inserts the given model to the Element at the specified position.
  //   ///
  //   /// - parameter model: The model to be added.
  //   func insert(model: Model, at i: Int) {
  //       models.insert(model, at: i)
  //       model.parentElement = self
  //   }

  //   /// This methods adds the natively supported Models to the Element.
  //   ///
  //   /// This method should only be called for the primary Element of the
  //   /// local Node.
  //   ///
  //   /// - parameter meshNetwork: The mesh network object.
  //   func addPrimaryElementModels(_ meshNetwork: MeshNetwork) {
  //       guard isPrimary else { return }
  //       insert(model: Model(sigModelId: .configurationServerModelId,
  //                           delegate: ConfigurationServerHandler(meshNetwork)), at: 0)
  //       insert(model: Model(sigModelId: .configurationClientModelId,
  //                           delegate: ConfigurationClientHandler(meshNetwork)), at: 1)
  //       insert(model: Model(sigModelId: .healthServerModelId), at: 2)
  //       insert(model: Model(sigModelId: .healthClientModelId), at: 3)
  //       insert(model: Model(sigModelId: .privateBeaconClientModelId,
  //                           delegate: PrivateBeaconClientHandler(meshNetwork)), at: 4)
  //       insert(model: Model(sigModelId: .sarConfigurationClientModelId,
  //                           delegate: SarConfigurationClientHandler(meshNetwork)), at: 5)
  //       insert(model: Model(sigModelId: .remoteProvisioningClientModelId,
  //                           delegate: RemoteProvisioningClientHandler(meshNetwork)), at: 6)
  //       insert(model: Model(sigModelId: .sceneClientModelId,
  //                           delegate: SceneClientHandler(meshNetwork)), at: 7)
  //   }

  //   /// Removes the models that are or should be supported natively.
  //   func removePrimaryElementModels() {
  //       models = models.filter { model in
  //           // Health models are not yet supported.
  //           !model.isHealthServer &&
  //           !model.isHealthClient &&
  //           // The library supports Scene Client model natively.
  //           !model.isSceneClient &&
  //           // The models that require Device Key should not be managed by users.
  //           // Some of them are supported natively in the library.
  //           !model.requiresDeviceKey
  //       }
  //   }

  //   /// The primary Element for Provisioner's Node.
  //   ///
  //   /// The Element will contain all mandatory Models (Configuration Server
  //   /// and Health Server) and supported clients (Configuration Client
  //   /// and Health Client).
  //   static var primaryElement: Element {
  //       // The Provisioner will always have a first Element with obligatory
  //       // Models.
  //       let element = Element(location: .unknown)
  //       element.name = "Primary Element"
  //       // Configuration Server is required for all nodes.
  //       element.add(model: Model(sigModelId: .configurationServerModelId))
  //       // Configuration Client is added, as this is a Provisioner's node.
  //       element.add(model: Model(sigModelId: .configurationClientModelId))
  //       // Health Server is required for all nodes.
  //       element.add(model: Model(sigModelId: .healthServerModelId))
  //       // Health Client is added, as this is a Provisioner's node.
  //       element.add(model: Model(sigModelId: .healthClientModelId))
  //       return element
  //   }
}
