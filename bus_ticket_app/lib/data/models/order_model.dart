import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String orderId;
  final String departureProvince;
  final String destinationProvince;
  final String departureTime;
  final String busCompanyName;
  final String orderStatus;
  final int totalCost;

  OrderModel({
    required this.orderId,
    required this.departureProvince,
    required this.destinationProvince,
    required this.departureTime,
    required this.busCompanyName,
    required this.orderStatus,
    required this.totalCost,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
