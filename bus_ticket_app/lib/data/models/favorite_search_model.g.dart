// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteSearchModel _$FavoriteSearchModelFromJson(Map<String, dynamic> json) =>
    FavoriteSearchModel(
      departureProvinceId: json['departureProvinceId'] as String,
      departureProvinceName: json['departureProvinceName'] as String,
      destinationProvinceId: json['destinationProvinceId'] as String,
      destinationProvinceName: json['destinationProvinceName'] as String,
      pickupStopId: (json['pickupStopId'] as num?)?.toInt(),
      pickupStopName: json['pickupStopName'] as String?,
      dropoffStopId: (json['dropoffStopId'] as num?)?.toInt(),
      dropoffStopName: json['dropoffStopName'] as String?,
      busCompanyId: json['busCompanyId'] as String,
      busCompanyName: json['busCompanyName'] as String,
      departureTime: json['departureTime'] as String,
    );

Map<String, dynamic> _$FavoriteSearchModelToJson(
        FavoriteSearchModel instance) =>
    <String, dynamic>{
      'departureProvinceId': instance.departureProvinceId,
      'departureProvinceName': instance.departureProvinceName,
      'destinationProvinceId': instance.destinationProvinceId,
      'destinationProvinceName': instance.destinationProvinceName,
      'pickupStopId': instance.pickupStopId,
      'pickupStopName': instance.pickupStopName,
      'dropoffStopId': instance.dropoffStopId,
      'dropoffStopName': instance.dropoffStopName,
      'busCompanyId': instance.busCompanyId,
      'busCompanyName': instance.busCompanyName,
      'departureTime': instance.departureTime,
    };
