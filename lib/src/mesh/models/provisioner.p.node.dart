part of 'provisioner.dart';

extension ProvisionerNodeX on Provisioner {
  /// The Provisioner's Node, if such exists, otherwise `nil`.
  Node? get node {
    return meshNetwork?.nodeForProvisioner(this);
  }
}
