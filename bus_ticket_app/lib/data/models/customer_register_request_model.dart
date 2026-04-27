import 'package:json_annotation/json_annotation.dart';

part 'customer_register_request_model.g.dart';

@JsonSerializable()
class CustomerRegisterRequestModel {
  @JsonKey(name: 'fullName')
  final String fullName;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'idRegion')
  final String idRegion;

  @JsonKey(name: 'dob')
  final String dob;

  CustomerRegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.idRegion,
  });

  factory CustomerRegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerRegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerRegisterRequestModelToJson(this);
}
