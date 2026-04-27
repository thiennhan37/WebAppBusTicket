// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRegisterRequestModel _$CustomerRegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    CustomerRegisterRequestModel(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      dob: json['dob'] as String,
      idRegion: json['idRegion'] as String,
    );

Map<String, dynamic> _$CustomerRegisterRequestModelToJson(
        CustomerRegisterRequestModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'idRegion': instance.idRegion,
      'dob': instance.dob,
    };
