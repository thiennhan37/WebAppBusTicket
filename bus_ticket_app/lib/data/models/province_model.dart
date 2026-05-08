import 'package:json_annotation/json_annotation.dart';

part 'province_model.g.dart';

@JsonSerializable()
class ProvinceModel {
  final String id;
  final String name;

  ProvinceModel({
    required this.id,
    required this.name,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) =>
      _$ProvinceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProvinceModelToJson(this);
}