part of 'node.dart';

extension NodeElementsX on Node {
  /// The Primary Element of the Node.
  ///
  /// `nil` is returned if Composition Data has not been received yet
  MeshElement? get primaryElement {
    if (!isCompositionDataReceived) {
      return null;
    }
    return elements.first;
  }

  // TODO: internal
  /// Adds given list of Elements to the Node.
  ///
  /// - parameter element: The list of Elements to be added.
  void addElements(List<MeshElement> elements) {
    for (var element in elements) {
      _addElement(element);
    }
  }

  // TODO: internal
  /// Adds the given Element to the Node.
  ///
  /// - parameter element: The Element to be added.
  void addElement(MeshElement element) {
    logger.f("MISSING IMPLEMENTATION");
  }

  void _addElement(MeshElement element) {
    final index = elements.length;
    elements.add(element);
    element.setParentNode(this);
    element.index = index;
  }

  /// Sets given list of Elements to the Node.
  ///
  /// Apart from simply replacing the Elements, this method copies properties of matching
  /// models from the old model to the new one. If at least one Model in the new Element
  /// was found in the new Element, the name of the Element is also copied.
  ///
  /// - parameter element: The new list of Elements to be added.
  void setElements(List<MeshElement> newElements) {
    // Look for matching Models. A matching model has the same Element index and Model id.

    final elementCount = math.min(elements.length, newElements.length);
    for (var e = 0; e < elementCount; e++) {
      final oldElement = elements[e];
      final newElement = newElements[e];

      final modelCount =
          math.min(oldElement.models.length, newElement.models.length);
      for (var m = 0; m < modelCount; m++) {
        final oldModel = oldElement.models[m];
        final newModel = newElement.models[m];
        if (oldModel.modelId == newModel.modelId) {
          newModel.applyFrom(oldModel);
          // If at least one Model matches, assume the Element didn't
          // change much and copy the name of it.
          if (oldElement.name != null) {
            newElement.name = oldElement.name;
          }
        }
      }
    }

    // Remove the old Elements.
    for (var element in elements) {
      element.setParentNode(null);
      element.index = 0;
    }
    elements.clear();

    // add new ones.
    addElements(newElements);
  }
}
