// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopResponse _$StopResponseFromJson(Map<String, dynamic> json) => StopResponse(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String?,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => StopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StopResponseToJson(StopResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'result': instance.result,
    };

StopModel _$StopModelFromJson(Map<String, dynamic> json) => StopModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      province: json['province'] == null
          ? null
          : ProvinceInfo.fromJson(json['province'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StopModelToJson(StopModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'province': instance.province,
    };

ProvinceInfo _$ProvinceInfoFromJson(Map<String, dynamic> json) => ProvinceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ProvinceInfoToJson(ProvinceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
