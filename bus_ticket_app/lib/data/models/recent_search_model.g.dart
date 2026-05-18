// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentSearchModel _$RecentSearchModelFromJson(Map<String, dynamic> json) =>
    RecentSearchModel(
      departureName: json['departureName'] as String,
      destinationName: json['destinationName'] as String,
      departureId: json['departureId'] as String,
      destinationId: json['destinationId'] as String,
      date: json['date'] as String,
      isRoundTrip: json['isRoundTrip'] as bool? ?? false,
      endDate: json['endDate'] as String?,
    );

Map<String, dynamic> _$RecentSearchModelToJson(RecentSearchModel instance) =>
    <String, dynamic>{
      'departureName': instance.departureName,
      'destinationName': instance.destinationName,
      'departureId': instance.departureId,
      'destinationId': instance.destinationId,
      'date': instance.date,
      'isRoundTrip': instance.isRoundTrip,
      'endDate': instance.endDate,
    };
