// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpResponseModel _$OtpResponseModelFromJson(Map<String, dynamic> json) =>
    OtpResponseModel(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String?,
      result: json['result'],
    );

Map<String, dynamic> _$OtpResponseModelToJson(OtpResponseModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'result': instance.result,
    };
