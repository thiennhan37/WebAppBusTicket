// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
      id: json['id'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      duration: json['duration'] as String,
      departureStation: json['departureStation'] as String,
      arrivalStation: json['arrivalStation'] as String,
      price: (json['price'] as num).toInt(),
      availableSeats: (json['availableSeats'] as num).toInt(),
      busCompanyName: json['busCompanyName'] as String,
      busType: json['busType'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
    );

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
      'id': instance.id,
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
