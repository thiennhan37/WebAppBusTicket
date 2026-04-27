import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_model.g.dart';

@JsonSerializable()
class OtpVerifyModel {
  final String email;
  final String otp;

  OtpVerifyModel({required this.email, required this.otp});

  factory OtpVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyModelToJson(this);
}
