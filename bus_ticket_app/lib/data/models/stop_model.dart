import 'package:json_annotation/json_annotation.dart';

part 'stop_model.g.dart';

@JsonSerializable()
class StopResponse {
  final int code;
  final String? message;
  final List<StopModel>? result;

  StopResponse({required this.code, this.message, this.result});

  factory StopResponse.fromJson(Map<String, dynamic> json) => _$StopResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StopResponseToJson(this);
}

@JsonSerializable()
class StopModel {
  final int id;
  final String name;
  final String address;
  final ProvinceInfo? province;

  StopModel({required this.id, required this.name, required this.address, this.province});

  factory StopModel.fromJson(Map<String, dynamic> json) => _$StopModelFromJson(json);
  Map<String, dynamic> toJson() => _$StopModelToJson(this);
}

@JsonSerializable()
class ProvinceInfo {
  final String id;
  final String name;

  ProvinceInfo({required this.id, required this.name});

  factory ProvinceInfo.fromJson(Map<String, dynamic> json) => _$ProvinceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ProvinceInfoToJson(this);
}
