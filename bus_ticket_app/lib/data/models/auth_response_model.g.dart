// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String?,
      result: json['result'] == null
          ? null
          : AuthResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'result': instance.result,
    };

AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => AuthResult(
      customerInfo: CustomerInfoModel.fromJson(
          json['customerInfo'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$AuthResultToJson(AuthResult instance) =>
    <String, dynamic>{
      'customerInfo': instance.customerInfo,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
