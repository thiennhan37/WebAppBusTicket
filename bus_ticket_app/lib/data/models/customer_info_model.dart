import 'package:json_annotation/json_annotation.dart';

part 'customer_info_model.g.dart';

enum Gender { MALE, FEMALE, OTHER }

enum CustomerStatus { ACTIVE, INACTIVE }

@JsonSerializable()
class CustomerInfoModel {
  final String id;
  final String email;
  final String? phone;
  @JsonKey(name: 'fullName')
  final String? fullName;
  final String? dob;
  final String? gender;
  final String? status;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  final String? idRegion;

  CustomerInfoModel({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.dob,
    this.gender,
    this.status,
    this.createdAt,
    this.idRegion,
  });

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerInfoModelToJson(this);

  // Helper methods
  Gender? get genderEnum {
    if (gender == null) return null;
    return Gender.values.firstWhere(
      (e) => e.name == gender,
      orElse: () => Gender.OTHER,
    );
  }

  CustomerStatus? get statusEnum {
    if (status == null) return null;
    return CustomerStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => CustomerStatus.INACTIVE,
    );
  }

  String getDisplayName() => fullName ?? email;

  bool isActive() => status == 'ACTIVE';
}
