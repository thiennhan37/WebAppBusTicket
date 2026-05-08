// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_customer_profile_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCustomerProfileRequestModel _$UpdateCustomerProfileRequestModelFromJson(
        Map<String, dynamic> json) =>
    UpdateCustomerProfileRequestModel(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      dob: _dateFromJson(json['dob'] as String),
      gender: json['gender'] as String,
      idRegion: json['idRegion'] as String,
    );

Map<String, dynamic> _$UpdateCustomerProfileRequestModelToJson(
        UpdateCustomerProfileRequestModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'dob': _dateToJson(instance.dob),
      'gender': instance.gender,
      'idRegion': instance.idRegion,
    };
