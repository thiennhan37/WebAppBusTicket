import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

@JsonSerializable()
class TripModel {
  final String id;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String departureStation;
  final String arrivalStation;
  final int price;
  final int availableSeats;
  final String busCompanyName;
  final String busType;
  final double rating;
  final int reviewCount;

  TripModel({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.departureStation,
    required this.arrivalStation,
    required this.price,
    required this.availableSeats,
    required this.busCompanyName,
    required this.busType,
    required this.rating,
    required this.reviewCount,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);
}