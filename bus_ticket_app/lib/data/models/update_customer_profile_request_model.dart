// lib/data/models/update_customer_profile_request_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

// Bắt buộc phải có dòng này để build_runner tạo file .g.dart
part 'update_customer_profile_request_model.g.dart';

@JsonSerializable()
class UpdateCustomerProfileRequestModel {
  final String fullName;
  final String phone;
  final String email;

  // Custom serialize/deserialize cho DateTime sang định dạng dd/MM/yyyy
  @JsonKey(toJson: _dateToJson, fromJson: _dateFromJson)
  final DateTime dob;

  final String gender;
  final String idRegion;

  UpdateCustomerProfileRequestModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.dob,
    required this.gender,
    required this.idRegion,
  });

  factory UpdateCustomerProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateCustomerProfileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCustomerProfileRequestModelToJson(this);
}

// --- Helper Functions xử lý Format Ngày Tháng ---
String _dateToJson(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

DateTime _dateFromJson(String dateStr) {
  return DateFormat('dd/MM/yyyy').parse(dateStr);
}