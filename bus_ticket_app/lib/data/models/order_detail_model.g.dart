// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailModel _$OrderDetailModelFromJson(Map<String, dynamic> json) =>
    OrderDetailModel(
      bookingOrderId: json['bookingOrderId'] as String,
      pickupProvince: json['pickupProvince'] as String,
      dropoffProvince: json['dropoffProvince'] as String,
      pickupStop: json['pickupStop'] as String,
      dropoffStop: json['dropoffStop'] as String,
      busCompanyName: json['busCompanyName'] as String,
      departureTime: json['departureTime'] as String,
      busType: json['busType'] as String,
      seatCount: (json['seatCount'] as num).toInt(),
      seatCodes:
          (json['seatCodes'] as List<dynamic>).map((e) => e as String).toList(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String,
    );

Map<String, dynamic> _$OrderDetailModelToJson(OrderDetailModel instance) =>
    <String, dynamic>{
      'bookingOrderId': instance.bookingOrderId,
      'pickupProvince': instance.pickupProvince,
      'dropoffProvince': instance.dropoffProvince,
      'pickupStop': instance.pickupStop,
      'dropoffStop': instance.dropoffStop,
      'busCompanyName': instance.busCompanyName,
      'departureTime': instance.departureTime,
      'busType': instance.busType,
      'seatCount': instance.seatCount,
      'seatCodes': instance.seatCodes,
      'totalAmount': instance.totalAmount,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
    };
