import 'package:freezed_annotation/freezed_annotation.dart';

part 'provisioner.freezed.dart';
part 'provisioner.g.dart';

@freezed
class Provisioner with _$Provisioner {
  const factory Provisioner({
    required String uuid,
    required String name,
  }) = _Provisioner;

  factory Provisioner.fromJson(Map<String, dynamic> json) =>
      _$ProvisionerFromJson(json);
}
