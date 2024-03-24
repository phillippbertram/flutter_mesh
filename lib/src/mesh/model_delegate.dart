// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/ModelDelegate.swift#L58

import 'package:async/async.dart';

import 'mesh_messages/mesh_message.dart';
import 'models/models.dart';
import 'types.dart';

typedef MessageComposer = MeshMessage Function();

/// Model delegate defines the functionality of a ``Model`` on the
/// Local Node.
///
/// Model Delegates are assigned to the Models during setting up
/// the ``MeshNetworkManager/localElements``.
///
/// The Model Delegate must declare a map of mesh message type
/// supported by this Model. Whenever a mesh message matching any
/// of the declared Op Codes is received, and the Model instance is bound
/// to the Application Key used to encrypt the message, one of the message
/// handlers will be called:
/// * ``ModelDelegate/model(_:didReceiveUnacknowledgedMessage:from:sentTo:)``
/// * ``ModelDelegate/model(_:didReceiveAcknowledgedMessage:from:sentTo:)``
/// * ``ModelDelegate/model(_:didReceiveResponse:toAcknowledgedMessage:from:)``
///
/// The Model Delegate also specifies should the Model support subscription
/// and defines publication composer for automatic publications.
mixin ModelDelegate {
  // NOTE: `Type` should be `MeshMessage` but it's not possible to use it as a type here
  Map<Uint32, Type> messageTypes = {};

  /// This method should handle the received Acknowledged Message.
  ///
  /// - parameters:
  ///   - model: The Model associated with this Model Delegate.
  ///   - request: The Acknowledged Message received.
  ///   - source:  The source Unicast Address.
  ///   - destination: The destination address of the request.
  /// - returns: The response message to be sent to the sender.
  /// - throws: The method should throw ``ModelError``
  ///           if the receive message is invalid and no response
  ///           should be replied.
  Result<MeshResponse> modelDidReceiveAcknowledgedMessage(
    MeshMessage message,
    Address source,
    Address destination,
  );

  /// This method should handle the received Unacknowledged Message.
  ///
  /// - parameters:
  ///   - model: The Model associated with this Model Delegate.
  ///   - message: The Unacknowledged Message received.
  ///   - source: The source Unicast Address.
  ///   - destination: The destination address of the request.
  Result<void> modelDidReceiveUnacknowledgedMessage(
    MeshMessage message,
    Address source,
    Address destination,
  );

  /// This method should handle the received response to the
  /// previously sent request.
  ///
  /// - parameters:
  ///   - model: The Model associated with this Model Delegate.
  ///   - response: The response received.
  ///   - request: The Acknowledged Message sent.
  ///   - source: The Unicast Address of the Element that sent the
  ///             response.
  Result<void> modelDidReceiveResponse(
    MeshMessage response,
    MeshMessage toAcknowledgedMessage,
    Address source,
  );
}
