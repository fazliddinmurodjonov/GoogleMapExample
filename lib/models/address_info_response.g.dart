// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressInfoResponse _$AddressInfoResponseFromJson(Map<String, dynamic> json) => AddressInfoResponse(
      displayName: json['display_name'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      country: json['country'] as String,
    );
