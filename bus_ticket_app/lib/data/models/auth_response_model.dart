import 'package:json_annotation/json_annotation.dart';
import 'customer_info_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final int code;
  final String? message;
  final AuthResult? result;

  AuthResponseModel({required this.code, this.message, this.result});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  // Helper methods
  bool get isSuccess => code == 0;

  bool get isInvalidOtp => code == 4022;

  // Easy getters
  String? get accessToken => result?.accessToken;

  String? get refreshToken => result?.refreshToken;

  CustomerInfoModel? get customerInfo => result?.customerInfo;
}

@JsonSerializable()
class AuthResult {
  @JsonKey(name: 'customerInfo')
  final CustomerInfoModel customerInfo;

  @JsonKey(name: 'accessToken')
  final String accessToken;

  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  AuthResult({
    required this.customerInfo,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResultToJson(this);
}
