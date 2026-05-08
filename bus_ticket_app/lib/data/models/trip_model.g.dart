// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
      id: json['tripId'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '--:--',
      arrivalTime: json['arrivalTime'] as String? ?? '--:--',
      duration: json['duration'] as String? ?? '',
      departureStation: json['departureStation'] as String? ?? '',
      arrivalStation: json['arrivalStation'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
      busCompanyName: json['busCompanyName'] as String? ?? 'Chưa rõ nhà xe',
      busType: json['busType'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
      'tripId': instance.id,
      'departureTime': instance.departureTime,
      'arrivalTime': instance.arrivalTime,
      'duration': instance.duration,
      'departureStation': instance.departureStation,
      'arrivalStation': instance.arrivalStation,
      'price': instance.price,
      'availableSeats': instance.availableSeats,
      'busCompanyName': instance.busCompanyName,
      'busType': instance.busType,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
    };
