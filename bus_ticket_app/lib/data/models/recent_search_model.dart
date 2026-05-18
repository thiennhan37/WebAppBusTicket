import 'package:json_annotation/json_annotation.dart';

part 'recent_search_model.g.dart';

@JsonSerializable()
class RecentSearchModel {
  final String departureName;
  final String destinationName;
  final String departureId;
  final String destinationId;
  final String date;
  final bool isRoundTrip;
  final String? endDate;

  RecentSearchModel({
    required this.departureName,
    required this.destinationName,
    required this.departureId,
    required this.destinationId,
    required this.date,
    this.isRoundTrip = false,
    this.endDate,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) =>
      _$RecentSearchModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecentSearchModelToJson(this);
}
