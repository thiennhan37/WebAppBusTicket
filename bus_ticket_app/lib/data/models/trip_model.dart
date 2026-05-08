import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake) // Tự động thử cả snake_case (ví dụ: departure_time)
class TripModel {
  @JsonKey(name: 'tripId', defaultValue: '')
  final String id;

  @JsonKey(name: 'departureTime', defaultValue: '--:--')
  final String departureTime;

  @JsonKey(name: 'arrivalTime', defaultValue: '--:--')
  final String arrivalTime;

  @JsonKey(name: 'duration', defaultValue: '')
  final String duration;

  @JsonKey(name: 'departureStation', defaultValue: '')
  final String departureStation;

  @JsonKey(name: 'arrivalStation', defaultValue: '')
  final String arrivalStation;

  @JsonKey(name: 'price', defaultValue: 0)
  final int price;

  @JsonKey(name: 'availableSeats', defaultValue: 0)
  final int availableSeats;

  @JsonKey(name: 'busCompanyName', defaultValue: 'Chưa rõ nhà xe')
  final String busCompanyName;

  @JsonKey(name: 'busType', defaultValue: '')
  final String busType;

  @JsonKey(name: 'rating', defaultValue: 0.0)
  final double rating;

  @JsonKey(name: 'reviewCount', defaultValue: 0)
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
