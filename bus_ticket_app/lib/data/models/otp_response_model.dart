import 'package:json_annotation/json_annotation.dart';

part 'otp_response_model.g.dart';

@JsonSerializable()
class OtpResponseModel {
  final int code;
  final String? message;
  final dynamic result; // null khi gửi OTP

  OtpResponseModel({required this.code, this.message, this.result});

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpResponseModelToJson(this);

  // Helper methods
  bool get isSuccess => code == 0;

  bool get isEmailNotFound => code == 4021;
}
