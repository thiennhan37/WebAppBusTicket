import 'package:json_annotation/json_annotation.dart';

part 'favorite_search_model.g.dart';

@JsonSerializable()
class FavoriteSearchModel {
  final String departureProvinceId;
  final String departureProvinceName;
  final String destinationProvinceId;
  final String destinationProvinceName;
  final int? pickupStopId;
  final String? pickupStopName;
  final int? dropoffStopId;
  final String? dropoffStopName;
  final String busCompanyId;
  final String busCompanyName;
  final String departureTime;

  FavoriteSearchModel({
    required this.departureProvinceId,
    required this.departureProvinceName,
    required this.destinationProvinceId,
    required this.destinationProvinceName,
    this.pickupStopId,
    this.pickupStopName,
    this.dropoffStopId,
    this.dropoffStopName,
    required this.busCompanyId,
    required this.busCompanyName,
    required this.departureTime,
  });

  factory FavoriteSearchModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteSearchModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteSearchModelToJson(this);
}