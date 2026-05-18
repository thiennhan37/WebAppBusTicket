import 'package:json_annotation/json_annotation.dart';

part 'order_detail_model.g.dart';

@JsonSerializable()
class OrderDetailModel {
  final String bookingOrderId;
  final String pickupProvince;
  final String dropoffProvince;
  final String pickupStop;
  final String dropoffStop;
  final String busCompanyName;
  final String departureTime;
  final String busType;
  final int seatCount;
  final List<String> seatCodes;
  final int totalAmount;
  final String contactName;
  final String contactPhone;
  final String contactEmail;

  OrderDetailModel({
    required this.bookingOrderId,
    required this.pickupProvince,
    required this.dropoffProvince,
    required this.pickupStop,
    required this.dropoffStop,
    required this.busCompanyName,
    required this.departureTime,
    required this.busType,
    required this.seatCount,
    required this.seatCodes,
    required this.totalAmount,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => _$OrderDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailModelToJson(this);
}
