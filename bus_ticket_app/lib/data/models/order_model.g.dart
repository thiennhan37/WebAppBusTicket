// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      orderId: json['orderId'] as String,
      departureProvince: json['departureProvince'] as String,
      destinationProvince: json['destinationProvince'] as String,
      departureTime: json['departureTime'] as String,
      busCompanyName: json['busCompanyName'] as String,
      orderStatus: json['orderStatus'] as String,
      totalCost: (json['totalCost'] as num).toInt(),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'departureProvince': instance.departureProvince,
      'destinationProvince': instance.destinationProvince,
      'departureTime': instance.departureTime,
      'busCompanyName': instance.busCompanyName,
      'orderStatus': instance.orderStatus,
      'totalCost': instance.totalCost,
    };
