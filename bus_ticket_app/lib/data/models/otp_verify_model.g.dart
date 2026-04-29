// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerifyModel _$OtpVerifyModelFromJson(Map<String, dynamic> json) =>
    OtpVerifyModel(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$OtpVerifyModelToJson(OtpVerifyModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otp': instance.otp,
    };
